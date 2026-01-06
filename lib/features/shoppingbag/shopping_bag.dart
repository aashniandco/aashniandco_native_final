import 'dart:ui';

import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart'; // Correct, single import for LoginScreen
import 'package:aashniandco/features/checkout/checkout_screen.dart';
import 'package:aashniandco/features/login/view/login_screen.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:aashniandco/features/shoppingbag/view/checkout_webview.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import ' shipping_bloc/shipping_bloc.dart';
import ' shipping_bloc/shipping_event.dart';
import ' shipping_bloc/shipping_state.dart';
import '../../constants/api_constants.dart';
import '../../constants/user_preferences_helper.dart';
// import '../login/view/login_screen.dart'; // Removed duplicate/conflicting import
import '../../utils/helpers.dart';
import '../../widgets/no_internet_widget.dart';
import '../auth/bloc/currency_bloc.dart';
import '../auth/bloc/currency_state.dart';
import 'cart_bloc/cart_bloc.dart';
import 'cart_bloc/cart_event.dart';
import 'cart_bloc/cart_state.dart';
import 'cart_item_widget.dart';
import 'model/countries.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';


import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Assuming you have these models and BLoCs defined elsewhere
// import 'models.dart';
// import 'blocs.dart';
// import 'widgets.dart';
// import 'screens.dart';


import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart'; // Correct, single import for LoginScreen
import 'package:aashniandco/features/checkout/checkout_screen.dart';
import 'package:aashniandco/features/login/view/login_screen.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter/material.dart';
import 'package:dio/src/adapters/io_adapter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import ' shipping_bloc/shipping_bloc.dart';
import ' shipping_bloc/shipping_event.dart';
import ' shipping_bloc/shipping_state.dart';
import '../../constants/user_preferences_helper.dart';
// import '../login/view/login_screen.dart'; // Removed duplicate/conflicting import
import 'cart_bloc/cart_bloc.dart';
import 'cart_bloc/cart_event.dart';
import 'cart_bloc/cart_state.dart';
import 'cart_item_widget.dart';
import 'model/countries.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inapp;
import 'package:dio_cookie_manager/dio_cookie_manager.dart' as dio_cookie;


import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_bloc.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_bloc.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_bloc.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_bloc.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:io';

import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_bloc.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_event.dart';
import 'package:aashniandco/features/shoppingbag/%20shipping_bloc/shipping_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- (Assumed Imports) ---
// Make sure you have these imports for your project structure.
// import 'package:your_app/api/api_constants.dart';
// import 'package:your_app/models/country_model.dart';
// import 'package:your_app/models/shipping_method_model.dart';
// import 'package:your_app/bloc/cart_bloc/cart_bloc.dart';
// import 'package:your_app/bloc/shipping_bloc/shipping_bloc.dart';
// import 'package:your_app/ui/screens/auth_screen.dart';
// import 'package:your_app/ui/screens/login_screen.dart';
// import 'package:your_app/ui/widgets/cart_item_widget.dart';
// import 'package:your_app/ui/screens/checkout_screen.dart';
// -----------------------------


import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- (Assumed Imports) ---
// Make sure you have these imports for your project structure.
// import 'package:your_app/api/api_constants.dart';
// import 'package:your_app/models/country_model.dart';
// import 'package:your_app/models/shipping_method_model.dart';
// import 'package:your_app/bloc/cart_bloc/cart_bloc.dart';
// import 'package:your_app/bloc/shipping_bloc/shipping_bloc.dart';
// import 'package:your_app/ui/screens/auth_screen.dart';
// import 'package:your_app/ui/screens/login_screen.dart';
// import 'package:your_app/ui/widgets/cart_item_widget.dart';
// import 'package:your_app/ui/screens/checkout_screen.dart';
// -----------------------------


import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- (Assumed Imports) ---
// Make sure you have these imports for your project structure.
// import 'package:your_app/api/api_constants.dart';
// import 'package:your_app/models/country_model.dart';
// import 'package:your_app/models/shipping_method_model.dart';
// import 'package:your_app/bloc/cart_bloc/cart_bloc.dart';
// import 'package:your_app/bloc/shipping_bloc/shipping_bloc.dart';
// import 'package:your_app/ui/screens/auth_screen.dart';
// import 'package:your_app/ui/screens/login_screen.dart';
// import 'package:your_app/ui/widgets/cart_item_widget.dart';
// import 'package:your_app/ui/screens/checkout_screen.dart';
// -----------------------------


class ShoppingBagScreen extends StatefulWidget {
  const ShoppingBagScreen({super.key});

  @override
  State<ShoppingBagScreen> createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  // Session State
  bool isLoading = true;
  bool isLoggedIn = false;
  bool hasGuestCart = false;
  String? _userToken;
  // Blocs & Controllers
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _couponController = TextEditingController();

  late ShippingBloc _shippingBloc;

  // Local state for UI
  List<Country> countries = [];
  String selectedCountryName = '';
  String selectedCountryId = '';
  String selectedRegionName = '';
  String selectedRegionId = '';
  bool isShippingLoading = false;
  double currentShippingCost = 0.0;
  List<ShippingMethod> availableShippingMethods = [];
  ShippingMethod? selectedShippingMethod;


  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Future<void> _initializeScreen() async {
  //   if (!mounted) return;
  //   setState(() => isLoading = true);
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
  //   hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
  //   _userToken = prefs.getString('user_token');
  //
  //   // --- ⛔️ REMOVE THIS ENTIRE IF BLOCK ⛔️ ---
  //   // if (!isLoggedIn && !hasGuestCart) {
  //   //   if (mounted) setState(() => isLoading = false);
  //   //   return;
  //   // }
  //   // --- END OF REMOVAL ---
  //
  //   // ✅ ALWAYS run this part
  //   _shippingBloc = context.read<ShippingBloc>();
  //   context.read<CartBloc>().add(FetchCartItems()); // Let the BLoC handle it
  //   _shippingBloc.add(FetchCountries());
  //   await _loadShippingPreferences();
  //
  //   if (mounted) setState(() => isLoading = false);
  // }
  Future<void> _initializeScreen() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
    _userToken = prefs.getString('user_token');

    if (!isLoggedIn && !hasGuestCart) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    _shippingBloc = context.read<ShippingBloc>();
    context.read<CartBloc>().add(FetchCartItems());
    _shippingBloc.add(FetchCountries());
    await _loadShippingPreferences();

    if (mounted) setState(() => isLoading = false);
  }

