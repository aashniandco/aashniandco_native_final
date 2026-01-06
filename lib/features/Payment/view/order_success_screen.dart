
import 'dart:convert';
import 'dart:io';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:http/http.dart' as http;

import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../categories/repository/api_service.dart';
import '../../profile/model/order_history.dart';
import '../../profile/repository/order_history_repository.dart';
import '../../shoppingbag/cart_bloc/cart_bloc.dart';
import '../../shoppingbag/cart_bloc/cart_event.dart';
import '../bloc/order_details_bloc.dart';
import '../bloc/order_details_event.dart';
import '../bloc/order_details_state.dart';
import '../model/order_details_model.dart';
import '../repositories/order_repository.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- PLACEHOLDER IMPORTS (Adjust these to your actual project file paths) ---
     // Your Authentication screen

// --- END PLACEHOLDERS ---


class OrderSuccessScreen extends StatefulWidget {
  // These are the parameters passed from your checkout screen
  final int orderId;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> billingAddress;
  final List<dynamic> items;
  final String paymentMethodCode;
  final String? guestEmail;

  const OrderSuccessScreen({
    Key? key,
    required this.orderId,
    required this.totals,
    required this.billingAddress,
    required this.items,
    required this.paymentMethodCode,
    this.guestEmail, // optional
  }) : super(key: key);

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  // This state holds the fully constructed OrderDetails object.
  late final OrderDetails order;
  OrderDetails11? _fetchedOrderDetails; // New variable for API fetched data
  bool _isLoadingFetchedOrder = true;
  String? _errorMessage;

  // ❌ Image fetching logic is REMOVED from this state.
  // It now lives inside each individual OrderItemCard.

// Example if OrderHistoryRepository already exists and has this method:
  final OrderHistoryRepository _orderHistoryRepository = OrderHistoryRepository();

  final CartRepository _cartRepository= CartRepository();
  @override
  void initState() {
    super.initState();
    // This part is correct: construct the order details object from widget parameters.
    order = OrderDetails.fromCheckoutData(
      orderId: widget.orderId,
      totalsData: widget.totals,
      billingAddressData: widget.billingAddress,
      cartItems: widget.items,
      paymentMethodCode: widget.paymentMethodCode,
    );



    _fetchFullOrderDetails();
    // Clear the user's cart after the order is successful.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CartBloc>().add(FetchCartItems());
      }
    });
  }

  // ✅ NEW METHOD: Displays addresses directly from the API response string
  Widget _buildAddressesFromApi(BuildContext context, String shippingStr, String billingStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAddressColumnString(context, 'Shipping Address', shippingStr)),
        const SizedBox(width: 16),
        Expanded(child: _buildAddressColumnString(context, 'Billing Address', billingStr)),
      ],
    );
  }

  Widget _buildAddressColumnString(BuildContext context, String title, String address) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
        const SizedBox(height: 12),
        // The API usually returns address with \n newlines, Text widget handles this automatically
        Text(address, style: bodyStyle),
      ],
    );
  }

  // ✅ NEW METHOD: Displays methods directly from the API response string
  Widget _buildMethodsFromApi(BuildContext context, String shippingMethod, String paymentMethod) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(paymentMethod, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
  Future<void> _fetchFullOrderDetails() async {
    setState(() {
      _isLoadingFetchedOrder = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final savedEmail = prefs.getString('user_email');

      OrderDetails11 result;

      if (token == null) {
        // Guest order
        if (savedEmail == null || savedEmail.isEmpty) {
          throw Exception("Guest email not provided");
        }
        print("Fetching guest order for email: $savedEmail");

        // Step 1: Get guest quote ID (from local storage)
        final guestQuoteId = prefs.getString('guest_quote_id');
        if (guestQuoteId == null || guestQuoteId.isEmpty) {
          throw Exception("Guest quote ID not found");
        }
        print("Guest Quote ID: $guestQuoteId");

        // Step 2: Fetch guest cart to get reserved_order_id (increment_id)
        final guestCart = await _cartRepository.fetchGuestCart(guestQuoteId);
        final incrementId = guestCart['reserved_order_id'];
        if (incrementId == null || incrementId.isEmpty) {
          throw Exception("Failed to get reserved_order_id from guest cart");
        }
        print("Resolved Increment ID: $incrementId");

        // Step 3: Fetch guest order using increment_id and email
        result = await _orderHistoryRepository.fetchGuestOrderDetails(
          orderIncrementId: incrementId,
          email: savedEmail,
        );

      } else {
        // Logged-in user
        print("Fetching logged-in order for order ID ${widget.orderId}");
        result = await _orderHistoryRepository.fetchOrderDetails(
          widget.orderId.toString(),
        );
      }

      if (mounted) {
        setState(() {
          _fetchedOrderDetails = result;
          _isLoadingFetchedOrder = false;
        });
      }
    } catch (e) {
      print("Error fetching order details: $e");
      if (mounted) {
        setState(() {
          _errorMessage =
          "Failed to load complete order details: ${e.toString()}";
          _isLoadingFetchedOrder = false;
        });
      }
    }
  }


  // Future<void> _fetchFullOrderDetails() async {
  //   setState(() {
  //     _isLoadingFetchedOrder = true;
  //     _errorMessage = null;
  //   });
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //
  //     OrderDetails11 result;
  //     final prefs1 = await SharedPreferences.getInstance();
  //     final savedEmail = prefs1.getString('user_email');
  //     if (token == null) {
  //       // Guest order
  //       final email = savedEmail;
  //       print("Saved Guest Email>>$email");
  //       if (email == null || email.isEmpty) {
  //         throw Exception("Guest email not provided");
  //       }
  //       print("Fetching guest order for order ID ${widget.orderId}");
  //       result = await _orderHistoryRepository.fetchGuestOrderDetails(
  //         orderIncrementId: widget.orderId.toString(),
  //         email: email,
  //       );
  //     } else {
  //       // Logged-in user
  //       print("Fetching logged-in order for order ID ${widget.orderId}");
  //       result = await _orderHistoryRepository.fetchOrderDetails(
  //         widget.orderId.toString(),
  //       );
  //     }
  //
  //     if (mounted) {
  //       setState(() {
  //         _fetchedOrderDetails = result;
  //         _isLoadingFetchedOrder = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching order details: $e");
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage =
  //         "Failed to load complete order details: ${e.toString()}";
  //         _isLoadingFetchedOrder = false;
  //       });
  //     }
  //   }
  // }


  // Future<void> _fetchFullOrderDetails() async {
  //   setState(() {
  //     _isLoadingFetchedOrder = true;
  //     _errorMessage = null;
  //   });
  //
  //   try {
  //     // Assuming your OrderHistoryRepository has the fetchOrderDetails method
  //     final result = await _orderHistoryRepository.fetchOrderDetails(widget.orderId.toString());
  //     if (mounted) {
  //       setState(() {
  //         _fetchedOrderDetails = result;
  //         _isLoadingFetchedOrder = false;
  //       });
  //     }
  //   } catch (e) {
  //     print("Error fetching full order details from API: $e");
  //     if (mounted) {
  //       setState(() {
  //         _errorMessage = "Failed to load complete order details: ${e.toString()}";
  //         _isLoadingFetchedOrder = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double currencyRate = 1.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      currencyRate = currencyState.selectedRate.rate;
    }

    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: currencyState is CurrencyLoaded ? currencyState.selectedLocale : 'en_IN',
      symbol: displaySymbol,
      decimalDigits: 2,
    );

    // --- LOADING STATE ---
    if (_isLoadingFetchedOrder) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Loading order details for order ID: ${widget.orderId}...'),
            ],
          ),
        ),
      );
    }

    // --- ERROR STATE ---
    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchFullOrderDetails, // Retry fetching
                  child: const Text('RETRY'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If we reach here, _fetchedOrderDetails should not be null.
    // Add a null check for safety, though the above logic should prevent it.
    if (_fetchedOrderDetails == null) {
      return Scaffold(
        body: Center(
          child: Text('Order details could not be loaded.'),
        ),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, _fetchedOrderDetails!.incrementId),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildOrderDetails(context, order.orderDate),
                const SizedBox(height: 24),
                Text('Order Information', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
                const SizedBox(height: 24),
                // _buildAddresses(context, order.shippingAddress, order.billingAddress),
                _buildAddresses( // Now takes Strings
                    context,
                    _fetchedOrderDetails!.shipTo,
                    _fetchedOrderDetails!.billingAddress
                ),

                const SizedBox(height: 24),
                // _buildMethods(context, order.shippingMethod, order.paymentMethod),
                _buildMethods( // Now takes Strings
                    context,
                    _fetchedOrderDetails!.shippingMethod,
                    _fetchedOrderDetails!.paymentMethod
                ),
                const SizedBox(height: 32),
                _buildItemsOrdered(context, order.items, currencyRate, currencyFormat)
                ,
                const SizedBox(height: 32),
                _buildTotals(context, order.totals, currencyRate, currencyFormat,  couponCode: order.totals.couponCode,)
                ,
                const SizedBox(height: 48),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen()),
                            (Route<dynamic> route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('CONTINUE SHOPPING'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets for the Main Screen ---

  Widget _buildHeader(BuildContext context, String orderNumber) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thank you for your purchase!',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
            children: [
              const TextSpan(text: 'Your order number is: '),
              TextSpan(
                text: orderNumber,  // <-- Pass increment_id here
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "We'll email you an order confirmation with details and tracking info.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }


  Widget _buildItemsOrdered(
      BuildContext context,
      List<OrderItem> items,
      double currencyRate,           // 👈 add back
      NumberFormat currencyFormat,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items Ordered',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Column(
          children: items.map((item) {
            return OrderItemCard(
              item: item,
              currencyRate: currencyRate,
              currencyFormat: currencyFormat,
            );
          }).toList(),
        ),
      ],
    );
  }



  Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
    String formattedDate = orderDateStr;
    try {
      final dateTime = DateTime.parse(orderDateStr);
      formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
    } catch (_) {}

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  // Used for displaying the Address text received from the API
  Widget _buildAddresses(BuildContext context, String shippingStr, String billingStr) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildAddressColumn(context, 'Shipping Address', shippingStr)),
        const SizedBox(width: 16),
        Expanded(child: _buildAddressColumn(context, 'Billing Address', billingStr)),
      ],
    );
  }

  // Used for styling the address text
  Widget _buildAddressColumn(BuildContext context, String title, String address) {
    final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
        const SizedBox(height: 12),
        // API returns data with newlines (\n), so we just display it directly
        Text(address, style: bodyStyle),
      ],
    );
  }

  // Used for displaying method names received from the API
  Widget _buildMethods(BuildContext context, String shippingMethod, String paymentMethod) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 12),
              Text(paymentMethod, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
  // Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
  //       const SizedBox(width: 16),
  //       Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
  //     ],
  //   );
  // }
  //
  // Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
  //   if (address == null) return const SizedBox.shrink();
  //   final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //       const SizedBox(height: 12),
  //       Text(address.name, style: bodyStyle),
  //       Text(address.street, style: bodyStyle),
  //       Text(address.cityPostcode, style: bodyStyle),
  //       Text(address.country, style: bodyStyle),
  //       Text(address.telephone, style: bodyStyle),
  //     ],
  //   );
  // }
  //
  // Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //             const SizedBox(height: 12),
  //             Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //             const SizedBox(height: 12),
  //             Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTotals(
      BuildContext context,
      Totals totals,
      double currencyRate,
      NumberFormat currencyFormat, {
        String? couponCode, // ✅ Correctly placed inside braces
      }) {
    final textStyle = Theme.of(context).textTheme.bodyLarge;
    final grandTotalStyle =
    textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);

    // Apply currency conversion before formatting
    final convertedSubtotal = totals.subtotal * currencyRate;
    final convertedShipping = totals.shipping * currencyRate;
    final convertedDiscount = totals.discount * currencyRate;
    final convertedGrandTotal = totals.grandTotal * currencyRate;

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 300,
        child: Column(
          children: [
            _buildKeyValueRow(
              'Subtotal',
              currencyFormat.format(convertedSubtotal),
              context: context,
              style: textStyle,
            ),
            const SizedBox(height: 8),
            _buildKeyValueRow(
              'Shipping & Handling',
              currencyFormat.format(convertedShipping),
              context: context,
              style: textStyle,
            ),

            // ✅ Conditional Discount Row with Coupon Code
            if (totals.discount > 0) ...[
              const SizedBox(height: 8),
              _buildKeyValueRow(
                couponCode != null && couponCode.isNotEmpty
                    ? 'Discount ($couponCode)'
                    : 'Discount',
                '-${currencyFormat.format(convertedDiscount)}',
                context: context,
                style: textStyle?.copyWith(color: Colors.black),
              ),
            ],

            const Divider(height: 24, thickness: 1),
            _buildKeyValueRow(
              'Grand Total',
              currencyFormat.format(convertedGrandTotal),
              context: context,
              style: grandTotalStyle,
            ),
          ],
        ),
      ),
    );
  }

