import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

import '../providers/notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? Colors.white : AppTheme.textBodyColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textBodyColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(notificationsProvider.notifier).markAllAsRead(),
              child: const Text(
                'Mark all as read',
                style: TextStyle(fontSize: 12),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isDark)
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white54 : Colors.black45,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            ref.read(notificationsProvider.notifier).clearAll(),
                        child: Text(
                          'Clear All',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.errorColor.withValues(alpha: 0.8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => ref
                            .read(notificationsProvider.notifier)
                            .removeNotification(item.id),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.1),
                            borderRadius: AppTheme.radiusMedium,
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppTheme.errorColor,
                          ),
                        ),
                        child: _buildNotificationTile(
                          context,
                          ref,
                          item,
                          isDark,
                          index,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    WidgetRef ref,
    NotificationItem item,
    bool isDark,
    int index,
  ) {
    return GestureDetector(
      onTap: () {
        if (item.isUnread) {
          ref.read(notificationsProvider.notifier).markAsRead(item.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: item.isUnread
              ? Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  width: 1.5,
                )
              : Border.all(color: Colors.transparent, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontWeight: item.isUnread
                                ? FontWeight.w900
                                : FontWeight.bold,
                            fontSize: 14,
                            color: isDark
                                ? Colors.white
                                : AppTheme.textBodyColor,
                          ),
                        ),
                      ),
                      if (item.isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                      height: 1.4,
                      fontWeight: item.isUnread
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.textHintDark
                          : AppTheme.textHintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 60,
              color: AppTheme.primaryColor.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'All caught up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications.',
            style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryColor,
            ),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
