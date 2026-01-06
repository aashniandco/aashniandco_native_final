// lib/features/checkout/payment_screen.dart

import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/Payment/view/payu_webview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// ✅ REMOVED: flutter_multi_formatter is no longer needed.
import 'package:flutter_stripe/flutter_stripe.dart'; // ✅ IMPORT STRIPE
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Your BLoC and Screen imports (adjust paths as needed)
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../checkout/checkout_stepper.dart';
import '../../checkout/model/payment_gateway_type.dart';
import '../../profile/model/order_history.dart';
import '../../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../../shoppingbag/cart_bloc/cart_bloc.dart';
import '../../shoppingbag/cart_bloc/cart_event.dart';
import '../../shoppingbag/cart_bloc/cart_state.dart';
import '../../shoppingbag/model/countries.dart';
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// --- ASSUMED IMPORTS (Replace with your actual project paths) ---
// import 'package:your_app/blocs/cart/cart_bloc.dart';
// import 'package:your_app/blocs/currency/currency_bloc.dart';
// import 'package:your_app/blocs/shipping/shipping_bloc.dart';
// import 'package:your_app/repositories/shipping_repository.dart';
// import 'package:your_app/models/country_model.dart'; // Assuming Country/Region models exist
// import 'package:your_app/screens/order_success_screen.dart';
// import 'package:your_app/screens/payu_webview_screen.dart';
// import 'package:your_app/widgets/checkout_stepper.dart'; // Assumed stepper widget

class PaymentScreen extends StatefulWidget {
  final List<dynamic> paymentMethods;
  final Map<String, dynamic> totals;
  final Map<String, dynamic> billingAddress;
  final PaymentGatewayType selectedGateway;
  final String? guestEmail;

  // UI summary fields
  final String shippingMethodName;
  final double shippingCost;

  const PaymentScreen({
    Key? key,
    required this.paymentMethods,
    required this.totals,
    required this.billingAddress,
    required this.selectedGateway,
    this.guestEmail,
    this.shippingMethodName = "Standard Shipping",
    this.shippingCost = 0.0,
  }) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // --- STATE VARIABLES ---
  bool _isBillingSameAsShipping = true;
  bool _isProcessing = false;
  bool _isApplePayAvailable = false;
  bool _isCardEntryActive = false;

  // Logic to toggle between "Form" and "Text View" for custom billing address
  bool _showBillingForm = false;
  Map<String, dynamic>? _customBillingAddress;

  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController countryController = TextEditingController(); // Stores country name for UI

  final CardEditController _cardController = CardEditController();

  String? _selectedCountry; // Stores Country ID (e.g., 'IN', 'US')
  String? _selectedState;   // Stores Region Name or Code

  List<Country> _apiCountries = [];
  List<Region> _apiStates = [];

  // Repository
  late final ShippingRepository _shippingRepository = ShippingRepository();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with shipping address as a baseline
    _fillControllers(widget.billingAddress);

