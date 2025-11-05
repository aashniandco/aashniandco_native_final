
import 'dart:convert';

import 'package:intl/intl.dart';


dynamic _parseNestedJson(dynamic value) {
  if (value is String && value.isNotEmpty) {
    try {
      // If it's a string, decode it.
      return json.decode(value);
    } catch (e) {
      // If decoding fails, return the original string or null.
      // Depending on your data, you might want to handle this differently.
      return value;
    }
  }
  // If it's not a string (e.g., already a Map or List), return it as is.
  return value;
}

// Your main OrderDetails class
class OrderDetails {
  final String orderId;
  final String orderDate;
  final String status;
  final Address? shippingAddress;
  final Address? billingAddress;
  final String shippingMethod;
  final PaymentMethod paymentMethod;
  final List<OrderItem> items;
  final Totals totals;

  OrderDetails({
    required this.orderId,
    required this.orderDate,
    required this.status,
    this.shippingAddress,
    this.billingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.items,
    required this.totals,
  });

  // This constructor is for when you fetch details from the API later (e.g., in an "Order History" screen)
  // factory OrderDetails.fromJson(dynamic json) {
  //   if (json is! List || json.length < 9) {
  //     throw const FormatException("Invalid JSON format for OrderDetails.");
  //   }
  //   return OrderDetails(
  //     orderId: json[0] as String? ?? '',
  //     orderDate: json[1] as String? ?? '',
  //     status: json[2] as String? ?? 'N/A',
  //     shippingAddress: json[3] != null ? Address.fromJson(json[3] as Map<String, dynamic>) : null,
  //     billingAddress: json[4] != null ? Address.fromJson(json[4] as Map<String, dynamic>) : null,
  //     shippingMethod: json[5] as String? ?? '',
  //     paymentMethod: PaymentMethod.fromJson(json[6] as Map<String, dynamic>? ?? {}),
  //     items: (json[7] as List<dynamic>?)?.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>)).toList() ?? [],
  //     totals: Totals.fromJson(json[8] as Map<String, dynamic>? ?? {}),
  //   );
  // }

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderId: json['order_number'] ?? '',
      orderDate: json['order_date'] ?? '',
      status: json['status'] ?? 'Unknown',
      shippingAddress: json['shipping_address'] != null ? Address.fromJson(json['shipping_address']) : null,
      billingAddress: json['billing_address'] != null ? Address.fromJson(json['billing_address']) : null,
      shippingMethod: json['shipping_method'] ?? '',
      paymentMethod: PaymentMethod.fromJson(json['payment_method'] ?? {}),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((itemJson) => OrderItem.fromJson(itemJson))
          .toList(),
      totals: Totals.fromJson(json['totals'] ?? {}),
    );
  }


  // ✅✅✅ THIS IS THE NEW CONSTRUCTOR FOR THE SUCCESS SCREEN ✅✅✅
  factory OrderDetails.fromCheckoutData({
    required int orderId,
    required Map<String, dynamic> totalsData,
    required Map<String, dynamic> billingAddressData,
    required List<dynamic> cartItems,
    required String paymentMethodCode,
  }) {
    final totals = Totals.fromCheckoutJson(totalsData);
    final address = Address.fromCheckoutJson(billingAddressData);

    String paymentTitle;
    String paymentDetails;
    // Use the paymentMethodCode to set the correct title and details.
    // Add more cases as you add more payment methods.
    switch (paymentMethodCode) {
      case 'payu_in_gateway': // Use the actual code from your backend
        paymentTitle = 'PayU';
        paymentDetails = 'Paid via PayU Gateway';
        break;
      case 'stripe_payments': // Use the actual code from your backend
        paymentTitle = 'Stripe';
        paymentDetails = 'Paid via Credit/Debit Card';
        break;
    // Add other payment methods here
    // case 'cashondelivery':
    //   paymentTitle = 'Cash On Delivery';
    //   paymentDetails = 'Pay upon receiving your order';
    //   break;
      default:
        paymentTitle = paymentMethodCode; // Fallback to the code itself
        paymentDetails = 'Payment processed';
    }
    return OrderDetails(
      orderId: orderId.toString(),
      orderDate: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      status: 'Processing',
      shippingAddress: address,
      billingAddress: address,
      shippingMethod: (totalsData['total_segments'] as List?)?.firstWhere((s) => s['code'] == 'shipping', orElse: () => {'title': 'N/A'})['title'] ?? 'N/A',
      paymentMethod: PaymentMethod(title: paymentTitle, details: paymentDetails),
      // paymentMethod: PaymentMethod(title: 'Stripe', details: 'Paid via Credit/Debit Card'),
      items: cartItems.map((item) => OrderItem.fromCartJson(item)).toList(),
      totals: totals,
    );
  }
}