  Future<List<ShippingMethod>> _fetchAvailableShippingMethods({
    required String countryId,
    required String regionId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    String sessionType;

    if (customerToken != null && customerToken.isNotEmpty) {
      sessionType = "LOGGED-IN";
      url = Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/estimate-shipping-methods');
     print("shoppingbag>>$url");
      headers['Authorization'] = 'Bearer $customerToken';
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      sessionType = "GUEST";
      url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId/estimate-shipping-methods');
    } else {
      throw Exception("No active session found to estimate shipping.");
    }

    final payload = {
      "address": {
        "country_id": countryId,
        "region_id": int.tryParse(regionId) ?? 0,
      }
    };

    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);

    if (kDebugMode) {
      print("--- Shipping Estimate Request ($sessionType) ---");
      print("URL: $url");
      print("Body: ${json.encode(payload)}");
    }

    final response = await client.post(url, headers: headers, body: json.encode(payload));

    if (kDebugMode) {
      print("Shipping Estimate Response: ${response.statusCode}, ${response.body}");
    }

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
    }
  }

  Future<void> _redirectToLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isUserLoggedIn');
    await prefs.remove('user_token');
    // Optional: clear other user-specific data

    if (!mounted) return;

    // Navigate and clear the navigation stack so they can't go back
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen1()),
          (route) => false,
    );
  }

  Future<void> _triggerShippingMethodUpdate() async {
    if (selectedCountryId.isEmpty) {
      if (kDebugMode) print("Skipping shipping fetch: Country is missing.");
      setState(() {
        availableShippingMethods = [];
        selectedShippingMethod = null;
        currentShippingCost = 0.0;
      });
      return;
    }

    if (!mounted) return;
    setState(() => isShippingLoading = true);

    try {
      final List<ShippingMethod> fetchedMethods = await _fetchAvailableShippingMethods(
        countryId: selectedCountryId,
        regionId: selectedRegionId,
      );

      if (!mounted) return;

      // if (fetchedMethods.isEmpty) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     const SnackBar(content: Text("No shipping methods available for this address.")),
      //   );
      // }

      setState(() {
        availableShippingMethods = fetchedMethods;
        if (availableShippingMethods.isNotEmpty) {
          selectedShippingMethod = availableShippingMethods.first;
          currentShippingCost = selectedShippingMethod!.amount;
        } else {
          selectedShippingMethod = null;
          currentShippingCost = 0.0;
        }
        isShippingLoading = false;
      });
      _saveShippingPreferences();

    } catch (e) {

      if (!mounted) return;

      if (e.toString().contains("The consumer isn't authorized to access %resources")) {
        _redirectToLogin();
        return;
      }

      if (kDebugMode) print("Error fetching shipping methods: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.grey),
      );
      setState(() {
        availableShippingMethods = [];
        selectedShippingMethod = null;
        currentShippingCost = 0.0;
        isShippingLoading = false;
      });
    }
  }


  Future<void> _saveShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country_name', selectedCountryName);
    await prefs.setString('selected_country_id', selectedCountryId);
    await prefs.setString('selected_region_name', selectedRegionName);
    await prefs.setString('selected_region_id', selectedRegionId);

    if (selectedShippingMethod != null) {
      await prefs.setDouble('shipping_price', selectedShippingMethod!.amount);
      await prefs.setString('shipping_method_name', selectedShippingMethod!.displayName);
      await prefs.setString('carrier_code', selectedShippingMethod!.carrierCode);
      await prefs.setString('method_code', selectedShippingMethod!.methodCode);
    } else {
      await prefs.remove('shipping_price');
      await prefs.remove('shipping_method_name');
      await prefs.remove('carrier_code');
      await prefs.remove('method_code');
    }
  }

  Future<void> _loadShippingPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      selectedCountryName = prefs.getString('selected_country_name') ?? '';
      selectedCountryId = prefs.getString('selected_country_id') ?? '';
      selectedRegionName = prefs.getString('selected_region_name') ?? '';
      selectedRegionId = prefs.getString('selected_region_id') ?? '';
    });
  }

  Widget _buildLoginPrompt(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Bag'),
        leading: IconButton(
          icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
              const SizedBox(height: 24),
              const Text("Login to View Your Bag",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text("Sign in to see your items, get shipping estimates, and proceed to checkout.",
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen1()))
                      .then((_) => _initializeScreen());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text("SIGN IN / CREATE ACCOUNT", style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Display a full-screen loader while the initial screen setup is in progress.
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Shopping Bag')),
        backgroundColor: Colors.white,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // If the user is not logged in and has no guest cart, they have no active session.
    // Prompt them to log in to see or use their bag.
    if (!isLoggedIn && !hasGuestCart) {
      return _buildLoginPrompt(context);
    }

    // Main UI for a user with an active session (logged in or guest).
    return MultiBlocListener(
      listeners: [
        BlocListener<ShippingBloc, ShippingState>(
          listener: (context, state) {
            if (state is CountriesLoaded) {
              // Sort the regions (states) within each country alphabetically
              for (var country in state.countries) {
                country.regions.sort((a, b) => a.name.compareTo(b.name));
              }

              // Sort the main country list alphabetically by name
              state.countries.sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));

              // Set the state with the fully sorted data
              setState(() => countries = state.countries);

              // Trigger shipping method update if a country is already selected,
              // or default to a country if the cart is loaded and has items.
              if (selectedCountryId.isNotEmpty) {
                _triggerShippingMethodUpdate();
              } else if ((context.read<CartBloc>().state is CartLoaded &&
                  (context.read<CartBloc>().state as CartLoaded).items.isNotEmpty) &&
                  countries.isNotEmpty) {
                final defaultCountry = countries.firstWhere((c) => c.id == 'GB', orElse: () => countries.first);
                setState(() {
                  selectedCountryName = defaultCountry.fullNameEnglish;
                  selectedCountryId = defaultCountry.id;
                });
                _triggerShippingMethodUpdate();
              }
            }
          },
        ),
        // --- START OF THE FIX ---
        // Add this new listener for CartBloc to handle coupon errors.
        //26/12/2025
        // BlocListener<CartBloc, CartState>(
        //   // Use listenWhen to only trigger if the state is CartLoaded and a couponError has just appeared.
        //   listenWhen: (previous, current) {
        //     if (current is CartLoaded) {
        //       // Trigger if there's a new error message.
        //       return current.couponError != null;
        //     }
        //     return false;
        //   },
        //   listener: (context, state) {
        //     // Because of listenWhen, we know 'state' is a CartLoaded instance.
        //     final loadedState = state as CartLoaded;
        //
        //     // Show the dialog with the error message from the state.
        //     _showCouponErrorDialog(loadedState.couponError!);
        //
        //     // IMPORTANT: Immediately dispatch an event to clear the error from the state.
        //     // This prevents the dialog from showing again on the next rebuild.
        //     context.read<CartBloc>().add(ClearCouponError());
        //   },
        // ),


        // --- END OF THE FIX ---

        BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            // 1. Handle AUTHENTICATION Errors (CartError State)
            if (state is CartError) {
              if (state.message.contains("The consumer isn't authorized to access %resources")) {
                _redirectToLogin(); // Direct navigation to Login
                return;
              }
            }

            // 2. Handle COUPON Errors (CartLoaded State)
            if (state is CartLoaded) {
              if (state.couponError != null) {
                _showCouponErrorDialog(state.couponError!);

                // Clear error immediately so the dialog doesn't pop up again on rebuild
                context.read<CartBloc>().add(ClearCouponError());
              }
            }
          },
        ),
        BlocListener<CartBloc, CartState>(
          listenWhen: (previous, current) {
            // Re-fetch shipping methods whenever the cart content changes.
            if (previous is CartLoading && current is CartLoaded) {
              return true;
            }
            if (previous is CartLoaded && current is CartLoaded) {
              final prevQty = previous.items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0));
              final currentQty = current.items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0));
              return prevQty != currentQty;
            }
            return false;
          },
          listener: (context, state) {
            if (kDebugMode) {
              print("Cart has changed. Refreshing shipping methods...");
            }
            _triggerShippingMethodUpdate();
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Shopping Bag'),
          leading: IconButton(
            icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
            onPressed: () => Navigator.pushAndRemoveUntil(
                context, MaterialPageRoute(builder: (context) => const AuthScreen()), (r) => false),
          ),
        ),
        backgroundColor: Colors.white,
        body: BlocBuilder<CartBloc, CartState>(
          builder: (context, state) {

            ///
            if (state is CartError) {

              //26/12/2025
              if (state.message.contains("The consumer isn't authorized")) {
                return const Center(child: CircularProgressIndicator());
              }

              // Use the helper to check if it's a network issue
              if (isNetworkError(state.message)) {
                return NoInternetWidget(
                  onRetry: () {
                    // 🔄 Retry Logic: Trigger the start event again
                    context.read<CartBloc>().add(FetchCartItems());
                  },
                );
              }
              // Optional: Handle non-internet errors here if needed
            }
            // Handle loading and initial states for the cart.
            if (state is CartLoading || state is CartInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            // Handle cart-related errors.
            if (state is CartError) {
              return Center(child: Text("Error: ${state.message}"));
            }

            // Handle the successfully loaded cart state.
            if (state is CartLoaded) {
              // ✅ MODIFIED PART: If the cart is loaded but has no items, display the empty bag message.
              if (state.items.isEmpty) {
                return const Center(
                  child: Text(
                    "Your shopping bag is empty.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              // If the cart has items, build the main content view.
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.items.length,
                            itemBuilder: (context, index) {
                              final item = state.items[index];
                              return CartItemWidget(
                                key: ValueKey(item['item_id']),
                                item: item,
                                onAdd: () => context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
                                onRemove: () {
                                  if ((item['qty'] ?? 1) > 1) {
                                    context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
                                  }
                                },
                                onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                              child: Column(
                                children: [
                                  _buildShippingContainer(),
                                  const SizedBox(height: 20),
                                  _buildOrderSummary(state),
                                  const SizedBox(height: 20),
                                  _buildCouponSection(state),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Bottom sticky checkout button.
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0,-5))
                        ]
                    ),
                    child: _buildCheckoutButton(),
  // Widget build(BuildContext context) {
  //   if (isLoading) {
  //     return Scaffold(
  //       appBar: AppBar(title: const Text('Shopping Bag')),
  //       body: const Center(child: CircularProgressIndicator()),
  //     );
  //   }
  //
  //   if (!isLoggedIn && !hasGuestCart) {
  //     return _buildLoginPrompt(context);
  //   }
  //
  //   return MultiBlocListener(
  //     listeners: [
  //       BlocListener<ShippingBloc, ShippingState>(
  //         listener: (context, state) {
  //           //live*
  //           // if (state is CountriesLoaded) {
  //           //   setState(() => countries = state.countries);
  //           //   if (selectedCountryId.isNotEmpty) {
  //           //     _triggerShippingMethodUpdate();
  //           //   } else if ((context.read<CartBloc>().state is CartLoaded &&
  //           //       (context.read<CartBloc>().state as CartLoaded).items.isNotEmpty) &&
  //           //       countries.isNotEmpty) {
  //           //     final defaultCountry = countries.firstWhere((c) => c.id == 'GB', orElse: () => countries.first);
  //           //     setState(() {
  //           //       selectedCountryName = defaultCountry.fullNameEnglish;
  //           //       selectedCountryId = defaultCountry.id;
  //           //     });
  //           //     _triggerShippingMethodUpdate();
  //           //   }
  //           // }
  //
  //           if (state is CountriesLoaded) {
  //             // ✅ 1. Sort the regions (states) within each country alphabetically
  //             for (var country in state.countries) {
  //               country.regions.sort((a, b) => a.name.compareTo(b.name));
  //             }
  //
  //             // ✅ 2. Sort the main country list alphabetically by name
  //             state.countries.sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));
  //
  //             // Now, set the state with the fully sorted data
  //             setState(() => countries = state.countries);
  //
  //             // The rest of your existing logic can remain as is
  //             if (selectedCountryId.isNotEmpty) {
  //               _triggerShippingMethodUpdate();
  //             } else if ((context.read<CartBloc>().state is CartLoaded &&
  //                 (context.read<CartBloc>().state as CartLoaded).items.isNotEmpty) &&
  //                 countries.isNotEmpty) {
  //               final defaultCountry = countries.firstWhere((c) => c.id == 'GB', orElse: () => countries.first);
  //               setState(() {
  //                 selectedCountryName = defaultCountry.fullNameEnglish;
  //                 selectedCountryId = defaultCountry.id;
  //               });
  //               _triggerShippingMethodUpdate();
  //             }
  //           }
  //
  //
  //         },
  //       ),
  //       // ✅ MODIFIED: THIS LISTENER IS NOW MORE ROBUST
  //       BlocListener<CartBloc, CartState>(
  //         listenWhen: (previous, current) {
  //           // Condition 1: Handle the standard loading -> loaded transition.
  //           if (previous is CartLoading && current is CartLoaded) {
  //             return true;
  //           }
  //           // Condition 2: Handle cases where the bloc might go from loaded -> loaded
  //           // with a different number of items, ensuring optimistic updates are caught.
  //           if (previous is CartLoaded && current is CartLoaded) {
  //             final prevQty = previous.items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0));
  //             final currentQty = current.items.fold<int>(0, (sum, item) => sum + (item['qty'] as int? ?? 0));
  //             return prevQty != currentQty;
  //           }
  //           return false;
  //         },
  //         listener: (context, state) {
  //           if (kDebugMode) {
  //             print("Cart has changed. Refreshing shipping methods...");
  //           }
  //           _triggerShippingMethodUpdate();
  //         },
  //       ),
  //     ],
  //     child: Scaffold(
  //       appBar: AppBar(
  //         title: const Text('Shopping Bag'),
  //         leading: IconButton(
  //           icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
  //           onPressed: () => Navigator.pushAndRemoveUntil(
  //               context, MaterialPageRoute(builder: (context) => const AuthScreen()), (r) => false),
  //         ),
  //       ),
  //       body: BlocBuilder<CartBloc, CartState>(
  //         builder: (context, state) {
  //           if (state is CartLoading || state is CartInitial) {
  //             return const Center(child: CircularProgressIndicator());
  //           }
  //
  //           if (state is CartError) {
  //             return Center(child: Text("Error: ${state.message}"));
  //           }
  //
  //           if (state is CartLoaded) {
  //             if (state.items.isEmpty) {
  //               return const Center(
  //                 child: Text("Your shopping bag is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)),
  //               );
  //             }
  //
  //             return Column(
  //               children: [
  //                 Expanded(
  //                   child: SingleChildScrollView(
  //                     controller: _scrollController,
  //                     padding: const EdgeInsets.only(bottom: 16),
  //                     child: Column(
  //                       children: [
  //                         ListView.builder(
  //                           shrinkWrap: true,
  //                           physics: const NeverScrollableScrollPhysics(),
  //                           itemCount: state.items.length,
  //                           itemBuilder: (context, index) {
  //                             final item = state.items[index];
  //                             return CartItemWidget(
  //                               key: ValueKey(item['item_id']),
  //                               item: item,
  //                               onAdd: () => context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
  //                               onRemove: () {
  //                                 if ((item['qty'] ?? 1) > 1) {
  //                                   context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
  //                                 }
  //                               },
  //                               onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
  //                             );
  //                           },
  //                         ),
  //                         Padding(
  //                           padding: const EdgeInsets.all(12.0),
  //                           child: Container(
  //                             decoration: BoxDecoration(
  //                                 color: Colors.grey.shade100,
  //                                 boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
  //                             child: Column(
  //                               children: [
  //                                 _buildShippingContainer(),
  //                                 const SizedBox(height: 20),
  //                                 _buildOrderSummary(state),
  //                                 const SizedBox(height: 20),
  //                                 // _buildCouponSection(),
  //                                 _buildCouponSection(state),
  //                                 const SizedBox(height: 20),
  //                               ],
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
  //                   width: double.infinity,
  //                   decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       boxShadow: [
  //                         BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0,-5))
  //                       ]
  //                   ),
  //                   child: _buildCheckoutButton(),
                  ),
                ],
              );
            }

            return const Center(child: Text("Welcome! Your cart is loading."));
          },
        ),
      ),
    );
  }

  Widget _buildShippingMethodsList() {
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double exchangeRate = 1.0;
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      exchangeRate = currencyState.selectedRate.rate;
    }

    if (isShippingLoading) {
      return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
    }
    if (availableShippingMethods.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text("Select a country to see shipping options."),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: availableShippingMethods.map((method) {
        final convertedAmount = method.amount * exchangeRate;
        return RadioListTile<ShippingMethod>(
          title: Text(method.displayName),
          subtitle: Text('$displaySymbol${convertedAmount.toStringAsFixed(2)}'),
          value: method,
          groupValue: selectedShippingMethod,
          activeColor: Colors.black,
          onChanged: (ShippingMethod? value) {
            setState(() {
              selectedShippingMethod = value;
              currentShippingCost = value?.amount ?? 0.0;
            });
            _saveShippingPreferences();
          },
        );
      }).toList(),
    );
  }


  Widget _buildShippingContainer() {
    final List<String> countryNames = [
      for (final country in countries)
        if (country.fullNameEnglish.isNotEmpty) country.fullNameEnglish,
    ];

    Country? selectedCountryData;
    if (selectedCountryName.isNotEmpty && countries.isNotEmpty) {
      try {
        selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
      } catch (_) {
        selectedCountryData = null;
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
            child: const Text('Estimate Shipping',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildDropdown(
                  label: 'Select Country',
                  value: selectedCountryName.isEmpty ? null : selectedCountryName,
                  items: countryNames,
                  onChanged: (value) {
                    if (value == null) return;
                    final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
                    setState(() {
                      selectedCountryName = country.fullNameEnglish;
                      selectedCountryId = country.id;
                      selectedRegionName = '';
                      selectedRegionId = '';
                      selectedShippingMethod = null;
                      availableShippingMethods = [];
                      currentShippingCost = 0.0;
                    });
                    _triggerShippingMethodUpdate();
                  },
                ),
                const SizedBox(height: 20),
                if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
                  buildDropdown(
                    label: 'Select State / Province',
                    value: selectedRegionName.isEmpty ? null : selectedRegionName,
                    items: [
                      for (final region in selectedCountryData.regions)
                        if (region.name.isNotEmpty) region.name,
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
                      setState(() {
                        selectedRegionName = region.name;
                        selectedRegionId = region.id;
                        selectedShippingMethod = null;
                        availableShippingMethods = [];
                        currentShippingCost = 0.0;
                      });
                      _triggerShippingMethodUpdate();
                    },
                  ),
                const SizedBox(height: 10),
                _buildShippingMethodsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(CartLoaded cartState) {
    final currencyState = context.watch<CurrencyBloc>().state;

    String displaySymbol = '₹';
    double exchangeRate = 1.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      exchangeRate = currencyState.selectedRate.rate;
    }

    // 1. Get the 'totals' object from the cart state.
    final totals = cartState.totals ?? {};

    // 2. Extract the subtotal and discount from the server's response.
    final double subtotal = (totals['subtotal_incl_tax'] ?? 0.0).toDouble();
    final double discount = (totals['discount_amount'] ?? 0.0).toDouble().abs();
    final String couponCode = totals['coupon_code'] ?? '';

    // 3. Use the shipping cost from the local UI state (`currentShippingCost`).
    //    This is the cost of the shipping method the user just tapped on.
    double shippingCostInBaseCurrency = currentShippingCost;

    // 4. --- ✅ KEY CHANGE: Manually calculate the total based on your rule ---
    //    (Subtotal - Discount) + Shipping Cost
    final double calculatedTotalInBaseCurrency = (subtotal - discount) + shippingCostInBaseCurrency;


    // 5. Apply the currency conversion rate to all values for display.
    final double subtotalConverted = subtotal * exchangeRate;
    final double discountConverted = discount * exchangeRate;
    final double shippingCostConverted = shippingCostInBaseCurrency * exchangeRate;
    final double totalConverted = calculatedTotalInBaseCurrency * exchangeRate; // Use the manually calculated total

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // --- Subtotal ---
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Subtotal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            Text('$displaySymbol${subtotalConverted.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ]),

          // --- Discount (Conditional Row) ---
          if (discount > 0) ...[
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Discount ($couponCode)', style: const TextStyle(fontSize: 16, color: Colors.black)),
              Text("-$displaySymbol${discountConverted.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, color: Colors.black)),
            ]),
          ],

          const SizedBox(height: 12),

          // --- Shipping Row ---
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Shipping (${selectedShippingMethod?.methodTitle ?? "Not Selected"})',
                style: const TextStyle(fontSize: 16)),
            Text("$displaySymbol${shippingCostConverted.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
          ]),

          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 12),

          // --- Order Total ---
          // This now reflects the instant calculation
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('$displaySymbol${totalConverted.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
        ],
      ),
    );
  }
  // Widget _buildOrderSummary(CartLoaded cartState) {
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //
  //   String displaySymbol = '₹';
  //   double exchangeRate = 1.0;
  //
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     exchangeRate = currencyState.selectedRate.rate;
  //   }
  //
  //   double subtotalInBaseCurrency = cartState.items.fold(
  //       0.0,
  //           (sum, item) =>
  //       sum + ((item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0)));
  //
  //   double shippingCostInBaseCurrency = currentShippingCost;
  //
  //   double subtotalConverted = subtotalInBaseCurrency * exchangeRate;
  //   double shippingCostConverted = shippingCostInBaseCurrency * exchangeRate;
  //   final totalConverted = subtotalConverted + shippingCostConverted;
  //   return Container(
  //     width: double.infinity,
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
  //     child: Column(
  //       children: [
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //           const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
  //           Text('$displaySymbol${subtotalConverted.toStringAsFixed(2)}',
  //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
  //         ]),
  //         const SizedBox(height: 12),
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //           Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})',
  //               style: const TextStyle(fontSize: 16)),
  //           Text("$displaySymbol${shippingCostConverted.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
  //         ]),
  //         const SizedBox(height: 20),
  //         const Divider(thickness: 1),
  //         const SizedBox(height: 12),
  //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
  //           const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //           Text('$displaySymbol${totalConverted.toStringAsFixed(2)}',
  //               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //         ]),
  //       ],
  //     ),
  //   );
  // }

  // Future<void> _showCouponErrorDialog(String message) async {
  //   return showDialog<void>(
  //     context: context,
  //     barrierDismissible: false, // User must tap a button to close!
  //     builder: (BuildContext dialogContext) {
  //       return AlertDialog(
  //         title: const Text('Invalid Coupon'),
  //         content: SingleChildScrollView(
  //           child: ListBody(
  //             children: <Widget>[
  //               Text(message),
  //             ],
  //           ),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: const Text('OK'),
  //             onPressed: () {
  //               Navigator.of(dialogContext).pop(); // Close the dialog
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _showCouponErrorDialog(String message) async {
    await showGeneralDialog<Object?>(
      context: context,
      barrierDismissible: false,
      barrierLabel: "Invalid Coupon",
      barrierColor: Colors.black.withOpacity(0.4), // Dim background overlay
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, anim1, anim2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, anim1, anim2, child) {
        final curvedValue = Curves.easeOutBack.transform(anim1.value) - 1.0;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), // 🌫️ Soft blur effect
          child: Opacity(
            opacity: anim1.value,
            child: Transform(
              transform: Matrix4.translationValues(0.0, curvedValue * -50, 0.0),
              child: AlertDialog(
                backgroundColor: Colors.black.withOpacity(0.9),
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Colors.white, width: 1),
                ),
                title: const Text(
                  'Invalid Coupon',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text(
                        message,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                actionsAlignment: MainAxisAlignment.end,
                actions: <Widget>[
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Text(
                        'OK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCouponSection(CartLoaded cartState) {
    final String appliedCouponCode = cartState.totals?['coupon_code'] ?? '';
    final bool isCouponApplied = appliedCouponCode.isNotEmpty;

    if (isCouponApplied) {
      _couponController.text = appliedCouponCode;
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _couponController,
            readOnly: isCouponApplied,
            decoration: InputDecoration(
              hintText: 'Enter coupon code',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,

              // 👉 Show X icon only when coupon applied
              suffixIcon: isCouponApplied
                  ? GestureDetector(
                onTap: () {
                  _couponController.clear();
                  context.read<CartBloc>().add(RemoveCoupon());
                },
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 18,
                ),
              )
                  : null,
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 👉 APPLY BUTTON – show only when no coupon is applied
        if (!isCouponApplied)
          ElevatedButton(
            onPressed: () {
              final code = _couponController.text.trim();
              if (code.isNotEmpty) {
                context.read<CartBloc>().add(ApplyCoupon(code));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              minimumSize: const Size(60, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Apply"),
          ),
      ],
    );
  }

  // Widget _buildCouponSection(CartLoaded cartState) {
  //   final String appliedCouponCode = cartState.totals?['coupon_code'] ?? '';
  //   final bool isCouponApplied = appliedCouponCode.isNotEmpty;
  //
  //   if (isCouponApplied) {
  //     _couponController.text = appliedCouponCode;
  //   }
  //
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: TextField(
  //           controller: _couponController,
  //           readOnly: isCouponApplied, // make readonly when applied
  //           decoration: InputDecoration(
  //             hintText: 'Enter coupon code',
  //             border: OutlineInputBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             filled: true,
  //             fillColor: Colors.white,
  //
  //             // 👉 X icon inside TextField
  //             suffixIcon: isCouponApplied
  //                 ? GestureDetector(
  //               onTap: () {
  //                 _couponController.clear();
  //                 context.read<CartBloc>().add(RemoveCoupon());
  //               },
  //               child: const Icon(
  //                 Icons.close,
  //                 color: Colors.black,
  //                 size: 18,
  //               ),
  //             )
  //                 : null,
  //           ),
  //         ),
  //       ),
  //
  //       const SizedBox(width: 12),
  //
  //       // 👉 Apply button only (no Cancel button)
  //       ElevatedButton(
  //         onPressed: () {
  //           if (!isCouponApplied) {
  //             final code = _couponController.text.trim();
  //             if (code.isNotEmpty) {
  //               context.read<CartBloc>().add(ApplyCoupon(code));
  //             }
  //           }
  //         },
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.black,
  //           foregroundColor: Colors.white,
  //           minimumSize: const Size(60, 50),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //         ),
  //         child: const Text("Apply"),
  //       ),
  //     ],
  //   );
  // }


  // Widget _buildCouponSection(CartLoaded cartState) {
  //   // Check if a coupon is already applied from the totals data
  //   final String appliedCouponCode = cartState.totals?['coupon_code'] ?? '';
  //   final bool isCouponApplied = appliedCouponCode.isNotEmpty;
  //
  //   // Set the text field if a coupon is already applied
  //   if (isCouponApplied) {
  //     _couponController.text = appliedCouponCode;
  //   }
  //
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: IgnorePointer(
  //           ignoring: isCouponApplied,
  //           child: TextField(
  //             controller: _couponController,
  //             readOnly: isCouponApplied, // Make read-only if coupon is applied
  //             decoration: InputDecoration(
  //                 hintText: 'Enter coupon code',
  //                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //                 filled: true,
  //                 fillColor: Colors.white),
  //           ),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       ElevatedButton(
  //           onPressed: () {
  //             if (isCouponApplied) {
  //               // If coupon is applied, the button should trigger remove
  //               _couponController.clear();
  //               context.read<CartBloc>().add( RemoveCoupon());
  //             } else {
  //               // Otherwise, apply the coupon from the text field
  //               final code = _couponController.text.trim();
  //               if (code.isNotEmpty) {
  //                 context.read<CartBloc>().add(ApplyCoupon(code));
  //               }
  //             }
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: isCouponApplied ? Colors.red : Colors.black,
  //             foregroundColor: Colors.white,
  //           ),
  //           child: Text(isCouponApplied ? "Cancel" : "Apply")),
  //     ],
  //   );
  // }

  // Widget _buildCouponSection() {
  //   return Row(
  //     children: [
  //       Expanded(
  //         child: TextField(
  //           decoration: InputDecoration(
  //               hintText: 'Enter coupon code',
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  //               filled: true,
  //               fillColor: Colors.white),
  //         ),
  //       ),
  //       const SizedBox(width: 12),
  //       ElevatedButton(
  //           onPressed: () {},
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
  //           child: const Text("Apply")),
  //     ],
  //   );
  // }

  Widget _buildCheckoutButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          _saveShippingPreferences();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<ShippingBloc>(),
                child:  CheckoutScreen(),
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          minimumSize: const Size(350, 50),
        ),
        child: const Text("CHECKOUT", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16)),
      ),
    );
  }

  Widget buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('Please select an option', style: TextStyle(color: Colors.grey.shade600)),
          items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            filled: true,
            fillColor: Colors.white,
          ),
          isExpanded: true,
        ),
      ],
    );
  }
  bool isNetworkError(String message) {
    return message.contains("SocketException") ||
        message.contains("ClientException") ||
        message.contains("Failed host lookup");
  }
}