    // API Calls
    _fetchCountries();
    if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
      _fetchStates(_selectedCountry!);
    }
    _checkApplePaySupport();
    context.read<CartBloc>().add(FetchCartItems());

  }

  /// Helper to pre-fill controllers
  void _fillControllers(Map<String, dynamic> address) {
    _firstNameController.text = address['firstname'] ?? '';
    _lastNameController.text = address['lastname'] ?? '';
    _streetAddressController.text = (address['street'] is List)
        ? (address['street'] as List).join(', ')
        : address['street'] ?? '';
    _cityController.text = address['city'] ?? '';
    _zipCodeController.text = address['postcode'] ?? '';
    _phoneController.text = address['telephone'] ?? '';
    _selectedCountry = address['country_id'];
    _selectedState = address['region'];
    // Note: countryController.text (Name) will be set when the country list loads matching the ID
  }

  @override
  void dispose() {
    _cardController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    countryController.dispose();
    super.dispose();
  }

  // --- LOGIC: UTILITIES ---

  bool isPaymentMethodAvailable(String code) {
    try {
      widget.paymentMethods.firstWhere((m) => m['code'] == code);
      return true;
    } catch (e) {
      return false;
    }
  }

  // Returns the address object to send to the API
  Map<String, dynamic> _getFinalBillingAddress() {
    if (_isBillingSameAsShipping) {
      return widget.billingAddress;
    } else {
      // Return the custom address currently in the controllers/state
      // Ensure we validate availability first
      if (_customBillingAddress != null) {
        return {
          ..._customBillingAddress!,
          'email': widget.billingAddress['email'] ?? widget.guestEmail,
          'save_in_address_book': 0,
        };
      }

      // Fallback: Construct from controllers directly if user didn't click "Update"
      // but logic flows through (e.g. direct pay click while form is open - usually blocked by UI)
      return {
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'street': [_streetAddressController.text],
        'city': _cityController.text,
        'country_id': _selectedCountry,
        'region': _selectedState ?? '',
        'postcode': _zipCodeController.text,
        'telephone': _phoneController.text,
        'email': widget.billingAddress['email'] ?? widget.guestEmail,
        'save_in_address_book': 0,
      };
    }
  }


  // --- LOGIC: API & PAYMENTS ---

  Future<void> _checkApplePaySupport() async {
    try {
      if (Platform.isIOS) {
        bool isSupported = await Stripe.instance.isPlatformPaySupported();
        setState(() => _isApplePayAvailable = isSupported);
      }
    } catch (e) {
      if (kDebugMode) print("Error checking Apple Pay support: $e");
    }
  }

  Future<void> _fetchCountries() async {
    try {
      final url = Uri.parse('https://aashniandco.com/rest/V1/directory/countries');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _apiCountries = data.map((e) => Country.fromJson(e)).toList();
          // Try to set the country name for the controller if ID exists
          if (_selectedCountry != null) {
            try {
              final c = _apiCountries.firstWhere((e) => e.id == _selectedCountry);
              countryController.text = c.fullNameEnglish ?? '';
            } catch (_) {}
          }
        });
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching countries: $e');
    }
  }

  Future<void> _fetchStates(String countryCode) async {
    try {
      final url = Uri.parse('https://aashniandco.com/rest/V1/directory/countries/$countryCode');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> regionsJson = data['available_regions'] ?? [];
        setState(() {
          _apiStates = regionsJson.map((e) => Region.fromJson(e)).toList();
        });
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching states: $e");
    }
  }

  void _placeOrder() {
    // Validation: If using different billing address, ensure it's set
    if (!_isBillingSameAsShipping && _customBillingAddress == null && _showBillingForm) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please update your billing address first."))
      );
      return;
    }

    if (widget.selectedGateway == PaymentGatewayType.stripe) {
      _placeOrderWithStripe();
    } else if (widget.selectedGateway == PaymentGatewayType.payu) {
      _placeOrderWithPayU();
    }
  }

  // Future<void> _handleApplePay() async {
  //   setState(() => _isProcessing = true);
  //   try {
  //     final double grandTotal = (widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0;
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
  //
  //     final String currencyCode = currencyState.selectedCurrencyCode;
  //
  //     final applePayItems = [
  //       ApplePayCartSummaryItem.immediate(
  //         label: 'Aashni & Co',
  //         amount: grandTotal.toStringAsFixed(2),
  //       )
  //     ];
  //
  //     final paymentMethod = await Stripe.instance.createPlatformPayPaymentMethod(
  //       params: PlatformPayPaymentMethodParams.applePay(
  //         applePayParams: ApplePayParams(
  //           cartItems: applePayItems,
  //           requiredShippingAddressFields: [],
  //           requiredBillingContactFields: [],
  //           merchantCountryCode: 'IN',
  //           currencyCode: currencyCode,
  //         ),
  //       ),
  //     );
  //
  //     if (mounted) {
  //       context.read<ShippingBloc>().add(
  //         SubmitPaymentInfo(
  //           paymentMethodCode: 'stripe_payments',
  //           billingAddress: _getFinalBillingAddress(),
  //           paymentMethodNonce: paymentMethod.paymentMethod.id,
  //           currencyCode: currencyCode,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //     }
  //   }
  // }
  // Future<void> _handleApplePay() async {
  //   setState(() => _isProcessing = true);
  //   try {
  //     // Get the Total Amount
  //     final double grandTotal = (widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0;
  //
  //     // Get Current Currency (But we might force USD for testing)
  //     final currencyState = context.read<CurrencyBloc>().state;
  //     String appCurrencyCode = 'INR';
  //     if (currencyState is CurrencyLoaded) {
  //       appCurrencyCode = currencyState.selectedCurrencyCode;
  //     }
  //
  //     // Prepare Cart Item
  //     final applePayItems = [
  //       ApplePayCartSummaryItem.immediate(
  //         label: 'Aashni & Co',
  //         amount: grandTotal.toStringAsFixed(2),
  //       )
  //     ];
  //
  //     // --- THE CRITICAL PART FOR INDIA TESTING ---
  //     final paymentMethod = await Stripe.instance.createPlatformPayPaymentMethod(
  //       params: PlatformPayPaymentMethodParams.applePay(
  //         applePayParams: ApplePayParams(
  //           cartItems: applePayItems,
  //           requiredShippingAddressFields: [],
  //           requiredBillingContactFields: [],
  //
  //           // MUST MATCH your Apple Developer Merchant ID
  //
  //
  //           // TRICK: Force 'US' to bypass India region lock
  //           merchantCountryCode: 'US',
  //
  //           // TRICK: Force 'USD' for the Apple Sheet to open successfully
  //           // (You can try 'INR' first, but if it fails, switch to 'USD')
  //           currencyCode: 'USD',
  //         ),
  //       ),
  //     );
  //
  //     // --- SUBMIT TOKEN TO YOUR BACKEND ---
  //     if (mounted) {
  //       context.read<ShippingBloc>().add(
  //         SubmitPaymentInfo(
  //           paymentMethodCode: 'stripe_payments',
  //           billingAddress: _getFinalBillingAddress(),
  //           paymentMethodNonce: paymentMethod.paymentMethod.id, // The Token
  //           currencyCode: appCurrencyCode, // Send actual currency to Magento
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       // Ignore "User Cancelled" errors
  //       if(e.toString().contains('Canceled')) return;
  //
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple Pay Error: ${e.toString()}')));
  //     }
  //   }
  // }

  Future<void> _handleApplePay() async {
    setState(() => _isProcessing = true);
    try {
      // 1. Get Currency Info & Exchange Rate
      final currencyState = context.read<CurrencyBloc>().state;
      String realCurrencyCode = 'INR';
      double exchangeRate = 1.0;

      if (currencyState is CurrencyLoaded) {
        realCurrencyCode = currencyState.selectedCurrencyCode;
        exchangeRate = currencyState.selectedRate.rate; // ✅ GET THE RATE
      }

      // 2. Get Base Total (INR)
      final double baseGrandTotal = (widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0;

      // 3. Calculate Display Total (Euro/USD/GBP)
      // ✅ Multiply by rate to get 14.49 instead of 1544
      final double finalDisplayAmount = baseGrandTotal * exchangeRate;

      final applePayItems = [
        ApplePayCartSummaryItem.immediate(
          label: 'Aashni & Co',
          // ✅ Convert the CALCULATED amount to string
          amount: finalDisplayAmount.toStringAsFixed(2),
        )
      ];

      final paymentMethod = await Stripe.instance.createPlatformPayPaymentMethod(
        params: PlatformPayPaymentMethodParams.applePay(
          applePayParams: ApplePayParams(
            cartItems: applePayItems,
            requiredShippingAddressFields: [],
            requiredBillingContactFields: [],
            merchantCountryCode: 'US',
            currencyCode: realCurrencyCode,
          ),
        ),
      );

      if (mounted) {
        context.read<ShippingBloc>().add(
          SubmitPaymentInfo(
            paymentMethodCode: 'stripe_payments',
            billingAddress: _getFinalBillingAddress(),
            paymentMethodNonce: paymentMethod.paymentMethod.id,
            currencyCode: realCurrencyCode,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        if (e.toString().contains('Canceled')) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Apple Pay Error: ${e.toString()}')));
      }
    }
  }

  Future<void> _placeOrderWithStripe() async {
    // 1. VALIDATION: Check if card details are complete
    if (_cardController.details.complete != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid card details. The card information cannot be empty.'),
          backgroundColor: Colors.black,
        ),
      );
      return; // Stop the process here
    }

    if (mounted) setState(() => _isProcessing = true);

    try {
      // 2. Proceed with Stripe payment method creation
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      if (mounted) {
        final currencyState = context.read<CurrencyBloc>().state;
        if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");

        context.read<ShippingBloc>().add(
          SubmitPaymentInfo(
            paymentMethodCode: 'stripe_payments',
            billingAddress: _getFinalBillingAddress(),
            paymentMethodNonce: paymentMethod.id,
            currencyCode: currencyState.selectedCurrencyCode,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        // Friendly error message for users
        String errorMsg = e.toString();
        if (errorMsg.contains("payment_method_data[card]")) {
          errorMsg = "Card details are missing or invalid.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
      }
    }
  }



  // Future<void> _placeOrderWithStripe() async {
  //   if (mounted) setState(() => _isProcessing = true);
  //   try {
  //     final paymentMethod = await Stripe.instance.createPaymentMethod(
  //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
  //     );
  //
  //     if (mounted) {
  //       final currencyState = context.read<CurrencyBloc>().state;
  //       if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
  //
  //       context.read<ShippingBloc>().add(
  //         SubmitPaymentInfo(
  //           paymentMethodCode: 'stripe_payments',
  //           billingAddress: _getFinalBillingAddress(),
  //           paymentMethodNonce: paymentMethod.id,
  //           currencyCode: currencyState.selectedCurrencyCode,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       setState(() => _isProcessing = false);
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
  //     }
  //   }
  // }

  Future<void> _placeOrderWithPayU() async {
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      final guestEmail = prefs.getString('user_email');
      final guestQuoteId = prefs.getString('guest_quote_id');

      final isLoggedIn = token != null && token.isNotEmpty;
      final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;

      if (!isLoggedIn && !isGuest) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No session found.'), backgroundColor: Colors.red));
        return;
      }

      final currencyState = context.read<CurrencyBloc>().state;
      if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
      final currencyCode = currencyState.selectedCurrencyCode;

      final payUData = await _shippingRepository.initiatePayUPayment(
        currencyCode: currencyCode,
        billingAddress: _getFinalBillingAddress(),
      );

      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
      );

      if (result != 'Success') {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed or canceled.'), backgroundColor: Colors.red));
        return;
      }

      final txnid = payUData['txnid'] as String;
      context.read<ShippingBloc>().add(
        FinalizePayUOrder(
          txnid: txnid,
          currencyCode: currencyCode,
          guestQuoteId: isGuest ? guestQuoteId : null,
          guestEmail: isGuest ? guestEmail : null,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    }
  }

  // --- UI BUILD ---

  @override
  @override
  Widget build(BuildContext context) {
    // 1. Get Currency State
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double currencyRate = 1.0;
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      currencyRate = currencyState.selectedRate.rate;
    }

    // 2. Get Cart Items (For the images in the bottom bar)
    final cartState = context.watch<CartBloc>().state;
    // final List<dynamic> cartItems = (cartState is CartLoaded) ? cartState.items : [];

    List<dynamic> cartItems = [];
    bool isLoadingCart = false;

    if (cartState is CartLoaded) {
      cartItems = cartState.items;
    } else if (cartState is CartLoading) {
      isLoadingCart = true;
    }

    // 3. Determine payment code
    String selectedPaymentCode;
    if (widget.selectedGateway == PaymentGatewayType.stripe) {
      selectedPaymentCode = 'stripe_payments';
    } else if (widget.selectedGateway == PaymentGatewayType.payu) {
      selectedPaymentCode = 'payu';
    } else {
      selectedPaymentCode = 'unknown';
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Purchase', style: TextStyle(color: Colors.black, fontFamily: 'Serif', fontSize: 24)),
      ),
      body: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) {
          // ... (Keep your existing listener code) ...
          if (state is PaymentSuccess || state is ShippingError) {
            if (mounted) setState(() => _isProcessing = false);
          }
          if (state is PaymentSuccess) {
                      final cartState = context.read<CartBloc>().state;
                      final cartItems = (cartState is CartLoaded) ? cartState.items : [];

                      // Determine address used for Success Screen
                      Map<String, dynamic> finalAddressUsed;
                      try {
                        finalAddressUsed = _getFinalBillingAddress();
                      } catch (e) {
                        finalAddressUsed = widget.billingAddress;
                      }

                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OrderSuccessScreen(
                            orderId: state.orderId,
                            totals: widget.totals,
                            billingAddress: finalAddressUsed,
                            items: cartItems,
                            paymentMethodCode: selectedPaymentCode,
                            guestEmail: widget.guestEmail,
                          ),
                        ),
                            (route) => false,
                      );
                    }

          else if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Column(
          children: [
            // STEPPER
            const CheckoutStepper(currentStep: 2),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ... (Keep all your existing scrollable content) ...
                    const SizedBox(height: 10),
                    const Text('Review & Pay', style: TextStyle(fontSize: 22, fontFamily: 'Serif', fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    _buildSectionHeader("SHIP TO"),
                    const SizedBox(height: 8),
                    // Text("${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}".toUpperCase()),
                    // ... rest of your address widgets ...
                    _buildAddressText(widget.billingAddress),
                    _buildChangeLink(),
                    const SizedBox(height: 24),
                    _buildSectionHeader("PAYMENT DETAILS"),
                    const SizedBox(height: 12),
                    if (widget.selectedGateway == PaymentGatewayType.stripe)
                      if (isPaymentMethodAvailable('stripe_payments'))
                        _buildStripePaymentSection()
                      else
                        const Center(child: Text("Stripe is not available."))
                    else if (widget.selectedGateway == PaymentGatewayType.payu)
                      _buildPayUPaymentSection(),

                    const SizedBox(height: 24),
                    _buildBillingAddressSection(),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1),
                    const SizedBox(height: 12),

                    // Keep this summary here if you want it in the scroll,
                    // or remove it if you only want the bottom bar.
                    _buildOrderTotalsSummary(displaySymbol, currencyRate),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // ---------------------------------------------------------
            // ✅ NEW BOTTOM SECTION (Summary + Button)
            // ---------------------------------------------------------
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The Image/Total Summary Bar
                    _buildBottomCartSummary(cartItems, displaySymbol, currencyRate,isLoadingCart),

                    // The Place Order Button
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: _buildPlaceOrderButton(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // Widget _buildBottomCartSummary(List<dynamic> cartItems, String symbol, double rate) {
  //
  //   // Calculate display total based on currency rate
  //   double grandTotal = ((widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0) * rate;
  //   int qty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
  //
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  //     decoration: BoxDecoration(
  //       border: Border(top: BorderSide(color: Colors.grey[200]!)),
  //     ),
  //     child: Row(
  //       children: [
  //         // 1. Expand Icon
  //         const Icon(Icons.keyboard_arrow_up, color: Colors.black54),
  //         const SizedBox(width: 8),
  //
  //         // 2. Item Count
  //         Text(
  //           "$qty",
  //           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
  //         ),
  //         const SizedBox(width: 12),
  //
  //         // 3. Product Images (Updated Logic)
  //         Expanded(
  //           child: SizedBox(
  //             height: 40,
  //             child: cartItems.isEmpty
  //                 ? const Text("No items", style: TextStyle(fontSize: 10, color: Colors.grey))
  //                 : ListView.separated(
  //               scrollDirection: Axis.horizontal,
  //               itemCount: cartItems.length > 3 ? 3 : cartItems.length,
  //               separatorBuilder: (_, __) => const SizedBox(width: 8),
  //               itemBuilder: (context, index) {
  //                 final item = cartItems[index];
  //
  //                 // ✅ ROBUST IMAGE EXTRACTOR
  //                 String? imageUrl = _extractImageUrl(item);
  //
  //                 return Container(
  //                   width: 30,
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.grey[300]!),
  //                     borderRadius: BorderRadius.circular(4),
  //                     color: Colors.grey[100],
  //                   ),
  //                   child: imageUrl != null && imageUrl.isNotEmpty
  //                       ? ClipRRect(
  //                     borderRadius: BorderRadius.circular(3),
  //                     child: Image.network(
  //                       imageUrl,
  //                       fit: BoxFit.cover,
  //                       errorBuilder: (ctx, err, stack) => const Icon(Icons.broken_image, size: 16, color: Colors.grey),
  //                     ),
  //                   )
  //                   // Show a default icon if no image URL found
  //                       : const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
  //                 );
  //               },
  //             ),
  //           ),
  //         ),
  //
  //         const SizedBox(width: 10),
  //
  //         // 4. TOTAL Price
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.end,
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             const Text(
  //               "TOTAL",
  //               style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.grey),
  //             ),
  //             Text(
  //               "$symbol${grandTotal.toStringAsFixed(2)}",
  //               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildBottomCartSummary(List<dynamic> cartItems, String symbol, double rate, bool isLoading) {
    double grandTotal = ((widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0) * rate;
    int qty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // 1. Expand Icon
          const Icon(Icons.keyboard_arrow_up, color: Colors.black54),
          const SizedBox(width: 8),

          // 2. Qty
          Text("$qty", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 12),

          // 3. Product Images (With Loading State)
          Expanded(
            child: SizedBox(
              height: 40,
              child: isLoading
                  ? const Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)
                ),
              )
                  : cartItems.isEmpty
                  ? const Text("No items found", style: TextStyle(fontSize: 10, color: Colors.grey))
                  : ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cartItems.length > 3 ? 3 : cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  String? imageUrl = _extractImageUrl(item);

                  return Container(
                    width: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[100],
                    ),
                    child: imageUrl != null && imageUrl.isNotEmpty
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 14, color: Colors.grey),
                      ),
                    )
                        : const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          const SizedBox(width: 10),

          // 4. Total
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
              Text("$symbol${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

// ✅ HELPER: Add this method inside your _PaymentScreenState class
// Helper method to extract image URL based on your OrderItem11 model
  String? _extractImageUrl(dynamic item) {
    print("DEBUG IMAGE ITEM: $item");
    try {
      // 1. If the item is already an instance of your class OrderItem11
      if (item is OrderItem11) {
        return item.imageUrl;
      }

      // 2. If the item is a generic Map (JSON)
      if (item is Map) {
        // Your model uses 'image_url', so we check that first
        return item['image_url']
            ?? item['extension_attributes']?['image_url'] // Common Magento path
            ?? item['product_image'] // Another common path
            ?? item['small_image'];
      }

      // 3. If item is a different object type (e.g. CartItem), try dynamic access
      return (item as dynamic).imageUrl
          ?? (item as dynamic).extensionAttributes?.imageUrl;

    } catch (e) {
      return null;
    }
  }
  // Widget build(BuildContext context) {
  //   // 1. Get Currency State
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //   String displaySymbol = '₹';
  //   double currencyRate = 1.0;
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     currencyRate = currencyState.selectedRate.rate;
  //   }
  //
  //   // 2. Determine payment code
  //   String selectedPaymentCode;
  //   if (widget.selectedGateway == PaymentGatewayType.stripe) {
  //     selectedPaymentCode = 'stripe_payments';
  //   } else if (widget.selectedGateway == PaymentGatewayType.payu) {
  //     selectedPaymentCode = 'payu';
  //   } else {
  //     selectedPaymentCode = 'unknown';
  //   }
  //
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     appBar: AppBar(
  //       backgroundColor: Colors.white,
  //       elevation: 0,
  //       centerTitle: true,
  //       iconTheme: const IconThemeData(color: Colors.black),
  //       title: const Text('Purchase', style: TextStyle(color: Colors.black, fontFamily: 'Serif', fontSize: 24)),
  //     ),
  //     body: BlocListener<ShippingBloc, ShippingState>(
  //       listener: (context, state) {
  //         if (state is PaymentSuccess || state is ShippingError) {
  //           if (mounted) setState(() => _isProcessing = false);
  //         }
  //
  //         if (state is PaymentSuccess) {
  //           final cartState = context.read<CartBloc>().state;
  //           final cartItems = (cartState is CartLoaded) ? cartState.items : [];
  //
  //           // Determine address used for Success Screen
  //           Map<String, dynamic> finalAddressUsed;
  //           try {
  //             finalAddressUsed = _getFinalBillingAddress();
  //           } catch (e) {
  //             finalAddressUsed = widget.billingAddress;
  //           }
  //
  //           Navigator.pushAndRemoveUntil(
  //             context,
  //             MaterialPageRoute(
  //               builder: (_) => OrderSuccessScreen(
  //                 orderId: state.orderId,
  //                 totals: widget.totals,
  //                 billingAddress: finalAddressUsed,
  //                 items: cartItems,
  //                 paymentMethodCode: selectedPaymentCode,
  //                 guestEmail: widget.guestEmail,
  //               ),
  //             ),
  //                 (route) => false,
  //           );
  //         } else if (state is ShippingError) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(content: Text('Payment Failed: ${state.message}'), backgroundColor: Colors.red),
  //           );
  //         }
  //       },
  //       child: Column(
  //         children: [
  //           // STEPPER
  //           const CheckoutStepper(currentStep: 2),
  //
  //           Expanded(
  //             child: SingleChildScrollView(
  //               padding: const EdgeInsets.symmetric(horizontal: 20),
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   const SizedBox(height: 10),
  //                   const Text('Review & Pay', style: TextStyle(fontSize: 22, fontFamily: 'Serif', fontWeight: FontWeight.bold)),
  //                   const SizedBox(height: 20),
  //
  //                   // SHIP TO SUMMARY
  //                   _buildSectionHeader("SHIP TO"),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     "${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}".toUpperCase(),
  //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //                   ),
  //                   Text(
  //                     "${widget.billingAddress['street'] is List ? (widget.billingAddress['street'] as List).join(', ') : widget.billingAddress['street']}\n"
  //                         "${widget.billingAddress['city']}, ${widget.billingAddress['region']}\n"
  //                         "${widget.billingAddress['country_id']}".toUpperCase(),
  //                     style: const TextStyle(height: 1.4, fontSize: 14, color: Colors.black87),
  //                   ),
  //                   _buildChangeLink(),
  //                   const SizedBox(height: 24),
  //
  //                   // SHIPPING OPTIONS SUMMARY
  //                   // _buildSectionHeader("SHIPPING OPTIONS"),
  //                   const SizedBox(height: 8),
  //                   // Row(
  //                   //   children: [
  //                   //     const Icon(Icons.local_shipping_outlined, size: 20),
  //                   //     const SizedBox(width: 8),
  //                   //     Expanded(
  //                   //       child: Column(
  //                   //         crossAxisAlignment: CrossAxisAlignment.start,
  //                   //         children: [
  //                   //           Text(widget.shippingMethodName, style: const TextStyle(fontWeight: FontWeight.bold)),
  //                   //           Text(
  //                   //             "Price: $displaySymbol${(widget.shippingCost * currencyRate).toStringAsFixed(2)}",
  //                   //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
  //                   //           ),
  //                   //         ],
  //                   //       ),
  //                   //     ),
  //                   //   ],
  //                   // ),
  //                   // _buildChangeLink(),
  //                   // const SizedBox(height: 24),
  //
  //                   // PACKAGING
  //                   // _buildSectionHeader("PACKAGING"),
  //                   // const SizedBox(height: 8),
  //                   // const Text("Standard Packaging", style: TextStyle(fontWeight: FontWeight.bold)),
  //                   // const Text("A discreet, recyclable box.", style: TextStyle(fontSize: 12, color: Colors.grey)),
  //                   // const SizedBox(height: 24),
  //
  //                   // PAYMENT DETAILS
  //                   _buildSectionHeader("PAYMENT DETAILS"),
  //                   const SizedBox(height: 12),
  //                   if (widget.selectedGateway == PaymentGatewayType.stripe)
  //                     if (isPaymentMethodAvailable('stripe_payments'))
  //                       _buildStripePaymentSection()
  //                     else
  //                       const Center(child: Text("Stripe is not available."))
  //                   else if (widget.selectedGateway == PaymentGatewayType.payu)
  //                     if (isPaymentMethodAvailable('payu'))
  //                       _buildPayUPaymentSection()
  //                     else
  //                       const Center(child: Text("PayU Money is not available.")),
  //
  //                   const SizedBox(height: 24),
  //
  //                   // BILLING ADDRESS
  //                   _buildBillingAddressSection(),
  //
  //                   const SizedBox(height: 24),
  //                   const Divider(thickness: 1),
  //                   const SizedBox(height: 12),
  //
  //                   // ORDER TOTALS
  //                   _buildOrderTotalsSummary(displaySymbol, currencyRate),
  //                   const SizedBox(height: 30),
  //                 ],
  //               ),
  //             ),
  //           ),
  //
  //           // PLACE ORDER BUTTON
  //           Container(
  //             padding: const EdgeInsets.all(20),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               border: Border(top: BorderSide(color: Colors.grey[200]!)),
  //             ),
  //             child: SafeArea(child: _buildPlaceOrderButton()),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // --- WIDGETS: BILLING ADDRESS SECTION ---

  Widget _buildBillingAddressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("BILLING ADDRESS"),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: const Text('My billing and shipping address are the same', style: TextStyle(fontSize: 14)),
          value: _isBillingSameAsShipping,
          onChanged: (bool? value) {
            setState(() {
              _isBillingSameAsShipping = value ?? true;
              if (_isBillingSameAsShipping) {
                // Revert to shipping address
                _showBillingForm = false;
                _customBillingAddress = null;
                // Optional: reset controllers
                _fillControllers(widget.billingAddress);
              } else {
                // Unchecked
                if (_customBillingAddress == null) {
                  _showBillingForm = true; // Show form if no custom address saved yet
                } else {
                  _showBillingForm = false; // Show text if custom address exists
                }
              }
            });
          },
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          dense: true,
          activeColor: Colors.black,
        ),

        // 1. Same as Shipping (Show Shipping Text)
        if (_isBillingSameAsShipping) ...[
          _buildAddressText(widget.billingAddress),
        ]
        // 2. Custom Address Form (Edit Mode)
        else if (_showBillingForm) ...[
          const SizedBox(height: 16),
          _buildTextField(controller: _firstNameController, labelText: 'First Name', isRequired: true),
          _buildTextField(controller: _lastNameController, labelText: 'Last Name', isRequired: true),
          _buildTextField(controller: _streetAddressController, labelText: 'Street Address', isRequired: true),
          _buildTextField(controller: _cityController, labelText: 'City', isRequired: true),
          _buildCountryDropdown(),
          _buildStateDropdown(),
          _buildTextField(controller: _zipCodeController, labelText: 'Zip/Postal Code', isRequired: true, keyboardType: TextInputType.number),
          _buildTextField(controller: _phoneController, labelText: 'Phone Number', isRequired: true, keyboardType: TextInputType.phone),

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Validation
                    if (_firstNameController.text.isEmpty || _streetAddressController.text.isEmpty ||
                        _cityController.text.isEmpty || _zipCodeController.text.isEmpty || _selectedCountry == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in required fields")));
                      return;
                    }

                    // Try to resolve IDs to names for UI display if possible
                    String? countryName = countryController.text; // already set by dropdown
                    // Region name is already in _selectedState if dropdown used

                    setState(() {
                      _customBillingAddress = {
                        'firstname': _firstNameController.text,
                        'lastname': _lastNameController.text,
                        'street': [_streetAddressController.text],
                        'city': _cityController.text,
                        'country_id': _selectedCountry,
                        // Not strictly needed for API but good for UI text display:
                        'country_name': countryName,
                        'region': _selectedState,
                        'postcode': _zipCodeController.text,
                        'telephone': _phoneController.text,
                      };
                      _showBillingForm = false; // Hide form, show updated text
                    });

                    FocusScope.of(context).unfocus();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Billing address updated.")));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Update Billing Address'),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isBillingSameAsShipping = true;
                    _showBillingForm = false;
                    _customBillingAddress = null;
                  });
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
              ),
            ],
          ),
        ]
        // 3. Custom Address Text (View Mode)
        else ...[
            if (_customBillingAddress != null)
              _buildAddressText(_customBillingAddress!),

            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: InkWell(
                onTap: () {
                  setState(() => _showBillingForm = true);
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("Edit Billing Address", style: TextStyle(decoration: TextDecoration.underline, fontSize: 13, color: Colors.blue)),
                ),
              ),
            ),
          ],
      ],
    );
  }

  // --- WIDGETS: FORM HELPERS ---

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: isRequired ? '$labelText *' : labelText,
          labelStyle: const TextStyle(fontSize: 13),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    final sortedCountries = List<Country>.from(_apiCountries)
      ..sort((a, b) => (a.fullNameEnglish ?? '').compareTo(b.fullNameEnglish ?? ''));

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration('Country'),
        value: countryController.text.isNotEmpty ? countryController.text : null,
        hint: const Text("Select Country", style: TextStyle(fontSize: 13)),
        isExpanded: true,
        items: sortedCountries
            .where((country) => country.fullNameEnglish != null)
            .map((Country country) {
          return DropdownMenuItem<String>(
            value: country.fullNameEnglish,
            child: Text(country.fullNameEnglish ?? '', style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            countryController.text = value ?? '';
            try {
              _selectedCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == value).id;
              _selectedState = null;
              if (_selectedCountry != null) _fetchStates(_selectedCountry!);
            } catch (_) {}
          });
        },
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: DropdownButtonFormField<String>(
        decoration: _inputDecoration("State / Province"),
        value: _selectedState,
        isExpanded: true,
        hint: const Text("Select State / Province", style: TextStyle(fontSize: 13)),
        items: _apiStates.map((region) {
          return DropdownMenuItem<String>(
            value: region.name,
            child: Text(region.name, style: const TextStyle(fontSize: 14)),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedState = value;
          });
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: const OutlineInputBorder(),
      isDense: true,
    );
  }

  Widget _buildAddressText(Map<String, dynamic> address) {
    String street = (address['street'] is List)
        ? (address['street'] as List).join(', ')
        : address['street'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 4),
      child: Text(
        '${address['firstname']} ${address['lastname']}\n'
            '$street\n'
            '${address['city']}, ${address['region'] ?? ''} ${address['postcode']}\n'
            '${address['country_id']}\n'
            '${address['telephone'] ?? ''}'.toUpperCase(),
        style: const TextStyle(height: 1.5, color: Colors.black, fontSize: 13),
      ),
    );
  }

  // --- WIDGETS: LAYOUT HELPERS ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black54),
    );
  }

  Widget _buildChangeLink() {
    return InkWell(
      onTap: () { Navigator.pop(context); },
      child: const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text("Change", style: TextStyle(decoration: TextDecoration.underline, fontSize: 13)),
      ),
    );
  }

  Widget _buildOrderTotalsSummary(String symbol, double rate) {
    double sub = ((widget.totals['subtotal'] as num?)?.toDouble() ?? 0.0) * rate;
    double ship = ((widget.totals['shipping_amount'] as num?)?.toDouble() ?? 0.0) * rate;
    double tax = ((widget.totals['tax_amount'] as num?)?.toDouble() ?? 0.0) * rate;
    double grand = ((widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0) * rate;

    return Column(
      children: [
        _buildRow("Item subtotal", "$symbol${sub.toStringAsFixed(2)}"),
        const SizedBox(height: 8),
        _buildRow("Shipping", "$symbol${ship.toStringAsFixed(2)}"),
        if (tax > 0) ...[
          const SizedBox(height: 8),
          _buildRow("Tax", "$symbol${tax.toStringAsFixed(2)}"),
        ],
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("$symbol${grand.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        )
      ],
    );
  }


  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return BlocBuilder<ShippingBloc, ShippingState>(
      builder: (context, state) {
        final isSubmitting = state is PaymentSubmitting || _isProcessing;
        return SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isSubmitting ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }

  Widget _buildStripePaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.credit_card, size: 20),
          ],
        ),
        const SizedBox(height: 16),

        // Detect tap on the card area
        GestureDetector(
          onTap: () {
            if (!_isCardEntryActive) {
              setState(() => _isCardEntryActive = true);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: _isCardEntryActive ? Colors.black : Colors.grey.shade400,
                width: _isCardEntryActive ? 1.5 : 1.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
              color: Colors.white,
            ),
            child: CardField(
              controller: _cardController,
              enablePostalCode: false,
              style: const TextStyle(fontSize: 15, color: Colors.black),
              decoration: const InputDecoration(border: InputBorder.none),
              // Detect when user starts typing
              onCardChanged: (card) {
                if (!_isCardEntryActive && card != null) {
                  setState(() => _isCardEntryActive = true);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 8),
        const Row(
          children: [
            Icon(Icons.lock, color: Colors.green, size: 14),
            SizedBox(width: 5),
            Expanded(
              child: Text(
                  'Protected by PCI DSS security standards.',
                  style: TextStyle(fontSize: 11, color: Colors.grey)
              ),
            ),
          ],
        ),

        // ✅ ONLY show Apple Pay if the user has NOT clicked/started entering Card details
        if (_isApplePayAvailable && !_isCardEntryActive) ...[
          const SizedBox(height: 20),
          const Row(children: [
            Expanded(child: Divider()),
            Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
            Expanded(child: Divider()),
          ]),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: PlatformPayButton(
              type: PlatformButtonType.buy,
              appearance: PlatformButtonStyle.black,
              onPressed: _handleApplePay,
            ),
          ),
        ],

        // ✅ Optional: Add a way to go back to Apple Pay if they change their mind
        if (_isCardEntryActive && _isApplePayAvailable)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => setState(() => _isCardEntryActive = false),
              child: const Text("Pay with Apple Pay instead",
                  style: TextStyle(fontSize: 12, decoration: TextDecoration.underline)),
            ),
          ),
      ],
    );
  }
  // Widget _buildStripePaymentSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Row(
  //         children: [
  //           Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //           SizedBox(width: 8),
  //           Icon(Icons.credit_card, size: 20),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       Container(
  //         padding: const EdgeInsets.all(12.0),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey.shade400),
  //           borderRadius: BorderRadius.circular(4.0),
  //         ),
  //         child: const CardField(
  //           enablePostalCode: false,
  //           style: TextStyle(fontSize: 15, color: Colors.black),
  //           decoration: InputDecoration(border: InputBorder.none),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       const Row(
  //         children: [
  //           Icon(Icons.lock, color: Colors.green, size: 14),
  //           SizedBox(width: 5),
  //           Expanded(child: Text('Protected by PCI DSS security standards.', style: TextStyle(fontSize: 11, color: Colors.grey))),
  //         ],
  //       ),
  //
  //       // ✅ NEW: UNCOMMENT THIS BLOCK FOR APPLE PAY
  //       if (_isApplePayAvailable) ...[
  //         const SizedBox(height: 20),
  //         const Row(children: [
  //           Expanded(child: Divider()),
  //           Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
  //           Expanded(child: Divider()),
  //         ]),
  //         const SizedBox(height: 10),
  //         SizedBox(
  //           width: double.infinity,
  //           height: 48,
  //           child: PlatformPayButton(
  //             type: PlatformButtonType.buy,
  //             appearance: PlatformButtonStyle.black,
  //             onPressed: _handleApplePay, // Links to the function above
  //           ),
  //         ),
  //       ],
  //     ],
  //   );
  // }

  // Widget _buildStripePaymentSection() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Row(
  //         children: [
  //           Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //           SizedBox(width: 8),
  //           Icon(Icons.credit_card, size: 20),
  //         ],
  //       ),
  //       const SizedBox(height: 16),
  //       Container(
  //         padding: const EdgeInsets.all(12.0),
  //         decoration: BoxDecoration(
  //           border: Border.all(color: Colors.grey.shade400),
  //           borderRadius: BorderRadius.circular(4.0),
  //         ),
  //         child: const CardField(
  //           enablePostalCode: false,
  //           style: TextStyle(fontSize: 15, color: Colors.black),
  //           decoration: InputDecoration(border: InputBorder.none),
  //         ),
  //       ),
  //       const SizedBox(height: 8),
  //       const Row(
  //         children: [
  //           Icon(Icons.lock, color: Colors.green, size: 14),
  //           SizedBox(width: 5),
  //           Expanded(child: Text('Protected by PCI DSS security standards.', style: TextStyle(fontSize: 11, color: Colors.grey))),
  //         ],
  //       ),
  //       // Apple Pay
  //       // if (_isApplePayAvailable) ...[
  //       //   const SizedBox(height: 20),
  //       //   SizedBox(
  //       //     width: double.infinity,
  //       //     height: 48,
  //       //     child: PlatformPayButton(
  //       //       type: PlatformButtonType.buy,
  //       //       appearance: PlatformButtonStyle.black,
  //       //       onPressed: _handleApplePay,
  //       //     ),
  //       //   ),
  //       //   const SizedBox(height: 20),
  //       //   const Row(children: [
  //       //     Expanded(child: Divider()),
  //       //     Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
  //       //     Expanded(child: Divider()),
  //       //   ]),
  //       // ],
  //     ],
  //   );
  // }

  Widget _buildPayUPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('PayU Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.payment, color: Colors.green, size: 20),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
          child: const Text(
            "You will be redirected to the secure PayU gateway to complete your payment.",
            style: TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}



//15/12/2025
// class PaymentScreen extends StatefulWidget {
//   final List<dynamic> paymentMethods;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final PaymentGatewayType selectedGateway;
//   final String? guestEmail;
//
//   // UI summary fields
//   final String shippingMethodName;
//   final double shippingCost;
//
//   const PaymentScreen({
//     Key? key,
//     required this.paymentMethods,
//     required this.totals,
//     required this.billingAddress,
//     required this.selectedGateway,
//     this.guestEmail,
//     this.shippingMethodName = "Standard Shipping",
//     this.shippingCost = 0.0,
//   }) : super(key: key);
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   // --- STATE VARIABLES ---
//   bool _isBillingSameAsShipping = true;
//   bool _isProcessing = false;
//   bool _isApplePayAvailable = false;
//
//   // Logic to toggle between "Form" and "Text View" for custom billing address
//   bool _showBillingForm = false;
//   Map<String, dynamic>? _customBillingAddress;
//
//   // Controllers
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipCodeController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController countryController = TextEditingController(); // Stores country name for UI
//
//   String? _selectedCountry; // Stores Country ID (e.g., 'IN', 'US')
//   String? _selectedState;   // Stores Region Name or Code
//
//   List<Country> _apiCountries = [];
//   List<Region> _apiStates = [];
//
//   // Repository
//   late final ShippingRepository _shippingRepository = ShippingRepository();
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with shipping address as a baseline
//     _fillControllers(widget.billingAddress);
//
//     // API Calls
//     _fetchCountries();
//     if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
//       _fetchStates(_selectedCountry!);
//     }
//     _checkApplePaySupport();
//   }
//
//   /// Helper to pre-fill controllers
//   void _fillControllers(Map<String, dynamic> address) {
//     _firstNameController.text = address['firstname'] ?? '';
//     _lastNameController.text = address['lastname'] ?? '';
//     _streetAddressController.text = (address['street'] is List)
//         ? (address['street'] as List).join(', ')
//         : address['street'] ?? '';
//     _cityController.text = address['city'] ?? '';
//     _zipCodeController.text = address['postcode'] ?? '';
//     _phoneController.text = address['telephone'] ?? '';
//     _selectedCountry = address['country_id'];
//     _selectedState = address['region'];
//     // Note: countryController.text (Name) will be set when the country list loads matching the ID
//   }
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _zipCodeController.dispose();
//     _phoneController.dispose();
//     countryController.dispose();
//     super.dispose();
//   }
//
//   // --- LOGIC: UTILITIES ---
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
//   // Returns the address object to send to the API
//   Map<String, dynamic> _getFinalBillingAddress() {
//     if (_isBillingSameAsShipping) {
//       return widget.billingAddress;
//     } else {
//       // Return the custom address currently in the controllers/state
//       // Ensure we validate availability first
//       if (_customBillingAddress != null) {
//         return {
//           ..._customBillingAddress!,
//           'email': widget.billingAddress['email'] ?? widget.guestEmail,
//           'save_in_address_book': 0,
//         };
//       }
//
//       // Fallback: Construct from controllers directly if user didn't click "Update"
//       // but logic flows through (e.g. direct pay click while form is open - usually blocked by UI)
//       return {
//         'firstname': _firstNameController.text,
//         'lastname': _lastNameController.text,
//         'street': [_streetAddressController.text],
//         'city': _cityController.text,
//         'country_id': _selectedCountry,
//         'region': _selectedState ?? '',
//         'postcode': _zipCodeController.text,
//         'telephone': _phoneController.text,
//         'email': widget.billingAddress['email'] ?? widget.guestEmail,
//         'save_in_address_book': 0,
//       };
//     }
//   }
//
//   // --- LOGIC: API & PAYMENTS ---
//
//   Future<void> _checkApplePaySupport() async {
//     try {
//       if (Platform.isIOS) {
//         bool isSupported = await Stripe.instance.isPlatformPaySupported();
//         setState(() => _isApplePayAvailable = isSupported);
//       }
//     } catch (e) {
//       if (kDebugMode) print("Error checking Apple Pay support: $e");
//     }
//   }
//
//   Future<void> _fetchCountries() async {
//     try {
//       final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         setState(() {
//           _apiCountries = data.map((e) => Country.fromJson(e)).toList();
//           // Try to set the country name for the controller if ID exists
//           if (_selectedCountry != null) {
//             try {
//               final c = _apiCountries.firstWhere((e) => e.id == _selectedCountry);
//               countryController.text = c.fullNameEnglish ?? '';
//             } catch (_) {}
//           }
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) print('Error fetching countries: $e');
//     }
//   }
//
//   Future<void> _fetchStates(String countryCode) async {
//     try {
//       final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries/$countryCode');
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List<dynamic> regionsJson = data['available_regions'] ?? [];
//         setState(() {
//           _apiStates = regionsJson.map((e) => Region.fromJson(e)).toList();
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) print("Error fetching states: $e");
//     }
//   }
//
//   void _placeOrder() {
//     // Validation: If using different billing address, ensure it's set
//     if (!_isBillingSameAsShipping && _customBillingAddress == null && _showBillingForm) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please update your billing address first."))
//       );
//       return;
//     }
//
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       _placeOrderWithStripe();
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       _placeOrderWithPayU();
//     }
//   }
//
//   Future<void> _handleApplePay() async {
//     setState(() => _isProcessing = true);
//     try {
//       final double grandTotal = (widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0;
//       final currencyState = context.read<CurrencyBloc>().state;
//       if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
//
//       final String currencyCode = currencyState.selectedCurrencyCode;
//
//       final applePayItems = [
//         ApplePayCartSummaryItem.immediate(
//           label: 'Aashni & Co',
//           amount: grandTotal.toStringAsFixed(2),
//         )
//       ];
//
//       final paymentMethod = await Stripe.instance.createPlatformPayPaymentMethod(
//         params: PlatformPayPaymentMethodParams.applePay(
//           applePayParams: ApplePayParams(
//             cartItems: applePayItems,
//             requiredShippingAddressFields: [],
//             requiredBillingContactFields: [],
//             merchantCountryCode: 'IN',
//             currencyCode: currencyCode,
//           ),
//         ),
//       );
//
//       if (mounted) {
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments',
//             billingAddress: _getFinalBillingAddress(),
//             paymentMethodNonce: paymentMethod.paymentMethod.id,
//             currencyCode: currencyCode,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//       }
//     }
//   }
//
//   Future<void> _placeOrderWithStripe() async {
//     if (mounted) setState(() => _isProcessing = true);
//     try {
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//       );
//
//       if (mounted) {
//         final currencyState = context.read<CurrencyBloc>().state;
//         if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
//
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments',
//             billingAddress: _getFinalBillingAddress(),
//             paymentMethodNonce: paymentMethod.id,
//             currencyCode: currencyState.selectedCurrencyCode,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
//       }
//     }
//   }
//
//   Future<void> _placeOrderWithPayU() async {
//     if (!mounted) return;
//     setState(() => _isProcessing = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//       final guestEmail = prefs.getString('user_email');
//       final guestQuoteId = prefs.getString('guest_quote_id');
//
//       final isLoggedIn = token != null && token.isNotEmpty;
//       final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//
//       if (!isLoggedIn && !isGuest) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No session found.'), backgroundColor: Colors.red));
//         return;
//       }
//
//       final currencyState = context.read<CurrencyBloc>().state;
//       if (currencyState is! CurrencyLoaded) throw Exception("Currency not loaded");
//       final currencyCode = currencyState.selectedCurrencyCode;
//
//       final payUData = await _shippingRepository.initiatePayUPayment(
//         currencyCode: currencyCode,
//         billingAddress: _getFinalBillingAddress(),
//       );
//
//       if (!mounted) return;
//
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
//       );
//
//       if (result != 'Success') {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment failed or canceled.'), backgroundColor: Colors.red));
//         return;
//       }
//
//       final txnid = payUData['txnid'] as String;
//       context.read<ShippingBloc>().add(
//         FinalizePayUOrder(
//           txnid: txnid,
//           currencyCode: currencyCode,
//           guestQuoteId: isGuest ? guestQuoteId : null,
//           guestEmail: isGuest ? guestEmail : null,
//         ),
//       );
//     } catch (e) {
//       if (mounted) setState(() => _isProcessing = false);
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
//     }
//   }
//
//   // --- UI BUILD ---
//
//   @override
//   Widget build(BuildContext context) {
//     // 1. Get Currency State
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double currencyRate = 1.0;
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       currencyRate = currencyState.selectedRate.rate;
//     }
//
//     // 2. Determine payment code
//     String selectedPaymentCode;
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       selectedPaymentCode = 'stripe_payments';
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       selectedPaymentCode = 'payu';
//     } else {
//       selectedPaymentCode = 'unknown';
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black),
//         title: const Text('Purchase', style: TextStyle(color: Colors.black, fontFamily: 'Serif', fontSize: 24)),
//       ),
//       body: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           if (state is PaymentSuccess || state is ShippingError) {
//             if (mounted) setState(() => _isProcessing = false);
//           }
//
//           if (state is PaymentSuccess) {
//             final cartState = context.read<CartBloc>().state;
//             final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//
//             // Determine address used for Success Screen
//             Map<String, dynamic> finalAddressUsed;
//             try {
//               finalAddressUsed = _getFinalBillingAddress();
//             } catch (e) {
//               finalAddressUsed = widget.billingAddress;
//             }
//
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => OrderSuccessScreen(
//                   orderId: state.orderId,
//                   totals: widget.totals,
//                   billingAddress: finalAddressUsed,
//                   items: cartItems,
//                   paymentMethodCode: selectedPaymentCode,
//                   guestEmail: widget.guestEmail,
//                 ),
//               ),
//                   (route) => false,
//             );
//           } else if (state is ShippingError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text('Payment Failed: ${state.message}'), backgroundColor: Colors.red),
//             );
//           }
//         },
//         child: Column(
//           children: [
//             // STEPPER
//             const CheckoutStepper(currentStep: 2),
//
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     const Text('Review & Pay', style: TextStyle(fontSize: 22, fontFamily: 'Serif', fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 20),
//
//                     // SHIP TO SUMMARY
//                     _buildSectionHeader("SHIP TO"),
//                     const SizedBox(height: 8),
//                     Text(
//                       "${widget.billingAddress['firstname']} ${widget.billingAddress['lastname']}".toUpperCase(),
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
//                     ),
//                     Text(
//                       "${widget.billingAddress['street'] is List ? (widget.billingAddress['street'] as List).join(', ') : widget.billingAddress['street']}\n"
//                           "${widget.billingAddress['city']}, ${widget.billingAddress['region']}\n"
//                           "${widget.billingAddress['country_id']}".toUpperCase(),
//                       style: const TextStyle(height: 1.4, fontSize: 14, color: Colors.black87),
//                     ),
//                     _buildChangeLink(),
//                     const SizedBox(height: 24),
//
//                     // SHIPPING OPTIONS SUMMARY
//                     // _buildSectionHeader("SHIPPING OPTIONS"),
//                     const SizedBox(height: 8),
//                     // Row(
//                     //   children: [
//                     //     const Icon(Icons.local_shipping_outlined, size: 20),
//                     //     const SizedBox(width: 8),
//                     //     Expanded(
//                     //       child: Column(
//                     //         crossAxisAlignment: CrossAxisAlignment.start,
//                     //         children: [
//                     //           Text(widget.shippingMethodName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                     //           Text(
//                     //             "Price: $displaySymbol${(widget.shippingCost * currencyRate).toStringAsFixed(2)}",
//                     //             style: TextStyle(color: Colors.grey[600], fontSize: 12),
//                     //           ),
//                     //         ],
//                     //       ),
//                     //     ),
//                     //   ],
//                     // ),
//                     // _buildChangeLink(),
//                     // const SizedBox(height: 24),
//
//                     // PACKAGING
//                     // _buildSectionHeader("PACKAGING"),
//                     // const SizedBox(height: 8),
//                     // const Text("Standard Packaging", style: TextStyle(fontWeight: FontWeight.bold)),
//                     // const Text("A discreet, recyclable box.", style: TextStyle(fontSize: 12, color: Colors.grey)),
//                     // const SizedBox(height: 24),
//
//                     // PAYMENT DETAILS
//                     _buildSectionHeader("PAYMENT DETAILS"),
//                     const SizedBox(height: 12),
//                     if (widget.selectedGateway == PaymentGatewayType.stripe)
//                       if (isPaymentMethodAvailable('stripe_payments'))
//                         _buildStripePaymentSection()
//                       else
//                         const Center(child: Text("Stripe is not available."))
//                     else if (widget.selectedGateway == PaymentGatewayType.payu)
//                       if (isPaymentMethodAvailable('payu'))
//                         _buildPayUPaymentSection()
//                       else
//                         const Center(child: Text("PayU Money is not available.")),
//
//                     const SizedBox(height: 24),
//
//                     // BILLING ADDRESS
//                     _buildBillingAddressSection(),
//
//                     const SizedBox(height: 24),
//                     const Divider(thickness: 1),
//                     const SizedBox(height: 12),
//
//                     // ORDER TOTALS
//                     _buildOrderTotalsSummary(displaySymbol, currencyRate),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//             ),
//
//             // PLACE ORDER BUTTON
//             Container(
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 border: Border(top: BorderSide(color: Colors.grey[200]!)),
//               ),
//               child: SafeArea(child: _buildPlaceOrderButton()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- WIDGETS: BILLING ADDRESS SECTION ---
//
//   Widget _buildBillingAddressSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildSectionHeader("BILLING ADDRESS"),
//         const SizedBox(height: 8),
//         CheckboxListTile(
//           title: const Text('My billing and shipping address are the same', style: TextStyle(fontSize: 14)),
//           value: _isBillingSameAsShipping,
//           onChanged: (bool? value) {
//             setState(() {
//               _isBillingSameAsShipping = value ?? true;
//               if (_isBillingSameAsShipping) {
//                 // Revert to shipping address
//                 _showBillingForm = false;
//                 _customBillingAddress = null;
//                 // Optional: reset controllers
//                 _fillControllers(widget.billingAddress);
//               } else {
//                 // Unchecked
//                 if (_customBillingAddress == null) {
//                   _showBillingForm = true; // Show form if no custom address saved yet
//                 } else {
//                   _showBillingForm = false; // Show text if custom address exists
//                 }
//               }
//             });
//           },
//           controlAffinity: ListTileControlAffinity.leading,
//           contentPadding: EdgeInsets.zero,
//           dense: true,
//           activeColor: Colors.black,
//         ),
//
//         // 1. Same as Shipping (Show Shipping Text)
//         if (_isBillingSameAsShipping) ...[
//           _buildAddressText(widget.billingAddress),
//         ]
//         // 2. Custom Address Form (Edit Mode)
//         else if (_showBillingForm) ...[
//           const SizedBox(height: 16),
//           _buildTextField(controller: _firstNameController, labelText: 'First Name', isRequired: true),
//           _buildTextField(controller: _lastNameController, labelText: 'Last Name', isRequired: true),
//           _buildTextField(controller: _streetAddressController, labelText: 'Street Address', isRequired: true),
//           _buildTextField(controller: _cityController, labelText: 'City', isRequired: true),
//           _buildCountryDropdown(),
//           _buildStateDropdown(),
//           _buildTextField(controller: _zipCodeController, labelText: 'Zip/Postal Code', isRequired: true, keyboardType: TextInputType.number),
//           _buildTextField(controller: _phoneController, labelText: 'Phone Number', isRequired: true, keyboardType: TextInputType.phone),
//
//           const SizedBox(height: 16),
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: () {
//                     // Validation
//                     if (_firstNameController.text.isEmpty || _streetAddressController.text.isEmpty ||
//                         _cityController.text.isEmpty || _zipCodeController.text.isEmpty || _selectedCountry == null) {
//                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill in required fields")));
//                       return;
//                     }
//
//                     // Try to resolve IDs to names for UI display if possible
//                     String? countryName = countryController.text; // already set by dropdown
//                     // Region name is already in _selectedState if dropdown used
//
//                     setState(() {
//                       _customBillingAddress = {
//                         'firstname': _firstNameController.text,
//                         'lastname': _lastNameController.text,
//                         'street': [_streetAddressController.text],
//                         'city': _cityController.text,
//                         'country_id': _selectedCountry,
//                         // Not strictly needed for API but good for UI text display:
//                         'country_name': countryName,
//                         'region': _selectedState,
//                         'postcode': _zipCodeController.text,
//                         'telephone': _phoneController.text,
//                       };
//                       _showBillingForm = false; // Hide form, show updated text
//                     });
//
//                     FocusScope.of(context).unfocus();
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Billing address updated.")));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text('Update Billing Address'),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               TextButton(
//                 onPressed: () {
//                   setState(() {
//                     _isBillingSameAsShipping = true;
//                     _showBillingForm = false;
//                     _customBillingAddress = null;
//                   });
//                 },
//                 child: const Text("Cancel", style: TextStyle(color: Colors.black54)),
//               ),
//             ],
//           ),
//         ]
//         // 3. Custom Address Text (View Mode)
//         else ...[
//             if (_customBillingAddress != null)
//               _buildAddressText(_customBillingAddress!),
//
//             Padding(
//               padding: const EdgeInsets.only(left: 10.0),
//               child: InkWell(
//                 onTap: () {
//                   setState(() => _showBillingForm = true);
//                 },
//                 child: const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 8.0),
//                   child: Text("Edit Billing Address", style: TextStyle(decoration: TextDecoration.underline, fontSize: 13, color: Colors.blue)),
//                 ),
//               ),
//             ),
//           ],
//       ],
//     );
//   }
//
//   // --- WIDGETS: FORM HELPERS ---
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     bool isRequired = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: isRequired ? '$labelText *' : labelText,
//           labelStyle: const TextStyle(fontSize: 13),
//           border: const OutlineInputBorder(),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//           isDense: true,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCountryDropdown() {
//     final sortedCountries = List<Country>.from(_apiCountries)
//       ..sort((a, b) => (a.fullNameEnglish ?? '').compareTo(b.fullNameEnglish ?? ''));
//
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: DropdownButtonFormField<String>(
//         decoration: _inputDecoration('Country'),
//         value: countryController.text.isNotEmpty ? countryController.text : null,
//         hint: const Text("Select Country", style: TextStyle(fontSize: 13)),
//         isExpanded: true,
//         items: sortedCountries
//             .where((country) => country.fullNameEnglish != null)
//             .map((Country country) {
//           return DropdownMenuItem<String>(
//             value: country.fullNameEnglish,
//             child: Text(country.fullNameEnglish ?? '', style: const TextStyle(fontSize: 14)),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             countryController.text = value ?? '';
//             try {
//               _selectedCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == value).id;
//               _selectedState = null;
//               if (_selectedCountry != null) _fetchStates(_selectedCountry!);
//             } catch (_) {}
//           });
//         },
//       ),
//     );
//   }
//
//   Widget _buildStateDropdown() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12.0),
//       child: DropdownButtonFormField<String>(
//         decoration: _inputDecoration("State / Province"),
//         value: _selectedState,
//         isExpanded: true,
//         hint: const Text("Select State / Province", style: TextStyle(fontSize: 13)),
//         items: _apiStates.map((region) {
//           return DropdownMenuItem<String>(
//             value: region.name,
//             child: Text(region.name, style: const TextStyle(fontSize: 14)),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             _selectedState = value;
//           });
//         },
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: Colors.black54, fontSize: 13),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//       border: const OutlineInputBorder(),
//       isDense: true,
//     );
//   }
//
//   Widget _buildAddressText(Map<String, dynamic> address) {
//     String street = (address['street'] is List)
//         ? (address['street'] as List).join(', ')
//         : address['street'] ?? '';
//
//     return Padding(
//       padding: const EdgeInsets.only(left: 10.0, top: 4),
//       child: Text(
//         '${address['firstname']} ${address['lastname']}\n'
//             '$street\n'
//             '${address['city']}, ${address['region'] ?? ''} ${address['postcode']}\n'
//             '${address['country_id']}\n'
//             '${address['telephone'] ?? ''}'.toUpperCase(),
//         style: const TextStyle(height: 1.5, color: Colors.black54, fontSize: 13),
//       ),
//     );
//   }
//
//   // --- WIDGETS: LAYOUT HELPERS ---
//
//   Widget _buildSectionHeader(String title) {
//     return Text(
//       title,
//       style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.black54),
//     );
//   }
//
//   Widget _buildChangeLink() {
//     return InkWell(
//       onTap: () { Navigator.pop(context); },
//       child: const Padding(
//         padding: EdgeInsets.symmetric(vertical: 4.0),
//         child: Text("Change", style: TextStyle(decoration: TextDecoration.underline, fontSize: 13)),
//       ),
//     );
//   }
//
//   Widget _buildOrderTotalsSummary(String symbol, double rate) {
//     double sub = ((widget.totals['subtotal'] as num?)?.toDouble() ?? 0.0) * rate;
//     double ship = ((widget.totals['shipping_amount'] as num?)?.toDouble() ?? 0.0) * rate;
//     double tax = ((widget.totals['tax_amount'] as num?)?.toDouble() ?? 0.0) * rate;
//     double grand = ((widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0) * rate;
//
//     return Column(
//       children: [
//         _buildRow("Item subtotal", "$symbol${sub.toStringAsFixed(2)}"),
//         const SizedBox(height: 8),
//         _buildRow("Shipping", "$symbol${ship.toStringAsFixed(2)}"),
//         if (tax > 0) ...[
//           const SizedBox(height: 8),
//           _buildRow("Tax", "$symbol${tax.toStringAsFixed(2)}"),
//         ],
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text("TOTAL", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             Text("$symbol${grand.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget _buildRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 14)),
//         Text(value, style: const TextStyle(fontSize: 14)),
//       ],
//     );
//   }
//
//   Widget _buildPlaceOrderButton() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       builder: (context, state) {
//         final isSubmitting = state is PaymentSubmitting || _isProcessing;
//         return SizedBox(
//           width: double.infinity,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: isSubmitting ? null : _placeOrder,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//             ),
//             child: isSubmitting
//                 ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
//                 : const Text('PLACE ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildStripePaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             SizedBox(width: 8),
//             Icon(Icons.credit_card, size: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(4.0),
//           ),
//           child: const CardField(
//             enablePostalCode: false,
//             style: TextStyle(fontSize: 15, color: Colors.black),
//             decoration: InputDecoration(border: InputBorder.none),
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Row(
//           children: [
//             Icon(Icons.lock, color: Colors.green, size: 14),
//             SizedBox(width: 5),
//             Expanded(child: Text('Protected by PCI DSS security standards.', style: TextStyle(fontSize: 11, color: Colors.grey))),
//           ],
//         ),
//         // Apple Pay
//         // if (_isApplePayAvailable) ...[
//         //   const SizedBox(height: 20),
//         //   SizedBox(
//         //     width: double.infinity,
//         //     height: 48,
//         //     child: PlatformPayButton(
//         //       type: PlatformButtonType.buy,
//         //       appearance: PlatformButtonStyle.black,
//         //       onPressed: _handleApplePay,
//         //     ),
//         //   ),
//         //   const SizedBox(height: 20),
//         //   const Row(children: [
//         //     Expanded(child: Divider()),
//         //     Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
//         //     Expanded(child: Divider()),
//         //   ]),
//         // ],
//       ],
//     );
//   }
//
//   Widget _buildPayUPaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Row(
//           children: [
//             Text('PayU Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             SizedBox(width: 8),
//             Icon(Icons.payment, color: Colors.green, size: 20),
//           ],
//         ),
//         const SizedBox(height: 10),
//         Container(
//           padding: const EdgeInsets.all(12),
//           decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
//           child: const Text(
//             "You will be redirected to the secure PayU gateway to complete your payment.",
//             style: TextStyle(fontSize: 13, color: Colors.black87),
//           ),
//         ),
//       ],
//     );
//   }
// }


//10/12/2025
// class PaymentScreen extends StatefulWidget {
//   final List<dynamic> paymentMethods;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final PaymentGatewayType selectedGateway;
//   final String? guestEmail;
//
//
//   const PaymentScreen({
//     Key? key,
//     required this.paymentMethods,
//     required this.totals,
//     required this.billingAddress,
//     required this.selectedGateway,
//     this.guestEmail,
//
//   }) : super(key: key);
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _isBillingSameAsShipping = true;
//   bool _isProcessing = false;
//   bool _isApplePayAvailable = false;
//
//   // Controllers for the new billing address fields
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipCodeController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   String? _selectedCountry; // For dropdown
//   String? _selectedState; // For dropdown
//   List<Country> _apiCountries = [];
//   List<Region> _apiStates = [];
//
//   final countryController = TextEditingController();
//
//   // Lazily initialize the repository
//   late final ShippingRepository _shippingRepository = ShippingRepository();
//   final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//   @override
//   void initState() {
//     super.initState();
//     // Pre-fill if needed, or leave blank for a new address
//     _firstNameController.text = widget.billingAddress['firstname'] ?? '';
//     _lastNameController.text = widget.billingAddress['lastname'] ?? '';
//     _streetAddressController.text = (widget.billingAddress['street'] as List?)?.join(', ') ?? '';
//     _cityController.text = widget.billingAddress['city'] ?? '';
//     _zipCodeController.text = widget.billingAddress['postcode'] ?? '';
//     _phoneController.text = widget.billingAddress['telephone'] ?? '';
//     _selectedCountry = widget.billingAddress['country_id'];
//     _selectedState = widget.billingAddress['region'];
//     _fetchCountries();
//     if (_selectedCountry != null && _selectedCountry!.isNotEmpty) {
//       _fetchStates(_selectedCountry!);
//     }
//
//     _checkApplePaySupport();
//
//   }
//
//   @override
//   void dispose() {
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _zipCodeController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   // NEW: Check if device supports Apple Pay
//   Future<void> _checkApplePaySupport() async {
//     try {
//       if (Platform.isIOS) {
//         bool isSupported = await Stripe.instance.isPlatformPaySupported();
//         setState(() {
//           _isApplePayAvailable = isSupported;
//         });
//       }
//     } catch (e) {
//       print("Error checking Apple Pay support: $e");
//     }
//   }
//
//   Future<void> _handleApplePay() async {
//     setState(() => _isProcessing = true);
//
//     try {
//       // 1. Get Totals and Currency
//       final double grandTotal = (widget.totals['grand_total'] as num?)?.toDouble() ?? 0.0;
//
//       final currencyState = context.read<CurrencyBloc>().state;
//       if (currencyState is! CurrencyLoaded) {
//         throw Exception("Currency not loaded");
//       }
//       final String currencyCode = currencyState.selectedCurrencyCode; // e.g., 'INR' or 'USD'
//
//       // 2. Define Apple Pay Items
//       final applePayItems = [
//         ApplePayCartSummaryItem.immediate(
//           label: 'Aashni & Co', // Your Business Name
//           amount: grandTotal.toStringAsFixed(2),
//         )
//       ];
//
//       // 3. Launch Apple Pay Sheet & Get Payment Method
//       // This creates a Payment Method (pm_xxxx) in Stripe without charging yet
//       final paymentMethod = await Stripe.instance.createPlatformPayPaymentMethod(
//         params: PlatformPayPaymentMethodParams.applePay(
//           applePayParams: ApplePayParams(
//             cartItems: applePayItems,
//             requiredShippingAddressFields: [], // We already have address
//             requiredBillingContactFields: [],
//             merchantCountryCode: 'IN', // YOUR STRIPE ACCOUNT COUNTRY CODE (Important)
//             currencyCode: currencyCode,
//           ),
//         ),
//       );
//
//       // 4. Send the Payment Method ID (Nonce) to your Backend via Bloc
//       // This reuses your existing logic for normal credit cards
//       if (mounted) {
//         // Get the address user confirmed in the form
//         final finalBillingAddress = _getFinalBillingAddress();
//
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments', // Backend likely treats this same as card
//             billingAddress: finalBillingAddress,
//             paymentMethodNonce: paymentMethod.paymentMethod.id, // The ID starting with 'pm_'
//             currencyCode: currencyCode,
//           ),
//         );
//       }
//     } on StripeException catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         // Don't show error if user simply cancelled the sheet
//         if (e.error.code != FailureCode.Canceled) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Apple Pay Error: ${e.error.localizedMessage}')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }
//
//   Future<void> _fetchStates(String countryCode) async {
//     try {
//       final url = Uri.parse(
//           'https://stage.aashniandco.com/rest/V1/directory/countries/$countryCode');
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//
//         final List<dynamic> regionsJson = data['available_regions'] ?? [];
//
//         setState(() {
//           _apiStates = regionsJson.map((e) => Region.fromJson(e)).toList();
//         });
//
//         print("Fetched States for $countryCode : $_apiStates");
//       } else {
//         print("Failed to load states: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching states: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
//
//     String selectedPaymentCode;
//
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       selectedPaymentCode = 'stripe_payments';
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       selectedPaymentCode = 'payu';
//     } else {
//       selectedPaymentCode = 'unknown';
//     }
//
//     bool isPaymentMethodAvailable(String code) {
//       try {
//         widget.paymentMethods.firstWhere((m) => m['code'] == code);
//         return true;
//       } catch (e) {
//         return false;
//       }
//     }
//
//     return Scaffold(
//
//       appBar: AppBar(title: const Text('Payment')),
//       backgroundColor: Colors.white,
//       body: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           if (state is PaymentSuccess || state is ShippingError) {
//             if (mounted) setState(() => _isProcessing = false);
//           }
//
//           if (state is PaymentSuccess) {
//             final cartState = context.read<CartBloc>().state;
//             final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//
//             // 1. DETERMINE THE ACTUAL ADDRESS USED
//             Map<String, dynamic> finalBillingAddressUsed;
//             try {
//               // Re-calculate the address that was just used for the order
//               finalBillingAddressUsed = _getFinalBillingAddress();
//             } catch (e) {
//               // Fallback to widget.billingAddress (Shipping address) if validation fails
//               // (though it shouldn't if payment succeeded)
//               finalBillingAddressUsed = widget.billingAddress;
//             }
//
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => OrderSuccessScreen(
//                   orderId: state.orderId,
//                   totals: widget.totals,
//                   // 2. PASS THE CALCULATED ADDRESS, NOT widget.billingAddress
//                   billingAddress: finalBillingAddressUsed,
//                   items: cartItems,
//                   paymentMethodCode: selectedPaymentCode,
//                 ),
//               ),
//                   (route) => false,
//             );
//             // if (state is PaymentSuccess) {
//             //   final cartState = context.read<CartBloc>().state;
//             //   final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//             //
//             //   Navigator.pushAndRemoveUntil(
//             //     context,
//             //     MaterialPageRoute(
//             //       builder: (_) => OrderSuccessScreen(
//             //         orderId: state.orderId,
//             //         totals: widget.totals,
//             //         billingAddress: widget.billingAddress,
//             //         items: cartItems,
//             //         paymentMethodCode: selectedPaymentCode,
//             //       ),
//             //     ),
//             //         (route) => false,
//             //   );
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
//               if (widget.selectedGateway == PaymentGatewayType.stripe)
//                 if (isPaymentMethodAvailable('stripe_payments'))
//                   _buildStripePaymentSection()
//                 else
//                   const Center(child: Text("Credit Card (Stripe) is not available for this order."))
//               else if (widget.selectedGateway == PaymentGatewayType.payu)
//                 if (isPaymentMethodAvailable('payu'))
//                   _buildPayUPaymentSection()
//                 else
//                   const Center(child: Text("PayU Money is not available for this order.")),
//               const SizedBox(height: 24),
//               _buildBillingAddressSection(),
//
//               const SizedBox(height: 24),
//               _buildPlaceOrderButton(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Map<String, dynamic> _getFinalBillingAddress() {
//     if (_isBillingSameAsShipping) {
//       return widget.billingAddress;
//     } else {
//       // Basic Validation
//       if (_firstNameController.text.isEmpty ||
//           _lastNameController.text.isEmpty ||
//           _streetAddressController.text.isEmpty ||
//           _cityController.text.isEmpty ||
//           _zipCodeController.text.isEmpty ||
//           _phoneController.text.isEmpty ||
//           _selectedCountry == null) {
//         throw Exception("Please fill in all required billing address fields.");
//       }
//
//       // Try to find the Region ID from the API list based on the selected name
//       String? regionId;
//       String? regionCode;
//
//       if (_apiStates.isNotEmpty && _selectedState != null) {
//         try {
//           final regionObj = _apiStates.firstWhere(
//                   (r) => r.name == _selectedState || r.code == _selectedState
//           );
//           regionId = regionObj.id.toString(); // Assuming Region model has 'id'
//           regionCode = regionObj.code;
//         } catch (e) {
//           // Region not found in list, relying on name only
//         }
//       }
//
//       return {
//         'firstname': _firstNameController.text,
//         'lastname': _lastNameController.text,
//         'street': [_streetAddressController.text], // Array for Magento
//         'city': _cityController.text,
//         'country_id': _selectedCountry,
//         'region': _selectedState ?? '',
//         'region_id': regionId, // Pass this if available
//         'region_code': regionCode, // Pass this if available
//         'postcode': _zipCodeController.text,
//         'telephone': _phoneController.text,
//         'save_in_address_book': 0,
//         // Ensure email is passed for guests
//         'email': widget.billingAddress['email'] ?? widget.guestEmail
//       };
//     }
//   }
//   // Map<String, dynamic> _getFinalBillingAddress() {
//   //   if (_isBillingSameAsShipping) {
//   //     // Return the original address passed from the previous screen
//   //     return widget.billingAddress;
//   //   } else {
//   //     // Construct address from form controllers
//   //     // VALIDATION: Ensure required fields are not empty
//   //     if (_firstNameController.text.isEmpty ||
//   //         _lastNameController.text.isEmpty ||
//   //         _streetAddressController.text.isEmpty ||
//   //         _cityController.text.isEmpty ||
//   //         _zipCodeController.text.isEmpty ||
//   //         _phoneController.text.isEmpty ||
//   //         _selectedCountry == null) {
//   //       throw Exception("Please fill in all required billing address fields.");
//   //     }
//   //
//   //     return {
//   //       'firstname': _firstNameController.text,
//   //       'lastname': _lastNameController.text,
//   //       'street': [_streetAddressController.text], // Magento expects an array for street
//   //       'city': _cityController.text,
//   //       'country_id': _selectedCountry, // Use the ID (e.g., 'IN'), not the name
//   //       'region': _selectedState ?? '',
//   //       'postcode': _zipCodeController.text,
//   //       'telephone': _phoneController.text,
//   //       'save_in_address_book': 0,
//   //       'email': widget.billingAddress['email'] ?? widget.guestEmail // Ensure email is passed if available
//   //     };
//   //   }
//   // }
//   void _placeOrder() {
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       _placeOrderWithStripe();
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       _placeOrderWithPayU();
//     }
//   }
//
//   // Widget _buildStripePaymentSection() {
//   //   return Column(
//   //     crossAxisAlignment: CrossAxisAlignment.start,
//   //     children: [
//   //       Row(
//   //         children: [
//   //           const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//   //           const SizedBox(width: 8),
//   //           Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
//   //         ],
//   //       ),
//   //       const SizedBox(height: 16),
//   //       Container(
//   //         padding: const EdgeInsets.all(12.0),
//   //         decoration: BoxDecoration(
//   //           border: Border.all(color: Colors.grey.shade400),
//   //           borderRadius: BorderRadius.circular(4.0),
//   //         ),
//   //         child: const CardField(),
//   //       ),
//   //       const SizedBox(height: 16),
//   //       const Row(
//   //         children: [
//   //           Icon(Icons.lock, color: Colors.green, size: 16),
//   //           SizedBox(width: 8),
//   //           Expanded(child: Text('Your card details are protected using PCI DSS v3.2 security standards.', style: TextStyle(fontSize: 12, color: Colors.black54))),
//   //         ],
//   //       )
//   //     ],
//   //   );
//   // }
//
//   Widget _buildStripePaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//
//         // ------------------------------------
//
//         Row(
//           children: [
//             const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(4.0),
//           ),
//           child: const CardField(),
//         ),
//         const SizedBox(height: 16),
//         const Row(
//           children: [
//             Icon(Icons.lock, color: Colors.green, size: 16),
//             SizedBox(width: 8),
//             Expanded(child: Text('Your card details are protected using PCI DSS v3.2 security standards.', style: TextStyle(fontSize: 12, color: Colors.black54))),
//           ],
//         ),
//
//         // --- NEW APPLE PAY BUTTON SECTION ---
//         if (_isApplePayAvailable) ...[
//           SizedBox(
//             width: double.infinity,
//             height: 48,
//             child: PlatformPayButton(
//               type: PlatformButtonType.buy,
//               appearance: PlatformButtonStyle.black,
//               onPressed: _handleApplePay,
//             ),
//           ),
//           const SizedBox(height: 20),
//           const Row(children: [
//             Expanded(child: Divider()),
//             Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("OR")),
//             Expanded(child: Divider()),
//           ]),
//           const SizedBox(height: 20),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildPayUPaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text('PayU Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             Image.asset(
//               'assets/images/payu_logo.png',
//               height: 20,
//               errorBuilder: (context, error, stackTrace) {
//                 return const Text('Logo', style: TextStyle(fontSize: 12, color: Colors.grey));
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         const Text("You will be redirected to the secure PayU gateway to complete your payment.", style: TextStyle(fontSize: 14, color: Colors.black54)),
//       ],
//     );
//   }
//
//   Future<void> _placeOrderWithStripe() async {
//     if (mounted) setState(() => _isProcessing = true);
//     try {
//       // 1. Get the correct address
//       final finalBillingAddress = _getFinalBillingAddress();
//
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//       );
//
//       if (mounted) {
//         final currencyState = context.read<CurrencyBloc>().state;
//         if (currencyState is! CurrencyLoaded) {
//           throw Exception("Currency not loaded");
//         }
//
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments',
//             billingAddress: finalBillingAddress, // <--- Pass the new address here
//             paymentMethodNonce: paymentMethod.id,
//             currencyCode: currencyState.selectedCurrencyCode,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }
//   //5/12/25
//   // Future<void> _placeOrderWithStripe() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //   try {
//   //     final paymentMethod = await Stripe.instance.createPaymentMethod(
//   //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//   //     );
//   //     if (mounted) {
//   //       final currencyState = context.read<CurrencyBloc>().state;
//   //       if (currencyState is! CurrencyLoaded) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Error: Currency information not available.')),
//   //         );
//   //         setState(() => _isProcessing = false);
//   //         return;
//   //       }
//   //       context.read<ShippingBloc>().add(
//   //         SubmitPaymentInfo(
//   //           paymentMethodCode: 'stripe_payments',
//   //           billingAddress: widget.billingAddress,
//   //           paymentMethodNonce: paymentMethod.id,
//   //           currencyCode: currencyState.selectedCurrencyCode,
//   //         ),
//   //       );
//   //     }
//   //   } on StripeException catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
//   //       );
//   //     }
//   //   }
//   // }
//
//
//   //6/12/2025
//
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('user_email');
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     if (kDebugMode) {
//   //       print("PaymentScreen get guestQuoteId >> $guestQuoteId");
//   //       print("PaymentScreen get guestEmail >> $guestEmail");
//   //     }
//   //
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //     final currencyCode = currencyState.selectedCurrencyCode;
//   //     print("💱 Currency Code for PayU from Bloc: $currencyCode");
//   //
//   //     final payUData = await _shippingRepository.initiatePayUPayment(
//   //       currencyCode: currencyCode,
//   //     );
//   //     if (!mounted) return;
//   //
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     context.read<ShippingBloc>().add(
//   //       FinalizePayUOrder(
//   //         txnid: txnid,
//   //         currencyCode: currencyCode,
//   //         guestQuoteId: isGuest ? guestQuoteId : null,
//   //         guestEmail: isGuest ? guestEmail : null,
//   //       ),
//   //     );
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: $currencyCode");
//   //       if (isGuest) {
//   //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//   //       }
//   //     }
//   //   } catch (e, stacktrace) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) {
//   //       print("❌ Error in placeOrderWithPayU: $e");
//   //       print("Stacktrace: $stacktrace");
//   //     }
//   //   }
//   // }
//
//   Future<void> _placeOrderWithPayU() async {
//     if (!mounted) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//       final guestEmail = prefs.getString('user_email');
//       final guestQuoteId = prefs.getString('guest_quote_id');
//
//       if (kDebugMode) {
//         print("PaymentScreen get guestQuoteId >> $guestQuoteId");
//         print("PaymentScreen get guestEmail >> $guestEmail");
//       }
//
//       final isLoggedIn = token != null && token.isNotEmpty;
//       final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//
//       if (!isLoggedIn && !isGuest) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('No session found. Cannot initiate payment.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         if (kDebugMode) print("⚠️ No session found for payment.");
//         return;
//       }
//
//       final currencyState = context.read<CurrencyBloc>().state;
//       if (currencyState is! CurrencyLoaded) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error: Currency information not available.')),
//         );
//         setState(() => _isProcessing = false);
//         return;
//       }
//       final currencyCode = currencyState.selectedCurrencyCode;
//       print("💱 Currency Code for PayU from Bloc: $currencyCode");
//
//       // ✅ 1. GET THE LATEST ADDRESS DATA
//       final finalBillingAddress = _getFinalBillingAddress();
//
//       // --- PRINT LOGIC START ---
//       print("****************************************");
//       print("PAYU ORDER INITIATED - FINAL BILLING ADDRESS:");
//       finalBillingAddress.forEach((key, value) {
//         print("$key: $value");
//       });
//       print("****************************************");
//       // --- PRINT LOGIC END ---
//
//       final payUData = await _shippingRepository.initiatePayUPayment(
//         currencyCode: currencyCode,
//         billingAddress: finalBillingAddress,
//       );
//
//       if (!mounted) return;
//
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PayUWebViewScreen(paymentData: payUData),
//         ),
//       );
//
//       if (result != 'Success') {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Payment failed or was canceled.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//         return;
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Payment Successful! Finalizing order...'),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       final txnid = payUData['txnid'] as String;
//
//       context.read<ShippingBloc>().add(
//         FinalizePayUOrder(
//           txnid: txnid,
//           currencyCode: currencyCode,
//           guestQuoteId: isGuest ? guestQuoteId : null,
//           guestEmail: isGuest ? guestEmail : null,
//         ),
//       );
//
//       if (kDebugMode) {
//         print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//             "and currencyCode: $currencyCode");
//         if (isGuest) {
//           print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//         }
//       }
//     } catch (e, stacktrace) {
//       if (mounted) setState(() => _isProcessing = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//       );
//       if (kDebugMode) {
//         print("❌ Error in placeOrderWithPayU: $e");
//         print("Stacktrace: $stacktrace");
//       }
//     }
//   }
//
//   //9/12/2025
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('user_email');
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     if (kDebugMode) {
//   //       print("PaymentScreen get guestQuoteId >> $guestQuoteId");
//   //       print("PaymentScreen get guestEmail >> $guestEmail");
//   //     }
//   //
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //     final currencyCode = currencyState.selectedCurrencyCode;
//   //     print("💱 Currency Code for PayU from Bloc: $currencyCode");
//   //
//   //     // ✅ 1. GET THE LATEST ADDRESS DATA
//   //     final finalBillingAddress = _getFinalBillingAddress();
//   //
//   //     final payUData = await _shippingRepository.initiatePayUPayment(
//   //       currencyCode: currencyCode,
//   //       billingAddress: finalBillingAddress,
//   //     );
//   //     if (!mounted) return;
//   //
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     context.read<ShippingBloc>().add(
//   //       FinalizePayUOrder(
//   //         txnid: txnid,
//   //         currencyCode: currencyCode,
//   //         guestQuoteId: isGuest ? guestQuoteId : null,
//   //         guestEmail: isGuest ? guestEmail : null,
//   //       ),
//   //     );
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: $currencyCode");
//   //       if (isGuest) {
//   //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//   //       }
//   //     }
//   //   } catch (e, stacktrace) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) {
//   //       print("❌ Error in placeOrderWithPayU: $e");
//   //       print("Stacktrace: $stacktrace");
//   //     }
//   //   }
//   // }
//
//
//   Widget _buildPlaceOrderButton() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       builder: (context, state) {
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
//               ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
//               : const Text('PLACE ORDER'),
//         );
//       },
//     );
//   }
//
//   Widget _buildEstimatedTotal(dynamic grandTotalValue, int qty) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//     final double baseGrandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
//
//     String displaySymbol = '₹';
//     double displayGrandTotal = baseGrandTotal;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       displayGrandTotal = baseGrandTotal * currencyState.selectedRate.rate;
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4.0)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Estimated Total', style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 4),
//               Text(
//                 '$displaySymbol${displayGrandTotal.toStringAsFixed(2)}',
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
//                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
//                 child: Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Future<void> _fetchCountries() async {
//     print("Countries Method Clicked>>");
//     try {
//       final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
//       final response = await http.get(url);
//
//       if (response.statusCode == 200) {
//         final List data = jsonDecode(response.body);
//         setState(() {
//           _apiCountries = data.map((e) => Country.fromJson(e)).toList();
//           print("_apiCountries>>$_apiCountries");
//         });
//       } else {
//         print('Failed to fetch countries: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching countries: $e');
//     }
//   }
//   Widget _buildBillingAddressSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CheckboxListTile(
//           title: const Text('My billing and shipping address are the same'),
//           value: _isBillingSameAsShipping,
//           onChanged: (bool? value) => setState(() => _isBillingSameAsShipping = value ?? true),
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
//                   '${widget.billingAddress['country_id']}\n'
//                   '${widget.billingAddress['telephone']}',
//               style: const TextStyle(height: 1.5, color: Colors.black87),
//             ),
//           )
//         ] else ...[ // This block is executed when _isBillingSameAsShipping is false
//           const SizedBox(height: 24),
//           const Text('Billing Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 16),
//           _buildTextField(
//             controller: _firstNameController,
//             labelText: 'First Name',
//             isRequired: true,
//           ),
//           _buildTextField(
//             controller: _lastNameController,
//             labelText: 'Last Name',
//             isRequired: true,
//           ),
//           _buildTextField(
//             controller: _streetAddressController,
//             labelText: 'Street Address',
//             isRequired: true,
//           ),
//           _buildTextField(
//             controller: _cityController,
//             labelText: 'City',
//             isRequired: true,
//           ),
//           _buildCountryDropdown(),
//           _buildStateDropdown(),
//           _buildTextField(
//             controller: _zipCodeController,
//             labelText: 'Zip/Postal Code',
//             isRequired: true,
//             keyboardType: TextInputType.number,
//           ),
//           _buildTextField(
//             controller: _phoneController,
//             labelText: 'Phone Number',
//             isRequired: true,
//             keyboardType: TextInputType.phone,
//           ),
//           const SizedBox(height: 24),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               // ElevatedButton(
//               //   onPressed: () {
//               //     if (_firstNameController.text.isEmpty || _streetAddressController.text.isEmpty) {
//               //       ScaffoldMessenger.of(context).showSnackBar(
//               //         const SnackBar(content: Text("Please fill in required fields")),
//               //       );
//               //     } else {
//               //       FocusScope.of(context).unfocus(); // Hide keyboard
//               //       ScaffoldMessenger.of(context).showSnackBar(
//               //         const SnackBar(content: Text("Billing address updated.")),
//               //       );
//               //       // You don't need to save to a variable, _getFinalBillingAddress() does it live.
//               //     }
//               //   },
//               //   // ElevatedButton(
//               //   //   onPressed: () {
//               //   //     // Handle update logic here, e.g., validate and save
//               //   //     print('Update Billing Address pressed');
//               //   //   },
//               //   style: ElevatedButton.styleFrom(
//               //     backgroundColor: Colors.black,
//               //     foregroundColor: Colors.white,
//               //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//               //   ),
//               //   child: const Text('Update'),
//               // ),
//
//               ElevatedButton(
//                 onPressed: () {
//                   // Basic Client-side validation
//                   if (_firstNameController.text.isEmpty ||
//                       _streetAddressController.text.isEmpty ||
//                       _cityController.text.isEmpty ||
//                       _zipCodeController.text.isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Please fill in required fields")),
//                     );
//                   } else {
//                     FocusScope.of(context).unfocus(); // Hide keyboard
//
//                     // --- PRINT LOGIC START ---
//                     Map<String, dynamic> updatedDetails = {
//                       'firstname': _firstNameController.text,
//                       'lastname': _lastNameController.text,
//                       'street': _streetAddressController.text,
//                       'city': _cityController.text,
//                       'country_id': _selectedCountry, // The ID (e.g., "IN")
//                       'country_name': countryController.text, // The Name (e.g., "India")
//                       'region': _selectedState,
//                       'postcode': _zipCodeController.text,
//                       'telephone': _phoneController.text,
//                     };
//
//                     print("========================================");
//                     print("USER CLICKED UPDATE - NEW BILLING DETAILS:");
//                     updatedDetails.forEach((key, value) {
//                       print("$key: $value");
//                     });
//                     print("========================================");
//                     // --- PRINT LOGIC END ---
//
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text("Billing address updated.")),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                 ),
//                 child: const Text('Update'),
//               ),
//               OutlinedButton(
//                 onPressed: () {
//                   // Handle cancel logic, e.g., revert changes or close form
//                   print('Cancel Billing Address pressed');
//                   setState(() {
//                     _isBillingSameAsShipping = true; // Revert to original state
//                   });
//                 },
//                 style: OutlinedButton.styleFrom(
//                   foregroundColor: Colors.black,
//                   side: const BorderSide(color: Colors.grey),
//                   padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                 ),
//                 child: const Text('Cancel'),
//               ),
//             ],
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String labelText,
//     bool isRequired = false,
//     TextInputType keyboardType = TextInputType.text,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: TextField(
//         controller: controller,
//         keyboardType: keyboardType,
//         decoration: InputDecoration(
//           labelText: isRequired ? '$labelText *' : labelText,
//           border: const OutlineInputBorder(),
//           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         ),
//       ),
//     );
//   }
//   /// InputDecoration for dropdown
//   InputDecoration _inputDecoration(BuildContext context, String label) {
//     return InputDecoration(
//       labelText: label,
//       labelStyle: const TextStyle(color: Colors.black54),
//       contentPadding:
//       const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       filled: true,
//       fillColor: Colors.white,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Colors.black12),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: Colors.black, width: 1.2),
//       ),
//     );
//   }
//
//   Widget _buildCountryDropdown() {
//     String? selectedCountry = countryController.text.isEmpty ? null : countryController.text;
//
//     final sortedCountries = List<Country>.from(_apiCountries)
//       ..sort((a, b) => (a.fullNameEnglish ?? '').compareTo(b.fullNameEnglish ?? ''));
//     // Example list of countries, replace with your actual data source
//     // Ensure 'AT' is included if it's a valid country_id that can come from billingAddress
//     final List<String> countries = ['India', 'United States', 'Canada', 'United Kingdom', 'AT']; // Added 'AT'
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child:      DropdownButtonFormField<String>(
//         decoration: _inputDecoration(context, 'Country'),
//         value: selectedCountry,
//         hint: const Text("Select Country"),
//         isExpanded: true,
//         items: sortedCountries
//             .where((country) => country.fullNameEnglish != null)
//             .map((Country country) {
//           return DropdownMenuItem<String>(
//             value: country.fullNameEnglish,
//             child: Text(country.fullNameEnglish ?? ''),
//           );
//         }).toList(),
//         onChanged: (value) {
//           setState(() {
//             selectedCountry = value;
//             countryController.text = value ?? '';
//             _selectedCountry = _apiCountries
//                 .firstWhere((c) => c.fullNameEnglish == value)
//                 .id; // important
//             _selectedState = null; // reset state
//
//             _fetchStates(_selectedCountry!); // ← load regions
//           });
//         },
//
//         validator: (value) =>
//         (value == null || value.isEmpty) ? 'Please select your country' : null,
//       ),
//     );
//   }
//
//   Widget _buildStateDropdown() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16.0),
//       child: DropdownButtonFormField<String>(
//         decoration: _inputDecoration(context, "State / Province"),
//         value: _selectedState,
//         isExpanded: true,
//         hint: const Text("Select State / Province"),
//
//         items: _apiStates.map((region) {
//           return DropdownMenuItem<String>(
//             value: region.name,
//             child: Text(region.name),
//           );
//         }).toList(),
//
//         onChanged: (value) {
//           setState(() {
//             _selectedState = value;
//           });
//         },
//
//         validator: (value) =>
//         (value == null || value.isEmpty) ? "Please select your state" : null,
//       ),
//     );
//   }
//
// }
//8/12/2025
// class PaymentScreen extends StatefulWidget {
//   final List<dynamic> paymentMethods;
//   final Map<String, dynamic> totals;
//   final Map<String, dynamic> billingAddress;
//   final PaymentGatewayType selectedGateway;
//   final String? guestEmail;
//
//   const PaymentScreen({
//     Key? key,
//     required this.paymentMethods,
//     required this.totals,
//     required this.billingAddress,
//     required this.selectedGateway,
//     this.guestEmail,
//   }) : super(key: key);
//
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   bool _isBillingSameAsShipping = true;
//   bool _isProcessing = false;
//
//   // Lazily initialize the repository
//   late final ShippingRepository _shippingRepository = ShippingRepository();
//   final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
//
//     // ✅ 1. DEFINE the payment code variable here.
//     // This makes it available to the entire build method, including the BlocListener.
//     String selectedPaymentCode;
//
//     // ✅ 2. ASSIGN the correct code based on the selected gateway.
//     // Use the exact codes your backend expects and that you check for below.
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       selectedPaymentCode = 'stripe_payments';
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       // This code 'payu' must match what you use in isPaymentMethodAvailable('payu')
//       selectedPaymentCode = 'payu';
//     } else {
//       // It's good practice to have a fallback.
//       selectedPaymentCode = 'unknown';
//     }
//
//     // This local function is fine as it is.
//     bool isPaymentMethodAvailable(String code) {
//       try {
//         widget.paymentMethods.firstWhere((m) => m['code'] == code);
//         return true;
//       } catch (e) {
//         return false;
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment')),
//       body: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           // This listener handles the result after the BLoC has processed the payment
//           if (state is PaymentSuccess || state is ShippingError) {
//             if (mounted) setState(() => _isProcessing = false);
//           }
//
//           if (state is PaymentSuccess) {
//             final cartState = context.read<CartBloc>().state;
//             final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//
//             Navigator.pushAndRemoveUntil(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => OrderSuccessScreen(
//                   orderId: state.orderId,
//                   totals: widget.totals,
//                   billingAddress: widget.billingAddress,
//                   items: cartItems,
//                   // ✅ 3. USE the variable which is now correctly defined in this scope.
//                   paymentMethodCode: selectedPaymentCode,
//
//
//                 ),
//               ),
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
//           // The rest of your UI code remains exactly the same.
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
//               const SizedBox(height: 24),
//               Text('Payment Method', style: Theme.of(context).textTheme.headlineSmall),
//               const SizedBox(height: 16),
//
//               // --- DYNAMIC UI LOGIC ---
//               if (widget.selectedGateway == PaymentGatewayType.stripe)
//                 if (isPaymentMethodAvailable('stripe_payments'))
//                   _buildStripePaymentSection()
//                 else
//                   const Center(child: Text("Credit Card (Stripe) is not available for this order."))
//               else if (widget.selectedGateway == PaymentGatewayType.payu)
//                 if (isPaymentMethodAvailable('payu'))
//                   _buildPayUPaymentSection()
//                 else
//                   const Center(child: Text("PayU Money is not available for this order.")),
//
//               const SizedBox(height: 24),
//               _buildPlaceOrderButton(),
//               const SizedBox(height: 24),
//               _buildBillingAddressSection(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//   // Widget build(BuildContext context) {
//   //   final cartItemQty = (widget.totals['items_qty'] as num?)?.toInt() ?? 0;
//   //
//   //   bool isPaymentMethodAvailable(String code) {
//   //     try {
//   //       widget.paymentMethods.firstWhere((m) => m['code'] == code);
//   //       return true;
//   //     } catch (e) {
//   //       return false;
//   //     }
//   //   }
//   //
//   //   return Scaffold(
//   //     appBar: AppBar(title: const Text('Payment')),
//   //     body: BlocListener<ShippingBloc, ShippingState>(
//   //       listener: (context, state) {
//   //         // This listener handles the result after the BLoC has processed the payment
//   //         if (state is PaymentSuccess || state is ShippingError) {
//   //           if (mounted) setState(() => _isProcessing = false);
//   //         }
//   //
//   //         if (state is PaymentSuccess) {
//   //           final cartState = context.read<CartBloc>().state;
//   //           final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//   //
//   //           Navigator.pushAndRemoveUntil(
//   //             context,
//   //             MaterialPageRoute(
//   //               builder: (_) => OrderSuccessScreen(
//   //                 orderId: state.orderId,
//   //                 totals: widget.totals,
//   //                 billingAddress: widget.billingAddress,
//   //                 items: cartItems,
//   //                 paymentMethodCode: selectedPaymentCode,
//   //               ),
//   //             ),
//   //                 (route) => false,
//   //           );
//   //         } else if (state is ShippingError) {
//   //           ScaffoldMessenger.of(context).showSnackBar(
//   //             SnackBar(
//   //               content: Text('Payment Failed: ${state.message}'),
//   //               backgroundColor: Colors.red,
//   //             ),
//   //           );
//   //         }
//   //       },
//   //       child: SingleChildScrollView(
//   //         padding: const EdgeInsets.all(16.0),
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.stretch,
//   //           children: [
//   //             _buildEstimatedTotal(widget.totals['grand_total'], cartItemQty),
//   //             const SizedBox(height: 24),
//   //             Text('Payment Method', style: Theme.of(context).textTheme.headlineSmall),
//   //             const SizedBox(height: 16),
//   //
//   //             // --- DYNAMIC UI LOGIC ---
//   //             if (widget.selectedGateway == PaymentGatewayType.stripe)
//   //               if (isPaymentMethodAvailable('stripe_payments'))
//   //                 _buildStripePaymentSection()
//   //               else
//   //                 const Center(child: Text("Credit Card (Stripe) is not available for this order."))
//   //             else if (widget.selectedGateway == PaymentGatewayType.payu)
//   //             // Assuming your PayU module's code is 'payu' or 'payu_method_code'
//   //               if (isPaymentMethodAvailable('payu')) // <-- CHECK THIS CODE
//   //                 _buildPayUPaymentSection()
//   //               else
//   //                 const Center(child: Text("PayU Money is not available for this order.")),
//   //
//   //             const SizedBox(height: 24),
//   //             _buildPlaceOrderButton(),
//   //             const SizedBox(height: 24),
//   //             _buildBillingAddressSection(),
//   //           ],
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   /// The dispatcher method that decides which payment flow to start.
//   void _placeOrder() {
//     if (widget.selectedGateway == PaymentGatewayType.stripe) {
//       _placeOrderWithStripe();
//     } else if (widget.selectedGateway == PaymentGatewayType.payu) {
//       _placeOrderWithPayU();
//     }
//   }
//
//   // --- UI WIDGETS ---
//
//   Widget _buildStripePaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text('Pay by Card (Stripe)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             Image.network('https://i.imgur.com/khpvoZl.png', height: 20),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.grey.shade400),
//             borderRadius: BorderRadius.circular(4.0),
//           ),
//           child: const CardField(),
//         ),
//         const SizedBox(height: 16),
//         const Row(
//           children: [
//             Icon(Icons.lock, color: Colors.green, size: 16),
//             SizedBox(width: 8),
//             Expanded(child: Text('Your card details are protected using PCI DSS v3.2 security standards.', style: TextStyle(fontSize: 12, color: Colors.black54))),
//           ],
//         )
//       ],
//     );
//   }
//
//   Widget _buildPayUPaymentSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             const Text('PayU Money', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//             const SizedBox(width: 8),
//             Image.asset(
//               'assets/images/payu_logo.png',
//               height: 20,
//               // Optional: Add error handling for the local asset
//               errorBuilder: (context, error, stackTrace) {
//                 return const Text('Logo', style: TextStyle(fontSize: 12, color: Colors.grey));
//               },
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         const Text("You will be redirected to the secure PayU gateway to complete your payment.", style: TextStyle(fontSize: 14, color: Colors.black54)),
//       ],
//     );
//   }
//
//   // --- PAYMENT LOGIC METHODS ---
//
//   Future<void> _placeOrderWithStripe() async {
//     // This method is already correct from your provided code. No changes needed.
//     if (mounted) setState(() => _isProcessing = true);
//     try {
//       final paymentMethod = await Stripe.instance.createPaymentMethod(
//         params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//       );
//       if (mounted) {
//         final currencyState = context.read<CurrencyBloc>().state;
//         if (currencyState is! CurrencyLoaded) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Error: Currency information not available.')),
//           );
//           setState(() => _isProcessing = false);
//           return;
//         }
//         context.read<ShippingBloc>().add(
//           SubmitPaymentInfo(
//             paymentMethodCode: 'stripe_payments',
//             billingAddress: widget.billingAddress,
//             paymentMethodNonce: paymentMethod.id,
//             currencyCode: currencyState.selectedCurrencyCode,
//           ),
//         );
//       }
//     } on StripeException catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
//         );
//       }
//     }
//   }
//
//   // Future<void> _placeOrderWithStripe() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     // This part is fine, it gets the payment token from Stripe
//   //     final paymentMethod = await Stripe.instance.createPaymentMethod(
//   //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//   //     );
//   //
//   //     if (mounted) {
//   //       // ✅ 1. Get the current currency state from the global BLoC
//   //       final currencyState = context.read<CurrencyBloc>().state;
//   //
//   //       // ✅ 2. Check if the currency is loaded before proceeding
//   //       if (currencyState is! CurrencyLoaded) {
//   //         // This is a safeguard. If the currency isn't loaded, we can't place the order correctly.
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Error: Currency information not available. Please restart the app.')),
//   //         );
//   //         // Stop the loading indicator
//   //         setState(() => _isProcessing = false);
//   //         return; // Exit the function
//   //       }
//   //
//   //       // ✅ 3. Dispatch the event WITH the required currencyCode
//   //       context.read<ShippingBloc>().add(
//   //         SubmitPaymentInfo(
//   //           paymentMethodCode: 'stripe_payments',
//   //           billingAddress: widget.billingAddress,
//   //           paymentMethodNonce: paymentMethod.id,
//   //           // Pass the currency code from the loaded state
//   //           currencyCode: currencyState.selectedCurrencyCode,
//   //         ),
//   //       );
//   //     }
//   //   } on StripeException catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
//   //       );
//   //     }
//   //   }
//   // }
//
//   // Future<void> _placeOrderWithStripe() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final paymentMethod = await Stripe.instance.createPaymentMethod(
//   //       params: const PaymentMethodParams.card(paymentMethodData: PaymentMethodData()),
//   //     );
//   //
//   //     if (mounted) {
//   //       context.read<ShippingBloc>().add(
//   //         SubmitPaymentInfo(
//   //           paymentMethodCode: 'stripe_payments',
//   //           billingAddress: widget.billingAddress,
//   //           paymentMethodNonce: paymentMethod.id,
//   //         ),
//   //       );
//   //     }
//   //   } on StripeException catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error: ${e.error.localizedMessage ?? "An unknown error occurred"}')),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('An unexpected error occurred: ${e.toString()}')),
//   //       );
//   //     }
//   //   }
//   // }
// //11/10/2025
//   Future<void> _placeOrderWithPayU() async {
//     if (!mounted) return;
//
//     setState(() => _isProcessing = true);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//       final guestEmail = prefs.getString('user_email');
//       final guestQuoteId = prefs.getString('guest_quote_id');
//
//       if (kDebugMode) {
//         print("PaymentScreen get guestQuoteId >> $guestQuoteId");
//         print("PaymentScreen get guestEmail >> $guestEmail");
//       }
//
//       final isLoggedIn = token != null && token.isNotEmpty;
//       final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//
//       if (!isLoggedIn && !isGuest) {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('No session found. Cannot initiate payment.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         if (kDebugMode) print("⚠️ No session found for payment.");
//         return;
//       }
//
//       // ✅ Get currency code from CurrencyBloc, same as Stripe
//       final currencyState = context.read<CurrencyBloc>().state;
//       if (currencyState is! CurrencyLoaded) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Error: Currency information not available.')),
//         );
//         setState(() => _isProcessing = false);
//         return;
//       }
//       final currencyCode = currencyState.selectedCurrencyCode;
//       print("💱 Currency Code for PayU from Bloc: $currencyCode");
//
//
//       // Initiate PayU payment, passing the currencyCode
//       final payUData = await _shippingRepository.initiatePayUPayment(
//         currencyCode: currencyCode, // ✅ PASS THE CURRENCY CODE HERE
//       );
//       if (!mounted) return;
//
//       // ... (rest of _placeOrderWithPayU remains the same)
//
//       // Open PayU WebView
//       final result = await Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => PayUWebViewScreen(paymentData: payUData),
//         ),
//       );
//
//       if (result != 'Success') {
//         setState(() => _isProcessing = false);
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Payment failed or was canceled.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//         if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//         return;
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Payment Successful! Finalizing order...'),
//           backgroundColor: Colors.green,
//         ),
//       );
//
//       final txnid = payUData['txnid'] as String;
//
//       context.read<ShippingBloc>().add(
//         FinalizePayUOrder(
//           txnid: txnid,
//           currencyCode: currencyCode,
//           guestQuoteId: isGuest ? guestQuoteId : null,
//           guestEmail: isGuest ? guestEmail : null,
//         ),
//       );
//
//       if (kDebugMode) {
//         print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//             "and currencyCode: $currencyCode");
//         if (isGuest) {
//           print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//         }
//       }
//     } catch (e, stacktrace) {
//       if (mounted) setState(() => _isProcessing = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//       );
//       if (kDebugMode) {
//         print("❌ Error in placeOrderWithPayU: $e");
//         print("Stacktrace: $stacktrace");
//       }
//     }
//   }
//
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('user_email'); // ✅ guest email key
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     if (kDebugMode) {
//   //       print("PaymentScreen get guestQuoteId >> $guestQuoteId");
//   //       print("PaymentScreen get guestEmail >> $guestEmail");
//   //     }
//   //
//   //     // Determine checkout type
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     if (kDebugMode) {
//   //       print(isLoggedIn
//   //           ? "🟢 Logged-in user flow → initiating PayU payment"
//   //           : "🟠 Guest checkout flow → initiating PayU payment");
//   //       if (isGuest) {
//   //         print(" Guest QuoteId: $guestQuoteId");
//   //         print(" Guest Email: $guestEmail");
//   //       }
//   //     }
//   //
//   //     // Initiate PayU payment
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     // Open PayU WebView
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     // Payment success → finalize order
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     // ✅ Currency code handling (same as Stripe flow)
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //
//   //     final currencyCode = currencyState.selectedCurrencyCode;
//   //     print("💱 Currency Code from Bloc: $currencyCode");
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     // Dispatch finalize order event
//   //     context.read<ShippingBloc>().add(
//   //       FinalizePayUOrder(
//   //         txnid: txnid,
//   //         currencyCode: currencyCode, // ✅ aligned with Stripe flow
//   //         guestQuoteId: isGuest ? guestQuoteId : null,
//   //         guestEmail: isGuest ? guestEmail : null,
//   //       ),
//   //     );
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: $currencyCode");
//   //       if (isGuest) {
//   //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//   //       }
//   //     }
//   //   } catch (e, stacktrace) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) {
//   //       print("❌ Error in placeOrderWithPayU: $e");
//   //       print("Stacktrace: $stacktrace");
//   //     }
//   //   }
//   // }
//
//   //4/10/2025
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     // Ensure 'user_email' is the correct key where you store the guest's email.
//   //     final guestEmail = prefs.getString('user_email');
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     if (kDebugMode) {
//   //       print("PaymetScreeng get guestquoteId>>$guestQuoteId");
//   //       print("PaymentScreen get guestEmail>>$guestEmail");
//   //     }
//   //
//   //     // Determine checkout type
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     // Ensure guestQuoteId is not empty for a valid guest session
//   //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty;
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     if (kDebugMode) {
//   //       print(isLoggedIn
//   //           ? "🟢 Logged-in user flow → initiating PayU payment"
//   //           : "🟠 Guest checkout flow → initiating PayU payment");
//   //       if (isGuest) {
//   //         print(" Guest QuoteId: $guestQuoteId");
//   //         print(" Guest Email: $guestEmail");
//   //       }
//   //     }
//   //
//   //     // Initiate PayU payment (initiatePayUPayment in ShippingRepository now correctly uses guestEmail for guests)
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     // Open PayU WebView
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     // Payment success → finalize order
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //
//   //     // ✅ Print the currency code here
//   //     print("Currency Code from Bloc: ${currencyState.selectedCurrencyCode}");
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     // Dispatch finalize order event with guest info if applicable
//   //     context.read<ShippingBloc>().add(FinalizePayUOrder(
//   //       txnid: txnid,
//   //       currencyCode: currencyState.selectedCurrencyCode,
//   //       guestQuoteId: isGuest ? guestQuoteId : null,
//   //       guestEmail: isGuest ? guestEmail : null, // ✅ CORRECTED: Pass the guest email
//   //     ));
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
//   //       if (isGuest) {
//   //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//   //       }
//   //     }
//   //   } catch (e, stacktrace) { // Catch stacktrace here too for better debugging
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) {
//   //       print("❌ Error in placeOrderWithPayU: $e");
//   //       print("Stacktrace: $stacktrace");
//   //     }
//   //   }
//   // }
//
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('user_email'); // Get guest email from prefs
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     print("PaymetScreeng get guestquoteId>>$guestQuoteId");
//   //     print("PaymentScreen get guestEmail>>$guestEmail"); // Log guest email
//   //
//   //     // Determine checkout type
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     final isGuest = guestQuoteId != null && guestQuoteId.isNotEmpty; // Ensure guestQuoteId is not empty
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     if (kDebugMode) {
//   //       print(isLoggedIn
//   //           ? "🟢 Logged-in user flow → initiating PayU payment"
//   //           : "🟠 Guest checkout flow → initiating PayU payment");
//   //       if (isGuest) {
//   //         print(" Guest QuoteId: $guestQuoteId");
//   //         print(" Guest Email: $guestEmail"); // Log guest email here
//   //       }
//   //     }
//   //
//   //     // Initiate PayU payment (auto handles guest/logged-in)
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     // Open PayU WebView
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     // Payment success → finalize order
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     // Dispatch finalize order event with guest info if applicable
//   //     context.read<ShippingBloc>().add(FinalizePayUOrder(
//   //       txnid: txnid,
//   //       currencyCode: currencyState.selectedCurrencyCode,
//   //       guestQuoteId: isGuest ? guestQuoteId : null,
//   //       guestEmail: isGuest ? guestEmail : null, // ✅ Pass the guest email
//   //     ));
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
//   //       if (isGuest) {
//   //         print("  Finalizing guest order with guestQuoteId: $guestQuoteId and guestEmail: $guestEmail");
//   //       }
//   //     }
//   //   } catch (e, stacktrace) { // Catch stacktrace here too for better debugging
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) {
//   //       print("❌ Error in placeOrderWithPayU: $e");
//   //       print("Stacktrace: $stacktrace");
//   //     }
//   //   }
//   // }
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (!mounted) return;
//   //
//   //   setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('user_email');
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //
//   //     print("PaymetScreeng get guestquoteId>>$guestQuoteId");
//   //
//   //     // Determine checkout type
//   //     final isLoggedIn = token != null && token.isNotEmpty;
//   //     final isGuest = guestQuoteId != null;
//   //
//   //     if (!isLoggedIn && !isGuest) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('No session found. Cannot initiate payment.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ No session found for payment.");
//   //       return;
//   //     }
//   //
//   //     if (kDebugMode) {
//   //       print(isLoggedIn
//   //           ? "🟢 Logged-in user flow → initiating PayU payment"
//   //           : "🟠 Guest checkout flow → initiating PayU payment");
//   //       if (isGuest) print(" Guest QuoteId: $guestQuoteId");
//   //     }
//   //
//   //     // Initiate PayU payment (auto handles guest/logged-in)
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     // Open PayU WebView
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result != 'Success') {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //       return;
//   //     }
//   //
//   //     // Payment success → finalize order
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       const SnackBar(
//   //         content: Text('Payment Successful! Finalizing order...'),
//   //         backgroundColor: Colors.green,
//   //       ),
//   //     );
//   //
//   //     final currencyState = context.read<CurrencyBloc>().state;
//   //     if (currencyState is! CurrencyLoaded) {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Error: Currency information not available.')),
//   //       );
//   //       setState(() => _isProcessing = false);
//   //       return;
//   //     }
//   //
//   //     final txnid = payUData['txnid'] as String;
//   //
//   //     // Dispatch finalize order event with guest info if applicable
//   //     context.read<ShippingBloc>().add(FinalizePayUOrder(
//   //       txnid: txnid,
//   //       currencyCode: currencyState.selectedCurrencyCode,
//   //       guestQuoteId: isGuest ? guestQuoteId : null,
//   //
//   //     ));
//   //
//   //     if (kDebugMode) {
//   //       print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //           "and currencyCode: ${currencyState.selectedCurrencyCode}");
//   //     }
//   //   } catch (e) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) print("❌ Error in placeOrderWithPayU: $e");
//   //   }
//   // }
//
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //   try {
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final token = prefs.getString('user_token');
//   //     final guestEmail = prefs.getString('guest_email');
//   //     final guestQuoteId = prefs.getString('guest_quote_id');
//   //
//   //     if (kDebugMode) {
//   //       if (token != null && token.isNotEmpty) {
//   //         print("🟢 Logged-in user flow → initiating PayU payment");
//   //       } else if (guestEmail != null && guestQuoteId != null) {
//   //         print("🟠 Guest checkout flow → initiating PayU payment");
//   //         print("Guest Email: $guestEmail");
//   //         print("Guest QuoteId: $guestQuoteId");
//   //       } else {
//   //         print("🔴 No session found → cannot initiate payment");
//   //       }
//   //     }
//   //
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     if (result == 'Success') {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment Successful! Finalizing order...'),
//   //           backgroundColor: Colors.green,
//   //         ),
//   //       );
//   //
//   //       // ✅ Currency logic fix
//   //       final currencyState = context.read<CurrencyBloc>().state;
//   //       if (currencyState is! CurrencyLoaded) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Error: Currency information not available.')),
//   //         );
//   //         setState(() => _isProcessing = false);
//   //         return;
//   //       }
//   //
//   //       final txnid = payUData['txnid'] as String;
//   //
//   //       context.read<ShippingBloc>().add(FinalizePayUOrder(
//   //         txnid: txnid,
//   //         currencyCode: currencyState.selectedCurrencyCode,
//   //       ));
//   //
//   //       if (kDebugMode) {
//   //         print("✅ Payment success! Dispatching FinalizePayUOrder with txnid: $txnid "
//   //             "and currencyCode: ${currencyState.selectedCurrencyCode}");
//   //       }
//   //     } else {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(
//   //           content: Text('Payment failed or was canceled.'),
//   //           backgroundColor: Colors.red,
//   //         ),
//   //       );
//   //       if (kDebugMode) print("⚠️ Payment not successful. Result: $result");
//   //     }
//   //   } catch (e) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //     if (kDebugMode) print("❌ Error in placeOrderWithPayU: $e");
//   //   }
//   // }
//
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //   try {
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
//   //     );
//   //
//   //     if (result == 'Success') {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
//   //       );
//   //
//   //       // ✅✅✅ THIS IS THE FINAL FIX ✅✅✅
//   //       // You must add the currency logic here, just like in the Stripe method.
//   //
//   //       // 1. Get the current currency state from the global BLoC
//   //       final currencyState = context.read<CurrencyBloc>().state;
//   //
//   //       // 2. Check if the currency is loaded before proceeding
//   //       if (currencyState is! CurrencyLoaded) {
//   //         ScaffoldMessenger.of(context).showSnackBar(
//   //           const SnackBar(content: Text('Error: Currency information not available.')),
//   //         );
//   //         setState(() => _isProcessing = false);
//   //         return;
//   //       }
//   //
//   //       final txnid = payUData['txnid'] as String;
//   //
//   //       // 3. Dispatch the event WITH the required currencyCode
//   //       context.read<ShippingBloc>().add(FinalizePayUOrder(
//   //         txnid: txnid,
//   //         currencyCode: currencyState.selectedCurrencyCode, // Pass the code
//   //       ));
//   //
//   //     } else {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //   }
//   // }
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //
//   //     // We no longer need to set processing to false here, the BLoC will handle it
//   //     // setState(() => _isProcessing = false);
//   //
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(builder: (context) => PayUWebViewScreen(paymentData: payUData)),
//   //     );
//   //
//   //     // After returning from WebView, handle the result
//   //     if (result == 'Success') {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
//   //       );
//   //
//   //       // ✅ INSTEAD OF NAVIGATING, DISPATCH THE NEW EVENT
//   //       // The BLoC listener will take care of the final navigation
//   //       final txnid = payUData['txnid'] as String;
//   //       context.read<ShippingBloc>().add(FinalizePayUOrder(txnid: txnid));
//   //
//   //     } else {
//   //       // If payment failed or was cancelled, stop the processing indicator
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) setState(() => _isProcessing = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //     );
//   //   }
//   // }
//   // Future<void> _placeOrderWithPayU() async {
//   //   if (mounted) setState(() => _isProcessing = true);
//   //
//   //   try {
//   //     // This now returns a `dynamic` type because it could be a List or a Map
//   //     final dynamic rawPayUData = await _shippingRepository.initiatePayUPayment();
//   //
//   //     // ------------------- ✅ NEW FIX STARTS HERE -------------------
//   //
//   //
//   //     // Check if the response is the incorrect List format
//   //
//   //     // Check if the response is already in the correct Map format
//   //
//   //     // ------------------- ✅ NEW FIX ENDS HERE -------------------
//   //     final payUData = await _shippingRepository.initiatePayUPayment();
//   //     if (!mounted) return;
//   //     setState(() => _isProcessing = false);
//   //
//   //     // Now, `payUData` is guaranteed to be a Map, and this navigation will work.
//   //     final result = await Navigator.push(
//   //       context,
//   //       MaterialPageRoute(
//   //         builder: (context) => PayUWebViewScreen(paymentData: payUData),
//   //       ),
//   //     );
//   //
//   //     // ... (rest of the function remains the same)
//   //     if (result == 'Success') {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment Successful! Finalizing order...'), backgroundColor: Colors.green),
//   //       );
//   //       final cartState = context.read<CartBloc>().state;
//   //       final cartItems = (cartState is CartLoaded) ? cartState.items : [];
//   //       Navigator.pushAndRemoveUntil(
//   //         context,
//   //         MaterialPageRoute(builder: (_) => OrderSuccessScreen(
//   //           orderId: int.tryParse(payUData['txnid'].toString().split('-').first.substring(1)) ?? 0,
//   //           totals: widget.totals,
//   //           billingAddress: widget.billingAddress,
//   //           items: cartItems,
//   //         )),
//   //             (route) => false,
//   //       );
//   //     } else {
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         const SnackBar(content: Text('Payment failed or was canceled.'), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       setState(() => _isProcessing = false);
//   //       ScaffoldMessenger.of(context).showSnackBar(
//   //         SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
//   //       );
//   //     }
//   //   }
//   // }
//
//   // --- COMMON UI WIDGETS ---
//
//   Widget _buildPlaceOrderButton() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       builder: (context, state) {
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
//               ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
//               : const Text('PLACE ORDER'),
//         );
//       },
//     );
//   }
//
//   Widget _buildEstimatedTotal(dynamic grandTotalValue, int qty) {
//     // final grandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
//     // ✅ 1. Get the current currency state
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     // --- Prepare variables ---
//     // This is the BASE grand total in INR from your API
//     final double baseGrandTotal = (grandTotalValue as num?)?.toDouble() ?? 0.0;
//
//     // ✅ 2. Set default and then calculate the display values
//     String displaySymbol = '₹'; // Default symbol
//     double displayGrandTotal = baseGrandTotal; // Default price
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       // Calculate price: (base price in INR) * (selected currency's rate)
//       displayGrandTotal = baseGrandTotal * currencyState.selectedRate.rate;
//     }
//
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(4.0)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text('Estimated Total', style: TextStyle(fontSize: 16)),
//               const SizedBox(height: 4),
//               Text(
//                 '$displaySymbol${displayGrandTotal.toStringAsFixed(2)}',
//                 style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               // Text(_currencyFormat.format(grandTotal), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ],
//           ),
//           Row(
//             children: [
//               const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
//                 child: Text(qty.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
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
//           onChanged: (bool? value) => setState(() => _isBillingSameAsShipping = value ?? true),
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
//                   '${widget.billingAddress['country_id']}\n'
//                   '${widget.billingAddress['telephone']}',
//               style: const TextStyle(height: 1.5, color: Colors.black87),
//             ),
//           )
//         ]
//       ],
//     );
//   }
// }

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