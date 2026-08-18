import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/services/database/app_database.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/icon_utils.dart';

class TransactionDetailSheet extends StatelessWidget {
  final Transaction transaction;
  final bool isDark;

  const TransactionDetailSheet({
    required this.transaction,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.amount < 0;
    final total = transaction.amount.abs() + transaction.fee + transaction.tax;
    final iconColor = Color(transaction.colorValue);
    final iconData = IconUtils.getIconData(transaction.iconCode);
    final formattedDate = DateFormat(
      'MMM dd, hh:mm a',
    ).format(transaction.createdAt);

    var metadata = <String, dynamic>{};
    if (transaction.metadata != null) {
      try {
        metadata = jsonDecode(transaction.metadata!);
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Header with Icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: iconColor, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Amount Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.surfaceDark.withOpacity(0.5)
                  : AppTheme.backgroundColor,
              borderRadius: AppTheme.radiusLarge,
            ),
            child: Column(
              children: [
                Text(
                  isExpense ? 'Amount Sent' : 'Amount Received',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "${isExpense ? '-' : '+'}Rs ${transaction.amount.abs().toStringAsFixed(2)}",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: isExpense
                        ? AppTheme.errorColor
                        : AppTheme.successColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (transaction.fee > 0 || transaction.tax > 0) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  _buildSummaryRow(
                    'Service Fee',
                    'Rs ${transaction.fee.toStringAsFixed(2)}',
                    isDark,
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow(
                    'Taxes',
                    'Rs ${transaction.tax.toStringAsFixed(2)}',
                    isDark,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1),
                  ),
                  _buildSummaryRow(
                    'Total Impact',
                    'Rs ${total.toStringAsFixed(2)}',
                    isDark,
                    isBold: true,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Status & Category
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Status',
                  'Completed',
                  Icons.check_circle_rounded,
                  AppTheme.successColor,
                  isDark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInfoCard(
                  'Category',
                  transaction.category,
                  iconData,
                  AppTheme.primaryColor,
                  isDark,
                ),
              ),
            ],
          ),

          if (metadata.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildMetadataSection(metadata, isDark),
          ],

          const SizedBox(height: 32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Receipt'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_rounded),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value,
    bool isDark, {
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white70 : Colors.black54,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
        borderRadius: AppTheme.radiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(Map<String, dynamic> metadata, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.black.withOpacity(0.02),
        borderRadius: AppTheme.radiusMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transaction Details',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          ...metadata.entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Text(
                    '${e.key}: ',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  Text(
                    e.value.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
