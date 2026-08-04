import 'package:drift/drift.dart' as drift;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:neruwallet/core/services/database/app_database.dart';

import '../utils/logger.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AppDatabase _db;

  NotificationService(this._db);

  /// Initializes notification handling
  Future<void> initialize() async {
    // Request permission (needed specifically for iOS/macOS)
    final settings = await _fcm.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      AppLogger.i('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      AppLogger.i('User granted provisional permission');
    } else {
      AppLogger.i('User declined or has not accepted permission');
    }

    // Get FCM Token (optional, for debugging or server integration)
    final token = await _fcm.getToken();
    AppLogger.i('FCM Token: $token');

    // Handle initial message when the app is opened from a terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _saveNotification(initialMessage);
    }

    // Handle messages in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _saveNotification(message);
    });

    // Handle messages when user taps it (works in background state)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _saveNotification(message);
    });
  }

  /// Saves a receipt notification to the Drift database
  Future<void> _saveNotification(RemoteMessage message) async {
    final title = message.notification?.title ?? 'No Title';
    final body = message.notification?.body ?? 'No Body';

    await _db.insertNotification(
      DbNotificationsCompanion(
        title: drift.Value(title),
        body: drift.Value(body),
        receivedAt: drift.Value(DateTime.now()),
      ),
    );
  }
}
