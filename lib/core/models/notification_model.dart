import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project/core/utils/date_formatter.dart';

enum NotificationType {
  newPost,
  requestReceived,
  requestAccepted,
  requestRejected,
  pickupReminder,
}

class NotificationModel {
  final String id;
  final NotificationType type;
  final String message;
  final String? postId;
  final String? requestId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.message,
    this.postId,
    this.requestId,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      type: NotificationType.values.byName(data['type']),
      message: data['message'] ?? '',
      postId: data['postId'],
      requestId: data['requestId'],
      isRead: data['isRead'] ?? false,
      createdAt: DateFormatter.parseDateTime(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'message': message,
      'postId': postId,
      'requestId': requestId,
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
