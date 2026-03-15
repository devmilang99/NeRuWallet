import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    // Temporary boolean to suggest if the user is a first-time user
    const bool isFirstTimeUser = true;

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    if (isFirstTimeUser) {
      // Check if all required permissions are granted
      final cameraStatus = await Permission.camera.status;
      final notificationStatus = await Permission.notification.status;
      final storageStatus = await Permission.storage.status;

      final allPermissionsGranted =
          cameraStatus.isGranted &&
          notificationStatus.isGranted &&
          storageStatus.isGranted;

      if (mounted) {
        if (allPermissionsGranted) {
          context.go('/onboarding');
        } else {
          context.go('/permissions');
        }
      }
    }
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
                )
                .then(delay: 100.ms) // 800 + 500 + 1200 + 100 = 2600ms
                .scaleXY(
                  begin: 1,
                  end: 1.05,
                  duration: 200.ms,
                ) // 2600 + 200 = 2800ms
                .then()
                .scaleXY(
                  begin: 1.05,
                  end: 1,
                  duration: 200.ms,
                ), // 2800 + 200 = 3000ms
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
