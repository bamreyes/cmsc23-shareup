enum DarkMode { light, dark, system }

class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String profileImage;
  final double discoveryRadius;
  final double latitude;
  final double longitude;
  final DarkMode appMode;
  final List<String> dietaryTags;
  final DateTime createdAt;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.profileImage,
    required this.discoveryRadius,
    required this.latitude,
    required this.longitude,
    required this.appMode,
    required this.dietaryTags,
    required this.createdAt,
  });
}
