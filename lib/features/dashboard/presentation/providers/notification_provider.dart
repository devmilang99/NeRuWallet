import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_provider.g.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color color;
  final bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.color,
    this.isUnread = true,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      time: time,
      icon: icon,
      color: color,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}

@riverpod
class Notifications extends _$Notifications {
  @override
  List<NotificationItem> build() => _initialNotifications;

  static final List<NotificationItem> _initialNotifications = [
    NotificationItem(
      id: '1',
      title: 'Welcome to NeRuWallet!',
      message:
          'Thank you for joining. Start exploring our premium features today.',
      time: '2 hours ago',
      icon: Icons.celebration_rounded,
      color: AppTheme.primaryColor,
    ),
    NotificationItem(
      id: '2',
      title: 'Cashback Received',
      message:
          'You received Rs. 25.00 cashback for your recent utility bill payment.',
      time: '5 hours ago',
      icon: Icons.account_balance_wallet_rounded,
      color: AppTheme.successColor,
    ),
    NotificationItem(
      id: '3',
      title: 'Security Alert',
      message:
          "A new login was detected from a new device. If this wasn't you, please change your PIN.",
      time: 'Yesterday',
      icon: Icons.security_rounded,
      color: AppTheme.warningColor,
      isUnread: false,
    ),
  ];

  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(isUnread: false) else n,
    ];
  }

  void markAllAsRead() {
    state = [for (final n in state) n.copyWith(isUnread: false)];
  }

  void clearAll() {
    state = [];
  }

  void removeNotification(String id) {
    state = state.where((n) => n.id != id).toList();
  }
}

@riverpod
int unreadNotificationCount(Ref ref) {
  return ref.watch(notificationsProvider).where((n) => n.isUnread).length;
}
