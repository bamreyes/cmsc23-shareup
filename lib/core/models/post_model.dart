enum PostStatus { available, reserved, completed, deleted }

class PostModel {
  final String userId;
  final String name;
  final String description;
  final String image;
  final DateTime expirationDate;
  final List<String> dietaryTags;
  final double latitude;
  final double longitude;
  final String locationName;
  final PostStatus status;
  final String? receiverId;
  final String? qrCode;
  final DateTime createdAt;
  final DateTime updatedAt;

  PostModel({
    required this.userId,
    required this.name,
    required this.description,
    required this.image,
    required this.expirationDate,
    required this.dietaryTags,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.status,
    this.receiverId,
    this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });
}