//fl
//   class ShoppingBagScreen extends StatefulWidget {
//     const ShoppingBagScreen({super.key});
//
//     @override
//     State<ShoppingBagScreen> createState() => _ShoppingBagScreenState();
//   }
//
//   class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
//     // Session State
//     bool isLoading = true;
//     bool isLoggedIn = false;
//     bool hasGuestCart = false;
//     String? _userEmail;
//     String? _userPassword;
//     String? _userToken;
//     // Blocs & Controllers
//     final ScrollController _scrollController = ScrollController();
//     late ShippingBloc _shippingBloc;
//
//     // Local state for UI, but critical logic will read from BLoC
//     double _cartTotalWeight = 0.0;
//     List<Country> countries = [];
//     String selectedCountryName = '';
//     String selectedCountryId = '';
//     String selectedRegionName = '';
//     String selectedRegionId = '';
//     bool isShippingLoading = false;
//     double currentShippingCost = 0.0;
//     List<ShippingMethod> availableShippingMethods = [];
//     ShippingMethod? selectedShippingMethod;
//
//
//
//     @override
//     void initState() {
//       super.initState();
//       _initializeScreen();
//     }
//
//     @override
//     void dispose() {
//       _scrollController.dispose();
//       super.dispose();
//     }
//
//     Future<void> _initializeScreen() async {
//       if (!mounted) return;
//       setState(() => isLoading = true);
//
//       final prefs = await SharedPreferences.getInstance();
//       isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//       hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//
//       _userEmail = prefs.getString('user_email');
//       _userPassword = prefs.getString('user_password');
//       _userToken = prefs.getString('user_token');
//
//
//       print("geustQuoteID>>$hasGuestCart");
//       print("User Email: $_userEmail");
//       print("User Password $_userPassword" );
//       print("User Token: $_userToken");
//       if (!isLoggedIn && !hasGuestCart) {
//         if (mounted) setState(() => isLoading = false);
//         return;
//       }
//
//       _shippingBloc = context.read<ShippingBloc>();
//       context.read<CartBloc>().add(FetchCartItems());
//       _shippingBloc.add(FetchCountries());
//       await _loadShippingPreferences();
//
//       if (mounted) setState(() => isLoading = false);
//     }
//
//
//
//     /// ✅ REVISED: This method now reads the cart weight directly from the BLoC state.
//     void _getShippingOptions() {
//       // Get the most up-to-date state from the CartBloc.
//       final cartState = context.read<CartBloc>().state;
//       double currentWeight = 0.0;
//       //
//       // double currentWeight = 1.5;
//
//       // Ensure the cart is loaded and get the weight.
//       if (cartState is CartLoaded) {
//         currentWeight = cartState.totalCartWeight;
//       }
//       // ✅ 2. --- ENHANCED DEBUGGING ---
//       print("--- [UI] Attempting to _getShippingOptions ---");
//       print("   - Is Logged In: $isLoggedIn");
//       print("   - Has Guest Cart: $hasGuestCart");
//       print("   - Selected Country ID: '$selectedCountryId'");
//       print("   - Selected Region ID: '$selectedRegionId'");
//       print("   - Current Cart Weight from BLoC: $currentWeight");
//       print("---------------------------------------------");
//       // Use the fresh weight value in the guard clause.
//       if (selectedCountryId.isEmpty || currentWeight <= 0) {
//         print("--- [UI] EXITING _getShippingOptions early. ---");
//         print('--- EXITING _getShippingOptions early. Reason: Country ID is empty or Weight is zero. ---');
//         setState(() {
//           isShippingLoading = false;
//           availableShippingMethods = [];
//           selectedShippingMethod = null;
//           currentShippingCost = 0.0;
//         });
//         return;
//       }
//       print("--- [UI] Guard clause passed. Dispatching FetchShippingMethods event. ---");
//       setState(() => isShippingLoading = true);
//       context.read<ShippingBloc>().add(
//         FetchShippingMethods(
//           countryId: selectedCountryId,
//           regionId: selectedRegionId,
//         ),
//       );
//     }
//
//     Future<void> _saveShippingPreferences() async {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('selected_country_name', selectedCountryName);
//       await prefs.setString('selected_country_id', selectedCountryId);
//       await prefs.setString('selected_region_name', selectedRegionName);
//       await prefs.setString('selected_region_id', selectedRegionId);
//
//       if (selectedShippingMethod != null) {
//         await prefs.setDouble('shipping_price', selectedShippingMethod!.amount);
//         await prefs.setString('shipping_method_name', selectedShippingMethod!.displayName);
//         await prefs.setString('carrier_code', selectedShippingMethod!.carrierCode);
//         await prefs.setString('method_code', selectedShippingMethod!.methodCode);
//       } else {
//         await prefs.remove('shipping_price');
//         await prefs.remove('shipping_method_name');
//         await prefs.remove('carrier_code');
//         await prefs.remove('method_code');
//       }
//     }
//
//     Future<void> _loadShippingPreferences() async {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() {
//         selectedCountryName = prefs.getString('selected_country_name') ?? '';
//         selectedCountryId = prefs.getString('selected_country_id') ?? '';
//         selectedRegionName = prefs.getString('selected_region_name') ?? '';
//         selectedRegionId = prefs.getString('selected_region_id') ?? '';
//       });
//     }
//
//     Widget _buildLoginPrompt(BuildContext context) {
//       return Scaffold(
//         appBar: AppBar(
//           title: const Text('Shopping Bag'),
//           leading: IconButton(
//             icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//         ),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.lock_outline, size: 60, color: Colors.grey),
//                 const SizedBox(height: 24),
//                 const Text("Login to View Your Bag",
//                     textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//                 Text("Sign in to see your items, get shipping estimates, and proceed to checkout.",
//                     textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
//                 const SizedBox(height: 32),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen1()))
//                         .then((_) => _initializeScreen());
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.black,
//                     foregroundColor: Colors.white,
//                     minimumSize: const Size(double.infinity, 50),
//                   ),
//                   child: const Text("SIGN IN / CREATE ACCOUNT", style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     @override
//
//     @override
//     Widget build(BuildContext context) {
//       if (isLoading) {
//         return Scaffold(
//           appBar: AppBar(title: const Text('Shopping Bag')),
//           body: const Center(child: CircularProgressIndicator()),
//         );
//       }
//
//       if (!isLoggedIn && !hasGuestCart) {
//         return _buildLoginPrompt(context);
//       }
//
//       return BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           if (state is CountriesLoaded) {
//             setState(() {
//               countries = state.countries;
//             });
//             if (selectedCountryId.isEmpty && (context.read<CartBloc>().state as CartLoaded).items.isNotEmpty && countries.isNotEmpty) {
//               final defaultCountry = countries.firstWhere((c) => c.id == 'GB', orElse: () => countries.first);
//               setState(() {
//                 selectedCountryName = defaultCountry.fullNameEnglish;
//                 selectedCountryId = defaultCountry.id;
//               });
//               _getShippingOptions();
//             }
//           } else if (state is ShippingMethodsLoaded) {
//             setState(() {
//               isShippingLoading = false;
//               availableShippingMethods = state.methods;
//               if (state.methods.isNotEmpty) {
//                 selectedShippingMethod = state.methods.first;
//                 currentShippingCost = selectedShippingMethod!.amount;
//               } else {
//                 selectedShippingMethod = null;
//                 currentShippingCost = 0.0;
//               }
//             });
//             _saveShippingPreferences();
//           } else if (state is ShippingError) {
//             setState(() {
//               isShippingLoading = false;
//               availableShippingMethods = [];
//               selectedShippingMethod = null;
//               currentShippingCost = 0.0;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Shopping Bag'),
//             leading: IconButton(
//               icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//               onPressed: () => Navigator.pushAndRemoveUntil(
//                   context, MaterialPageRoute(builder: (context) => const AuthScreen()), (r) => false),
//             ),
//           ),
//           body: BlocBuilder<CartBloc, CartState>(
//             builder: (context, state) {
//               if (state is CartLoading || state is CartInitial) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is CartError) {
//                 return Center(child: Text("Error: ${state.message}"));
//               }
//
//               if (state is CartLoaded) {
//                 WidgetsBinding.instance.addPostFrameCallback((_) {
//                   print("cartTotalWeight>>$_cartTotalWeight");
//                   if (mounted && _cartTotalWeight != state.totalCartWeight) {
//                     _cartTotalWeight = state.totalCartWeight;
//                     _getShippingOptions();
//                   }
//                 });
//
//                 if (state.items.isEmpty) {
//                   return const Center(
//                     child: Text("Your shopping bag is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)),
//                   );
//                 }
//
//                 // ✅ THIS IS THE CORRECTED LAYOUT
//                 return Column(
//                   children: [
//                     // 1. AN EXPANDED WIDGET THAT CONTAINS ALL SCROLLABLE CONTENT
//                     Expanded(
//                       child: SingleChildScrollView(
//                         controller: _scrollController,
//                         padding: const EdgeInsets.only(bottom: 16), // Give some space at the very end of the scroll
//                         child: Column(
//                           children: [
//                             // The list of cart items
//                             ListView.builder(
//                               // These two properties are crucial for nesting a ListView inside a SingleChildScrollView
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               itemCount: state.items.length,
//                               itemBuilder: (context, index) {
//                                 final item = state.items[index];
//                                 return CartItemWidget(
//                                   key: ValueKey(item['item_id']),
//                                   item: item,
//                                   onAdd: () => context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
//                                   onRemove: () {
//                                     if ((item['qty'] ?? 1) > 1) {
//                                       context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
//                                     }
//                                   },
//                                   onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
//                                 );
//                               },
//                             ),
//
//                             // The summary section, now INSIDE the scroll view
//                             Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//                                 child: Column(
//                                   children: [
//                                     _buildShippingContainer(),
//                                     const SizedBox(height: 20),
//                                     _buildOrderSummary(state),
//                                     const SizedBox(height: 20),
//                                     _buildCouponSection(),
//                                     const SizedBox(height: 20), // Extra space before the end of the grey box
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//
//                     // 2. THE FIXED BUTTON AT THE BOTTOM, OUTSIDE THE SCROLL VIEW
//                     Container(
//                       padding: const EdgeInsets.fromLTRB(16, 16, 16, 24), // Add padding for aesthetics
//                       width: double.infinity,
//                       decoration: BoxDecoration(
//                           color: Colors.white, // Or another color to lift it off the background
//                           boxShadow: [
//                             BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0,-5))
//                           ]
//                       ),
//                       child: _buildCheckoutButton(),
//                     ),
//                   ],
//                 );
//               }
//
//               return const Center(child: Text("Welcome! Your cart is loading."));
//             },
//           ),
//         ),
//       );
//     }
//     // Widget build(BuildContext context) {
//     //   if (isLoading) {
//     //     return Scaffold(
//     //       appBar: AppBar(title: const Text('Shopping Bag')),
//     //       body: const Center(child: CircularProgressIndicator()),
//     //     );
//     //   }
//     //
//     //   if (!isLoggedIn && !hasGuestCart) {
//     //     return _buildLoginPrompt(context);
//     //   }
//     //
//     //   return BlocListener<ShippingBloc, ShippingState>(
//     //     listener: (context, state) {
//     //       if (state is CountriesLoaded) {
//     //         setState(() {
//     //           countries = state.countries;
//     //         });
//     //         // Set a default country if none is selected, to get an initial estimate
//     //         if (selectedCountryId.isEmpty && (context.read<CartBloc>().state as CartLoaded).items.isNotEmpty && countries.isNotEmpty) {
//     //           final defaultCountry = countries.firstWhere((c) => c.id == 'GB', orElse: () => countries.first);
//     //           setState(() {
//     //             selectedCountryName = defaultCountry.fullNameEnglish;
//     //             selectedCountryId = defaultCountry.id;
//     //           });
//     //           _getShippingOptions();
//     //         }
//     //       } else if (state is ShippingMethodsLoaded) {
//     //         setState(() {
//     //           isShippingLoading = false;
//     //           availableShippingMethods = state.methods;
//     //           if (state.methods.isNotEmpty) {
//     //             selectedShippingMethod = state.methods.first;
//     //             currentShippingCost = selectedShippingMethod!.amount;
//     //           } else {
//     //             selectedShippingMethod = null;
//     //             currentShippingCost = 0.0;
//     //           }
//     //         });
//     //         _saveShippingPreferences();
//     //       } else if (state is ShippingError) {
//     //         setState(() {
//     //           isShippingLoading = false;
//     //           availableShippingMethods = [];
//     //           selectedShippingMethod = null;
//     //           currentShippingCost = 0.0;
//     //         });
//     //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Shipping Error: ${state.message}')));
//     //       }
//     //     },
//     //     child: Scaffold(
//     //       appBar: AppBar(
//     //         title: const Text('Shopping Bag'),
//     //         leading: IconButton(
//     //           icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//     //           onPressed: () => Navigator.pushAndRemoveUntil(
//     //               context, MaterialPageRoute(builder: (context) => const AuthScreen()), (r) => false),
//     //         ),
//     //       ),
//     //       body: Column(
//     //         children: [
//     //           Expanded(
//     //             child: BlocBuilder<CartBloc, CartState>(
//     //               builder: (context, state) {
//     //                 if (state is CartLoading || state is CartInitial) {
//     //                   return const Center(child: CircularProgressIndicator());
//     //                 }
//     //
//     //                 if (state is CartLoaded) {
//     //                   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //                     if (mounted && _cartTotalWeight != state.totalCartWeight) {
//     //                       _cartTotalWeight = state.totalCartWeight;
//     //                       _getShippingOptions();
//     //                     }
//     //                   });
//     //
//     //                   if (state.items.isEmpty) {
//     //                     return const Center(
//     //                       child: Text("Your shopping bag is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)),
//     //                     );
//     //                   }
//     //
//     //                   return ListView.builder(
//     //                     itemCount: state.items.length,
//     //                     itemBuilder: (context, index) {
//     //                       final item = state.items[index];
//     //                       return CartItemWidget(
//     //                         key: ValueKey(item['item_id']),
//     //                         item: item,
//     //                         onAdd: () =>
//     //                             context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
//     //                         onRemove: () {
//     //                           if ((item['qty'] ?? 1) > 1) {
//     //                             context
//     //                                 .read<CartBloc>()
//     //                                 .add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
//     //                           }
//     //                         },
//     //                         onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
//     //                       );
//     //                     },
//     //                   );
//     //                 }
//     //
//     //                 if (state is CartError) {
//     //                   return Center(child: Text("Error: ${state.message}"));
//     //                 }
//     //
//     //                 return const Center(child: Text("Welcome! Your cart is loading."));
//     //               },
//     //             ),
//     //           ),
//     //           BlocBuilder<CartBloc, CartState>(
//     //             builder: (context, cartState) {
//     //               if (cartState is CartLoaded && cartState.items.isNotEmpty) {
//     //                 return Flexible(
//     //                   fit: FlexFit.loose,
//     //                   child: Container(
//     //                     padding: const EdgeInsets.all(12),
//     //                     decoration: BoxDecoration(
//     //                         color: Colors.grey.shade100,
//     //                         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
//     //                     child: SingleChildScrollView(
//     //                       controller: _scrollController,
//     //                       child: Column(
//     //                         mainAxisSize: MainAxisSize.min,
//     //                         children: [
//     //                           _buildShippingContainer(),
//     //                           const SizedBox(height: 20),
//     //                           _buildOrderSummary(cartState),
//     //                           const SizedBox(height: 20),
//     //                           _buildCouponSection(),
//     //                           const SizedBox(height: 20),
//     //                           _buildCheckoutButton(),
//     //                         ],
//     //                       ),
//     //                     ),
//     //                   ),
//     //                 );
//     //               }
//     //               return const SizedBox.shrink();
//     //             },
//     //           ),
//     //         ],
//     //       ),
//     //     ),
//     //   );
//     // }
//
//     Widget _buildShippingMethodsList() {
//       // ✅ Get currency state here as well
//       final currencyState = context.watch<CurrencyBloc>().state;
//       String displaySymbol = '₹';
//       double exchangeRate = 1.0;
//       if (currencyState is CurrencyLoaded) {
//         displaySymbol = currencyState.selectedSymbol;
//         exchangeRate = currencyState.selectedRate.rate;
//       }
//
//       if (isShippingLoading) {
//         return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
//       }
//       if (availableShippingMethods.isEmpty) {
//         return const Padding(
//           padding: EdgeInsets.symmetric(vertical: 8.0),
//           child: Text("No shipping methods available for this address."),
//         );
//       }
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: availableShippingMethods.map((method) {
//           // ✅ Convert the shipping method amount for display
//           final convertedAmount = method.amount * exchangeRate;
//           return RadioListTile<ShippingMethod>(
//             title: Text(method.displayName),
//             // ✅ Display the converted amount and symbol
//             subtitle: Text('$displaySymbol${convertedAmount.toStringAsFixed(2)}'),
//             value: method,
//             groupValue: selectedShippingMethod,
//             activeColor: Colors.black,
//             onChanged: (ShippingMethod? value) {
//               setState(() {
//                 selectedShippingMethod = value;
//                 // IMPORTANT: `currentShippingCost` state variable must remain in the BASE currency (INR)
//                 currentShippingCost = value?.amount ?? 0.0;
//               });
//               _saveShippingPreferences();
//             },
//           );
//         }).toList(),
//       );
//     }
//
//     // Widget _buildShippingMethodsList() {
//     //   if (isShippingLoading) {
//     //     return const Padding(padding: EdgeInsets.all(16.0), child: Center(child: CircularProgressIndicator()));
//     //   }
//     //   if (availableShippingMethods.isEmpty) {
//     //     return const Padding(
//     //       padding: EdgeInsets.symmetric(vertical: 8.0),
//     //       child: Text("No shipping methods available for this address."),
//     //     );
//     //   }
//     //   return Column(
//     //     crossAxisAlignment: CrossAxisAlignment.start,
//     //     children: availableShippingMethods.map((method) {
//     //       return RadioListTile<ShippingMethod>(
//     //         title: Text(method.displayName),
//     //         subtitle: Text('₹${method.amount.toStringAsFixed(2)}'),
//     //         value: method,
//     //         groupValue: selectedShippingMethod,
//     //         activeColor: Colors.black,
//     //         onChanged: (ShippingMethod? value) {
//     //           setState(() {
//     //             selectedShippingMethod = value;
//     //             currentShippingCost = value?.amount ?? 0.0;
//     //           });
//     //           _saveShippingPreferences();
//     //         },
//     //       );
//     //     }).toList(),
//     //   );
//     // }
//
//     Widget _buildShippingContainer() {
//       final List<String> countryNames = [
//         for (final country in countries)
//           if (country.fullNameEnglish.isNotEmpty) country.fullNameEnglish,
//       ];
//
//       Country? selectedCountryData;
//       if (selectedCountryName.isNotEmpty && countries.isNotEmpty) {
//         try {
//           selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
//         } catch (_) {
//           selectedCountryData = null;
//         }
//       }
//
//       return Container(
//         width: double.infinity,
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(16),
//               width: double.infinity,
//               decoration: const BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
//               child: const Text('Estimate Shipping',
//                   style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 children: [
//                   buildDropdown(
//                     label: 'Select Country',
//                     value: selectedCountryName.isEmpty ? null : selectedCountryName,
//                     items: countryNames,
//                     onChanged: (value) {
//                       if (value == null) return;
//                       final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
//                       setState(() {
//                         selectedCountryName = country.fullNameEnglish;
//                         selectedCountryId = country.id;
//                         // Reset dependent fields
//                         selectedRegionName = '';
//                         selectedRegionId = '';
//                         selectedShippingMethod = null;
//                         availableShippingMethods = [];
//                         currentShippingCost = 0.0;
//                       });
//                       // ✅ ACTION: Fetch shipping options immediately after state is set.
//                       _getShippingOptions();
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
//                     buildDropdown(
//                       label: 'Select State / Province',
//                       value: selectedRegionName.isEmpty ? null : selectedRegionName,
//                       items: [
//                         for (final region in selectedCountryData.regions)
//                           if (region.name.isNotEmpty) region.name,
//                       ],
//                       onChanged: (value) {
//                         if (value == null) return;
//                         final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
//                         setState(() {
//                           selectedRegionName = region.name;
//                           selectedRegionId = region.id;
//                           // Reset shipping method when region changes
//                           selectedShippingMethod = null;
//                           availableShippingMethods = [];
//                           currentShippingCost = 0.0;
//                         });
//                         // ✅ ACTION: Fetch shipping options immediately after state is set.
//                         _getShippingOptions();
//                       },
//                     ),
//                   const SizedBox(height: 10),
//                   _buildShippingMethodsList(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//     //17/10/2025
//     // Widget _buildShippingContainer() {
//     //   final List<String> countryNames = [
//     //     for (final country in countries)
//     //       if (country.fullNameEnglish.isNotEmpty) country.fullNameEnglish,
//     //   ];
//     //
//     //   Country? selectedCountryData;
//     //   if (selectedCountryName.isNotEmpty && countries.isNotEmpty) {
//     //     try {
//     //       selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
//     //     } catch (_) {
//     //       selectedCountryData = null;
//     //     }
//     //   }
//     //
//     //   return Container(
//     //     width: double.infinity,
//     //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//     //     child: Column(
//     //       children: [
//     //         Container(
//     //           padding: const EdgeInsets.all(16),
//     //           width: double.infinity,
//     //           decoration: const BoxDecoration(
//     //               color: Colors.black,
//     //               borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
//     //           child: const Text('Estimate Shipping',
//     //               style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
//     //         ),
//     //         Padding(
//     //           padding: const EdgeInsets.all(16.0),
//     //           child: Column(
//     //             children: [
//     //               buildDropdown(
//     //                 label: 'Select Country',
//     //                 value: selectedCountryName.isEmpty ? null : selectedCountryName,
//     //                 items: countryNames,
//     //                 onChanged: (value) {
//     //                   if (value == null) return;
//     //                   final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
//     //                   setState(() {
//     //                     selectedCountryName = country.fullNameEnglish;
//     //                     selectedCountryId = country.id;
//     //                     selectedRegionName = '';
//     //                     selectedRegionId = '';
//     //                     selectedShippingMethod = null;
//     //                     availableShippingMethods = [];
//     //                     currentShippingCost = 0.0;
//     //                   });
//     //                   _getShippingOptions();
//     //                 },
//     //               ),
//     //               const SizedBox(height: 20),
//     //               if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
//     //                 buildDropdown(
//     //                   label: 'Select State / Province',
//     //                   value: selectedRegionName.isEmpty ? null : selectedRegionName,
//     //                   items: [
//     //                     for (final region in selectedCountryData.regions)
//     //                       if (region.name.isNotEmpty) region.name,
//     //                   ],
//     //                   onChanged: (value) {
//     //                     if (value == null) return;
//     //                     final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
//     //                     setState(() {
//     //                       selectedRegionName = region.name;
//     //                       selectedRegionId = region.id;
//     //                       selectedShippingMethod = null;
//     //                       availableShippingMethods = [];
//     //                       currentShippingCost = 0.0;
//     //                     });
//     //                     _getShippingOptions();
//     //                   },
//     //                 ),
//     //               const SizedBox(height: 10),
//     //               _buildShippingMethodsList(),
//     //             ],
//     //           ),
//     //         ),
//     //       ],
//     //     ),
//     //   );
//     // }
//
//
//     Widget _buildOrderSummary(CartLoaded cartState) {
//       // ✅ 1. Get the current currency state
//       final currencyState = context.watch<CurrencyBloc>().state;
//
//       // Default values for safety
//       String displaySymbol = '₹';
//       double exchangeRate = 1.0;
//
//       // If currency is loaded, get the real symbol and rate
//       if (currencyState is CurrencyLoaded) {
//         displaySymbol = currencyState.selectedSymbol;
//         exchangeRate = currencyState.selectedRate.rate;
//       }
//
//       // ✅ 2. Calculate totals using the exchange rate
//       // Subtotal is calculated from the base price in INR
//       double subtotalInBaseCurrency = cartState.items.fold(
//           0.0,
//               (sum, item) =>
//           sum + ((item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0)));
//
//       // Shipping cost is also in the base currency (INR)
//       double shippingCostInBaseCurrency = currentShippingCost;
//
//       // Convert all values to the selected currency for display
//       double subtotalConverted = subtotalInBaseCurrency * exchangeRate;
//       double shippingCostConverted = shippingCostInBaseCurrency * exchangeRate;
//       final totalConverted = subtotalConverted + shippingCostConverted;
//       return Container(
//         width: double.infinity,
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//         child: Column(
//           children: [
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//               // ✅ 3. Display the converted subtotal and symbol
//               Text('$displaySymbol${subtotalConverted.toStringAsFixed(2)}',
//                   style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//             ]),
//             const SizedBox(height: 12),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})',
//                   style: const TextStyle(fontSize: 16)),
//               // ✅ 3. Display the converted shipping cost and symbol
//               Text("$displaySymbol${shippingCostConverted.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//             ]),
//             const SizedBox(height: 20),
//             const Divider(thickness: 1),
//             const SizedBox(height: 12),
//             Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//               const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//               // ✅ 3. Display the converted total and symbol
//               Text('$displaySymbol${totalConverted.toStringAsFixed(2)}',
//                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             ]),
//           ],
//         ),
//       );
//     }
//
//     //3/9/2025
//     // Widget _buildOrderSummary(CartLoaded cartState) {
//     //
//     //   // double subtotal = cartState.items
//     //   //     .fold(0.0, (sum, item) => sum + ((item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0)));
//     //   // final total = subtotal + currentShippingCost;
//     //   // ✅ 1. Get the current currency state
//     //   final currencyState = context.watch<CurrencyBloc>().state;
//     //
//     //   // Default values for safety
//     //   String displaySymbol = '₹';
//     //   double exchangeRate = 1.0;
//     //
//     //   // If currency is loaded, get the real symbol and rate
//     //   if (currencyState is CurrencyLoaded) {
//     //     displaySymbol = currencyState.selectedSymbol;
//     //     exchangeRate = currencyState.selectedRate.rate;
//     //   }
//     //
//     //   // ✅ 2. Calculate totals using the exchange rate
//     //   // Subtotal is calculated from the base price in INR
//     //   double subtotalInBaseCurrency = cartState.items.fold(
//     //       0.0,
//     //           (sum, item) =>
//     //       sum + ((item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0)));
//     //
//     //   // Shipping cost is also in the base currency (INR)
//     //   double shippingCostInBaseCurrency = currentShippingCost;
//     //
//     //   // Convert all values to the selected currency for display
//     //   double subtotalConverted = subtotalInBaseCurrency * exchangeRate;
//     //   double shippingCostConverted = shippingCostInBaseCurrency * exchangeRate;
//     //   final totalConverted = subtotalConverted + shippingCostConverted;
//     //   return Container(
//     //     width: double.infinity,
//     //     padding: const EdgeInsets.all(16),
//     //     decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//     //     child: Column(
//     //       children: [
//     //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //           const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//     //           // ✅ 3. Display the converted subtotal and symbol
//     //           Text('$displaySymbol${subtotalConverted.toStringAsFixed(2)}',
//     //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//     //         ]),
//     //         const SizedBox(height: 12),
//     //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //           Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})',
//     //               style: const TextStyle(fontSize: 16)),
//     //           // ✅ 3. Display the converted shipping cost and symbol
//     //           Text("$displaySymbol${shippingCostConverted.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//     //         ]),
//     //         const SizedBox(height: 20),
//     //         const Divider(thickness: 1),
//     //         const SizedBox(height: 12),
//     //         Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //           const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     //           // ✅ 3. Display the converted total and symbol
//     //           Text('$displaySymbol${totalConverted.toStringAsFixed(2)}',
//     //               style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     //         ]),
//     //       ],
//     //     ),
//     //   );
//     //
//     //   // return Container(
//     //   //   width: double.infinity,
//     //   //   padding: const EdgeInsets.all(16),
//     //   //   decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//     //   //   child: Column(
//     //   //     children: [
//     //   //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //   //         const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//     //   //         Text('₹${subtotal.toStringAsFixed(2)}',
//     //   //             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//     //   //       ]),
//     //   //       const SizedBox(height: 12),
//     //   //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //   //         Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})',
//     //   //             style: const TextStyle(fontSize: 16)),
//     //   //         Text("₹${currentShippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//     //   //       ]),
//     //   //       const SizedBox(height: 20),
//     //   //       const Divider(thickness: 1),
//     //   //       const SizedBox(height: 12),
//     //   //       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//     //   //         const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     //   //         Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//     //   //       ]),
//     //   //     ],
//     //   //   ),
//     //   // );
//     // }
//
//     Widget _buildCouponSection() {
//       return Row(
//         children: [
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                   hintText: 'Enter coupon code',
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//                   filled: true,
//                   fillColor: Colors.white),
//             ),
//           ),
//           const SizedBox(width: 12),
//           ElevatedButton(
//               onPressed: () {},
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
//               child: const Text("Apply")),
//         ],
//       );
//     }
//
//     // NEW METHOD: Handle token login and navigation
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   _saveShippingPreferences();
//     //
//     //   if (_userToken != null && _userToken!.isNotEmpty) {
//     //     try {
//     //       // Step 1: Call Magento login API
//     //       final response = await http.post(
//     //         Uri.parse('https://stage.aashniandco.com/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (response.statusCode == 200) {
//     //         // Step 2: Decode API response as List
//     //         final data = jsonDecode(response.body) as List<dynamic>;
//     //
//     //         // Map the response
//     //         final cookieName = data[0] as String;   // "PHPSESSID"
//     //         final cookieValue = data[1] as String;  // "56fsdtcfd804igo3bevsaveck1"
//     //         final cookiePath = data[2] as String;   // "/"
//     //         final cookieDomain = data[3] as String; // "stage.aashniandco.com"
//     //         final isSecure = data[4] as bool;       // true
//     //         final isHttpOnly = data[5] as bool;     // true
//     //         final redirectUrl = "https://stage.aashniandco.com${data[6]}";
//     //
//     //         print("cookieName$cookieName");
//     //         print("cookieValue$cookieValue");
//     //
//     //         // Step 3: Set the Magento session cookie in WebView
//     //         final cookieManager = inapp.CookieManager();
//     //         await cookieManager.setCookie(
//     //           url: inapp.WebUri("https://stage.aashniandco.com"),
//     //           name: cookieName,
//     //           value: cookieValue,
//     //           domain: cookieDomain,
//     //           path: cookiePath,
//     //           isHttpOnly: isHttpOnly,
//     //           isSecure: isSecure,
//     //         );
//     //
//     //         // Step 4: Navigate to WebView
//     //         Navigator.push(
//     //           context,
//     //           MaterialPageRoute(
//     //             builder: (_) => WebViewScreen(initialUrl: redirectUrl),
//     //           ),
//     //         );
//     //       } else {
//     //         throw Exception('Failed to login via token. Status: ${response.statusCode}');
//     //       }
//     //     } catch (e) {
//     //       ScaffoldMessenger.of(context).showSnackBar(
//     //         SnackBar(content: Text('Login error: $e')),
//     //       );
//     //     }
//     //   } else {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text('User token not found. Please log in again.')),
//     //     );
//     //     Navigator.push(
//     //       context,
//     //       MaterialPageRoute(builder: (context) => const LoginScreen1()),
//     //     );
//     //   }
//     // }
//
//
// //11/9/2025
// //     Future<void> _performTokenLoginAndNavigateToCheckout() async {
// //       if (_userToken!.isEmpty) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text('User token not found. Please log in again.')),
// //         );
// //         Navigator.pushNamed(context, "/login");
// //         return;
// //       }
// //
// //       try {
// //         final response = await http.post(
// //           Uri.parse('https://stage.aashniandco.com/rest/V1/solr/loginByToken'),
// //           headers: {'Content-Type': 'application/json'},
// //           body: jsonEncode({'token': _userToken}),
// //         );
// //
// //         if (response.statusCode != 200) {
// //           throw Exception('Login via token failed: ${response.statusCode}');
// //         }
// //
// //         final data = jsonDecode(response.body) as List<dynamic>;
// //         final cookies = data[0] as List<dynamic>;
// //         final redirectPath = data[1] as String;
// //         final baseUrl = "https://stage.aashniandco.com";
// //         final redirectUrl = "$baseUrl/checkout/#shipping/"; // base URL, SPA will handle hash
// //
// //         // Set cookies before loading WebView
// //         final cookieManager = inapp.CookieManager.instance();
// //         await cookieManager.deleteAllCookies();
// //         for (var cookie in cookies) {
// //           final cookieMap = cookie as Map<String, dynamic>;
// //           await cookieManager.setCookie(
// //             url: WebUri(baseUrl),
// //             name: cookieMap['name'],
// //             value: cookieMap['value'],
// //             domain: cookieMap['domain'],
// //             path: cookieMap['path'],
// //             isSecure: cookieMap['secure'] ?? true,
// //             isHttpOnly: cookieMap['httponly'] ?? false,
// //             sameSite: HTTPCookieSameSitePolicy.LAX,
// //           );
// //           print("🍪 Cookie set: ${cookieMap['name']}=${cookieMap['value']}");
// //         }
// //
// //         // Wait a tiny bit to ensure cookies are committed
// //         await Future.delayed(const Duration(milliseconds: 200));
// //
// //         // Navigate to WebViewScreen
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => WebViewScreen(initialUrl: 'https://stage.aashniandco.com/checkout/#shipping'),
// //           ),
// //         );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Login error: $e')),
// //         );
// //       }
// //     }
//
// // 15/9/2025
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   if (_userToken!.isEmpty) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       const SnackBar(content: Text('User token not found. Please log in again.')),
//     //     );
//     //     Navigator.pushNamed(context, "/login");
//     //     return;
//     //   }
//     //
//     //   try {
//     //     // ✅ Get the current currency state
//     //     final currencyState = context.read<CurrencyBloc>().state;
//     //     final selectedCurrency = currencyState is CurrencyLoaded
//     //         ? currencyState.selectedCurrencyCode  // e.g., "USD", "EUR"
//     //         : 'INR';
//     //
//     //     final response = await http.post(
//     //       Uri.parse('https://stage.aashniandco.com/rest/V1/solr/loginByToken'),
//     //       headers: {'Content-Type': 'application/json'},
//     //       body: jsonEncode({'token': _userToken}),
//     //     );
//     //
//     //     if (response.statusCode != 200) {
//     //       throw Exception('Login via token failed: ${response.statusCode}');
//     //     }
//     //
//     //     final data = jsonDecode(response.body) as List<dynamic>;
//     //     final cookies = data[0] as List<dynamic>;
//     //     final baseUrl = "https://stage.aashniandco.com";
//     //
//     //     // Set cookies before loading WebView
//     //     final cookieManager = inapp.CookieManager.instance();
//     //     await cookieManager.deleteAllCookies();
//     //     for (var cookie in cookies) {
//     //       final cookieMap = cookie as Map<String, dynamic>;
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookieMap['name'],
//     //         value: cookieMap['value'],
//     //         domain: cookieMap['domain'],
//     //         path: cookieMap['path'],
//     //         isSecure: cookieMap['secure'] ?? true,
//     //         isHttpOnly: cookieMap['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //       print("🍪 Cookie set: ${cookieMap['name']}=${cookieMap['value']}");
//     //     }
//     //
//     //     // ✅ Set currency cookie
//     //     await cookieManager.setCookie(
//     //       url: WebUri(baseUrl),
//     //       name: 'currency',
//     //       value: selectedCurrency,
//     //       domain: 'stage.aashniandco.com',
//     //       path: '/',
//     //       isSecure: true,
//     //       isHttpOnly: false,
//     //       sameSite: HTTPCookieSameSitePolicy.LAX,
//     //     );
//     //
//     //     await Future.delayed(const Duration(milliseconds: 200));
//     //
//     //     // Navigate to WebViewScreen with optional currency param
//     //     // final redirectUrl = 'https://stage.aashniandco.com/checkout/#shipping?currency=$selectedCurrency';
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(initialUrl: 'https://stage.aashniandco.com/checkout/#shipping'),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Login error: $e')),
//     //     );
//     //   }
//     // }
//
// //16/9/2025
// //     Future<void> _performTokenLoginAndNavigateToCheckout() async {
// //       if (_userToken == null || _userToken!.isEmpty) {
// //         // Guest checkout flow
// //         print("Guest checkout - navigating to WebView directly");
// //
// //         // Navigate to WebViewScreen without login
// //         final currencyState = context.read<CurrencyBloc>().state;
// //         final selectedCurrency = currencyState is CurrencyLoaded
// //             ? currencyState.selectedCurrencyCode
// //             : 'INR';
// //
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => WebViewScreen(
// //               initialUrl: 'https://stage.aashniandco.com/checkout/#shipping?currency=$selectedCurrency',
// //             ),
// //           ),
// //         );
// //         return;
// //       }
// //
// //       try {
// //         // ✅ Authenticated user flow
// //         final currencyState = context.read<CurrencyBloc>().state;
// //         final selectedCurrency = currencyState is CurrencyLoaded
// //             ? currencyState.selectedCurrencyCode
// //             : 'INR';
// //
// //         final response = await http.post(
// //           Uri.parse('https://stage.aashniandco.com/rest/V1/solr/loginByToken'),
// //           headers: {'Content-Type': 'application/json'},
// //           body: jsonEncode({'token': _userToken}),
// //         );
// //
// //         if (response.statusCode != 200) {
// //           throw Exception('Login via token failed: ${response.statusCode}');
// //         }
// //
// //         final data = jsonDecode(response.body) as List<dynamic>;
// //         final cookies = data[0] as List<dynamic>;
// //         final baseUrl = "https://stage.aashniandco.com";
// //
// //         final cookieManager = inapp.CookieManager.instance();
// //         await cookieManager.deleteAllCookies();
// //         for (var cookie in cookies) {
// //           final cookieMap = cookie as Map<String, dynamic>;
// //           await cookieManager.setCookie(
// //             url: WebUri(baseUrl),
// //             name: cookieMap['name'],
// //             value: cookieMap['value'],
// //             domain: cookieMap['domain'],
// //             path: cookieMap['path'],
// //             isSecure: cookieMap['secure'] ?? true,
// //             isHttpOnly: cookieMap['httponly'] ?? false,
// //             sameSite: HTTPCookieSameSitePolicy.LAX,
// //           );
// //         }
// //
// //         // Set currency cookie
// //         await cookieManager.setCookie(
// //           url: WebUri(baseUrl),
// //           name: 'currency',
// //           value: selectedCurrency,
// //           domain: 'stage.aashniandco.com',
// //           path: '/',
// //           isSecure: true,
// //           isHttpOnly: false,
// //           sameSite: HTTPCookieSameSitePolicy.LAX,
// //         );
// //
// //         await Future.delayed(const Duration(milliseconds: 200));
// //
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => WebViewScreen(initialUrl: 'https://stage.aashniandco.com/checkout/#shipping'),
// //           ),
// //         );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Login error: $e')),
// //         );
// //       }
// //     }
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //   _userEmail = prefs.getString('user_email');
//     //   _userPassword = prefs.getString('user_password');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //
//     //   // Clear previous cookies before checkout
//     //   await cookieManager.deleteAllCookies();
//     //
//     //   try {
//     //     final baseUrl = "https://stage.aashniandco.com";
//     //
//     //     // ---------------- Guest checkout ----------------
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //
//     //       if (guestQuoteId.isEmpty) {
//     //         throw Exception('No guest cart found');
//     //       }
//     //
//     //       // Call initGuestCheckout API to get cookies
//     //       final response = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/initGuestCheckout'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'guestQuoteId': guestQuoteId}),
//     //       );
//     //
//     //       if (response.statusCode != 200) {
//     //         throw Exception('Guest checkout init failed: ${response.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(response.body) as List<dynamic>;
//     //
//     //       // First element: cookies
//     //       final cookies = (data[0] as List<dynamic>)
//     //           .map((e) => e as Map<String, dynamic>)
//     //           .toList();
//     //
//     //       // ---------------- Set all cookies ----------------
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Set currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // ✅ Wait a short time to ensure cookies are applied (important for iOS)
//     //       await Future.delayed(const Duration(milliseconds: 500)); // iOS sometimes needs more time
//     //
//     //
//     //       // ---------------- Navigate to checkout ----------------
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: '$baseUrl/checkout/#shipping',
//     //           ),
//     //         ),
//     //       );
//     //       return;
//     //     }
//     //
//     //     // ---------------- Authenticated user ----------------
//     //     print("Authenticated user - token login");
//     //
//     //     final loginResponse = await http.post(
//     //       Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //       headers: {'Content-Type': 'application/json'},
//     //       body: jsonEncode({'token': _userToken}),
//     //     );
//     //
//     //     if (loginResponse.statusCode != 200) {
//     //       throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //     }
//     //
//     //     final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //     final cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //
//     //     // Set cookies for authenticated user
//     //     for (var cookie in cookies) {
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookie['name'],
//     //         value: cookie['value'],
//     //         domain: cookie['domain'],
//     //         path: cookie['path'],
//     //         isSecure: cookie['secure'] ?? true,
//     //         isHttpOnly: cookie['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //     }
//     //
//     //     // Set currency cookie
//     //     await cookieManager.setCookie(
//     //       url: WebUri(baseUrl),
//     //       name: 'currency',
//     //       value: selectedCurrency,
//     //       domain: 'stage.aashniandco.com',
//     //       path: '/',
//     //       isSecure: true,
//     //       isHttpOnly: false,
//     //       sameSite: HTTPCookieSameSitePolicy.LAX,
//     //     );
//     //
//     //     // Wait briefly for iOS
//     //     await Future.delayed(const Duration(milliseconds: 200));
//     //
//     //     // Navigate to checkout
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(
//     //           initialUrl: '$baseUrl/checkout/#shipping',
//     //         ),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//     //
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //   _userEmail = prefs.getString('user_email');
//     //   _userPassword = prefs.getString('user_password');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //
//     //   // Clear previous cookies before checkout
//     //   await cookieManager.deleteAllCookies();
//     //
//     //   try {
//     //     final baseUrl = "https://stage.aashniandco.com";
//     //
//     //     // ---------------- Guest checkout ----------------
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //
//     //       if (guestQuoteId.isEmpty) {
//     //         throw Exception('No guest cart found');
//     //       }
//     //
//     //       // Call initGuestCheckout API to get cookies
//     //       final response = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/initGuestCheckout'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'guestQuoteId': guestQuoteId}),
//     //       );
//     //
//     //       if (response.statusCode != 200) {
//     //         throw Exception('Guest checkout init failed: ${response.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(response.body) as List<dynamic>;
//     //       final cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //
//     //       // Set all cookies
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Set currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // Wait a short time to ensure cookies are applied (important for iOS)
//     //       await Future.delayed(const Duration(milliseconds: 700));
//     //
//     //       // ✅ Print guest cookies for debugging
//     //       final guestCookies = await cookieManager.getCookies(url: WebUri(baseUrl));
//     //       print("Guest Cookies: $guestCookies");
//     //
//     //       // Navigate to checkout
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //             builder: (_) => WebViewScreen(initialUrl: 'https://stage.aashniandco.com/checkout/#shipping'),
//     //         ),
//     //       );
//     //       return;
//     //     }
//     //
//     //     // ---------------- Authenticated user ----------------
//     //     print("Authenticated user - token login");
//     //
//     //     final loginResponse = await http.post(
//     //       Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //       headers: {'Content-Type': 'application/json'},
//     //       body: jsonEncode({'token': _userToken}),
//     //     );
//     //
//     //     if (loginResponse.statusCode != 200) {
//     //       throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //     }
//     //
//     //     final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //     final cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //
//     //     // Set cookies for authenticated user
//     //     for (var cookie in cookies) {
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookie['name'],
//     //         value: cookie['value'],
//     //         domain: cookie['domain'],
//     //         path: cookie['path'],
//     //         isSecure: cookie['secure'] ?? true,
//     //         isHttpOnly: cookie['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //     }
//     //
//     //     // Set currency cookie
//     //     await cookieManager.setCookie(
//     //       url: WebUri(baseUrl),
//     //       name: 'currency',
//     //       value: selectedCurrency,
//     //       domain: 'stage.aashniandco.com',
//     //       path: '/',
//     //       isSecure: true,
//     //       isHttpOnly: false,
//     //       sameSite: HTTPCookieSameSitePolicy.LAX,
//     //     );
//     //
//     //     // Wait briefly for iOS
//     //     await Future.delayed(const Duration(milliseconds: 500));
//     //
//     //     // ✅ Print logged-in cookies for debugging
//     //     final authCookies = await cookieManager.getCookies(url: WebUri(baseUrl));
//     //     print("Authenticated User Cookies: $authCookies");
//     //
//     //     // Navigate to checkout
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(initialUrl: '$baseUrl/checkout/#shipping'),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //
//     //   // Clear previous cookies before checkout
//     //   await cookieManager.deleteAllCookies();
//     //
//     //   try {
//     //     const baseUrl = "https://stage.aashniandco.com";
//     //
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //
//     //       if (guestQuoteId.isEmpty) {
//     //         throw Exception('No guest cart found');
//     //       }
//     //
//     //       // Call initGuestCheckout API
//     //       final response = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/initGuestCheckout'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'guestQuoteId': guestQuoteId}),
//     //       );
//     //
//     //       if (response.statusCode != 200) {
//     //         throw Exception('Guest checkout init failed: ${response.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(response.body) as List<dynamic>;
//     //
//     //       // Extract cookies and checkout path
//     //       final cookies = (data[0] as List<dynamic>)
//     //           .map((e) => e as Map<String, dynamic>)
//     //           .toList();
//     //       final checkoutPath = data.length > 1 ? data[1] as String : "/checkout/#shipping";
//     //
//     //       print("Guest Cookies: $cookies");
//     //       print("Checkout Path: $checkoutPath");
//     //
//     //       // Set cookies
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Set currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // Short delay for iOS to ensure cookies are applied
//     //       await Future.delayed(const Duration(milliseconds: 500));
//     //
//     //       // Navigate to checkout
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //           ),
//     //         ),
//     //       );
//     //       return;
//     //     }
//     //
//     //     // ---------------- Authenticated User ----------------
//     //     print("Authenticated user - token login");
//     //
//     //     final loginResponse = await http.post(
//     //       Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //       headers: {'Content-Type': 'application/json'},
//     //       body: jsonEncode({'token': _userToken}),
//     //     );
//     //
//     //     if (loginResponse.statusCode != 200) {
//     //       throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //     }
//     //
//     //     final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //     final cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //     final checkoutPath = data.length > 1 ? data[1] as String : "/checkout/#shipping";
//     //
//     //     print("User Cookies: $cookies");
//     //     print("Checkout Path: $checkoutPath");
//     //
//     //     // Set cookies for authenticated user
//     //     for (var cookie in cookies) {
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookie['name'],
//     //         value: cookie['value'],
//     //         domain: cookie['domain'],
//     //         path: cookie['path'],
//     //         isSecure: cookie['secure'] ?? true,
//     //         isHttpOnly: cookie['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //     }
//     //
//     //     // Set currency cookie
//     //     await cookieManager.setCookie(
//     //       url: WebUri(baseUrl),
//     //       name: 'currency',
//     //       value: selectedCurrency,
//     //       domain: 'stage.aashniandco.com',
//     //       path: '/',
//     //       isSecure: true,
//     //       isHttpOnly: false,
//     //       sameSite: HTTPCookieSameSitePolicy.LAX,
//     //     );
//     //
//     //     // Delay briefly for iOS
//     //     await Future.delayed(const Duration(milliseconds: 500));
//     //
//     //     // Navigate to checkout
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(
//     //           initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //         ),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //   await cookieManager.deleteAllCookies();
//     //
//     //   const baseUrl = "https://stage.aashniandco.com";
//     //
//     //   try {
//     //     List<Map<String, dynamic>> cookies = [];
//     //     String checkoutPath = "/checkout/#shipping";
//     //
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //
//     //       if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//     //
//     //       final response = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/initGuestCheckout'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'guestQuoteId': guestQuoteId}),
//     //       );
//     //
//     //       if (response.statusCode != 200) {
//     //         throw Exception('Guest checkout init failed: ${response.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(response.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //       checkoutPath = data.length > 1 ? data[1] as String : checkoutPath;
//     //
//     //       // Add currency cookie
//     //       cookies.add({
//     //         'name': 'currency',
//     //         'value': selectedCurrency,
//     //         'domain': 'stage.aashniandco.com',
//     //         'path': '/',
//     //         'secure': true,
//     //         'httponly': false,
//     //       });
//     //
//     //       // Navigate to WebView for guest
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,
//     //           ),
//     //         ),
//     //       );
//     //     } else {
//     //       // ---------------- Authenticated User ----------------
//     //       print("Authenticated user - token login");
//     //
//     //       final loginResponse = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (loginResponse.statusCode != 200) {
//     //         throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //       checkoutPath = data.length > 1 ? data[1] as String : checkoutPath;
//     //
//     //       // Add currency cookie
//     //       cookies.add({
//     //         'name': 'currency',
//     //         'value': selectedCurrency,
//     //         'domain': 'stage.aashniandco.com',
//     //         'path': '/',
//     //         'secure': true,
//     //         'httponly': false,
//     //       });
//     //
//     //       // Navigate to WebView for logged-in user
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,
//     //           ),
//     //         ),
//     //       );
//     //     }
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
//      //18/9/2025
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //   await cookieManager.deleteAllCookies();
//     //
//     //   const baseUrl = "https://stage.aashniandco.com";
//     //
//     //   try {
//     //     List<Map<String, dynamic>> cookies = [];
//     //     String checkoutPath = "/checkout/#shipping";
//     //
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //
//     //       if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//     //
//     //       final response = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/initGuestCheckout'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'guestQuoteId': guestQuoteId}),
//     //       );
//     //
//     //       if (response.statusCode != 200) {
//     //         throw Exception('Guest checkout init failed: ${response.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(response.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //       checkoutPath = data.length > 1 ? data[1] as String : checkoutPath;
//     //
//     //       // Apply cookies via CookieManager
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Add currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // Short delay for iOS to ensure cookies are applied
//     //       await Future.delayed(const Duration(milliseconds: 500));
//     //
//     //       // Navigate to WebView for guest
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,// use dynamic path from API
//     //           ),
//     //         ),
//     //       );
//     //     } else {
//     //       // ---------------- Authenticated User ----------------
//     //       print("Authenticated user - token login");
//     //
//     //       final loginResponse = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (loginResponse.statusCode != 200) {
//     //         throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //       checkoutPath = data.length > 1 ? data[1] as String : checkoutPath;
//     //
//     //       // Apply cookies via CookieManager
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Add currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // Short delay for iOS
//     //       await Future.delayed(const Duration(milliseconds: 500));
//     //
//     //       // Navigate to WebView for logged-in user
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,
//     //           ),
//     //         ),
//     //       );
//     //     }
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
// ///19/09/2025
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   const baseUrl = "https://stage.aashniandco.com";
//     //   final cookieManager = inapp.CookieManager.instance();
//     //
//     //   try {
//     //     // Clear all old cookies
//     //     await cookieManager.deleteAllCookies();
//     //
//     //     List<Map<String, dynamic>> cookies = [];
//     //     String checkoutPath = "/checkout/#shipping";
//     //
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("🟢 Guest checkout - guestQuoteId: $guestQuoteId");
//     //       if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//     //
//     //       // 🔹 Read saved frontend cookies
//     //       final savedCookies = prefs.getString('guest_cart_cookies');
//     //       if (savedCookies != null) {
//     //         cookies = (jsonDecode(savedCookies) as List<dynamic>)
//     //             .map((e) => e as Map<String, dynamic>)
//     //             .toList();
//     //
//     //         // ✅ Print all saved cookies for debugging
//     //         print("🟢 Saved Guest Cookies from SharedPreferences:");
//     //         for (var cookie in cookies) {
//     //           print(
//     //               "Name: ${cookie['name']}, Value: ${cookie['value']}, Domain: ${cookie['domain']}, Path: ${cookie['path']}, Secure: ${cookie['secure']}, HttpOnly: ${cookie['httponly']}"
//     //           );
//     //         }
//     //       } else {
//     //         print("⚠️ No saved guest cookies found in SharedPreferences.");
//     //       }
//     //
//     //       // 🔹 Apply cookies via CookieManager
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Add currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // ✅ Print all cookies after setting
//     //       final allCookies = await cookieManager.getCookies(url: WebUri(baseUrl));
//     //       print("🟢 Guest Checkout Cookies applied to WebView:");
//     //       for (var cookie in allCookies) {
//     //         print(
//     //             "Name: ${cookie.name}, Value: ${cookie.value}, Domain: ${cookie.domain}, Path: ${cookie.path}, Secure: ${cookie.isSecure}, HttpOnly: ${cookie.isHttpOnly}"
//     //         );
//     //       }
//     //
//     //       // Navigate to WebView
//     //       await Future.delayed(const Duration(milliseconds: 500));
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,
//     //           ),
//     //         ),
//     //       );
//     //     } else {
//     //       // ---------------- Authenticated User ----------------
//     //       print("🟢 Authenticated user - token login");
//     //
//     //       final loginResponse = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (loginResponse.statusCode != 200) {
//     //         throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //       checkoutPath = data.length > 1 ? data[1] as String : checkoutPath;
//     //
//     //       // Set cookies in WebView
//     //       for (var cookie in cookies) {
//     //         await cookieManager.setCookie(
//     //           url: WebUri(baseUrl),
//     //           name: cookie['name'],
//     //           value: cookie['value'],
//     //           domain: cookie['domain'],
//     //           path: cookie['path'],
//     //           isSecure: cookie['secure'] ?? true,
//     //           isHttpOnly: cookie['httponly'] ?? false,
//     //           sameSite: HTTPCookieSameSitePolicy.LAX,
//     //         );
//     //       }
//     //
//     //       // Add currency cookie
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: 'currency',
//     //         value: selectedCurrency,
//     //         domain: 'stage.aashniandco.com',
//     //         path: '/',
//     //         isSecure: true,
//     //         isHttpOnly: false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //
//     //       // ✅ Print cookies for authenticated user
//     //       final allCookies = await cookieManager.getCookies(url: WebUri(baseUrl));
//     //       print("🟢 Authenticated User Cookies applied to WebView:");
//     //       for (var cookie in allCookies) {
//     //         print(
//     //             "Name: ${cookie.name}, Value: ${cookie.value}, Domain: ${cookie.domain}, Path: ${cookie.path}, Secure: ${cookie.isSecure}, HttpOnly: ${cookie.isHttpOnly}"
//     //         );
//     //       }
//     //
//     //       await Future.delayed(const Duration(milliseconds: 500));
//     //       Navigator.pushReplacement(
//     //         context,
//     //         MaterialPageRoute(
//     //           builder: (_) => WebViewScreen(
//     //             initialUrl: 'https://stage.aashniandco.com/checkout/#shipping',
//     //             cookies: cookies,
//     //           ),
//     //         ),
//     //       );
//     //     }
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   // 1️⃣ Get currency from CurrencyBloc
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   String displaySymbol = '₹'; // default
//     //   double exchangeRate = 1.0;
//     //
//     //   if (currencyState is CurrencyLoaded) {
//     //     displaySymbol = currencyState.selectedSymbol;
//     //     exchangeRate = currencyState.selectedRate.rate;
//     //   }
//     //
//     //   // 2️⃣ Calculate subtotal in base currency
//     //   final cartState = context.read<CartBloc>().state;
//     //   double subtotalInBaseCurrency = 0.0;
//     //   if (cartState is CartLoaded) {
//     //     subtotalInBaseCurrency = cartState.items.fold(
//     //       0.0,
//     //           (sum, item) =>
//     //       sum + ((item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0)),
//     //     );
//     //   }
//     //
//     //   // 3️⃣ Apply exchange rate
//     //   double subtotalStitched = subtotalInBaseCurrency * exchangeRate;
//     //   double shippingStitched = currentShippingCost * exchangeRate;
//     //
//     //   // 4️⃣ Build checkout URL (optional query parameters)
//     //   final checkoutUrl = Uri.parse("https://stage.aashniandco.com/checkout").replace(
//     //     queryParameters: {
//     //       'subtotal': subtotalStitched.toStringAsFixed(2),
//     //       'shipping': shippingStitched.toStringAsFixed(2),
//     //       'currency': displaySymbol, // optional, for debugging
//     //     },
//     //   );
//     //
//     //   // 5️⃣ Navigate to WebViewScreen and pass currency code
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(
//     //       builder: (_) => WebViewScreen(
//     //         initialUrl: checkoutUrl.toString(),
//     //         currencyCode: displaySymbol, // Pass current currency here
//     //       ),
//     //     ),
//     //   );
//     // }
//
// //19
//     Future<void> _performTokenLoginAndNavigateToCheckout() async {
//       final prefs = await SharedPreferences.getInstance();
//       final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//       _userToken = prefs.getString('user_token');
//
//       final currencyState = context.read<CurrencyBloc>().state;
//       final selectedCurrency = currencyState is CurrencyLoaded
//           ? currencyState.selectedCurrencyCode
//           : 'INR';
//
//       final cookieManager = inapp.CookieManager.instance();
//       await cookieManager.deleteAllCookies(); // Clear previous cookies
//
//       const baseUrl = "https://aashniandco.com";
//       List<Map<String, dynamic>> cookies = [];
//
//       try {
//         if (_userToken == null || _userToken!.isEmpty) {
//           // ---------------- Guest Checkout ----------------
//           print("Guest checkout - guestQuoteId: $guestQuoteId");
//           if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//
//           // Get guest cookies from SharedPreferences
//           final storedCookiesStr = prefs.getString("guest_cart_cookies");
//           print("guestcookie>>$storedCookiesStr");
//           if (storedCookiesStr == null || storedCookiesStr.isEmpty) {
//             throw Exception('No guest cookies found in SharedPreferences');
//           }
//
//           cookies = (jsonDecode(storedCookiesStr) as List)
//               .map((e) => e as Map<String, dynamic>)
//               .toList();
//           print("✅ Using stored guest cookies from SharedPreferences");
//
//         } else {
//           // ---------------- Authenticated User ----------------
//           print("Authenticated user - token login");
//
//           // Fetch cookies from API
//           final loginResponse = await http.post(
//             Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//             headers: {'Content-Type': 'application/json'},
//             body: jsonEncode({'token': _userToken}),
//           );
//
//           if (loginResponse.statusCode != 200) {
//             throw Exception('Login via token failed: ${loginResponse.statusCode}');
//           }
//
//           final data = jsonDecode(loginResponse.body) as List<dynamic>;
//           cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//
//           // Save cookies for future use
//           await prefs.setString("user_cart_cookies", json.encode(cookies));
//           print("✅ Fetched and saved logged-in user cookies from API");
//         }
//
//         // ---------------- Apply cookies to WebView ----------------
//         for (var cookie in cookies) {
//           await cookieManager.setCookie(
//             url: WebUri(baseUrl),
//             name: cookie['name'],
//             value: cookie['value'],
//             domain: 'stage.aashniandco.com', // force exact domain
//             path: cookie['path'] ?? '/',
//             isSecure: cookie['secure'] ?? true,
//             isHttpOnly: cookie['httponly'] ?? false,
//             sameSite: HTTPCookieSameSitePolicy.LAX,
//           );
//         }
//
//         // Add currency cookie
//         await cookieManager.setCookie(
//           url: WebUri(baseUrl),
//           name: 'currency',
//           value: selectedCurrency,
//           domain: 'stage.aashniandco.com',
//           path: '/',
//           isSecure: true,
//           isHttpOnly: false,
//           sameSite: HTTPCookieSameSitePolicy.LAX,
//         );
//
//         // Short delay to ensure cookies are applied (especially for iOS)
//         await Future.delayed(const Duration(milliseconds: 300));
//
//         // Navigate to WebView
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => WebViewScreen(
//               initialUrl: '$baseUrl/checkout/#shipping',
//               cookies: cookies,
//             ),
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Checkout error: $e')),
//         );
//       }
//     }
// // 30/9/2025
// //     Future<void> _performTokenLoginAndNavigateToCheckout() async {
// //       final prefs = await SharedPreferences.getInstance();
// //       final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
// //       _userToken = prefs.getString('user_token');
// //
// //       final currencyState = context.read<CurrencyBloc>().state;
// //       final selectedCurrency = currencyState is CurrencyLoaded
// //           ? currencyState.selectedCurrencyCode
// //           : 'INR';
// //
// //       final cookieManager = inapp.CookieManager.instance();
// //       await cookieManager.deleteAllCookies(); // Clear previous cookies
// //
// //       const baseUrl = "https://stage.aashniandco.com";
// //       List<Map<String, dynamic>> cookies = [];
// //
// //       try {
// //         if (_userToken == null || _userToken!.isEmpty) {
// //           // ---------------- Guest Checkout ----------------
// //           print("Guest checkout - guestQuoteId: $guestQuoteId");
// //           if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
// //
// //           // Get guest cookies from SharedPreferences
// //           final storedCookiesStr = prefs.getString("guest_cart_cookies");
// //           if (storedCookiesStr == null || storedCookiesStr.isEmpty) {
// //             throw Exception('No guest cookies found in SharedPreferences');
// //           }
// //
// //           cookies = (jsonDecode(storedCookiesStr) as List)
// //               .map((e) => e as Map<String, dynamic>)
// //               .toList();
// //           print("✅ Using stored guest cookies from SharedPreferences");
// //         } else {
// //           // ---------------- Authenticated User ----------------
// //           print("Authenticated user - token login");
// //
// //           // Fetch cookies from API
// //           final loginResponse = await http.post(
// //             Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
// //             headers: {'Content-Type': 'application/json'},
// //             body: jsonEncode({'token': _userToken}),
// //           );
// //
// //           if (loginResponse.statusCode != 200) {
// //             throw Exception('Login via token failed: ${loginResponse.statusCode}');
// //           }
// //
// //           final data = jsonDecode(loginResponse.body) as List<dynamic>;
// //           cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
// //
// //           await prefs.setString("user_cart_cookies", json.encode(cookies));
// //           print("✅ Fetched and saved logged-in user cookies from API");
// //         }
// //
// //         // ---------------- Navigate to WebViewScreen ----------------
// //         Navigator.pushReplacement(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => WebViewScreen(
// //               initialUrl: '$baseUrl/checkout/#shipping',
// //               cookies: cookies,
// //               selectedCurrency: selectedCurrency,
// //             ),
// //           ),
// //         );
// //       } catch (e) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(content: Text('Checkout error: $e')),
// //         );
// //       }
// //     }
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //   await cookieManager.deleteAllCookies(); // Clear previous cookies
//     //
//     //   const baseUrl = "https://stage.aashniandco.com";
//     //   List<Map<String, dynamic>> cookies = [];
//     //
//     //   try {
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //       if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//     //
//     //       // Get guest cookies from SharedPreferences
//     //       final storedCookiesStr = prefs.getString("guest_cart_cookies");
//     //       if (storedCookiesStr == null || storedCookiesStr.isEmpty) {
//     //         throw Exception('No guest cookies found in SharedPreferences');
//     //       }
//     //       cookies = (jsonDecode(storedCookiesStr) as List)
//     //           .map((e) => e as Map<String, dynamic>)
//     //           .toList();
//     //       print("✅ Using stored guest cookies from SharedPreferences");
//     //
//     //       // Add mandatory Magento guest session cookies
//     //       cookies.addAll([
//     //         {
//     //           "name": "mage-cache-sessid",
//     //           "value": guestQuoteId,
//     //           "domain": "stage.aashniandco.com",
//     //           "path": "/",
//     //           "secure": true,
//     //           "httponly": false,
//     //         },
//     //         {
//     //           "name": "currency",
//     //           "value": selectedCurrency,
//     //           "domain": "stage.aashniandco.com",
//     //           "path": "/",
//     //           "secure": true,
//     //           "httponly": false,
//     //         },
//     //       ]);
//     //
//     //       // Bind guest cart to session to prevent /cart redirection
//     //       await http.put(
//     //         Uri.parse('$baseUrl/rest/V1/guest-carts/$guestQuoteId'),
//     //         headers: {'Content-Type': 'application/json'},
//     //       );
//     //     } else {
//     //       // ---------------- Authenticated User ----------------
//     //       print("Authenticated user - token login");
//     //
//     //       final loginResponse = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (loginResponse.statusCode != 200) {
//     //         throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //       cookies = (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //
//     //       // Save cookies for future use
//     //       await prefs.setString("user_cart_cookies", json.encode(cookies));
//     //       print("✅ Fetched and saved logged-in user cookies from API");
//     //     }
//     //
//     //     // ---------------- Apply cookies to WebView ----------------
//     //     for (var cookie in cookies) {
//     //       final value = cookie['value']?.toString() ?? '';
//     //       if (value.isEmpty) {
//     //         print("⚠️ Skipping empty cookie: ${cookie['name']}");
//     //         continue; // iOS requires non-empty cookie values
//     //       }
//     //
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookie['name'],
//     //         value: value,
//     //         domain: cookie['domain'] ?? 'stage.aashniandco.com',
//     //         path: cookie['path'] ?? '/',
//     //         isSecure: cookie['secure'] ?? true,
//     //         isHttpOnly: cookie['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //     }
//     //
//     //     // Short delay for iOS to ensure cookies applied
//     //     await Future.delayed(const Duration(seconds: 1));
//     //
//     //     // Navigate to WebView
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(
//     //           initialUrl: '$baseUrl/checkout/#shipping',
//     //           cookies: cookies,
//     //         ),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //     print("❌ Checkout error: $e");
//     //   }
//     // }
//
//
//
//
//
//     // Future<void> _performTokenLoginAndNavigateToCheckout() async {
//     //   final prefs = await SharedPreferences.getInstance();
//     //   final guestQuoteId = prefs.getString('guest_quote_id') ?? '';
//     //   _userToken = prefs.getString('user_token');
//     //
//     //   final currencyState = context.read<CurrencyBloc>().state;
//     //   final selectedCurrency = currencyState is CurrencyLoaded
//     //       ? currencyState.selectedCurrencyCode
//     //       : 'INR';
//     //
//     //   final cookieManager = inapp.CookieManager.instance();
//     //   await cookieManager.deleteAllCookies(); // Clear previous cookies
//     //
//     //   const baseUrl = "https://stage.aashniandco.com";
//     //   List<Map<String, dynamic>> cookies = [];
//     //
//     //   try {
//     //     if (_userToken == null || _userToken!.isEmpty) {
//     //       // ---------------- Guest Checkout ----------------
//     //       print("Guest checkout - guestQuoteId: $guestQuoteId");
//     //       if (guestQuoteId.isEmpty) throw Exception('No guest cart found');
//     //
//     //       // Get guest cookies from SharedPreferences
//     //       final storedCookiesStr = prefs.getString("guest_cart_cookies");
//     //       print("guestcookie>>$storedCookiesStr");
//     //       if (storedCookiesStr == null || storedCookiesStr.isEmpty) {
//     //         throw Exception('No guest cookies found in SharedPreferences');
//     //       }
//     //
//     //       cookies = (jsonDecode(storedCookiesStr) as List)
//     //           .map((e) => e as Map<String, dynamic>)
//     //           .toList();
//     //       print("✅ Using stored guest cookies from SharedPreferences");
//     //
//     //       // 🔎 Ensure required cookies exist (frontend + PHPSESSID + X-Magento-Vary)
//     //       final hasFrontend = cookies.any((c) => c['name'] == 'frontend');
//     //       final hasPhpSess = cookies.any((c) => c['name'] == 'PHPSESSID');
//     //       if (!hasFrontend || !hasPhpSess) {
//     //         print("⚠️ Missing critical cookies, fetching fresh from /checkout/ ...");
//     //
//     //         final httpClient = HttpClient()
//     //           ..badCertificateCallback = (cert, host, port) => true;
//     //         final frontendReq = await httpClient
//     //             .getUrl(Uri.parse('https://stage.aashniandco.com/checkout/'));
//     //         frontendReq.headers.set(
//     //           'User-Agent',
//     //           'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) '
//     //               'AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148',
//     //         );
//     //
//     //         final frontendResp = await frontendReq.close();
//     //         List<Map<String, dynamic>> refreshedCookies = [];
//     //
//     //         // Collect from HttpClientResponse.cookies
//     //         for (var cookie in frontendResp.cookies) {
//     //           refreshedCookies.add({
//     //             "name": cookie.name,
//     //             "value": cookie.value,
//     //             "domain": cookie.domain ?? "stage.aashniandco.com",
//     //             "path": cookie.path ?? "/",
//     //             "secure": cookie.secure,
//     //             "httponly": cookie.httpOnly,
//     //           });
//     //           print("🍪 Fresh cookie: ${cookie.name}=${cookie.value}");
//     //         }
//     //
//     //         // Collect from Set-Cookie headers
//     //         frontendResp.headers.forEach((name, values) {
//     //           if (name.toLowerCase() == 'set-cookie') {
//     //             for (var cookieStr in values) {
//     //               final parts = cookieStr.split(';');
//     //               final nameValue = parts.first.split('=');
//     //               if (nameValue.length == 2) {
//     //                 final cName = nameValue[0].trim();
//     //                 final cValue = nameValue[1].trim();
//     //                 if (!refreshedCookies.any((c) => c['name'] == cName)) {
//     //                   refreshedCookies.add({
//     //                     "name": cName,
//     //                     "value": cValue,
//     //                     "domain": "stage.aashniandco.com",
//     //                     "path": "/",
//     //                     "secure": cookieStr.contains("Secure"),
//     //                     "httponly": cookieStr.toLowerCase().contains("httponly"),
//     //                   });
//     //                 }
//     //                 print("🍪 Fresh Set-Cookie: $cName=$cValue");
//     //               }
//     //             }
//     //           }
//     //         });
//     //
//     //         if (refreshedCookies.isNotEmpty) {
//     //           cookies = refreshedCookies;
//     //           await prefs.setString("guest_cart_cookies", json.encode(cookies));
//     //           print("✅ Refreshed cookies saved to SharedPreferences");
//     //         }
//     //       }
//     //     } else {
//     //       // ---------------- Authenticated User ----------------
//     //       print("Authenticated user - token login");
//     //
//     //       final loginResponse = await http.post(
//     //         Uri.parse('$baseUrl/rest/V1/solr/loginByToken'),
//     //         headers: {'Content-Type': 'application/json'},
//     //         body: jsonEncode({'token': _userToken}),
//     //       );
//     //
//     //       if (loginResponse.statusCode != 200) {
//     //         throw Exception('Login via token failed: ${loginResponse.statusCode}');
//     //       }
//     //
//     //       final data = jsonDecode(loginResponse.body) as List<dynamic>;
//     //       cookies =
//     //           (data[0] as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
//     //
//     //       await prefs.setString("user_cart_cookies", json.encode(cookies));
//     //       print("✅ Fetched and saved logged-in user cookies from API");
//     //     }
//     //
//     //     // ---------------- Apply cookies to WebView ----------------
//     //     for (var cookie in cookies) {
//     //       await cookieManager.setCookie(
//     //         url: WebUri(baseUrl),
//     //         name: cookie['name'],
//     //         value: cookie['value'],
//     //         domain: 'stage.aashniandco.com', // force exact domain
//     //         path: cookie['path'] ?? '/',
//     //         isSecure: cookie['secure'] ?? true,
//     //         isHttpOnly: cookie['httponly'] ?? false,
//     //         sameSite: HTTPCookieSameSitePolicy.LAX,
//     //       );
//     //     }
//     //
//     //     // Add currency cookie
//     //     await cookieManager.setCookie(
//     //       url: WebUri(baseUrl),
//     //       name: 'currency',
//     //       value: selectedCurrency,
//     //       domain: 'stage.aashniandco.com',
//     //       path: '/',
//     //       isSecure: true,
//     //       isHttpOnly: false,
//     //       sameSite: HTTPCookieSameSitePolicy.LAX,
//     //     );
//     //
//     //     await Future.delayed(const Duration(milliseconds: 300));
//     //
//     //     Navigator.pushReplacement(
//     //       context,
//     //       MaterialPageRoute(
//     //         builder: (_) => WebViewScreen(
//     //           initialUrl: '$baseUrl/checkout/#shipping',
//     //           cookies: cookies,
//     //         ),
//     //       ),
//     //     );
//     //   } catch (e) {
//     //     ScaffoldMessenger.of(context).showSnackBar(
//     //       SnackBar(content: Text('Checkout error: $e')),
//     //     );
//     //   }
//     // }
//
//
//
//
//
//
//
//
// //27/09/2025
// //     Widget _buildCheckoutButton() {
// //       return Center(
// //         child: ElevatedButton(
// //           onPressed: _performTokenLoginAndNavigateToCheckout, // Call the new method
// //           style: ElevatedButton.styleFrom(
// //             backgroundColor: Colors.black,
// //             foregroundColor: Colors.white,
// //             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
// //             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
// //             minimumSize: const Size(250, 50),
// //           ),
// //           child: const Text(
// //             "PROCEED TO CHECKOUT",
// //             style: TextStyle(fontWeight: FontWeight.bold),
// //           ),
// //         ),
// //       );
// //     }
//
//
//     Widget _buildCheckoutButton() {
//       return Center(
//         child: ElevatedButton(
//           onPressed: () {
//             _saveShippingPreferences();
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => BlocProvider.value(
//                   value: context.read<ShippingBloc>(),
//                   child:  CheckoutScreen(),
//                 ),
//               ),
//             );
//           },
//           style: ElevatedButton.styleFrom(
//             backgroundColor: Colors.black,
//             foregroundColor: Colors.white,
//             shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//             padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//             minimumSize: const Size(250, 50),
//           ),
//           child: const Text("PROCEED TO CHECKOUT", style: TextStyle(fontWeight: FontWeight.bold)),
//         ),
//       );
//     }
//
//     Widget buildDropdown({
//       required String label,
//       required String? value,
//       required List<String> items,
//       required ValueChanged<String?> onChanged,
//     }) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//           const SizedBox(height: 8),
//           DropdownButtonFormField<String>(
//             value: value,
//             hint: Text('Please select an option', style: TextStyle(color: Colors.grey.shade600)),
//             items: items.map((String item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
//               filled: true,
//               fillColor: Colors.white,
//             ),
//             isExpanded: true,
//           ),
//         ],
//       );
//     }
//   }

// class ShoppingBagScreen extends StatefulWidget {
//   @override
//   _ShoppingBagScreenState createState() => _ShoppingBagScreenState();
// }
//
// class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
//   // State variables
//   bool isLoading = true;
//   bool isLoggedIn = false; // The most important state for this feature
//
//   final ScrollController _scrollController = ScrollController();
//   late ShippingBloc _shippingBloc;
//
//   // Cart & Weight
//   double _cartTotalWeight = 0.0;
//
//   // Shipping & Location
//   String selectedCountryName = '';
//   String selectedCountryId = '';
//   String selectedRegionName = '';
//   String selectedRegionId = '';
//
//   List<Country> countries = [];
//   List<String> countryNames = [];
//
//   // Shipping Methods & Cost
//   bool isShippingLoading = false;
//   double currentShippingCost = 0.0;
//   List<ShippingMethod> availableShippingMethods = [];
//   ShippingMethod? selectedShippingMethod;
//
//   // Dio & Cookies (for guest/user sessions)
//   late Dio dio;
//   late PersistCookieJar persistentCookieJar;
//   bool _isDioInitialized = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // This is the main entry point to set up the screen.
//     _initializeScreen();
//   }
//
//   /// This function now orchestrates initialization for BOTH guests and logged-in users.
//   Future<void> _initializeScreen() async {
//     setState(() {
//       isLoading = true; // Show loading indicator for initial setup
//     });
//
//     await _checkLoginStatus(); // Determines if the user is a guest or logged in
//
//     // --- Initialize components and fetch data for all users ---
//     _shippingBloc = context.read<ShippingBloc>();
//     await _initializeAsyncDependencies();
//
//     // Dispatch a single event to the CartBloc.
//     // The BLoC should be responsible for checking login status and fetching
//     // either the user's cart or the guest's cart.
//     context.read<CartBloc>().add(FetchCartItems());
//
//     // Fetch data common to both guests and logged-in users for shipping estimation
//     _shippingBloc.add(FetchCountries());
//     await _loadShippingPreferences();
//
//     setState(() {
//       isLoading = false; // Hide initial setup loader
//     });
//   }
//
//   /// Checks SharedPreferences to set the initial `isLoggedIn` state.
//   Future<void> _checkLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!mounted) return;
//     setState(() {
//       isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     });
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _getShippingOptions() {
//     // Shipping options can be fetched for guests too, so the isLoggedIn check is removed.
//     if (selectedCountryId.isEmpty) {
//       setState(() {
//         isShippingLoading = false;
//         availableShippingMethods = [];
//         selectedShippingMethod = null;
//         currentShippingCost = 0.0;
//       });
//       return;
//     }
//
//     setState(() {
//       isShippingLoading = true;
//       availableShippingMethods = [];
//       selectedShippingMethod = null;
//       currentShippingCost = 0.0;
//     });
//
//     context.read<ShippingBloc>().add(
//       FetchShippingMethods(
//         countryId: selectedCountryId,
//         regionId: selectedRegionId,
//       ),
//     );
//   }
//
//   // NOTE: `_loadCustomerIdAndFetchWeight` and `fetchCartTotalWeight` have been removed.
//   // This responsibility is now handled within the CartBloc and its repository,
//   // and the total weight is provided via the `CartLoaded` state.
//
//   void _saveShippingPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_country_name', selectedCountryName);
//     await prefs.setString('selected_country_id', selectedCountryId);
//     await prefs.setString('selected_region_name', selectedRegionName);
//     await prefs.setString('selected_region_id', selectedRegionId);
//
//     if (selectedShippingMethod != null) {
//       await prefs.setDouble('shipping_price', selectedShippingMethod!.amount);
//       await prefs.setString('shipping_method_name', selectedShippingMethod!.displayName);
//       await prefs.setString('carrier_code', selectedShippingMethod!.carrierCode);
//       await prefs.setString('method_code', selectedShippingMethod!.methodCode);
//     } else {
//       await prefs.remove('shipping_price');
//       await prefs.remove('shipping_method_name');
//       await prefs.remove('carrier_code');
//       await prefs.remove('method_code');
//     }
//     print("✅ Preferences Saved: Country='${selectedCountryName}', Region='${selectedRegionName}'");
//   }
//
//   Future<void> _initializeAsyncDependencies() async {
//     if (_isDioInitialized) return;
//
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     String appDocPath = appDocDir.path;
//     persistentCookieJar = PersistCookieJar(
//       ignoreExpires: true,
//       storage: FileStorage(
//           appDocPath + "/.cookies/"),
//     );
//
//     dio = Dio(BaseOptions(baseUrl: 'https://stage.aashniandco.com/rest'));
//     dio.interceptors.add(
//         CookieManager(persistentCookieJar));
//
//     (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
//       final client = HttpClient();
//       client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       return client;
//     };
//
//     _isDioInitialized = true;
//   }
//
//   Future<void> _loadShippingPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedCountryName = prefs.getString('selected_country_name');
//     final savedCountryId = prefs.getString('selected_country_id');
//     final savedRegionName = prefs.getString('selected_region_name');
//     final savedRegionId = prefs.getString('selected_region_id');
//
//     if (savedCountryName != null && savedCountryId != null) {
//       if (!mounted) return;
//       print("✅ Preferences Loaded: Country='${savedCountryName}', Region='${savedRegionName ?? ''}'");
//       setState(() {
//         selectedCountryName = savedCountryName;
//         selectedCountryId = savedCountryId;
//         selectedRegionName = savedRegionName ?? '';
//         selectedRegionId = savedRegionId ?? '';
//       });
//     }
//   }
//
//   /// Widget shown to GUEST users when their cart is empty.
//   /// It prompts them to log in to start adding items.
//   Widget _buildGuestEmptyCartPrompt(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24.0),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const Icon(Icons.shopping_bag_outlined, size: 60, color: Colors.grey),
//           const SizedBox(height: 24),
//           const Text(
//             "Please Login To Add Items",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             "Your cart is currently empty. Sign in to add products and enjoy a seamless checkout experience.",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
//           ),
//           const SizedBox(height: 32),
//           ElevatedButton(
//             onPressed: () {
//               // Navigate to the login screen. After returning, re-initialize
//               // to check the new login status and fetch the user's cart.
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => LoginScreen1()),
//               ).then((_) {
//                 _initializeScreen();
//               });
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               minimumSize: const Size(double.infinity, 50),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text(
//               "Sign In / Create Account",
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // This initial loader is for the _initializeScreen setup.
//     // The BlocBuilder will handle loading for the cart items specifically.
//     if (isLoading) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Shopping Bag')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     // Guests are no longer blocked here. The UI is now driven by the BLoC state.
//     return BlocListener<ShippingBloc, ShippingState>(
//       listener: (context, state) {
//         if (state is ShippingMethodsLoaded) {
//           setState(() {
//             isShippingLoading = false;
//             availableShippingMethods = state.methods;
//             if (state.methods.isNotEmpty) {
//               selectedShippingMethod = state.methods.first;
//               currentShippingCost = selectedShippingMethod!.amount;
//             } else {
//               selectedShippingMethod = null;
//               currentShippingCost = 0.0;
//             }
//           });
//           _saveShippingPreferences();
//         } else if (state is ShippingError) {
//           setState(() {
//             isShippingLoading = false;
//             availableShippingMethods = [];
//             selectedShippingMethod = null;
//             currentShippingCost = 0.0;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Error: ${state.message}')),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Shopping Bag'),
//           leading: IconButton(
//             icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//             onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => AuthScreen()), (r) => false),
//           ),
//         ),
//         body: Column(
//           children: [
//             Expanded(
//               child: BlocBuilder<CartBloc, CartState>(
//                 builder: (context, state) {
//                   if (state is CartLoading) {
//                     return const Center(child: CircularProgressIndicator());
//                   }
//                   // ✅ SUCCESS CASE: Handles both GUEST and LOGGED-IN users with items.
//                   else if (state is CartLoaded && state.items.isNotEmpty) {
//                     // This callback ensures the weight update happens after the build.
//                     WidgetsBinding.instance.addPostFrameCallback((_) {
//                       if (mounted && _cartTotalWeight != state.totalCartWeight) {
//                         setState(() => _cartTotalWeight = state.totalCartWeight);
//                         // Fetch shipping options whenever weight changes.
//                         _getShippingOptions();
//                       }
//                     });
//
//                     return ListView.builder(
//                       itemCount: state.items.length,
//                       itemBuilder: (context, index) {
//                         final item = state.items[index];
//                         return CartItemWidget(
//                           key: ValueKey(item['item_id']),
//                           item: item,
//                           onAdd: () => context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) + 1)),
//                           onRemove: () {
//                             if ((item['qty'] ?? 1) > 1) {
//                               context.read<CartBloc>().add(UpdateCartItemQty(item['item_id'], (item['qty'] ?? 1) - 1));
//                             }
//                           },
//                           onDelete: () => context.read<CartBloc>().add(RemoveCartItem(item['item_id'])),
//                         );
//                       },
//                     );
//                   }
//                   // ✅ EMPTY/ERROR CASE: Differentiates between GUEST and LOGGED-IN users.
//                   else if ((state is CartLoaded && state.items.isEmpty) || state is CartError) {
//                     if (isLoggedIn) {
//                       // Case for a logged-in user with an empty cart.
//                       return const Center(
//                         child: Text(
//                           "Your shopping cart is empty.",
//                           style: TextStyle(fontSize: 18, color: Colors.grey),
//                         ),
//                       );
//                     } else {
//                       // Case for a guest user with an empty cart.
//                       return _buildGuestEmptyCartPrompt(context);
//                     }
//                   }
//                   // Default State: Fallback while the BLoC is initializing.
//                   return const Center(child: Text("Welcome! Your cart is loading."));
//                 },
//               ),
//             ),
//             BlocBuilder<CartBloc, CartState>(
//               builder: (context, cartState) {
//                 // The summary container only shows if the cart is loaded and has items.
//                 if (cartState is CartLoaded && cartState.items.isNotEmpty) {
//                   return Flexible(
//                     fit: FlexFit.loose,
//                     child: Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(color: Colors.grey.shade100, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
//                       child: SingleChildScrollView(
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             _buildShippingContainer(),
//                             const SizedBox(height: 20),
//                             _buildOrderSummary(cartState),
//                             const SizedBox(height: 20),
//                             _buildCouponSection(),
//                             const SizedBox(height: 20),
//                             _buildCheckoutButton(),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 }
//                 // If cart is empty, loading, or in error state, show nothing here.
//                 return const SizedBox.shrink();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // --- All other build helper methods (_buildShippingContainer, _buildOrderSummary, etc.) remain unchanged ---
//
//   Widget _buildShippingMethodsList() {
//     if (isShippingLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     // The isLoggedIn check is removed as shipping can be estimated for guests.
//     if (availableShippingMethods.isEmpty) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 8.0),
//         child: Text("No shipping methods available for this address."),
//       );
//     }
//
//     return Column(
//       children: availableShippingMethods.map((method) {
//         return RadioListTile<ShippingMethod>(
//           title: Text(method.displayName),
//           subtitle: Text('₹${method.amount.toStringAsFixed(2)}'),
//           value: method,
//           groupValue: selectedShippingMethod,
//           onChanged: (ShippingMethod? value) {
//             setState(() {
//               selectedShippingMethod = value;
//               currentShippingCost = value?.amount ?? 0.0;
//             });
//             _saveShippingPreferences();
//           },
//         );
//       }).toList(),
//     );
//   }
//
//   Widget _buildShippingContainer() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       buildWhen: (previous, current) => current is CountriesLoaded || current is ShippingInitial,
//       builder: (context, shippingState) {
//
//         final List<Country> countries = (shippingState is CountriesLoaded) ? shippingState.countries : [];
//         final List<String> countryNames = countries.map((c) => c.fullNameEnglish).toList();
//
//         Country? selectedCountryData;
//         if (selectedCountryName.isNotEmpty) {
//           try {
//             selectedCountryData = countries.firstWhere((c) => c.fullNameEnglish == selectedCountryName);
//           } catch (e) {
//             selectedCountryData = null;
//           }
//         }
//
//         return Container(
//           width: double.infinity,
//           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//           child: Column(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 width: double.infinity,
//                 decoration: const BoxDecoration(color: Colors.black, borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16))),
//                 child: const Text('Estimate Shipping', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     buildDropdown(
//                       label: 'Select Country',
//                       value: selectedCountryName.isEmpty ? null : selectedCountryName,
//                       items: countryNames,
//                       onChanged: (value) {
//                         if (value != null) {
//                           final Country country = countries.firstWhere((c) => c.fullNameEnglish == value);
//                           setState(() {
//                             selectedCountryName = country.fullNameEnglish;
//                             selectedCountryId = country.id;
//                             selectedRegionName = '';
//                             selectedRegionId = '';
//                             selectedShippingMethod = null;
//                             availableShippingMethods = [];
//                             currentShippingCost = 0.0;
//                           });
//                           _getShippingOptions();
//                         }
//                       },
//                     ),
//                     const SizedBox(height: 20),
//
//                     if (selectedCountryData != null && selectedCountryData.regions.isNotEmpty)
//                       buildDropdown(
//                         label: 'Select State / Province',
//                         value: selectedRegionName.isEmpty ? null : selectedRegionName,
//                         items: selectedCountryData.regions.map((r) => r.name).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             final Region region = selectedCountryData!.regions.firstWhere((r) => r.name == value);
//                             setState(() {
//                               selectedRegionName = region.name;
//                               selectedRegionId = region.id;
//                               selectedShippingMethod = null;
//                               availableShippingMethods = [];
//                               currentShippingCost = 0.0;
//                             });
//                             _getShippingOptions();
//                           }
//                         },
//                       ),
//                     const SizedBox(height: 20),
//                     _buildShippingMethodsList(),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildOrderSummary(CartLoaded cartState) {
//     double subtotal = 0.0;
//     for (var item in cartState.items) {
//       subtotal += (item['qty'] ?? 1) * (double.tryParse(item['price'].toString()) ?? 0.0);
//     }
//     final total = subtotal + currentShippingCost;
//
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
//       child: Column(
//         children: [
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             const Text('Subtotal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//             Text('₹${subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
//           ]),
//           const SizedBox(height: 12),
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             Text('Shipping (${selectedShippingMethod?.displayName ?? "Not Selected"})', style: const TextStyle(fontSize: 16)),
//             Text("₹${currentShippingCost.toStringAsFixed(2)}", style: const TextStyle(fontSize: 16)),
//           ]),
//           const SizedBox(height: 20),
//           const Divider(thickness: 1),
//           const SizedBox(height: 12),
//           Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//             const Text('Order Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//             Text('₹${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//           ]),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCouponSection() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextField(
//             decoration: InputDecoration(hintText: 'Enter coupon code', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
//           ),
//         ),
//         const SizedBox(width: 12),
//         ElevatedButton(onPressed: () {}, child: const Text("Apply")),
//       ],
//     );
//   }
//
//   Widget _buildCheckoutButton() {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () {
//           _saveShippingPreferences();
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => BlocProvider.value(
//                 value: context.read<ShippingBloc>(),
//                 child: CheckoutScreen(),
//               ),
//             ),
//           );
//         },
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.black,
//           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//         ),
//         child: const Text("PROCEED TO CHECKOUT", style: TextStyle(color: Colors.white)),
//       ),
//     );
//   }
//
//   Widget buildDropdown({
//     required String label,
//     required String? value,
//     required List<String> items,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(
//             fontSize: 14, fontWeight: FontWeight.w500)),
//         const SizedBox(height: 8),
//         SizedBox(
//           width: double.infinity,
//           child: DropdownButtonFormField<String>(
//             value: value,
//             hint: const Text('Please select an option'),
//             items: items.map((String item) {
//               return DropdownMenuItem<String>(
//                 value: item,
//                 child: Text(item),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 12, vertical: 12),
//             ),
//             isExpanded: true,
//           ),
//         ),
//       ],
//     );
//   }
// }