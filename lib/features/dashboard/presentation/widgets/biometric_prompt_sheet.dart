import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BiometricPromptSheet extends ConsumerStatefulWidget {
  final List<BiometricType> biometrics;
  final VoidCallback onEnrolled;

  const BiometricPromptSheet({
    super.key,
    required this.biometrics,
    required this.onEnrolled,
  });

  @override
  ConsumerState<BiometricPromptSheet> createState() =>
      _BiometricPromptSheetState();
}

class _BiometricPromptSheetState extends ConsumerState<BiometricPromptSheet> {
  bool _isEnrolled = false;
  bool _loginAuth = true;
  bool _transactionAuth = true;

  @override
  Widget build(BuildContext context) {
    final bool hasFace = widget.biometrics.contains(BiometricType.face);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 32),
          _buildIcon(hasFace),
          const SizedBox(height: 24),
          _buildHeader(hasFace, isDark),
          const SizedBox(height: 12),
          _buildDescription(hasFace, isDark),
          const SizedBox(height: 40),
          if (!_isEnrolled)
            _buildEnrollActions(isDark)
          else
            _buildSettingsActions(isDark),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildIcon(bool hasFace) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        hasFace ? Icons.face_unlock_rounded : Icons.fingerprint_rounded,
        size: 64,
        color: AppTheme.primaryColor,
      ),
    ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildHeader(bool hasFace, bool isDark) {
    return Text(
      _isEnrolled ? "Configure Security" : "Enable Biometric Login",
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildDescription(bool hasFace, bool isDark) {
    return Text(
      _isEnrolled
          ? "Choose where you'd like to use biometric authentication for enhanced security."
          : "Use your ${hasFace ? 'Face ID' : 'fingerprint'} for faster and more secure access to your wallet.",
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryColor,
      ),
    );
  }

  Widget _buildEnrollActions(bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final bool didAuthenticate = await BiometricService.authenticate(
                localizedReason:
                    'Please authenticate to enable biometric login',
              );
              if (didAuthenticate) {
                setState(() {
                  _isEnrolled = true;
                });
              }
            },
            child: const Text("Enroll Now"),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            final prefService = ref.read(preferenceServiceProvider);
            await prefService.setBool('biometric_onboarding_completed', true);
            if (mounted) Navigator.pop(context);
          },
          child: Text(
            "Maybe Later",
            style: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsActions(bool isDark) {
    return Column(
      children: [
        _buildModalToggle(
          title: "Login with Biometrics",
          subtitle: "Fast and secure account access",
          value: _loginAuth,
          onChanged: (val) => setState(() => _loginAuth = val),
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        _buildModalToggle(
          title: "Authorize Transactions",
          subtitle: "Confirm payments instantly",
          value: _transactionAuth,
          onChanged: (val) => setState(() => _transactionAuth = val),
          isDark: isDark,
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () async {
            final prefService = ref.read(preferenceServiceProvider);
            await prefService.setBool(
              'biometrics_enabled',
              _loginAuth || _transactionAuth,
            );
            await prefService.setBool('biometrics_login_enabled', _loginAuth);
            await prefService.setBool(
              'biometrics_transaction_enabled',
              _transactionAuth,
            );
            // Mark onboarding as completed
            await prefService.setBool('biometric_onboarding_completed', true);

            if (mounted) {
              Navigator.pop(context);
              widget.onEnrolled();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Security settings updated successfully!"),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            }
          },
          child: const Text("Confirm Settings"),
        ),
      ],
    );
  }

  Widget _buildModalToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.black.withValues(alpha: 0.02),
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}
