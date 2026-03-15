import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';

class ProfileTab extends StatelessWidget {
  final bool isDark;
  final bool biometricsEnabled;
  final Function(bool) onToggleBiometrics;

  const ProfileTab({
    super.key,
    required this.isDark,
    required this.biometricsEnabled,
    required this.onToggleBiometrics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 64, bottom: 100),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppTheme.radiusLarge,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: const Text(
                    'RG',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Raju Ghimire',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'raju@neruwallet.com',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppTheme.radiusFull,
                      ),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'KYC Verified',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn().scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
          _buildProfileMenuItem(
            isDark,
            Icons.account_circle_outlined,
            'Edit Profile',
            'Update your info',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.security_rounded,
            'Security',
            'PIN, biometrics & 2FA',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.lock_reset_rounded,
            'Change Password',
            'Update your login password',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.pin_rounded,
            'Change Transaction PIN',
            'Secure your transactions',
          ),
          _buildBiometricToggle(isDark),
          _buildProfileMenuItem(
            isDark,
            Icons.no_encryption_gmailerrorred_rounded,
            'Remove Biometrics',
            'Delete saved biometric data',
            color: AppTheme.errorColor,
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.help_outline_rounded,
            'Help & Support',
            'FAQ, live chat',
          ),
          _buildProfileMenuItem(
            isDark,
            Icons.privacy_tip_outlined,
            'Privacy Policy',
            'Read our policies',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.logout_rounded,
                color: AppTheme.errorColor,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                side: const BorderSide(color: AppTheme.errorColor),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem(
    bool isDark,
    IconData icon,
    String title,
    String sub, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color ?? AppTheme.primaryColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: color,
                    ),
                  ),
                  Text(
                    sub,
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? AppTheme.textHintDark : AppTheme.textHintColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricToggle(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : Colors.white,
          borderRadius: AppTheme.radiusMedium,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: Colors.orange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Biometric Login',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Use fingerprint or face ID',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: biometricsEnabled,
              activeColor: AppTheme.primaryColor,
              onChanged: onToggleBiometrics,
            ),
          ],
        ),
      ),
    );
  }
}
