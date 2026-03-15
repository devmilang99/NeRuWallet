import 'package:flutter/material.dart';
import 'package:neruwallet/core/theme/app_theme.dart';
import '../../data/models/currency.dart';

class CurrencySelectorSheet extends StatelessWidget {
  final List<Currency> currencies;
  final Currency? selectedCurrency;
  final Function(Currency) onSelected;

  const CurrencySelectorSheet({
    super.key,
    required this.currencies,
    required this.selectedCurrency,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Select Currency",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = selectedCurrency?.code == currency.code;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                  leading: Text(currency.flag, style: const TextStyle(fontSize: 28)),
                  title: Text(
                    currency.name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isDark ? Colors.white : AppTheme.textBodyColor,
                    ),
                  ),
                  subtitle: Text(currency.code, style: const TextStyle(color: Colors.grey)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    onSelected(currency);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
