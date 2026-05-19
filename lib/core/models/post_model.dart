import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/utils/date_formatter.dart';

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

  PostModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? image,
    DateTime? expirationDate,
    List<String>? dietaryTags,
    double? latitude,
    double? longitude,
    String? locationName,
    PostStatus? status,
    String? receiverId,
    String? qrCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      expirationDate: expirationDate ?? this.expirationDate,
      dietaryTags: dietaryTags ?? this.dietaryTags,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      status: status ?? this.status,
      receiverId: receiverId ?? this.receiverId,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      image: json['image'] as String? ?? '',
      expirationDate: DateFormatter.parseDateTime(json['expirationDate'] ?? json['expiration_date']),
      dietaryTags: List<String>.from(json['dietaryTags'] ?? []),
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      locationName: json['locationName'] as String? ?? 'Unknown Location',
      status: PostStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PostStatus.available,
      ),
      receiverId: json['receiverId'] as String?,
      qrCode: json['qrCode'] as String?,
      createdAt: DateFormatter.parseDateTime(json['createdAt']),
      updatedAt: DateFormatter.parseDateTime(json['updatedAt']),
    );
  }
}