//stage*
  // Widget _buildTotals(
  //     BuildContext context,
  //     Totals totals,
  //     double currencyRate,
  //     NumberFormat currencyFormat,
  //     ) {
  //   final textStyle = Theme.of(context).textTheme.bodyLarge;
  //   final grandTotalStyle =
  //   textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
  //
  //   // Apply currency conversion before formatting
  //   final convertedSubtotal = totals.subtotal * currencyRate;
  //   final convertedShipping = totals.shipping * currencyRate;
  //   final convertedDiscount = totals.discount * currencyRate; // Convert the discount
  //   final convertedGrandTotal = totals.grandTotal * currencyRate;
  //
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       width: 300,
  //       child: Column(
  //         children: [
  //           _buildKeyValueRow(
  //             'Subtotal',
  //             currencyFormat.format(convertedSubtotal),
  //             context: context,
  //             style: textStyle,
  //           ),
  //           const SizedBox(height: 8),
  //           _buildKeyValueRow(
  //             'Shipping & Handling',
  //             currencyFormat.format(convertedShipping),
  //             context: context,
  //             style: textStyle,
  //           ),
  //
  //           // ✅ START: ADD CONDITIONAL DISCOUNT ROW
  //           // This block only appears if there was a discount.
  //           if (totals.discount > 0) ...[
  //             const SizedBox(height: 8),
  //             _buildKeyValueRow(
  //               'Discount',
  //               // Display as a negative value, e.g., "-₹86.21"
  //               '-${currencyFormat.format(convertedDiscount)}',
  //               context: context,
  //               // Style it to stand out
  //               style: textStyle?.copyWith(color: Colors.black),
  //             ),
  //           ],
  //           // ✅ END: ADD CONDITIONAL DISCOUNT ROW
  //
  //           const Divider(height: 24, thickness: 1),
  //           _buildKeyValueRow(
  //             'Grand Total',
  //             currencyFormat.format(convertedGrandTotal),
  //             context: context,
  //             style: grandTotalStyle,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTotals(
  //     BuildContext context,
  //     Totals totals,
  //     double currencyRate,          // 👈 add currencyRate here
  //     NumberFormat currencyFormat,
  //     ) {
  //   final textStyle = Theme.of(context).textTheme.bodyLarge;
  //   final grandTotalStyle =
  //   textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
  //
  //   // Apply currency conversion before formatting
  //   final convertedSubtotal = totals.subtotal * currencyRate;
  //   final convertedShipping = totals.shipping * currencyRate;
  //   final convertedGrandTotal = totals.grandTotal * currencyRate;
  //
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       width: 300,
  //       child: Column(
  //         children: [
  //           _buildKeyValueRow(
  //             'Subtotal',
  //             currencyFormat.format(convertedSubtotal),
  //             context: context,
  //             style: textStyle,
  //           ),
  //           const SizedBox(height: 8),
  //           _buildKeyValueRow(
  //             'Shipping & Handling',
  //             currencyFormat.format(convertedShipping),
  //             context: context,
  //             style: textStyle,
  //           ),
  //           const Divider(height: 24, thickness: 1),
  //           _buildKeyValueRow(
  //             'Grand Total',
  //             currencyFormat.format(convertedGrandTotal),
  //             context: context,
  //             style: grandTotalStyle,
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



  Widget _buildKeyValueRow(String label, String value, {required BuildContext context, TextStyle? style}) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    return Row(
      children: [
        Expanded(child: Text(label, style: effectiveStyle)),
        Text(value, style: effectiveStyle),
      ],
    );
  }
}

