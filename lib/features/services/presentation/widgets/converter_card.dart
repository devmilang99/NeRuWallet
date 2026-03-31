import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/currency_model.dart';
import '../../data/services/mock_exchange_service.dart';
import 'currency_selector_sheet.dart';

class ConverterCard extends StatefulWidget {
  const ConverterCard({super.key});

  @override
  State<ConverterCard> createState() => _ConverterCardState();
}

class _ConverterCardState extends State<ConverterCard> {
  Currency _fromCurrency = Currency.currencies[0]; // USD
  Currency _toCurrency = Currency.currencies[9];   // NPR
  final TextEditingController _fromController = TextEditingController(text: "1");
  final TextEditingController _toController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateConversion();
  }

  void _updateConversion([String? value]) {
    final amount = double.tryParse(_fromController.text) ?? 0.0;
    final converted = MockExchangeService.convert(
      amount,
      _fromCurrency.code,
      _toCurrency.code,
    );
    _toController.text = converted.toStringAsFixed(2);
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _updateConversion();
    });
  }

  void _openSelector(bool isFrom) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CurrencySelectorSheet(
        currencies: Currency.currencies,
        selectedCurrency: isFrom ? _fromCurrency : _toCurrency,
        onSelected: (currency) {
          setState(() {
            if (isFrom) {
              _fromCurrency = currency;
            } else {
              _toCurrency = currency;
            }
            _updateConversion();
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          _buildCurrencyInput(
            title: "From",
            controller: _fromController,
            currency: _fromCurrency,
            onCurrencyTap: () => _openSelector(true),
            onChanged: _updateConversion,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Divider(color: isDark ? Colors.white10 : Colors.black12),
                InkWell(
                  onTap: _swapCurrencies,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppTheme.surfaceDark : Colors.white,
                        width: 4,
                      ),
                    ),
                    child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 24),
                  ),
                ).animate(target: 1).rotate(duration: 400.ms, curve: Curves.easeInOut),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _buildCurrencyInput(
            title: "To",
            controller: _toController,
            currency: _toCurrency,
            onCurrencyTap: () => _openSelector(false),
            readOnly: true,
            isDark: isDark,
          ),
          const SizedBox(height: 24),
          Text(
            "1 ${_fromCurrency.code} = ${MockExchangeService.getRate(_fromCurrency.code, _toCurrency.code).toStringAsFixed(4)} ${_toCurrency.code}",
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyInput({
    required String title,
    required TextEditingController controller,
    required Currency currency,
    required VoidCallback onCurrencyTap,
    required bool isDark,
    bool readOnly = false,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            InkWell(
              onTap: onCurrencyTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(currency.flag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      currency.code,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: controller,
                readOnly: readOnly,
                onChanged: onChanged,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
