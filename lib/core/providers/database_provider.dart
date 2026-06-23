import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/notification_service.dart';

/// Database provider for Drift.
final databaseProvider = Provider<AppDatabase>((ref) {
  // Reuse the generated Riverpod `appDatabaseProvider` to ensure only
  // a single `AppDatabase` instance exists across the app.
  return ref.watch(appDatabaseProvider);
});

/// Notification Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationService(db);
});
