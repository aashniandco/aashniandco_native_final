import 'package:aashniandco/features/profile/view/order_history_details.dart';
import 'package:flutter/material.dart';

import '../../Payment/repositories/order_repository.dart';
import '../model/order_history.dart';
import '../repository/order_history_repository.dart';

// lib/features/order/view/orders_screen.dart

import 'package:flutter/material.dart';
import '../model/order_history.dart';
import '../repository/order_history_repository.dart';
 // Import the new details screen

import 'package:flutter/material.dart';
import '../model/order_history.dart';
import '../repository/order_history_repository.dart';
import 'order_history_details.dart'; // Make sure this import is correct

import 'package:flutter/material.dart';
 // Make sure this path is correct
import '../repository/order_history_repository.dart';
import 'order_history_details.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderHistoryRepository _orderRepository = OrderHistoryRepository();
  late Future<List<OrderSummary>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderRepository.fetchOrders();
  }

  String _formatDate(String dateTimeString) {
    try {
      final date = DateTime.parse(dateTimeString);
      return "${date.month}/${date.day}/${date.year.toString().substring(2)}";
    } catch (e) {
      return dateTimeString.split(' ').first;
    }
  }

  // ✅ THIS IS THE CORRECTED NAVIGATION FUNCTION
  void _navigateToDetails(OrderSummary order) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => OrderHistoryDetails(
          orderId: order.id,
          incrementId: order.incrementId,
        ),
      ),
    );
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: FutureBuilder<List<OrderSummary>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Could not load orders.\nPlease check your connection and try again.\n\nError: ${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found"));
          }

          final orders = snapshot.data!;
          orders.sort((a, b) => b.incrementId.compareTo(a.incrementId));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  onTap: () => _navigateToDetails(order), // This now calls the corrected function
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Order #${order.incrementId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _formatDate(order.createdAt),
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text.rich(
                          TextSpan(
                            text: 'Ship To: ',
                            style: TextStyle(color: Colors.grey.shade700),
                            children: [
                              TextSpan(
                                text: order.shipTo.split(',').first,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text.rich(
                          TextSpan(
                            text: 'Order Total: ',
                            style: TextStyle(color: Colors.grey.shade700),
                            children: [
                              TextSpan(
                          text: "${getCurrencySymbol(order.currencyCode)}${order.grandTotal.toStringAsFixed(2)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // TextButton(
                            //   onPressed: () {
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(content: Text('Reorder feature coming soon!')),
                            //     );
                            //   },
                            //   child: const Text('Reorder'),
                            // ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _navigateToDetails(order),
                              child: const Text('View Order'),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
