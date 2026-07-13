import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
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
  final AuthService _authService = AuthService();

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
      biometricOnly: true,
    );

    if (success && mounted) {
      context.go('/dashboard');
    }
  }

  Future<void> _handleGoogleLogin() async {
    GlassDialog.showLoading(context, message: 'Connecting to Google...');
    try {
      final user = await _authService.signInWithGoogle();
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
            debugPrint('Background sync failed: $e');
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
        debugPrint('Google Login Detail Error: $e');
        String errorMessage = 'Google Sign-In failed: ${e.toString()}';
        if (e.toString().contains('cancelled')) {
          errorMessage = 'Google Sign-In was cancelled.';
        }
        GlassDialog.showError(context, errorMessage);
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    GlassDialog.showLoading(context, message: 'Connecting to Apple...');
    try {
      final user = await _authService.signInWithApple();
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
            debugPrint('Background sync failed: $e');
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
        String errorMessage = 'Apple Sign-In failed. Please try again.';
        if (e.toString().contains('cancelled')) {
          errorMessage = 'Apple Sign-In was cancelled.';
        } else if (e.toString().contains('identity token')) {
          errorMessage =
              'Failed to retrieve Apple credentials. Please try again.';
        } else if (e.toString().contains('entitlements')) {
          errorMessage =
              'Apple Sign-In is not properly configured. Please contact support.';
        }
        GlassDialog.showError(context, errorMessage);
      }
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      GlassDialog.showError(context, "Please enter both email and password.");
      return;
    }

    GlassDialog.showLoading(context, message: 'Signing you in...');

    try {
      final user = await _authService.signInWithEmailPassword(
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
          "Authentication Failed: ${e.toString()}",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Welcome Back!",
                style: Theme.of(
                  context,
                ).textTheme.displayLarge?.copyWith(fontWeight: FontWeight.w900),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 8),
              Text(
                "Log in to secure your financial future.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.surfaceDark.withValues(alpha: 0.6)
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: "Email address",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? false),
                        ),
                        const Text(
                          "Remember me",
                          style: TextStyle(fontSize: 13),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () =>
                              context.push('/auth/forgot-password'),
                          child: const Text("Forgot password?"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _handleLogin,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 64),
                      ),
                      child: const Text("Sign In"),
                    ),
                    if (_biometricEnabled) ...[
                      const SizedBox(height: 24),
                      Center(
                        child: IconButton(
                          icon: const Icon(
                            Icons.fingerprint_rounded,
                            size: 56,
                            color: AppTheme.primaryColor,
                          ),
                          onPressed: _handleBiometricLogin,
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(),
                    ],
                  ],
                ),
              ).animate().fadeIn(delay: 400.ms).scale(),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("or continue with"),
                  ),
                  Expanded(child: Divider()),
                ],
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildSocialButton(
                      icon:
                          "https://www.vectorlogo.zone/logos/google/google-icon.svg",
                      label: "Google",
                      onPressed: _handleGoogleLogin,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      icon:
                          "https://www.vectorlogo.zone/logos/apple/apple-tile.svg",
                      label: "Apple",
                      onPressed: _handleAppleLogin,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              const SizedBox(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("New here? "),
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

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
