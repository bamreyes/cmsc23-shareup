import 'package:cloud_firestore/cloud_firestore.dart';

enum RequestStatus { pending, accepted, rejected, cancelled, completed }

class RequestModel {
  final String postId;
  final String requesterId;
  final DateTime pickupDatetime;
  final String? message;
  final RequestStatus status;
  final DateTime createdAt;

  RequestModel({
    required this.postId,
    required this.requesterId,
    required this.pickupDatetime,
    this.message,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'requesterId': requesterId,
      'pickupDatetime': Timestamp.fromDate(pickupDatetime),
      'message': message,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
