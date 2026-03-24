import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthService _authService = AuthService();

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      GlassDialog.showError(
        context,
        "Please enter both email and password to continue.",
      );
      return;
    }

    GlassDialog.showLoading(context, message: 'Signing you in...');

    try {
      final user = await _authService.signInWithEmailPassword(
        _emailController.text,
        _passwordController.text,
      );
      if (mounted) {
        Navigator.pop(context); // Close loading
        if (user != null) {
          if (user.isNewUser) {
            context.go('/auth/security-setup', extra: false);
          } else {
            // Save 'remember me' preference for splash auto-login
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('remember_me', _rememberMe);
            context.go('/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showError(
          context,
          "Authentication Failed: ${e.toString()}",
        );
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    GlassDialog.showLoading(context, message: 'Connecting to Google...');
    try {
      final user = await _authService.signInWithGoogle();
      if (mounted) {
        Navigator.pop(context); // Close loading
        if (user != null) {
          if (user.isNewUser) {
            context.go('/auth/security-setup', extra: {
              'isSocial': true,
              'email': user.email,
              'name': user.name,
              'isNewUser': true,
            });
          } else {
            context.go('/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showError(
          context,
          "Google Sign-In failed. Please try again.",
        );
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    GlassDialog.showLoading(context, message: 'Connecting to Apple...');
    try {
      final user = await _authService.signInWithApple();
      if (mounted) {
        Navigator.pop(context); // Close loading
        if (user != null) {
          if (user.isNewUser) {
            context.go('/auth/security-setup', extra: {
              'isSocial': true,
              'email': user.email,
              'name': user.name,
              'isNewUser': true,
            });
          } else {
            context.go('/dashboard');
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showError(
          context,
          "Apple Sign-In failed. Please try again.",
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSavedPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartBiometricLogin();
    });
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _rememberMe = prefs.getBool('remember_me') ?? false;
      });
    }
  }

  Future<void> _checkAndStartBiometricLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isBiometricEnabled =
        prefs.getBool('biometrics_enabled') ?? false;

    if (isBiometricEnabled) {
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _auth.isDeviceSupported();

      if (canAuthenticate) {
        try {
          final bool didAuthenticate = await _auth.authenticate(
            localizedReason: 'Authenticate to access your NeRuWallet',
            options: const AuthenticationOptions(
              stickyAuth: true,
              biometricOnly: true,
            ),
          );

          if (didAuthenticate && mounted) {
            context.go('/dashboard');
          }
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppTheme.surfaceDark : Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
              ).animate().fadeIn().slideX(begin: -0.5, end: 0),
              const SizedBox(height: 32),
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
              // Card for Login Fields
              Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.surfaceDark.withValues(alpha: 0.6)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: AppTheme.radiusLarge,
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.05,
                          ),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Email
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: "Email address",
                            hintText: "example@domain.com",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Password
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            hintText: "••••••••",
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        // Row: Remember Me (left) + Forgot Password (right)
                        Row(
                          children: [
                            // Remember Me checkbox
                            Transform.scale(
                              scale: 0.9,
                              child: Checkbox(
                                value: _rememberMe,
                                activeColor: AppTheme.primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                onChanged: (val) => setState(() => _rememberMe = val ?? false),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _rememberMe = !_rememberMe),
                              child: Text(
                                "Remember me",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
                                ),
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () => context.push('/auth/forgot-password'),
                              child: Text(
                                "Forgot password?",
                                style: TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 64),
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.radiusMedium,
                            ),
                          ),
                          child: const Text("Sign In"),
                        ),
                        if (_emailController
                            .text
                            .isEmpty) // Just a placeholder check if we should show biometric icon explicitly
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.fingerprint,
                                size: 40,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: _checkAndStartBiometricLogin,
                            ),
                          ),
                      ],
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms)
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1, 1),
                    curve: Curves.easeOutBack,
                  ),
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
                      icon: "https://www.svgrepo.com/show/475656/google-color.svg",
                      label: "Google",
                      onPressed: _handleGoogleLogin,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSocialButton(
                      icon: "https://www.svgrepo.com/show/303108/apple-black-logo.svg",
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
                  Text(
                    "New to NeRuWallet?",
                    style: TextStyle(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/auth/signup'),
                    child: const Text(
                      "Create Account",
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 1000.ms),
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
