import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  final bool isKycVerified;
  final VoidCallback onToggleBalance;
  final VoidCallback onProfileTap;
  final List<TransactionModel> transactions;
  final List<QuickActionModel> quickActions;

  const HomeTab({
    super.key,
    required this.isDark,
    required this.balanceVisible,
    required this.isKycVerified,
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
        SliverAppBar(
          expandedHeight: 140,
          floating: true,
          pinned: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: DashboardHeader(
              isDark: isDark,
              userName: 'Raju Ghimire',
              onProfileTap: onProfileTap,
              onNotificationTap: () {},
            ),
          ),
        ),
        if (!isKycVerified)
          SliverToBoxAdapter(
            child: _buildKycWarningBanner(context),
          ),
        SliverToBoxAdapter(
          child: BalanceCard(
            isDark: isDark,
            isVisible: balanceVisible,
            onToggleVisibility: onToggleBalance,
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverToBoxAdapter(
          child: QuickActionsGrid(isDark: isDark, actions: quickActions),
        ),
        SliverToBoxAdapter(child: PromoCard(isDark: isDark)),
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

  Widget _buildKycWarningBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shield_outlined, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Unverified',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Complete your eKYC to unlock transactions and higher limits.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/home'), // Start eKYC
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
                elevation: 0,
              ),
              child: const Text(
                'Verify Identity Now',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
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
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
