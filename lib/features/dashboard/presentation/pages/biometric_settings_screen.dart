import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:local_auth/local_auth.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() => _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState extends ConsumerState<BiometricSettingsScreen> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _loginEnabled = false;
  bool _transactionEnabled = false;
  bool _isDeviceSupported = false;

  @override
  void initState() {
    super.initState();
    _checkSupport();
    _loadSettings();
  }

  Future<void> _checkSupport() async {
    final bool isSupported = await _auth.isDeviceSupported();
    setState(() {
      _isDeviceSupported = isSupported;
    });
  }

  Future<void> _loadSettings() async {
    final prefService = ref.read(preferenceServiceProvider);
    final loginEnabled = await prefService.getBool('biometrics_login_enabled') ?? false;
    final transactionEnabled = await prefService.getBool('biometrics_transaction_enabled') ?? false;
    setState(() {
      _loginEnabled = loginEnabled;
      _transactionEnabled = transactionEnabled;
    });
  }

  Future<void> _toggleLoginBiometrics(bool value) async {
    final prefService = ref.read(preferenceServiceProvider);
    if (value) {
      // Authenticate once before enabling
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Confirm to enable biometric login',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      if (!authenticated) return;
    }

    await prefService.setBool('biometrics_login_enabled', value);
    // Backward compatibility
    await prefService.setBool('biometrics_enabled', value);
    
    setState(() {
      _loginEnabled = value;
    });
  }

  Future<void> _toggleTransactionBiometrics(bool value) async {
    final prefService = ref.read(preferenceServiceProvider);
    if (value) {
      final bool authenticated = await _auth.authenticate(
        localizedReason: 'Confirm to enable biometric transactions',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: true),
      );
      if (!authenticated) return;
    }

    await prefService.setBool('biometrics_transaction_enabled', value);
    setState(() {
      _transactionEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Biometric Security"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(isDark),
              const SizedBox(height: 32),
              const Text(
                "PREFERENCES",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingCard(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fingerprint_rounded, size: 48, color: AppTheme.primaryColor),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isDeviceSupported ? "Device Supported" : "Wait Support Info",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : AppTheme.textBodyColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Use your biometric credentials for quick and secure access.",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSettingCard(bool isDark) {
    return Card(
      child: Column(
        children: [
          _buildToggleTile(
            title: "Biometric Login",
            subtitle: "Access your account without password",
            value: _loginEnabled,
            onChanged: _toggleLoginBiometrics,
            isDark: isDark,
          ),
          Divider(height: 1, color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.1)),
          _buildToggleTile(
            title: "Transaction Validation",
            subtitle: "Confirm payments using your biometrics",
            value: _transactionEnabled,
            onChanged: _toggleTransactionBiometrics,
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : AppTheme.textBodyColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primaryColor,
      ),
    );
  }
}
