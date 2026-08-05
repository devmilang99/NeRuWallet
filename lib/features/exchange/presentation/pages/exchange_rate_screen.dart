import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../widgets/converter_card.dart';
import '../widgets/rate_list_card.dart';

class ExchangeRateScreen extends StatelessWidget {
  const ExchangeRateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Currency Exchange',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark ? Colors.white : AppTheme.textBodyColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Convert Anywhere',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppTheme.textBodyColor,
                ),
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Real-time rates with commercial grade precision.',
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppTheme.textSecondaryColor,
                ),
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),
              
              // Converter Section
              const ConverterCard()
                .animate()
                .fadeIn(delay: 200.ms)
                .scale(begin: const Offset(0.95, 0.95), curve: Curves.easeOutBack),
              
              const SizedBox(height: 40),
              
              // Rates Header
              Row((
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text'Live Exchange Rates',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppTheme.textBodyColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 16),
              
              // Rates List
              const RateListCard()
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.1, end: 0),
                
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
