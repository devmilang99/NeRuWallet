import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../widgets/transaction_tile.dart';
import '../../../data/models/transaction_model.dart';

class HistoryTab extends StatelessWidget {
  final bool isDark;
  final List<TransactionModel> transactions;

  const HistoryTab({
    super.key,
    required this.isDark,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final months = ['All', 'Mar', 'Feb', 'Jan'];
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          floating: false,
          pinned: true,
          stretch: true,
          backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF1F5F9),
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            stretchModes: const [StretchMode.blurBackground, StretchMode.zoomBackground],
            centerTitle: false,
            titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
            title: Text(
              'Transactions',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 24,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: months.length,
                separatorBuilder: (context, idx) => const SizedBox(width: 10),
                itemBuilder: (ctx, i) {
                  final isActive = i == 0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.primaryColor
                          : (isDark ? AppTheme.surfaceDark : Colors.white),
                      borderRadius: AppTheme.radiusFull,
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      months[i],
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? AppTheme.textBodyDark
                                : AppTheme.textBodyColor),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  );
                },
              ),
            ),
          ).animate().fadeIn(),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) => TransactionTile(
                transaction: transactions[i],
                isDark: isDark,
                index: i,
              ),
              childCount: transactions.length,
            ),
          ),
        ),
      ],
    );
  }
}
