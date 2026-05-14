import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/models/notification_preferences.dart';
import 'package:project/core/services/location_service.dart';
import 'package:project/core/services/user_service.dart';
import 'package:project/core/utils/result.dart';

import 'package:project/core/services/database_service.dart';

class ProfileProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final LocationService _locationService = LocationService();
  final DatabaseService _databaseService = DatabaseService();

  ProfileProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        loadCurrentUser();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  Future<Result<UserModel?>> loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Result.error("No user logged in");

    final result = await _databaseService.getUserById(uid);
    if (result.isSuccess) {
      _currentUser = result.data;
      notifyListeners();
      return Result.success(_currentUser);
    }
    return Result.error(result.error ?? "Failed to load user");
  }

  Future<void> updateLocation() async {
    final result = await _locationService.getCurrentLocation();
    if (result.isError || result.data == null) return;

    final lat = result.data!.latitude;
    final lng = result.data!.longitude;

    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(latitude: lat, longitude: lng);
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _userService.updateUserLocation(uid, lat, lng);
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    List<String>? dietaryTags,
    double? discoveryRadius,
    AppMode? appMode,
    NotificationPreferences? notificationPreferences,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final Map<String, dynamic> data = {};
    if (dietaryTags != null) data['dietaryTags'] = dietaryTags;
    if (discoveryRadius != null) data['discoveryRadius'] = discoveryRadius;
    if (appMode != null) data['appMode'] = appMode.name;
    if (notificationPreferences != null) {
      data['notificationPreferences'] = notificationPreferences.toMap();
    }

    if (data.isEmpty) return;

    final result = await _userService.updateUser(uid, data);
    if (result.isSuccess) {
      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(
          dietaryTags: dietaryTags,
          discoveryRadius: discoveryRadius,
          appMode: appMode,
          notificationPreferences: notificationPreferences,
        );
        notifyListeners();
      }
    }
  }

  void clearProfile() {
    _currentUser = null;
    notifyListeners();
  }
}

final profileProvider = ProfileProvider();
