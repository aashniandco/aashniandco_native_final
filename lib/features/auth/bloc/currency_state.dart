import 'package:equatable/equatable.dart';

import '../data/models/available_currency.dart';
import '../data/models/currency_data.dart';
import '../data/models/currency_info.dart';
import '../data/models/exchange_rate.dart';



// abstract class CurrencyState extends Equatable {
//   const CurrencyState();
//   @override
//   List<Object?> get props => [];
// }
//
// class CurrencyInitial extends CurrencyState {}
// class CurrencyLoading extends CurrencyState {}
//
// class CurrencyLoaded extends CurrencyState {
//   final CurrencyInfo selectedCurrency;
//   final List<AvailableCurrency> availableCurrencies;
//
//   const CurrencyLoaded({
//     required this.selectedCurrency,
//     required this.availableCurrencies,
//   });
//
//   @override
//   List<Object?> get props => [selectedCurrency, availableCurrencies];
// }

abstract class CurrencyState extends Equatable {
  const CurrencyState();
  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}
class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final CurrencyData currencyData;
  final String selectedLocale; // Keep if needed
  final String selectedCurrencyCode;

  const CurrencyLoaded({
    required this.currencyData,
    required this.selectedLocale,
    required this.selectedCurrencyCode,
  });

  // Helper getters to make UI code cleaner
  ExchangeRate get selectedRate {
    return currencyData.exchangeRates.firstWhere(
          (r) => r.currencyTo == selectedCurrencyCode,
      orElse: () => ExchangeRate(currencyTo: currencyData.baseCurrencyCode, rate: 1.0),
    );
  }

  // You need a map for symbols. This can be static here.
  static const Map<String, String> _symbols = {
    'INR': '₹', 'USD': '\$', 'GBP': '£', 'EUR': '€', 'AUD': 'A\$', 'CAD': 'C\$', 'SGD': 'S\$', 'HKD': 'HK\$',
    // Add all other currencies your app supports here
  };

  String get selectedSymbol => _symbols[selectedCurrencyCode] ?? selectedCurrencyCode;

  @override
  List<Object> get props => [currencyData, selectedLocale, selectedCurrencyCode]; // Include all properties that define the state
}

class CurrencyError extends CurrencyState {
  final String message;
  const CurrencyError(this.message);

  @override
  List<Object> get props => [message];
}

// class CurrencyLoaded extends CurrencyState {
//   // All the data we need for currency management
//   final CurrencyData currencyData;
//   final String selectedLocale;
//
//   // The currency the user has currently selected
//   final String selectedCurrencyCode;
//
//   const CurrencyLoaded({required this.currencyData,    required this.selectedLocale, required this.selectedCurrencyCode});
//
//   // Helper getters to make UI code cleaner
//   ExchangeRate get selectedRate => currencyData.exchangeRates.firstWhere(
//         (r) => r.currencyTo == selectedCurrencyCode,
//     orElse: () => ExchangeRate(currencyTo: currencyData.baseCurrencyCode, rate: 1.0),
//   );
//
//   // You need a map for symbols. This can be static or you can expand the API.
//   static const Map<String, String> _symbols = {
//     'INR': '₹', 'USD': '\$', 'GBP': '£', 'EUR': '€', 'AUD': 'A\$', 'CAD': 'C\$', 'SGD': 'SG\$', 'HKD': 'HK\$',
//   };
//
//   String get selectedSymbol => _symbols[selectedCurrencyCode] ?? selectedCurrencyCode;
//
//   @override
//   List<Object?> get props => [currencyData, selectedCurrencyCode];
// }
//
// class CurrencyError extends CurrencyState {
//   final String message;
//   const CurrencyError(this.message);
//   @override
//   List<Object> get props => [message];
// }