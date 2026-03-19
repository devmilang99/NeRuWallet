import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusMessage = "Initializing systems...";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    setState(() {
      _hasError = false;
      _statusMessage = "Checking connectivity...";
    });

    // Minimum delay for branding
    final splashFuture = Future.delayed(const Duration(seconds: 3));

    try {
      // 1. Check Connectivity
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception("No internet connection detected.");
      }

      // Verify actual internet access (Connectivity only checks radio)
      try {
        final result = await InternetAddress.lookup(
          'google.com',
        ).timeout(const Duration(seconds: 5));
        if (result.isEmpty || result[0].rawAddress.isEmpty) {
          throw Exception("No internet access.");
        }
      } catch (_) {
        throw Exception("Server unreachable. Check your connection.");
      }

      setState(() => _statusMessage = "Loading user preferences...");
      final prefs = await SharedPreferences.getInstance();
      final bool isFirstTime = prefs.getBool('is_first_time') ?? true;

      // Wait for splash animation if it's faster than the checks
      await splashFuture;

      if (!mounted) return;

      if (isFirstTime) {
        await _navigateBasedOnPermissions();
      } else {
        context.go('/auth/login');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statusMessage = e.toString().replaceAll("Exception: ", "");
          _hasError = true;
        });
      }
    }
  }

  Future<void> _navigateBasedOnPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final notificationStatus = await Permission.notification.status;

    // We only force permission screen if camera or notifications are missing
    final allPermissionsGranted =
        cameraStatus.isGranted && notificationStatus.isGranted;

    if (mounted) {
      if (allPermissionsGranted) {
        context.go('/onboarding');
      } else {
        context.go('/permissions');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(isDark),
            const SizedBox(height: 40),
            _buildContent(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.9),
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
        );
  }

  Widget _buildContent(bool isDark) {
    return Column(
      children: [
        Text(
          "NeRuWallet",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 24),

        if (_hasError) ...[
          Icon(
            Icons.wifi_off_rounded,
            color: AppTheme.errorColor,
            size: 32,
          ).animate().shake(),
          const SizedBox(height: 12),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: _initializeApp,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text("Retry Connection"),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
        ] else ...[
          Text(
            _statusMessage,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ).animate(key: ValueKey(_statusMessage)).fadeIn(),
          const SizedBox(height: 16),
          const SizedBox(
            width: 140,
            child: LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: AppTheme.primaryColor,
              minHeight: 2,
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ],
    );
  }
}
