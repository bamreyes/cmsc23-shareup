class NotificationPreferences {
  final bool newPost;
  final bool requestReceived;
  final bool requestAccepted;
  final bool requestRejected;
  final bool pickupReminder;

  NotificationPreferences({
    required this.newPost,
    required this.requestReceived,
    required this.requestAccepted,
    required this.requestRejected,
    required this.pickupReminder,
  });
}
