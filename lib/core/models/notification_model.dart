enum NotificationType {
  newPost,
  requestReceived,
  requestAccepted,
  requestRejected,
  pickupReminder
}

class NotificationModel {
  final NotificationType type;
  final String message;
  final String? postId;
  final String? requestId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.type,
    required this.message,
    this.postId,
    this.requestId,
    required this.isRead,
    required this.createdAt,
  });
}
