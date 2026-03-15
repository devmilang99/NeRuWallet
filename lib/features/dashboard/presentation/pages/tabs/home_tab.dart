import 'package:flutter/material.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/quick_actions_grid.dart';
import '../../widgets/promo_card.dart';
import '../../widgets/transaction_tile.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/models/quick_action_model.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class HomeTab extends StatelessWidget {
  final bool isDark;
  final bool balanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onProfileTap;
  final List<TransactionModel> transactions;
  final List<QuickActionModel> quickActions;

  const HomeTab({
    super.key,
    required this.isDark,
    required this.balanceVisible,
    required this.onToggleBalance,
    required this.onProfileTap,
    required this.transactions,
    required this.quickActions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: DashboardHeader(
            isDark: isDark,
            userName: 'Raju Ghimire',
            onProfileTap: onProfileTap,
            onNotificationTap: () {},
          ),
        ),
        SliverToBoxAdapter(
          child: BalanceCard(
            isDark: isDark,
            isVisible: balanceVisible,
            onToggleVisibility: onToggleBalance,
          ),
        ),
        SliverToBoxAdapter(
          child: QuickActionsGrid(
            isDark: isDark,
            actions: quickActions,
          ),
        ),
        SliverToBoxAdapter(
          child: PromoCard(isDark: isDark),
        ),
        SliverToBoxAdapter(
          child: _buildSectionHeader(context, 'Recent Transactions', isDark),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => TransactionTile(
              transaction: transactions[i],
              isDark: isDark,
              index: i,
            ),
            childCount: transactions.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'See All',
              style: TextStyle(color: AppTheme.primaryColor, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
