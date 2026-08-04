import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';

class SecuritySetupScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? signupData;
  final bool isSocialLogin;

  const SecuritySetupScreen({
    super.key,
    this.isSocialLogin = false,
    this.signupData,
  });

  @override
  ConsumerState<SecuritySetupScreen> createState() =>
      _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends ConsumerState<SecuritySetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  String? _selectedQuestion;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation states
  String? _passwordError;
  String? _confirmPasswordError;
  String? _securityAnswerError;
  String? _securityQuestionError;

  final List<String> _securityQuestions = [
    "What is your mother's maiden name?",
    'What was the name of your first pet?',
    'What is the name of the city where you were born?',
    "What was your favorite school teacher's name?",
    'What was your first car?',
  ];

  Future<void> _handleRegister() async {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      _securityAnswerError = null;
      _securityQuestionError = null;
    });

    var hasError = false;

    final password = _passwordController.text;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNum = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.length < 8) {
      setState(
        () => _passwordError = 'Password must be at least 8 characters.',
      );
      hasError = true;
    } else if (!hasUpper) {
      setState(() => _passwordError = 'Add at least one capital letter.');
      hasError = true;
    } else if (!hasNum) {
      setState(() => _passwordError = 'Add at least one number.');
      hasError = true;
    } else if (!hasSpecial) {
      setState(() => _passwordError = 'Add at least one special character.');
      hasError = true;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = 'Passwords do not match.');
      hasError = true;
    }
    if (_selectedQuestion == null) {
      setState(
        () => _securityQuestionError = 'Please select a security question.',
      );
      hasError = true;
    }
    if (_securityAnswerController.text.isEmpty) {
      setState(() => _securityAnswerError = 'Please provide an answer.');
      hasError = true;
    }

    if (hasError) {
      setState(() {
        _obscurePassword = false;
        _obscureConfirmPassword = false;
      });
      return;
    }

    // Now go to PIN setup and pass our accumulated data
    final combinedSignupData = <String, dynamic>{
      ...widget.signupData ?? {},
      'password': _passwordController.text,
      'security_question': _selectedQuestion!,
      'security_answer': _securityAnswerController.text.trim(),
      'isSocial': widget.isSocialLogin,
    };

    if (mounted) {
      context.push(
        '/auth/pin-setup',
        extra: {
          'mode': PinMode.set,
          'signupData': combinedSignupData,
          'isNewUser': true, // Social or not, it's a new setup
        },
      );
    }
  }

  Future<void> _handleBackActions() async {
    final isNewSocial =
        widget.isSocialLogin && (widget.signupData?['isNewUser'] ?? false);

    if (isNewSocial) {
      if (!mounted) return;
      GlassDialog.showConfirm(
        context,
        title: 'Cancel Registration?',
        message:
            'Your account connection is incomplete. If you leave now, your registration will be cancelled.',
        confirmText: 'Yes, Cancel',
        cancelText: 'Stay here',
        isDestructive: true,
        onConfirm: () async {
          // Add a loading indicator while deleting the account
          GlassDialog.showLoading(
            context,
            message: 'Cancelling registration...',
          );
          try {
            await ref.read(authServiceProvider).deleteAccount();
          } catch (e) {
            AppLogger.e('Error during account cleanup', e);
          }
          if (mounted) {
            // Close loading and go back to login
            Navigator.pop(context);
            context.go('/auth/login');
          }
        },
      );
    } else {
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
      child: DecoratedBox(
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
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.security_rounded,
                            size: 48,
                            color: AppTheme.primaryColor,
                          ),
                        ).animate().scale(
                          duration: 600.ms,
                          curve: Curves.easeOutBack,
                        ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                        'Security Setup',
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                      )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 12),
                  Text(
                    'Protect your account by setting up a secure password and recovery question.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                      height: 1.5,
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 40),
                  _buildPasswordStep(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceDark.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.6),
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              _buildSectionHeader(
                'Login Password',
                'Set a strong password',
                isDark ? Colors.white : AppTheme.textBodyColor,
              ),
              const SizedBox(height: 24),
              // Password Requirements Checklist
              _buildRequirementsList(),
              const SizedBox(height: 24),
              _buildInputField(
                controller: _passwordController,
                label: 'Password',
                errorText: _passwordError,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                onChanged: (val) {
                  setState(() {
                    if (_passwordError != null) _passwordError = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _confirmPasswordController,
                label: 'Confirm Password',
                errorText: _confirmPasswordError,
                obscureText: _obscureConfirmPassword,
                prefixIcon: Icons.lock_clock_outlined,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    size: 20,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    if (_confirmPasswordError != null) {
                      _confirmPasswordError = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 32),
              _buildSectionHeader(
                'Security Question',
                'Used for account recovery',
                isDark ? Colors.white : AppTheme.textBodyColor,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _selectedQuestion,
                isExpanded: true,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Select Question',
                  errorText: _securityQuestionError,
                  prefixIcon: const Icon(Icons.help_outline, size: 22),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.02),
                ),
                items: _securityQuestions
                    .map(
                      (q) => DropdownMenuItem(
                        value: q,
                        child: Text(q, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedQuestion = val;
                    _securityQuestionError = null;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildInputField(
                controller: _securityAnswerController,
                label: 'Your Answer',
                errorText: _securityAnswerError,
                prefixIcon: Icons.question_answer_outlined,
                onChanged: (val) {
                  if (_securityAnswerError != null) {
                    setState(() => _securityAnswerError = null);
                  }
                },
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _handleRegister,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppTheme.radiusMedium,
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Next Step',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }

  Widget _buildRequirementsList() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildRequirementRow(
            'At least 8 characters',
            _passwordController.text.length >= 8,
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'One capital letter',
            _passwordController.text.contains(RegExp(r'[A-Z]')),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'One number',
            _passwordController.text.contains(RegExp(r'[0-9]')),
          ),
          const SizedBox(height: 8),
          _buildRequirementRow(
            'One special character',
            _passwordController.text.contains(
              RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    String? errorText,
    bool obscureText = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            prefixIcon: Icon(prefixIcon, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : Colors.black.withValues(alpha: 0.02),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Row(
      children: [
        Icon(
              isMet
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isMet
                  ? AppTheme.successColor
                  : Colors.grey.withValues(alpha: 0.5),
            )
            .animate(target: isMet ? 1 : 0)
            .scale(duration: 200.ms)
            .tint(color: AppTheme.successColor),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? AppTheme.successColor : Colors.grey,
            fontWeight: isMet ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
