// lib/features/checkout/payment_screen.dart

import 'package:aashniandco/features/Payment/view/payu_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ REMOVED: flutter_multi_formatter is no longer needed.
import 'package:flutter_stripe/flutter_stripe.dart'; // ✅ IMPORT STRIPE
import 'package:intl/intl.dart';

// Your BLoC and Screen imports (adjust paths as needed)
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../checkout/model/payment_gateway_type.dart';
import '../../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../../shoppingbag/cart_bloc/cart_bloc.dart';
import '../../shoppingbag/cart_bloc/cart_state.dart';
import '../../shoppingbag/repository/shipping_repository.dart';
import 'order_success_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:payu_checkoutpro_flutter/payu_checkoutpro_flutter.dart'; // Import the specific package


// ✅ REMOVED: CardDetails model is no longer needed.

// class PaymentScreen extends StatefulWidget {
//   final List<dynamic> paymentMethods;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//
//   const PaymentScreen({
//     Key? key,
//     required this.paymentMethods,
//     required this.totals,
//     required this.billingAddress,
//   }) : super(key: key);
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }


class PaymentScreen extends StatefulWidget {
  final List<dynamic> paymentMethods;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> billingAddress;
  final PaymentGatewayType selectedGateway;
  final String? guestEmail;

  const PaymentScreen({
    Key? key,
    required this.paymentMethods,
    required this.totals,
    required this.billingAddress,
    required this.selectedGateway,
    this.guestEmail,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isBillingSameAsShipping = true;
  bool _isProcessing = false;

  // Lazily initialize the repository
  late final ShippingRepository _shippingRepository = ShippingRepository();
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  @override
  @override
  Widget build(BuildContext context) {
    final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;

    // ✅ 1. DEFINE the payment code variable here.
    // This makes it available to the entire build method, including the BlocListener.
    String selectedPaymentCode;

    // ✅ 2. ASSIGN the correct code based on the selected gateway.
    // Use the exact codes your backend expects and that you check for below.
    if (widget.selectedGateway == PaymentGatewayType.stripe) {
      selectedPaymentCode = 'stripe_payments';
    } else if (widget.selectedGateway == PaymentGatewayType.payu) {
      // This code 'payu' must match what you use in isPaymentMethodAvailable('payu')
      selectedPaymentCode = 'payu';
    } else {
      // It's good practice to have a fallback.
      selectedPaymentCode = 'unknown';
    }

    // This local function is fine as it is.
    bool isPaymentMethodAvailable(String code) {
      try {
        widget.paymentMethods.firstWhere((m) => m['code'] == code);
        return true;
      } catch (e) {
        return false;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          // This listener handles the result after the BLoC has processed the payment
          if (state is PaymentSuccess || state is ShippingError) {
            if (mounted) setState(() => _isProcessing = false);
          }

          if (state is PaymentSuccess) {
            final cartState = context.read<CartBloc>().state;
            final cartItems = (cartState is CartLoaded) ? cartState.items : [];

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (_) => OrderSuccessScreen(
                  orderId: state.orderId,
                  totals: widget.totals,
                  billingAddress: widget.billingAddress,
                  items: cartItems,
                  // ✅ 3. USE the variable which is now correctly defined in this scope.
                  paymentMethodCode: selectedPaymentCode,


                ),
              ),
                  (route) => false,
            );
          } else if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment Failed: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          // The rest of your UI code remains exactly the same.
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
              const SizedBox(height: 24),
              Text('Payment Method', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),

              // --- DYNAMIC UI LOGIC ---
              if (widget.selectedGateway == PaymentGatewayType.stripe)
                if (isPaymentMethodAvailable('stripe_payments'))
                  _buildStripePaymentSection()
                else
                  const Center(child: Text("Credit Card (Stripe) is not available for this order."))
              else if (widget.selectedGateway == PaymentGatewayType.payu)
                if (isPaymentMethodAvailable('payu'))
                  _buildPayUPaymentSection()
                else
                  const Center(child: Text("PayU Money is not available for this order.")),

              const SizedBox(height: 24),
              _buildPlaceOrderButton(),
              const SizedBox(height: 24),
              _buildBillingAddressSection(),
            ],
          ),
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
  //
  //   bool isPaymentMethodAvailable(String code) {
  //     try {
  //       widget.paymentMethods.firstWhere((m) => m['code'] == code);
  //       return true;
  //     } catch (e) {
  //       return false;
  //     }
  //   }
  //
  //   return Scaffold(
  //     appBar: AppBar(title: const Text('Payment')),
  //     body: BlocListener<ShippingBloc, ShippingState>(
  //       listener: (context, state) {
  //         // This listener handles the result after the BLoC has processed the payment
  //         if (state is PaymentSuccess || state is ShippingError) {
  //           if (mounted) setState(() => _isProcessing = false);
  //         }
  //
  //         if (state is PaymentSuccess) {
  //           final cartState = context.read<CartBloc>().state;
  //           final cartItems = (cartState is CartLoaded) ? cartState.items : [];
  //
  //           Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //               builder: (_) => OrderSuccessScreen(
  //                 orderId: state.orderId,
  //                 totals: widget.totals,
  //                 billingAddress: widget.billingAddress,
  //                 items: cartItems,
  //                 paymentMethodCode: selectedPaymentCode,
  //               ),
  //             ),
  //                 (route) => false,
  //           );
  //         } else if (state is ShippingError) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text('Payment Failed: ${state.message}'),
  //               backgroundColor: Colors.red,
  //             ),
  //           );
  //         }
  //       },
  //       child: SingleChildScrollView(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.stretch,
  //           children: [
  //             _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
  //             const SizedBox(height: 24),
  //             Text('Payment Method', style: Theme.of(context).textTheme.headlineSmall),
  //             const SizedBox(height: 16),
  //
  //             // --- DYNAMIC UI LOGIC ---
  //             if (widget.selectedGateway == PaymentGatewayType.stripe)
  //               if (isPaymentMethodAvailable('stripe_payments'))
  //                 _buildStripePaymentSection()
  //               else
  //                 const Center(child: Text("Credit Card (Stripe) is not available for this order."))
  //             else if (widget.selectedGateway == PaymentGatewayType.payu)
  //             // Assuming your PayU module's code is 'payu' or 'payu_method_code'
  //               if (isPaymentMethodAvailable('payu')) // <-- CHECK THIS CODE
  //                 _buildPayUPaymentSection()
  //               else
  //                 const Center(child: Text("PayU Money is not available for this order.")),
  //
  //             const SizedBox(height: 24),
  //             _buildPlaceOrderButton(),
  //             const SizedBox(height: 24),
  //             _buildBillingAddressSection(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// The dispatcher method that decides which payment flow to start.
  void _placeOrder() {
    if (widget.selectedGateway == PaymentGatewayType.stripe) {
      _placeOrderWithStripe();
    } else if (widget.selectedGateway == PaymentGatewayType.payu) {
      _placeOrderWithPayU();
    }
  }

  // --- UI WIDGETS ---

  Widget _buildStripePaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: const CardField(),
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Icon(Icons.lock, color: Colors.green, size: 16),
            SizedBox(width: 8),
            Expanded(child: Text('Your card details are protected using PCI DSS v3.2 security standards.', style: TextStyle(fontSize: 12, color: Colors.black54))),
          ],
        )
      ],
    );
  }

  Widget _buildPayUPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('PayU Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Image.asset(
              'assets/images/payu_logo.png',
              height: 20,
              // Optional: Add error handling for the local asset
              errorBuilder: (context, error, stackTrace) {
                return const Text('Logo', style: TextStyle(fontSize: 12, color: Colors.grey));
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text("You will be redirected to the secure PayU gateway to complete your payment.", style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  // --- PAYMENT LOGIC METHODS ---

  Future<void> _placeOrderWithStripe() async {
    // This method is already correct from your provided code. No changes needed.
    if (mounted) setState(() => _isProcessing = true);
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
      );
      if (mounted) {
        final currencyState = context.read<CurrencyBloc>().state;
        if (currencyState is! CurrencyLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: Currency information not available.')),
          );
          setState(() => _isProcessing = false);
          return;
        }
        context.read<ShippingBloc>().add(
          SubmitPaymentInfo(
            paymentMethodCode: 'stripe_payments',
            billingAddress: widget.billingAddress,
            paymentMethodNonce: paymentMethod.id,
            currencyCode: currencyState.selectedCurrencyCode,
          ),
        );
      }
    } on StripeException catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
        );
      }
    }
  }

  // Future<void> _placeOrderWithStripe() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //
  //   try {
  //     // This part is fine, it gets the payment token from Stripe
  //     final paymentMethod = await Stripe.instance.createPaymentMethod(
  //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
  //     );
  //
  //     if (mounted) {
  //       // ✅ 1. Get the current currency state from the global BLoC
  //       final currencyState = context.read<CurrencyBloc>().state;
  //
  //       // ✅ 2. Check if the currency is loaded before proceeding
  //       if (currencyState is! CurrencyLoaded) {
  //         // This is a safeguard. If the currency isn't loaded, we can't place the order correctly.
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Error: Currency information not available. Please restart the app.')),
  //         );
  //         // Stop the loading indicator
  //         setState(() => _isProcessing = false);
  //         return; // Exit the function
  //       }
  //
  //       // ✅ 3. Dispatch the event WITH the required currencyCode
  //       context.read<ShippingBloc>().add(
  //         SubmitPaymentInfo(
  //           paymentMethodCode: 'stripe_payments',
  //           billingAddress: widget.billingAddress,
  //           paymentMethodNonce: paymentMethod.id,
  //           // Pass the currency code from the loaded state
  //           currencyCode: currencyState.selectedCurrencyCode,
  //         ),
  //       );
  //     }
  //   } on StripeException catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }

  // Future<void> _placeOrderWithStripe() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //
  //   try {
  //     final paymentMethod = await Stripe.instance.createPaymentMethod(
  //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
  //     );
  //
  //     if (mounted) {
  //       context.read<ShippingBloc>().add(
  //         SubmitPaymentInfo(
  //           paymentMethodCode: 'stripe_payments',
  //           billingAddress: widget.billingAddress,
  //           paymentMethodNonce: paymentMethod.id,
  //         ),
  //       );
  //     }
  //   } on StripeException catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
  //       );
  //     }
  //   }
  // }
