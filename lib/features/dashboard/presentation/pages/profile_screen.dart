import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/core/services/biometric_service.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:neruwallet/features/auth/presentation/pages/change_pin_profile_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isKycVerified = false;
  bool _biometricHardwareSupported = false;
  bool _biometricEnrolled = false;
  bool _isBiometricLocked = false;
  String _userName = 'User';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadKycStatus();
    _loadProfileCapabilities();
  }

  void _loadUserInfo() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.displayName ?? 'User';
        _userEmail = user.email ?? '';
      });
    }
  }

  Future<void> _loadKycStatus() async {
    final prefService = ref.read(preferenceServiceProvider);
    final isVerified = await prefService.getBool('is_kyc_verified') ?? false;
    if (mounted) {
      setState(() {
        _isKycVerified = isVerified;
      });
    }
  }

  Future<void> _loadProfileCapabilities() async {
    final hardwareSupported = await BiometricService.hasHardwareSupport();
    final enrolled = await BiometricService.isEnrolled();
    final locked = await BiometricService.isLockedOut();

    if (mounted) {
      setState(() {
        _biometricHardwareSupported = hardwareSupported;
        _biometricEnrolled = enrolled;
        _isBiometricLocked = locked;
      });
    }
  }

  void _handleLogout() {
    GlassDialog.showConfirm(
      context,
      title: 'Sign Out',
      message: 'Are you sure you want to sign out of your NeRuWallet account?',
      confirmText: 'Sign Out',
      isDestructive: true,
      onConfirm: () async {
        await _authService.signOut();
        if (mounted) context.go('/auth/login');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(isDark),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(isDark),
                  const SizedBox(height: 32),
                  _buildSectionTitle('Security Settings', isDark),
                  const SizedBox(height: 12),
                  _buildSecurityCard(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Account Details', isDark),
                  const SizedBox(height: 12),
                  _buildAccountCard(isDark),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Support & Legal', isDark),
                  const SizedBox(height: 12),
                  _buildSupportCard(isDark),
                  const SizedBox(height: 40),
                  _buildLogoutButton(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : const Color(0xFFF8FAFC),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppTheme.textBodyColor,
          size: 20,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Profile Settings',
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textBodyColor,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    _userName
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              if (_isKycVerified)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  _userEmail,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: _isKycVerified
                      ? null
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'KYC Verification is currently unavailable.',
                              ),
                            ),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppTheme.radiusFull,
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isKycVerified
                              ? Icons.verified_user_rounded
                              : Icons.shield_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isKycVerified
                              ? 'Verified Account'
                              : 'Verify Your Account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        color: isDark ? Colors.white70 : AppTheme.textSecondaryColor,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildSecurityCard(bool isDark) {
    return FutureBuilder<bool?>(
      future: ref
          .read(preferenceServiceProvider)
          .getBool('biometrics_login_enabled'),
      builder: (context, snapshot) {
        final bool isBiometricEnabled = snapshot.data ?? false;

        return Card(
          child: Column(
            children: [
              _buildSettingTile(
                icon: Icons.fingerprint_rounded,
                title: 'Biometric Security',
                subtitle: !_biometricHardwareSupported
                    ? 'Hardware unsupported'
                    : (_isBiometricLocked
                          ? 'Biometrics locked (Use PIN)'
                          : (!_biometricEnrolled
                                ? 'Not activated in device settings'
                                : (isBiometricEnabled
                                      ? 'Enabled - Manage Settings'
                                      : 'Tap to enable biometric login'))),
                isDark: isDark,
                onTap:
                    (!_biometricHardwareSupported ||
                        _isBiometricLocked ||
                        !_biometricEnrolled)
                    ? null
                    : () => context.push('/profile/biometric-settings'),
                trailing: Switch.adaptive(
                  value: isBiometricEnabled,
                  onChanged:
                      (!_biometricHardwareSupported ||
                          _isBiometricLocked ||
                          !_biometricEnrolled)
                      ? null
                      : (value) async {
                          if (value) {
                            final authenticated =
                                await BiometricService.authenticate(
                                  localizedReason:
                                      'Confirm to enable biometric login',
                                );
                            if (!authenticated) return;
                          }
                          final prefService = ref.read(preferenceServiceProvider);
                          await prefService.setBool('biometrics_login_enabled', value);
                          await prefService.setBool('biometrics_enabled', value);
                          setState(() {});
                        },
                  activeTrackColor: AppTheme.primaryColor,
                ),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                icon: Icons.lock_outline_rounded,
                title: 'Change Password',
                subtitle: 'Update login credentials',
                isDark: isDark,
                onTap: () => context.push('/profile/change-password'),
              ),
              _buildDivider(isDark),
              _buildSettingTile(
                icon: Icons.pin_rounded,
                title: 'Transaction PIN',
                subtitle: 'Set or reset your security PIN',
                isDark: isDark,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePinProfileScreen(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildAccountCard(bool isDark) {
    return Card(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.person_outline_rounded,
            title: 'Personal Information',
            subtitle: 'Name, email, and phone',
            isDark: isDark,
            onTap: () => context.push('/profile/personal-info'),
          ),
          _buildDivider(isDark),
          /* Removed Notifications item as requested */
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSupportCard(bool isDark) {
    return Card(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & Support',
            subtitle: 'FAQs and direct contact',
            isDark: isDark,
            onTap: () => context.push('/profile/help-support'),
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How we protect your data',
            isDark: isDark,
            onTap: () => context.push('/profile/privacy-policy'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDark ? Colors.white : AppTheme.textBodyColor,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryColor,
          fontSize: 12,
        ),
      ),
      trailing:
          trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
          ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 20,
      color: isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.03),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return OutlinedButton.icon(
      onPressed: _handleLogout,
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('Sign Out'),

      style: OutlinedButton.styleFrom(
        foregroundColor: AppTheme.errorColor,
        side: const BorderSide(color: AppTheme.errorColor, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: AppTheme.radiusMedium),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }
}
