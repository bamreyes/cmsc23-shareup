import 'package:cloud_firestore/cloud_firestore.dart';


enum PostStatus {
  available,
  reserved,
  completed,
  deleted
}

class PostModel {
  final String? id;
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
    this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.image,
    required this.expirationDate,
    required this.dietaryTags,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.status = PostStatus.available, 
    this.receiverId,
    this.qrCode,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'description': description,
      'image': image,
      'expiration_date': Timestamp.fromDate(expirationDate),
      'dietary_tags': dietaryTags,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'status': status.name, 
      'receiver_id': receiverId,
      'qr_code': qrCode,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }


  factory PostModel.fromJson(Map<String, dynamic> json, String docId) {
    return PostModel(
      id: docId,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      expirationDate: (json['expiration_date'] as Timestamp).toDate(),
      dietaryTags: List<String>.from(json['dietary_tags'] ?? []),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String,
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.available,
      ),
      receiverId: json['receiver_id'] as String?,
      qrCode: json['qr_code'] as String?,
      createdAt: (json['created_at'] as Timestamp).toDate(),
      updatedAt: (json['updated_at'] as Timestamp).toDate(),
    );
  }
}