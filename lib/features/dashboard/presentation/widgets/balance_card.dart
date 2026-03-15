import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BalanceCard extends StatelessWidget {
  final bool isDark;
  final bool isVisible;
  final VoidCallback onToggleVisibility;

  const BalanceCard({
    super.key,
    required this.isDark,
    required this.isVisible,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6366F1),
              Color(0xFF8B5CF6),
              Color(0xFF4F46E5),
            ],
          ),
          borderRadius: AppTheme.radiusLarge,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Stack(
          children: [
            // decorative circles
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -40,
              right: 60,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Balance',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    GestureDetector(
                      onTap: onToggleVisibility,
                      child: Icon(
                        isVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isVisible
                      ? const Text(
                          'NPR 47,250.00',
                          key: ValueKey('visible'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        )
                      : const Text(
                          'NPR ••••••••',
                          key: ValueKey('hidden'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: const [
                    Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFF34D399),
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '+12.5% this month',
                      style: TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCardStat(
                      'Income',
                      'NPR 55,000',
                      Icons.arrow_downward_rounded,
                      const Color(0xFF34D399),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    _buildCardStat(
                      'Expense',
                      'NPR 7,750',
                      Icons.arrow_upward_rounded,
                      const Color(0xFFFC8181),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
          ),
    );
  }

  Widget _buildCardStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 12),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
