import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'dart:ui';

class BalanceCard extends StatelessWidget {
  final bool isDark;
  final bool isVisible;
  final double balance;
  final double totalExpenses;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const BalanceCard({
    super.key,
    required this.isDark,
    required this.isVisible,
    required this.balance,
    required this.totalExpenses,
    required this.onToggleVisibility,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Stack(
        children: [
          // Background Gradient & Glow
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: AppTheme.radiusLarge,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6366F1),
                  const Color(0xFF8B5CF6),
                  const Color(0xFFD946EF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          
          // Decorative Abstract Shapes for Premium Look
          Positioned(
            top: -20,
            right: -20,
            child: _buildCircle(120, Colors.white.withValues(alpha: 0.1)),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveY(begin: 0, end: 10, duration: 3.seconds),
          
          Positioned(
            bottom: -30,
            left: -10,
            child: _buildCircle(150, Colors.white.withValues(alpha: 0.05)),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).moveX(begin: 0, end: 15, duration: 4.seconds),

          // Main Glass Content
          ClipRRect(
            borderRadius: AppTheme.radiusLarge,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                height: 200,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radiusLarge,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL BALANCE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: isVisible
                                  ? Text(
                                      'Rs. ${NumberFormat('#,###.00').format(balance)}',
                                      key: const ValueKey('visible'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    )
                                  : const Text(
                                      'Rs. ••••••••',
                                      key: ValueKey('hidden'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        _buildVisibilityToggle(),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModernStat(
                              'INCOME',
                              'Rs. 12,450.00',
                              Icons.arrow_downward_rounded,
                              const Color(0xFF4ADE80),
                              onIncomeTap,
                            ),
                          ),
                          Container(width: 1, height: 30, color: Colors.white24),
                          Expanded(
                            child: _buildModernStat(
                              'EXPENSE',
                              'Rs. ${NumberFormat('#,###.00').format(totalExpenses)}',
                              Icons.arrow_upward_rounded,
                              const Color(0xFFF87171),
                              onExpenseTap,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GestureDetector(
      onTap: onToggleVisibility,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(
          isVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildModernStat(
    String label,
    String value,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
