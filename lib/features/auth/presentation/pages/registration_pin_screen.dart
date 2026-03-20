import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

class RegistrationPinScreen extends StatefulWidget {
  final Map<String, dynamic> signupData;

  const RegistrationPinScreen({
    super.key, 
    required this.signupData,
  });

  @override
  State<RegistrationPinScreen> createState() => _RegistrationPinScreenState();
}

class _RegistrationPinScreenState extends State<RegistrationPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  int _step = 1; // 1: New PIN, 2: Confirm PIN
  bool _showMismatchError = false;
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
    final prefs = await SharedPreferences.getInstance();
    
    if (_step == 1) {
      if (_pinController.text.length != 4) {
        if (mounted) {
          GlassDialog.showError(context, "PIN must be 4 digits.");
        }
        return;
      }
      setState(() => _step = 2);
      _confirmPinFocusNode.requestFocus();
      return;
    }

    if (_step == 2) {
      if (_pinController.text != _confirmPinController.text) {
        setState(() {
          _showMismatchError = true;
        });
        _confirmPinFocusNode.requestFocus();
        return;
      }

      if (!mounted) return;
      GlassDialog.showLoading(context, message: 'Creating Account...');
      try {
        // Save PIN first
        await prefs.setString('transaction_pin', _pinController.text);
        
        final data = widget.signupData;
        await _authService.signUpWithEmailPassword(
          data['email'], 
          data['password'], 
          data['name'],
        );
        
        // Also save security data
        if (data.containsKey('security_question')) {
          await prefs.setString('security_question', data['security_question']);
          await prefs.setString('security_answer', data['security_answer']);
        }
        if (data.containsKey('password')) {
          await prefs.setString('app_password', data['password']);
        }

        if (mounted) {
          Navigator.pop(context); // Close loading
          GlassDialog.showSuccess(
            context, 
            "Registration successful! Please login to your account.",
            onConfirm: () => context.go('/auth/login'),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          GlassDialog.showError(context, "Registration failed: ${e.toString()}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Transaction PIN"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.lock_person_rounded, size: 80, color: AppTheme.primaryColor)
                  .animate().scale(delay: 200.ms),
              const SizedBox(height: 32),
              Text(
                "Create a 4-digit PIN for your wallet transactions",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              
              _buildOtpSection(
                controller: _pinController,
                focusNode: _pinFocusNode,
                label: "Create PIN",
                isDark: isDark,
                onComplete: () {
                  setState(() => _step = 2);
                  _confirmPinFocusNode.requestFocus();
                },
                enabled: _step == 1,
              ),
              if (_step == 2) ...[
                const SizedBox(height: 40),
                _buildOtpSection(
                  controller: _confirmPinController,
                  focusNode: _confirmPinFocusNode,
                  label: "Confirm PIN",
                  isDark: isDark,
                  onComplete: _handleComplete,
                ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                if (_showMismatchError)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: const Text(
                      "PINs do not match. Please try again.",
                      style: TextStyle(color: AppTheme.errorColor, fontSize: 13, fontWeight: FontWeight.bold),
                    ).animate().shake(),
                  ),
              ],
              
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _handleComplete,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 64),
                  shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
                ),
                child: Text(_step == 2 ? "Finish Registration" : "Next"),
              ).animate().fadeIn(delay: 600.ms),
            ],
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
              ...List.generate(4, (index) => _buildOtpBox(index, controller, isDark, enabled)),
            ],
          ),
          SizedBox(
            height: 0,
            width: 0,
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
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index, TextEditingController controller, bool isDark, bool enabled) {
    String char = "";
    if (controller.text.length > index) {
      char = controller.text[index];
    }

    bool isFocused = enabled && controller.text.length == index;
    bool isWrong = false;
    if (_showMismatchError && controller == _confirmPinController) {
      if (index < controller.text.length && index < _pinController.text.length) {
        isWrong = controller.text[index] != _pinController.text[index];
      } else if (index < controller.text.length) {
        isWrong = true;
      }
    }

    return Container(
      width: 60,
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWrong
              ? AppTheme.errorColor
              : (isFocused 
                  ? AppTheme.primaryColor 
                  : (isDark ? Colors.white10 : Colors.black12)),
          width: 2,
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: (isWrong ? AppTheme.errorColor : AppTheme.primaryColor).withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          )
        ] : [],
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isWrong ? AppTheme.errorColor : (isDark ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }
}