// =========================================================================
// ✅ NEW STATEFUL WIDGET FOR DISPLAYING A SINGLE ORDER ITEM WITH ITS IMAGE
// =========================================================================
class OrderItemCard extends StatefulWidget {
  final OrderItem item;
  final double currencyRate;
  final NumberFormat currencyFormat;

  const OrderItemCard({
    Key? key,
    required this.item,
    required this.currencyRate,
    required this.currencyFormat,
  }) : super(key: key);

  @override
  State<OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<OrderItemCard> {
  final ApiService _apiService = ApiService();
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductImage();
  }

  Future<void> _fetchProductImage() async {
    final String fullSku = widget.item.sku;
    // Extract the base SKU (e.g., "ABC-123" from "ABC-123-Small")
    final String baseSku = fullSku.split('-').first.trim();

    try {
      final images = await _apiService.fetchProductImages(baseSku);
      if (mounted) {
        setState(() {
          if (images.isNotEmpty) {
            _imageUrl = images.first.imageUrl;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching image for order item SKU $baseSku: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final item = widget.item;
    final convertedPrice = item.price * widget.currencyRate;
    final convertedSubtotal = item.subtotal * widget.currencyRate;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 80,
                height: 100,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: _isLoading
                      ? Container(color: Colors.grey[200]) // Placeholder while loading
                      : _imageUrl != null
                      ? CachedNetworkImage(
                    imageUrl: _imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  )
                      : Container( // Fallback if no image found
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (item.options.isNotEmpty) ...[
                      Text(item.options, style: textTheme.bodyMedium),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'SKU: ${item.sku}',
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric('Price', widget.currencyFormat.format(convertedPrice), context),
              _buildMetric('Qty', item.qty.toString(), context),
              _buildMetric('Subtotal', widget.currencyFormat.format(convertedSubtotal), context, isBold: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }


}
//8/12/2025
// class OrderSuccessScreen extends StatefulWidget {
//   // These are the parameters passed from your checkout screen
//   final int orderId;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final List<dynamic> items;
//   final String paymentMethodCode;
//   final String? guestEmail;
//
//   const OrderSuccessScreen({
//     Key? key,
//     required this.orderId,
//     required this.totals,
//     required this.billingAddress,
//     required this.items,
//     required this.paymentMethodCode,
//     this.guestEmail, // optional
//   }) : super(key: key);
//
//   @override
//   State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
// }
//
// class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
//   // This state holds the fully constructed OrderDetails object.
//   late final OrderDetails order;
//   OrderDetails11? _fetchedOrderDetails; // New variable for API fetched data
//   bool _isLoadingFetchedOrder = true;
//   String? _errorMessage;
//
//   // ❌ Image fetching logic is REMOVED from this state.
//   // It now lives inside each individual OrderItemCard.
//
// // Example if OrderHistoryRepository already exists and has this method:
//   final OrderHistoryRepository _orderHistoryRepository = OrderHistoryRepository();
//
//   final CartRepository _cartRepository= CartRepository();
//   @override
//   void initState() {
//     super.initState();
//     // This part is correct: construct the order details object from widget parameters.
//     order = OrderDetails.fromCheckoutData(
//       orderId: widget.orderId,
//       totalsData: widget.totals,
//       billingAddressData: widget.billingAddress,
//       cartItems: widget.items,
//       paymentMethodCode: widget.paymentMethodCode,
//     );
//
//
//
//     _fetchFullOrderDetails();
//     // Clear the user's cart after the order is successful.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         context.read<CartBloc>().add(FetchCartItems());
//       }
//     });
//   }
//
//   Future<void> _fetchFullOrderDetails() async {
//     setState(() {
//       _isLoadingFetchedOrder = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//       final savedEmail = prefs.getString('user_email');
//
//       OrderDetails11 result;
//
//       if (token == null) {
//         // Guest order
//         if (savedEmail == null || savedEmail.isEmpty) {
//           throw Exception("Guest email not provided");
//         }
//         print("Fetching guest order for email: $savedEmail");
//
//         // Step 1: Get guest quote ID (from local storage)
//         final guestQuoteId = prefs.getString('guest_quote_id');
//         if (guestQuoteId == null || guestQuoteId.isEmpty) {
//           throw Exception("Guest quote ID not found");
//         }
//         print("Guest Quote ID: $guestQuoteId");
//
//         // Step 2: Fetch guest cart to get reserved_order_id (increment_id)
//         final guestCart = await _cartRepository.fetchGuestCart(guestQuoteId);
//         final incrementId = guestCart['reserved_order_id'];
//         if (incrementId == null || incrementId.isEmpty) {
//           throw Exception("Failed to get reserved_order_id from guest cart");
//         }
//         print("Resolved Increment ID: $incrementId");
//
//         // Step 3: Fetch guest order using increment_id and email
//         result = await _orderHistoryRepository.fetchGuestOrderDetails(
//           orderIncrementId: incrementId,
//           email: savedEmail,
//         );
//
//       } else {
//         // Logged-in user
//         print("Fetching logged-in order for order ID ${widget.orderId}");
//         result = await _orderHistoryRepository.fetchOrderDetails(
//           widget.orderId.toString(),
//         );
//       }
//
//       if (mounted) {
//         setState(() {
//           _fetchedOrderDetails = result;
//           _isLoadingFetchedOrder = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching order details: $e");
//       if (mounted) {
//         setState(() {
//           _errorMessage =
//           "Failed to load complete order details: ${e.toString()}";
//           _isLoadingFetchedOrder = false;
//         });
//       }
//     }
//   }
//
//
//   // Future<void> _fetchFullOrderDetails() async {
//   //   setState(() {
//   //     _isLoadingFetchedOrder = true;
//   //     _errorMessage = null;
//   //   });
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //
//   //     OrderDetails11 result;
//   //     final prefs1 = await SharedPreferences.getInstance();
//   //     final savedEmail = prefs1.getString('user_email');
//   //     if (token == null) {
//   //       // Guest order
//   //       final email = savedEmail;
//   //       print("Saved Guest Email>>$email");
//   //       if (email == null || email.isEmpty) {
//   //         throw Exception("Guest email not provided");
//   //       }
//   //       print("Fetching guest order for order ID ${widget.orderId}");
//   //       result = await _orderHistoryRepository.fetchGuestOrderDetails(
//   //         orderIncrementId: widget.orderId.toString(),
//   //         email: email,
//   //       );
//   //     } else {
//   //       // Logged-in user
//   //       print("Fetching logged-in order for order ID ${widget.orderId}");
//   //       result = await _orderHistoryRepository.fetchOrderDetails(
//   //         widget.orderId.toString(),
//   //       );
//   //     }
//   //
//   //     if (mounted) {
//   //       setState(() {
//   //         _fetchedOrderDetails = result;
//   //         _isLoadingFetchedOrder = false;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error fetching order details: $e");
//   //     if (mounted) {
//   //       setState(() {
//   //         _errorMessage =
//   //         "Failed to load complete order details: ${e.toString()}";
//   //         _isLoadingFetchedOrder = false;
//   //       });
//   //     }
//   //   }
//   // }
//
//
//   // Future<void> _fetchFullOrderDetails() async {
//   //   setState(() {
//   //     _isLoadingFetchedOrder = true;
//   //     _errorMessage = null;
//   //   });
//   //
//   //   try {
//   //     // Assuming your OrderHistoryRepository has the fetchOrderDetails method
//   //     final result = await _orderHistoryRepository.fetchOrderDetails(widget.orderId.toString());
//   //     if (mounted) {
//   //       setState(() {
//   //         _fetchedOrderDetails = result;
//   //         _isLoadingFetchedOrder = false;
//   //       });
//   //     }
//   //   } catch (e) {
//   //     print("Error fetching full order details from API: $e");
//   //     if (mounted) {
//   //       setState(() {
//   //         _errorMessage = "Failed to load complete order details: ${e.toString()}";
//   //         _isLoadingFetchedOrder = false;
//   //       });
//   //     }
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double currencyRate = 1.0;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       currencyRate = currencyState.selectedRate.rate;
//     }
//
//     final NumberFormat currencyFormat = NumberFormat.currency(
//       locale: currencyState is CurrencyLoaded ? currencyState.selectedLocale : 'en_IN',
//       symbol: displaySymbol,
//       decimalDigits: 2,
//     );
//
//     // --- LOADING STATE ---
//     if (_isLoadingFetchedOrder) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 16),
//               Text('Loading order details for order ID: ${widget.orderId}...'),
//             ],
//           ),
//         ),
//       );
//     }
//
//     // --- ERROR STATE ---
//     if (_errorMessage != null) {
//       return Scaffold(
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.error_outline, color: Colors.red, size: 48),
//                 const SizedBox(height: 16),
//                 Text(
//                   _errorMessage!,
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.red),
//                 ),
//                 const SizedBox(height: 24),
//                 ElevatedButton(
//                   onPressed: _fetchFullOrderDetails, // Retry fetching
//                   child: const Text('RETRY'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     // If we reach here, _fetchedOrderDetails should not be null.
//     // Add a null check for safety, though the above logic should prevent it.
//     if (_fetchedOrderDetails == null) {
//       return Scaffold(
//         body: Center(
//           child: Text('Order details could not be loaded.'),
//         ),
//       );
//     }
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildHeader(context, _fetchedOrderDetails!.incrementId),
//                 const SizedBox(height: 24),
//                 const Divider(),
//                 const SizedBox(height: 16),
//                 _buildOrderDetails(context, order.orderDate),
//                 const SizedBox(height: 24),
//                 Text('Order Information', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
//                 const SizedBox(height: 24),
//                 _buildAddresses(context, order.shippingAddress, order.billingAddress),
//                 const SizedBox(height: 24),
//                 _buildMethods(context, order.shippingMethod, order.paymentMethod),
//                 const SizedBox(height: 32),
//                 _buildItemsOrdered(context, order.items, currencyRate, currencyFormat)
//                 ,
//                 const SizedBox(height: 32),
//                 _buildTotals(context, order.totals, currencyRate, currencyFormat,couponCode: order.totals.couponCode)
//                 ,
//                 const SizedBox(height: 48),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (_) => const AuthScreen()),
//                             (Route<dynamic> route) => false,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text('CONTINUE SHOPPING'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- Helper Widgets for the Main Screen ---
//
//   Widget _buildHeader(BuildContext context, String orderNumber) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           'Thank you for your purchase!',
//           style: Theme.of(context).textTheme.headlineSmall,
//         ),
//         const SizedBox(height: 24),
//         RichText(
//           text: TextSpan(
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
//             children: [
//               const TextSpan(text: 'Your order number is: '),
//               TextSpan(
//                 text: orderNumber,  // <-- Pass increment_id here
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "We'll email you an order confirmation with details and tracking info.",
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
//
//
//   Widget _buildItemsOrdered(
//       BuildContext context,
//       List<OrderItem> items,
//       double currencyRate,           // 👈 add back
//       NumberFormat currencyFormat,
//       ) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Items Ordered',
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         Column(
//           children: items.map((item) {
//             return OrderItemCard(
//               item: item,
//               currencyRate: currencyRate,
//               currencyFormat: currencyFormat,
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
//
//
//
//   Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
//     String formattedDate = orderDateStr;
//     try {
//       final dateTime = DateTime.parse(orderDateStr);
//       formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
//     } catch (_) {}
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
//       ],
//     );
//   }
//
//   Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
//         const SizedBox(width: 16),
//         Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
//       ],
//     );
//   }
//
//   Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
//     if (address == null) return const SizedBox.shrink();
//     final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//         const SizedBox(height: 12),
//         Text(address.name, style: bodyStyle),
//         Text(address.street, style: bodyStyle),
//         Text(address.cityPostcode, style: bodyStyle),
//         Text(address.country, style: bodyStyle),
//         Text(address.telephone, style: bodyStyle),
//       ],
//     );
//   }
//
//   Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTotals(
//       BuildContext context,
//       Totals totals,
//       double currencyRate,
//       NumberFormat currencyFormat, {
//         String? couponCode, // ✅ Correctly placed inside braces
//       }) {
//     final textStyle = Theme.of(context).textTheme.bodyLarge;
//     final grandTotalStyle =
//     textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
//
//     // Apply currency conversion before formatting
//     final convertedSubtotal = totals.subtotal * currencyRate;
//     final convertedShipping = totals.shipping * currencyRate;
//     final convertedDiscount = totals.discount * currencyRate;
//     final convertedGrandTotal = totals.grandTotal * currencyRate;
//
//     return Align(
//       alignment: Alignment.centerRight,
//       child: SizedBox(
//         width: 300,
//         child: Column(
//           children: [
//             _buildKeyValueRow(
//               'Subtotal',
//               currencyFormat.format(convertedSubtotal),
//               context: context,
//               style: textStyle,
//             ),
//             const SizedBox(height: 8),
//             _buildKeyValueRow(
//               'Shipping & Handling',
//               currencyFormat.format(convertedShipping),
//               context: context,
//               style: textStyle,
//             ),
//
//             // ✅ Conditional Discount Row with Coupon Code
//             if (totals.discount > 0) ...[
//               const SizedBox(height: 8),
//               _buildKeyValueRow(
//                 couponCode != null && couponCode.isNotEmpty
//                     ? 'Discount ($couponCode)'
//                     : 'Discount',
//                 '-${currencyFormat.format(convertedDiscount)}',
//                 context: context,
//                 style: textStyle?.copyWith(color: Colors.black),
//               ),
//             ],
//
//             const Divider(height: 24, thickness: 1),
//             _buildKeyValueRow(
//               'Grand Total',
//               currencyFormat.format(convertedGrandTotal),
//               context: context,
//               style: grandTotalStyle,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   //live*
//   // Widget _buildTotals(
//   //     BuildContext context,
//   //     Totals totals,
//   //     double currencyRate,          // 👈 add currencyRate here
//   //     NumberFormat currencyFormat,
//   //     ) {
//   //   final textStyle = Theme.of(context).textTheme.bodyLarge;
//   //   final grandTotalStyle =
//   //   textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
//   //
//   //   // Apply currency conversion before formatting
//   //   final convertedSubtotal = totals.subtotal * currencyRate;
//   //   final convertedShipping = totals.shipping * currencyRate;
//   //   final convertedGrandTotal = totals.grandTotal * currencyRate;
//   //
//   //   return Align(
//   //     alignment: Alignment.centerRight,
//   //     child: SizedBox(
//   //       width: 300,
//   //       child: Column(
//   //         children: [
//   //           _buildKeyValueRow(
//   //             'Subtotal',
//   //             currencyFormat.format(convertedSubtotal),
//   //             context: context,
//   //             style: textStyle,
//   //           ),
//   //           const SizedBox(height: 8),
//   //           _buildKeyValueRow(
//   //             'Shipping & Handling',
//   //             currencyFormat.format(convertedShipping),
//   //             context: context,
//   //             style: textStyle,
//   //           ),
//   //           const Divider(height: 24, thickness: 1),
//   //           _buildKeyValueRow(
//   //             'Grand Total',
//   //             currencyFormat.format(convertedGrandTotal),
//   //             context: context,
//   //             style: grandTotalStyle,
//   //           ),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//
//
//   Widget _buildKeyValueRow(String label, String value, {required BuildContext context, TextStyle? style}) {
//     final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
//     return Row(
//       children: [
//         Expanded(child: Text(label, style: effectiveStyle)),
//         Text(value, style: effectiveStyle),
//       ],
//     );
//   }
// }
//
// // =========================================================================
// // ✅ NEW STATEFUL WIDGET FOR DISPLAYING A SINGLE ORDER ITEM WITH ITS IMAGE
// // =========================================================================
// class OrderItemCard extends StatefulWidget {
//   final OrderItem item;
//   final double currencyRate;
//   final NumberFormat currencyFormat;
//
//   const OrderItemCard({
//     Key? key,
//     required this.item,
//     required this.currencyRate,
//     required this.currencyFormat,
//   }) : super(key: key);
//
//   @override
//   State<OrderItemCard> createState() => _OrderItemCardState();
// }
//
// class _OrderItemCardState extends State<OrderItemCard> {
//   final ApiService _apiService = ApiService();
//   String? _imageUrl;
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchProductImage();
//   }
//
//   Future<void> _fetchProductImage() async {
//     final String fullSku = widget.item.sku;
//     // Extract the base SKU (e.g., "ABC-123" from "ABC-123-Small")
//     final String baseSku = fullSku.split('-').first.trim();
//
//     try {
//       final images = await _apiService.fetchProductImages(baseSku);
//       if (mounted) {
//         setState(() {
//           if (images.isNotEmpty) {
//             _imageUrl = images.first.imageUrl;
//           }
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print("Error fetching image for order item SKU $baseSku: $e");
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     final item = widget.item;
//     final convertedPrice = item.price * widget.currencyRate;
//     final convertedSubtotal = item.subtotal * widget.currencyRate;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 80,
//                 height: 100,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4.0),
//                   child: _isLoading
//                       ? Container(color: Colors.grey[200]) // Placeholder while loading
//                       : _imageUrl != null
//                       ? CachedNetworkImage(
//                     imageUrl: _imageUrl!,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(color: Colors.grey[200]),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                     ),
//                   )
//                       : Container( // Fallback if no image found
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     if (item.options.isNotEmpty) ...[
//                       Text(item.options, style: textTheme.bodyMedium),
//                       const SizedBox(height: 4),
//                     ],
//                     Text(
//                       'SKU: ${item.sku}',
//                       style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildMetric('Price', widget.currencyFormat.format(convertedPrice), context),
//               _buildMetric('Qty', item.qty.toString(), context),
//               _buildMetric('Subtotal', widget.currencyFormat.format(convertedSubtotal), context, isBold: true),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
//     final textTheme = Theme.of(context).textTheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: textTheme.bodyMedium?.copyWith(
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//
//
// }

//22/8/2025
// class OrderSuccessScreen extends StatefulWidget {
//   // These are the parameters passed from your checkout screen
//   final int orderId;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final List<dynamic> items;
//   final String paymentMethodCode;
//
//   const OrderSuccessScreen({
//     Key? key,
//     required this.orderId,
//     required this.totals,
//     required this.billingAddress,
//     required this.items,
//     required this.paymentMethodCode,
//   }) : super(key: key);
//
//   @override
//   State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
// }
//
// class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
//   // ✅ We will hold the fully constructed OrderDetails object here.
//   // 'late final' is perfect because we initialize it once in initState and never change it.
//   late final OrderDetails order;
//
//   @override
//   // void initState() {
//   //   super.initState();
//   //   // ✅ Use your new factory constructor to build the OrderDetails object
//   //   // immediately from the widget's parameters. No network call needed!
//   //   order = OrderDetails.fromCheckoutData(
//   //     orderId: widget.orderId,
//   //     totalsData: widget.totals,
//   //     billingAddressData: widget.billingAddress,
//   //     cartItems: widget.items,
//   //   );
//   //
//   //   // ✅ Clear the user's cart now that the order is successful.
//   //   // This is done after the first frame is built to avoid state issues.
//   //   WidgetsBinding.instance.addPostFrameCallback((_) {
//   //     // Assuming you have a 'ClearCart' event or that FetchCartItems will
//   //     // result in an empty cart from the server.
//   //     context.read<CartBloc>().add(FetchCartItems());
//   //   });
//   // }
//
//   void initState() {
//     super.initState();
//     // ✅ Pass the new parameter to your factory constructor
//     order = OrderDetails.fromCheckoutData(
//       orderId: widget.orderId,
//       totalsData: widget.totals,
//       billingAddressData: widget.billingAddress,
//       cartItems: widget.items,
//       paymentMethodCode: widget.paymentMethodCode, // <--- PASS IT HERE
//     );
//
//     // ... (rest of your initState is unchanged) ...
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CartBloc>().add(FetchCartItems());
//     });
//
//   }
//
//   // ❌ The _fetchOrderDetails and _getCustomerToken methods are no longer needed for this screen.
//   // They would be used in a different screen, like an "Order History Details" page.
//
//   @override
//   Widget build(BuildContext context) {
//     final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//     // ✅ No FutureBuilder needed! The UI can be built directly
//     // because we constructed the 'order' object in initState.
//     return Scaffold(
//       body: SafeArea(
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // All your _build methods will now use the 'order' object
//                 _buildHeader(context, order.orderId),
//                 const SizedBox(height: 24),
//                 const Divider(),
//                 const SizedBox(height: 16),
//                 _buildOrderDetails(context, order.orderDate),
//                 const SizedBox(height: 24),
//                 Text('Order Information', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
//                 const SizedBox(height: 24),
//                 _buildAddresses(context, order.shippingAddress, order.billingAddress),
//                 const SizedBox(height: 24),
//                 _buildMethods(context, order.shippingMethod, order.paymentMethod),
//                 const SizedBox(height: 32),
//                 _buildItemsOrdered(context, order.items, currencyFormat),
//                 const SizedBox(height: 32),
//                 _buildTotals(context, order.totals, currencyFormat),
//                 const SizedBox(height: 48),
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(builder: (_) => AuthScreen()),
//                             (Route<dynamic> route) => false,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                     ),
//                     child: const Text('CONTINUE SHOPPING'),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // --- All your helper widgets remain unchanged ---
//   // They work perfectly with your new strongly-typed model objects.
//   // [ PASTE ALL YOUR HELPER WIDGETS HERE... _buildHeader, _buildOrderDetails, etc. ]
//
//   Widget _buildHeader(BuildContext context, String orderNumber) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Thank you for your purchase!', style: Theme.of(context).textTheme.headlineSmall),
//         const SizedBox(height: 24),
//         RichText(
//           text: TextSpan(
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
//             children: [
//               const TextSpan(text: 'Your order number is: '),
//               TextSpan(
//                 text: orderNumber,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "We'll email you an order confirmation with details and tracking info.",
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildItemsOrdered(BuildContext context, List<OrderItem> items, NumberFormat currencyFormat) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Items Ordered', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         Column(
//           children: items.map((item) => _buildOrderItemCard(context, item, currencyFormat)).toList(),
//         ),
//       ],
//     );
//   }
//   Widget _buildOrderItemCard(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
//     final textTheme = Theme.of(context).textTheme;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 80,
//                 height: 100,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4.0),
//                   // Since imageUrl might be null from cart data, provide a fallback.
//                   child: item.imageUrl != null
//                       ? CachedNetworkImage(
//                     imageUrl: item.imageUrl!,
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(color: Colors.grey[200]),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                     ),
//                   )
//                       : Container(
//                     color: Colors.grey[200],
//                     child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     if (item.options.isNotEmpty) ...[
//                       Text(item.options, style: textTheme.bodyMedium),
//                       const SizedBox(height: 4),
//                     ],
//                     Text(
//                       'SKU: ${item.sku}',
//                       style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildMetric('Price', currencyFormat.format(item.price), context),
//               _buildMetric('Qty', item.qty.toString(), context),
//               _buildMetric('Subtotal', currencyFormat.format(item.subtotal), context, isBold: true),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
//     final textTheme = Theme.of(context).textTheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: textTheme.bodyMedium?.copyWith(
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
//     String formattedDate = orderDateStr;
//     try {
//       final dateTime = DateTime.parse(orderDateStr);
//       formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
//     } catch (_) {
//       // Fallback if parsing fails
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
//       ],
//     );
//   }
//   Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
//         const SizedBox(width: 16),
//         Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
//       ],
//     );
//   }
//   Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
//     if (address == null) return const SizedBox.shrink();
//
//     final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//         const SizedBox(height: 12),
//         Text(address.name, style: bodyStyle),
//         Text(address.street, style: bodyStyle),
//         Text(address.cityPostcode, style: bodyStyle),
//         Text(address.country, style: bodyStyle),
//         Text(address.telephone, style: bodyStyle),
//       ],
//     );
//   }
//   Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
//               const Divider(height: 16),
//               _buildKeyValueRow('', paymentMethod.details, context: context),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildTotals(BuildContext context, Totals totals, NumberFormat currencyFormat) {
//     final textStyle = Theme.of(context).textTheme.bodyLarge;
//     final grandTotalStyle = textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
//
//     return Align(
//       alignment: Alignment.centerRight,
//       child: SizedBox(
//         width: 300,
//         child: Column(
//           children: [
//             _buildKeyValueRow('Subtotal', currencyFormat.format(totals.subtotal), context: context, style: textStyle),
//             const SizedBox(height: 8),
//             _buildKeyValueRow('Shipping & Handling', currencyFormat.format(totals.shipping), context: context, style: textStyle),
//             const Divider(height: 24, thickness: 1),
//             _buildKeyValueRow('Grand Total', currencyFormat.format(totals.grandTotal), context: context, style: grandTotalStyle),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildKeyValueRow(String label, String value, {
//     required BuildContext context,
//     TextStyle? style,
//   }) {
//     final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
//
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: effectiveStyle,
//           ),
//         ),
//         Text(
//           value,
//           style: effectiveStyle,
//         ),
//       ],
//     );
//   }
// }

// 18/08/2025
// class OrderSuccessScreen extends StatefulWidget {
//   // final int orderEntityId;
//   final int orderId;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final List<dynamic> items;
//
//   const OrderSuccessScreen({
//     Key? key,
//     required this.orderId,
//     // required this.orderId,
//     required this.totals,
//     required this.billingAddress,
//     required this.items,
//   }) : super(key: key);
//
//   @override
//   State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
// }
//
// class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
//   late Future<OrderDetails> _orderDetailsFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     // ✅ Start fetching the order details as soon as the screen is initialized.
//     // The Future is stored in our state variable.
//     _orderDetailsFuture = _fetchOrderDetails(widget.orderId);
//   }
//
//   Future<OrderDetails> _fetchOrderDetails(int orderId) async {
//     final token = await _getCustomerToken();
//     if (token == null) {
//       throw Exception('Authentication token not found. Please log in.');
//     }
//
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/order-details/$orderId');
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     final response = await ioClient.get(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       // 1. Decode the entire JSON response from the server.
//       final decodedResponse = json.decode(response.body);
//
//       // ✅ FIX: Check if the decoded response is a List and is not empty.
//       if (decodedResponse is List && decodedResponse.isNotEmpty) {
//         // 2. The actual order data is the FIRST item in the list.
//         final Map<String, dynamic> orderDataMap = decodedResponse[0];
//
//         // 3. Now pass the correct Map to the fromJson constructor.
//         return OrderDetails.fromJson(orderDataMap);
//       } else {
//         // This is a safeguard in case the API returns an empty list or an unexpected format.
//         throw Exception('API returned an empty or invalid response for the order.');
//       }
//     } else {
//       final errorData = json.decode(response.body);
//       final errorMessage = errorData['message'] ?? 'Failed to load order details.';
//       throw Exception(errorMessage);
//     }
//   }
//   // Future<OrderDetails> _fetchOrderDetails(int orderId) async {
//   //   final token = await _getCustomerToken(); // Replace with your actual token logic
//   //   if (token == null) {
//   //     throw Exception('Authentication token not found. Please log in.');
//   //   }
//   //
//   //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/order-details/$orderId');
//   //   HttpClient httpClient = HttpClient();
//   //   httpClient.badCertificateCallback = (cert, host, port) => true; // For dev only
//   //   IOClient ioClient = IOClient(httpClient);
//   //
//   //   final response = await ioClient.get(
//   //     url,
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //       'Authorization': 'Bearer $token',
//   //     },
//   //   );
//   //
//   //   if (response.statusCode == 200) {
//   //     final data = json.decode(response.body);
//   //     // The API call returns the data, which is then parsed by the model.
//   //     return OrderDetails.fromJson(data);
//   //   } else {
//   //     final errorData = json.decode(response.body);
//   //     final errorMessage = errorData['message'] ?? 'Failed to load order details.';
//   //     throw Exception(errorMessage);
//   //   }
//   // }
//
//   Future<String?> _getCustomerToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     // TODO: Make sure the key 'customer_token' matches what you use after login
//     return prefs.getString('user_token');
//   }
//
//   @override
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // ✅ Use a FutureBuilder to handle the UI based on the API call's state.
//       body: FutureBuilder<OrderDetails>(
//         future: _orderDetailsFuture, // The future we want to monitor
//         builder: (context, snapshot) {
//           // ====== 1. LOADING STATE ======
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//
//           // ====== 2. ERROR STATE ======
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Error loading order details: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             );
//           }
//
//           // ====== 3. SUCCESS STATE ======
//           if (snapshot.hasData) {
//             // The future completed successfully, we have our order data!
//             final order = snapshot.data!;
//             final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//             // ✅ Clear the user's cart now that we've successfully loaded the page.
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               // Assuming you have a 'ClearCart' event, otherwise FetchCartItems might also work
//               // if your server-side logic clears the cart after order placement.
//               // Using a dedicated ClearCart event is safer.
//               context.read<CartBloc>().add(FetchCartItems()); // or FetchCartItems()
//             });
//
//             // This is your original UI, now built with fresh data from the API
//             return SafeArea(
//               child: SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // ✅ This now uses the orderId from the fetched 'order' object.
//                       _buildHeader(context, order.orderId),
//                       const SizedBox(height: 24),
//                       const Divider(),
//                       const SizedBox(height: 16),
//                       _buildOrderDetails(context, order.orderDate),
//                       const SizedBox(height: 24),
//                       Text('Order Information', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
//                       const SizedBox(height: 24),
//                       _buildAddresses(context, order.shippingAddress, order.billingAddress),
//                       const SizedBox(height: 24),
//                       _buildMethods(context, order.shippingMethod, order.paymentMethod),
//                       const SizedBox(height: 32),
//                       _buildItemsOrdered(context, order.items, currencyFormat),
//                       const SizedBox(height: 32),
//                       _buildTotals(context, order.totals, currencyFormat),
//                       const SizedBox(height: 48),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: () {
//                             Navigator.pushAndRemoveUntil(
//                               context,
//                               MaterialPageRoute(builder: (_) => AuthScreen()),
//                                   (Route<dynamic> route) => false,
//                             );
//                           },
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.black,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: const Text('CONTINUE SHOPPING'),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           }
//
//           // ====== 4. FALLBACK STATE (e.g., if snapshot has no data and no error) ======
//           return const Center(child: Text('No order details available.'));
//         },
//       ),
//     );
//   }
//
//   // --- All your helper widgets (_buildHeader, _buildItemsOrdered, etc.) remain unchanged ---
//   // --- They will work perfectly because they receive the 'order' object just like before. ---
//   // [ PASTE ALL YOUR HELPER WIDGETS HERE... _buildHeader, _buildOrderDetails, etc. ]
//   Widget _buildHeader(BuildContext context, String orderNumber) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Thank you for your purchase!', style: Theme.of(context).textTheme.headlineSmall),
//         const SizedBox(height: 24),
//         RichText(
//           text: TextSpan(
//             style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
//             children: [
//               const TextSpan(text: 'Your order number is: '),
//               TextSpan(
//                 text: orderNumber,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           "We'll email you an order confirmation with details and tracking info.",
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//       ],
//     );
//   }
//
//   // ... and so on for all the other helper methods. I'll omit them for brevity
//   // but you should include all of them in your final file.
//
//   Widget _buildItemsOrdered(BuildContext context, List<OrderItem> items, NumberFormat currencyFormat) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Items Ordered', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 16),
//         Column(
//           children: items.map((item) => _buildOrderItemCard(context, item, currencyFormat)).toList(),
//         ),
//       ],
//     );
//   }
//   Widget _buildOrderItemCard(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
//     final textTheme = Theme.of(context).textTheme;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       padding: const EdgeInsets.all(12.0),
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.grey.shade300),
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               SizedBox(
//                 width: 80,
//                 height: 100,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(4.0),
//                   child: CachedNetworkImage(
//                     imageUrl: item.imageUrl ?? '',
//                     fit: BoxFit.cover,
//                     placeholder: (context, url) => Container(color: Colors.grey[200]),
//                     errorWidget: (context, url, error) => Container(
//                       color: Colors.grey[200],
//                       child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       item.name,
//                       style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     if (item.options.isNotEmpty) ...[
//                       Text(item.options, style: textTheme.bodyMedium),
//                       const SizedBox(height: 4),
//                     ],
//                     Text(
//                       'SKU: ${item.sku}',
//                       style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const Divider(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _buildMetric('Price', currencyFormat.format(item.price), context),
//               _buildMetric('Qty', item.qty.toString(), context),
//               _buildMetric('Subtotal', currencyFormat.format(item.subtotal), context, isBold: true),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//   Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
//     final textTheme = Theme.of(context).textTheme;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
//         ),
//         const SizedBox(height: 2),
//         Text(
//           value,
//           style: textTheme.bodyMedium?.copyWith(
//             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
//     String formattedDate = orderDateStr;
//     try {
//       final dateTime = DateTime.parse(orderDateStr);
//       formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
//     } catch (_) {}
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
//         const SizedBox(height: 4),
//         Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
//       ],
//     );
//   }
//   Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
//         const SizedBox(width: 16),
//         Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
//       ],
//     );
//   }
//   Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
//     if (address == null) return const SizedBox.shrink();
//
//     final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//         const SizedBox(height: 12),
//         Text(address.name, style: bodyStyle),
//         Text(address.street, style: bodyStyle),
//         Text(address.cityPostcode, style: bodyStyle),
//         Text(address.country, style: bodyStyle),
//         Text(address.telephone, style: bodyStyle),
//       ],
//     );
//   }
//   Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
//             ],
//           ),
//         ),
//         const SizedBox(width: 16),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
//               const SizedBox(height: 12),
//               Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
//               const Divider(height: 16),
//               _buildKeyValueRow('', paymentMethod.details, context: context),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   Widget _buildTotals(BuildContext context, Totals totals, NumberFormat currencyFormat) {
//     final textStyle = Theme.of(context).textTheme.bodyLarge;
//     final grandTotalStyle = textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
//
//     return Align(
//       alignment: Alignment.centerRight,
//       child: SizedBox(
//         width: 300,
//         child: Column(
//           children: [
//             _buildKeyValueRow('Subtotal', currencyFormat.format(totals.subtotal), context: context, style: textStyle),
//             const SizedBox(height: 8),
//             _buildKeyValueRow('Shipping & Handling', currencyFormat.format(totals.shipping), context: context, style: textStyle),
//             const Divider(height: 24, thickness: 1),
//             _buildKeyValueRow('Grand Total', currencyFormat.format(totals.grandTotal), context: context, style: grandTotalStyle),
//           ],
//         ),
//       ),
//     );
//   }
//   Widget _buildKeyValueRow(String label, String value, {
//     required BuildContext context,
//     TextStyle? style,
//   }) {
//     final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
//
//     return Row(
//       children: [
//         Expanded(
//           child: Text(
//             label,
//             style: effectiveStyle,
//           ),
//         ),
//         Text(
//           value,
//           style: effectiveStyle,
//         ),
//       ],
//     );
//   }
// }
  // Widget build(BuildContext context) {
  //   final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  //
  //   // ✅ Reconstruct the OrderDetails object directly from the passed data
  //   final order = OrderDetails.fromCheckoutData(
  //     orderId: widget.orderId,
  //     totalsData: widget.totals,
  //     billingAddressData: widget.billingAddress,
  //     cartItems: widget.items,
  //   );
  //
  //   // ✅ Clear the user's cart in the background
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     context.read<CartBloc>().add(FetchCartItems());
  //   });
  //
  //   return Scaffold(
  //     body: SafeArea(
  //       child: SingleChildScrollView(
  //         child: Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               _buildHeader(context, order.orderId),
  //               const SizedBox(height: 24),
  //               const Divider(),
  //               const SizedBox(height: 16),
  //               _buildOrderDetails(context, order.orderDate),
  //               const SizedBox(height: 24),
  //               Text('Order Information', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontFamily: 'serif')),
  //               const SizedBox(height: 24),
  //               _buildAddresses(context, order.shippingAddress, order.billingAddress),
  //               const SizedBox(height: 24),
  //               _buildMethods(context, order.shippingMethod, order.paymentMethod),
  //               const SizedBox(height: 32),
  //               _buildItemsOrdered(context, order.items, currencyFormat),
  //               const SizedBox(height: 32),
  //               _buildTotals(context, order.totals, currencyFormat),
  //               const SizedBox(height: 48),
  //               SizedBox(
  //                 width: double.infinity,
  //                 child: ElevatedButton(
  //                   onPressed: () {
  //                     Navigator.pushAndRemoveUntil(
  //                       context,
  //                       MaterialPageRoute(builder: (_) => AuthScreen()),
  //                           (Route<dynamic> route) => false, // This removes all previous routes
  //                     );
  //                   },
  //
  //                   style: ElevatedButton.styleFrom(
  //                     backgroundColor: Colors.black,
  //                     foregroundColor: Colors.white,
  //                     padding: const EdgeInsets.symmetric(vertical: 16),
  //                   ),
  //                   child: const Text('CONTINUE SHOPPING'),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  // // --- Helper widgets are mostly the same, except for the item list ---
  // Widget _buildItemsOrdered(BuildContext context, List<OrderItem> items, NumberFormat currencyFormat) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Items Ordered', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 16),
  //       // We use a Column to list our new custom cards vertically
  //       Column(
  //         children: items.map((item) => _buildOrderItemCard(context, item, currencyFormat)).toList(),
  //       ),
  //     ],
  //   );
  // }
  //
  // // ✅ THIS IS THE NEW MOBILE-FRIENDLY CARD WIDGET THAT REPLACES DATATABLE
  // Widget _buildOrderItemCard(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
  //   final textTheme = Theme.of(context).textTheme;
  //
  //   return Container(
  //     margin: const EdgeInsets.only(bottom: 16.0),
  //     padding: const EdgeInsets.all(12.0),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: Colors.grey.shade300),
  //       borderRadius: BorderRadius.circular(8.0),
  //     ),
  //     child: Column(
  //       children: [
  //         // Top section: Image + Name/SKU/Options
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Image
  //             SizedBox(
  //               width: 80,
  //               height: 100,
  //               child: ClipRRect(
  //                 borderRadius: BorderRadius.circular(4.0),
  //                 child: CachedNetworkImage(
  //                   imageUrl: item.imageUrl ?? '',
  //                   fit: BoxFit.cover,
  //                   placeholder: (context, url) => Container(color: Colors.grey[200]),
  //                   errorWidget: (context, url, error) => Container(
  //                     color: Colors.grey[200],
  //                     child: const Icon(Icons.image_not_supported, color: Colors.grey),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             // Details
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     item.name,
  //                     style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   const SizedBox(height: 4),
  //                   if (item.options.isNotEmpty) ...[
  //                     Text(item.options, style: textTheme.bodyMedium),
  //                     const SizedBox(height: 4),
  //                   ],
  //                   Text(
  //                     'SKU: ${item.sku}',
  //                     style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //         const Divider(height: 24),
  //         // Bottom section: Price, Qty, Subtotal
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             _buildMetric('Price', currencyFormat.format(item.price), context),
  //             _buildMetric('Qty', item.qty.toString(), context),
  //             _buildMetric('Subtotal', currencyFormat.format(item.subtotal), context, isBold: true),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // // Helper for the small price/qty/subtotal metrics
  // Widget _buildMetric(String label, String value, BuildContext context, {bool isBold = false}) {
  //   final textTheme = Theme.of(context).textTheme;
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(
  //         label,
  //         style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
  //       ),
  //       const SizedBox(height: 2),
  //       Text(
  //         value,
  //         style: textTheme.bodyMedium?.copyWith(
  //           fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildHeader(BuildContext context, String orderNumber) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Thank you for your purchase!', style: Theme.of(context).textTheme.headlineSmall),
  //       const SizedBox(height: 24),
  //       RichText(
  //         text: TextSpan(
  //           style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16),
  //           children: [
  //             const TextSpan(text: 'Your order number is: '),
  //             TextSpan(
  //               text: orderNumber,
  //               style: const TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         "We'll email you an order confirmation with details and tracking info.",
  //         style: Theme.of(context).textTheme.bodyMedium,
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildOrderDetails(BuildContext context, String orderDateStr) {
  //   String formattedDate = orderDateStr;
  //   try {
  //     final dateTime = DateTime.parse(orderDateStr);
  //     formattedDate = DateFormat('MMMM d, yyyy').format(dateTime);
  //   } catch (_) {}
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text('Order details:', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 4),
  //       Text('Order Date: $formattedDate', style: Theme.of(context).textTheme.bodyMedium),
  //     ],
  //   );
  // }
  //
  // Widget _buildAddresses(BuildContext context, Address? shipping, Address? billing) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(child: _buildAddressColumn(context, 'Shipping Address', shipping)),
  //       const SizedBox(width: 16),
  //       Expanded(child: _buildAddressColumn(context, 'Billing Address', billing)),
  //     ],
  //   );
  // }
  //
  // Widget _buildAddressColumn(BuildContext context, String title, Address? address) {
  //   if (address == null) return const SizedBox.shrink();
  //
  //   final bodyStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //       const SizedBox(height: 12),
  //       Text(address.name, style: bodyStyle),
  //       Text(address.street, style: bodyStyle),
  //       Text(address.cityPostcode, style: bodyStyle),
  //       Text(address.country, style: bodyStyle),
  //       Text(address.telephone, style: bodyStyle),
  //     ],
  //   );
  // }
  //
  // Widget _buildMethods(BuildContext context, String shippingMethod, PaymentMethod paymentMethod) {
  //   return Row(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Shipping Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //             const SizedBox(height: 12),
  //             Text(shippingMethod, style: Theme.of(context).textTheme.bodyMedium),
  //           ],
  //         ),
  //       ),
  //       const SizedBox(width: 16),
  //       Expanded(
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text('Payment Method', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20)),
  //             const SizedBox(height: 12),
  //             Text(paymentMethod.title, style: Theme.of(context).textTheme.bodyMedium),
  //             const Divider(height: 16),
  //             _buildKeyValueRow('', paymentMethod.details, context: context),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // DataRow _buildItemRow(BuildContext context, OrderItem item, NumberFormat currencyFormat) {
  //   final textStyle = Theme.of(context).textTheme.bodyMedium;
  //   final nameStyle = textStyle?.copyWith(fontWeight: FontWeight.bold);
  //
  //   return DataRow(
  //     cells: [
  //       DataCell(
  //         // ✅ Use a ConstrainedBox to give the cell a max-width, preventing overflow.
  //         // This works better with DataTable's layout calculations.
  //         ConstrainedBox(
  //           constraints: const BoxConstraints(maxWidth: 250), // Adjust this width as needed
  //           child: Row(
  //             children: [
  //               SizedBox(
  //                 width: 60,
  //                 height: 80,
  //                 child: CachedNetworkImage(
  //                   imageUrl: item.imageUrl ?? '',
  //                   fit: BoxFit.cover,
  //                   placeholder: (context, url) => Container(color: Colors.grey[200]),
  //                   errorWidget: (context, url, error) => Container(
  //                     color: Colors.grey[200],
  //                     child: const Icon(Icons.image_not_supported),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               Expanded(
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   // ✅ Add mainAxisAlignment to center the text vertically in the cell.
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     Text(
  //                       item.name,
  //                       style: nameStyle,
  //                       overflow: TextOverflow.ellipsis,
  //                       // ✅ Use maxLines to prevent text from wrapping and causing vertical overflow.
  //                       maxLines: 2,
  //                     ),
  //                     if (item.options.isNotEmpty)
  //                       Text(
  //                         item.options,
  //                         style: textStyle,
  //                         overflow: TextOverflow.ellipsis,
  //                         maxLines: 1,
  //                       ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       DataCell(Text(item.sku, style: textStyle)),
  //       DataCell(Text(currencyFormat.format(item.price), style: textStyle)),
  //       DataCell(Text(item.qty.toString(), style: textStyle)),
  //       DataCell(Text(currencyFormat.format(item.subtotal), style: textStyle)),
  //     ],
  //   );
  // }
  //
  // Widget _buildStatusTracker(BuildContext context, String currentStatus) {
  //   return Row(
  //     children: [
  //       const Text('Order Status: ', style: TextStyle(fontWeight: FontWeight.bold)),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //         decoration: BoxDecoration(
  //           color: Colors.blue.shade100,
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         child: Text(
  //           currentStatus,
  //           style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold),
  //         ),
  //       ),
  //     ],
  //   );
  // }
  //
  // Widget _buildTotals(BuildContext context, Totals totals, NumberFormat currencyFormat) {
  //   final textStyle = Theme.of(context).textTheme.bodyLarge;
  //   final grandTotalStyle = textStyle?.copyWith(fontWeight: FontWeight.bold, fontSize: 20);
  //
  //   return Align(
  //     alignment: Alignment.centerRight,
  //     child: SizedBox(
  //       width: 300,
  //       child: Column(
  //         children: [
  //           _buildKeyValueRow('Subtotal', currencyFormat.format(totals.subtotal), context: context, style: textStyle),
  //           const SizedBox(height: 8),
  //           _buildKeyValueRow('Shipping & Handling', currencyFormat.format(totals.shipping), context: context, style: textStyle),
  //           const Divider(height: 24, thickness: 1),
  //           _buildKeyValueRow('Grand Total', currencyFormat.format(totals.grandTotal), context: context, style: grandTotalStyle),
  //         ],
  //       ),
  //     ),
  //   );
  // }
  //
  // Widget _buildKeyValueRow(String label, String value, {
  //   required BuildContext context,
  //   TextStyle? style,
  // }) {
  //   final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
  //
  //   return Row(
  //     // We no longer need mainAxisAlignment.spaceBetween
  //     children: [
  //       // Wrap the label in an Expanded widget.
  //       // This makes it take up all available space, pushing the value to the right.
  //       Expanded(
  //         child: Text(
  //           label,
  //           style: effectiveStyle,
  //         ),
  //       ),
  //       // The value will now be aligned to the right, taking up only the space it needs.
  //       Text(
  //         value,
  //         style: effectiveStyle,
  //       ),
  //     ],
  //   );
  // }
