import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/quick_action_model.dart';

class QuickActionsGrid extends StatelessWidget {
  final bool isDark;
  final List<QuickActionModel> actions;

  const QuickActionsGrid({
    super.key,
    required this.isDark,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 16,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: actions.length,
              itemBuilder: (ctx, i) => _buildQuickActionItem(context, actions[i], i),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, QuickActionModel action, int index) {
    return GestureDetector(
      onTap: () {
        if (action.label == 'Exchange') {
          context.push('/exchange-rates');
        } else if (action.label == 'Scan QR') {
          context.push('/qr-pay');
        } else if (action.label == 'Send') {
          context.push('/transfer');
        } else if (action.label == 'Receive') {
          context.push('/receive');
        } else if (action.label == 'Top Up') {
          context.push('/top-up');
        } else if (action.label == 'Pay Bill') {
          context.push('/pay-bill');
        }
      },


      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ).animate(delay: (50 * index).ms).fadeIn().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
          ),
    );
  }
}
