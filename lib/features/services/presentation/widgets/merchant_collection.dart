import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_theme.dart';

class MerchantCollection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> merchants;

  const MerchantCollection({
    required this.title,
    required this.merchants,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: merchants.length,
          itemBuilder: (ctx, i) {
            final m = merchants[i];
            return InkWell(
              onTap: () {},
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
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: m['color'].withValues(alpha: 0.1),
                        borderRadius: AppTheme.radiusMedium,
                      ),
                      child: Icon(m['icon'], color: m['color'], size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      m['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      m['category'] ?? 'Partner',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (i * 100).ms).fadeIn().slideY(begin: 0.1, end: 0);
          },
        ),
      ],
    );
  }
}
