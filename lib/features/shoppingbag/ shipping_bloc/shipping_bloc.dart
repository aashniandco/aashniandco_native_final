

import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';
import 'package:flutter/foundation.dart';

import '../model/countries.dart';
import '../repository/shipping_repository.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ShippingBloc extends Bloc<ShippingEvent, ShippingState> {
  final ShippingRepository _shippingRepository;

  ShippingBloc()
      : _shippingRepository = ShippingRepository(),
        super(ShippingInitial()) {
    on<FetchCountries>(_onFetchCountries);
    // on<EstimateShipping>(_onEstimateShipping);

    // ✅ REGISTER THE NEW EVENT HANDLER
    on<FetchShippingMethods>(_onFetchShippingMethods);
    on<SubmitShippingInfo>(_onSubmitShippingInfo);
    on<SubmitPaymentInfo>(_onSubmitPaymentInfo);
    on<FinalizePayUOrder>(_onFinalizePayUOrder);
  }


  Future<void> _onFetchShippingMethods(
      FetchShippingMethods event, Emitter<ShippingState> emit) async {
    emit(ShippingMethodsLoading());
    try {
      // We assume a postcode isn't required for this initial estimate, but you can add it
      final methods = await _shippingRepository.fetchAvailableShippingMethods(
        countryId: event.countryId, regionId: event.regionId, postcode: event.postcode,);
      emit(ShippingMethodsLoaded(methods));
    } catch (e) {
      emit(ShippingError(e.toString()));
    }
  }

  Future<void> _onFetchCountries(FetchCountries event, Emitter<ShippingState> emit) async {
    emit(CountriesLoading());
    try {
      final shippingRepository = ShippingRepository();
      final rawCountries = await shippingRepository.fetchCountries();
      final countries = rawCountries.map((json) => Country.fromJson(json)).toList();
      emit(CountriesLoaded(countries));
    } catch (e) {
      emit(ShippingError("Failed to load countries"));
    }
  }

  // Future<void> _onEstimateShipping(EstimateShipping event, Emitter<ShippingState> emit) async {
  //   emit(ShippingRateLoading());
  //   try {
  //     final shippingRepository = ShippingRepository();
  //     final shippingRate = await shippingRepository.estimateShipping(event.countryId,event.weight);
  //     emit(ShippingRateLoaded(shippingRate!));
  //   } catch (e) {
  //     emit(ShippingError("Failed to estimate shipping"));
  //   }
  // }

  Future<void> _onSubmitShippingInfo(
      SubmitShippingInfo event,
      Emitter<ShippingState> emit,
      ) async {
    emit(ShippingInfoSubmitting());
    try {
      // This now returns the full response with payment methods and totals
      final result = await _shippingRepository.submitShippingInformation(event);

      final paymentMethods = result['payment_methods'] as List<dynamic>;
      final totals = result['totals'] as Map<String, dynamic>;

      // Reconstruct billing address from the event to pass it forward
      final billingAddress = {
        "region": event.regionName,
        "region_id": int.tryParse(event.regionId) ?? 0,
        "region_code": event.regionCode,
        "country_id": event.countryId,
        "street": [event.streetAddress],
        "postcode": event.zipCode,
        "city": event.city,
        "firstname": event.firstName,
        "lastname": event.lastName,
        "email": event.email.isNotEmpty ? event.email : "mitesh@gmail.com",
        "telephone": event.phone,
      };

      emit(ShippingInfoSubmittedSuccessfully(
        paymentMethods: paymentMethods,
        totals: totals,
        billingAddress: billingAddress,
      ));
    } catch (e) {
      emit(ShippingError(e.toString()));
    }
  }

  // ADD THIS NEW METHOD
  Future<void> _onSubmitPaymentInfo(
      SubmitPaymentInfo event,
      Emitter<ShippingState> emit,
      ) async {
    emit(PaymentSubmitting());
    try {
      // This call now works for both user types because the logic is in the repository.
      final orderId = await _shippingRepository.submitPaymentInformation(event);
      emit(PaymentSuccess(orderId: orderId));
    } catch (e) {
      emit(ShippingError(e.toString()));
    }
  }


  Future<void> _onFinalizePayUOrder(
      FinalizePayUOrder event,
      Emitter<ShippingState> emit,
      ) async {
    emit(PaymentSubmitting());
    try {
      final orderId = await _shippingRepository.finalizePayUOrder(
        txnid: event.txnid,
        currencyCode: event.currencyCode,
        guestQuoteId: event.guestQuoteId,
        guestEmail: event.guestEmail,

      );
      emit(PaymentSuccess(orderId: orderId));
    } catch (e) {
      emit(ShippingError(e.toString()));
    }
  }

// Future<void> _onFinalizePayUOrder(
  //     FinalizePayUOrder event,
  //     Emitter<ShippingState> emit,
  //     ) async {
  //   emit(PaymentSubmitting()); // Show a loading state
  //   try {
  //     // This repository method will call your new Magento API
  //     final orderId = await _shippingRepository.finalizePayUOrder(event.txnid);
  //     emit(PaymentSuccess(orderId: orderId));
  //   } catch (e) {
  //     emit(ShippingError(e.toString()));
  //   }
  // }
}