//11/10/2025
  Future<void> _placeOrderWithPayU() async {
    if (!mounted) return;

    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final guestEmail = prefs.getString('user_email');
      final guestQuoteId = prefs.getString('guest_quote_id');

      if (kDebugMode) {
        print("PaymentScreen get guestQuoteId >> $guestQuoteId");
        print("PaymentScreen get guestEmail >> $guestEmail");
      }

      final isLoggedIn = token != null && token.isNotEmpty;
      final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;

      if (!isLoggedIn && !isGuest) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No session found. Cannot initiate payment.'),
            backgroundColor: Colors.red,
          ),
        );
        if (kDebugMode) print("⚠️ No session found for payment.");
        return;
      }

      // ✅ Get currency code from CurrencyBloc, same as Stripe
      final currencyState = context.read<CurrencyBloc>().state;
      if (currencyState is! CurrencyLoaded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Currency information not available.')),
        );
        setState(() => _isProcessing = false);
        return;
      }
      final currencyCode = currencyState.selectedCurrencyCode;
      print("💱 Currency Code for PayU from Bloc: $currencyCode");


      // Initiate PayU payment, passing the currencyCode
      final payUData = await _shippingRepository.initiatePayUPayment(
        currencyCode: currencyCode, // ✅ PASS THE CURRENCY CODE HERE
      );
      if (!mounted) return;

      // ... (rest of _placeOrderWithPayU remains the same)

      // Open PayU WebView
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PayUWebViewScreen(paymentData: payUData),
        ),
      );

      if (result != 'Success') {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment failed or was canceled.'),
            backgroundColor: Colors.red,
          ),
        );
        if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful! Finalizing order...'),
          backgroundColor: Colors.green,
        ),
      );

      final txnid = payUData['txnid'] as String;

      context.read<ShippingBloc>().add(
        FinalizePayUOrder(
          txnid: txnid,
          currencyCode: currencyCode,
          guestQuoteId: isGuest ? guestQuoteId : null,
          guestEmail: isGuest ? guestEmail : null,
        ),
      );

      if (kDebugMode) {
        print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
            "and currencyCode: $currencyCode");
        if (isGuest) {
          print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
        }
      }
    } catch (e, stacktrace) {
      if (mounted) setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
      if (kDebugMode) {
        print("❌ Error in placeOrderWithPayU: $e");
        print("Stacktrace: $stacktrace");
      }
    }
  }

  // Future<void> _placeOrderWithPayU() async {
  //   if (!mounted) return;
  //
  //   setState(() => _isProcessing = true);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //     final guestEmail = prefs.getString('user_email'); // ✅ guest email key
  //     final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //     if (kDebugMode) {
  //       print("PaymentScreen get guestQuoteId >> $guestQuoteId");
  //       print("PaymentScreen get guestEmail >> $guestEmail");
  //     }
  //
  //     // Determine checkout type
  //     final isLoggedIn = token != null && token.isNotEmpty;
  //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
  //
  //     if (!isLoggedIn && !isGuest) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('No session found. Cannot initiate payment.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ No session found for payment.");
  //       return;
  //     }
  //
  //     if (kDebugMode) {
  //       print(isLoggedIn
  //           ? "🟢 Logged-in user flow → initiating PayU payment"
  //           : "🟠 Guest checkout flow → initiating PayU payment");
  //       if (isGuest) {
  //         print(" Guest QuoteId: $guestQuoteId");
  //         print(" Guest Email: $guestEmail");
  //       }
  //     }
  //
  //     // Initiate PayU payment
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     // Open PayU WebView
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     if (result != 'Success') {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment failed or was canceled.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
  //       return;
  //     }
  //
  //     // Payment success → finalize order
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Payment Successful! Finalizing order...'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //
  //     // ✅ Currency code handling (same as Stripe flow)
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     if (currencyState is! CurrencyLoaded) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error: Currency information not available.')),
  //       );
  //       setState(() => _isProcessing = false);
  //       return;
  //     }
  //
  //     final currencyCode = currencyState.selectedCurrencyCode;
  //     print("💱 Currency Code from Bloc: $currencyCode");
  //
  //     final txnid = payUData['txnid'] as String;
  //
  //     // Dispatch finalize order event
  //     context.read<ShippingBloc>().add(
  //       FinalizePayUOrder(
  //         txnid: txnid,
  //         currencyCode: currencyCode, // ✅ aligned with Stripe flow
  //         guestQuoteId: isGuest ? guestQuoteId : null,
  //         guestEmail: isGuest ? guestEmail : null,
  //       ),
  //     );
  //
  //     if (kDebugMode) {
  //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
  //           "and currencyCode: $currencyCode");
  //       if (isGuest) {
  //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
  //       }
  //     }
  //   } catch (e, stacktrace) {
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //     if (kDebugMode) {
  //       print("❌ Error in placeOrderWithPayU: $e");
  //       print("Stacktrace: $stacktrace");
  //     }
  //   }
  // }

  //4/10/2025
  // Future<void> _placeOrderWithPayU() async {
  //   if (!mounted) return;
  //
  //   setState(() => _isProcessing = true);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //     // Ensure 'user_email' is the correct key where you store the guest's email.
  //     final guestEmail = prefs.getString('user_email');
  //     final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //     if (kDebugMode) {
  //       print("PaymetScreeng get guestquoteId>>$guestQuoteId");
  //       print("PaymentScreen get guestEmail>>$guestEmail");
  //     }
  //
  //     // Determine checkout type
  //     final isLoggedIn = token != null && token.isNotEmpty;
  //     // Ensure guestQuoteId is not empty for a valid guest session
  //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
  //
  //     if (!isLoggedIn && !isGuest) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('No session found. Cannot initiate payment.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ No session found for payment.");
  //       return;
  //     }
  //
  //     if (kDebugMode) {
  //       print(isLoggedIn
  //           ? "🟢 Logged-in user flow → initiating PayU payment"
  //           : "🟠 Guest checkout flow → initiating PayU payment");
  //       if (isGuest) {
  //         print(" Guest QuoteId: $guestQuoteId");
  //         print(" Guest Email: $guestEmail");
  //       }
  //     }
  //
  //     // Initiate PayU payment (initiatePayUPayment in ShippingRepository now correctly uses guestEmail for guests)
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     // Open PayU WebView
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     if (result != 'Success') {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment failed or was canceled.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
  //       return;
  //     }
  //
  //     // Payment success → finalize order
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Payment Successful! Finalizing order...'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     if (currencyState is! CurrencyLoaded) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error: Currency information not available.')),
  //       );
  //       setState(() => _isProcessing = false);
  //       return;
  //     }
  //
  //     // ✅ Print the currency code here
  //     print("Currency Code from Bloc: ${currencyState.selectedCurrencyCode}");
  //
  //     final txnid = payUData['txnid'] as String;
  //
  //     // Dispatch finalize order event with guest info if applicable
  //     context.read<ShippingBloc>().add(FinalizePayUOrder(
  //       txnid: txnid,
  //       currencyCode: currencyState.selectedCurrencyCode,
  //       guestQuoteId: isGuest ? guestQuoteId : null,
  //       guestEmail: isGuest ? guestEmail : null, // ✅ CORRECTED: Pass the guest email
  //     ));
  //
  //     if (kDebugMode) {
  //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
  //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
  //       if (isGuest) {
  //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
  //       }
  //     }
  //   } catch (e, stacktrace) { // Catch stacktrace here too for better debugging
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //     if (kDebugMode) {
  //       print("❌ Error in placeOrderWithPayU: $e");
  //       print("Stacktrace: $stacktrace");
  //     }
  //   }
  // }

  // Future<void> _placeOrderWithPayU() async {
  //   if (!mounted) return;
  //
  //   setState(() => _isProcessing = true);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //     final guestEmail = prefs.getString('user_email'); // Get guest email from prefs
  //     final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //     print("PaymetScreeng get guestquoteId>>$guestQuoteId");
  //     print("PaymentScreen get guestEmail>>$guestEmail"); // Log guest email
  //
  //     // Determine checkout type
  //     final isLoggedIn = token != null && token.isNotEmpty;
  //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty; // Ensure guestQuoteId is not empty
  //
  //     if (!isLoggedIn && !isGuest) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('No session found. Cannot initiate payment.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ No session found for payment.");
  //       return;
  //     }
  //
  //     if (kDebugMode) {
  //       print(isLoggedIn
  //           ? "🟢 Logged-in user flow → initiating PayU payment"
  //           : "🟠 Guest checkout flow → initiating PayU payment");
  //       if (isGuest) {
  //         print(" Guest QuoteId: $guestQuoteId");
  //         print(" Guest Email: $guestEmail"); // Log guest email here
  //       }
  //     }
  //
  //     // Initiate PayU payment (auto handles guest/logged-in)
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     // Open PayU WebView
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     if (result != 'Success') {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment failed or was canceled.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
  //       return;
  //     }
  //
  //     // Payment success → finalize order
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Payment Successful! Finalizing order...'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     if (currencyState is! CurrencyLoaded) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error: Currency information not available.')),
  //       );
  //       setState(() => _isProcessing = false);
  //       return;
  //     }
  //
  //     final txnid = payUData['txnid'] as String;
  //
  //     // Dispatch finalize order event with guest info if applicable
  //     context.read<ShippingBloc>().add(FinalizePayUOrder(
  //       txnid: txnid,
  //       currencyCode: currencyState.selectedCurrencyCode,
  //       guestQuoteId: isGuest ? guestQuoteId : null,
  //       guestEmail: isGuest ? guestEmail : null, // ✅ Pass the guest email
  //     ));
  //
  //     if (kDebugMode) {
  //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
  //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
  //       if (isGuest) {
  //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
  //       }
  //     }
  //   } catch (e, stacktrace) { // Catch stacktrace here too for better debugging
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //     if (kDebugMode) {
  //       print("❌ Error in placeOrderWithPayU: $e");
  //       print("Stacktrace: $stacktrace");
  //     }
  //   }
  // }
  // Future<void> _placeOrderWithPayU() async {
  //   if (!mounted) return;
  //
  //   setState(() => _isProcessing = true);
  //
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //     final guestEmail = prefs.getString('user_email');
  //     final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //
  //     print("PaymetScreeng get guestquoteId>>$guestQuoteId");
  //
  //     // Determine checkout type
  //     final isLoggedIn = token != null && token.isNotEmpty;
  //     final isGuest = guestQuoteId != null;
  //
  //     if (!isLoggedIn && !isGuest) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('No session found. Cannot initiate payment.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ No session found for payment.");
  //       return;
  //     }
  //
  //     if (kDebugMode) {
  //       print(isLoggedIn
  //           ? "🟢 Logged-in user flow → initiating PayU payment"
  //           : "🟠 Guest checkout flow → initiating PayU payment");
  //       if (isGuest) print(" Guest QuoteId: $guestQuoteId");
  //     }
  //
  //     // Initiate PayU payment (auto handles guest/logged-in)
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     // Open PayU WebView
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     if (result != 'Success') {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment failed or was canceled.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
  //       return;
  //     }
  //
  //     // Payment success → finalize order
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text('Payment Successful! Finalizing order...'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     if (currencyState is! CurrencyLoaded) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Error: Currency information not available.')),
  //       );
  //       setState(() => _isProcessing = false);
  //       return;
  //     }
  //
  //     final txnid = payUData['txnid'] as String;
  //
  //     // Dispatch finalize order event with guest info if applicable
  //     context.read<ShippingBloc>().add(FinalizePayUOrder(
  //       txnid: txnid,
  //       currencyCode: currencyState.selectedCurrencyCode,
  //       guestQuoteId: isGuest ? guestQuoteId : null,
  //
  //     ));
  //
  //     if (kDebugMode) {
  //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
  //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //     if (kDebugMode) print("❌ Error in placeOrderWithPayU: $e");
  //   }
  // }

  // Future<void> _placeOrderWithPayU() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('user_token');
  //     final guestEmail = prefs.getString('guest_email');
  //     final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //     if (kDebugMode) {
  //       if (token != null && token.isNotEmpty) {
  //         print("🟢 Logged-in user flow → initiating PayU payment");
  //       } else if (guestEmail != null && guestQuoteId != null) {
  //         print("🟠 Guest checkout flow → initiating PayU payment");
  //         print("Guest Email: $guestEmail");
  //         print("Guest QuoteId: $guestQuoteId");
  //       } else {
  //         print("🔴 No session found → cannot initiate payment");
  //       }
  //     }
  //
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     if (result == 'Success') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment Successful! Finalizing order...'),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //
  //       // ✅ Currency logic fix
  //       final currencyState = context.read<CurrencyBloc>().state;
  //       if (currencyState is! CurrencyLoaded) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Error: Currency information not available.')),
  //         );
  //         setState(() => _isProcessing = false);
  //         return;
  //       }
  //
  //       final txnid = payUData['txnid'] as String;
  //
  //       context.read<ShippingBloc>().add(FinalizePayUOrder(
  //         txnid: txnid,
  //         currencyCode: currencyState.selectedCurrencyCode,
  //       ));
  //
  //       if (kDebugMode) {
  //         print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
  //             "and currencyCode: ${currencyState.selectedCurrencyCode}");
  //       }
  //     } else {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Payment failed or was canceled.'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //     if (kDebugMode) print("❌ Error in placeOrderWithPayU: $e");
  //   }
  // }

  // Future<void> _placeOrderWithPayU() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //   try {
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
  //     );
  //
  //     if (result == 'Success') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
  //       );
  //
  //       // ✅✅✅ THIS IS THE FINAL FIX ✅✅✅
  //       // You must add the currency logic here, just like in the Stripe method.
  //
  //       // 1. Get the current currency state from the global BLoC
  //       final currencyState = context.read<CurrencyBloc>().state;
  //
  //       // 2. Check if the currency is loaded before proceeding
  //       if (currencyState is! CurrencyLoaded) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Error: Currency information not available.')),
  //         );
  //         setState(() => _isProcessing = false);
  //         return;
  //       }
  //
  //       final txnid = payUData['txnid'] as String;
  //
  //       // 3. Dispatch the event WITH the required currencyCode
  //       context.read<ShippingBloc>().add(FinalizePayUOrder(
  //         txnid: txnid,
  //         currencyCode: currencyState.selectedCurrencyCode, // Pass the code
  //       ));
  //
  //     } else {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //   }
  // }
  // Future<void> _placeOrderWithPayU() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //
  //   try {
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //
  //     // We no longer need to set processing to false here, the BLoC will handle it
  //     // setState(() => _isProcessing = false);
  //
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
  //     );
  //
  //     // After returning from WebView, handle the result
  //     if (result == 'Success') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
  //       );
  //
  //       // ✅ INSTEAD OF NAVIGATING, DISPATCH THE NEW EVENT
  //       // The BLoC listener will take care of the final navigation
  //       final txnid = payUData['txnid'] as String;
  //       context.read<ShippingBloc>().add(FinalizePayUOrder(txnid: txnid));
  //
  //     } else {
  //       // If payment failed or was cancelled, stop the processing indicator
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) setState(() => _isProcessing = false);
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //     );
  //   }
  // }
  // Future<void> _placeOrderWithPayU() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //
  //   try {
  //     // This now returns a `dynamic` type because it could be a List or a Map
  //     final dynamic rawPayUData = await _shippingRepository.initiatePayUPayment();
  //
  //     // ------------------- ✅ NEW FIX STARTS HERE -------------------
  //
  //
  //     // Check if the response is the incorrect List format
  //
  //     // Check if the response is already in the correct Map format
  //
  //     // ------------------- ✅ NEW FIX ENDS HERE -------------------
  //     final payUData = await _shippingRepository.initiatePayUPayment();
  //     if (!mounted) return;
  //     setState(() => _isProcessing = false);
  //
  //     // Now, `payUData` is guaranteed to be a Map, and this navigation will work.
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
  //       ),
  //     );
  //
  //     // ... (rest of the function remains the same)
  //     if (result == 'Success') {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
  //       );
  //       final cartState = context.read<CartBloc>().state;
  //       final cartItems = (cartState is CartLoaded) ? cartState.items : [];
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (_) => OrderSuccessScreen(
  //           orderId: int.tryParse(payUData['txnid'].toString().split('-').first.substring(1)) ?? 0,
  //           totals: widget.totals,
  //           billingAddress: widget.billingAddress,
  //           items: cartItems,
  //         )),
  //             (route) => false,
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
  //       );
  //     }
  //   }
  // }

  // --- COMMON UI WIDGETS ---

  Widget _buildPlaceOrderButton() {
    return BlocBuilder<ShippingBloc, ShippingState>(
      builder: (context, state) {
        final isSubmitting = state is PaymentSubmitting || _isProcessing;
        return ElevatedButton(
          onPressed: isSubmitting ? null : _placeOrder,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          child: isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : const Text('PLACE ORDER'),
        );
      },
    );
  }

  Widget _buildEstimatedTotal(dynamic grandTotalValue, int qty) {
    // final grandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
    // ✅ 1. Get the current currency state
    final currencyState = context.watch<CurrencyBloc>().state;

    // --- Prepare variables ---
    // This is the BASE grand total in INR from your API
    final double baseGrandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;

    // ✅ 2. Set default and then calculate the display values
    String displaySymbol = '₹'; // Default symbol
    double displayGrandTotal = baseGrandTotal; // Default price

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      // Calculate price: (base price in INR) * (selected currency's rate)
      displayGrandTotal = baseGrandTotal * currencyState.selectedRate.rate;
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4.0)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Estimated Total', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 4),
              Text(
                '$displaySymbol${displayGrandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Text(_currencyFormat.format(grandTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
                child: Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('My billing and shipping address are the same'),
          value: _isBillingSameAsShipping,
          onChanged: (bool? value) => setState(() => _isBillingSameAsShipping = value ?? true),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        if (_isBillingSameAsShipping) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              '${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}\n'
                  '${widget.billingAddress['street']?.join(', ')}\n'
                  '${widget.billingAddress['city']}, ${widget.billingAddress['region']} ${widget.billingAddress['postcode']}\n'
                  '${widget.billingAddress['country_id']}\n'
                  '${widget.billingAddress['telephone']}',
              style: const TextStyle(height: 1.5, color: Colors.black87),
            ),
          )
        ]
      ],
    );
  }
}

