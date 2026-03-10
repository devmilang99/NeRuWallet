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
    // After animation or duration, navigate to onboarding
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
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
                .scale(
                  duration: 800.ms,
                  curve: Curves.fastOutSlowIn,
                )
                .rotate(
                  duration: 800.ms,
                  curve: Curves.fastOutSlowIn,
                )
                .then(delay: 500.ms)
                .shimmer(duration: 1200.ms, color: Colors.white24),
            const SizedBox(height: 40),
            Text(
              "NeRuWallet",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.primaryColor,
                    fontSize: 36,
                    letterSpacing: 2,
                  ),
            )
                .animate()
                .fadeIn(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.5, end: 0, duration: 800.ms),
            const SizedBox(height: 10),
            Text(
              "Secure, Scalable, Seamless",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textHintColor,
                    letterSpacing: 1.2,
                  ),
            )
                .animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