// Your Address class
class Address {
  final String name;
  final String street;
  final String city;
  final String postcode;
  final String country;
  final String telephone;

  Address({
    required this.name,
    required this.street,
    required this.city,
    required this.postcode,
    required this.country,
    required this.telephone,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      name: json['name'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postcode: json['postcode'] as String? ?? '',
      country: json['country'] as String? ?? '',
      telephone: json['telephone'] as String? ?? '',
    );
  }

  // ✅ NEW CONSTRUCTOR TO HANDLE ADDRESS DATA FROM CHECKOUT
  Address.fromCheckoutJson(Map<String, dynamic> json)
      : name = '${json['firstname']} ${json['lastname']}',
        street = (json['street'] as List).join(', '),
        city = json['city'],
        postcode = json['postcode'],
        country = json['country_id'], // This is a country ID, you might map it to a name in the UI if needed
        telephone = json['telephone'];

  String get cityPostcode => '$city, $postcode';
}

// Your PaymentMethod class
class PaymentMethod {
  final String title;
  final String details;
  PaymentMethod({required this.title, required this.details});
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(title: json['title'] as String? ?? '', details: json['details'] as String? ?? 'N/A');
  }
}

// Your OrderItem class
class OrderItem {
  final String name;
  final String options;
  final String sku;
  final double price;
  final int qty;
  final double subtotal;
  final String? imageUrl;

  OrderItem({
    required this.name,
    required this.options,
    required this.sku,
    required this.price,
    required this.qty,
    required this.subtotal,
    this.imageUrl,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['name'] as String? ?? '',
      options: json['options'] as String? ?? '',
      sku: json['sku'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
    );
  }

  // ✅ NEW CONSTRUCTOR TO HANDLE CART ITEM DATA
  factory OrderItem.fromCartJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0.0;
    final qty = (json['qty'] as num?)?.toInt() ?? 0;
    return OrderItem(
      name: json['name'] ?? 'N/A',
      options: '', // You would parse this from `product_option` if available
      sku: json['sku'] ?? 'N/A',
      price: price,
      qty: qty,
      subtotal: price * qty,
      // NOTE: You need a way to get the image URL. It might not be in the cart item data.
      // This is a common limitation. You might need to fetch it or pass it from the product page.
      imageUrl: null,
    );
  }
}

// Your Totals class

class Totals {
  final double subtotal;
  final double shipping;
  final double discount;
  final double grandTotal;
  final String? couponCode;

