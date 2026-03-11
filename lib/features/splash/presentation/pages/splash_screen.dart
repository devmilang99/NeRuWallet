import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        context.go('/permissions');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppTheme.surfaceDark.withOpacity(0.8)
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(
                          alpha: isDark ? 0.2 : 0.1,
                        ),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ),
                )
                .animate()
                .scale(duration: 800.ms, curve: Curves.fastOutSlowIn)
                .rotate(duration: 800.ms, curve: Curves.fastOutSlowIn)
                .then(delay: 500.ms)
                .shimmer(
                  duration: 1200.ms,
                  color: isDark ? Colors.white10 : Colors.white24,
                ),
            const SizedBox(height: 40),
            Text(
                  "NeRuWallet",
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.3, end: 0, duration: 800.ms),
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: AppTheme.radiusFull,
              ),
            ).animate().fadeIn(delay: 1000.ms).scaleX(begin: 0, end: 1),
            const SizedBox(height: 12),
            Text(
              "Professional Digital Payments",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 1200.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
