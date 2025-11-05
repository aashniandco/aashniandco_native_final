import 'package:equatable/equatable.dart';

// Represents one currency from the list of all available currencies
class AvailableCurrency extends Equatable {
  final String code;
  final String symbol;

  const AvailableCurrency({required this.code, required this.symbol});

  factory AvailableCurrency.fromJson(Map<String, dynamic> json) {
    return AvailableCurrency(
      code: json['code'] ?? '',
      symbol: json['symbol'] ?? '',
    );
  }

  @override
  List<Object?> get props => [code, symbol];
}