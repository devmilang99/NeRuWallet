import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
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

      setState(() => _statusMessage = "Loading user preferences...");
      final prefService = ref.read(preferenceServiceProvider);
      final bool isFirstTime =
          await prefService.getBool('is_first_time') ?? true;

      // Wait for splash animation if it's faster than the checks
      await splashFuture;

      if (!mounted) return;

      if (isFirstTime) {
        await _navigateBasedOnPermissions();
      } else {
        // Check if user is already authenticated and can skip login
        final destination = await _resolveAuthDestination(prefService);

        // If the destination is dashboard and the user enabled app-login via biometrics,
        // prompt for biometric authentication before navigating.
        if (destination == '/dashboard') {
          final bool biometricEnabled =
              await prefService.getBool('biometrics_login_enabled') ?? false;

          final bool canAuth =
              biometricEnabled && await BiometricService.isEnrolled();

          if (canAuth) {
            final success = await BiometricService.authenticate(
              title: 'NeRuWallet',
              subtitle: 'Authenticate to continue',
              reason: 'Please authenticate to access your wallet',
              biometricOnly: true,
            );

            if (mounted) {
              if (success) {
                context.go(destination);
              } else {
                // Failed biometric: send to login so user can re-authenticate.
                context.go('/auth/login');
              }
            }
            return;
          }
        }

        if (mounted) context.go(destination);
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

  /// Determines where to navigate after the splash screen for returning users.
  ///
  /// - If the user is signed in via a **social provider** (Google / Apple),
  ///   go to dashboard directly (they never need to re-enter credentials).
  /// - If the user signed in with **email/password** AND has "Remember Me"
  ///   enabled, go to dashboard directly.
  /// - Otherwise, route to the login screen.
  Future<String> _resolveAuthDestination(PreferenceService prefService) async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final bool registrationComplete =
        await prefService.getBool('registration_complete') ?? false;

    if (firebaseUser != null) {
      // Check the sign-in providers linked to this account
      final providers = firebaseUser.providerData
          .map((p) => p.providerId)
          .toList();
      final isSocialUser =
          providers.contains('google.com') || providers.contains('apple.com');

      // If registration was never finished (PINs not set), and it's a social user,
      // the user should be removed according to requirements.
      if (!registrationComplete && isSocialUser) {
        final authService = AuthService();
        await authService.deleteAccount();
        return '/auth/login';
      }

      if (isSocialUser) {
        // Social users: always go straight to dashboard on app reopen IF registration is complete
        return '/dashboard';
      }

      // Email/password user: only skip login if "Remember Me" was enabled
      final bool rememberMe = await prefService.getBool('remember_me') ?? false;
      if (rememberMe && registrationComplete) {
        return '/dashboard';
      }
    }

    return '/auth/login';
  }

  Future<void> _navigateBasedOnPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final notificationStatus = await Permission.notification.status;

    // We only force permission screen if camera or notifications are missing
    final allPermissionsGranted =
        cameraStatus.isGranted && notificationStatus.isGranted;

    if (mounted) {
      if (allPermissionsGranted) {
        context.go('/theme-selection');
      } else {
        context.goNamed('permissions');
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
          child: Image.asset(
            "assets/icons/app_icon.png",
            height: 80,
            width: 80,
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
