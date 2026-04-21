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

  NotificationPreferences copyWith({
    bool? newPost,
    bool? requestReceived,
    bool? requestAccepted,
    bool? requestRejected,
    bool? pickupReminder,
  }) {
    return NotificationPreferences(
      newPost: newPost ?? this.newPost,
      requestReceived: requestReceived ?? this.requestReceived,
      requestAccepted: requestAccepted ?? this.requestAccepted,
      requestRejected: requestRejected ?? this.requestRejected,
      pickupReminder: pickupReminder ?? this.pickupReminder,
    );
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> data) {
    return NotificationPreferences(
      newPost: data['newPost'] ?? true,
      requestReceived: data['requestReceived'] ?? true,
      requestAccepted: data['requestAccepted'] ?? true,
      requestRejected: data['requestRejected'] ?? true,
      pickupReminder: data['pickupReminder'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newPost': newPost,
      'requestReceived': requestReceived,
      'requestAccepted': requestAccepted,
      'requestRejected': requestRejected,
      'pickupReminder': pickupReminder,
    };
  }
}
