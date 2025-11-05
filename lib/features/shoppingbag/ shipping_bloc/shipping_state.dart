import '../model/countries.dart';

abstract class ShippingState {}

class ShippingInitial extends ShippingState {}

class CountriesLoading extends ShippingState {}

class CountriesLoaded extends ShippingState {
  final List<Country> countries;
  CountriesLoaded(this.countries);
}

class ShippingRateLoading extends ShippingState {}

class ShippingRateLoaded extends ShippingState {
  final double shippingPrice;

  ShippingRateLoaded(this.shippingPrice);
}

// ✅ ADD THESE NEW STATES
class ShippingInfoSubmitting extends ShippingState {}

class ShippingInfoSubmitted extends ShippingState {
  // Pass the API response to the UI so it can be used for the next screen (e.g., payment)
  final Map<String, dynamic> submissionResponse;

  ShippingInfoSubmitted({required this.submissionResponse});

  @override
  List<Object> get props => [submissionResponse];
}


class ShippingInfoSubmittedSuccessfully extends ShippingState {
  final List<dynamic> paymentMethods;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> billingAddress; // We'll pass the address along

  ShippingInfoSubmittedSuccessfully({
    required this.paymentMethods,
    required this.totals,
    required this.billingAddress,
  });
}

// Add these new states for the payment process
class PaymentSubmitting extends ShippingState {}

class PaymentSuccess extends ShippingState {
  final int orderId; // Magento returns the Order ID as an integer

   PaymentSuccess({required this.orderId});
}

// v-- ADD THIS STATE --v
class PaymentFailure extends ShippingState {
  final String error;
  PaymentFailure({required this.error});
}

class ShippingError extends ShippingState {
  final String message;
  ShippingError(this.message);
}
class ShippingMethodsLoading extends ShippingState {}
// 🔄 REPLACE ShippingRateLoaded state with this
class ShippingMethodsLoaded extends ShippingState {
  final List<ShippingMethod> methods;
  ShippingMethodsLoaded(this.methods);
}