// In your order_history.dart or order.dart file

// In your order_history.dart file

// lib/features/order/model/order_history.dart

// Model for a single item within an order
// lib/features/order/model/order_models.dart

// --- 1. MODEL FOR THE ORDER LIST SCREEN ---
// This model matches the response from your list API endpoint.

class OrderSummary {
  final String id; // This is the entity_id
  final String incrementId;
  final String status;
  final String createdAt;
  final String shipTo;
  final double grandTotal;
  final String currencyCode;

  OrderSummary({
    required this.id,
    required this.incrementId,
    required this.status,
    required this.createdAt,
    required this.shipTo,
    required this.grandTotal,
    required this.currencyCode,

  });

  // This factory correctly parses the JSON from your list API
  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id']?.toString() ?? '',
      incrementId: json['increment_id']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      createdAt: json['created_at']?.toString() ?? "",
      shipTo: json['ship_to']?.toString() ?? "",
      grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0.0') ?? 0.0,
      currencyCode: json['order_currency_code']?.toString() ?? "INR",

    );
  }
}


// --- 2. MODELS FOR THE ORDER DETAILS SCREEN ---
// These models match the response from your /aashni/order-details/:orderId endpoint.

class OrderDetails11 {
  final String incrementId;
  final String createdAt;
  final String status;
  final String shipTo;
  final String billingAddress;
  final String shippingMethod;
  final String paymentMethod;
  final double grandTotal;
  final double subtotal;
  final double shippingAmount;
  final List<OrderItem11> items;
  final String currencyCode;
  final double discountAmount;
  final String couponCode;

  OrderDetails11({
    required this.incrementId,
    required this.createdAt,
    required this.status,
    required this.shipTo,
    required this.billingAddress,
    required this.shippingMethod,
    required this.paymentMethod,
    required this.grandTotal,
    required this.subtotal,
    required this.shippingAmount,
    required this.items,
    required this.currencyCode,
    required this.discountAmount,
    required this.couponCode,
  });

  // This helper formats the address map from your API
  static String _formatAddressFromMap(Map<String, dynamic> addressMap) {
    return [
      addressMap['name'] ?? '',
      addressMap['street'] ?? '',
      '${addressMap['city'] ?? ''}, ${addressMap['postcode'] ?? ''}',
      addressMap['country'] ?? '',
      addressMap['telephone'] ?? '',
    ].where((s) => s.isNotEmpty).join('\n');
  }

  // This helper formats the payment map from your API
  static String _formatPaymentFromMap(Map<String, dynamic> paymentMap) {
    return [
      paymentMap['title'] ?? '',
      paymentMap['details'] ?? '',
    ].where((s) => s.isNotEmpty).join('\n');
  }

  // ✅ NEW FACTORY to parse the keyless list from your API
  factory OrderDetails11.fromKeylessList(List<dynamic> list) {
    if (list.length < 9) {
      throw FormatException("Invalid API response format: list is too short. Length = ${list.length}");
    }

    final itemsList = (list[7] as List<dynamic>)
        .map((itemJson) => OrderItem11.fromJson(itemJson as Map<String, dynamic>))
        .toList();

    final totalsMap = list[8] as Map<String, dynamic>;

    return OrderDetails11(
      incrementId: list[0] as String,
      createdAt: list[1] as String,
      status: list[2] as String,
      shipTo: _formatAddressFromMap(list[3] as Map<String, dynamic>),
      billingAddress: _formatAddressFromMap(list[4] as Map<String, dynamic>),
      shippingMethod: list[5] as String,
      paymentMethod: _formatPaymentFromMap(list[6] as Map<String, dynamic>),
      items: itemsList,
      subtotal: (totalsMap['subtotal'] as num).toDouble(),
      shippingAmount: (totalsMap['shipping'] as num).toDouble(),
      grandTotal: (totalsMap['grand_total'] as num).toDouble(),
      currencyCode: (totalsMap['currency_code'] ?? 'USD') as String, // ✅ FIXED
      discountAmount: (totalsMap['discount_amount'] as num?)?.toDouble()?.abs() ?? 0.0,
      couponCode: totalsMap['coupon_code'] as String? ?? '',
    );
  }

}


class OrderItem11 {
  final String name;
  final String sku;
  final double price;
  final int qty;
  final String imageUrl;
  final String status;
  final String currencyCode;
  final double subtotal;

  final int statusCode;     // ✅ NEW
  final String statusText;  // ✅ NEW
  final String tracking;

