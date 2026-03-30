import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/providers/quick_actions_provider.dart';
import '../../data/models/quick_action_model.dart';
import '../pages/quick_actions_manager_screen.dart';

class QuickActionsGrid extends ConsumerStatefulWidget {
  final bool isDark;

  const QuickActionsGrid({super.key, required this.isDark});

  @override
  ConsumerState<QuickActionsGrid> createState() => _QuickActionsGridState();
}

class _QuickActionsGridState extends ConsumerState<QuickActionsGrid> {
  @override
  Widget build(BuildContext context) {
    final actions = ref.watch(quickActionsProvider);
    final isDark = widget.isDark;

    final displayedActions = actions.take(6).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuickActionsManagerScreen(isDark: isDark),
                      ),
                    );
                  },
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: isDark ? Colors.white38 : Colors.black26,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Customize',
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // Sticking to 3 as it fits 6 items perfectly in 2 rows
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: displayedActions.length,
              itemBuilder: (ctx, i) => _buildQuickActionItem(context, displayedActions[i], i),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildQuickActionItem(
    BuildContext context,
    QuickActionModel action,
    int index,
  ) {
    final isDark = widget.isDark;
    return InkWell(
      onTap: () {
        if (action.label == 'Exchange') {
          context.push('/exchange-rates');
        } else if (action.label == 'Scan QR') {
          context.push('/qr-pay');
        } else if (action.label == 'Top Up') {
          context.push('/top-up');
        } else if (action.label == 'Pay Bill' || action.category == 'Bills') {
          context.push('/pay-bill');
        } else if (action.label == 'Fine Payment') {
          context.push('/fine-payment');
        } else if (action.label == 'Gov Services') {
          context.push('/gov-services');
        }
      },
      borderRadius: AppTheme.radiusMedium,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: action.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(action.icon, color: action.color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            action.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: isDark ? Colors.white : AppTheme.textBodyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
