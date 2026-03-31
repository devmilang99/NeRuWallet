import 'dart:math';

class MockExchangeService {
  // Base currency is USD
  static final Map<String, double> _baseRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'JPY': 150.25,
    'AUD': 1.52,
    'CAD': 1.35,
    'CHF': 0.88,
    'CNY': 7.19,
    'INR': 82.95,
    'NPR': 132.72,
  };

  static double getRate(String from, String to) {
    final fromRate = _baseRates[from] ?? 1.0;
    final toRate = _baseRates[to] ?? 1.0;
    
    // Convert through USD
    return toRate / fromRate;
  }

  static double convert(double amount, String from, String to) {
    return amount * getRate(from, to);
  }

  static List<Map<String, dynamic>> getPopularRates(String baseCode) {
    final baseRate = _baseRates[baseCode] ?? 1.0;
    final List<Map<String, dynamic>> rates = [];

    _baseRates.forEach((code, rate) {
      if (code != baseCode) {
        rates.add({
          'code': code,
          'rate': rate / baseRate,
          'change': (Random().nextDouble() * 2 - 1) * 0.5, // Random daily change
        });
      }
    });

    return rates;
  }
}
