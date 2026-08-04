import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/encryption_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/secure_signing_service.dart';
import 'package:neruwallet/core/services/sync_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

enum PinMode { set, change, verify, reset }

class TransactionPinScreen extends ConsumerStatefulWidget {
  final PinMode mode;
  final VoidCallback? onSuccess;
  final Map<String, dynamic>? signupData;

  const TransactionPinScreen({
    required this.mode,
    super.key,
    this.onSuccess,
    this.signupData,
  });

  @override
  ConsumerState<TransactionPinScreen> createState() =>
      _TransactionPinScreenState();
}

class _TransactionPinScreenState extends ConsumerState<TransactionPinScreen> {
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _passwordController = TextEditingController();
  final _oldPinController = TextEditingController();

  int _step =
      1; // 0: Verification (Old PIN/Password), 1: PIN entry, 2: Confirmation
  bool _showMismatchError = false;
  bool _obscurePassword = true;
  bool _biometricsAvailable = false;

  final _pinFocusNode = FocusNode();
  final _confirmPinFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _oldPinFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Initialize step based on mode
    if (widget.mode == PinMode.reset || widget.mode == PinMode.change) {
      _step = 0;
    } else {
      _step = 1;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkBiometricAvailability();
        if (_step == 0) {
          if (widget.mode == PinMode.reset) {
            _passwordFocusNode.requestFocus();
          } else {
            _oldPinFocusNode.requestFocus();
          }
        } else {
          _pinFocusNode.requestFocus();
        }

        // Auto-initiate biometric for transaction verification at the beginning
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
    _passwordFocusNode.dispose();
    _oldPinFocusNode.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _passwordController.dispose();
    _oldPinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final prefService = ref.read(preferenceServiceProvider);
    final isEnabled =
        await prefService.getBool('biometrics_transaction_enabled') ?? false;
    final isEnrolled = await BiometricService.isEnrolled();

    if (mounted) {
      setState(() => _biometricsAvailable = isEnabled && isEnrolled);
    }

    // Auto-initiate biometric for transaction verification at the beginning
    if (widget.mode == PinMode.verify && isEnabled && isEnrolled) {
      _checkBiometricForVerification();
    }
  }

