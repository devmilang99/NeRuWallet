import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    final prefService = ref.read(preferenceServiceProvider);
    final rememberMe = await prefService.getBool('remember_me') ?? false;
    final biometricEnabled =
        await prefService.getBool('biometrics_login_enabled') ?? false;

    // Check if biometrics are enrolled by the system
    final isEnrolled = await BiometricService.isEnrolled();

    if (mounted) {
      setState(() {
        _rememberMe = rememberMe;
        _biometricEnabled = biometricEnabled && isEnrolled;
      });
    }
  }

  Future<void> _handleBiometricLogin() async {
    final success = await BiometricService.authenticate(
      title: 'NeRuWallet Login',
      subtitle: 'Authenticate to access your wallet',
      reason: 'Use biometrics to securely log in.',
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleGoogleLogin() async {
    GlassDialog.showLoading(context, message: 'Connecting to Google...');
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      if (!mounted) return;
      Navigator.pop(context); // Close loading
      if (user != null) {
        if (user.isNewUser) {
          context.go(
            '/auth/security-setup',
            extra: {
              'isSocial': true,
              'email': user.email,
              'name': user.name,
              'isNewUser': true,
            },
          );
        } else {
          // Sync data from cloud in background before navigating
          ref.read(syncServiceProvider).performFullSync().catchError((e) {
            AppLogger.e('Background sync failed', e);
          });

          final prefService = ref.read(preferenceServiceProvider);
          await prefService.setBool('registration_complete', true);
          if (!mounted) return;
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        AppLogger.e('Google Login Detail Error', e);
        var errorMessage = 'Google Sign-In failed: ${e.toString()}';
        if (e.toString().contains('cancelled')) {
          errorMessage = 'Google Sign-In was cancelled.';
        }
        GlassDialog.showError(context, errorMessage);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      GlassDialog.showError(context, 'Please enter both email and password.');
      return;
    }

    GlassDialog.showLoading(context, message: 'Signing you in...');

    try {
      final user = await ref
          .read(authServiceProvider)
          .signInWithEmailPassword(
            _emailController.text,
            _passwordController.text,
          );
      if (mounted) {
        Navigator.pop(context);
        if (user != null) {
          final prefService = ref.read(preferenceServiceProvider);
          if (user.isNewUser) {
            context.go(
              '/auth/security-setup',
              extra: {
                'isSocial': false,
                'email': _emailController.text,
                'isNewUser': true,
              },
            );
          } else {
            // Sync data from cloud in background for returning email users
            ref.read(syncServiceProvider).performFullSync().catchError((e) {
              debugPrint('Background sync failed: $e');
            });

            await prefService.setBool('remember_me', _rememberMe);
            await prefService.setBool('registration_complete', true);
            if (mounted) context.go('/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showError(
          context,
          'Authentication Failed: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: isDark ? 0.3 : 0.1,
              child: Image.network(
                'https://images.unsplash.com/photo-1639762681485-074b7f938ba0?q=80&w=2832&auto=format&fit=crop',
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    (isDark
                            ? AppTheme.backgroundDark
                            : AppTheme.backgroundColor)
                        .withValues(alpha: 0.8),
                    isDark ? AppTheme.backgroundDark : AppTheme.backgroundColor,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 600, // Adaptive for large screens
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 40,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                                  'Welcome',
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 40,
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 200.ms)
                                .slideX(begin: -0.2, end: 0),
                            const SizedBox(height: 12),
                            Text(
                                  'Log in to secure your financial future.',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: isDark
                                            ? AppTheme.textSecondaryDark
                                            : AppTheme.textSecondaryColor,
                                        letterSpacing: 0.5,
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 300.ms)
                                .slideX(begin: -0.2, end: 0),
                            const SizedBox(height: 48),
                            // Card for Fields
                            Container(
                                  padding: const EdgeInsets.all(28),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.surfaceDark.withValues(
                                            alpha: 0.7,
                                          )
                                        : Colors.white.withValues(alpha: 0.9),
                                    borderRadius: AppTheme.radiusLarge,
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.08)
                                          : Colors.white,
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.3 : 0.08,
                                        ),
                                        blurRadius: 40,
                                        offset: const Offset(0, 20),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          labelText: 'Email address',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                          hintText: 'example@domain.com',
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      TextField(
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          labelText: 'Password',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline_rounded,
                                          ),
                                          hintText: '••••••••',
                                          suffixIcon: IconButton(
                                            onPressed: () => setState(
                                              () => _obscurePassword =
                                                  !_obscurePassword,
                                            ),
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                        .visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              onChanged: (v) => setState(
                                                () => _rememberMe = v ?? false,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Text(
                                            'Remember me',
                                            style: TextStyle(fontSize: 13),
                                          ),
                                          const Spacer(),
                                          TextButton(
                                            onPressed: () => context.push(
                                              '/auth/forgot-password',
                                            ),
                                            style: TextButton.styleFrom(
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            child: const Text(
                                              'Forgot password?',
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 32),
                                      ElevatedButton(
                                        onPressed: _handleLogin,
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: const Size(
                                            double.infinity,
                                            64,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: AppTheme.radiusMedium,
                                          ),
                                          elevation: 8,
                                          shadowColor: AppTheme.primaryColor
                                              .withValues(alpha: 0.3),
                                        ),
                                        child: const Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (_biometricEnabled) ...[
                                        const SizedBox(height: 24),
                                        const Row(
                                          children: [
                                            Expanded(child: Divider()),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 16.0,
                                              ),
                                              child: Text(
                                                'Quick Access',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                            Expanded(child: Divider()),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Center(
                                              child: InkWell(
                                                onTap: _handleBiometricLogin,
                                                borderRadius:
                                                    BorderRadius.circular(30),
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    12,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: AppTheme
                                                          .primaryColor
                                                          .withValues(
                                                            alpha: 0.2,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Icon(
                                                    Icons.fingerprint_rounded,
                                                    size: 48,
                                                    color:
                                                        AppTheme.primaryColor,
                                                  ),
                                                ),
                                              ),
                                            )
                                            .animate()
                                            .fadeIn(delay: 500.ms)
                                            .scale(),
                                      ],
                                    ],
                                  ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .scale(
                                  begin: const Offset(0.9, 0.9),
                                  end: const Offset(1, 1),
                                ),
                            const SizedBox(height: 40),
                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 32),
                            _buildSocialButton(
                                  icon:
                                      'https://www.vectorlogo.zone/logos/google/google-icon.svg',
                                  label: 'Google',
                                  onPressed: _handleGoogleLogin,
                                )
                                .animate()
                                .fadeIn(delay: 800.ms)
                                .slideY(begin: 0.2, end: 0),
                            const SizedBox(height: 48),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text('New here? '),
                                TextButton(
                                  onPressed: () => context.push('/auth/signup'),
                                  child: const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().fadeIn(delay: 1000.ms),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        backgroundColor: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.4)
            : Colors.white.withValues(alpha: 0.6),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.network(
            icon,
            height: 20,
            placeholderBuilder: (context) => const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
