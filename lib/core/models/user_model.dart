import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_preferences.dart';

enum AppMode { light, dark, system }

class UserModel {
  final String? uid;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String profileImage;
  final double discoveryRadius;
  final double latitude;
  final double longitude;
  final AppMode appMode;
  final List<String> dietaryTags;
  final DateTime createdAt;
  final NotificationPreferences notificationPreferences;

  UserModel({
    this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.profileImage,
    required this.discoveryRadius,
    this.latitude = 0,
    this.longitude = 0,
    this.appMode = AppMode.system,
    required this.dietaryTags,
    required this.createdAt,
    required this.notificationPreferences,
  });

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? profileImage,
    double? discoveryRadius,
    double? latitude,
    double? longitude,
    AppMode? appMode,
    List<String>? dietaryTags,
    DateTime? createdAt,
    NotificationPreferences? notificationPreferences,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      username: username ?? this.username,
      profileImage: profileImage ?? this.profileImage,
      discoveryRadius: discoveryRadius ?? this.discoveryRadius,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      appMode: appMode ?? this.appMode,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      createdAt: createdAt ?? this.createdAt,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data["uid"],
      firstName: data["firstName"] ?? '',
      lastName: data["lastName"] ?? '',
      email: data["email"] ?? '',
      username: data["username"] ?? '',
      profileImage: data["profileImage"] ?? '',
      discoveryRadius: (data["discoveryRadius"] ?? 0.0).toDouble(),
      latitude: (data["latitude"] ?? 0.0).toDouble(),
      longitude: (data["longitude"] ?? 0.0).toDouble(),
      appMode: AppMode.values.firstWhere(
        (e) => e.name == data["appMode"],
        orElse: () => AppMode.system,
      ),
      dietaryTags: List<String>.from(data["dietaryTags"] ?? []),
      createdAt: (data["createdAt"] as Timestamp).toDate(),
      notificationPreferences: NotificationPreferences.fromMap(
        data['notificationPreferences'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (uid != null) 'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'username': username,
      'profileImage': profileImage,
      'discoveryRadius': discoveryRadius,
      'latitude': latitude,
      'longitude': longitude,
      'appMode': appMode.name,
      'dietaryTags': dietaryTags,
      'createdAt': Timestamp.fromDate(createdAt),
      'notificationPreferences': notificationPreferences.toMap(),
    };
  }

  static List<UserModel> fromMapArray(String data) {
    final Iterable<dynamic> parsed = jsonDecode(data);
    return parsed.map<UserModel>((dynamic d) => UserModel.fromMap(d)).toList();
  }
}
