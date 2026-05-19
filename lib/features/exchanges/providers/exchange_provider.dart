import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/services/media_service.dart';
import 'package:project/core/utils/result.dart';
import 'package:project/core/models/notification_model.dart';
import 'package:project/core/services/push_notification_service.dart';

class ExchangeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final LocationService _locationService = LocationService();
  final MediaService _mediaService = MediaService();

  List<PostModel> _posts = [];
  List<RequestModel> _requests = [];
  final Map<String, Map<String, dynamic>> _requestDetails = {};

  final Map<String, RequestModel> _postRequests = {};
  final Map<String, UserModel> _postReceivers = {};

  final Map<String, List<RequestModel>> _inboundRequests = {};
  final Map<String, UserModel> _cachedRequesters = {};

  bool _isLoading = false;

  StreamSubscription<List<PostModel>>? _postsSubscription;
  StreamSubscription<List<RequestModel>>? _requestsSubscription;
  final Map<String, StreamSubscription<List<RequestModel>>>
  _inboundSubscriptions = {};

  List<PostModel> get posts => _posts;
  List<RequestModel> get requests => _requests;
  Map<String, Map<String, dynamic>> get requestDetails => _requestDetails;

  RequestModel? getRequestForPost(String postId) => _postRequests[postId];
  UserModel? getReceiverForPost(String postId) => _postReceivers[postId];

  List<RequestModel> getInboundRequestsForPost(String postId) =>
      _inboundRequests[postId] ?? [];
  UserModel? getCachedRequester(String userId) => _cachedRequesters[userId];

  bool get isLoading => _isLoading;

  Future<Result<File>> pickImage(ImageSource source) async {
    return await _mediaService.pickImage(source);
  }

  Future<Result<Map<String, dynamic>>> detectCurrentLocation() async {
    final posResult = await _locationService.getCurrentLocation();
    if (posResult.isError) {
      return Result.error(posResult.error ?? 'Failed to get location');
    }

    final position = posResult.data!;
    final addressResult = await _locationService.getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (addressResult.isError) {
      return Result.success({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'address': 'Unknown Location',
      });
    }

    return Result.success({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': addressResult.data!,
    });
  }

  Future<void> fetchMyPosts(String userId) async {
    await _postsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _postsSubscription = _databaseService
        .getMyPostsStream(userId)
        .listen(
          (fetchedPosts) async {
            _posts = fetchedPosts;

            for (var post in _posts) {
              if (post.status == PostStatus.reserved ||
                  post.status == PostStatus.completed) {
                _fetchReceiverForPostRealTime(post);
              }
            }

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Error in posts stream: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> _fetchReceiverForPostRealTime(PostModel post) async {
    if (post.id == null) return;
    final requestResult = await _databaseService.getRequestByPostId(post.id!);
    if (requestResult.isSuccess && requestResult.data != null) {
      final request = requestResult.data!;
      _postRequests[post.id!] = request;

      final userResult = await _databaseService.getUserById(
        request.requesterId,
      );
      if (userResult.isSuccess && userResult.data != null) {
        _postReceivers[post.id!] = userResult.data!;
      }
    } else if (post.receiverId != null) {
      final userResult = await _databaseService.getUserById(post.receiverId!);
      if (userResult.isSuccess && userResult.data != null) {
        _postReceivers[post.id!] = userResult.data!;
      }
    }
    notifyListeners();
  }

  Future<void> fetchMyRequests(String userId) async {
    await _requestsSubscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _requestsSubscription = _databaseService
        .getMyRequestsStream(userId)
        .listen(
          (fetchedRequests) async {
            _requests = fetchedRequests;

            for (var req in _requests) {
              final detailsResult = await _databaseService
                  .getRequestDetailsByPostId(req.postId);
              if (detailsResult.isSuccess && detailsResult.data != null) {
                _requestDetails[req.postId] = detailsResult.data!;
              }
            }

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Error in requests stream: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  Future<void> fetchReceiverForPost(PostModel post) async {
    if (post.status != PostStatus.reserved || post.id == null) return;

    // Skip if already fetched
    if (_postReceivers.containsKey(post.id)) return;

    bool fetchedUser = false;
    final requestResult = await _databaseService.getRequestByPostId(post.id!);
    if (requestResult.isSuccess && requestResult.data != null) {
      final request = requestResult.data!;
      _postRequests[post.id!] = request;

      final userResult = await _databaseService.getUserById(
        request.requesterId,
      );
      if (userResult.isSuccess && userResult.data != null) {
        _postReceivers[post.id!] = userResult.data!;
        fetchedUser = true;
      }
    }

    if (!fetchedUser && post.receiverId != null) {
      final userResult = await _databaseService.getUserById(post.receiverId!);
      if (userResult.isSuccess && userResult.data != null) {
        _postReceivers[post.id!] = userResult.data!;
      }
    }

    notifyListeners();
  }

  /// Creates a new post in Firestore
  Future<Result<bool>> createPost(PostModel post) async {
    final result = await _databaseService.createPost(post);

    if (result.isSuccess && result.data != null) {
      final postId = result.data!;
      final newPost = post.copyWith(id: postId);
      _posts.insert(0, newPost);
      notifyListeners();

      _notifyUsersOfNewPost(newPost);
      return Result.success(true);
    }

    return Result.error(result.error ?? 'Failed to create post');
  }

  Future<void> _notifyUsersOfNewPost(PostModel post) async {
    try {
      final usersResult = await _databaseService.getAllUsers();
      if (usersResult.isError || usersResult.data == null) return;

      final users = usersResult.data!;
      for (var user in users) {
        if (user.uid == post.userId) continue;
        if (!user.notificationPreferences.newPost) continue;

        final distanceResult = _locationService.getDistance(
          startLatitude: post.latitude,
          startLongitude: post.longitude,
          endLatitude: user.latitude,
          endLongitude: user.longitude,
        );
        if (distanceResult.isError || distanceResult.data == null) continue;
        final distanceInKm = distanceResult.data!;
        if (distanceInKm > user.discoveryRadius) continue;

        bool isTagMatch = true;
        if (user.dietaryTags.isNotEmpty) {
          isTagMatch = post.dietaryTags.any(
            (tag) => user.dietaryTags.contains(tag),
          );
        }

        if (!isTagMatch) continue;

        if (user.uid != null && post.id != null) {
          await _databaseService.createNotification(
            userId: user.uid!,
            type: NotificationType.newPost.name,
            message: 'A new listing matching your preferences is available nearby: ${post.name}!',
            postId: post.id!,
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to send new post notifications: $e');
    }
  }

  Future<Result<bool>> deletePost(String postId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.deletePost(postId);

    if (result.isSuccess) {
      _posts.removeWhere((p) => p.id == postId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<dynamic> createRequest(
    RequestModel request, {
    required String sellerId,
    required String itemNavigatorName,
    required String requesterName,
  }) async {
    final result = await _databaseService.createRequest(request);

    if (result.isSuccess && result.data != null) {
      final createdRequest = result.data!;
      _requests.insert(0, createdRequest);
      if (createdRequest.id != null) {
        await _databaseService.createNotification(
          userId: sellerId,
          type: NotificationType.requestReceived.name,
          message: '$requesterName has requested your $itemNavigatorName. Tap to view the request.',
          postId: createdRequest.postId,
          requestId: createdRequest.id!,
        );
      }
      notifyListeners();
    }

    return result;
  }

  Future<dynamic> cancelRequest(String requestId, String postId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.cancelRequest(requestId, postId);

    if (result.isSuccess) {
      final index = _requests.indexWhere((request) => request.id == requestId);
      if (index != -1) {
        final oldReq = _requests[index];
        _requests[index] = RequestModel(
          id: oldReq.id,
          postId: oldReq.postId,
          requesterId: oldReq.requesterId,
          pickupDatetime: oldReq.pickupDatetime,
          message: oldReq.message,
          status: RequestStatus.cancelled,
          createdAt: oldReq.createdAt,
        );
      }

      // Cancel scheduled reminders for both Owner and Requester
      PushNotificationService().cancelPickupReminder(requestId, true);
      PushNotificationService().cancelPickupReminder(requestId, false);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> fetchInboundRequestforPost(String postId) async {
    await _inboundSubscriptions[postId]?.cancel();
    _isLoading = true;
    notifyListeners();

    _inboundSubscriptions[postId] = _databaseService
        .getInboundRequestsStream(postId)
        .listen(
          (fetched) async {
            _inboundRequests[postId] = fetched;

            // Cache requester profile details
            for (var req in fetched) {
              if (!_cachedRequesters.containsKey(req.requesterId)) {
                final userResult = await _databaseService.getUserById(
                  req.requesterId,
                );
                if (userResult.isSuccess && userResult.data != null) {
                  _cachedRequesters[req.requesterId] = userResult.data!;
                }
              }
            }

            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            debugPrint("Error in inbound requests stream: $error");
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _requestsSubscription?.cancel();
    for (var sub in _inboundSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }

  Future<Result<bool>> acceptRequest(
    String requestId,
    String postId,
    String requesterId,
  ) async {
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.acceptRequest(requestId, postId);

    if (result.isSuccess) {
      final postIndex = _posts.indexWhere((p) => p.id == postId);
      String itemName = 'item';

      if (postIndex != -1) {
        final oldPost = _posts[postIndex];
        itemName = oldPost.name;
        _posts[postIndex] = PostModel(
          id: oldPost.id,
          userId: oldPost.userId,
          name: oldPost.name,
          description: oldPost.description,
          image: oldPost.image,
          expirationDate: oldPost.expirationDate,
          dietaryTags: oldPost.dietaryTags,
          latitude: oldPost.latitude,
          longitude: oldPost.longitude,
          locationName: oldPost.locationName,
          status: PostStatus.reserved,
          receiverId: requesterId,
          qrCode: oldPost.qrCode,
          createdAt: oldPost.createdAt,
          updatedAt: DateTime.now(),
        );
      }

      if (_inboundRequests.containsKey(postId)) {
        _inboundRequests[postId] = _inboundRequests[postId]!.map((req) {
          if (req.id == requestId) {
            final acceptedReq = RequestModel(
              id: req.id,
              postId: req.postId,
              requesterId: req.requesterId,
              pickupDatetime: req.pickupDatetime,
              message: req.message,
              status: RequestStatus.accepted,
              createdAt: req.createdAt,
            );
            _postRequests[postId] = acceptedReq;

            // Schedule pickup reminder for the Owner (1 hour before pickup)
            PushNotificationService().schedulePickupReminder(
              requestId: requestId,
              itemName: itemName,
              pickupDatetime: req.pickupDatetime,
              isOwner: true,
            );

            return acceptedReq;
          } else if (req.status == RequestStatus.pending) {
            return RequestModel(
              id: req.id,
              postId: req.postId,
              requesterId: req.requesterId,
              pickupDatetime: req.pickupDatetime,
              message: req.message,
              status: RequestStatus.rejected,
              createdAt: req.createdAt,
            );
          }
          return req;
        }).toList();
      }

      if (_cachedRequesters.containsKey(requesterId)) {
        _postReceivers[postId] = _cachedRequesters[requesterId]!;
      }

      await _databaseService.createNotification(
        userId: requesterId,
        type: NotificationType.requestAccepted.name,
        message: 'Your request for $itemName has been approved! View details here.',
        postId: postId,
        requestId: requestId,
      );
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<dynamic> rejectRequest(String requestId, String postId) async {
    _isLoading = true;
    notifyListeners();

    final targetRequest = _inboundRequests[postId]?.firstWhere(
      (req) => req.id == requestId,
    );
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    final itemName = postIndex != -1 ? _posts[postIndex].name : 'an item';

    final result = await _databaseService.rejectRequest(requestId);

    if (result.isSuccess) {
      if (targetRequest != null) {
        await _databaseService.createNotification(
          userId: targetRequest.requesterId,
          type: NotificationType.requestRejected.name,
          message: 'Your request for $itemName was unfortunately declined.',
          postId: postId,
          requestId: requestId,
        );
      }

      _inboundRequests[postId]?.removeWhere((req) => req.id == requestId);
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<Result<String>> completePostByQr({
    required String postId,
    required String scannerId,
  }) async {
    final result = await _databaseService.completePostByQr(
      postId: postId,
      scannerId: scannerId,
    );

    if (result.isSuccess) {
      final idx = _posts.indexWhere((p) => p.id == postId);
      if (idx != -1) {
        final old = _posts[idx];
        _posts[idx] = PostModel(
          id: old.id,
          userId: old.userId,
          name: old.name,
          description: old.description,
          image: old.image,
          expirationDate: old.expirationDate,
          dietaryTags: old.dietaryTags,
          latitude: old.latitude,
          longitude: old.longitude,
          locationName: old.locationName,
          status: PostStatus.completed,
          receiverId: old.receiverId,
          qrCode: old.qrCode,
          createdAt: old.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      final acceptedReq = _postRequests[postId];
      if (acceptedReq != null && acceptedReq.id != null) {
        PushNotificationService().cancelPickupReminder(acceptedReq.id!, true);
        PushNotificationService().cancelPickupReminder(acceptedReq.id!, false);
      }

      notifyListeners();
    }

    return result;
  }
}
