import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';

class ExchangeProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<PostModel> _posts = [];
  List<RequestModel> _requests = [];
  final Map<String, Map<String, dynamic>> _requestDetails = {};

  final Map<String, RequestModel> _postRequests = {};
  final Map<String, UserModel> _postReceivers = {};

  bool _isLoading = false;

  List<PostModel> get posts => _posts;
  List<RequestModel> get requests => _requests;
  Map<String, Map<String, dynamic>> get requestDetails => _requestDetails;

  RequestModel? getRequestForPost(String postId) => _postRequests[postId];
  UserModel? getReceiverForPost(String postId) => _postReceivers[postId];

  bool get isLoading => _isLoading;

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

      final futures = _requests.map((request) async {
        if (!_requestDetails.containsKey(request.postId)) {
          final detailsResult = await _databaseService
              .getRequestDetailsByPostId(request.postId);
          if (detailsResult.isSuccess && detailsResult.data != null) {
            _requestDetails[request.postId] = detailsResult.data!;
          }
        }
      });

      await Future.wait(futures);
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
        // change to cancelled
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
}
