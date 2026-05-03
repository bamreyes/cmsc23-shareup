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
      'userId': userId,
      'name': name,
      'description': description,
      'image': image,
      'expirationDate': Timestamp.fromDate(expirationDate),
      'dietaryTags': dietaryTags,
      'latitude': latitude,
      'longitude': longitude,
      'locationName': locationName,
      'status': status.name,
      'receiverId': receiverId,
      'qrCode': qrCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }


  factory PostModel.fromJson(Map<String, dynamic> json, String docId) {
    return PostModel(
      id: docId,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      expirationDate: ((json['expirationDate'] ?? json['expiration_date']) as Timestamp).toDate(),
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['locationName'] as String,
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.available,
      ),
      receiverId: json['receiverId'] as String?,
      qrCode: json['qrCode'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
    );
  }
}