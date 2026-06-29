import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class TransactionReceiptSheet extends StatelessWidget {
  final String title;
  final String target;
  final double amount;
  final double fee;
  final double tax;
  final VoidCallback onConfirm;
  final bool isSuccess;
  final String? transactionId;
  final Map<String, dynamic>? metadata;

  const TransactionReceiptSheet({
    super.key,
    required this.title,
    required this.target,
    required this.amount,
    this.fee = 0.0,
    this.tax = 0.0,
    required this.onConfirm,
    this.isSuccess = false,
    this.transactionId,
    this.metadata,
  });

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String target,
    required double amount,
    double fee = 0.0,
    double tax = 0.0,
    Map<String, dynamic>? metadata,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionReceiptSheet(
        title: title,
        target: target,
        amount: amount,
        fee: fee,
        tax: tax,
        onConfirm: () => Navigator.pop(context),
        isSuccess: true,
        transactionId:
            "TXN${DateTime.now().millisecondsSinceEpoch % 100000000}",
        metadata: metadata,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final total = (fee == 0 && tax == 0) ? amount : amount + fee + tax;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.receipt_long_rounded,
              size: 64,
              color: isSuccess ? AppTheme.successColor : AppTheme.primaryColor,
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 16),
            Text(
              isSuccess ? "Payment Successful" : "Transaction Preview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : AppTheme.textBodyColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess
                  ? "Your transaction has been processed."
                  : "Please review the details below",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),

            // Receipt Details
            _buildReceiptRow("Service", title, isDark),
            const SizedBox(height: 12),
            _buildReceiptRow("To/From", target, isDark),

            if (metadata != null) ...[
              for (var entry in metadata!.entries) ...[
                const SizedBox(height: 12),
                _buildReceiptRow(entry.key, entry.value.toString(), isDark),
              ],
            ],

            if (isSuccess && transactionId != null) ...[
              const SizedBox(height: 12),
              _buildReceiptRow("Transaction ID", transactionId!, isDark),
            ],

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            _buildReceiptRow(
              "Base Amount",
              "Rs. ${amount.toStringAsFixed(2)}",
              isDark,
            ),

            if (fee != 0.0) ...[
              const SizedBox(height: 12),
              _buildReceiptRow(
                "Service Fee",
                "Rs. ${fee.toStringAsFixed(2)}",
                isDark,
              ),
            ],
            if (tax != 0.0) ...[
              const SizedBox(height: 12),
              _buildReceiptRow(
                "Service Tax (VAT)",
                "Rs. ${tax.toStringAsFixed(2)}",
                isDark,
              ),
            ],

            const SizedBox(height: 24),

            // Total Amount
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color:
                    (isSuccess ? AppTheme.successColor : AppTheme.primaryColor)
                        .withValues(alpha: 0.05),
                borderRadius: AppTheme.radiusLarge,
                border: Border.all(
                  color:
                      (isSuccess
                              ? AppTheme.successColor
                              : AppTheme.primaryColor)
                          .withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSuccess ? "Amount Paid" : "Total Payable",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Rs. ${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                      color: isSuccess
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            if (!isSuccess)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusLarge,
                  ),
                  elevation: 4,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Confirm & Authenticate",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0)
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusLarge,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onConfirm,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text("Download"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 56),
                        backgroundColor: AppTheme.successColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppTheme.radiusLarge,
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),

            const SizedBox(height: 12),
            if (!isSuccess)
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Modify Details"),
              )
            else
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text("Back to Home"),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.textBodyColor,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
