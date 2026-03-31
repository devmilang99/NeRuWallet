import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import 'package:neruwallet/features/services/presentation/widgets/service_widgets.dart';

class GovServicesScreen extends StatelessWidget {
  const GovServicesScreen({super.key});

  final List<Map<String, dynamic>> _govPortals = const [
    {'name': 'Driver License Pay', 'icon': Icons.badge_rounded, 'color': Color(0xFF6366F1)},
    {'name': 'Passport Service', 'icon': Icons.public_rounded, 'color': Color(0xFF0EA5E9)},
    {'name': 'National Identity Pay', 'icon': Icons.fingerprint_rounded, 'color': Color(0xFF10B981)},
    {'name': 'Social Security Fund', 'icon': Icons.family_restroom_rounded, 'color': Color(0xFFEC4899)},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Government Services',
      children: [
        const ServiceHeader(
          title: 'Direct GOV Access',
          subtitle: 'Pay for official government services directly from your wallet securely.',
          icon: Icons.account_balance_rounded,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 32),
        const Text(
          'Available Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: _govPortals.length,
          itemBuilder: (ctx, i) {
            final portal = _govPortals[i];
            return InkWell(
              onTap: () {}, // Navigate to specific service
              borderRadius: AppTheme.radiusLarge,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.surfaceDark : Colors.white,
                  borderRadius: AppTheme.radiusLarge,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: portal['color'].withValues(alpha: 0.1),
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      child: Icon(portal['icon'], color: portal['color'], size: 28),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      portal['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (i * 100).ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
          },
        ),
      ],
    );
  }
}
