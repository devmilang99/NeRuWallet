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
    return Column(
      children: [
        const SizedBox(height: 64),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Transactions',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.filter_list_rounded),
              ),
            ],
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: months.length,
            separatorBuilder: (context, idx) => const SizedBox(width: 10),
            itemBuilder: (ctx, i) {
              final isActive = i == 0;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppTheme.primaryColor
                      : (isDark ? AppTheme.surfaceDark : Colors.white),
                  borderRadius: AppTheme.radiusFull,
                ),
                child: Text(
                  months[i],
                  style: TextStyle(
                    color: isActive
                        ? Colors.white
                        : (isDark
                            ? AppTheme.textBodyDark
                            : AppTheme.textBodyColor),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: transactions.length,
            itemBuilder: (ctx, i) => TransactionTile(
              transaction: transactions[i],
              isDark: isDark,
              index: i,
            ),
          ),
        ),
      ],
    );
  }
}
