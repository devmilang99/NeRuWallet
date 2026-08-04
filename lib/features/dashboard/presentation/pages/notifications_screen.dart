import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/providers/database_provider.dart';
import 'package:neruwallet/core/services/database/app_database.dart';

/// VIEW MODEL: NotificationViewModel
/// Manages the state of the notifications screen.
class NotificationViewModel extends StateNotifier<AsyncValue<List<DbNotification>>> {
  final AppDatabase _db;

  NotificationViewModel(this._db) : super(const AsyncValue.loading()) {
    _init();
  }

  void _init() {
    // Watch notifications from the Drift database for real-time updates
    _db.watchNotifications().listen((notifications) {
      state = AsyncValue.data(notifications);
    }, onError: (err, stack) {
      state = AsyncValue.error(err, stack);
    });
  }

  Future<void> markAsRead(int id) async {
    await _db.markNotificationAsRead(id);
  }
}

final notificationViewModelProvider = StateNotifierProvider<NotificationViewModel, AsyncValue<List<DbNotification>>>((ref) {
  final db = ref.watch(databaseProvider);
  return NotificationViewModel(db);
});

/// VIEW: NotificationsScreen
/// A clean, professional UI to view notification history.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsState = ref.watch(notificationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: notificationsState.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead ? Colors.grey.shade200 : Colors.blue.shade50,
                  child: Icon(
                    notification.isRead ? Icons.notifications_none : Icons.notifications_active,
                    color: notification.isRead ? Colors.grey : Colors.blue,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notification.body),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(notification.receivedAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                onTap: () => ref.read(notificationViewModelProvider.notifier).markAsRead(notification.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
