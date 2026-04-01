import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../widgets/service_widgets.dart';
import '../../widgets/converter_card.dart';
import '../../widgets/rate_list_card.dart';

class ExchangeRateScreen extends StatelessWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BaseServicePage(
      title: 'Currency Exchange',
      children: [
        const ServiceHeader(
          title: 'Global Currency',
          subtitle: 'Real-time exchange rates with commercial grade precision.',
          icon: Icons.currency_exchange_rounded,
          color: Color(0xFF0EA5E9),
        ),
        const SizedBox(height: 32),
        
        const ConverterCard()
          .animate()
          .fadeIn(delay: 200.ms)
          .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
        
        const SizedBox(height: 32),
        
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.notifications_active_outlined, size: 18),
          label: const Text('Set Rate Alert'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
            foregroundColor: const Color(0xFF0EA5E9),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ).animate(delay: 300.ms).fadeIn(),

        const SizedBox(height: 32),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Live Exchange Rates",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppTheme.textBodyColor,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text("Compare"),
            ),
          ],
        ).animate().fadeIn(delay: 400.ms),
        
        const SizedBox(height: 16),
        
        const RateListCard()
          .animate()
          .fadeIn(delay: 500.ms)
          .slideY(begin: 0.1, end: 0),
          
        const SizedBox(height: 40),
      ],
    );
  }
}