  Totals({required this.subtotal, required this.shipping,required this.discount,required this.grandTotal,this.couponCode});

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code'],
    );
  }

  // ✅ NEW CONSTRUCTOR TO HANDLE TOTALS DATA FROM CHECKOUT
  factory Totals.fromCheckoutJson(Map<String, dynamic> json) {
    return Totals(
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shipping: (json['shipping_amount'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount_amount'] as num?)?.toDouble()?.abs() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['coupon_code'],
    );
  }
}
//live*
// class Totals {
//   final double subtotal;
//   final double shipping;
//   final double grandTotal;
//
//   Totals({required this.subtotal, required this.shipping, required this.grandTotal});
//
//   factory Totals.fromJson(Map<String, dynamic> json) {
//     return Totals(
//       subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
//       shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
//       grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
//
//   // ✅ NEW CONSTRUCTOR TO HANDLE TOTALS DATA FROM CHECKOUT
//   factory Totals.fromCheckoutJson(Map<String, dynamic> json) {
//     return Totals(
//       subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
//       shipping: (json['shipping_amount'] as num?)?.toDouble() ?? 0.0,
//       grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
// }




// class OrderDetails {
//   final String orderId;
//   final String orderDate;
//   final String status;
//   final Address? shippingAddress;
//   final Address? billingAddress;
//   final String shippingMethod;
//   final PaymentMethod paymentMethod;
//   final List<OrderItem> items;
//   final Totals totals;
//
//   OrderDetails({
//     required this.orderId,
//     required this.orderDate,
//     required this.status,
//     this.shippingAddress,
//     this.billingAddress,
//     required this.shippingMethod,
//     required this.paymentMethod,
//     required this.items,
//     required this.totals,
//   });
//
//   // ... inside the OrderDetails class ...
//
//   factory OrderDetails.fromJson(dynamic json) {
//     // The API returns a List (JSON Array), not a Map (JSON Object).
//     // We must parse it by index.
//     if (json is! List || json.length < 9) {
//       // Basic validation to prevent crashing if the array is malformed.
//       throw const FormatException("Invalid JSON format: Expected an array with at least 9 elements.");
//     }
//
//     return OrderDetails(
//       // Accessing elements by their position in the array
//       orderId: json[0] as String? ?? '',
//       orderDate: json[1] as String? ?? '',
//       status: json[2] as String? ?? 'N/A',
//
//       shippingAddress: json[3] != null
//           ? Address.fromJson(json[3] as Map<String, dynamic>)
//           : null,
//
//       billingAddress: json[4] != null
//           ? Address.fromJson(json[4] as Map<String, dynamic>)
//           : null,
//
//       shippingMethod: json[5] as String? ?? '',
//
//       paymentMethod: PaymentMethod.fromJson(json[6] as Map<String, dynamic>? ?? {}),
//
//       items: (json[7] as List<dynamic>?)
//           ?.map((itemJson) => OrderItem.fromJson(itemJson as Map<String, dynamic>))
//           .toList() ??
//           [],
//
//       totals: Totals.fromJson(json[8] as Map<String, dynamic>? ?? {}),
//     );
//   }
// }
//
// class Address {
//   final String name;
//   final String street;
//   final String city;
//   final String postcode;
//   final String country;
//   final String telephone;
//
//   Address({
//     required this.name,
//     required this.street,
//     required this.city,
//     required this.postcode,
//     required this.country,
//     required this.telephone,
//   });
//
//   factory Address.fromJson(Map<String, dynamic> json) {
//     return Address(
//       name: json['name'] as String? ?? '',
//       street: json['street'] as String? ?? '',
//       city: json['city'] as String? ?? '',
//       postcode: json['postcode'] as String? ?? '',
//       country: json['country'] as String? ?? '',
//       telephone: json['telephone'] as String? ?? '',
//     );
//   }
//
//   String get cityPostcode => '$city, $postcode';
// }
//
// class PaymentMethod {
//   final String title;
//   final String details;
//
//   PaymentMethod({required this.title, required this.details});
//
//   factory PaymentMethod.fromJson(Map<String, dynamic> json) {
//     return PaymentMethod(
//       title: json['title'] as String? ?? '',
//       details: json['details'] as String? ?? 'N/A',
//     );
//   }
// }
//
// class OrderItem {
//   final String name;
//   final String options;
//   final String sku;
//   final double price;
//   final int qty;
//   final double subtotal;
//   final String? imageUrl;
//
//   OrderItem({
//     required this.name,
//     required this.options,
//     required this.sku,
//     required this.price,
//     required this.qty,
//     required this.subtotal,
//     this.imageUrl,
//   });
//
//   factory OrderItem.fromJson(Map<String, dynamic> json) {
//     return OrderItem(
//       name: json['name'] as String? ?? '',
//       options: json['options'] as String? ?? '',
//       sku: json['sku'] as String? ?? '',
//       price: (json['price'] as num?)?.toDouble() ?? 0.0,
//       qty: (json['qty'] as num?)?.toInt() ?? 0,
//       subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
//       imageUrl: json['image_url'] as String?,
//     );
//   }
// }
//
// class Totals {
//   final double subtotal;
//   final double shipping;
//   final double grandTotal;
//
//   Totals({required this.subtotal, required this.shipping, required this.grandTotal});
//
//   factory Totals.fromJson(Map<String, dynamic> json) {
//     return Totals(
//       subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
//       shipping: (json['shipping'] as num?)?.toDouble() ?? 0.0,
//       grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
// }