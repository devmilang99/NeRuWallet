import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Help & Support',
      children: [
        _buildSupportSection('Fastest Support', Icons.support_agent_rounded, [
          _buildActionItem(
            'Live Chat (24/7)',
            'Chat with our experts',
            Icons.chat_bubble_outline_rounded,
            Colors.blue,
            isDark,
          ),
          _buildActionItem(
            'Call Support',
            '+977-1-4123456',
            Icons.call_outlined,
            Colors.green,
            isDark,
          ),
          _buildActionItem(
            'Email Us',
            'support@neruwallet.com',
            Icons.email_outlined,
            Colors.orange,
            isDark,
          ),
        ]),
        const SizedBox(height: 24),
        _buildSupportSection(
          'Frequently Asked Questions',
          Icons.help_outline_rounded,
          [
            _buildFaqItem(
              'How to reset transaction PIN?',
              'Go to Profile -> Transaction PIN -> Reset PIN.',
              isDark,
            ),
            _buildFaqItem(
              'What are the transaction limits?',
              'KYC verified: Rs. 1,00,000/day. Unverified: Rs. 5,000/day.',
              isDark,
            ),
            _buildFaqItem(
              'Is NeRuWallet safe?',
              'Yes, we use bank-grade encryption and biometric security.',
              isDark,
            ),
            _buildFaqItem(
              'How to verify KYC?',
              'Go to Home -> Verify Identity and follow the steps.',
              isDark,
            ),
          ],
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildSupportSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildActionItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Colors.grey,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.05, end: 0);
  }

  Widget _buildFaqItem(String question, String answer, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }
}
