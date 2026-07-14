import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

import '../../widgets/balance_card.dart';
import '../../widgets/dashboard_header.dart';
import '../../widgets/promo_card.dart';
import '../../widgets/quick_actions_grid.dart';
import '../../widgets/transaction_tile.dart';

class HomeTab extends StatelessWidget {
  final bool isDark;
  final String userName;
  final bool balanceVisible;
  final bool isKycVerified;
  final VoidCallback onToggleBalance;
  final VoidCallback onProfileTap;
  final List<Transaction> transactions;
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;
  final VoidCallback? onViewAll;

  const HomeTab({
    super.key,
    required this.isDark,
    required this.userName,
    required this.balanceVisible,
    required this.isKycVerified,
    required this.onToggleBalance,
    required this.onProfileTap,
    required this.transactions,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 110,
          floating: true,
          pinned: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: DashboardHeader(
              isDark: isDark,
              userName: userName,
              onProfileTap: onProfileTap,
              onNotificationTap: () {},
            ),
          ),
        ),
        if (!isKycVerified)
          SliverToBoxAdapter(child: _buildKycWarningBanner(context)),
        SliverToBoxAdapter(
          child: BalanceCard(
            isDark: isDark,
            isVisible: balanceVisible,
            userName: userName,
            balance: totalBalance,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            showStats: transactions.isNotEmpty,
            onToggleVisibility: onToggleBalance,
            onAiAdvisorTap: () {
              final totalVolume = transactions.fold(
                0.0,
                (sum, t) => sum + t.amount.abs(),
              );
              if (totalVolume < 10000) {
                GlassDialog.showInfo(
                  context,
                  title: 'Analysis Unavailable',
                  message:
                      'You must have a total transaction volume of at least Rs. 10,000 to unlock AI insights and conversation.',
                );
              } else {
                context.push('/ai-advisor');
              }
            },
            onIncomeTap: () => _showTransactionListBottomSheet(
              context,
              'Income',
              transactions.where((t) => t.amount > 0).toList(),
            ),
            onExpenseTap: () => _showTransactionListBottomSheet(
              context,
              'Expense',
              transactions.where((t) => t.amount < 0).toList(),
            ),
          ),
        ),
        SliverToBoxAdapter(child: const SizedBox(height: 12)),
        SliverToBoxAdapter(child: QuickActionsGrid(isDark: isDark)),
        SliverToBoxAdapter(child: PromoCard(isDark: isDark)),
        SliverToBoxAdapter(
          child: _buildSectionHeader(
            context,
            'Recent Transactions',
            isDark,
            onViewAll,
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 120),
          sliver: transactions.isEmpty
              ? SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isDark ? AppTheme.surfaceDark : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history_rounded,
                            size: 40,
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.1),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : AppTheme.textSecondaryColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Transactions you make will appear here.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.textHintDark
                                : AppTheme.textHintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => TransactionTile(
                      transaction: transactions[i],
                      isDark: isDark,
                      index: i,
                    ),
                    childCount: transactions.length > 5
                        ? 5
                        : transactions.length,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildKycWarningBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFF59E0B).withValues(alpha: 0.9),
            const Color(0xFFD97706),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Account Unverified',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Complete eKYC to unlock full limits.',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              context.push('/ekyc');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFD97706),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: AppTheme.radiusMedium,
              ),
              elevation: 0,
            ),
            child: const Text(
              'Verify Now',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    bool isDark,
    VoidCallback? onViewAll,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          if (onViewAll != null)
            TextButton(
              onPressed: onViewAll,
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTransactionListBottomSheet(
    BuildContext context,
    String title,
    List<Transaction> filteredTransactions,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white12 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filteredTransactions.isEmpty
                  ? const Center(child: Text('No transactions found'))
                  : ListView.builder(
                      itemCount: filteredTransactions.length,
                      itemBuilder: (context, i) => TransactionTile(
                        transaction: filteredTransactions[i],
                        isDark: isDark,
                        index: i,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
