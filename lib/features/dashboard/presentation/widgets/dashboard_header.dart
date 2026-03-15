import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class DashboardHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final VoidCallback onProfileTap;
  final VoidCallback onNotificationTap;

  const DashboardHeader({
    super.key,
    required this.isDark,
    required this.userName,
    required this.onProfileTap,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 64, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Evening 👋',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                userName,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2, end: 0),
          Row(
            children: [
              _buildIconButton(context, Icons.notifications_outlined, onNotificationTap),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onProfileTap,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: AppTheme.primaryColor.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    userName.split(' ').map((e) => e[0]).take(2).join(''),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2, end: 0),
        ],
      ),
    );
  }

  Widget _buildIconButton(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isDark ? AppTheme.textBodyDark : AppTheme.textBodyColor,
        ),
      ),
    );
  }
}
