

import 'package:equatable/equatable.dart';

import '../data/models/available_currency.dart';



abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();
  @override
  List<Object> get props => [];
}

// Event to trigger the initial data fetch on app start
class FetchInitialCurrency extends CurrencyEvent {}

class FetchCurrencyData extends CurrencyEvent {}

// Event for when the user manually selects a new currency
// class ChangeCurrency extends CurrencyEvent {
//   final AvailableCurrency newCurrency;
//   const ChangeCurrency(this.newCurrency);
//   @override
//   List<Object> get props => [newCurrency];
// }

class ChangeCurrency extends CurrencyEvent {
  final String newCurrencyCode;
  const ChangeCurrency(this.newCurrencyCode);
  @override
  List<Object> get props => [newCurrencyCode];
}