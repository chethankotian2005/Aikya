import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/user_doc.dart';

final messagingServiceProvider = Provider<MessagingService>((ref) {
  return MessagingService();
});

class MessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _foregroundReady = false;

  /// Asks for permission, stores the FCM token on the user's doc and subscribes
  /// to the role topic the backend broadcasts to. Push is best-effort: failures
  /// are logged, never shown to the user.
  Future<void> requestPermissionAndSetup(UserDoc user) async {
    try {
      final settings = await _fcm.requestPermission(alert: true, badge: true, sound: true);
      final allowed = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      if (!allowed) return;

      final token = await _fcm.getToken();
      if (token != null && token != user.fcmToken) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'fcmToken': token});
      }

      // Topic subscriptions are not supported by the web SDK.
      if (!kIsWeb) {
        final isStudent = user.role == UserRole.student;
        await _fcm.subscribeToTopic(isStudent ? 'all_students' : 'all_faculty');
        await _fcm.unsubscribeFromTopic(isStudent ? 'all_faculty' : 'all_students');
        await _initForegroundNotifications();
      }
    } catch (e) {
      debugPrint('Push notification setup skipped: $e');
    }
  }

  Future<void> _initForegroundNotifications() async {
    if (_foregroundReady) return;
    _foregroundReady = true;

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(settings: settings);
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription: 'Department updates, attendance and memory wall notifications.',
          importance: Importance.high,
          priority: Priority.high,
          icon: notification.android?.smallIcon ?? '@mipmap/launcher_icon',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }
}
