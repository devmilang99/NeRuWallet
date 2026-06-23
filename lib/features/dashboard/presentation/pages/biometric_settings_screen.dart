import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState
    extends ConsumerState<BiometricSettingsScreen>
    with WidgetsBindingObserver {
  bool _loginEnabled = false;
  bool _transactionEnabled = false;
  bool _hardwareSupported = false;
  bool _isEnrolled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    final bool hasHardware = await BiometricService.hasHardwareSupport();
    final bool enrolled = await BiometricService.isEnrolled();
    final prefService = ref.read(preferenceServiceProvider);
    final loginEnabled =
        await prefService.getBool('biometrics_login_enabled') ?? false;
    final transactionEnabled =
        await prefService.getBool('biometrics_transaction_enabled') ?? false;

    if (mounted) {
      setState(() {
        _hardwareSupported = hasHardware;
        _isEnrolled = enrolled;
        _loginEnabled = loginEnabled;
        _transactionEnabled = transactionEnabled;
      });
    }
  }

  Future<void> _toggleLoginBiometrics(bool value) async {
    if (!_hardwareSupported || !_isEnrolled) return;

    if (value) {
      final bool authenticated = await BiometricService.authenticate(
        localizedReason: 'Confirm to enable biometric login',
      );
      if (!authenticated) return;
    }

    final prefService = ref.read(preferenceServiceProvider);
    await prefService.setBool('biometrics_login_enabled', value);
    await prefService.setBool('biometrics_enabled', value);

    if (mounted) {
      setState(() {
        _loginEnabled = value;
      });
    }
  }

  Future<void> _toggleTransactionBiometrics(bool value) async {
    if (!_hardwareSupported || !_isEnrolled) return;

    if (value) {
      final bool authenticated = await BiometricService.authenticate(
        localizedReason: 'Confirm to enable transaction biometrics',
      );
      if (!authenticated) return;
    }

    final prefService = ref.read(preferenceServiceProvider);
    await prefService.setBool('biometrics_transaction_enabled', value);
    if (mounted) {
      setState(() {
        _transactionEnabled = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Biometric Security"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
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
          const Icon(
            Icons.fingerprint_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _hardwareSupported
                      ? (_isEnrolled ? "Biometrics Active" : "Action Required")
                      : "Not Supported",
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
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryColor,
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
    final bool canToggle = _hardwareSupported && _isEnrolled;

    return Card(
      child: Column(
        children: [
          _buildToggleTile(
            title: "Biometric Login",
            subtitle: !_hardwareSupported
                ? "Hardware unsupported on this device"
                : (!_isEnrolled
                    ? "Activate biometrics in device settings"
                    : "Access your account without password"),
            value: _loginEnabled,
            onChanged: canToggle ? _toggleLoginBiometrics : null,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            color: isDark
                ? Colors.white12
                : Colors.black.withValues(alpha: 0.1),
          ),
          _buildToggleTile(
            title: "Transaction Validation",
            subtitle: !_hardwareSupported
                ? "Hardware unsupported on this device"
                : (!_isEnrolled
                    ? "Activate biometrics in device settings"
                    : "Confirm payments using your biometrics"),
            value: _transactionEnabled,
            onChanged: canToggle ? _toggleTransactionBiometrics : null,
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
    required ValueChanged<bool>? onChanged,
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
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryColor,
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
