import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/transaction_model.dart';
import 'transaction_detail_sheet.dart';

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
    final double displayAmount = transaction.amount.abs() + transaction.fee + transaction.tax;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
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
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                isDismissible: false,
                enableDrag: false,
                backgroundColor: Colors.transparent,
                builder: (context) => TransactionDetailSheet(
                  transaction: transaction,
                  isDark: isDark,
                ),
              );
            },
            borderRadius: AppTheme.radiusMedium,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: transaction.color.withValues(alpha: 0.1),
                      borderRadius: AppTheme.radiusMedium,
                    ),
                    child: Icon(transaction.icon, color: transaction.color, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          transaction.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${isCredit ? '+' : ''}NPR ${displayAmount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isCredit ? AppTheme.successColor : AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.time,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
