import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../data/models/available_currency.dart';
import '../data/models/currency_info.dart';
import '../services/currency_service.dart';
import '../services/ip_service.dart';
import 'currency_event.dart';
import 'currency_state.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService;

  CurrencyBloc(this._currencyService) : super(CurrencyInitial()) {
    on<FetchCurrencyData>(_onFetchCurrencyData);
    on<ChangeCurrency>(_onChangeCurrency);
  }

  Future<void> _onFetchCurrencyData(FetchCurrencyData event, Emitter<CurrencyState> emit) async {
    emit(CurrencyLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString('selected_currency_code');

      final data = await _currencyService.fetchCurrencyData();

      String initialSelectedCode = data.baseCurrencyCode;

      // If a currency was previously saved, try to use that
      if (savedCode != null && data.availableCurrencyCodes.contains(savedCode)) {
        initialSelectedCode = savedCode;
      } else if (savedCode != null) {
        print('Warning: Saved currency code "$savedCode" not found in fetched data. Falling back to base.');
      }

      emit(CurrencyLoaded(
        currencyData: data,
        selectedLocale: 'en_IN', // Assuming this is static
        selectedCurrencyCode: initialSelectedCode, // Only pass the code
      ));
    } catch (e) {
      emit(CurrencyError(e.toString()));
    }
  }

  void _onChangeCurrency(ChangeCurrency event, Emitter<CurrencyState> emit) async {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      final newCurrencyCode = event.newCurrencyCode;

      // No need to calculate newRate or newSymbol here; the CurrencyLoaded getters handle it.

      // Update SharedPreferences with the new currency code
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency_code', newCurrencyCode);
      // We don't need to save the symbol explicitly here, as the getter in CurrencyLoaded
      // will always derive it correctly from the code using its internal map.
      // If you still want to save it for other non-bloc parts of the app, you could get it via `currentState.selectedSymbol`
      // before emitting the new state, but for bloc consumers, it's not strictly necessary.

      emit(CurrencyLoaded(
        currencyData: currentState.currencyData,
        selectedLocale: currentState.selectedLocale,
        selectedCurrencyCode: newCurrencyCode, // Only pass the code
      ));
    }
  }
}

//8/9/2025
// class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
//   final CurrencyService _currencyService;
//
//   CurrencyBloc(this._currencyService) : super(CurrencyInitial()) {
//     on<FetchCurrencyData>(_onFetchCurrencyData);
//     on<ChangeCurrency>(_onChangeCurrency);
//   }
//
//   Future<void> _onFetchCurrencyData(FetchCurrencyData event, Emitter<CurrencyState> emit) async {
//     emit(CurrencyLoading());
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedCode = prefs.getString('selected_currency_code');
//       final savedSymbol = prefs.getString('selected_currency_symbol');
//       final data = await _currencyService.fetchCurrencyData();
//       // Initially, the selected currency is the base currency from the API
//       emit(CurrencyLoaded(
//         currencyData: data,
//         selectedCurrencyCode: data.baseCurrencyCode,
//         selectedLocale: 'en_IN',
//       ));
//     } catch (e) {
//       emit(CurrencyError(e.toString()));
//     }
//   }
//
//   void _onChangeCurrency(ChangeCurrency event, Emitter<CurrencyState> emit) {
//     final currentState = state;
//     if (currentState is CurrencyLoaded) {
//       // Just update the selected code. All other data remains the same.
//       emit(CurrencyLoaded(
//         currencyData: currentState.currencyData,
//         selectedCurrencyCode: event.newCurrencyCode,
//         selectedLocale: 'en_IN',
//       ));
//     }
//   }
// }

// class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
//   final IpService _ipService;
//   final CurrencyService _currencyService;
//
//   CurrencyBloc(this._ipService, this._currencyService) : super(CurrencyInitial()) {
//     on<FetchInitialCurrency>(_onFetchInitialCurrency);
//     on<ChangeCurrency>(_onChangeCurrency);
//   }
//
//   // ✅ THIS IS THE FUNCTION THAT ANSWERS YOUR QUESTION
//   Future<void> _onFetchInitialCurrency(FetchInitialCurrency event, Emitter<CurrencyState> emit) async {
//     emit(CurrencyLoading());
//     try {
//       // 1. Get the IP address from the IpService
//       final ipAddress = await _ipService.getPublicIpAddress();
//
//       // 2. IMMEDIATELY PASS the ipAddress to the CurrencyService
//       final selectedCurrencyInfo = await _currencyService.fetchCurrencyInfo(ipAddress);
//
//       // 3. Also fetch the list of all available currencies
//       final availableCurrencies = await _currencyService.fetchAvailableCurrencies();
//
//       // 4. Emit a single state containing all the data
//       emit(CurrencyLoaded(
//         selectedCurrency: selectedCurrencyInfo,
//         availableCurrencies: availableCurrencies,
//       ));
//     } catch (e) {
//       emit(CurrencyError(e.toString()));
//     }
//   }
//   void _onChangeCurrency(ChangeCurrency event, Emitter<CurrencyState> emit) {
//     final currentState = state;
//     if (currentState is CurrencyLoaded) {
//       final newSelectedInfo = CurrencyInfo(
//         countryCode: '', // Country code isn't relevant for a manual switch
//         currencyCode: event.newCurrency.code,
//         currencySymbol: event.newCurrency.symbol,
//       );
//       emit(CurrencyLoaded(
//         selectedCurrency: newSelectedInfo,
//         availableCurrencies: currentState.availableCurrencies,
//       ));
//     }
//   }
// }