// class PaymentScreen extends StatefulWidget {
//   final List<dynamic> paymentMethods;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final PaymentGatewayType selectedGateway; // <-- ADD THIS PROPERTY
//
//   const PaymentScreen({
//     Key? key,
//     required this.paymentMethods,
//     required this.totals,
//     required this.billingAddress,
//     required this.selectedGateway, // <-- ADD THIS TO THE CONSTRUCTOR
//   }) : super(key: key);
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _isBillingSameAsShipping = true;
//   bool _isProcessing = false;
//
//   final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//   @override
//   Widget build(BuildContext context) {
//     final stripePaymentMethod = widget.paymentMethods.firstWhere(
//           (m) => m['code'] == 'stripe_payments',
//       orElse: () => null,
//     );
//     final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           if (state is PaymentSuccess || state is ShippingError) {
//             if (mounted) setState(() => _isProcessing = false);
//           }
//
//           if (state is PaymentSuccess) {
//             // ✅ THE FIX IS HERE: Navigate with the data we already have.
//             final cartState = context.read<CartBloc>().state;
//             final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                   builder: (_) => OrderSuccessScreen(
//                     orderId: state.orderId,
//                     totals: widget.totals,
//                     billingAddress: widget.billingAddress,
//                     items: cartItems,
//                     // Pass the cart items
//                   )),
//                   (route) => false,
//             );
//           } else if (state is ShippingError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Payment Failed: ${state.message}'),
//                 backgroundColor: Colors.red,
//               ),
//             );
//           }
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
//               const SizedBox(height: 24),
//               Text('Payment Method', style: Theme.of(context).textTheme.headlineSmall),
//               const SizedBox(height: 16),
//               if (stripePaymentMethod != null) ...[
//                 _buildStripePaymentSection(),
//                 const SizedBox(height: 24),
//                 _buildPlaceOrderButton(),
//                 const SizedBox(height: 24),
//                 _buildBillingAddressSection(),
//               ] else
//                 const Text("No supported payment methods available."),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ✅ THIS WIDGET IS NOW SECURE AND PCI-COMPLIANT
//   Widget _buildStripePaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             // You can replace this with a local asset if you prefer
//             Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//         // --- Use Stripe's secure, pre-built CardField widget ---
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(4.0),
//           ),
//           child: CardField(
//             onCardChanged: (details) {
//               // You can use this callback to enable/disable the place order button
//               // based on whether the card details are complete.
//               print('Card details complete: ${details?.complete}');
//             },
//           ),
//         ),
//         const SizedBox(height: 16),
//         const Row(
//           children: [
//             Icon(Icons.lock, color: Colors.green, size: 16),
//             SizedBox(width: 8),
//             Expanded(
//               child: Text(
//                 'Your card details are protected using PCI DSS v3.2 security standards.',
//                 style: TextStyle(fontSize: 12, color: Colors.black54),
//               ),
//             ),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget _buildPlaceOrderButton() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       builder: (context, state) {
//         // Disable button if BLoC is working OR if we are talking to Stripe
//         final isSubmitting = state is PaymentSubmitting || _isProcessing;
//         return ElevatedButton(
//           onPressed: isSubmitting ? null : _placeOrder,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black,
//             foregroundColor: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 16),
//             textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           child: isSubmitting
//               ? const SizedBox(
//             width: 24,
//             height: 24,
//             child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
//           )
//               : const Text('PLACE ORDER'),
//         );
//       },
//     );
//   }
//
//   // ✅ THIS IS THE CORE LOGIC IMPLEMENTATION
//   // lib/features/checkout/payment_screen.dart
//
// // ✅ THIS IS THE CORE LOGIC FOR THE WORKAROUND
//   // lib/features/checkout/payment_screen.dart
//
// // ✅ THIS IS THE CORE LOGIC FOR THE WORKAROUND
//   // lib/features/checkout/payment_screen.dart
//
//   void _placeOrder() async {
//     // Start local loading indicator immediately for better UX
//     if (mounted) {
//       setState(() { _isProcessing = true; });
//     }
//
//     try {
//       // ------------------- START OF THE FINAL FIX -------------------
//       // STEP 1: Create a modern "PaymentMethod" instead of a legacy token.
//       // This will generate a payment method with a 'pm_...' prefix.
//       print("--- 1. Requesting MODERN PaymentMethod from Stripe... ---");
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: const PaymentMethodParams.card(
//           paymentMethodData: PaymentMethodData(), // Uses data from the CardField
//         ),
//       );
//
//       print("--- 2. Stripe API Response (PaymentMethod Success!) ---");
//       print("PaymentMethod ID: ${paymentMethod.id}"); // This will be like "pm_card_..."
//       print("Card Brand: ${paymentMethod.card.brand}");
//       print("Card Last 4: ${paymentMethod.card.last4}");
//       print("-----------------------------------------------------");
//
//       // STEP 2: Dispatch the event to your BLoC with the modern PaymentMethod ID.
//       if (mounted) {
//         print("--- 3. Dispatching event to ShippingBloc... ---");
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments',
//             billingAddress: widget.billingAddress,
//             // Pass the modern 'pm_...' ID here. Your backend is ready for this.
//             paymentMethodNonce: paymentMethod.id,
//           ),
//         );
//       }
//       // -------------------- END OF THE FINAL FIX --------------------
//
//     } on StripeException catch (e) {
//       // This catches errors from Stripe's side (e.g., invalid card, network error).
//       print("--- Stripe SDK Error ---");
//       print(e.error.localizedMessage ?? e.toString());
//       print("-------------------------");
//       if (mounted) {
//         setState(() { _isProcessing = false; });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
//         );
//       }
//     } catch (e) {
//       // This catches any other unexpected errors.
//       print("--- Generic Error ---");
//       print(e.toString());
//       print("----------------------");
//       if (mounted) {
//         setState(() { _isProcessing = false; });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
//         );
//       }
//     }
//   }
//
//   // --- Omitted for brevity, your existing _buildEstimatedTotal and _buildBillingAddressSection methods are fine ---
//   Widget _buildEstimatedTotal(dynamic grandTotalValue, int qty) {
//     final grandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(4.0),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Estimated Total', style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 4),
//               Text(
//                 _currencyFormat.format(grandTotal),
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           Row(
//             children: [
//               const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 child: Text(
//                   qty.toString(),
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBillingAddressSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CheckboxListTile(
//           title: const Text('My billing and shipping address are the same'),
//           value: _isBillingSameAsShipping,
//           onChanged: (bool? value) {
//             setState(() {
//               _isBillingSameAsShipping = value ?? true;
//             });
//           },
//           controlAffinity: ListTileControlAffinity.leading,
//           contentPadding: EdgeInsets.zero,
//         ),
//         if (_isBillingSameAsShipping) ...[
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.only(left: 16.0),
//             child: Text(
//               '${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}\n'
//                   '${widget.billingAddress['street']?.join(', ')}\n'
//                   '${widget.billingAddress['city']}, ${widget.billingAddress['region']} ${widget.billingAddress['postcode']}\n'
//                   '${widget.billingAddress['country_id']}\n' // You might want to map this ID to a full country name
//                   '${widget.billingAddress['telephone']}',
//               style: const TextStyle(height: 1.5, color: Colors.black87),
//             ),
//           )
//         ]
//         // You can add another form here if the checkbox is unchecked
//       ],
//     );
//   }
// }