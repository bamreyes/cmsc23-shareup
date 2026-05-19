import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/models/notification_model.dart';
import 'package:project/features/notifications/providers/notification_provider.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});



  @override
  Widget build(BuildContext context) {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (currentUid == null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppColors.scaffoldDark : AppColors.scaffoldLight,
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

    return StreamBuilder<List<NotificationModel>>(
      stream: context.watch<NotificationProvider>().streamNotifications(currentUid),
      builder: (context, snapshot) {
        final notifications = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: isDarkMode ? AppColors.scaffoldDark : AppColors.scaffoldLight,
          appBar: AppHeader.back(
            title: 'Notifications',
            onBack: () => Navigator.of(context).pop(),
          ),
          body: () {
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

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isDarkMode ? AppColors.neutral900 : AppColors.neutral100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off_outlined,
                        size: 64,
                        color: isDarkMode ? AppColors.neutral600 : AppColors.neutral400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'All Caught Up!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? AppColors.white : AppColors.neutral800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No notifications yet.',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? AppColors.neutral400 : AppColors.neutral500,
                      ),
                    ),
                  ],
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
          }(),
        );
      },
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

  void _onNotificationTap(BuildContext context, NotificationModel notification) {
    final String? currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;

    context.read<NotificationProvider>().markAsRead(currentUid, notification.id);

    switch (notification.type) {
      case NotificationType.newPost:
        context.go('/feed');
        break;
      case NotificationType.requestReceived:
      case NotificationType.requestAccepted:
      case NotificationType.requestRejected:
      case NotificationType.pickupReminder:
        context.go('/exchanges');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    final cardBgColor = notification.isRead
        ? (isDarkMode ? AppColors.cardDark : AppColors.cardLight)
        : (isDarkMode ? const Color(0xFF1B2E17) : const Color(0xFFF1FDE8));
        
    final borderColor = notification.isRead
        ? (isDarkMode ? AppColors.borderDark : AppColors.borderLight)
        : (isDarkMode ? AppColors.primary800 : AppColors.primary300);

    return InkWell(
      onTap: () => _onNotificationTap(context, notification),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode ? AppColors.neutral800 : AppColors.primary100,
              ),
              child: ClipOval(
                child: Icon(
                  Icons.notifications_outlined, 
                  color: isDarkMode ? AppColors.primary400 : AppColors.primary700, 
                  size: 24,
                ),
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
                        child: Row(
                          children: [
                            if (!notification.isRead) ...[
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            Expanded(
                              child: Text(
                                _getNotificationTitle(notification.type),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.bold,
                                  color: isDarkMode ? AppColors.white : AppColors.neutral900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _getTimeAgo(notification.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? AppColors.neutral400 : AppColors.neutral500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? AppColors.neutral300 : AppColors.neutral700,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}