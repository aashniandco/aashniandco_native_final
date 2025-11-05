import 'package:equatable/equatable.dart';

abstract class ShippingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}




class FetchCountries extends ShippingEvent {}

class EstimateShipping extends ShippingEvent {
  final String countryId;

  final double weight;

  EstimateShipping(this.countryId,this.weight);
}


class SubmitShippingInfo extends ShippingEvent {
  final String firstName;
  final String lastName;
  final String streetAddress;
  final String city;
  final String zipCode;
  final String phone;
  final String email;
  final String countryId;
  final String regionName;
  final String regionId;
  final String regionCode;
  final String carrierCode;
  final String methodCode;

   SubmitShippingInfo({
    required this.firstName,
    required this.lastName,
    required this.streetAddress,
    required this.city,
    required this.zipCode,
    required this.phone,
    required this.email,
    required this.countryId,
    required this.regionName,
    required this.regionId,
    required this.regionCode,
    required this.carrierCode,
    required this.methodCode,
  });




  @override
  List<Object> get props => [
    firstName, lastName, streetAddress, city, zipCode, phone, email,
    countryId, regionName, regionId, regionCode, carrierCode, methodCode
  ];



}

// class SubmitPaymentInfo extends ShippingEvent {
//   final String paymentMethodCode;
//   final Map<String, dynamic> billingAddress;
//   final String paymentMethodNonce;
//
//    SubmitPaymentInfo({
//     required this.paymentMethodCode,
//     required this.billingAddress,
//      required this.paymentMethodNonce,
//   });
// }

class SubmitPaymentInfo extends ShippingEvent {
  final String paymentMethodCode;
  final Map<String, dynamic> billingAddress;
  final String? paymentMethodNonce;
  final String currencyCode; // ✅ ADD THIS NEW REQUIRED PARAMETER

   SubmitPaymentInfo({
    required this.paymentMethodCode,
    required this.billingAddress,
    this.paymentMethodNonce,
    required this.currencyCode, // ✅ MAKE IT REQUIRED
  });
}

// 🔄 REPLACE EstimateShipping event
class FetchShippingMethods extends ShippingEvent {
  final String countryId;
  final String regionId;
  final String postcode;

  // Add other address fields if you need them
  FetchShippingMethods({required this.countryId, required this.regionId, this.postcode = ""});

}


// class FinalizePayUOrder extends ShippingEvent {
//   final String txnid; // The transaction ID from PayU
//
//    FinalizePayUOrder({required this.txnid});
//
//   @override
//   List<Object> get props => [txnid];
// }


// ✅ MODIFIED: This event now includes the currency code.
class FinalizePayUOrder extends ShippingEvent {
  final String txnid;
  final String currencyCode;
  final String? guestQuoteId;
  final String? guestEmail;


  FinalizePayUOrder({
    required this.txnid,
    required this.currencyCode,
    this.guestQuoteId,
    this.guestEmail,

  });
}

// class FinalizePayUOrder extends ShippingEvent {
//   final String txnid;
//   final String currencyCode; // The currency the user paid with.
//
//
//   FinalizePayUOrder({required this.txnid, required this.currencyCode});
//
//   @override
//   List<Object> get props => [txnid, currencyCode];
// }

// ✅ NEW EVENT (Recommended): Create a similar event for Stripe.
// This separates the initial payment submission from the finalization after 3D Secure, etc.
// If your current Stripe flow works with just SubmitPaymentInfo, you might not need this yet,
// but it's good practice.
class FinalizeStripeOrder extends ShippingEvent {
  final String paymentIntentId;
  final String currencyCode;

  FinalizeStripeOrder({required this.paymentIntentId, required this.currencyCode});

  @override
  List<Object> get props => [paymentIntentId, currencyCode];
}