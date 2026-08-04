import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/providers/init_provider.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _statusMessage = 'Initializing systems...';
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Minimum branding delay to show the logo
    final splashFuture = Future.delayed(const Duration(seconds: 2));

    try {
      // 1. Core System Initialization (Supabase/Firebase started in main.dart)
      if (mounted) setState(() => _statusMessage = 'Starting systems...');
      await ref.read(appInitProvider);

      // 2. Connectivity & User Data (Parallel)
      if (mounted) setState(() => _statusMessage = 'Syncing data...');

      final results = await Future.wait([
        Connectivity().checkConnectivity(),
        ref.read(preferenceServiceProvider).getBool('is_first_time'),
        splashFuture, // Ensure we stay at least 2 seconds for branding
      ]);

      final connectivityResult = results[0] as List<ConnectivityResult>;
      final isFirstTime = (results[1] as bool?) ?? true;

      // 3. Check Connectivity
      if (connectivityResult.contains(ConnectivityResult.none)) {
        throw Exception('No internet connection detected.');
      }

      if (!mounted) return;

      final prefService = ref.read(preferenceServiceProvider);

      if (isFirstTime) {
        await _navigateBasedOnPermissions();
      } else {
        // 4. Validate Session with server if user exists locally
        final supabaseUser = sb.Supabase.instance.client.auth.currentUser;
        if (supabaseUser != null) {
          if (mounted) setState(() => _statusMessage = 'Validating session...');
          final isValid = await ref.read(authServiceProvider).validateSession();

          if (!isValid) {
            await prefService.clearAuthPreferences();
            await ref.read(authServiceProvider).signOut();

            if (mounted) {
              await _showInvalidSessionDialog();
              if (mounted) {
                context.go('/auth/login');
              }
              return;
            }
          }
        }

        // Check if user is already authenticated and can skip login
        final destination = await _resolveAuthDestination(prefService);

        // If the destination is dashboard and the user enabled app-login via biometrics,
        // prompt for biometric authentication before navigating.
        if (destination == '/dashboard') {
          final biometricEnabled =
              await prefService.getBool('biometrics_login_enabled') ?? false;

          final canAuth =
              biometricEnabled && await BiometricService.isEnrolled();

          if (canAuth) {
            final success = await BiometricService.authenticate(
              title: 'NeRuWallet',
              subtitle: 'Authenticate to continue',
              reason: 'Please authenticate to access your wallet',
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
          _statusMessage = e.toString().replaceAll('Exception: ', '');
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
    final supabaseUser = sb.Supabase.instance.client.auth.currentUser;
    final registrationComplete =
        await prefService.getBool('registration_complete') ?? false;

    if (supabaseUser != null) {
      final providers =
          supabaseUser.appMetadata['providers'] as List<dynamic>? ?? [];
      final isSocialUser =
          providers.contains('google') || providers.contains('apple');

      // If local registration is marked as incomplete, we trigger sync in the background
      // and let the user proceed if they are a social user (who are already authenticated).
      if (!registrationComplete) {
        // TRIGGER BACKGROUND SYNC WITHOUT AWAITING
        unawaited(
          ref
              .read(syncServiceProvider)
              .performFullSync()
              .then<void>((_) async {
                final restored =
                    await prefService.getBool('registration_complete') ?? false;
                if (!restored && isSocialUser) {
                  // If sync failed to restore completion state for a social user,
                  // we might eventually need to handle that, but don't block splash.
                }
              })
              .catchError((Object e) {
                AppLogger.e('Background sync failed', e);
              }),
        );

        if (isSocialUser) return '/dashboard';
      }

      if (isSocialUser) return '/dashboard';

      final rememberMe = await prefService.getBool('remember_me') ?? false;
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

  Future<void> _showInvalidSessionDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusLarge),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
              SizedBox(width: 10),
              Text('Session Expired'),
            ],
          ),
          content: const Text(
            'Your account session is no longer valid or has been removed. '
            'To keep your wallet secure, you must register or sign in again.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundColor,
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
            'assets/icons/app_icon.png',
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
          'NeRuWallet',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.primaryColor,
            fontSize: 42,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

        const SizedBox(height: 24),

        if (_hasError) ...[
          const Icon(
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
            label: const Text('Retry Connection'),
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
