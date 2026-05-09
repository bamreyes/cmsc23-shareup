import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';

class FeedProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<PostModel> _posts = [];
  final Map<String, UserModel> _users = {};
  bool _isLoading = false;
  String? _error;

  List<PostModel> get posts => _posts;
  UserModel? getUser(String userId) => _users[userId];
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _databaseService.getAllPosts();

    if (result.isSuccess) {
      _posts = result.data ?? [];
    } else {
      _error = result.error;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchUser(String userId) async {
    if (_users.containsKey(userId)) return;
    
    final result = await _databaseService.getUserById(userId);
    if (result.isSuccess && result.data != null) {
      _users[userId] = result.data!;
      notifyListeners();
    }
  }
}

final feedProvider = FeedProvider();
