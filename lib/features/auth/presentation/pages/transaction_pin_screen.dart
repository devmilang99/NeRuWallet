import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';

enum PinMode { set, change, verify, reset }

class TransactionPinScreen extends StatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;
  final Map<String, dynamic>? signupData;

  const TransactionPinScreen({
    super.key,
    required this.mode,
    this.onSuccess,
    this.signupData,
  });

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final AuthService _authService = AuthService();
  final LocalAuthentication _auth = LocalAuthentication();

  int _step = 1; // 1: PIN entry, 2: Confirmation (if setup/reset)
  bool _showMismatchError = false;

  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _step = 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _pinFocusNode.requestFocus();
        if (widget.mode == PinMode.verify) {
          _checkBiometricForVerification();
        }
      }
    });
  }

  @override
  void dispose() {
    _pinFocusNode.dispose();
    _confirmPinFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    if (_step == 1) {
      if (_pinController.text.length != 4) {
        if (mounted) {
          GlassDialog.showError(context, "PIN must be 4 digits.");
        }
        return;
      }

      if (widget.mode == PinMode.verify) {
        await _handleTransactionVerification();
      } else {
        setState(() => _step = 2);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _confirmPinFocusNode.requestFocus();
        });
      }
      return;
    }

    if (_step == 2) {
      if (_pinController.text != _confirmPinController.text) {
        setState(() {
          _showMismatchError = true;
          _confirmPinController.clear();
        });
        _confirmPinFocusNode.requestFocus();
        return;
      }

      switch (widget.mode) {
        case PinMode.set:
          await _handleNewUserPinSetup();
          break;
        case PinMode.change:
        case PinMode.reset:
          await _handleChangePin();
          break;
        case PinMode.verify:
          await _handleTransactionVerification();
          break;
      }
    }
  }

  Future<void> _handleNewUserPinSetup() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    GlassDialog.showLoading(context, message: 'Completing your setup...');
    try {
      await prefs.setString('transaction_pin', _pinController.text);

      if (widget.signupData != null) {
        final data = widget.signupData!;
        final bool isSocial = data['isSocial'] ?? false;

        if (!isSocial) {
          await _authService.signUpWithEmailPassword(
            data['email'],
            data['password'],
            data['name'],
          );
        }

        if (data.containsKey('security_question')) {
          await prefs.setString('security_question', data['security_question']);
          await prefs.setString('security_answer', data['security_answer']);
        }

        if (data.containsKey('password')) {
          await prefs.setString('app_password', data['password']);
        }
      }

      if (mounted) {
        Navigator.pop(context); // Close loading
        String message = widget.signupData?['isSocial'] == true
            ? "Account setup successfully! Welcome to NeRuWallet."
            : "Registration successful!";

        GlassDialog.showSuccess(
          context,
          message,
          onConfirm: () => context.go('/dashboard'),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showError(context, "Setup failed: ${e.toString()}");
      }
    }
  }

  Future<void> _checkBiometricForVerification() async {
    if (widget.mode != PinMode.verify) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isEnabled = prefs.getBool('biometrics_transaction_enabled') ?? false;

    if (!isEnabled) {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();
      
      if (mounted && (canCheck || isSupported)) {
        GlassDialog.showConfirm(
          context,
          title: 'Enable Biometrics',
          message: 'Biometric authentication is available on your device. Would you like to enable it for faster transactions?',
          confirmText: 'Go to Settings',
          onConfirm: () => context.push('/profile/biometric-settings'),
        );
      }
      return;
    }

    try {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Confirm this transaction',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated && mounted) {
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        } else {
          context.go('/dashboard');
        }
      }
    } catch (e) {
      debugPrint("Biometric auth failed: $e");
    }
  }

  Future<void> _handleChangePin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    GlassDialog.showLoading(context, message: 'Updating PIN...');
    try {
      await prefs.setString('transaction_pin', _pinController.text);

      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showSuccess(
          context,
          "Transaction PIN updated successfully!",
          onConfirm: () => context.go('/dashboard'),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showError(context, "Update failed: ${e.toString()}");
      }
    }
  }

  Future<void> _handleTransactionVerification() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('transaction_pin');

    if (_pinController.text == savedPin) {
      if (!mounted) return;
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        context.go('/dashboard');
      }
    } else {
      if (mounted) {
        GlassDialog.showError(context, "Incorrect PIN. Please try again.");
      }
      _pinController.clear();
      _pinFocusNode.requestFocus();
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
      return;
    }

    final isNewSocial = widget.mode == PinMode.set && (widget.signupData?['isSocial'] ?? false);

    if (isNewSocial) {
      if (!mounted) return;
      GlassDialog.showConfirm(
        context,
        title: "Cancel Registration?",
        message: "Your account connection is incomplete. If you leave now, your registration will be cancelled.",
        confirmText: "Yes, Cancel",
        cancelText: "Stay here",
        isDestructive: true,
        onConfirm: () async {
          GlassDialog.showLoading(context, message: "Cancelling registration...");
          try {
            await _authService.deleteAccount();
          } catch (e) {
            debugPrint("Error: $e");
          }
          if (mounted) {
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
    String title = widget.mode == PinMode.verify ? "Enter PIN" : "Setup PIN";
    String subtitle = widget.mode == PinMode.verify
        ? "Authorize this transaction"
        : "Create a 4-digit PIN for security";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackActions();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.shield_rounded,
                  size: 80,
                  color: AppTheme.primaryColor,
                ).animate().scale(delay: 200.ms),
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
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _confirmPinFocusNode.requestFocus();
                      });
                    }
                  },
                  enabled: _step == 1,
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
                    label: "Confirm PIN",
                    isDark: isDark,
                    onComplete: _handleComplete,
                    isConfirm: true,
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  if (_showMismatchError)
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: const Text(
                        "PINs do not match",
                        style: TextStyle(
                          color: AppTheme.errorColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().shake(),
                    ),
                ],
                const SizedBox(height: 48),
                if (widget.mode == PinMode.verify)
                  TextButton(
                    onPressed: () => context.push('/auth/pin-setup', extra: {'mode': PinMode.reset}),
                    child: const Text("Forgot PIN?"),
                  ),
                if (widget.mode == PinMode.verify)
                  FutureBuilder<bool>(
                    future: SharedPreferences.getInstance().then((p) => p.getBool('biometrics_transaction_enabled') ?? false),
                    builder: (context, snapshot) {
                      if (snapshot.data == true) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: IconButton(
                            icon: const Icon(
                              Icons.fingerprint_rounded,
                              size: 48,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: _checkBiometricForVerification,
                          ),
                        ).animate().fadeIn(delay: 600.ms).scale();
                      }
                      return const SizedBox.shrink();
                    },
                  ),
              ],
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
    bool isConfirm = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          focusNode.unfocus();
          Future.delayed(const Duration(milliseconds: 50), () {
            if (mounted) focusNode.requestFocus();
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildOtpBox(index, controller, isDark, enabled || isConfirm)),
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
    if (controller.text.length > index) char = controller.text[index];
    bool isFocused = enabled && controller.text.length == index;
    bool isWrong = _showMismatchError && controller == _confirmPinController;
    
    return Container(
      width: 60,
      height: 60,
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
