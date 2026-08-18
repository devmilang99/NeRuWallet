import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Privacy Policy',
      children: [
        _buildPolicySection(
          'Introduction',
          'Welcome to NeRuWallet. We are committed to protecting your personal information and your right to privacy. This privacy notice describes how we collect, use, and share your information when you use our services.',
          isDark,
        ),
        _buildPolicySection(
          'Data Collection',
          'We collect personal identifiers such as your name, email, and phone number, alongside financial transaction data and biometric authentication info (stored locally on your device), to ensure secure and efficient payment processing.',
          isDark,
        ),
        _buildPolicySection(
          'Information Sharing',
          'We do not sell your personal data. We only share information with third-party service providers (like payment processors and KYC verification partners) necessary to complete your requests under strict confidentiality agreements.',
          isDark,
        ),
        _buildPolicySection(
          'Security Measures',
          'NeRuWallet uses industry-standard encryption, secure socket layers (SSL), and advanced biometric authentication to protect your sensitive financial data from unauthorized access or breaches.',
          isDark,
        ),
        _buildPolicySection(
          'User Rights',
          'You have the right to access, rectify, or delete your personal information. You can also withdraw consent for specific data uses, such as marketing notifications, directly from your profile settings.',
          isDark,
        ),
        _buildPolicySection(
          'Updates to Policy',
          'We may update this privacy policy periodically to reflect changes in our practices or regulatory requirements. We will notify you of any significant changes via the app or email.',
          isDark,
        ),
        const SizedBox(height: 48),
        Center(
          child: Text(
            'Last Updated: April 2026',
            style: TextStyle(
              color: Colors.grey.withOpacity(0.5),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildPolicySection(String title, String content, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : Colors.white,
            borderRadius: AppTheme.radiusMedium,
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
          child: Text(
            content,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.05, end: 0);
  }
}
