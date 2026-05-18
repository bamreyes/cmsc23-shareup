import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/models/notification_model.dart';
import 'package:project/features/notifications/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldLight,
        appBar: AppHeader.back(
          title: 'Notifications',
          onBack: () => Navigator.of(context).pop(),
        ),
        body: const Center(
          child: Text(
            'Please log in to view your notifications.',
            style: TextStyle(color: AppColors.neutral500, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppHeader.back(
        title: 'Notifications',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: context.watch<NotificationProvider>().streamNotifications(currentUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary500),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading notifications',
                style: TextStyle(color: AppColors.error500),
              ),
            );
          }

          final notifications = snapshot.data ?? [];

          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications yet.',
                style: TextStyle(color: AppColors.neutral500, fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _NotificationCard(notification: notifications[index]);
            },
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationCard({required this.notification});

  String _getNotificationTitle(NotificationType type) {
    switch (type) {
      case NotificationType.newPost:
        return 'New Listing Nearby';
      case NotificationType.pickupReminder:
        return 'Upcoming Exchange';
      case NotificationType.requestReceived:
        return 'Request Received';
      case NotificationType.requestAccepted:
        return 'Request Approved';
      case NotificationType.requestRejected:
        return 'Request Rejected';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final duration = DateTime.now().difference(dateTime);
    if (duration.inDays >= 1) return '${duration.inDays}d ago';
    if (duration.inHours >= 1) return '${duration.inHours}h ago';
    if (duration.inMinutes >= 1) return '${duration.inMinutes}m ago';
    return 'Just now';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary100,
            ),
            child: const ClipOval(
              child: Icon(Icons.person, color: AppColors.primary700, size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getNotificationTitle(notification.type),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                      ),
                    ),
                    Text(
                      _getTimeAgo(notification.createdAt),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.neutral700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}