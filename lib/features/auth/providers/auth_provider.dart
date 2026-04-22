import 'dart:io';
import 'package:flutter/material.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/auth_service.dart';
import 'package:project/core/services/cloudinary_service.dart';
import 'package:project/core/services/user_service.dart';
import 'package:project/core/models/notification_preferences.dart';
import 'package:project/core/utils/result.dart';

class AuthProvider extends ChangeNotifier {
  final CloudinaryService _cloudinary = CloudinaryService();
  final AuthService _auth = AuthService();
  final UserService _user = UserService();

  String? username;
  String? email;
  String? password;
  String? firstName;
  String? lastName;
  List<String> dietaryTags = [];
  File? imageFile;
  String? imageUrl;
  NotificationPreferences notificationPreferences = NotificationPreferences(
    newPost: true,
    requestReceived: true,
    requestAccepted: true,
    requestRejected: true,
    pickupReminder: true,
  );

  List<String> get myDietaryTags => dietaryTags;

  void toggleDietaryTag(String tag) {
    final removed = dietaryTags.remove(tag);
    if (!removed) {
      dietaryTags.add(tag);
    }
    notifyListeners();
  }

  void updateAccountDetails({
    required String username,
    required String email,
    required String password,
  }) {
    this.email = email;
    this.username = username;
    this.password = password;
    notifyListeners();
  }

  void updateUserPreferences({
    required String firstName,
    required String lastName,
  }) {
    this.firstName = firstName;
    this.lastName = lastName;
    notifyListeners();
  }

  void updateNotificationPreferences(NotificationPreferences preferences) {
    notificationPreferences = preferences;
    notifyListeners();
  }

  void setImageFile(File image) {
    imageFile = image;
    notifyListeners();
  }

  void sendImage() async {
    Result<String> result = await _cloudinary.uploadFile(imageFile!);
    imageUrl = result.data;
  }

  Future<Result<dynamic>?> signUp() async {
    final signUpResult = await _auth.signUp(email!, password!);

    if (signUpResult.isError) {
      return signUpResult;
    }

    Result<String> cloudinaryResult = await _cloudinary.uploadFile(imageFile!);
    if (signUpResult.isError) {
      return cloudinaryResult;
    }

    final imageUrl = cloudinaryResult.data;
    final uid = signUpResult.data!.uid;

    UserModel user = UserModel(
      uid: uid,
      firstName: firstName!,
      lastName: lastName!,
      email: email!,
      username: username!,
      profileImage: imageUrl!,
      dietaryTags: dietaryTags,
      discoveryRadius: 0,
      createdAt: DateTime.now(),
      notificationPreferences: notificationPreferences,
    );
    _user.addUser(user);
    return Result.success("Successfully signed up the user");
  }
}
