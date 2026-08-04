import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neruwallet/core/providers/balance_provider.dart';
import 'package:neruwallet/core/providers/spending_limit_provider.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BalanceCard extends ConsumerWidget {
  final bool isDark;
  final bool isVisible;
  final String userName;
  final double balance;
  final double totalIncome;
  final double totalExpenses;
  final bool showStats;
  final VoidCallback onToggleVisibility;
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;
  final VoidCallback? onAiAdvisorTap;

  const BalanceCard({
    required this.isDark,
    required this.isVisible,
    required this.userName,
    required this.balance,
    required this.totalIncome,
    required this.totalExpenses,
    required this.showStats,
    required this.onToggleVisibility,
    super.key,
    this.onIncomeTap,
    this.onExpenseTap,
    this.onAiAdvisorTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _buildLimitWarning(ref),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Stack(
            children: [
              // Virtual Card Background
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: AppTheme.radiusLarge,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E1E2E), // Deep space blue/black
                      Color(0xFF2D2D44),
                      Color(0xFF1E1E2E),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
              ),

              // Decorative Glows
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
              ),

              // Glassmorphic Overlay for depth
              ClipRRect(
                borderRadius: AppTheme.radiusLarge,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    height: 220,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: AppTheme.radiusLarge,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                        width: 1.5,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header: Brand & Chip
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'NeRu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  ' PLATINUM',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                if (onAiAdvisorTap != null)
                                  IconButton(
                                        onPressed: onAiAdvisorTap,
                                        icon: const Icon(
                                          Icons.auto_awesome_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Colors.white
                                              .withValues(alpha: 0.1),
                                          padding: const EdgeInsets.all(8),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      )
                                      .animate(
                                        onPlay: (controller) =>
                                            controller.repeat(),
                                      )
                                      .shimmer(
                                        duration: 2000.ms,
                                        color: AppTheme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                const SizedBox(width: 12),
                                _buildCardChip(),
                              ],
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Balance Section
                        const Text(
                          'TOTAL BALANCE',
                          style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                layoutBuilder:
                                    (currentChild, previousChildren) => Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        ...previousChildren,
                                        ?currentChild,
                                      ],
                                    ),
                                child: isVisible
                                    ? Text(
                                        'Rs. ${NumberFormat('#,###.00').format(balance)}',
                                        key: const ValueKey('visible'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      )
                                    : const Text(
                                        'Rs. ••••••••',
                                        key: ValueKey('hidden'),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 2,
                                        ),
                                      ),
                              ),
                            ),
                            _buildVisibilityToggle(),
                          ],
                        ),
                        const Spacer(),
                        // Card Footer: Card Number & Name
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '•••• •••• •••• 4200',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    letterSpacing: 3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'VALID THRU',
                                  style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '12/28',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // NFC Icon subtle decoration
              Positioned(
                right: 24,
                top: 80,
                child: Transform.rotate(
                  angle: 1.57,
                  child: Icon(
                    Icons.wifi_rounded,
                    color: Colors.white.withValues(alpha: 0.1),
                    size: 24,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
        ),

        // Income/Expense Stats Card (Separate from Virtual Card)
        if (showStats)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildModernStat(
                      'INCOME',
                      'Rs. ${NumberFormat('#,###.00').format(totalIncome)}',
                      Icons.arrow_downward_rounded,
                      const Color(0xFF10B981),
                      onIncomeTap,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: (isDark ? Colors.white : Colors.black).withValues(
                      alpha: 0.05,
                    ),
                  ),
                  Expanded(
                    child: _buildModernStat(
                      'EXPENSE',
                      'Rs. ${NumberFormat('#,###.00').format(totalExpenses)}',
                      Icons.arrow_upward_rounded,
                      const Color(0xFFEF4444),
                      onExpenseTap,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
          ),
      ],
    );
  }

  Widget _buildCardChip() {
    return Container(
      width: 45,
      height: 35,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withValues(alpha: 0.8),
            const Color(0xFFB8860B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          ...List.generate(
            3,
            (i) => Positioned(
              top: (i + 1) * 8.0,
              left: 0,
              right: 0,
              child: Container(height: 1, color: Colors.black12),
            ),
          ),
          ...List.generate(
            2,
            (i) => Positioned(
              left: (i + 1) * 15.0,
              top: 0,
              bottom: 0,
              child: Container(width: 1, color: Colors.black12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return GestureDetector(
      onTap: onToggleVisibility,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.textBodyColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLimitWarning(WidgetRef ref) {
    final limitAsync = ref.watch(spendingLimitProvider);

    return limitAsync.when(
      data: (limitData) {
        if (!limitData.enabled || limitData.limit <= 0) {
          return const SizedBox.shrink();
        }

        final currentSpending = ref.watch(balanceProvider).monthlyExpenses;

        if (currentSpending > limitData.limit) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.errorColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppTheme.errorColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Monthly spending limit exceeded!',
                    style: TextStyle(
                      color: AppTheme.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  'Rs. ${currentSpending.toStringAsFixed(0)} / ${limitData.limit.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().shake();
        }
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
