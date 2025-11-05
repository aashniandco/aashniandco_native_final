// lib/features/order/view/order_history_details.dart

import 'package:flutter/material.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../model/order_history.dart'; // Make sure this import path is correct
import 'package:flutter_bloc/flutter_bloc.dart';
// lib/features/order/view/order_history_details.dart

import 'package:flutter/material.dart';
 // Make sure this path is correct
import '../repository/order_history_repository.dart';

// class OrderHistoryDetails extends StatefulWidget {
//   final String orderId;
//   final String incrementId;
//
//   const OrderHistoryDetails({
//     super.key,
//     required this.orderId,
//     required this.incrementId,
//   });
//
//   @override
//   State<OrderHistoryDetails> createState() => _OrderHistoryDetailsState();
// }
//
// class _OrderHistoryDetailsState extends State<OrderHistoryDetails> {
//   final OrderHistoryRepository _repository = OrderHistoryRepository();
//   late Future<OrderDetails11> _orderDetailsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _orderDetailsFuture = _repository.fetchOrderDetails(widget.orderId);
//   }
//
//   String getCurrencySymbol(String code) {
//     switch (code.toUpperCase()) {
//       case "AUD": return "AU\$";
//       case "GBP": return "£";
//       case "CAD": return "CA\$";
//       case "EUR": return "€";
//       case "HKD": return "HK\$";
//       case "INR": return "₹";
//       case "SGD": return "SG\$";
//       case "USD": return "\$";
//       default: return code;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order #${widget.incrementId}"),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//       ),
//       body: FutureBuilder<OrderDetails11>(
//         future: _orderDetailsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Failed to load order details.\nError: ${snapshot.error}',
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }
//
//           if (!snapshot.hasData) {
//             return const Center(child: Text('Order not found.'));
//           }
//
//           final order = snapshot.data!;
//           final symbol = getCurrencySymbol(order.currencyCode);
//
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildSectionTitle('Items Ordered'),
//                 ...order.items.map((item) => _buildOrderItem(item, symbol)).toList(),
//                 const SizedBox(height: 24),
//                 _buildOrderTotals(
//                   subtotal: order.subtotal,
//                   shipping: order.shippingAmount,
//                   grandTotal: order.grandTotal,
//                   currencySymbol: symbol,
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // --- Helper widgets ---
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 16.0),
//       child: Text(
//         title,
//         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _buildOrderItem(OrderItem11 item, String symbol) {
//     // Prices are assumed to be in order currency already
//     final price = item.price;
//     final subtotal = item.price * item.qty;
//
//     return Card(
//       elevation: 1,
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Column(
//           children: [
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   width: 80,
//                   height: 100,
//                   color: Colors.grey[200],
//                   child: item.imageUrl.isNotEmpty
//                       ? Image.network(
//                     item.imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stack) =>
//                     const Icon(Icons.image, size: 40, color: Colors.grey),
//                   )
//                       : const Icon(Icons.image, size: 40, color: Colors.grey),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(item.name,
//                           style: const TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 16)),
//                       const SizedBox(height: 4),
//                       Text('SKU: ${item.sku}',
//                           style: const TextStyle(color: Colors.grey)),
//                       const SizedBox(height: 8),
//                       Text('Price: $symbol${price.toStringAsFixed(2)}'),
//                       Text('Qty: ${item.qty}'),
//                       Text('Subtotal: $symbol${subtotal.toStringAsFixed(2)}'),
//                       Text('Status: ${item.status}'),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildOrderTotals({
//     required double subtotal,
//     required double shipping,
//     required double grandTotal,
//     required String currencySymbol,
//   }) {
//     return Column(
//       children: [
//         _buildSummaryRow('Subtotal', '$currencySymbol${subtotal.toStringAsFixed(2)}'),
//         _buildSummaryRow('Shipping & Handling', '$currencySymbol${shipping.toStringAsFixed(2)}'),
//     _buildSummaryRow('Duties and Taxes', '${currencySymbol}0.00'),
//
//         const Divider(height: 20),
//         _buildSummaryRow('Grand Total', '$currencySymbol${grandTotal.toStringAsFixed(2)}', isBold: true),
//       ],
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 16)),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: isBold ? 18 : 16,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// old
class OrderHistoryDetails extends StatefulWidget {
  final String orderId;
  final String incrementId;

  const OrderHistoryDetails({
    super.key,
    required this.orderId,
    required this.incrementId,
  });

  @override
  State<OrderHistoryDetails> createState() => _OrderHistoryDetailsState();
}

