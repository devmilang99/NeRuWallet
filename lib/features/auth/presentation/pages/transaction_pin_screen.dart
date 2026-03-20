import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PinMode { set, change, verify, reset }

class TransactionPinScreen extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;

  const TransactionPinScreen({
    super.key, 
    required this.mode, 
    this.onSuccess,
  });

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  
  int _step = 1; // 1: PIN entry, 2: Confirmation (if setup/reset)
  bool _showMismatchError = false;

  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _step = 1;
  }

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (widget.mode == PinMode.verify) {
      final savedPin = prefs.getString('transaction_pin');
      if (_pinController.text == savedPin) {
        if (!mounted) return;
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          // If no success callback, just go home or back
          if (context.canPop()) {
            context.pop(true);
          } else {
            context.go('/dashboard');
          }
        }
      } else {
        if (mounted) {
          GlassDialog.showError(context, "Incorrect PIN. Please try again.");
        }
        _pinController.clear();
        _pinFocusNode.requestFocus();
      }
      return;
    }

    // Handle generic set/reset (Setup that isn't registration)
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
      GlassDialog.showLoading(context, message: 'Saving PIN...');
      try {
        await prefs.setString('transaction_pin', _pinController.text);
        if (mounted) {
          Navigator.pop(context);
          GlassDialog.showSuccess(
            context, 
            "Transaction PIN ${widget.mode == PinMode.set ? 'set' : 'updated'} successfully!",
            onConfirm: () => context.go('/dashboard'),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          GlassDialog.showError(context, "Failed to save: ${e.toString()}");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String title = widget.mode == PinMode.verify ? "Enter PIN" : "Setup PIN";
    String subtitle = widget.mode == PinMode.verify 
        ? "Authorize this transaction" 
        : "Create a 4-digit PIN for security";

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
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
              const Icon(Icons.shield_rounded, size: 80, color: AppTheme.primaryColor)
                  .animate().scale(delay: 200.ms),
              const SizedBox(height: 32),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 48),
              
              _buildOtpSection(
                controller: _pinController,
                focusNode: _pinFocusNode,
                label: widget.mode == PinMode.verify ? "Enter PIN" : "New PIN",
                isDark: isDark,
                onComplete: () {
                   if (widget.mode == PinMode.verify) {
                     _handleComplete();
                   } else {
                     setState(() => _step = 2);
                     _confirmPinFocusNode.requestFocus();
                   }
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
                      "PINs do not match",
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
                child: Text(widget.mode == PinMode.verify || _step == 2 ? "Verify" : "Next"),
              ).animate().fadeIn(delay: 600.ms),
              
              if (widget.mode == PinMode.verify)
                TextButton(
                  onPressed: () => context.push('/auth/pin-setup', extra: {'mode': PinMode.reset}),
                  child: const Text("Forgot PIN?"),
                ),
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
            height: 0, width: 0,
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
      width: 60, height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWrong ? AppTheme.errorColor : (isFocused ? AppTheme.primaryColor : (isDark ? Colors.white10 : Colors.black12)),
          width: 2,
        ),
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
