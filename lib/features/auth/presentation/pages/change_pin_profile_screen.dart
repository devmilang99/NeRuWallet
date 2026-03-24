import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChangePinProfileScreen extends StatefulWidget {
  const ChangePinProfileScreen({super.key});

  @override
  State<ChangePinProfileScreen> createState() => _ChangePinProfileScreenState();
}

class _ChangePinProfileScreenState extends State<ChangePinProfileScreen> {
  final _oldPinController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  int _step = 0; // 0: Old PIN, 1: New PIN, 2: Confirm PIN
  bool _showMismatchError = false;

  final _oldPinFocusNode = FocusNode();
  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _step = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _oldPinFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _oldPinFocusNode.dispose();
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_step == 0) {
      final savedPin = prefs.getString('transaction_pin');
      if (_oldPinController.text != savedPin) {
        if (mounted) {
          GlassDialog.showError(context, "Old PIN is incorrect.");
        }
        _oldPinController.clear();
        _oldPinFocusNode.requestFocus();
        return;
      }
      setState(() => _step = 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pinFocusNode.requestFocus();
      });
      return;
    }

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
        });
        _confirmPinFocusNode.requestFocus();
        return;
      }

      if (!mounted) return;
      GlassDialog.showLoading(context, message: 'Updating PIN...');
      
      try {
        await prefs.setString('transaction_pin', _pinController.text);
        
        if (mounted) {
          Navigator.pop(context); // Close loading
          GlassDialog.showSuccess(
            context, 
            "Transaction PIN updated successfully!",
            onConfirm: () => context.go('/dashboard'),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context); // Close loading
          GlassDialog.showError(context, "Update failed: ${e.toString()}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Change PIN"),
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
              const Icon(Icons.lock_reset_rounded, size: 80, color: AppTheme.primaryColor)
                  .animate().scale(delay: 200.ms),
              const SizedBox(height: 32),
              Text(
                _step == 0 
                  ? "Verify your current identity to update your PIN" 
                  : "Choose a new 4-digit PIN for your transactions",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              
              if (_step == 0)
                _buildOtpSection(
                  controller: _oldPinController,
                  focusNode: _oldPinFocusNode,
                  label: "Old PIN",
                  isDark: isDark,
                  onComplete: _handleComplete,
                )
              else ...[
                _buildOtpSection(
                  controller: _pinController,
                  focusNode: _pinFocusNode,
                  label: "New PIN",
                  isDark: isDark,
                  onComplete: () {
                    setState(() => _step = 2);
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _confirmPinFocusNode.requestFocus();
                    });
                  },
                  enabled: _step == 1,
                  // If user clicks the first PIN field while on confirm step,
                  // bring them back to the first step.
                  onTap: _step == 2 
                    ? () => setState(() {
                        _step = 1;
                        _pinFocusNode.requestFocus();
                      }) 
                    : null,
                ),
                if (_step == 2) ...[
                  const SizedBox(height: 40),
                  _buildOtpSection(
                    controller: _confirmPinController,
                    focusNode: _confirmPinFocusNode,
                    label: "Confirm New PIN",
                    isDark: isDark,
                    onComplete: _handleComplete,
                    isConfirm: true,
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
              ],
              
              const SizedBox(height: 48),
              // Manual button removed - auto-submits on 4th digit
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
    bool isConfirm = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (enabled || isConfirm) {
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
              ...List.generate(4, (index) => _buildOtpBox(index, controller, isDark, enabled || isConfirm)),
            ],
          ),
          IgnorePointer(
            child: Opacity(
              opacity: 0,
              child: SizedBox(
                height: 1,
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  autofocus: false,
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
      width: 60, height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWrong
              ? AppTheme.errorColor
              : (isFocused ? AppTheme.primaryColor : (isDark ? Colors.white10 : Colors.black12)),
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
