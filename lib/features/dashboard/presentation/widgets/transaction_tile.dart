import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final bool isDark;
  final int index;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: transaction.color.withValues(alpha: 0.12),
                borderRadius: AppTheme.radiusMedium,
              ),
              child: Icon(transaction.icon, color: transaction.color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    transaction.subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : ''}NPR ${transaction.amount.abs().toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isCredit
                        ? AppTheme.successColor
                        : AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppTheme.textHintDark
                        : AppTheme.textHintColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate(delay: (60 * index).ms).fadeIn().slideX(begin: 0.05, end: 0),
    );
  }
}
