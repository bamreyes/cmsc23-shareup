import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:project/core/models/user_model.dart';
import 'package:project/core/models/notification_preferences.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  factory PushNotificationService() => _instance;

  PushNotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  static NotificationPreferences? _cachedPrefs;

  final Set<String> _processedNotificationIds = {};

  String? _currentUserId;
  StreamSubscription<DocumentSnapshot>? _prefsSubscription;
  StreamSubscription<QuerySnapshot>? _notifSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  static Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message,
  ) async {
    debugPrint("Handling background push notification: ${message.messageId}");
  }

  Future<void> initialize(String userId) async {
    if (_isInitialized && _currentUserId == userId) return;
    _isInitialized = true;
    _currentUserId = userId;

    _processedNotificationIds.clear();
    await _prefsSubscription?.cancel();
    await _notifSubscription?.cancel();
    await _tokenRefreshSubscription?.cancel();

    try {
      tz.initializeTimeZones();

      await _localNotifications.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          ),
        ),
      );

      _prefsSubscription = _db
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((userSnap) {
            if (userSnap.exists && userSnap.data() != null) {
              _cachedPrefs = UserModel.fromMap(
                userSnap.data()!,
              ).notificationPreferences;
            }
          });

      final DateTime serviceStartTime = DateTime.now();

      _notifSubscription = _db
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
            for (var doc in snapshot.docs) {
              final notificationId = doc.id;
              if (_processedNotificationIds.contains(notificationId)) continue;

              final data = doc.data();
              final timestamp = data['createdAt'] as Timestamp?;

              final createdAt = timestamp?.toDate() ?? DateTime.now();

              if (createdAt.isAfter(
                serviceStartTime.subtract(const Duration(seconds: 5)),
              )) {
                _processedNotificationIds.add(notificationId);

                final message = data['message'] as String? ?? '';
                final type = data['type'] as String? ?? 'Notification';

                if (_cachedPrefs != null) {
                  if (type == 'newPost' && !_cachedPrefs!.newPost) continue;
                  if (type == 'pickupReminder' && !_cachedPrefs!.pickupReminder)
                    continue;
                  if (type == 'requestReceived' &&
                      !_cachedPrefs!.requestReceived)
                    continue;
                  if (type == 'requestAccepted' &&
                      !_cachedPrefs!.requestAccepted)
                    continue;
                  if (type == 'requestRejected' &&
                      !_cachedPrefs!.requestRejected)
                    continue;
                }

                final titleMap = {
                  'newPost': 'New Listing Nearby',
                  'pickupReminder': 'Upcoming Exchange',
                  'requestReceived': 'Request Received',
                  'requestAccepted': 'Request Accepted',
                  'requestRejected': 'Request Rejected',
                };
                final title = titleMap[type] ?? 'ShareUP';

                if (type == 'requestAccepted') {
                  final reqId = data['requestId'] as String?;
                  final postId = data['postId'] as String?;
                  if (reqId != null && postId != null) {
                    _scheduleRequesterPickupReminder(reqId, postId);
                  }
                }

                _showLocalNotification(title, message);
              }
            }
          });

      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await _fcm.getToken();
        if (token != null) await _saveTokenToFirestore(userId, token);

        _tokenRefreshSubscription = _fcm.onTokenRefresh.listen(
          (newToken) => _saveTokenToFirestore(userId, newToken),
        );

        await _fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
        FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler,
        );

        FirebaseMessaging.onMessage.listen((msg) {
          debugPrint(
            "FCM foreground push received, silenced in favor of real-time Firestore listener: ${msg.messageId}",
          );
        });
      }
    } catch (e) {
      debugPrint("Failed to initialize notifications: $e");
    }
  }

  Future<void> _showLocalNotification(String title, String body) async {
    await _localNotifications.show(
      id: DateTime.now().hashCode & 0x7FFFFFFF,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'shareup_channel_id',
          'ShareUP Notifications',
          channelDescription:
              'High importance notifications for ShareUP exchanges.',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
      ),
    );
  }

  Future<void> schedulePickupReminder({
    required String requestId,
    required String itemName,
    required DateTime pickupDatetime,
    required bool isOwner,
  }) async {
    try {
      if (_cachedPrefs != null && !_cachedPrefs!.pickupReminder) {
        debugPrint("Pickup reminder preference disabled, skipping scheduling.");
        return;
      }

      final now = DateTime.now();
      final reminderTime = pickupDatetime.subtract(const Duration(hours: 1));

      if (reminderTime.isBefore(now)) return;

      final scheduledDate = tz.TZDateTime.from(reminderTime, tz.local);
      final notificationId =
          (requestId.hashCode + (isOwner ? 1000 : 2000)) & 0x7FFFFFFF;
      final message = isOwner
          ? "You have a pickup scheduled for your listing '$itemName' in 1 hour!"
          : "Friendly reminder: your pickup for '$itemName' is scheduled in 1 hour!";

      await _localNotifications.zonedSchedule(
        id: notificationId,
        title: "Exchange Reminder",
        body: message,
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'shareup_pickup_channel',
            'ShareUP Pickup Reminders',
            channelDescription: 'Reminders for your upcoming food exchanges.',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      debugPrint(
        "Successfully scheduled pickup reminder at $scheduledDate for $itemName",
      );
    } catch (e) {
      debugPrint("Failed to schedule pickup reminder: $e");
    }
  }

  Future<void> cancelPickupReminder(String requestId, bool isOwner) async {
    try {
      final notificationId =
          (requestId.hashCode + (isOwner ? 1000 : 2000)) & 0x7FFFFFFF;
      await _localNotifications.cancel(id: notificationId);
      debugPrint(
        "Cancelled scheduled pickup reminder for requestId: $requestId",
      );
    } catch (e) {
      debugPrint("Failed to cancel scheduled notification: $e");
    }
  }

  Future<void> _scheduleRequesterPickupReminder(
    String requestId,
    String postId,
  ) async {
    try {
      final reqDoc = await _db.collection('requests').doc(requestId).get();
      final postDoc = await _db.collection('posts').doc(postId).get();
      if (!reqDoc.exists || !postDoc.exists) return;

      final reqData = reqDoc.data()!;
      final postData = postDoc.data()!;
      final timestamp = reqData['pickupDatetime'] as Timestamp?;
      final itemName = postData['name'] as String? ?? 'item';

      if (timestamp != null) {
        await schedulePickupReminder(
          requestId: requestId,
          itemName: itemName,
          pickupDatetime: timestamp.toDate(),
          isOwner: false,
        );
      }
    } catch (e) {
      debugPrint("Failed to auto-schedule requester pickup reminder: $e");
    }
  }

  Future<void> _saveTokenToFirestore(String userId, String token) async {
    try {
      await _db.collection('users').doc(userId).update({
        'fcmTokens': FieldValue.arrayUnion([token]),
      });
    } catch (e) {
      debugPrint("Failed to save FCM token: $e");
    }
  }
}
