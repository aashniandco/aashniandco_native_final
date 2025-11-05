import 'package:equatable/equatable.dart';

// Represents the GeoIP-detected currency information
class CurrencyInfo extends Equatable {
  final String countryCode;
  final String currencyCode;
  final String currencySymbol;

  const CurrencyInfo({
    required this.countryCode,
    required this.currencyCode,
    required this.currencySymbol,
  });

  factory CurrencyInfo.fromJson(Map<String, dynamic> json) {
    return CurrencyInfo(
      countryCode: json['country_code'] ?? 'N/A',
      currencyCode: json['currency_code'] ?? 'USD',
      currencySymbol: json['currency_symbol'] ?? '\$',
    );
  }

  @override
  List<Object?> get props => [countryCode, currencyCode, currencySymbol];
}