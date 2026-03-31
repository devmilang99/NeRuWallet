import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/currency_model.dart';

class CurrencySelectorSheet extends StatelessWidget {
  final List<Currency> currencies;
  final Currency selectedCurrency;
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Select Currency",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final bool isSelected = currency.code == selectedCurrency.code;
                
                return ListTile(
                  onTap: () {
                    onSelected(currency);
                    Navigator.pop(context);
                  },
                  leading: Text(currency.flag, style: const TextStyle(fontSize: 24)),
                  title: Text(currency.code, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(currency.name),
                  trailing: isSelected 
                    ? const Icon(Icons.check_circle_rounded, color: AppTheme.primaryColor)
                    : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
