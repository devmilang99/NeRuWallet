import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/dashboard/data/models/transaction_model.dart';
import 'package:intl/intl.dart';

class TransactionDetailSheet extends StatelessWidget {
  final TransactionModel transaction;
  final bool isDark;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.amount < 0;
    final double total = transaction.totalPayable;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          // Icon and Title
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transaction.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(transaction.icon, size: 40, color: transaction.color),
          ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          
          const SizedBox(height: 16),
          Text(
            transaction.title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppTheme.textBodyColor,
            ),
          ),
          Text(
            transaction.subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          
          // Financial Breakdown
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : Colors.grey[50],
              borderRadius: AppTheme.radiusLarge,
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Column(
              children: [
                _buildDetailRow("Status", "Completed", isDark, valueColor: AppTheme.successColor),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildDetailRow("Date & Time", transaction.time == 'Just now' ? DateFormat('dd MMM, hh:mm a').format(DateTime.now()) : transaction.time, isDark),
                const SizedBox(height: 12),
                _buildDetailRow("Transaction Type", transaction.category, isDark),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                _buildDetailRow("Base Amount", "Rs. ${transaction.amount.abs().toStringAsFixed(2)}", isDark),
                if (isExpense) ...[
                  const SizedBox(height: 12),
                  _buildDetailRow("Service Fee", "Rs. ${transaction.fee.toStringAsFixed(2)}", isDark),
                  const SizedBox(height: 12),
                  _buildDetailRow("Service Tax (VAT)", "Rs. ${transaction.tax.toStringAsFixed(2)}", isDark),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Amount",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Rs. ${total.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: isExpense ? AppTheme.errorColor : AppTheme.successColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Download/Share Buttons (Mocked for now as per request)
          Row(
            children: [
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.download_rounded,
                  label: "Download Receipt",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Receipt downloaded to your gallery!')),
                    );
                  },
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildActionBtn(
                  icon: Icons.share_rounded,
                  label: "Share",
                  onTap: () {},
                  isDark: isDark,
                ),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isDark ? Colors.white : AppTheme.textBodyColor),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? AppTheme.surfaceDark : Colors.grey[100],
        foregroundColor: isDark ? Colors.white : AppTheme.textBodyColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: AppTheme.radiusLarge,
          side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
