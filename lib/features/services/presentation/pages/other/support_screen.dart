import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Customer Support',
      children: [
        const ServiceHeader(
          title: 'How can we help?',
          subtitle: 'Our team is here 24/7 to help you with your queries and issues.',
          icon: Icons.headset_mic_rounded,
          color: Color(0xFF6366F1),
        ),
        const SizedBox(height: 32),
        const Text(
          'Contact Channels',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildContactCard(isDark, 'Live Chat', 'Chat with our support agent instantly.', Icons.chat_bubble_outline_rounded, Colors.blue),
        _buildContactCard(isDark, 'Email Us', 'support@neruwallet.com', Icons.alternate_email_rounded, Colors.orange),
        _buildContactCard(isDark, 'Phone Call', '1660-01-2026 (Toll Free)', Icons.phone_rounded, Colors.green),
        const SizedBox(height: 32),
        const Text(
          'Frequently Asked Questions',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 16),
        _buildFAQItem(isDark, 'How to reset my PIN?'),
        _buildFAQItem(isDark, 'What are the transaction limits?'),
        _buildFAQItem(isDark, 'Is my money safe in NeRuWallet?'),
      ],
    );
  }

  Widget _buildContactCard(bool isDark, String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: AppTheme.radiusMedium,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
        ],
      ),
    ).animate().fadeIn().slideX(begin: 0.05, end: 0);
  }

  Widget _buildFAQItem(bool isDark, String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark.withValues(alpha: 0.5) : Colors.white70,
        borderRadius: AppTheme.radiusMedium,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Icon(Icons.add_rounded, color: Colors.grey, size: 20),
        ],
      ),
    );
  }
}