class _OrderHistoryDetailsState extends State<OrderHistoryDetails> {
  final OrderHistoryRepository _repository = OrderHistoryRepository();
  late Future<OrderDetails11> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Access orderId using widget.orderId
    _orderDetailsFuture = _repository.fetchOrderDetails(widget.orderId);
  }


  String getCurrencySymbol(String code) {
    switch (code.toUpperCase()) {
      case "AUD": return "AU\$"; // Australian Dollar
      case "GBP": return "£";   // British Pound
      case "CAD": return "CA\$"; // Canadian Dollar
      case "EUR": return "€";   // Euro
      case "HKD": return "HK\$"; // Hong Kong Dollar
      case "INR": return "₹";   // Indian Rupee
      case "SGD": return "SG\$"; // Singapore Dollar
      case "USD": return "\$";  // US Dollar
      default: return code;     // fallback: show code itself
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order #${widget.incrementId}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, currencyState) {
          if (currencyState is! CurrencyLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return FutureBuilder<OrderDetails11>(
            future: _orderDetailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Failed to load order details.\nError: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

              if (!snapshot.hasData) {
                return const Center(child: Text('Order not found.'));
              }

              final order = snapshot.data!;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Items Ordered'),
                    ...order.items.map((item) => _buildOrderItem(item, currencyState)).toList(),
                    const SizedBox(height: 24),
                    _buildOrderTotals(
                      subtotal: order.subtotal,
                      shipping: order.shippingAmount,
                      discount: order.discountAmount, // Pass the discount amount
                      couponCode: order.couponCode,
                      grandTotal: order.grandTotal,
                      currencyCode: order.currencyCode,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }


  // --- Helper widgets remain unchanged ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem11 item, CurrencyLoaded currencyState) {
    // Conversion rate for selected currency
    final conversionRate = currencyState.selectedRate.rate;
    final symbol = currencyState.selectedSymbol;

    print('Current Symbol: $symbol');
    print('Conversion Rate: $conversionRate');
    print('Original Price: ${item.price}');

    // Convert price and subtotal
    final convertedPrice = item.price * conversionRate;
    final convertedSubtotal = item.price * item.qty * conversionRate;

    print('Converted Price: $convertedPrice');
    print('Converted Subtotal: $convertedSubtotal');

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: item.imageUrl.isNotEmpty
                      ? Image.network(item.imageUrl, fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                      const Icon(Icons.image, size: 40, color: Colors.grey))
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('SKU: ${item.sku}',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      // Display converted price with the selected symbol
                      Text('Price: $symbol${convertedPrice.toStringAsFixed(2)}'),
                      Text('Qty: ${item.qty}'),
                      // Display converted subtotal with the selected symbol
                      Text('Subtotal: $symbol${convertedSubtotal.toStringAsFixed(2)}'),
                      Text('Status: ${item.status}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
          ],
        ),
      ),
    );
  }



  // Widget _buildStatusTracker({required String currentStatus}) {
  //   final statuses = ['In Production', 'Quality Control', 'Shipped', 'Custom Clearance', 'Delivered'];
  //   int activeIndex = -1;
  //   String normalizedStatus = currentStatus.toLowerCase();
  //
  //   if (normalizedStatus.contains('pending')) activeIndex = 0;
  //   else if (normalizedStatus.contains('processing')) activeIndex = 1;
  //   else if (normalizedStatus.contains('shipped')) activeIndex = 2;
  //   else if (normalizedStatus.contains('delivered') || normalizedStatus.contains('complete')) activeIndex = 4;
  //   else activeIndex = 0; // fallback
  //
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: List.generate(statuses.length, (index) {
  //         final isCompleted = index < activeIndex;
  //         final isActive = index == activeIndex;
  //         final color = isCompleted || isActive ? Colors.green : Colors.grey;
  //
  //         return Row(
  //           children: [
  //             Column(
  //               children: [
  //                 Icon(Icons.check_circle, color: color, size: 30),
  //                 const SizedBox(height: 4),
  //                 Text(
  //                   statuses[index],
  //                   style: TextStyle(fontSize: 12, color: color, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
  //                 ),
  //               ],
  //             ),
  //             if (index < statuses.length - 1)
  //               Container(
  //                 width: 30,
  //                 height: 2,
  //                 color: isCompleted ? Colors.green : Colors.grey[300],
  //                 margin: const EdgeInsets.symmetric(horizontal: 4),
  //               ),
  //           ],
  //         );
  //       }),
  //     ),
  //   );
  // }
  Widget _buildOrderTotals({
    required double subtotal,
    required double shipping,
    required double discount,      // ✅ Add discount parameter
    required String couponCode,   // ✅ Add couponCode parameter
    required double grandTotal,
    required String currencyCode,
  }) {
    final symbol = getCurrencySymbol(currencyCode);

    return Column(
      children: [
        _buildSummaryRow('Subtotal', '$symbol${subtotal.toStringAsFixed(2)}'),

        // ✅ START: ADD CONDITIONAL DISCOUNT ROW
        // This 'if' block ensures the row only appears if there's a discount.
        if (discount > 0)
          _buildSummaryRow(
            'Discount ($couponCode)', // Display coupon code in the label
            '-$symbol${discount.toStringAsFixed(2)}', // Display as a negative value
            color: Colors.black, // Optional: Style the discount text
          ),
        // ✅ END: ADD CONDITIONAL DISCOUNT ROW

        _buildSummaryRow('Shipping & Handling', '$symbol${shipping.toStringAsFixed(2)}'),
        _buildSummaryRow('Duties and Taxes', '${symbol}0.00'),
        const Divider(height: 20),
        _buildSummaryRow('Grand Total', '$symbol${grandTotal.toStringAsFixed(2)}',
            isBold: true),
      ],
    );
  }

  // Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: const TextStyle(fontSize: 16)),
  //         Text(
  //           value,
  //           style: TextStyle(
  //             fontSize: isBold ? 18 : 16,
  //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _buildSummaryRow(String label, String value, {bool isBold = false, Color? color}) {
    final defaultTextStyle = TextStyle(
      fontSize: isBold ? 18 : 16,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: defaultTextStyle.copyWith(color: color)),
          Text(
            value,
            style: defaultTextStyle.copyWith(color: color),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoBlock({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// class OrderHistoryDetails extends StatelessWidget {
//   final Order order;
//
//   const OrderHistoryDetails({super.key, required this.order});
//
//   // Helper function to format the date string, making it more readable.
//   String _formatDate(String dateTimeString) {
//     try {
//       final date = DateTime.parse(dateTimeString);
//       // Example format: June 12, 2025
//       const monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
//       return "${monthNames[date.month - 1]} ${date.day}, ${date.year}";
//     } catch (e) {
//       return dateTimeString.split(' ').first; // Fallback
//     }
//   }
//
//   // Helper to parse and format the multi-line shipping address.
//   // Input: "mitesh desai, , mum, 400000, AU"
//   // Output: "mitesh desai\nmum\n400000\nAU"
//   String _formatAddress(String addressString) {
//     return addressString
//         .split(',') // Split the string by commas
//         .map((part) => part.trim()) // Remove leading/trailing whitespace
//         .where((part) => part.isNotEmpty) // Filter out any empty parts
//         .join('\n'); // Join the remaining parts with a newline
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Order #${order.incrementId}"),
//         centerTitle: true,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16.0),
//         children: [
//           // --- Card for Order Information ---
//           _buildInfoCard(
//             context: context,
//             title: 'Order Information',
//             children: [
//               _buildDetailRow(label: 'Order #', value: order.incrementId),
//               _buildDetailRow(label: 'Order Date', value: _formatDate(order.createdAt)),
//               _buildDetailRow(label: 'Status', value: order.status),
//               _buildDetailRow(
//                 label: 'Order Total',
//                 value: '₹${order.grandTotal.toStringAsFixed(2)}',
//                 valueIsBold: true,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // --- Card for Shipping Information ---
//           _buildInfoCard(
//             context: context,
//             title: 'Shipping Information',
//             children: [
//               _buildDetailRow(label: 'Ship To', value: _formatAddress(order.shipTo)),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           // --- Card for Billing Information (can be added later) ---
//           // _buildInfoCard(
//           //   context: context,
//           //   title: 'Billing Information',
//           //   children: [
//           //     _buildDetailRow(label: 'Billing Address', value: 'Same as shipping'),
//           //     _buildDetailRow(label: 'Payment Method', value: 'Credit Card'),
//           //   ],
//           // ),
//           // const SizedBox(height: 20),
//
//           // --- Placeholder for Items List ---
//           _buildInfoCard(
//             context: context,
//             title: 'Items Ordered',
//             children: [
//               // You would typically have another ListView or Column here
//               // populated with the items from your order object.
//               const Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8.0),
//                 child: Text(
//                   'Item details functionality will be added here.',
//                   style: TextStyle(color: Colors.grey),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// A reusable widget to create a consistent card layout for information sections.
//   Widget _buildInfoCard({
//     required BuildContext context,
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const Divider(height: 20, thickness: 1),
//             ...children,
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// A reusable widget to display a labeled piece of information, keeping the UI consistent.
//   Widget _buildDetailRow({
//     required String label,
//     required String value,
//     bool valueIsBold = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: const TextStyle(
//               fontSize: 15,
//               color: Colors.black54,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               value,
//               textAlign: TextAlign.end,
//               style: TextStyle(
//                 fontSize: 15,
//                 fontWeight: valueIsBold ? FontWeight.bold : FontWeight.normal,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }