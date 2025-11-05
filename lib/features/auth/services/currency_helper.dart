import 'package:intl/intl.dart';

class CurrencyHelper {
  static double convertPrice({
    required double price,
    required String fromCurrency,
    required String toCurrency,
    required Map<String, double> exchangeRates,
  }) {
    if (fromCurrency == toCurrency) return price;

    final key = "${fromCurrency}_TO_${toCurrency}";
    if (exchangeRates.containsKey(key)) {
      return price * exchangeRates[key]!;
    }

    return price; // fallback
  }

  static String formatCurrency(double value, String currencyCode) {
    final format = NumberFormat.simpleCurrency(name: currencyCode);
    return format.format(value);
  }
}
