import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/auth_service.dart';
import 'package:project/core/services/cloudinary_service.dart';
import 'package:project/core/services/user_service.dart';
import 'package:project/core/models/notification_preferences.dart';
import 'package:project/core/utils/result.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

class AuthProvider extends ChangeNotifier {
  final CloudinaryService _cloudinary = CloudinaryService();
  final AuthService _auth = AuthService();
  final UserService _user = UserService();

  AuthProvider() {
    _isLoggedIn = FirebaseAuth.instance.currentUser != null;
    _auth.authStateChanges.listen((User? user) {
      _isLoggedIn = user != null;
      notifyListeners();
    });
  }

  String? _username;
  String? _email;
  String? _password;
  String? _firstName;
  String? _lastName;
  final List<String> _dietaryTags = [];
  File? _imageFile;
  String? _imageUrl;
  NotificationPreferences _notificationPreferences = NotificationPreferences(
    newPost: true,
    requestReceived: true,
    requestAccepted: true,
    requestRejected: true,
    pickupReminder: true,
  );
  bool _isLoggedIn = false;

  // Getters
  String? get username => _username;
  String? get email => _email;
  String? get password => _password;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  List<String> get dietaryTags => _dietaryTags;
  File? get imageFile => _imageFile;
  String? get imageUrl => _imageUrl;
  NotificationPreferences get notificationPreferences =>
      _notificationPreferences;
  bool get isLoggedIn => _isLoggedIn;

  void toggleDietaryTag(String tag) {
    final removed = _dietaryTags.remove(tag);
    if (!removed) {
      _dietaryTags.add(tag);
    }
    notifyListeners();
  }

  void updateAccountDetails({
    required String username,
    required String email,
    required String password,
  }) {
    _email = email;
    _username = username;
    _password = password;
    notifyListeners();
  }

  void updateUserPreferences({
    required String firstName,
    required String lastName,
  }) {
    _firstName = firstName;
    _lastName = lastName;
    notifyListeners();
  }

  void updateNotificationPreferences(NotificationPreferences preferences) {
    _notificationPreferences = preferences;
    notifyListeners();
  }

  void setImageFile(File image) {
    _imageFile = image;
    notifyListeners();
  }

  void clearProvider() {
    _username = null;
    _email = null;
    _password = null;
    _firstName = null;
    _lastName = null;
    _dietaryTags.clear();
    _imageFile = null;
    notifyListeners();
  }

  Future<Result<dynamic>?> signUp() async {
    try {
      final signUpResult = await _auth.signUp(_email!, _password!);

      if (signUpResult.isError) {
        return signUpResult;
      }

      Result<String> cloudinaryResult = await _cloudinary.uploadFile(
        _imageFile!,
      );
      if (cloudinaryResult.isError) {
        await _auth.deleteUser();
        return cloudinaryResult;
      }

      final imageUrl = cloudinaryResult.data;
      final uid = signUpResult.data!.uid;

      UserModel user = UserModel(
        uid: uid,
        firstName: _firstName!,
        lastName: _lastName!,
        email: _email!,
        username: _username!,
        profileImage: imageUrl!,
        dietaryTags: _dietaryTags,
        discoveryRadius: 20,
        createdAt: DateTime.now(),
        notificationPreferences: _notificationPreferences,
      );
      final addResult = await _user.addUser(user);
      if (addResult.isError) {
        await _auth.deleteUser();
        return addResult;
      }
      final loaded = await profileProvider.loadCurrentUser();
      if (loaded.isError) {
        await _auth.deleteUser();
        return Result.error("Failed to load user profile after registration");
      }
      await Future.delayed(const Duration(milliseconds: 500));

      return Result.success("Successfully signed up the user");
    } catch (e) {
      await _auth.deleteUser();
      return Result.error(e.toString());
    }
  }

  Future<Result<User?>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signIn(email, password);
    if (result.isError) {
      return result;
    }
    return result;
  }

  Future<Result<String?>> logOut() async {
    final result = await _auth.logOut();
    clearProvider();
    return result;
  }
}

final authProvider = AuthProvider();
