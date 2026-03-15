import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/currency.dart';
import '../../data/services/mock_exchange_service.dart';

class RateListCard extends StatelessWidget {
  const RateListCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final popularRates = MockExchangeService.getPopularRates('USD');

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: AppTheme.radiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: popularRates.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          indent: 70,
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
        itemBuilder: (context, index) {
          final rateData = popularRates[index];
          final currency = Currency.currencies.firstWhere((c) => c.code == rateData['code']);
          final double change = rateData['change'];
          final isPositive = change >= 0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Text(currency.flag, style: const TextStyle(fontSize: 24)),
            ),
            title: Text(
              currency.code,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              currency.name,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppTheme.textSecondaryColor,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "1.00 USD = ${rateData['rate'].toStringAsFixed(2)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: isPositive ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${isPositive ? '+' : ''}${change.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
