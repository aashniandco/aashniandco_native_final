class ExchangeRate {
  final String currencyTo;
  final double rate;

  ExchangeRate({required this.currencyTo, required this.rate});

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    return ExchangeRate(
      currencyTo: json['currency_to'] ?? '',
      rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
    );
  }
}