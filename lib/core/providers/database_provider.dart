import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/services/notification_service.dart';

/// Database provider for Drift.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Notification Service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationService(db);
});
