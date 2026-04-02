import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BookingVerificationSheet extends StatelessWidget {
  final String title;
  final String provider;
  final Map<String, String> details;
  final List<String>? passengers;
  final double amount;
  final Color color;
  final VoidCallback onConfirm;

  const BookingVerificationSheet({
    super.key,
    required this.title,
    required this.provider,
    required this.details,
    this.passengers,
    required this.amount,
    required this.color,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.fact_check_rounded, size: 40, color: color),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 16),
              Text(
                "Verify Booking",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppTheme.textBodyColor,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Please review your $title details",
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white54 : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              
              // Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.grey[50],
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200]!,
                  ),
                ),
                child: Column(
                  children: [
                    _buildRow("Provider", provider, isDark, isHeader: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    ...details.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildRow(e.key, e.value, isDark),
                    )),
                    if (passengers != null && passengers!.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1),
                      ),
                      _buildRow("Review Passengers", "", isDark, isHeader: true),
                      const SizedBox(height: 12),
                      ...passengers!.map((p) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Icon(Icons.person_outline_rounded, size: 14, color: color),
                            const SizedBox(width: 8),
                            Text(
                              p,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isDark ? Colors.white : AppTheme.textBodyColor,
                              ),
                            ),
                          ],
                        ),
                      )),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Total Amount
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(color: color.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Fare",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Rs. ${amount.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  onConfirm();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded, size: 20),
                    SizedBox(width: 12),
                    Text(
                      "Confirm & Pay",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Modify Details",
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey[600]),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, bool isDark, {bool isHeader = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontSize: isHeader ? 12 : 14,
            fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
            letterSpacing: isHeader ? 1 : 0,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.textBodyColor,
            fontWeight: isHeader ? FontWeight.w900 : FontWeight.bold,
            fontSize: isHeader ? 15 : 14,
          ),
        ),
      ],
    );
  }
}
