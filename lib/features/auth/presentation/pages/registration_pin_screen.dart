import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

class RegistrationPinScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> signupData;

  const RegistrationPinScreen({super.key, required this.signupData});

  @override
  ConsumerState<RegistrationPinScreen> createState() =>
      _RegistrationPinScreenState();
}

class _RegistrationPinScreenState extends ConsumerState<RegistrationPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  int _step = 1; // 1: New PIN, 2: Confirm PIN
  bool _showMismatchError = false;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final prefService = ref.read(preferenceServiceProvider);

    if (_step == 1) {
      if (_pinController.text.length != 4) {
        if (mounted) {
          GlassDialog.showError(context, "PIN must be 4 digits.");
        }
        return;
      }
      setState(() => _step = 2);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _confirmPinFocusNode.requestFocus();
      });
      return;
    }

    if (_step == 2) {
      if (_pinController.text != _confirmPinController.text) {
        setState(() {
          _showMismatchError = true;
          _confirmPinController.clear();
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confirmPinFocusNode.requestFocus();
        });
        return;
      }

      if (_isLoading) return;
      setState(() => _isLoading = true);

      if (!mounted) return;
      GlassDialog.showLoading(context, message: 'Creating Account...');
      try {
        // Save PIN first with AES encryption
        await prefService.setString(
          'transaction_pin',
          _pinController.text,
          encrypted: true,
        );

        final data = widget.signupData;
        final bool isSocial = data['isSocial'] ?? false;

        if (!isSocial) {
          await _authService.signUpWithEmailPassword(
            data['email'],
            data['password'],
            data['name'],
          );
        }

        // Also save security data
        if (data.containsKey('security_question')) {
          await prefService.setString(
            'security_question',
            data['security_question'],
          );
          await prefService.setString(
            'security_answer',
            data['security_answer'],
            encrypted: true,
          );
        }
        if (data.containsKey('password')) {
          await prefService.setString(
            'app_password',
            data['password'],
            encrypted: true,
          );
        }

        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context); // Close loading
          GlassDialog.showSuccess(
            context,
            isSocial
                ? "Account setup completed successfully!"
                : "Registration successful! Please login to your account.",
            onConfirm: () =>
                isSocial ? context.go('/dashboard') : context.go('/auth/login'),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context); // Close loading

          String errorMessage = "Registration failed. Please try again.";

          if (e.toString().contains("over_email_send_rate_limit")) {
            errorMessage =
                "Too many attempts. Please wait a few minutes before trying again or use a different email.";
          } else if (e.toString().contains("User already registered")) {
            errorMessage = "This email is already registered. Please login.";
          }

          GlassDialog.showError(
            context,
            errorMessage,
            onRetry: () {
              if (mounted) context.go('/auth/login');
            },
          );
        }
      }
    }
  }

  Future<void> _handleBackActions() async {
    if (_step == 2) {
      setState(() {
        _step = 1;
        _confirmPinController.clear();
        _showMismatchError = false;
      });
      _pinFocusNode.requestFocus();
    } else {
      final isNewSocial =
          (widget.signupData['isSocial'] ?? false) &&
          (widget.signupData['isNewUser'] ?? false);
      if (isNewSocial) {
        await _authService.deleteAccount();
      }
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackActions();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? AppTheme.darkGradient
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.backgroundColor, Colors.white],
                ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              "Security Setup",
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: IconButton(
              onPressed: _handleBackActions,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 20,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ).animate().scale(
                    duration: 600.ms,
                    curve: Curves.easeOutBack,
                  ),
                  const SizedBox(height: 32),
                  Text(
                        _step == 1
                            ? "Create Transaction PIN"
                            : "Confirm Your PIN",
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    _step == 1
                        ? "Set a 4-digit PIN for secure wallet transactions."
                        : "Please re-enter your PIN to confirm.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 60),

                  if (_step == 1)
                    _buildOtpSection(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      label: "Enter 4-digit PIN",
                      isDark: isDark,
                      onComplete: () {
                        setState(() => _step = 2);
                        _confirmPinFocusNode.requestFocus();
                      },
                      enabled: true,
                    ).animate().fadeIn().slideX(begin: -0.1, end: 0)
                  else
                    _buildOtpSection(
                      controller: _confirmPinController,
                      focusNode: _confirmPinFocusNode,
                      label: "Re-enter PIN",
                      isDark: isDark,
                      onComplete: _handleComplete,
                    ).animate().fadeIn().slideX(begin: 0.1, end: 0),

                  if (_showMismatchError)
                    Padding(
                      padding: const EdgeInsets.only(top: 24.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppTheme.errorColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "PINs do not match. Try again.",
                              style: TextStyle(
                                color: AppTheme.errorColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ).animate().shake().fadeIn(),
                    ),

                  const SizedBox(height: 80),
                  ElevatedButton(
                    onPressed: _handleComplete,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppTheme.radiusLarge,
                      ),
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                    ),
                    child: Text(
                      _step == 2 ? "Finish Setup" : "Continue",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpSection({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isDark,
    required VoidCallback onComplete,
    bool enabled = true,
  }) {
    return GestureDetector(
      onTap: () {
        if (enabled) {
          focusNode.requestFocus();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                4,
                (index) => _buildOtpBox(index, controller, isDark, enabled),
              ),
            ],
          ),
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              width: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: enabled,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (val) {
                  if (_showMismatchError) {
                    setState(() => _showMismatchError = false);
                  } else {
                    setState(() {});
                  }
                  if (val.length == 4) {
                    onComplete();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpBox(
    int index,
    TextEditingController controller,
    bool isDark,
    bool enabled,
  ) {
    String char = "";
    if (controller.text.length > index) {
      char = controller.text[index];
    }

    bool isFocused = enabled && controller.text.length == index;
    bool isWrong = false;
    if (_showMismatchError && controller == _confirmPinController) {
      if (index < controller.text.length &&
          index < _pinController.text.length) {
        isWrong = controller.text[index] != _pinController.text[index];
      } else if (index < controller.text.length) {
        isWrong = true;
      }
    }

    return Container(
      width: 65,
      height: 70,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWrong
              ? AppTheme.errorColor
              : (isFocused
                    ? AppTheme.primaryColor
                    : (isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.05))),
          width: 2,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          char.isNotEmpty ? "•" : "", // Use dots for PIN security
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isWrong
                ? AppTheme.errorColor
                : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