  Future<void> _checkBiometricForVerification() async {
    var authenticated = false;

    try {
      if (Platform.isAndroid || Platform.isIOS) {
        final signingService = ref.read(secureSigningServiceProvider);
        final isGenerated = await signingService.isKeyGenerated();

        if (isGenerated) {
          // Use Hardware-backed signing (StrongBox/TEE/SecureEnclave)
          // This will trigger FaceID/TouchID/Fingerprint with Device PIN fallback
          final dataToSign = Uint8List.fromList(
            'verify_transaction_${DateTime.now().millisecondsSinceEpoch}'
                .codeUnits,
          );
          final signature = await signingService.signData(dataToSign);
          authenticated = signature != null;
        }
      }
    } catch (e) {
      AppLogger.e('Hardware signing error', e);
    }

    // Fallback to standard biometric auth if native hardware signing failed/unavailable
    if (!authenticated) {
      try {
        authenticated = await BiometricService.authenticate(
          title: 'Authorize Transaction',
          subtitle: 'Confirm your identity to proceed',
          reason:
              'Please scan your fingerprint or face to authorize this transaction.',
          biometricOnly:
              false, // Allow device credential fallback if supported by plugin
        );
      } catch (e) {
        AppLogger.e('Standard biometric error', e);
      }
    }

    if (authenticated && mounted) {
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        context.go('/dashboard');
      }
    } else if (mounted) {
      // If all biometric/device auth fails or is canceled, ensure App PIN field is focused
      _pinFocusNode.requestFocus();
    }
  }

  Future<void> _handleComplete() async {
    final prefService = ref.read(preferenceServiceProvider);

    if (_step == 0) {
      if (widget.mode == PinMode.reset) {
        final savedPassword = await prefService.getString(
          'app_password',
          encrypted: true,
        );
        if (_passwordController.text != savedPassword) {
          if (mounted) GlassDialog.showError(context, 'Incorrect password.');
          return;
        }
      } else if (widget.mode == PinMode.change) {
        final savedPin = await prefService.getString(
          'transaction_pin',
          encrypted: true,
        );
        if (_oldPinController.text != savedPin) {
          if (mounted) GlassDialog.showError(context, 'Old PIN is incorrect.');
          _oldPinController.clear();
          _oldPinFocusNode.requestFocus();
          return;
        }
      }

      setState(() => _step = 1);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pinFocusNode.requestFocus();
      });
      return;
    }

    if (_step == 1) {
      if (_pinController.text.length != 4) {
        if (mounted) GlassDialog.showError(context, 'PIN must be 4 digits.');
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
    final prefService = ref.read(preferenceServiceProvider);
    if (!mounted) return;

    GlassDialog.showLoading(context, message: 'Completing setup...');
    try {
      final pin = _pinController.text;

      // 1. Prepare all data to be saved locally
      await prefService.setString('transaction_pin', pin, encrypted: true);

      final initialPrefs = <String, String>{
        'transaction_pin': ref.read(encryptionServiceProvider).encrypt(pin),
      };

      if (widget.signupData != null) {
        final data = widget.signupData!;
        final bool isSocial = data['isSocial'] ?? false;

        if (data.containsKey('password')) {
          await prefService.setString(
            'app_password',
            data['password'],
            encrypted: true,
          );
          initialPrefs['app_password'] = ref
              .read(encryptionServiceProvider)
              .encrypt(data['password']);
        }

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
          initialPrefs['security_question'] = data['security_question'];
          initialPrefs['security_answer'] = ref
              .read(encryptionServiceProvider)
              .encrypt(data['security_answer']);
        }

        // 2. Register or Sync based on auth type
        if (!isSocial) {
          // New Email/Password User
          await ref
              .read(authServiceProvider)
              .signUpWithEmailPassword(
                data['email'],
                data['password'],
                data['name'],
                initialPreferences: initialPrefs,
              );
        } else {
          // Social User - Already logged in, just sync preferences
          final user = sb.Supabase.instance.client.auth.currentUser;
          if (user != null) {
            final List<Map<String, dynamic>> prefsToSync = initialPrefs.entries
                .map(
                  (e) => {'user_id': user.id, 'key': e.key, 'value': e.value},
                )
                .toList();

            await sb.Supabase.instance.client
                .from('app_preferences')
                .upsert(prefsToSync, onConflict: 'user_id,key');
          }
        }

        await prefService.setBool('registration_complete', true);
      }

      // 3. Final Sync to ensure everything is matched
      ref.read(syncServiceProvider).performFullSync().catchError((e) {
        AppLogger.e('Final sync failed', e);
      });

      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showSuccess(
          context,
          'Account & Security setup successful!',
          onConfirm: () => context.go('/dashboard'),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        GlassDialog.showError(context, 'Setup failed: ${e.toString()}');
      }
    }
  }

  Future<void> _handleChangePin() async {
    final prefService = ref.read(preferenceServiceProvider);
    if (!mounted) return;

    GlassDialog.showLoading(context, message: 'Updating PIN...');
    try {
      await prefService.setString(
        'transaction_pin',
        _pinController.text,
        encrypted: true,
      );

      // Sync the new PIN to the cloud in background
      ref.read(syncServiceProvider).performFullSync().catchError((e) {
        AppLogger.e('Cloud sync failed', e);
      });

      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showSuccess(
          context,
          'Transaction PIN updated successfully!',
          onConfirm: () => context.go('/dashboard'),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        GlassDialog.showError(context, 'Update failed: ${e.toString()}');
      }
    }
  }

  Future<void> _handleTransactionVerification() async {
    final prefService = ref.read(preferenceServiceProvider);
    final savedPin = await prefService.getString(
      'transaction_pin',
      encrypted: true,
    );

    if (_pinController.text == savedPin) {
      if (!mounted) return;
      if (widget.onSuccess != null) {
        widget.onSuccess!();
      } else {
        context.go('/dashboard');
      }
    } else {
      if (mounted) {
        GlassDialog.showError(context, 'Incorrect PIN. Please try again.');
      }
      _pinController.clear();
      _pinFocusNode.requestFocus();
    }
  }

  Future<void> _handleBackActions() async {
    if (_step == 1 &&
        (widget.mode == PinMode.reset || widget.mode == PinMode.change)) {
      setState(() {
        _step = 0;
        _pinController.clear();
      });
      if (widget.mode == PinMode.reset) {
        _passwordFocusNode.requestFocus();
      } else {
        _oldPinFocusNode.requestFocus();
      }
      return;
    }

    if (_step == 2) {
      setState(() {
        _step = 1;
        _confirmPinController.clear();
        _showMismatchError = false;
      });
      _pinFocusNode.requestFocus();
      return;
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    final title = widget.mode == PinMode.verify
        ? 'Enter PIN'
        : (widget.mode == PinMode.reset ? 'Reset PIN' : 'Transaction PIN');

    String subtitle;
    if (widget.mode == PinMode.verify) {
      subtitle = 'Authorize this transaction';
    } else if (_step == 0) {
      subtitle = widget.mode == PinMode.reset
          ? 'Verify your password to set a new PIN'
          : 'Enter your old PIN to continue';
    } else {
      subtitle = 'Choose a 4-digit PIN for your transactions';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _handleBackActions();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: isDark
              ? AppTheme.backgroundDark
              : AppTheme.backgroundColor,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
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
            bottom: false,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomInset),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Icon(
                    _step == 0
                        ? Icons.lock_person_rounded
                        : Icons.shield_rounded,
                    size: 80,
                    color: AppTheme.primaryColor,
                  ).animate().scale(delay: 200.ms),
                  const SizedBox(height: 32),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryColor,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 48),

                  if (_step == 0) ...[
                    if (widget.mode == PinMode.reset)
                      Column(
                        children: [
                          TextField(
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Login Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            onSubmitted: (_) => _handleComplete(),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: _handleComplete,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 56),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppTheme.radiusMedium,
                              ),
                            ),
                            child: const Text('Verify Password'),
                          ),
                        ],
                      )
                    else
                      _buildOtpSection(
                        controller: _oldPinController,
                        focusNode: _oldPinFocusNode,
                        label: 'Old PIN',
                        isDark: isDark,
                        onComplete: _handleComplete,
                      ),
                  ] else ...[
                    _buildOtpSection(
                      controller: _pinController,
                      focusNode: _pinFocusNode,
                      label: widget.mode == PinMode.verify
                          ? 'Enter PIN'
                          : 'New PIN',
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
                        label: 'Confirm PIN',
                        isDark: isDark,
                        onComplete: _handleComplete,
                        isConfirm: true,
                      ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                      if (_showMismatchError)
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: const Text(
                            'PINs do not match. Please try again.',
                            style: TextStyle(
                              color: AppTheme.errorColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().shake(),
                        ),
                    ],
                  ],
                  const SizedBox(height: 48),
                  if (widget.mode == PinMode.verify)
                    Column(
                      children: [
                        TextButton(
                          onPressed: () => context.push(
                            '/auth/pin-setup',
                            extra: {'mode': PinMode.reset},
                          ),
                          child: const Text('Forgot PIN?'),
                        ),
                        if (_biometricsAvailable) ...[
                          const SizedBox(height: 16),
                          IconButton(
                            icon: const Icon(
                              Icons.fingerprint_rounded,
                              size: 64,
                              color: AppTheme.primaryColor,
                            ),
                            onPressed: _checkBiometricForVerification,
                          ).animate().scale(),
                        ],
                      ],
                    ),
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
    bool isConfirm = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap();
        } else if (enabled || isConfirm) {
          if (focusNode.hasFocus) {
            focusNode.unfocus();
            Future.delayed(const Duration(milliseconds: 10), () {
              focusNode.requestFocus();
            });
          } else {
            focusNode.requestFocus();
          }
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
                (index) => _buildOtpBox(
                  index,
                  controller,
                  isDark,
                  enabled || isConfirm,
                ),
              ),
            ],
          ),
          Opacity(
            opacity: 0,
            child: SizedBox(
              height: 1,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                keyboardType: TextInputType.number,
                maxLength: 4,
                onChanged: (val) {
                  if (_showMismatchError) {
                    setState(() => _showMismatchError = false);
                  } else {
                    setState(() {});
                  }
                  if (val.length == 4) onComplete();
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
    var char = '';
    if (controller.text.length > index) char = controller.text[index];
    final isFocused = enabled && controller.text.length == index;
    final isWrong = _showMismatchError && controller == _confirmPinController;

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
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: (isWrong ? AppTheme.errorColor : AppTheme.primaryColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          char,
          style: TextStyle(
            fontSize: 24,
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
