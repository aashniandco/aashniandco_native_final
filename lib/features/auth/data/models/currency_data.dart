

import 'exchange_rate.dart';

class CurrencyData {
  final String baseCurrencyCode;
  final String baseCurrencySymbol;
  final List<String> availableCurrencyCodes;
  final List<ExchangeRate> exchangeRates;

  CurrencyData({
    required this.baseCurrencyCode,
    required this.baseCurrencySymbol,
    required this.availableCurrencyCodes,
    required this.exchangeRates,
  });

  factory CurrencyData.fromJson(Map<String, dynamic> json) {
    var ratesList = json['exchange_rates'] as List? ?? [];
    List<ExchangeRate> rates = ratesList.map((i) => ExchangeRate.fromJson(i)).toList();

    var codesList = json['available_currency_codes'] as List? ?? [];
    List<String> codes = codesList.map((i) => i.toString()).toList();

    return CurrencyData(
      baseCurrencyCode: json['base_currency_code'] ?? 'USD',
      baseCurrencySymbol: json['base_currency_symbol'] ?? '\$',
      availableCurrencyCodes: codes,
      exchangeRates: rates,
    );
  }
}