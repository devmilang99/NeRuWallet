import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Welcome to NeRuWallet!',
        'message': 'Thank you for joining. Start exploring our premium features today.',
        'time': '2 hours ago',
        'icon': Icons.celebration_rounded,
        'color': AppTheme.primaryColor,
        'isUnread': true,
      },
      {
        'title': 'Cashback Received',
        'message': 'You received Rs. 25.00 cashback for your recent utility bill payment.',
        'time': '5 hours ago',
        'icon': Icons.account_balance_wallet_rounded,
        'color': AppTheme.successColor,
        'isUnread': true,
      },
      {
        'title': 'Security Alert',
        'message': 'A new login was detected from a new device. If this wasn\'t you, please change your PIN.',
        'time': 'Yesterday',
        'icon': Icons.security_rounded,
        'color': AppTheme.warningColor,
        'isUnread': false,
      },
      {
        'title': 'Limited Offer Claimed',
        'message': 'Your zero-fee voucher is now active! Enjoy 3 free transactions.',
        'time': '1 day ago',
        'icon': Icons.local_offer_rounded,
        'color': AppTheme.accentColor,
        'isUnread': false,
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, 
            color: isDark ? Colors.white : AppTheme.textBodyColor, size: 20),
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
          TextButton(
            onPressed: () {},
            child: const Text('Mark all as read', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return _buildNotificationTile(item, isDark, index);
              },
            ),
    );
  }

  Widget _buildNotificationTile(Map<String, dynamic> item, bool isDark, int index) {
    return Container(
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
        border: item['isUnread'] 
          ? Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1), width: 1.5)
          : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item['color'].withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item['icon'], color: item['color'], size: 20),
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
                        item['title'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                    if (item['isUnread'])
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
                  item['message'],
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['time'],
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.05, end: 0);
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
            style: TextStyle(color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}
