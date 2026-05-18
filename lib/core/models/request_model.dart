import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/utils/date_formatter.dart';

enum RequestStatus { pending, accepted, rejected, cancelled, completed }

class RequestModel {
  final String? id;
  final String postId;
  final String requesterId;
  final DateTime pickupDatetime;
  final String? message;
  final RequestStatus status;
  final DateTime createdAt;

  RequestModel({
    this.id,
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

  factory RequestModel.fromJson(Map<String, dynamic> data, String docId) {
    return RequestModel(
      id: docId,
      postId: data['postId'],
      requesterId: data['requesterId'],
      pickupDatetime: DateFormatter.parseDateTime(data['pickupDatetime'] ?? data['pickupDateTime']),
      message: data['message'],
      status: RequestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => RequestStatus.pending,
      ),
      createdAt: DateFormatter.parseDateTime(data['createdAt']),
    );
  }
}
