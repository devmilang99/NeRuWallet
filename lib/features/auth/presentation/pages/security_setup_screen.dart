import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/auth/presentation/pages/transaction_pin_screen.dart';

class SecuritySetupScreen extends StatefulWidget {
  final Map<String, dynamic>? signupData;
  final bool isSocialLogin;

  const SecuritySetupScreen({
    super.key,
    this.isSocialLogin = false,
    this.signupData,
  });

  @override
  State<SecuritySetupScreen> createState() => _SecuritySetupScreenState();
}

class _SecuritySetupScreenState extends State<SecuritySetupScreen> {
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
    "What was the name of your first pet?",
    "What is the name of the city where you were born?",
    "What was your favorite school teacher's name?",
    "What was your first car?",
  ];

  Future<void> _handleRegister() async {
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
      _securityAnswerError = null;
      _securityQuestionError = null;
    });

    bool hasError = false;

    final password = _passwordController.text;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasNum = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (password.length < 8) {
      setState(
        () => _passwordError = "Password must be at least 8 characters.",
      );
      hasError = true;
    } else if (!hasUpper) {
      setState(() => _passwordError = "Add at least one capital letter.");
      hasError = true;
    } else if (!hasNum) {
      setState(() => _passwordError = "Add at least one number.");
      hasError = true;
    } else if (!hasSpecial) {
      setState(() => _passwordError = "Add at least one special character.");
      hasError = true;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _confirmPasswordError = "Passwords do not match.");
      hasError = true;
    }
    if (_selectedQuestion == null) {
      setState(
        () => _securityQuestionError = "Please select a security question.",
      );
      hasError = true;
    }
    if (_securityAnswerController.text.isEmpty) {
      setState(() => _securityAnswerError = "Please provide an answer.");
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
    final Map<String, dynamic> combinedSignupData = {
      ...widget.signupData ?? {},
      'password': _passwordController.text,
      'security_question': _selectedQuestion!,
      'security_answer': _securityAnswerController.text.trim(),
    };

    if (mounted) {
      context.push(
        '/auth/pin-setup',
        extra: {'mode': PinMode.set, 'signupData': combinedSignupData},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textBodyDark : AppTheme.textBodyColor;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Login Password",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Text(
                    "Set a password to secure your account login.",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0),
              const SizedBox(height: 40),
              _buildPasswordStep(isDark),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStep(bool isDark) {
    final titleColor = isDark ? AppTheme.textBodyDark : AppTheme.textBodyColor;

    return Column(
          children: [
            // Password Requirements Checklist
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                children: [
                  _buildRequirementRow(
                    "At least 8 characters",
                    _passwordController.text.length >= 8,
                  ),
                  const SizedBox(height: 6),
                  _buildRequirementRow(
                    "At least one capital letter",
                    _passwordController.text.contains(RegExp(r'[A-Z]')),
                  ),
                  const SizedBox(height: 6),
                  _buildRequirementRow(
                    "At least one number",
                    _passwordController.text.contains(RegExp(r'[0-9]')),
                  ),
                  const SizedBox(height: 6),
                  _buildRequirementRow(
                    "At least one special character",
                    _passwordController.text.contains(
                      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) {
                setState(() {
                  if (_passwordError != null) _passwordError = null;
                });
              },
              decoration: InputDecoration(
                labelText: "Password",
                errorText: _passwordError,
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              onChanged: (_) {
                if (_confirmPasswordError != null) {
                  setState(() => _confirmPasswordError = null);
                }
              },
              decoration: InputDecoration(
                labelText: "Confirm Password",
                errorText: _confirmPasswordError,
                prefixIcon: const Icon(Icons.lock_clock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            _buildSectionHeader(
              "Security Question",
              "Used for account recovery",
              titleColor,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedQuestion,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: "Select Question",
                errorText: _securityQuestionError,
                prefixIcon: const Icon(Icons.help_outline),
              ),
              items: _securityQuestions
                  .map(
                    (q) => DropdownMenuItem(
                      value: q,
                      child: Text(
                        q,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
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
            TextField(
              controller: _securityAnswerController,
              onChanged: (_) {
                if (_securityAnswerError != null) {
                  setState(() => _securityAnswerError = null);
                }
              },
              decoration: InputDecoration(
                labelText: "Answer",
                errorText: _securityAnswerError,
                prefixIcon: const Icon(Icons.question_answer_outlined),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _handleRegister,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(
                  borderRadius: AppTheme.radiusMedium,
                ),
              ),
              child: const Text("Next"),
            ),
          ],
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
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
