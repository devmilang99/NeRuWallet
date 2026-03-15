class Currency {
  final String code;
  final String name;
  final String flag;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.flag,
    required this.symbol,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  static const List<Currency> currencies = [
    Currency(code: 'USD', name: 'United States Dollar', flag: '🇺🇸', symbol: '\$'),
    Currency(code: 'EUR', name: 'Euro', flag: '🇪🇺', symbol: '€'),
    Currency(code: 'GBP', name: 'British Pound', flag: '🇬🇧', symbol: '£'),
    Currency(code: 'JPY', name: 'Japanese Yen', flag: '🇯🇵', symbol: '¥'),
    Currency(code: 'AUD', name: 'Australian Dollar', flag: '🇦🇺', symbol: 'A\$'),
    Currency(code: 'CAD', name: 'Canadian Dollar', flag: '🇨🇦', symbol: 'C\$'),
    Currency(code: 'CHF', name: 'Swiss Franc', flag: '🇨🇭', symbol: 'Fr'),
    Currency(code: 'CNY', name: 'Chinese Yuan', flag: '🇨🇳', symbol: '¥'),
    Currency(code: 'INR', name: 'Indian Rupee', flag: '🇮🇳', symbol: '₹'),
    Currency(code: 'NPR', name: 'Nepalese Rupee', flag: '🇳🇵', symbol: 'Rs'),
  ];
}
