import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/services/secure_signing_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/utils/logger.dart';

class BiometricSettingsScreen extends ConsumerStatefulWidget {
  const BiometricSettingsScreen({super.key});

  @override
  ConsumerState<BiometricSettingsScreen> createState() =>
      _BiometricSettingsScreenState();
}

class _BiometricSettingsScreenState
    extends ConsumerState<BiometricSettingsScreen> {
  bool _loginEnabled = false;
  bool _transactionEnabled = false;
  bool _isSupported = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefService = ref.read(preferenceServiceProvider);
    final login =
        await prefService.getBool('biometrics_login_enabled') ?? false;
    final trans =
        await prefService.getBool('biometrics_transaction_enabled') ?? false;
    final supported = await BiometricService.isEnrolled();

    if (mounted) {
      setState(() {
        _loginEnabled = login;
        _transactionEnabled = trans;
        _isSupported = supported;
      });
    }
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefService = ref.read(preferenceServiceProvider);
    AppLogger.d('Settings: Updating $key to $value');

    // If enabling transaction verification, ensure hardware key is generated
    if (key == 'biometrics_transaction_enabled' && value == true) {
      final signingService = ref.read(secureSigningServiceProvider);
      final isGenerated = await signingService.isKeyGenerated();
      AppLogger.d('Settings: Key already generated? $isGenerated');
      if (!isGenerated) {
        AppLogger.i('Settings: Requesting hardware key generation...');
        final success = await signingService.generateSecureKey();
        AppLogger.i('Settings: Key generation success: $success');
      }
    }

    await prefService.setBool(key, value);
    if (key == 'biometrics_login_enabled') {
      await prefService.setBool('biometrics_enabled', value);
    }
    _loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
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
          title: const Text('Biometric Security'),
          centerTitle: true,
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
          children: [
            _buildStatusHeader(isDark),
            const SizedBox(height: 32),
            _buildSectionTitle('PREFERENCES'),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  _buildToggleTile(
                    'App Login',
                    'Use biometrics to unlock the wallet',
                    Icons.fingerprint_rounded,
                    _loginEnabled,
                    _isSupported
                        ? (v) => _updateSetting('biometrics_login_enabled', v)
                        : null,
                  ),
                  const Divider(height: 1),
                  _buildToggleTile(
                    'Transaction Verification',
                    'Verify payments using biometrics',
                    Icons.lock_outline_rounded,
                    _transactionEnabled,
                    _isSupported
                        ? (v) => _updateSetting(
                            'biometrics_transaction_enabled',
                            v,
                          )
                        : null,
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: AppTheme.radiusLarge,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.security_rounded,
            size: 48,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isSupported ? 'Hardware Ready' : 'Hardware Not Detected',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  _isSupported
                      ? 'Your device supports biometric authentication.'
                      : 'Biometrics are not available on this device.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String desc,
    IconData icon,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppTheme.primaryColor,
      ),
    );
  }
}
