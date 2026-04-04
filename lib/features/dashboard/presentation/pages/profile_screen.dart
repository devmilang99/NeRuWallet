import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:ekyc_shared/ekyc_shared.dart' as ocr;
import 'package:neruwallet/core/widgets/glass_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:neruwallet/features/auth/data/services/auth_service.dart';
import 'package:neruwallet/features/auth/presentation/pages/change_pin_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  bool _isKycVerified = false;

  @override
  void initState() {
    super.initState();
    _loadKycStatus();
  }

  Future<void> _loadKycStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isKycVerified = prefs.getBool('is_kyc_verified') ?? false;
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
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
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
      backgroundColor: isDark ? AppTheme.backgroundDark : const Color(0xFFF8FAFC),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, 
          color: isDark ? Colors.white : AppTheme.textBodyColor, size: 20),
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
                child: const CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Text(
                    'RG',
                    style: TextStyle(
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
                    child: const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Raju Ghimire',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  'raju@neruwallet.com',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ocr.HomeScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppTheme.radiusFull,
                      border: Border.all(color: Colors.white38),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isKycVerified ? Icons.verified_user_rounded : Icons.shield_rounded, 
                          color: Colors.white, 
                          size: 14
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isKycVerified ? 'Verified Account' : 'Verify Your Account',
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
    return Card(
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Security',
            subtitle: 'Manage Face ID/Fingerprint',
            isDark: isDark,
            onTap: () => context.push('/profile/biometric-settings'),
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            subtitle: 'Update login credentials',
            isDark: isDark,
            onTap: () => context.push('/auth/security-setup', extra: {'isSocial': true}),
          ),
          _buildDivider(isDark),
          _buildSettingTile(
            icon: Icons.pin_rounded,
            title: 'Transaction PIN',
            subtitle: 'Set or reset your security PIN',
            isDark: isDark,
            // Navigate directly to ChangePinProfileScreen which handles the
            // full 3-step flow: verify old PIN → new PIN → confirm new PIN.
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChangePinProfileScreen(),
              ),
            ),
          ),
        ],
      ),
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
          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryColor,
          fontSize: 12,
        ),
      ),
      trailing: trailing ?? Icon(
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
