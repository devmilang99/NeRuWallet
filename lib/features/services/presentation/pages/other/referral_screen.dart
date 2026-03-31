import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class ReferralScreen extends StatelessWidget {
  const ReferralScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseServicePage(
      title: 'Refer & Earn',
      children: [
        const ServiceHeader(
          title: 'Invite Friends',
          subtitle: 'Refer your friends to NeRuWallet and earn rewards for each successful signup.',
          icon: Icons.people_rounded,
          color: Color(0xFF10B981),
        ),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.1),
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              const Text(
                'YOUR CODE',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppTheme.radiusMedium,
                  border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'NE RU 20 26',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF10B981)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Earn Rs. 50.00 for every friend who joins using your code and completes their KYC.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ).animate().fadeIn().slideY(begin: 0.1, end: 0),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: const Text('Share Invite Link'),
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}
