import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/services/media_service.dart';
import 'package:project/core/utils/result.dart';

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
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.getMyPosts(userId);
    if (result.isSuccess) {
      _posts = result.data ?? [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyRequests(String userId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.getMyRequests(userId);
    if (result.isSuccess) {
      _requests = result.data ?? [];

      for (var req in _requests) {
        final detailsResult = await _databaseService.getRequestDetailsByPostId(
          req.postId,
        );
        if (detailsResult.isSuccess && detailsResult.data != null) {
          _requestDetails[req.postId] = detailsResult.data!;
        }
      }
    }

    _isLoading = false;
    notifyListeners();
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

    if (result.isSuccess) {
      _posts.insert(0, post);
      notifyListeners();
    }

    return result;
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

  Future<dynamic> createRequest(RequestModel request) async {
    final result = await _databaseService.createRequest(request);

    if (result.isSuccess) {
      _requests.insert(0, result.data!);
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
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<void> fetchInboundRequestforPost(String postId) async {
    _isLoading = true;
    _inboundRequests.remove(postId);
    notifyListeners();

    final result = await _databaseService.getRequestsForPost(postId);
    if (result.isSuccess) {
      _inboundRequests[postId] = result.data ?? [];

      for (var req in _inboundRequests[postId]!) {
        if (!_cachedRequesters.containsKey(req.requesterId)) {
          final userResult = await _databaseService.getUserById(
            req.requesterId,
          );
          if (userResult.isSuccess && userResult.data != null) {
            _cachedRequesters[req.requesterId] = userResult.data!;
          }
        }
      }
    }

    _isLoading = false;
    notifyListeners();
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
      if (postIndex != -1) {
        final oldPost = _posts[postIndex];
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
    }

    _isLoading = false;
    notifyListeners();
    return result;
  }

  Future<dynamic> rejectRequest(String requestId, String postId) async {
    _isLoading = true;
    notifyListeners();

    final result = await _databaseService.rejectRequest(requestId);

    if (result.isSuccess) {
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
      // Update local posts list
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
      notifyListeners();
    }

    return result;
  }
}