  OrderItem11({
    required this.name,
    required this.sku,
    required this.price,
    required this.qty,
    required this.imageUrl,
    required this.status,
    required this.currencyCode,
    required this.subtotal,
    required this.statusCode,
    required this.statusText,
    required this.tracking,
  });

  factory OrderItem11.fromJson(Map<String, dynamic> json) {
    return OrderItem11(
      name: json['name'] ?? 'Unknown Item',
      sku: json['sku'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      imageUrl: json['image_url'] ?? '',
      status: json['status'] ?? 'Pending',
      currencyCode: json['order_currency_code'] ?? 'USD',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      statusCode: json['status_code'] ?? 0,
      statusText: json['item_status'] ?? '',
      tracking: json['tracking'] ?? '',
    );
  }
}

// TODO: This model should be updated to match the full API response for a single order,
// including a list of items, billing address, payment method, etc.
// class Order {
//   final String id;
//   final String incrementId;
//   final String status;
//   final String createdAt;
//   final String shipTo;
//   final double grandTotal;
//   // --- ADDED FIELDS (as placeholders for now) ---
//   final String billingAddress;
//   final String shippingMethod;
//   final String paymentMethod;
//   final List<OrderItem> items;
//
//   Order({
//     required this.id,
//     required this.incrementId,
//     required this.status,
//     required this.createdAt,
//     required this.shipTo,
//     required this.grandTotal,
//     // Add new fields to constructor
//     required this.billingAddress,
//     required this.shippingMethod,
//     required this.paymentMethod,
//     required this.items,
//   });
//
//   factory Order.fromJson(Map<String, dynamic> json) {
//     // This factory now uses placeholder data for the new fields.
//     // TODO: Update this to parse the real data from your API.
//     var placeholderItems = [
//       OrderItem(
//         imageUrl: '', // An empty URL will show the placeholder image
//         name: 'Chamee and Palak',
//         sku: 'CPABOHEM009-Medium',
//         price: 38000.00,
//         quantity: 1,
//         status: 'In Pending',
//       )
//     ];
//
//     // Calculate subtotal from items
//     double subtotal = placeholderItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
//
//     return Order(
//       id: json['id']?.toString() ?? '',
//       incrementId: json['increment_id']?.toString() ?? "",
//       status: json['status']?.toString() ?? "",
//       createdAt: json['created_at']?.toString() ?? "",
//       shipTo: json['ship_to']?.toString() ?? "laksh Jain\ntest\nmum, Tasmania, 212\nAustralia\nT: 1212",
//       grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0.0') ?? 0.0,
//
//       // --- Placeholder Data ---
//       items: placeholderItems,
//       billingAddress: "laksh Jain\ntest\nmum, Tasmania, 212\nAustralia\nT: 1212",
//       shippingMethod: 'Shipping - DHL',
//       paymentMethod: 'Pay by Card (Stripe)\nCard: Amex ending **** 0005\nExpires: 11/2029',
//     );
//   }
// }
//
//
// // A model for items within an order.
// class OrderItem {
//   final String imageUrl;
//   final String name;
//   final String sku;
//   final double price;
//   final int quantity;
//   final String status;
//
//   OrderItem({
//     required this.imageUrl,
//     required this.name,
//     required this.sku,
//     required this.price,
//     required this.quantity,
//     required this.status,
//   });
// }

// class Order {
//   final String id;
//   final String incrementId;
//   final String status;
//   final String createdAt;
//   final String shipTo;
//   final double grandTotal;
//
//   Order({
//     required this.id,
//     required this.incrementId,
//     required this.status,
//     required this.createdAt,
//     required this.shipTo,
//     required this.grandTotal,
//   });
//
//   // ✅ THIS IS THE CORRECTED, FULLY ROBUST FACTORY
//   factory Order.fromJson(Map<String, dynamic> json) {
//     return Order(
//       // Safely convert id to String
//       id: json['id']?.toString() ?? '',
//
//       // Safely convert increment_id to String
//       incrementId: json['increment_id']?.toString() ?? "",
//
//       // Safely convert status to String
//       status: json['status']?.toString() ?? "",
//
//       // Safely convert created_at to String
//       createdAt: json['created_at']?.toString() ?? "",
//
//       // Safely convert ship_to to String
//       shipTo: json['ship_to']?.toString() ?? "",
//
//       // grand_total parsing is already safe
//       grandTotal: double.tryParse(json['grand_total']?.toString() ?? '0.0') ?? 0.0,
//     );
//   }
// }