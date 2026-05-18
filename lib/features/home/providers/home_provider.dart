import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';

class LeaderboardEntry {
  final UserModel user;
  final int count;

  LeaderboardEntry({
    required this.user,
    required this.count,
  });
}

class HomeProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();

  int _postCount = 0;
  int _requestCount = 0;
  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<PostModel>>? _leaderboardSubscription;

  HomeProvider() {
    initLeaderboardListener();
  }

  void initLeaderboardListener() {
    if (_leaderboardSubscription != null) return;

    _leaderboardSubscription =
        _db.getCompletedPostsStream().listen((posts) async {
      try {
        final Map<String, int> userCompletedCounts = {};
        for (var post in posts) {
          if (post.userId.isNotEmpty) {
            userCompletedCounts[post.userId] =
                (userCompletedCounts[post.userId] ?? 0) + 1;
          }
        }

        final sortedEntries = userCompletedCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        final top10Entries = sortedEntries.take(10).toList();

        final List<LeaderboardEntry> leaderboardList = [];
        for (var entry in top10Entries) {
          final userResult = await _db.getUserById(entry.key);
          if (userResult.isSuccess && userResult.data != null) {
            leaderboardList.add(LeaderboardEntry(
              user: userResult.data!,
              count: entry.value,
            ));
          }
        }

        _leaderboard = leaderboardList;
        notifyListeners();
      } catch (e) {
        debugPrint('Error updating leaderboard real-time: $e');
      }
    });
  }

  @override
  void dispose() {
    _leaderboardSubscription?.cancel();
    super.dispose();
  }

  int get postCount => _postCount;
  int get requestCount => _requestCount;
  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchStats(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        getPostCount(userId),
        getRequestCount(userId),
        getLeaderboard(),
      ]);
      _postCount = results[0] as int;
      _requestCount = results[1] as int;
      _leaderboard = results[2] as List<LeaderboardEntry>;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<int> getPostCount(String userId) async {
    final response = await _db.getMyPosts(userId);

    if (response.isSuccess) {
      final posts = response.data;
      final filtered = posts!.where((post) {
        if (post.status == PostStatus.completed) {
          return false;
        }
        return true;
      }).toList();
      final count = filtered.length;
      return count;
    }
    return 0;
  }

  Future<int> getRequestCount(String userId) async {
    final response = await _db.getMyRequests(userId);

    if (response.isSuccess) {
      final requests = response.data;
      final filtered = requests!.where((request) {
        if (request.status == RequestStatus.pending ||
            request.status == RequestStatus.accepted) {
          return true;
        }
        return false;
      }).toList();
      final count = filtered.length;
      return count;
    }
    return 0;
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await _db.getCompletedPosts();
    if (!response.isSuccess || response.data == null) {
      return [];
    }

    final posts = response.data!;
    final Map<String, int> userCompletedCounts = {};
    for (var post in posts) {
      if (post.userId.isNotEmpty) {
        userCompletedCounts[post.userId] = (userCompletedCounts[post.userId] ?? 0) + 1;
      }
    }

    final sortedEntries = userCompletedCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top10Entries = sortedEntries.take(10).toList();

    final List<LeaderboardEntry> leaderboardList = [];
    for (var entry in top10Entries) {
      final userResult = await _db.getUserById(entry.key);
      if (userResult.isSuccess && userResult.data != null) {
        leaderboardList.add(LeaderboardEntry(
          user: userResult.data!,
          count: entry.value,
        ));
      }
    }

    return leaderboardList;
  }
}

final homeProvider = HomeProvider();
