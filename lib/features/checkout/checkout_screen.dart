import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:aashniandco/features/shoppingbag/shopping_bag.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:http/io_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../constants/api_constants.dart';
import '../Payment/view/payment_screen.dart';
import '../auth/bloc/currency_bloc.dart';
import '../auth/bloc/currency_state.dart';
import '../profile/model/customer_address_model.dart';
import '../profile/repository/order_history_repository.dart';
import '../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../shoppingbag/cart_bloc/cart_bloc.dart';
import '../shoppingbag/cart_bloc/cart_event.dart';
import '../shoppingbag/model/countries.dart';
import '../shoppingbag/repository/cart_repository.dart';

// lib/screens/checkout_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/payment_gateway_type.dart';

// Import all your required files
// NOTE: Replace 'your_app' with your actual project name/path


// class CheckoutScreen extends StatefulWidget {
//   const CheckoutScreen({Key? key}) : super(key: key);
//
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   // Blocs and Repositories
//   late ShippingBloc _shippingBloc;
//   final CartRepository _cartRepository = CartRepository();
//   final String _baseUrl = 'https://stage.aashniandco.com/rest/V1';
//
//   // Flags
//   bool _isPageLoading = true;
//   bool _isCartLoading = true;
//   bool isUserLoggedIn = false;
//   bool _areCountriesLoading = true;
//   bool _initialCountryLoadAttempted = false;
//   bool _isFetchingShippingMethods = false;
//
//   // Data
//   String? _cartError;
//   String? _countriesError;
//   List<Country> _apiCountries = [];
//   Map<String, dynamic> _totals = {};
//   List<Map<String, dynamic>> _displayableShippingMethods = [];
//
//   // Controllers
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   // Selected values for UI state
//   Country? _selectedApiCountryObject;
//   String? _selectedCountry; // Dropdown value for country
//   String? _selectedState;   // Dropdown value for state
//   String? _selectedShippingMethodId;
//
//   // Derived properties for easy access in the UI
//   double get _subTotal => (_totals['subtotal'] as num?)?.toDouble() ?? 0.0;
//   int get _itemsQty => (_totals['items_qty'] as int?) ?? 0;
//   List<String> get _currentStates => _selectedApiCountryObject?.regions.map((r) => r.name).toList() ?? [];
//
//   String get selectedCountryId => _selectedApiCountryObject?.id ?? '';
//   String get selectedRegionId {
//     if (_selectedApiCountryObject == null || _selectedState == null) return '';
//     try { return _selectedApiCountryObject!.regions.firstWhere((r) => r.name == _selectedState).id; }
//     catch (e) { return ''; }
//   }
//   String get selectedRegionName => _selectedState ?? '';
//   String get selectedRegionCode {
//     if (_selectedApiCountryObject == null || _selectedState == null) return '';
//     try { return _selectedApiCountryObject!.regions.firstWhere((r) => r.name == _selectedState).code; }
//     catch (e) { return ''; }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _shippingBloc = context.read<ShippingBloc>();
//     _initializeCheckout();
//   }
//
//   Future<void> _initializeCheckout() async {
//     if (!mounted) return;
//     setState(() => _isPageLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//
//     // Fetch cart totals first, then countries.
//     await _fetchCartAndTotals();
//     _fetchCountries(); // This is async and will be handled by the BLoC listener
//
//     // Loading preferences will be triggered by the BLoC listener once countries are loaded.
//   }
//
//   Future<void> _fetchCountries() async {
//     if (!mounted) return;
//     setState(() { _areCountriesLoading = true; _countriesError = null; });
//     _shippingBloc.add(FetchCountries());
//   }
//
//   Future<void> _fetchCartAndTotals() async {
//     if (!mounted) return;
//     setState(() { _isCartLoading = true; _cartError = null; });
//     try {
//       final totalsData = await _cartRepository.fetchCartTotals();
//       if (!mounted) return;
//       setState(() {
//         _totals = totalsData;
//         _isCartLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _cartError = e.toString();
//         _isCartLoading = false;
//       });
//     }
//   }
//
//   Future<void> _loadShippingPreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     final countryNameFromPrefs = prefs.getString('selected_country_name');
//     final regionNameFromPrefs = prefs.getString('selected_region_name');
//
//     if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
//       try {
//         final matchedCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == countryNameFromPrefs);
//         _selectedApiCountryObject = matchedCountry;
//         _selectedCountry = matchedCountry.fullNameEnglish;
//
//         if (regionNameFromPrefs != null && matchedCountry.regions.any((r) => r.name == regionNameFromPrefs)) {
//           _selectedState = regionNameFromPrefs;
//         }
//       } catch (e) {
//         _selectedApiCountryObject = null;
//         _selectedCountry = null;
//         _selectedState = null;
//       }
//     }
//
//     if (mounted) setState(() {});
//     await _triggerShippingMethodUpdate();
//   }
//
//   Future<void> _triggerShippingMethodUpdate() async {
//     if (selectedCountryId.isEmpty) return;
//
//     if (!mounted) return;
//     setState(() => _isFetchingShippingMethods = true);
//
//     try {
//       final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
//         countryId: selectedCountryId,
//         regionId: selectedRegionId,
//         postcode: _zipController.text,
//       );
//
//       if (!mounted) return;
//
//       final newUiMethods = fetchedMethods.map((method) {
//         return {
//           'id': '${method.carrierCode}_${method.methodCode}',
//           'price_str': '₹${method.amount.toStringAsFixed(2)}',
//           'price_val': method.amount,
//           'title': method.methodTitle,
//           'carrier': method.carrierTitle,
//           'carrier_code': method.carrierCode,
//           'method_code': method.methodCode,
//         };
//       }).toList();
//
//       setState(() {
//         _displayableShippingMethods = newUiMethods;
//         if (newUiMethods.isNotEmpty) {
//           _selectedShippingMethodId = newUiMethods.first['id'] as String;
//         } else {
//           _selectedShippingMethodId = null;
//         }
//       });
//
//     } catch (e) {
//       if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
//       setState(() => _displayableShippingMethods = []);
//     } finally {
//       if(mounted) setState(() => _isFetchingShippingMethods = false);
//     }
//   }
//
//   Future<List<ShippingMethod>> fetchAvailableShippingMethods({
//     required String countryId,
//     required String regionId,
//     required String postcode,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     late Uri url;
//     Map<String, String> headers = {'Content-Type': 'application/json'};
//     final ioClient = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
//
//     if (isUserLoggedIn && customerToken != null) {
//       url = Uri.parse('$_baseUrl/carts/mine/estimate-shipping-methods');
//       headers['Authorization'] = 'Bearer $customerToken';
//     } else if (guestQuoteId != null) {
//       url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId/estimate-shipping-methods');
//     } else {
//       throw Exception("No active cart session found.");
//     }
//
//     final payload = {
//       "address": {
//         "country_id": countryId,
//         "region_id": int.tryParse(regionId) ?? 0,
//         "postcode": postcode.isNotEmpty ? postcode : "00000",
//         "city": _cityController.text.isNotEmpty ? _cityController.text : "Placeholder",
//         "street": [_streetAddressController.text.isNotEmpty ? _streetAddressController.text : "Placeholder"],
//         "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
//         "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
//         "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
//       }
//     };
//
//     final response = await ioClient.post(url, headers: headers, body: json.encode(payload));
//     ioClient.close();
//
//     if (response.statusCode == 200) {
//       return (json.decode(response.body) as List).map((data) => ShippingMethod.fromJson(data)).toList();
//     } else {
//       throw Exception(json.decode(response.body)['message'] ?? "Failed to fetch shipping methods.");
//     }
//   }
//
//   void _onCountryChanged(String? newCountryName) {
//     if (newCountryName == null || newCountryName == _selectedCountry) return;
//
//     try {
//       final newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
//       setState(() {
//         _selectedApiCountryObject = newSelectedApiCountry;
//         _selectedCountry = newCountryName;
//         _selectedState = null;
//         _displayableShippingMethods = [];
//         _selectedShippingMethodId = null;
//       });
//       _triggerShippingMethodUpdate();
//     } catch (e) {
//       if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
//     }
//   }
//
//   void _onStateChanged(String? newRegionName) {
//     if (newRegionName == null || newRegionName == _selectedState) return;
//     setState(() => _selectedState = newRegionName);
//     _triggerShippingMethodUpdate();
//   }
//
//   // --- WIDGET BUILD ---
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<ShippingBloc, ShippingState>(
//       bloc: _shippingBloc,
//       listener: (context, state) {
//         if (!mounted) return;
//
//         if(state is ShippingInfoSubmitting) {
//           // You can show a loading dialog here if you want
//         } else if (state is CountriesLoaded) {
//           setState(() {
//             _apiCountries = state.countries;
//             _areCountriesLoading = false;
//             _initialCountryLoadAttempted = true;
//             _countriesError = null;
//           });
//           if(!_isPageLoading) _loadShippingPreferences();
//         } else if (state is ShippingError) {
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
//         } else if (state is ShippingInfoSubmittedSuccessfully) {
//           Navigator.push(context, MaterialPageRoute(builder: (_) =>
//               BlocProvider.value(
//                 value: _shippingBloc,
//                 child: PaymentScreen(
//                   paymentMethods: state.paymentMethods,
//                   totals: state.totals,
//                   billingAddress: state.billingAddress,
//                 ),
//               ),
//           ),
//           );
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Checkout'),
//           leading: IconButton(
//             icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pushAndRemoveUntil(
//                 MaterialPageRoute(builder: (context) =>  ShoppingBagScreen()), (route) => false),
//           ),
//         ),
//         body: SafeArea(
//           child: (_isPageLoading && !_initialCountryLoadAttempted)
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: _buildCheckoutForm(),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutForm() {
//     final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildEstimatedTotal(),
//         const SizedBox(height: 24.0),
//         const Text('Shipping Address', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 20.0),
//
//         if (!isUserLoggedIn) ...[
//           _buildTextFieldWithLabel('Email Address', controller: _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
//           Padding(
//             padding: const EdgeInsets.only(top: 6.0, bottom: 16.0),
//             child: Text('You can create an account after checkout.', style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
//           ),
//           const Divider(height: 1),
//           const SizedBox(height: 16.0),
//         ],
//
//         _buildTextFieldWithLabel('First Name', controller: _firstNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Last Name', controller: _lastNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('Country', isRequired: true),
//         DropdownButtonFormField<String>(
//           decoration: _inputDecoration(),
//           value: _selectedCountry,
//           isExpanded: true,
//           hint: const Text("Select Country"),
//           items: _apiCountries.map((Country country) => DropdownMenuItem<String>(
//             value: country.fullNameEnglish,
//             child: Text(country.fullNameEnglish),
//           )).toList(),
//           onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
//         ),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('State/Province', isRequired: true),
//         DropdownButtonFormField<String>(
//           decoration: _inputDecoration(),
//           value: _selectedState,
//           hint: Text(isStateDropdownEnabled ? 'Please select a region...' : 'No regions available'),
//           isExpanded: true,
//           items: _currentStates.map((String regionName) => DropdownMenuItem<String>(
//               value: regionName,
//               child: Text(regionName))
//           ).toList(),
//           onChanged: isStateDropdownEnabled ? _onStateChanged : null,
//         ),
//         const SizedBox(height: 16.0),
//
//         _buildTextFieldWithLabel('Street Address', controller: _streetAddressController, isRequired: true, maxLines: 2),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('City', controller: _cityController, isRequired: true),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Zip/Postal Code', controller: _zipController, isRequired: true, keyboardType: TextInputType.number, onEditingComplete: _triggerShippingMethodUpdate),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Phone Number', controller: _phoneController, isRequired: true, keyboardType: TextInputType.phone),
//         const SizedBox(height: 24.0),
//
//         _buildShippingMethodsSection(),
//         const SizedBox(height: 24.0),
//         _buildSubmitButton(),
//       ],
//     );
//   }
//
//   Widget _buildEstimatedTotal() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6.0)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           const Text('Order Subtotal', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500)),
//           _isCartLoading
//               ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold))
//               : Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildShippingMethodsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Shipping Methods', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8.0),
//         const Divider(height: 1),
//         const SizedBox(height: 16.0),
//         if (_isFetchingShippingMethods)
//           const Center(child: Text("Estimating shipping costs..."))
//         else if (_displayableShippingMethods.isEmpty)
//           const Center(child: Text("Please fill address details to estimate shipping."))
//         else
//           Column(
//             children: _displayableShippingMethods.map((method) => RadioListTile<String>(
//               title: Text("${method['title']} (${method['carrier']})"),
//               subtitle: Text(method['price_str'] as String),
//               value: method['id'] as String,
//               groupValue: _selectedShippingMethodId,
//               onChanged: (String? value) {
//                 if (value != null) setState(() => _selectedShippingMethodId = value);
//               },
//             )).toList(),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildSubmitButton() {
//     return BlocBuilder<ShippingBloc, ShippingState>(
//       bloc: _shippingBloc,
//       builder: (context, state) {
//         final isSubmitting = state is ShippingInfoSubmitting;
//         return SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.black,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             onPressed: (isSubmitting || _selectedShippingMethodId == null) ? null : () {
//               // Your validation logic...
//               if (_firstNameController.text.isEmpty || /* ... other checks ... */ selectedCountryId.isEmpty) {
//                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
//                 return;
//               }
//
//               final selectedMethod = _displayableShippingMethods.firstWhere((m) => m['id'] == _selectedShippingMethodId);
//
//               _shippingBloc.add(
//                 SubmitShippingInfo(
//                   isGuest: !isUserLoggedIn,
//                   firstName: _firstNameController.text,
//                   lastName: _lastNameController.text,
//                   streetAddress: _streetAddressController.text,
//                   city: _cityController.text,
//                   zipCode: _zipController.text,
//                   phone: _phoneController.text,
//                   email: isUserLoggedIn ? "placeholder@email.com" : _emailController.text,
//                   countryId: selectedCountryId,
//                   regionName: selectedRegionName,
//                   regionId: selectedRegionId,
//                   regionCode: selectedRegionCode,
//                   carrierCode: selectedMethod['carrier_code'] as String,
//                   methodCode: selectedMethod['method_code'] as String,
//                 ),
//               );
//             },
//             child: isSubmitting
//                 ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
//                 : const Text('NEXT'),
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _buildLabel(String label, {bool isRequired = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: RichText(
//         text: TextSpan(
//           text: label,
//           style: const TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.w500),
//           children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))] : [],
//         ),
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration() {
//     return InputDecoration(
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0)),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//     );
//   }
//
//   Widget _buildTextFieldWithLabel(String label, {
//     required bool isRequired,
//     required TextEditingController controller,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//     void Function()? onEditingComplete,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildLabel(label, isRequired: isRequired),
//         TextField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           onEditingComplete: onEditingComplete,
//           decoration: _inputDecoration(),
//         ),
//       ],
//     );
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _zipController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
// }
class CheckoutScreen extends StatefulWidget {
  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late ShippingBloc _shippingBloc;

  Country? _selectedApiCountryObject;
  String? _selectedCountry;
  List<Country> _apiCountries = [];
  bool _areCountriesLoading = true;
  bool _initialCountryLoadAttempted = false;
  String? _countriesError;
  int customerId = 0;
  String selectedRegionCode = '';
  bool _isSubmitting = false;
  String? _selectedShippingMethodId;

  double _subTotal = 0.0;

  String? _selectedState;
  List<String> _currentStates = [];

  String selectedCountryName = '';
  String selectedCountryId = '';
  String selectedRegionName = '';
  String selectedRegionId = '';
  double _cartTotalWeight = 0.0;

  bool isUserLoggedIn = false;
  double _grandTotal = 0.0;
  int _itemsQty = 0;

  String selectedShippingMethodName = '';
  double currentShippingCost = 0.0;
  String carrierCode = '';
  String methodCode = '';
  bool _isFetchingShippingMethods = false;

  // Explicitly defined list to prevent TypeErrors
  List<Map<String, dynamic>> _displayableShippingMethods = [];

  final CartRepository _cartRepository = CartRepository();
  List<Map<String, dynamic>> _fetchedCartItems = [];
  List<Map<String, dynamic>> _fetchTotals = [];
  bool _isCartLoading = false;
  String? _cartError;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _streetAddressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _saveAddressToProfile = false;

  bool _isLoadingShippingPrefs = true;

  // UI helper for "Title" (Mr/Mrs) to match the image UI
  String _selectedTitle = 'Mr';

  final OrderHistoryRepository _addressRepository = OrderHistoryRepository();
  List<CustomerAddress> _savedAddresses = [];
  bool _isAddressesLoading = false;

  // The 4th Dynamic Card Data
  CustomerAddress? _manualAddressPreview;
  bool _showAddressForm = false;
  String? _selectedSavedAddressId; // Tracks which card (0,1,2 or 'manual') is active

  bool get _isPageLoading =>
      _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);

  // ---------------------------------------------------------------------------
  // LOGIC METHODS (KEPT EXACTLY AS PROVIDED)
  // ---------------------------------------------------------------------------

  Future<List<ShippingMethod>> fetchAvailableShippingMethods({
    required String countryId,
    required String regionId,
    required String postcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (customerToken != null && customerToken.isNotEmpty) {
      url = Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/estimate-shipping-methods');
      headers['Authorization'] = 'Bearer $customerToken';
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId/estimate-shipping-methods');
    } else {
      throw Exception("No active session found to estimate shipping.");
    }

    final payload = {
      "address": {
        "country_id": countryId,
        "region_id": int.tryParse(regionId) ?? 0,
        "postcode": postcode,
        "city": _cityController.text,
        "street": [_streetAddressController.text],
      }
    };

    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
    final response = await client.post(url, headers: headers, body: json.encode(payload));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
    }
  }

  Future<void> _fetchCartDataAndCalculateTotals() async {
    if (!mounted) return;
    setState(() => _isCartLoading = true);
    try {
      final items = await _cartRepository.getCartItems();
      if (!mounted) return;

      double calculatedSubtotal = 0.0;
      int calculatedQty = 0;
      for (var item in items) {
        final price = (item['price'] as num?)?.toDouble() ?? 0.0;
        final qty = (item['qty'] as num?)?.toInt() ?? 0;
        calculatedSubtotal += (price * qty);
        calculatedQty += qty;
      }

      setState(() {
        _subTotal = calculatedSubtotal;
        _itemsQty = calculatedQty;
        _isCartLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cartError = e.toString();
        _isCartLoading = false;
      });
    }
  }

  Future<void> _triggerShippingMethodUpdate() async {
    if (selectedCountryId.isEmpty) return;
    if (!mounted) return;
    setState(() {
      _isFetchingShippingMethods = true;
    });

    try {
      final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
        countryId: selectedCountryId,
        regionId: selectedRegionId,
        postcode: _zipController.text,
      );

      if (!mounted) return;

      if (fetchedMethods.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No shipping methods available for this address.")),
        );
        setState(() {
          _displayableShippingMethods = [];
          _selectedShippingMethodId = null;
          _isFetchingShippingMethods = false;
        });
        return;
      }

      // Explicit <String, dynamic> cast here fixes the inference issue
      final List<Map<String, dynamic>> newUiMethods = fetchedMethods.map((method) {
        return <String, dynamic>{
          'id': '${method.carrierCode}_${method.methodCode}',
          'price_str': '₹${method.amount.toStringAsFixed(2)}',
          'price_val': method.amount,
          'title': method.methodTitle,
          'carrier': method.carrierTitle,
          'carrier_code': method.carrierCode,
          'method_code': method.methodCode,
        };
      }).toList();

      setState(() {
        _displayableShippingMethods = newUiMethods;
        if (_displayableShippingMethods.isNotEmpty) {
          final firstMethod = _displayableShippingMethods.first;
          _selectedShippingMethodId = firstMethod['id'] as String;
          currentShippingCost = firstMethod['price_val'] as double;
          selectedShippingMethodName = firstMethod['title'] as String;
          carrierCode = firstMethod['carrier_code'] as String;
          methodCode = firstMethod['method_code'] as String;
        } else {
          _selectedShippingMethodId = null;
        }
        _isFetchingShippingMethods = false;
      });

    } catch (e) {
      if (!mounted) return;
      if (kDebugMode) print("Error fetching shipping methods: $e");
      setState(() {
        _displayableShippingMethods = [];
        _selectedShippingMethodId = null;
        _isFetchingShippingMethods = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _shippingBloc = ShippingBloc();
    _shippingBloc.add(FetchCountries());
    _initializeCheckout();

    // Listeners to update the 4th Card preview in real-time
    _firstNameController.addListener(_updateManualPreview);
    _lastNameController.addListener(_updateManualPreview);
    _zipController.addListener(_updateManualPreview);
    _cityController.addListener(_updateManualPreview);
    _streetAddressController.addListener(_updateManualPreview);
  }

  void _updateManualPreview() {
    if (_showAddressForm) {
      setState(() {
        _manualAddressPreview = CustomerAddress(
          id: 0, // Manual flag
          firstname: _firstNameController.text,
          lastname: _lastNameController.text,
          street: _streetAddressController.text,
          city: _cityController.text,
          postcode: _zipController.text,
          country: selectedCountryId,
          telephone: _phoneController.text,
          region: selectedRegionName,
          isDefaultBilling: false,
          isDefaultShipping: false,
        );
      });
    }
  }

  Future<void> _initializeCheckout() async {
    await _loadLoginStatus();
    if (isUserLoggedIn) {
      await _fetchSavedAddresses();
    } else {
      setState(() => _showAddressForm = true);
    }
    _fetchCartDataAndCalculateTotals();
  }

  Future<void> _fetchSavedAddresses() async {
    setState(() => _isAddressesLoading = true);
    try {
      final addresses = await _addressRepository.fetchAddresses();
      setState(() {
        _savedAddresses = addresses;
        _isAddressesLoading = false;

        if (_savedAddresses.isNotEmpty) {
          // Automatically select the first address
          _selectAddressForShipping(_savedAddresses.first, index: "0");
          _showAddressForm = false; // Hide form since we have addresses
        } else {
          // No addresses found: show the manual form immediately
          _showAddressForm = true;
          _selectedSavedAddressId = "manual";
        }
      });
    } catch (e) {
      setState(() {
        _isAddressesLoading = false;
        _showAddressForm = true;
        _selectedSavedAddressId = "manual";
      });
    }
  }
  // Future<void> _fetchSavedAddresses() async {
  //   setState(() => _isAddressesLoading = true);
  //   try {
  //     final addresses = await _addressRepository.fetchAddresses();
  //     setState(() {
  //       _savedAddresses = addresses;
  //       _isAddressesLoading = false;
  //       if (_savedAddresses.isNotEmpty) {
  //         _selectAddressForShipping(_savedAddresses.first, index: "0");
  //       } else {
  //         _showAddressForm = true;
  //       }
  //     });
  //   } catch (e) {
  //     setState(() { _isAddressesLoading = false; _showAddressForm = true; });
  //   }
  // }

  void _selectAddressForShipping(CustomerAddress addr, {required String index}) {
    setState(() {
      _selectedSavedAddressId = index;
      _firstNameController.text = addr.firstname;
      _lastNameController.text = addr.lastname;
      _streetAddressController.text = addr.street;
      _cityController.text = addr.city;
      _zipController.text = addr.postcode;
      _phoneController.text = addr.telephone;
      selectedCountryId = addr.country;
      selectedRegionId = addr.regionId?.toString() ?? '';
      selectedRegionName = addr.region ?? '';

      // If clicking a saved card, hide the form. If manual, show it.
      _showAddressForm = (index == "manual");
    });
    _triggerShippingMethodUpdate();
  }

  Widget _buildSavedAddressesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Show only actual addresses + 1 slot for the "Add New/Manual" card
            itemCount: _savedAddresses.length + 1,
            itemBuilder: (context, index) {
              if (index < _savedAddresses.length) {
                return _buildAddressCard(_savedAddresses[index], index.toString());
              } else {
                // The last item is always the "Add New" or "Manual Preview" card
                if (_manualAddressPreview != null || _showAddressForm) {
                  return _buildAddressCard(_manualAddressPreview ?? CustomerAddress(id:0, firstname: "New", lastname: "Address", street: "", city: "", postcode: "", country: "", telephone: "", isDefaultBilling: false, isDefaultShipping: false), "manual");
                } else {
                  return _buildAddNewCard();
                }
              }
            },
          ),
        ),
      ],
    );
  }
  // Widget _buildSavedAddressesList() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       const Text('Shipping Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //       const SizedBox(height: 15),
  //       SizedBox(
  //         height: 240,
  //         child: ListView.builder(
  //           scrollDirection: Axis.horizontal,
  //           itemCount: 4, // Strictly 4 slots
  //           itemBuilder: (context, index) {
  //             // Slots 1, 2, 3: Saved Addresses
  //             if (index < 3) {
  //               if (index < _savedAddresses.length) {
  //                 return _buildAddressCard(_savedAddresses[index], index.toString());
  //               } else {
  //                 return _buildEmptySlot(); // Placeholder if user has < 3 addresses
  //               }
  //             }
  //
  //             // Slot 4: The Dynamic Manual/Add Card
  //             if (_manualAddressPreview != null || _showAddressForm) {
  //               return _buildAddressCard(_manualAddressPreview ?? CustomerAddress(id:0, firstname: "New", lastname: "Address", street: "", city: "", postcode: "", country: "", telephone: "", isDefaultBilling: false, isDefaultShipping: false), "manual");
  //             } else {
  //               return _buildAddNewCard();
  //             }
  //           },
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildAddressCard(CustomerAddress addr, String indexId) {
    bool isSelected = _selectedSavedAddressId == indexId;
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12, bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[50] : Colors.white,
        border: Border.all(color: isSelected ? Colors.black : Colors.grey[300]!, width: isSelected ? 2 : 1),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${addr.firstname} ${addr.lastname}", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Expanded(child: Text("${addr.street}\n${addr.city}, ${addr.region ?? ''}\n${addr.postcode}",
              style: const TextStyle(fontSize: 12, height: 1.4))),
          const Divider(),
          Center(
            child: TextButton(
              onPressed: () => _selectAddressForShipping(addr, index: indexId),
              child: Text(isSelected ? "SELECTED" : (indexId == "manual" ? "EDIT / USE" : "SHIP HERE"),
                  style: TextStyle(color: isSelected ? Colors.green : Colors.blue, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAddNewCard() {
    return GestureDetector(
      onTap: () {
        _clearAddressForm();
        setState(() {
          _showAddressForm = true;
          _selectedSavedAddressId = "manual";
        });
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12, bottom: 10),
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add_circle_outline, size: 40, color: Colors.grey), Text("Add New Address")],
        ),
      ),


    );
  }




  Widget _buildEmptySlot() => Container(width: 220, margin: const EdgeInsets.only(right: 12), color: Colors.transparent);
  Future<void> _loadShippingPreferencesForCheckout() async {
    if (!mounted) return;
    setState(() {
      _isLoadingShippingPrefs = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final String? countryNameFromPrefs = prefs.getString('selected_country_name');
    final String? countryIdFromPrefs = prefs.getString('selected_country_id');
    final String? regionNameFromPrefs = prefs.getString('selected_region_name');
    final String? regionIdFromPrefs = prefs.getString('selected_region_id');
    final double? shippingPriceFromPrefs = prefs.getDouble('shipping_price');
    final String? shippingMethodNameFromPrefs = prefs.getString('method_name');
    final String? carrierCodeFromPrefs = prefs.getString('carrier_code');
    final String? methodCodeFromPrefs = prefs.getString('method_code');

    Country? resolvedApiCountry;

    if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
      try {
        resolvedApiCountry = _apiCountries.firstWhere(
                (c) => c.fullNameEnglish == countryNameFromPrefs || (countryIdFromPrefs != null && c.id == countryIdFromPrefs)
        );
      } catch (e) {
        resolvedApiCountry = null;
      }
    }

    if (resolvedApiCountry == null && _selectedApiCountryObject != null && _apiCountries.isNotEmpty) {
      try {
        resolvedApiCountry = _apiCountries.firstWhere((c) => c.id == _selectedApiCountryObject!.id);
      } catch (e) {
        resolvedApiCountry = null;
      }
    }

    if (resolvedApiCountry == null && _apiCountries.isNotEmpty) {
      resolvedApiCountry = _apiCountries.first;
    }

    List<String> newCurrentStatesList = [];
    List<Region> regionsForResolvedCountry = [];
    String finalSelectedCountryDropDownName = _selectedCountry ?? '';
    String finalSelectedCountryId = selectedCountryId;
    String finalSelectedCountryFullName = selectedCountryName;

    if (resolvedApiCountry != null) {
      _selectedApiCountryObject = resolvedApiCountry;
      finalSelectedCountryDropDownName = resolvedApiCountry.fullNameEnglish;
      finalSelectedCountryId = resolvedApiCountry.id;
      finalSelectedCountryFullName = resolvedApiCountry.fullNameEnglish;
      regionsForResolvedCountry = resolvedApiCountry.regions;
      newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
    } else if (_apiCountries.isEmpty && countryNameFromPrefs != null) {
      finalSelectedCountryDropDownName = countryNameFromPrefs;
      finalSelectedCountryId = countryIdFromPrefs ?? '';
      finalSelectedCountryFullName = countryNameFromPrefs;
      _selectedApiCountryObject = null;
    } else {
      _selectedApiCountryObject = null;
    }

    String? finalSelectedStateDropDownName = _selectedState;
    String finalSelectedRegionStoredId = selectedRegionId;
    String finalSelectedRegionStoredName = selectedRegionName;

    if (regionNameFromPrefs != null && regionsForResolvedCountry.isNotEmpty) {
      Region? matchedRegionFromPrefs;
      try {
        matchedRegionFromPrefs = regionsForResolvedCountry.firstWhere(
                (r) => r.name == regionNameFromPrefs || (regionIdFromPrefs != null && r.id == regionIdFromPrefs)
        );
      } catch (e) { matchedRegionFromPrefs = null; }

      if (matchedRegionFromPrefs != null) {
        finalSelectedStateDropDownName = matchedRegionFromPrefs.name;
        finalSelectedRegionStoredId = matchedRegionFromPrefs.id;
        finalSelectedRegionStoredName = matchedRegionFromPrefs.name;
      } else {
        if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
          finalSelectedStateDropDownName = null;
          finalSelectedRegionStoredId = '';
          finalSelectedRegionStoredName = '';
        }
      }
    }

    double loadedShippingCost = 0.0;
    String loadedShippingMethodName = '';
    String? loadedSelectedShippingId;
    String loadedCarrierCode = '';
    String loadedMethodCode = '';

    if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
      loadedShippingCost = shippingPriceFromPrefs;
      loadedShippingMethodName = shippingMethodNameFromPrefs;
      loadedSelectedShippingId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
      loadedCarrierCode = carrierCodeFromPrefs;
      loadedMethodCode = methodCodeFromPrefs;
    }

    if (!mounted) return;
    setState(() {
      _selectedCountry = finalSelectedCountryDropDownName.isNotEmpty ? finalSelectedCountryDropDownName : null;
      this.selectedCountryId = finalSelectedCountryId;
      this.selectedCountryName = finalSelectedCountryFullName;

      _currentStates = newCurrentStatesList;
      _selectedState = finalSelectedStateDropDownName;

      this.selectedRegionName = finalSelectedRegionStoredName;
      this.selectedRegionId = finalSelectedRegionStoredId;

      currentShippingCost = loadedShippingCost;
      selectedShippingMethodName = loadedShippingMethodName;
      _selectedShippingMethodId = loadedSelectedShippingId;
      carrierCode = loadedCarrierCode;
      methodCode = loadedMethodCode;

      _isLoadingShippingPrefs = false;
    });

    _triggerShippingMethodUpdate();
  }

  Future<void> _callAndProcessFetchTotal() async {
    if (!mounted) return;
    setState(() { _isCartLoading = true; _cartError = null; });
    try {
      final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
      if (!mounted) return;
      if (totalsObject != null) {
        double foundSubtotal = 0.0;
        if (totalsObject['total_segments'] is List) {
          try {
            final subtotalSegment = (totalsObject['total_segments'] as List)
                .firstWhere((segment) => segment['code'] == 'subtotal');
            foundSubtotal = (subtotalSegment['value'] as num?)?.toDouble() ?? 0.0;
          } catch (e) {
            foundSubtotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
          }
        }

        setState(() {
          _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
          _subTotal = foundSubtotal;
          _itemsQty = totalsObject['items_qty'] as int? ?? 0;

          if (totalsObject['total_segments'] is List) {
            _fetchTotals = (totalsObject['total_segments'] as List)
                .map((segment) => segment as Map<String, dynamic>)
                .toList();
          } else { _fetchTotals = []; }
          _isCartLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cartError = e.toString(); _isCartLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _performFetchTotalApiCallModified() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      return Future.value({'grand_total': 0.0, 'items_qty': 0, 'total_segments': []});
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(
        Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/totals'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception("Failed to fetch totals");
      }
    } finally { ioClient.close(); }
  }

  Future<void> _fetchAndPrintCartItemsDirectly() async {
    if (!mounted) return;
    try {
      final items = await _cartRepository.getCartItems();
      if (!mounted) return;
      setState(() { _fetchedCartItems = items; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _cartError = (_cartError ?? "") + " Cart items error: " + e.toString(); _fetchedCartItems = []; });
    }
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() { isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false; });
  }

  void _onCountryChanged(String? newCountryName) {
    if (newCountryName == null || newCountryName == _selectedCountry) return;

    Country? newSelectedApiCountry;
    try {
      newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
    } catch (e) { return; }

    setState(() {
      _selectedApiCountryObject = newSelectedApiCountry;
      _selectedCountry = newSelectedApiCountry?.fullNameEnglish;
      selectedCountryName = newSelectedApiCountry!.fullNameEnglish;
      selectedCountryId = newSelectedApiCountry.id;

      // Reset state/region when country changes
      _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();
      _currentStates.sort();
      _selectedState = null;
      selectedRegionName = '';
      selectedRegionId = '';

      // Clear old methods so user doesn't see wrong prices while loading
      _displayableShippingMethods = [];
      _selectedShippingMethodId = null;
    });

    // IMPORTANT: Only trigger if Zip/City is valid for the new country
    // For now, call it to fetch "standard" rates for the new country
    _triggerShippingMethodUpdate();
  }
  // void _onCountryChanged(String? newCountryName) {
  //   if (newCountryName == null || newCountryName == _selectedCountry) return;
  //
  //   Country? newSelectedApiCountry;
  //   try {
  //     newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
  //   } catch (e) {
  //     return;
  //   }
  //
  //   setState(() {
  //     _selectedApiCountryObject = newSelectedApiCountry;
  //     _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
  //     selectedCountryName = newSelectedApiCountry.fullNameEnglish;
  //     selectedCountryId = newSelectedApiCountry.id;
  //
  //     final stateNames = newSelectedApiCountry.regions.map((r) => r.name).toList();
  //     stateNames.sort();
  //     _currentStates = stateNames;
  //
  //     _selectedState = null;
  //     selectedRegionName = '';
  //     selectedRegionId = '';
  //     _displayableShippingMethods = [];
  //     _selectedShippingMethodId = null;
  //     _isFetchingShippingMethods = false;
  //   });
  //   _triggerShippingMethodUpdate();
  // }

  Future<void> _saveCurrentSelectionsToPrefs() async {
    if (selectedCountryName.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_country_name', selectedCountryName);
    await prefs.setString('selected_country_id', selectedCountryId);

    if (selectedRegionName.isNotEmpty) {
      await prefs.setString('selected_region_name', selectedRegionName);
      await prefs.setString('selected_region_id', selectedRegionId);
    } else {
      await prefs.remove('selected_region_name');
      await prefs.remove('selected_region_id');
    }
    await prefs.setDouble('shipping_price', currentShippingCost);
    await prefs.setString('shipping_method_name', selectedShippingMethodName);
    await prefs.setString('shipping_carrier_code', carrierCode);
    await prefs.setString('shipping_method_code', methodCode);
  }

  @override
  void dispose() {
    _shippingBloc.close();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // NEW UI WIDGETS START HERE
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // 1. Get Currency State for Bottom Bar
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double displaySubtotal = _subTotal;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      displaySubtotal = _subTotal * currencyState.selectedRate.rate;
    }

    return BlocProvider.value(
      value: _shippingBloc,
      child: BlocListener<ShippingBloc, ShippingState>(
        listener: (context, state) async {
          if (!mounted) return;

          if (state is CountriesLoading) {
            setState(() {
              _areCountriesLoading = true;
              _countriesError = null;
            });
          } else if (state is CountriesLoaded) {
            _apiCountries = state.countries;
            _areCountriesLoading = false;
            _initialCountryLoadAttempted = true;
            _countriesError = null;
            _loadShippingPreferencesForCheckout();
          } else if (state is ShippingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is ShippingInfoSubmittedSuccessfully) {
            final countryId = state.billingAddress['country_id'] as String? ?? '';
            final PaymentGatewayType gateway;

            if (countryId.toUpperCase() == 'IN') {
              gateway = PaymentGatewayType.payu;
            } else {
              gateway = PaymentGatewayType.stripe;
            }
            final prefs = await SharedPreferences.getInstance();
            final savedEmail = prefs.getString('user_email');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: _shippingBloc,
                  child: PaymentScreen(
                      paymentMethods: state.paymentMethods,
                      totals: state.totals,
                      billingAddress: state.billingAddress,
                      selectedGateway: gateway,
                      guestEmail: savedEmail
                  ),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text('Purchase', style: TextStyle(color: Colors.black, fontFamily: 'Serif', fontSize: 24)),
            leading: IconButton(
              icon: Icon(Platform.isIOS ? Icons.close : Icons.close, color: Colors.black),
              onPressed: () {
                if (Navigator.canPop(context)) Navigator.pop(context);
                else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
              },
            ),
          ),
          body: Column(
            children: [
              _buildStepper(),
              Expanded(
                child: _isPageLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.black))
                    : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: _buildCheckoutForm(),
                ),
              ),
              _buildBottomSummaryBar(displaySymbol, displaySubtotal),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildStepItem("Shipping", "1", true),
          _buildStepLine(),
          _buildStepItem("Review & Pay", "2", false),
          _buildStepLine(),
          _buildStepItem("Complete", "3", false),
        ],
      ),
    );
  }

  Widget _buildStepItem(String label, String number, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isActive ? Colors.green[800]! : Colors.grey[300]!),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                color: isActive ? Colors.green[800] : Colors.grey[400],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.black : Colors.grey[500],
            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
          ),
        )
      ],
    );
  }

  Widget _buildStepLine() {
    return Container(
      width: 40,
      height: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
    );
  }

  Widget _buildCheckoutForm() {
    if (_isAddressesLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // ONLY show the Shipping Address section if the user is logged in
        // AND they actually have saved addresses.
        if (isUserLoggedIn && _savedAddresses.isNotEmpty) ...[
          _buildSavedAddressesList(),
          const SizedBox(height: 20), // This is the "part between" you want to hide
        ],

        // Show the input form if "Add New" is clicked, user is Guest,
        // OR if the logged-in user has no addresses yet.
        if (_showAddressForm || !isUserLoggedIn || _savedAddresses.isEmpty) ...[
          const Text('Address Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildAddressInputFields(),
        ],

        const SizedBox(height: 30.0),

        // SHIPPING METHODS
        BlocBuilder<ShippingBloc, ShippingState>(
            builder: (context, blocState) => _buildShippingMethodsSection(blocState)
        ),
        const SizedBox(height: 40.0),
      ],
    );
  }
  // Widget _buildCheckoutForm() {
  //   if (_isAddressesLoading) return const Center(child: CircularProgressIndicator());
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       if (isUserLoggedIn) _buildSavedAddressesList(),
  //
  //       const SizedBox(height: 20),
  //
  //       // Show the input form ONLY if "Add New" is clicked or user is Guest
  //       if (_showAddressForm || !isUserLoggedIn) ...[
  //         const Text('Address Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
  //         const SizedBox(height: 15),
  //         _buildAddressInputFields(), // Put your textfields here
  //       ],
  //
  //       const SizedBox(height: 30.0),
  //
  //       // SHIPPING METHODS (Will update based on the selected card above)
  //       BlocBuilder<ShippingBloc, ShippingState>(
  //           builder: (context, blocState) => _buildShippingMethodsSection(blocState)
  //       ),
  //       const SizedBox(height: 40.0),
  //     ],
  //   );
  // }

  Widget _buildAddressInputFields() {
    final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
    final sortedCountries = List<Country>.from(_apiCountries)
      ..sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Country Selector
        const Text("Shipping to", style: TextStyle(fontSize: 15, color: Colors.black54)),
        DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.zero,
            border: InputBorder.none,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
          value: _selectedCountry,
          isExpanded: true,
          hint: const Text("Select Country"),
          style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
          items: sortedCountries.map((Country country) {
            return DropdownMenuItem<String>(
              value: country.fullNameEnglish,
              child: Text(country.fullNameEnglish),
            );
          }).toList(),
          onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
        ),
        const Divider(thickness: 1, color: Colors.grey),
        const SizedBox(height: 20.0),

        // 2. Email (Only for Guests)
        if (!isUserLoggedIn) ...[
          _buildStyledTextField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16.0),
        ],

        // 3. Title and First Name Row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Title", style: TextStyle(fontSize: 13, color: Colors.black)),
                  const SizedBox(height: 8),
                  Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTitle,
                        isExpanded: true,
                        items: ['Mr', 'Mrs', 'Ms', 'Dr']
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedTitle = val!),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              flex: 4,
              child: _buildStyledTextField(label: 'First name', controller: _firstNameController),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // 4. Last Name
        _buildStyledTextField(label: 'Last name', controller: _lastNameController),
        const SizedBox(height: 16.0),

        // 5. Address
        _buildStyledTextField(label: 'Address', controller: _streetAddressController),
        const SizedBox(height: 16.0),

        // 6. City
        _buildStyledTextField(label: 'City', controller: _cityController),
        const SizedBox(height: 16.0),

        // 7. State Dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("State / Province", style: TextStyle(fontSize: 13, color: Colors.black)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(4.0),
                    borderSide: const BorderSide(color: Colors.black, width: 1)),
              ),
              value: _selectedState,
              hint: Text(_currentStates.isEmpty ? "Select State" : "Select State",
                  style: TextStyle(color: Colors.grey[500])),
              isExpanded: true,
              items: _currentStates.map((String regionName) {
                return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
              }).toList(),
              onChanged: isStateDropdownEnabled
                  ? (newRegionName) {
                if (newRegionName == null) return;
                setState(() {
                  Region? selectedRegionObject;
                  if (_selectedApiCountryObject != null) {
                    try {
                      selectedRegionObject = _selectedApiCountryObject!.regions
                          .firstWhere((r) => r.name == newRegionName);
                    } catch (e) {
                      selectedRegionObject = null;
                    }
                  }
                  _selectedState = newRegionName;
                  if (selectedRegionObject != null) {
                    selectedRegionName = selectedRegionObject.name;
                    selectedRegionId = selectedRegionObject.id;
                    selectedRegionCode = selectedRegionObject.code;
                  } else {
                    selectedRegionName = '';
                    selectedRegionId = '';
                    selectedRegionCode = '';
                  }
                });
                _triggerShippingMethodUpdate();
              }
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // 8. Zip Code
        _buildStyledTextField(
            label: 'Zip / Postal Code',
            controller: _zipController,
            keyboardType: TextInputType.number,
            onEditingComplete: _triggerShippingMethodUpdate),
        const SizedBox(height: 16.0),

        // 9. Phone Number
        _buildStyledTextField(
            label: 'Phone Number',
            controller: _phoneController,
            keyboardType: TextInputType.phone),
        if (isUserLoggedIn)
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _saveAddressToProfile,
                  activeColor: Colors.black,
                  onChanged: (bool? value) {
                    setState(() {
                      _saveAddressToProfile = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text("Save this address to my profile",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
      ],
    );
  }
  // Widget _buildCheckoutForm() {
  //   final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
  //   final sortedCountries = List<Country>.from(_apiCountries)
  //     ..sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: <Widget>[
  //       const Text(
  //         'Shipping Details',
  //         style: TextStyle(fontSize: 26.0, fontFamily: 'Serif', color: Colors.black87),
  //       ),
  //       const SizedBox(height: 20.0),
  //
  //       // Country Selector (Styled to look like text if possible, but keeping Dropdown logic)
  //       const SizedBox(height: 10),
  //       const Text("Shipping to", style: TextStyle(fontSize: 15, color: Colors.black54)),
  //
  //       // Kept original DropdownButtonFormField logic, but styled minimally
  //       DropdownButtonFormField<String>(
  //         decoration: const InputDecoration(
  //           isDense: true,
  //           contentPadding: EdgeInsets.zero,
  //           border: InputBorder.none,
  //         ),
  //         icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
  //         value: _selectedCountry,
  //         isExpanded: true,
  //         hint: const Text("Select Country"),
  //         style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
  //         items: sortedCountries.map((Country country) {
  //           return DropdownMenuItem<String>(
  //             value: country.fullNameEnglish,
  //             child: Row(
  //               children: [
  //                 // A placeholder for flag could go here
  //                 Text(country.fullNameEnglish),
  //               ],
  //             ),
  //           );
  //         }).toList(),
  //         onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
  //       ),
  //       const Divider(thickness: 1, color: Colors.grey),
  //       const SizedBox(height: 20.0),
  //
  //       if (!isUserLoggedIn) ...[
  //         _buildStyledTextField(
  //             label: 'Email Address',
  //             controller: _emailController,
  //             keyboardType: TextInputType.emailAddress
  //         ),
  //         const SizedBox(height: 16.0),
  //       ],
  //
  //       // Title and First Name Row
  //       Row(
  //         children: [
  //           Expanded(
  //             flex: 2,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const Text("Title", style: TextStyle(fontSize: 13, color: Colors.black)),
  //                 const SizedBox(height: 8),
  //                 Container(
  //                   height: 50,
  //                   padding: const EdgeInsets.symmetric(horizontal: 10),
  //                   decoration: BoxDecoration(
  //                     border: Border.all(color: Colors.grey[300]!),
  //                     borderRadius: BorderRadius.circular(4),
  //                   ),
  //                   child: DropdownButtonHideUnderline(
  //                     child: DropdownButton<String>(
  //                       value: _selectedTitle,
  //                       isExpanded: true,
  //                       items: ['Mr', 'Mrs', 'Ms', 'Dr'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
  //                       onChanged: (val) => setState(() => _selectedTitle = val!),
  //                     ),
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //           const SizedBox(width: 15),
  //           Expanded(
  //             flex: 4,
  //             child: _buildStyledTextField(label: 'First name', controller: _firstNameController),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16.0),
  //
  //       _buildStyledTextField(label: 'Last name', controller: _lastNameController),
  //       const SizedBox(height: 16.0),
  //
  //       _buildStyledTextField(label: 'Address', controller: _streetAddressController),
  //       // Padding(
  //       //   padding: const EdgeInsets.only(top: 8.0),
  //       //   child: GestureDetector(
  //       //     onTap: () {
  //       //       // Logic to show Address line 2 if needed
  //       //     },
  //       //     child: const Text("Add new line", style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)),
  //       //   ),
  //       // ),
  //       const SizedBox(height: 16.0),
  //
  //       _buildStyledTextField(label: 'City', controller: _cityController),
  //       const SizedBox(height: 16.0),
  //
  //       // State Dropdown
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text("State / Province", style: TextStyle(fontSize: 13, color: Colors.black)),
  //           const SizedBox(height: 8),
  //           DropdownButtonFormField<String>(
  //             decoration: InputDecoration(
  //               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  //               border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
  //               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
  //               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Colors.black, width: 1)),
  //             ),
  //             value: _selectedState,
  //             hint: Text(_currentStates.isEmpty ? "Select State" : "Select State", style: TextStyle(color: Colors.grey[500])),
  //             isExpanded: true,
  //             items: _currentStates.map((String regionName) {
  //               return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
  //             }).toList(),
  //             onChanged: isStateDropdownEnabled ? (newRegionName) {
  //               if (newRegionName == null) return;
  //               setState(() {
  //                 Region? selectedRegionObject;
  //                 if (_selectedApiCountryObject != null) {
  //                   try {
  //                     selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
  //                   } catch (e) { selectedRegionObject = null; }
  //                 }
  //                 _selectedState = newRegionName;
  //                 if (selectedRegionObject != null) {
  //                   selectedRegionName = selectedRegionObject.name;
  //                   selectedRegionId = selectedRegionObject.id;
  //                   selectedRegionCode = selectedRegionObject.code;
  //                 } else {
  //                   selectedRegionName = ''; selectedRegionId = ''; selectedRegionCode = '';
  //                 }
  //               });
  //               _triggerShippingMethodUpdate();
  //             } : null,
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 16.0),
  //
  //       _buildStyledTextField(
  //           label: 'Zip / Postal Code',
  //           controller: _zipController,
  //           keyboardType: TextInputType.number,
  //           onEditingComplete: _triggerShippingMethodUpdate
  //       ),
  //       const SizedBox(height: 16.0),
  //
  //       _buildStyledTextField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
  //       const SizedBox(height: 30.0),
  //
  //       BlocBuilder<ShippingBloc, ShippingState>(
  //           builder: (context, blocState) {
  //             return _buildShippingMethodsSection(blocState);
  //           }
  //       ),
  //       const SizedBox(height: 40.0),
  //     ],
  //   );
  // }

  Widget _buildStyledTextField({
    required String label,
    required TextEditingController? controller,
    TextInputType? keyboardType,
    void Function()? onEditingComplete
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Colors.black, width: 1)),
          ),
          style: const TextStyle(fontSize: 15),
        )
      ],
    );
  }

  Widget _buildBottomSummaryBar(String symbol, double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                Text("$symbol${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            BlocBuilder<ShippingBloc, ShippingState>(
              builder: (context, state) {
                final isSubmitting = state is ShippingInfoSubmitting;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                  ),
                  // If submitting, disable button. Otherwise call _submitForm
                  onPressed: isSubmitting ? null : _submitForm,
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text("NEXT"),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  void _clearAddressForm() {
    _firstNameController.clear();
    _lastNameController.clear();
    _streetAddressController.clear();
    _cityController.clear();
    _zipController.clear();
    _phoneController.clear();
    setState(() {
      _selectedCountry = null;
      selectedCountryId = '';
      _selectedState = null;
      selectedRegionName = '';
      selectedRegionId = '';
      _displayableShippingMethods = [];
      _selectedShippingMethodId = null;
    });
  }

  void _submitForm() async {
    // 1. Validation
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _streetAddressController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _zipController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        selectedCountryId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields.')));
      return;
    }

    if (_displayableShippingMethods.isEmpty || _selectedShippingMethodId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a shipping method.')));
      return;
    }

    // 2. OPTIONAL: Save Address to Profile API call
    if (isUserLoggedIn && _saveAddressToProfile) {
      try {
        // Show a small loading indicator if you like,
        // but usually, we just wrap it in the submission flow
        CustomerAddress newAddr = CustomerAddress(
          id: 0,
          firstname: _firstNameController.text,
          lastname: _lastNameController.text,
          street: _streetAddressController.text,
          city: _cityController.text,
          postcode: _zipController.text,
          country: selectedCountryId,
          telephone: _phoneController.text,
          isDefaultBilling: false,
          isDefaultShipping: false,
        );

        await _addressRepository.saveAddress(
          newAddr,
          region: selectedRegionName,
          regionId: selectedRegionId,
        );
        print("Address saved to profile successfully.");
      } catch (e) {
        print("Failed to save address to profile: $e");
        // We don't necessarily want to block the whole checkout if only the
        // "save to profile" fails, but you can alert the user here.
      }
    }

    // 3. Save Selections to local Prefs (for later use)
    await _saveCurrentSelectionsToPrefs();

    // 4. Trigger the ShippingBloc to submit to Magento Cart
    // This event (once successful) triggers the BlocListener
    // to navigate to PaymentScreen automatically.
    final enteredEmail = _emailController.text.isNotEmpty
        ? _emailController.text.trim()
        : 'mitesh@gmail.com';

    _shippingBloc.add(
      SubmitShippingInfo(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        streetAddress: _streetAddressController.text,
        city: _cityController.text,
        zipCode: _zipController.text,
        phone: _phoneController.text,
        email: enteredEmail,
        countryId: selectedCountryId,
        regionName: selectedRegionName,
        regionId: selectedRegionId,
        regionCode: selectedRegionCode,
        carrierCode: carrierCode,
        methodCode: methodCode,
      ),
    );
  }
  //3/1/2026
  // EXACT VALIDATION AND LOGIC FROM ORIGINAL CODE
  // void _submitForm() async {
  //   // 1. Validation: Ensure all fields are filled
  //   if (_firstNameController.text.isEmpty ||
  //       _lastNameController.text.isEmpty ||
  //       _streetAddressController.text.isEmpty ||
  //       _cityController.text.isEmpty ||
  //       _zipController.text.isEmpty ||
  //       _phoneController.text.isEmpty ||
  //       selectedCountryId.isEmpty
  //   ) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
  //     return;
  //   }
  //
  //   // 2. Validation: Ensure a shipping method is actually selected
  //   // We check if we have methods and if an ID is selected
  //   if (_displayableShippingMethods.isEmpty || _selectedShippingMethodId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a shipping method first.')));
  //     return;
  //   }
  //
  //   // Safety check: ensure the selected ID actually exists in the current list
  //   // Cast the list explicitly to avoid the Type error you saw previously
  //   final displayList = _displayableShippingMethods.cast<Map<String, dynamic>>();
  //   final determinedShippingMethod = displayList.firstWhere(
  //         (m) => m['id'] == _selectedShippingMethodId,
  //     orElse: () => <String, dynamic>{},
  //   );
  //
  //   if (determinedShippingMethod.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid shipping method selected. Please select again.')));
  //     return;
  //   }
  //
  //   // 3. Save selections
  //   await _saveCurrentSelectionsToPrefs();
  //
  //   final finalCarrierCode = carrierCode;
  //   final finalMethodCode = methodCode;
  //
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
  //   // final finalMethodCode = prefs.getString('method_code') ?? methodCode;
  //
  //   // Handle Email
  //   final enteredEmail = _emailController.text.isNotEmpty ? _emailController.text.trim() : 'mitesh@gmail.com';
  //   // await prefs.setString('user_email', enteredEmail);
  //
  //   print("--- ✅ SUBMITTING SHIPPING INFO ---");
  //   print("Carrier: $finalCarrierCode, Method: $finalMethodCode");
  //   // 4. Debug Print
  //   if (kDebugMode) {
  //     print("--- ✅ SUBMITTING SHIPPING INFO ---");
  //     print("Email: $enteredEmail");
  //     print("Carrier: $finalCarrierCode, Method: $finalMethodCode");
  //   }
  //
  //   // 5. Trigger Bloc Event - ✅ FIX: Use _shippingBloc directly
  //   _shippingBloc.add(
  //     SubmitShippingInfo(
  //       firstName: _firstNameController.text,
  //       lastName: _lastNameController.text,
  //       streetAddress: _streetAddressController.text,
  //       city: _cityController.text,
  //       zipCode: _zipController.text,
  //       phone: _phoneController.text,
  //       email: enteredEmail,
  //       countryId: selectedCountryId,
  //       regionName: selectedRegionName,
  //       regionId: selectedRegionId,
  //       regionCode: selectedRegionCode,
  //       carrierCode: finalCarrierCode,
  //       methodCode: finalMethodCode,
  //     ),
  //   );
  // }
  // Restored Shipping Table Logic + Radio Button interactivity
  Widget _buildShippingMethodsSection(ShippingState state) {
    if (_isFetchingShippingMethods) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: Text("Estimating shipping...")),
      );
    }

    if (_displayableShippingMethods.isEmpty) return const SizedBox.shrink();

    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double exchangeRate = 1.0;
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      exchangeRate = currencyState.selectedRate.rate;
    }

    // Cast to correct type
    final displayList = _displayableShippingMethods.cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Shipping Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        ...displayList.map((method) {
          final double baseShippingPrice = method['price_val'] as double;
          final double displayShippingPrice = baseShippingPrice * exchangeRate;
          final bool isSelected = method['id'] == _selectedShippingMethodId;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedShippingMethodId = method['id'] as String;
                currentShippingCost = method['price_val'] as double;
                selectedShippingMethodName = method['title'] as String;
                carrierCode = method['carrier_code'] as String;
                methodCode = method['method_code'] as String;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey[50] : Colors.white,
                border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey[300]!,
                    width: isSelected ? 1.5 : 1.0
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Radio<String>(
                    value: method['id'] as String,
                    groupValue: _selectedShippingMethodId,
                    activeColor: Colors.black,
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          _selectedShippingMethodId = value;
                          currentShippingCost = method['price_val'] as double;
                          selectedShippingMethodName = method['title'] as String;
                          carrierCode = method['carrier_code'] as String;
                          methodCode = method['method_code'] as String;
                        });
                      }
                    },
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(method['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(method['carrier'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(
                      "$displaySymbol${displayShippingPrice.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}


//2/1/2025
//   class CheckoutScreen extends StatefulWidget {
//     @override
//     _CheckoutScreenState createState() => _CheckoutScreenState();
//   }
//
//   class _CheckoutScreenState extends State<CheckoutScreen> {
//     late ShippingBloc _shippingBloc;
//
//     Country? _selectedApiCountryObject;
//     String? _selectedCountry;
//     List<Country> _apiCountries = [];
//     bool _areCountriesLoading = true;
//     bool _initialCountryLoadAttempted = false;
//     String? _countriesError;
//     int customerId = 0;
//     String selectedRegionCode = '';
//     bool _isSubmitting = false;
//     String? _selectedShippingMethodId;
//
//     double _subTotal = 0.0;
//
//     String? _selectedState;
//     List<String> _currentStates = [];
//
//     String selectedCountryName = '';
//     String selectedCountryId = '';
//     String selectedRegionName = '';
//     String selectedRegionId = '';
//     double _cartTotalWeight = 0.0;
//
//     bool isUserLoggedIn = false;
//     double _grandTotal = 0.0;
//     int _itemsQty = 0;
//
//     String selectedShippingMethodName = '';
//     double currentShippingCost = 0.0;
//     String carrierCode = '';
//     String methodCode = '';
//     bool _isFetchingShippingMethods = false;
//
//     // Explicitly defined list to prevent TypeErrors
//     List<Map<String, dynamic>> _displayableShippingMethods = [];
//
//     final CartRepository _cartRepository = CartRepository();
//     List<Map<String, dynamic>> _fetchedCartItems = [];
//     List<Map<String, dynamic>> _fetchTotals = [];
//     bool _isCartLoading = false;
//     String? _cartError;
//
//     final TextEditingController _emailController = TextEditingController();
//     final TextEditingController _firstNameController = TextEditingController();
//     final TextEditingController _lastNameController = TextEditingController();
//     final TextEditingController _streetAddressController = TextEditingController();
//     final TextEditingController _cityController = TextEditingController();
//     final TextEditingController _zipController = TextEditingController();
//     final TextEditingController _phoneController = TextEditingController();
//
//     bool _isLoadingShippingPrefs = true;
//
//     // UI helper for "Title" (Mr/Mrs) to match the image UI
//     String _selectedTitle = 'Mr';
//
//     bool get _isPageLoading =>
//         _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);
//
//     // ---------------------------------------------------------------------------
//     // LOGIC METHODS (KEPT EXACTLY AS PROVIDED)
//     // ---------------------------------------------------------------------------
//
//     Future<List<ShippingMethod>> fetchAvailableShippingMethods({
//       required String countryId,
//       required String regionId,
//       required String postcode,
//     }) async {
//       final prefs = await SharedPreferences.getInstance();
//       final customerToken = prefs.getString('user_token');
//       final guestQuoteId = prefs.getString('guest_quote_id');
//
//       Uri url;
//       Map<String, String> headers = {'Content-Type': 'application/json'};
//
//       if (customerToken != null && customerToken.isNotEmpty) {
//         url = Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/estimate-shipping-methods');
//         headers['Authorization'] = 'Bearer $customerToken';
//       } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//         url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId/estimate-shipping-methods');
//       } else {
//         throw Exception("No active session found to estimate shipping.");
//       }
//
//       final payload = {
//         "address": {
//           "country_id": countryId,
//           "region_id": int.tryParse(regionId) ?? 0,
//           "postcode": postcode,
//           "city": _cityController.text,
//           "street": [_streetAddressController.text],
//         }
//       };
//
//       final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
//       final response = await client.post(url, headers: headers, body: json.encode(payload));
//
//       if (response.statusCode == 200) {
//         final List<dynamic> responseData = json.decode(response.body);
//         return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
//       } else {
//         final errorBody = json.decode(response.body);
//         throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
//       }
//     }
//
//     Future<void> _fetchCartDataAndCalculateTotals() async {
//       if (!mounted) return;
//       setState(() => _isCartLoading = true);
//       try {
//         final items = await _cartRepository.getCartItems();
//         if (!mounted) return;
//
//         double calculatedSubtotal = 0.0;
//         int calculatedQty = 0;
//         for (var item in items) {
//           final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//           final qty = (item['qty'] as num?)?.toInt() ?? 0;
//           calculatedSubtotal += (price * qty);
//           calculatedQty += qty;
//         }
//
//         setState(() {
//           _subTotal = calculatedSubtotal;
//           _itemsQty = calculatedQty;
//           _isCartLoading = false;
//         });
//       } catch (e) {
//         if (!mounted) return;
//         setState(() {
//           _cartError = e.toString();
//           _isCartLoading = false;
//         });
//       }
//     }
//
//     Future<void> _triggerShippingMethodUpdate() async {
//       if (selectedCountryId.isEmpty) return;
//       if (!mounted) return;
//       setState(() {
//         _isFetchingShippingMethods = true;
//       });
//
//       try {
//         final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
//           countryId: selectedCountryId,
//           regionId: selectedRegionId,
//           postcode: _zipController.text,
//         );
//
//         if (!mounted) return;
//
//         if (fetchedMethods.isEmpty) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("No shipping methods available for this address.")),
//           );
//           setState(() {
//             _displayableShippingMethods = [];
//             _selectedShippingMethodId = null;
//             _isFetchingShippingMethods = false;
//           });
//           return;
//         }
//
//         // Explicit <String, dynamic> cast here fixes the inference issue
//         final List<Map<String, dynamic>> newUiMethods = fetchedMethods.map((method) {
//           return <String, dynamic>{
//             'id': '${method.carrierCode}_${method.methodCode}',
//             'price_str': '₹${method.amount.toStringAsFixed(2)}',
//             'price_val': method.amount,
//             'title': method.methodTitle,
//             'carrier': method.carrierTitle,
//             'carrier_code': method.carrierCode,
//             'method_code': method.methodCode,
//           };
//         }).toList();
//
//         setState(() {
//           _displayableShippingMethods = newUiMethods;
//           if (_displayableShippingMethods.isNotEmpty) {
//             final firstMethod = _displayableShippingMethods.first;
//             _selectedShippingMethodId = firstMethod['id'] as String;
//             currentShippingCost = firstMethod['price_val'] as double;
//             selectedShippingMethodName = firstMethod['title'] as String;
//             carrierCode = firstMethod['carrier_code'] as String;
//             methodCode = firstMethod['method_code'] as String;
//           } else {
//             _selectedShippingMethodId = null;
//           }
//           _isFetchingShippingMethods = false;
//         });
//
//       } catch (e) {
//         if (!mounted) return;
//         if (kDebugMode) print("Error fetching shipping methods: $e");
//         setState(() {
//           _displayableShippingMethods = [];
//           _selectedShippingMethodId = null;
//           _isFetchingShippingMethods = false;
//         });
//       }
//     }
//
//     @override
//     void initState() {
//       super.initState();
//       _shippingBloc = ShippingBloc();
//       _shippingBloc.add(FetchCountries());
//       _fetchCartDataAndCalculateTotals();
//       _loadLoginStatus();
//       _fetchAndPrintCartItemsDirectly();
//       _callAndProcessFetchTotal();
//     }
//
//     Future<void> _loadShippingPreferencesForCheckout() async {
//       if (!mounted) return;
//       setState(() {
//         _isLoadingShippingPrefs = true;
//       });
//
//       final prefs = await SharedPreferences.getInstance();
//       final String? countryNameFromPrefs = prefs.getString('selected_country_name');
//       final String? countryIdFromPrefs = prefs.getString('selected_country_id');
//       final String? regionNameFromPrefs = prefs.getString('selected_region_name');
//       final String? regionIdFromPrefs = prefs.getString('selected_region_id');
//       final double? shippingPriceFromPrefs = prefs.getDouble('shipping_price');
//       final String? shippingMethodNameFromPrefs = prefs.getString('method_name');
//       final String? carrierCodeFromPrefs = prefs.getString('carrier_code');
//       final String? methodCodeFromPrefs = prefs.getString('method_code');
//
//       Country? resolvedApiCountry;
//
//       if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
//         try {
//           resolvedApiCountry = _apiCountries.firstWhere(
//                   (c) => c.fullNameEnglish == countryNameFromPrefs || (countryIdFromPrefs != null && c.id == countryIdFromPrefs)
//           );
//         } catch (e) {
//           resolvedApiCountry = null;
//         }
//       }
//
//       if (resolvedApiCountry == null && _selectedApiCountryObject != null && _apiCountries.isNotEmpty) {
//         try {
//           resolvedApiCountry = _apiCountries.firstWhere((c) => c.id == _selectedApiCountryObject!.id);
//         } catch (e) {
//           resolvedApiCountry = null;
//         }
//       }
//
//       if (resolvedApiCountry == null && _apiCountries.isNotEmpty) {
//         resolvedApiCountry = _apiCountries.first;
//       }
//
//       List<String> newCurrentStatesList = [];
//       List<Region> regionsForResolvedCountry = [];
//       String finalSelectedCountryDropDownName = _selectedCountry ?? '';
//       String finalSelectedCountryId = selectedCountryId;
//       String finalSelectedCountryFullName = selectedCountryName;
//
//       if (resolvedApiCountry != null) {
//         _selectedApiCountryObject = resolvedApiCountry;
//         finalSelectedCountryDropDownName = resolvedApiCountry.fullNameEnglish;
//         finalSelectedCountryId = resolvedApiCountry.id;
//         finalSelectedCountryFullName = resolvedApiCountry.fullNameEnglish;
//         regionsForResolvedCountry = resolvedApiCountry.regions;
//         newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
//       } else if (_apiCountries.isEmpty && countryNameFromPrefs != null) {
//         finalSelectedCountryDropDownName = countryNameFromPrefs;
//         finalSelectedCountryId = countryIdFromPrefs ?? '';
//         finalSelectedCountryFullName = countryNameFromPrefs;
//         _selectedApiCountryObject = null;
//       } else {
//         _selectedApiCountryObject = null;
//       }
//
//       String? finalSelectedStateDropDownName = _selectedState;
//       String finalSelectedRegionStoredId = selectedRegionId;
//       String finalSelectedRegionStoredName = selectedRegionName;
//
//       if (regionNameFromPrefs != null && regionsForResolvedCountry.isNotEmpty) {
//         Region? matchedRegionFromPrefs;
//         try {
//           matchedRegionFromPrefs = regionsForResolvedCountry.firstWhere(
//                   (r) => r.name == regionNameFromPrefs || (regionIdFromPrefs != null && r.id == regionIdFromPrefs)
//           );
//         } catch (e) { matchedRegionFromPrefs = null; }
//
//         if (matchedRegionFromPrefs != null) {
//           finalSelectedStateDropDownName = matchedRegionFromPrefs.name;
//           finalSelectedRegionStoredId = matchedRegionFromPrefs.id;
//           finalSelectedRegionStoredName = matchedRegionFromPrefs.name;
//         } else {
//           if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
//             finalSelectedStateDropDownName = null;
//             finalSelectedRegionStoredId = '';
//             finalSelectedRegionStoredName = '';
//           }
//         }
//       }
//
//       double loadedShippingCost = 0.0;
//       String loadedShippingMethodName = '';
//       String? loadedSelectedShippingId;
//       String loadedCarrierCode = '';
//       String loadedMethodCode = '';
//
//       if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
//         loadedShippingCost = shippingPriceFromPrefs;
//         loadedShippingMethodName = shippingMethodNameFromPrefs;
//         loadedSelectedShippingId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
//         loadedCarrierCode = carrierCodeFromPrefs;
//         loadedMethodCode = methodCodeFromPrefs;
//       }
//
//       if (!mounted) return;
//       setState(() {
//         _selectedCountry = finalSelectedCountryDropDownName.isNotEmpty ? finalSelectedCountryDropDownName : null;
//         this.selectedCountryId = finalSelectedCountryId;
//         this.selectedCountryName = finalSelectedCountryFullName;
//
//         _currentStates = newCurrentStatesList;
//         _selectedState = finalSelectedStateDropDownName;
//
//         this.selectedRegionName = finalSelectedRegionStoredName;
//         this.selectedRegionId = finalSelectedRegionStoredId;
//
//         currentShippingCost = loadedShippingCost;
//         selectedShippingMethodName = loadedShippingMethodName;
//         _selectedShippingMethodId = loadedSelectedShippingId;
//         carrierCode = loadedCarrierCode;
//         methodCode = loadedMethodCode;
//
//         _isLoadingShippingPrefs = false;
//       });
//
//       _triggerShippingMethodUpdate();
//     }
//
//     Future<void> _callAndProcessFetchTotal() async {
//       if (!mounted) return;
//       setState(() { _isCartLoading = true; _cartError = null; });
//       try {
//         final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
//         if (!mounted) return;
//         if (totalsObject != null) {
//           double foundSubtotal = 0.0;
//           if (totalsObject['total_segments'] is List) {
//             try {
//               final subtotalSegment = (totalsObject['total_segments'] as List)
//                   .firstWhere((segment) => segment['code'] == 'subtotal');
//               foundSubtotal = (subtotalSegment['value'] as num?)?.toDouble() ?? 0.0;
//             } catch (e) {
//               foundSubtotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//             }
//           }
//
//           setState(() {
//             _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//             _subTotal = foundSubtotal;
//             _itemsQty = totalsObject['items_qty'] as int? ?? 0;
//
//             if (totalsObject['total_segments'] is List) {
//               _fetchTotals = (totalsObject['total_segments'] as List)
//                   .map((segment) => segment as Map<String, dynamic>)
//                   .toList();
//             } else { _fetchTotals = []; }
//             _isCartLoading = false;
//           });
//         }
//       } catch (e) {
//         if (!mounted) return;
//         setState(() {
//           _cartError = e.toString(); _isCartLoading = false;
//         });
//       }
//     }
//
//     Future<Map<String, dynamic>?> _performFetchTotalApiCallModified() async {
//       final prefs = await SharedPreferences.getInstance();
//       final customerToken = prefs.getString('user_token');
//
//       if (customerToken == null || customerToken.isEmpty) {
//         return Future.value({'grand_total': 0.0, 'items_qty': 0, 'total_segments': []});
//       }
//
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       try {
//         final response = await ioClient.get(
//           Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/totals'),
//           headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
//         );
//         if (response.statusCode == 200) {
//           return json.decode(response.body) as Map<String, dynamic>;
//         } else {
//           throw Exception("Failed to fetch totals");
//         }
//       } finally { ioClient.close(); }
//     }
//
//     Future<void> _fetchAndPrintCartItemsDirectly() async {
//       if (!mounted) return;
//       try {
//         final items = await _cartRepository.getCartItems();
//         if (!mounted) return;
//         setState(() { _fetchedCartItems = items; });
//       } catch (e) {
//         if (!mounted) return;
//         setState(() { _cartError = (_cartError ?? "") + " Cart items error: " + e.toString(); _fetchedCartItems = []; });
//       }
//     }
//
//     Future<void> _loadLoginStatus() async {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() { isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false; });
//     }
//
//     void _onCountryChanged(String? newCountryName) {
//       if (newCountryName == null || newCountryName == _selectedCountry) return;
//
//       Country? newSelectedApiCountry;
//       try {
//         newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
//       } catch (e) {
//         return;
//       }
//
//       setState(() {
//         _selectedApiCountryObject = newSelectedApiCountry;
//         _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
//         selectedCountryName = newSelectedApiCountry.fullNameEnglish;
//         selectedCountryId = newSelectedApiCountry.id;
//
//         final stateNames = newSelectedApiCountry.regions.map((r) => r.name).toList();
//         stateNames.sort();
//         _currentStates = stateNames;
//
//         _selectedState = null;
//         selectedRegionName = '';
//         selectedRegionId = '';
//         _displayableShippingMethods = [];
//         _selectedShippingMethodId = null;
//         _isFetchingShippingMethods = false;
//       });
//       _triggerShippingMethodUpdate();
//     }
//
//     Future<void> _saveCurrentSelectionsToPrefs() async {
//       if (selectedCountryName.isEmpty) return;
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('selected_country_name', selectedCountryName);
//       await prefs.setString('selected_country_id', selectedCountryId);
//
//       if (selectedRegionName.isNotEmpty) {
//         await prefs.setString('selected_region_name', selectedRegionName);
//         await prefs.setString('selected_region_id', selectedRegionId);
//       } else {
//         await prefs.remove('selected_region_name');
//         await prefs.remove('selected_region_id');
//       }
//       await prefs.setDouble('shipping_price', currentShippingCost);
//       await prefs.setString('shipping_method_name', selectedShippingMethodName);
//       await prefs.setString('shipping_carrier_code', carrierCode);
//       await prefs.setString('shipping_method_code', methodCode);
//     }
//
//     @override
//     void dispose() {
//       _shippingBloc.close();
//       _emailController.dispose();
//       _firstNameController.dispose();
//       _lastNameController.dispose();
//       _streetAddressController.dispose();
//       _cityController.dispose();
//       _zipController.dispose();
//       _phoneController.dispose();
//       super.dispose();
//     }
//
//     // ---------------------------------------------------------------------------
//     // NEW UI WIDGETS START HERE
//     // ---------------------------------------------------------------------------
//
//     @override
//     Widget build(BuildContext context) {
//       // 1. Get Currency State for Bottom Bar
//       final currencyState = context.watch<CurrencyBloc>().state;
//       String displaySymbol = '₹';
//       double displaySubtotal = _subTotal;
//
//       if (currencyState is CurrencyLoaded) {
//         displaySymbol = currencyState.selectedSymbol;
//         displaySubtotal = _subTotal * currencyState.selectedRate.rate;
//       }
//
//       return BlocProvider.value(
//         value: _shippingBloc,
//         child: BlocListener<ShippingBloc, ShippingState>(
//           listener: (context, state) async {
//             if (!mounted) return;
//
//             if (state is CountriesLoading) {
//               setState(() {
//                 _areCountriesLoading = true;
//                 _countriesError = null;
//               });
//             } else if (state is CountriesLoaded) {
//               _apiCountries = state.countries;
//               _areCountriesLoading = false;
//               _initialCountryLoadAttempted = true;
//               _countriesError = null;
//               _loadShippingPreferencesForCheckout();
//             } else if (state is ShippingError) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//               );
//             } else if (state is ShippingInfoSubmittedSuccessfully) {
//               final countryId = state.billingAddress['country_id'] as String? ?? '';
//               final PaymentGatewayType gateway;
//
//               if (countryId.toUpperCase() == 'IN') {
//                 gateway = PaymentGatewayType.payu;
//               } else {
//                 gateway = PaymentGatewayType.stripe;
//               }
//               final prefs = await SharedPreferences.getInstance();
//               final savedEmail = prefs.getString('user_email');
//
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => BlocProvider.value(
//                     value: _shippingBloc,
//                     child: PaymentScreen(
//                         paymentMethods: state.paymentMethods,
//                         totals: state.totals,
//                         billingAddress: state.billingAddress,
//                         selectedGateway: gateway,
//                         guestEmail: savedEmail
//                     ),
//                   ),
//                 ),
//               );
//             }
//           },
//           child: Scaffold(
//             backgroundColor: Colors.white,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               centerTitle: true,
//               title: const Text('Purchase', style: TextStyle(color: Colors.black, fontFamily: 'Serif', fontSize: 24)),
//               leading: IconButton(
//                 icon: Icon(Platform.isIOS ? Icons.close : Icons.close, color: Colors.black),
//                 onPressed: () {
//                   if (Navigator.canPop(context)) Navigator.pop(context);
//                   else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//                 },
//               ),
//             ),
//             body: Column(
//               children: [
//                 _buildStepper(),
//                 Expanded(
//                   child: _isPageLoading
//                       ? const Center(child: CircularProgressIndicator(color: Colors.black))
//                       : SingleChildScrollView(
//                     padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
//                     child: _buildCheckoutForm(),
//                   ),
//                 ),
//                 _buildBottomSummaryBar(displaySymbol, displaySubtotal),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     Widget _buildStepper() {
//       return Container(
//         color: Colors.white,
//         padding: const EdgeInsets.only(bottom: 20),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             _buildStepItem("Shipping", "1", true),
//             _buildStepLine(),
//             _buildStepItem("Review & Pay", "2", false),
//             _buildStepLine(),
//             _buildStepItem("Complete", "3", false),
//           ],
//         ),
//       );
//     }
//
//     Widget _buildStepItem(String label, String number, bool isActive) {
//       return Column(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(color: isActive ? Colors.green[800]! : Colors.grey[300]!),
//             ),
//             child: Center(
//               child: Text(
//                 number,
//                 style: TextStyle(
//                   color: isActive ? Colors.green[800] : Colors.grey[400],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: isActive ? Colors.black : Colors.grey[500],
//               fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
//             ),
//           )
//         ],
//       );
//     }
//
//     Widget _buildStepLine() {
//       return Container(
//         width: 40,
//         height: 1,
//         color: Colors.grey[300],
//         margin: const EdgeInsets.only(bottom: 20, left: 5, right: 5),
//       );
//     }
//
//     Widget _buildCheckoutForm() {
//       final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
//       final sortedCountries = List<Country>.from(_apiCountries)
//         ..sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: <Widget>[
//           const Text(
//             'Shipping Details',
//             style: TextStyle(fontSize: 26.0, fontFamily: 'Serif', color: Colors.black87),
//           ),
//           const SizedBox(height: 20.0),
//
//           // Country Selector (Styled to look like text if possible, but keeping Dropdown logic)
//           const SizedBox(height: 10),
//           const Text("Shipping to", style: TextStyle(fontSize: 15, color: Colors.black54)),
//
//           // Kept original DropdownButtonFormField logic, but styled minimally
//           DropdownButtonFormField<String>(
//             decoration: const InputDecoration(
//               isDense: true,
//               contentPadding: EdgeInsets.zero,
//               border: InputBorder.none,
//             ),
//             icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
//             value: _selectedCountry,
//             isExpanded: true,
//             hint: const Text("Select Country"),
//             style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.w500),
//             items: sortedCountries.map((Country country) {
//               return DropdownMenuItem<String>(
//                 value: country.fullNameEnglish,
//                 child: Row(
//                   children: [
//                     // A placeholder for flag could go here
//                     Text(country.fullNameEnglish),
//                   ],
//                 ),
//               );
//             }).toList(),
//             onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
//           ),
//           const Divider(thickness: 1, color: Colors.grey),
//           const SizedBox(height: 20.0),
//
//           if (!isUserLoggedIn) ...[
//             _buildStyledTextField(
//                 label: 'Email Address',
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress
//             ),
//             const SizedBox(height: 16.0),
//           ],
//
//           // Title and First Name Row
//           Row(
//             children: [
//               Expanded(
//                 flex: 2,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Title", style: TextStyle(fontSize: 13, color: Colors.black)),
//                     const SizedBox(height: 8),
//                     Container(
//                       height: 50,
//                       padding: const EdgeInsets.symmetric(horizontal: 10),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: DropdownButtonHideUnderline(
//                         child: DropdownButton<String>(
//                           value: _selectedTitle,
//                           isExpanded: true,
//                           items: ['Mr', 'Mrs', 'Ms', 'Dr'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
//                           onChanged: (val) => setState(() => _selectedTitle = val!),
//                         ),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 15),
//               Expanded(
//                 flex: 4,
//                 child: _buildStyledTextField(label: 'First name', controller: _firstNameController),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16.0),
//
//           _buildStyledTextField(label: 'Last name', controller: _lastNameController),
//           const SizedBox(height: 16.0),
//
//           _buildStyledTextField(label: 'Address', controller: _streetAddressController),
//           // Padding(
//           //   padding: const EdgeInsets.only(top: 8.0),
//           //   child: GestureDetector(
//           //     onTap: () {
//           //       // Logic to show Address line 2 if needed
//           //     },
//           //     child: const Text("Add new line", style: TextStyle(decoration: TextDecoration.underline, color: Colors.grey)),
//           //   ),
//           // ),
//           const SizedBox(height: 16.0),
//
//           _buildStyledTextField(label: 'City', controller: _cityController),
//           const SizedBox(height: 16.0),
//
//           // State Dropdown
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text("State / Province", style: TextStyle(fontSize: 13, color: Colors.black)),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//                   border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
//                   enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
//                   focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Colors.black, width: 1)),
//                 ),
//                 value: _selectedState,
//                 hint: Text(_currentStates.isEmpty ? "Select State" : "Select State", style: TextStyle(color: Colors.grey[500])),
//                 isExpanded: true,
//                 items: _currentStates.map((String regionName) {
//                   return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
//                 }).toList(),
//                 onChanged: isStateDropdownEnabled ? (newRegionName) {
//                   if (newRegionName == null) return;
//                   setState(() {
//                     Region? selectedRegionObject;
//                     if (_selectedApiCountryObject != null) {
//                       try {
//                         selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
//                       } catch (e) { selectedRegionObject = null; }
//                     }
//                     _selectedState = newRegionName;
//                     if (selectedRegionObject != null) {
//                       selectedRegionName = selectedRegionObject.name;
//                       selectedRegionId = selectedRegionObject.id;
//                       selectedRegionCode = selectedRegionObject.code;
//                     } else {
//                       selectedRegionName = ''; selectedRegionId = ''; selectedRegionCode = '';
//                     }
//                   });
//                   _triggerShippingMethodUpdate();
//                 } : null,
//               ),
//             ],
//           ),
//           const SizedBox(height: 16.0),
//
//           _buildStyledTextField(
//               label: 'Zip / Postal Code',
//               controller: _zipController,
//               keyboardType: TextInputType.number,
//               onEditingComplete: _triggerShippingMethodUpdate
//           ),
//           const SizedBox(height: 16.0),
//
//           _buildStyledTextField(label: 'Phone Number', controller: _phoneController, keyboardType: TextInputType.phone),
//           const SizedBox(height: 30.0),
//
//           BlocBuilder<ShippingBloc, ShippingState>(
//               builder: (context, blocState) {
//                 return _buildShippingMethodsSection(blocState);
//               }
//           ),
//           const SizedBox(height: 40.0),
//         ],
//       );
//     }
//
//     Widget _buildStyledTextField({
//       required String label,
//       required TextEditingController? controller,
//       TextInputType? keyboardType,
//       void Function()? onEditingComplete
//     }) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 13, color: Colors.black)),
//           const SizedBox(height: 8),
//           TextField(
//             controller: controller,
//             keyboardType: keyboardType,
//             onEditingComplete: onEditingComplete,
//             decoration: InputDecoration(
//               isDense: true,
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
//               border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
//               enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[300]!)),
//               focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: const BorderSide(color: Colors.black, width: 1)),
//             ),
//             style: const TextStyle(fontSize: 15),
//           )
//         ],
//       );
//     }
//
//     Widget _buildBottomSummaryBar(String symbol, double total) {
//       return Container(
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             border: Border(top: BorderSide(color: Colors.grey[200]!)),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
//         ),
//         child: SafeArea(
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   const Text("TOTAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
//                   Text("$symbol${total.toStringAsFixed(0)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               BlocBuilder<ShippingBloc, ShippingState>(
//                 builder: (context, state) {
//                   final isSubmitting = state is ShippingInfoSubmitting;
//                   return ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
//                     ),
//                     // If submitting, disable button. Otherwise call _submitForm
//                     onPressed: isSubmitting ? null : _submitForm,
//                     child: isSubmitting
//                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                         : const Text("NEXT"),
//                   );
//                 },
//               )
//             ],
//           ),
//         ),
//       );
//     }
//
//     // EXACT VALIDATION AND LOGIC FROM ORIGINAL CODE
//     void _submitForm() async {
//       // 1. Validation: Ensure all fields are filled
//       if (_firstNameController.text.isEmpty ||
//           _lastNameController.text.isEmpty ||
//           _streetAddressController.text.isEmpty ||
//           _cityController.text.isEmpty ||
//           _zipController.text.isEmpty ||
//           _phoneController.text.isEmpty ||
//           selectedCountryId.isEmpty
//       ) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields.')));
//         return;
//       }
//
//       // 2. Validation: Ensure a shipping method is actually selected
//       // We check if we have methods and if an ID is selected
//       if (_displayableShippingMethods.isEmpty || _selectedShippingMethodId == null) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a shipping method first.')));
//         return;
//       }
//
//       // Safety check: ensure the selected ID actually exists in the current list
//       // Cast the list explicitly to avoid the Type error you saw previously
//       final displayList = _displayableShippingMethods.cast<Map<String, dynamic>>();
//       final determinedShippingMethod = displayList.firstWhere(
//             (m) => m['id'] == _selectedShippingMethodId,
//         orElse: () => <String, dynamic>{},
//       );
//
//       if (determinedShippingMethod.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid shipping method selected. Please select again.')));
//         return;
//       }
//
//       // 3. Save selections
//       await _saveCurrentSelectionsToPrefs();
//
//       final prefs = await SharedPreferences.getInstance();
//       final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
//       final finalMethodCode = prefs.getString('method_code') ?? methodCode;
//
//       // Handle Email
//       final enteredEmail = _emailController.text.isNotEmpty ? _emailController.text.trim() : 'mitesh@gmail.com';
//       await prefs.setString('user_email', enteredEmail);
//
//       // 4. Debug Print
//       if (kDebugMode) {
//         print("--- ✅ SUBMITTING SHIPPING INFO ---");
//         print("Email: $enteredEmail");
//         print("Carrier: $finalCarrierCode, Method: $finalMethodCode");
//       }
//
//       // 5. Trigger Bloc Event - ✅ FIX: Use _shippingBloc directly
//       _shippingBloc.add(
//         SubmitShippingInfo(
//           firstName: _firstNameController.text,
//           lastName: _lastNameController.text,
//           streetAddress: _streetAddressController.text,
//           city: _cityController.text,
//           zipCode: _zipController.text,
//           phone: _phoneController.text,
//           email: enteredEmail,
//           countryId: selectedCountryId,
//           regionName: selectedRegionName,
//           regionId: selectedRegionId,
//           regionCode: selectedRegionCode,
//           carrierCode: finalCarrierCode,
//           methodCode: finalMethodCode,
//         ),
//       );
//     }
//     // Restored Shipping Table Logic + Radio Button interactivity
//     Widget _buildShippingMethodsSection(ShippingState state) {
//       if (_isFetchingShippingMethods) {
//         return const Padding(
//           padding: EdgeInsets.symmetric(vertical: 20),
//           child: Center(child: Text("Estimating shipping...")),
//         );
//       }
//
//       if (_displayableShippingMethods.isEmpty) return const SizedBox.shrink();
//
//       final currencyState = context.watch<CurrencyBloc>().state;
//       String displaySymbol = '₹';
//       double exchangeRate = 1.0;
//       if (currencyState is CurrencyLoaded) {
//         displaySymbol = currencyState.selectedSymbol;
//         exchangeRate = currencyState.selectedRate.rate;
//       }
//
//       // Cast to correct type
//       final displayList = _displayableShippingMethods.cast<Map<String, dynamic>>();
//
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Shipping Method", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 10),
//
//           ...displayList.map((method) {
//             final double baseShippingPrice = method['price_val'] as double;
//             final double displayShippingPrice = baseShippingPrice * exchangeRate;
//             final bool isSelected = method['id'] == _selectedShippingMethodId;
//
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _selectedShippingMethodId = method['id'] as String;
//                   currentShippingCost = method['price_val'] as double;
//                   selectedShippingMethodName = method['title'] as String;
//                   carrierCode = method['carrier_code'] as String;
//                   methodCode = method['method_code'] as String;
//                 });
//               },
//               child: Container(
//                 margin: const EdgeInsets.only(bottom: 10),
//                 decoration: BoxDecoration(
//                   color: isSelected ? Colors.grey[50] : Colors.white,
//                   border: Border.all(
//                       color: isSelected ? Colors.black : Colors.grey[300]!,
//                       width: isSelected ? 1.5 : 1.0
//                   ),
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   children: [
//                     Radio<String>(
//                       value: method['id'] as String,
//                       groupValue: _selectedShippingMethodId,
//                       activeColor: Colors.black,
//                       onChanged: (String? value) {
//                         if (value != null) {
//                           setState(() {
//                             _selectedShippingMethodId = value;
//                             currentShippingCost = method['price_val'] as double;
//                             selectedShippingMethodName = method['title'] as String;
//                             carrierCode = method['carrier_code'] as String;
//                             methodCode = method['method_code'] as String;
//                           });
//                         }
//                       },
//                     ),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(method['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
//                           Text(method['carrier'], style: const TextStyle(fontSize: 12, color: Colors.grey)),
//                         ],
//                       ),
//                     ),
//                     Text(
//                         "$displaySymbol${displayShippingPrice.toStringAsFixed(2)}",
//                         style: const TextStyle(fontWeight: FontWeight.bold)
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       );
//     }
//   }

//10/12/2025
// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late ShippingBloc _shippingBloc;
//
//   Country? _selectedApiCountryObject;
//   String? _selectedCountry;
//   List<Country> _apiCountries = [];
//   bool _areCountriesLoading = true;
//   bool _initialCountryLoadAttempted = false;
//   String? _countriesError;
//   int customerId=0;
//   String selectedRegionCode= '';
//   bool _isSubmitting = false;
//   String? _selectedShippingMethodId;
//
//   double _subTotal = 0.0;
//
//   String? _selectedState;
//   List<String> _currentStates = [];
//
//   String selectedCountryName = '';
//   String selectedCountryId = '';
//   String selectedRegionName = '';
//   String selectedRegionId = '';
//   double _cartTotalWeight = 0.0;
//
//   bool isUserLoggedIn = false;
//   double _grandTotal = 0.0;
//   int _itemsQty = 0;
//
//   String selectedShippingMethodName = '';
//   double currentShippingCost = 0.0;
//   String carrierCode = '';
//   String methodCode = '';
//   bool _isFetchingShippingMethods = false;
//
//
//   // This will be our live list for UI and updates
//   List<Map<String, dynamic>> _displayableShippingMethods = [];
//
//   final CartRepository _cartRepository = CartRepository();
//   List<Map<String, dynamic>> _fetchedCartItems = [];
//   List<Map<String, dynamic>> _fetchTotals = [];
//   bool _isCartLoading = false;
//   String? _cartError;
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   bool _isLoadingShippingPrefs = true;
//
//   bool get _isPageLoading => _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);
//
//
//   Future<List<ShippingMethod>> fetchAvailableShippingMethods({
//     required String countryId,
//     required String regionId,
//     required String postcode,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     Uri url;
//     Map<String, String> headers = {'Content-Type': 'application/json'};
//     String sessionType;
//
//     // This if/else correctly selects the API endpoint for the current session.
//     if (customerToken != null && customerToken.isNotEmpty) {
//       sessionType = "LOGGED-IN";
//       url = Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/estimate-shipping-methods');
//       headers['Authorization'] = 'Bearer $customerToken';
//     } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       sessionType = "GUEST";
//       // This is the standard Magento guest endpoint.
//       url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId/estimate-shipping-methods');
//     } else {
//       throw Exception("No active session found to estimate shipping.");
//     }
//
//     // A complete address is required for accurate shipping.
//     final payload = {
//       "address": {
//         "country_id": countryId,
//         "region_id": int.tryParse(regionId) ?? 0,
//         "postcode": postcode,
//         // Optional: Include other fields if your shipping methods need them.
//         "city": _cityController.text,
//         "street": [_streetAddressController.text],
//       }
//     };
//
//     final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
//
//     if (kDebugMode) {
//       print("--- Shipping Estimate Request ($sessionType) ---");
//       print("URL: $url");
//       print("Body: ${json.encode(payload)}");
//     }
//
//     final response = await client.post(url, headers: headers, body: json.encode(payload));
//
//     if (kDebugMode) {
//       print("Shipping Estimate Response: ${response.statusCode}, ${response.body}");
//     }
//
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
//     } else {
//       final errorBody = json.decode(response.body);
//       throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
//     }
//   }
//
//   // The new shipping method fetcher.
//   // Future<List<ShippingMethod>> fetchAvailableShippingMethods({
//   //   required String countryId,
//   //   required String regionId,
//   //   required String postcode,
//   // }) async {
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final customerToken = prefs.getString('user_token');
//   //
//   //   if (customerToken == null || customerToken.isEmpty) {
//   //     throw Exception("User not logged in");
//   //   }
//   //
//   //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');
//   //
//   //   final payload = {
//   //     "address": {
//   //       "country_id": countryId,
//   //       "region_id": int.tryParse(regionId) ?? 0, // Handles empty regionId
//   //       "postcode": postcode.isNotEmpty ? postcode : "00000", // Use a placeholder if empty
//   //       "city": _cityController.text.isNotEmpty ? _cityController.text : "Placeholder",
//   //       "street": [_streetAddressController.text.isNotEmpty ? _streetAddressController.text : "Placeholder"],
//   //       "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
//   //       "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
//   //       "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
//   //     }
//   //   };
//   //
//   //   HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//   //   IOClient ioClient = IOClient(httpClient);
//   //
//   //   final response = await ioClient.post(
//   //     url,
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //       'Authorization': 'Bearer $customerToken',
//   //     },
//   //     body: json.encode(payload),
//   //   );
//   //
//   //   if (kDebugMode) {
//   //     print("Shipping Estimation Payload: ${json.encode(payload)}");
//   //     print("Standard Shipping API Response: ${response.body}");
//   //   }
//   //
//   //
//   //   if (response.statusCode == 200) {
//   //     final List<dynamic> responseData = json.decode(response.body);
//   //     return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
//   //   } else {
//   //     final errorBody = json.decode(response.body);
//   //     throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
//   //   }
//   // }
//
//
//   Future<void> _fetchCartData() async {
//     if (!mounted) return;
//     setState(() => _isCartLoading = true);
//     final cartRepo = CartRepository();
//     try {
//       final items = await cartRepo.getCartItems();
//       if (!mounted) return;
//
//       double calculatedSubtotal = 0.0;
//       int calculatedQty = 0;
//       for (var item in items) {
//         final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//         final qty = (item['qty'] as num?)?.toInt() ?? 0;
//         calculatedSubtotal += (price * qty);
//         calculatedQty += qty;
//       }
//
//       setState(() {
//         _subTotal = calculatedSubtotal;
//         _itemsQty = calculatedQty;
//         _isCartLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _cartError = e.toString();
//         _isCartLoading = false;
//       });
//     }
//   }
//
//
//   Future<void> _fetchCartDataAndCalculateTotals() async {
//     if (!mounted) return;
//     setState(() => _isCartLoading = true);
//     try {
//       // This method in your repository already works for both users.
//       final items = await _cartRepository.getCartItems();
//       if (!mounted) return;
//
//       double calculatedSubtotal = 0.0;
//       int calculatedQty = 0;
//       for (var item in items) {
//         final price = (item['price'] as num?)?.toDouble() ?? 0.0;
//         final qty = (item['qty'] as num?)?.toInt() ?? 0;
//         calculatedSubtotal += (price * qty);
//         calculatedQty += qty;
//       }
//
//       setState(() {
//         _subTotal = calculatedSubtotal;
//         _itemsQty = calculatedQty;
//         _isCartLoading = false;
//       });
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _cartError = e.toString();
//         _isCartLoading = false;
//       });
//     }
//   }
//
//   // ✅ MODIFIED: Central function to trigger shipping updates. Now only requires a country.
//   Future<void> _triggerShippingMethodUpdate() async {
//     // 1. Validate that we have at least a country.
//     if (selectedCountryId.isEmpty) {
//       if (kDebugMode) {
//         print("Skipping shipping fetch: Country is missing.");
//       }
//       return;
//     }
//
//     // 2. Show a loading indicator in the UI.
//     if(!mounted) return;
//     setState(() {
//       _isFetchingShippingMethods = true;
//     });
//
//     try {
//       // 3. Call the API fetcher function with available data. It will use placeholders for missing info.
//       final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
//         countryId: selectedCountryId,
//         regionId: selectedRegionId,
//         postcode: _zipController.text,
//       );
//
//       if(!mounted) return;
//
//       if (fetchedMethods.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No shipping methods available for this address.")),
//         );
//         setState(() {
//           _displayableShippingMethods = [];
//           _selectedShippingMethodId = null;
//           _isFetchingShippingMethods = false;
//         });
//         return;
//       }
//
//       // 4. Transform the API response into the format your UI table expects.
//       final newUiMethods = fetchedMethods.map((method) {
//         return {
//           'id': '${method.carrierCode}_${method.methodCode}', // A unique ID
//           'price_str': '₹${method.amount.toStringAsFixed(2)}',
//           'price_val': method.amount,
//           'title': method.methodTitle,
//           'carrier': method.carrierTitle,
//           'carrier_code': method.carrierCode,
//           'method_code': method.methodCode,
//         };
//       }).toList();
//
//       // 5. Update the state to display the new methods.
//       setState(() {
//         _displayableShippingMethods = newUiMethods;
//
//         if (_displayableShippingMethods.isNotEmpty) {
//           final firstMethod = _displayableShippingMethods.first;
//           _selectedShippingMethodId = firstMethod['id'] as String;
//           currentShippingCost = firstMethod['price_val'] as double;
//           selectedShippingMethodName = firstMethod['title'] as String;
//           carrierCode = firstMethod['carrier_code'] as String;
//           methodCode = firstMethod['method_code'] as String;
//         } else {
//           _selectedShippingMethodId = null;
//         }
//         _isFetchingShippingMethods = false;
//       });
//
//     } catch (e) {
//       if(!mounted) return;
//       if (kDebugMode) print("Error fetching shipping methods: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
//       );
//       // 6. Handle errors by clearing the list and hiding the loader.
//       setState(() {
//         _displayableShippingMethods = [];
//         _selectedShippingMethodId = null;
//         _isFetchingShippingMethods = false;
//       });
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _shippingBloc = ShippingBloc();
//     _shippingBloc.add(FetchCountries());
//     _fetchCartDataAndCalculateTotals();
//     _loadLoginStatus();
//     _fetchAndPrintCartItemsDirectly();
//     _callAndProcessFetchTotal();
//   }
//
//
//   Future<void> _loadShippingPreferencesForCheckout() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoadingShippingPrefs = true;
//     });
//
//     final prefs = await SharedPreferences.getInstance();
//     final String? countryNameFromPrefs = prefs.getString('selected_country_name');
//     final String? countryIdFromPrefs = prefs.getString('selected_country_id');
//     final String? regionNameFromPrefs = prefs.getString('selected_region_name');
//     final String? regionIdFromPrefs = prefs.getString('selected_region_id');
//     final double? shippingPriceFromPrefs = prefs.getDouble('shipping_price');
//     final String? shippingMethodNameFromPrefs = prefs.getString('method_name');
//     final String? carrierCodeFromPrefs = prefs.getString('carrier_code');
//     final String? methodCodeFromPrefs = prefs.getString('method_code');
//
//     if (kDebugMode) {
//       print("--- Loading Shipping Preferences (CheckoutScreen) ---");
//       print("API Countries available: ${_apiCountries.length}, Prefs Country: $countryNameFromPrefs (ID: $countryIdFromPrefs), Prefs Region: $regionNameFromPrefs (ID: $regionIdFromPrefs)");
//       print("Prefs Shipping: Method='$shippingMethodNameFromPrefs', Price='$shippingPriceFromPrefs'");
//     }
//
//     Country? resolvedApiCountry;
//
//     if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
//       try {
//         resolvedApiCountry = _apiCountries.firstWhere(
//                 (c) => c.fullNameEnglish == countryNameFromPrefs || (countryIdFromPrefs != null && c.id == countryIdFromPrefs)
//         );
//         if (kDebugMode) print("Found country from prefs in API list: ${resolvedApiCountry.fullNameEnglish}");
//       } catch (e) {
//         if (kDebugMode) print("Country from prefs ('$countryNameFromPrefs') not found in API list.");
//         resolvedApiCountry = null;
//       }
//     }
//
//     if (resolvedApiCountry == null && _selectedApiCountryObject != null && _apiCountries.isNotEmpty) {
//       try {
//         resolvedApiCountry = _apiCountries.firstWhere((c) => c.id == _selectedApiCountryObject!.id);
//         if (kDebugMode) print("Validated current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') with API list.");
//       } catch (e) {
//         if (kDebugMode) print("Current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') no longer valid in API list.");
//         resolvedApiCountry = null;
//       }
//     }
//
//     if (resolvedApiCountry == null && _apiCountries.isNotEmpty) {
//       resolvedApiCountry = _apiCountries.first;
//       if (kDebugMode) print("Defaulting to first API country: ${resolvedApiCountry.fullNameEnglish}");
//     }
//
//     List<String> newCurrentStatesList = [];
//     List<Region> regionsForResolvedCountry = [];
//     String finalSelectedCountryDropDownName = _selectedCountry ?? '';
//     String finalSelectedCountryId = selectedCountryId;
//     String finalSelectedCountryFullName = selectedCountryName;
//
//
//     if (resolvedApiCountry != null) {
//       _selectedApiCountryObject = resolvedApiCountry;
//       finalSelectedCountryDropDownName = resolvedApiCountry.fullNameEnglish;
//       finalSelectedCountryId = resolvedApiCountry.id;
//       finalSelectedCountryFullName = resolvedApiCountry.fullNameEnglish;
//       regionsForResolvedCountry = resolvedApiCountry.regions;
//       newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
//     } else if (_apiCountries.isEmpty && countryNameFromPrefs != null) {
//       finalSelectedCountryDropDownName = countryNameFromPrefs;
//       finalSelectedCountryId = countryIdFromPrefs ?? '';
//       finalSelectedCountryFullName = countryNameFromPrefs;
//       _selectedApiCountryObject = null;
//       if (kDebugMode) print("API countries empty. Using country from prefs: $finalSelectedCountryFullName. Regions will be empty.");
//     } else {
//       if (_selectedApiCountryObject != null && _selectedApiCountryObject!.fullNameEnglish == _selectedCountry) {
//         regionsForResolvedCountry = _selectedApiCountryObject!.regions;
//         newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
//       } else {
//         _selectedApiCountryObject = null;
//       }
//       if (kDebugMode) print("Could not fully resolve a country with API list. Current dropdown: $_selectedCountry. Regions may be empty or based on previous valid state.");
//     }
//
//     String? finalSelectedStateDropDownName = _selectedState;
//     String finalSelectedRegionStoredId = selectedRegionId;
//     String finalSelectedRegionStoredName = selectedRegionName;
//
//
//     if (regionNameFromPrefs != null && regionsForResolvedCountry.isNotEmpty) {
//       Region? matchedRegionFromPrefs;
//       try {
//         matchedRegionFromPrefs = regionsForResolvedCountry.firstWhere(
//                 (r) => r.name == regionNameFromPrefs || (regionIdFromPrefs != null && r.id == regionIdFromPrefs)
//         );
//       } catch (e) { matchedRegionFromPrefs = null; }
//
//       if (matchedRegionFromPrefs != null) {
//         finalSelectedStateDropDownName = matchedRegionFromPrefs.name;
//         finalSelectedRegionStoredId = matchedRegionFromPrefs.id;
//         finalSelectedRegionStoredName = matchedRegionFromPrefs.name;
//         if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') matched: ${matchedRegionFromPrefs.name} (ID: ${matchedRegionFromPrefs.id})");
//       } else {
//         if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') not found in available regions for $finalSelectedCountryFullName.");
//         if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
//           finalSelectedStateDropDownName = null;
//           finalSelectedRegionStoredId = '';
//           finalSelectedRegionStoredName = '';
//           if (kDebugMode) print("Resetting selected state as it's not in the new list of states.");
//         }
//       }
//     } else if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
//       finalSelectedStateDropDownName = null;
//       finalSelectedRegionStoredId = '';
//       finalSelectedRegionStoredName = '';
//       if (kDebugMode) print("Current _selectedState ('$_selectedState') is invalid for the determined country's regions. Resetting.");
//     }
//
//     double loadedShippingCost = 0.0;
//     String loadedShippingMethodName = '';
//     String? loadedSelectedShippingId;
//     String loadedCarrierCode = '';
//     String loadedMethodCode = '';
//
//     if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
//       loadedShippingCost = shippingPriceFromPrefs;
//       loadedShippingMethodName = shippingMethodNameFromPrefs;
//       loadedSelectedShippingId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
//       loadedCarrierCode = carrierCodeFromPrefs;
//       loadedMethodCode = methodCodeFromPrefs;
//     }
//
//     if (!mounted) return;
//     setState(() {
//       _selectedCountry = finalSelectedCountryDropDownName.isNotEmpty ? finalSelectedCountryDropDownName : null;
//       this.selectedCountryId = finalSelectedCountryId;
//       this.selectedCountryName = finalSelectedCountryFullName;
//
//       _currentStates = newCurrentStatesList;
//       _selectedState = finalSelectedStateDropDownName;
//
//       this.selectedRegionName = finalSelectedRegionStoredName;
//       this.selectedRegionId = finalSelectedRegionStoredId;
//
//       currentShippingCost = loadedShippingCost;
//       selectedShippingMethodName = loadedShippingMethodName;
//       _selectedShippingMethodId = loadedSelectedShippingId;
//       carrierCode = loadedCarrierCode;
//       methodCode = loadedMethodCode;
//
//       _isLoadingShippingPrefs = false;
//
//       if (kDebugMode) {
//         print("--- setState COMPLETE (Prefs Loading) ---");
//         print("Final _selectedShippingMethodId: $_selectedShippingMethodId");
//       }
//     });
//
//     // ✅ ADDED: Trigger shipping fetch after preferences are loaded.
//     _triggerShippingMethodUpdate();
//   }
//
//
//   Future<void> _callAndProcessFetchTotal() async {
//     if (!mounted) return;
//     setState(() { _isCartLoading = true; _cartError = null; });
//     try {
//       final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
//       if (!mounted) return;
//       if (totalsObject != null) {
//         // Find the subtotal from the total_segments array
//         double foundSubtotal = 0.0;
//         if (totalsObject['total_segments'] is List) {
//           try {
//             final subtotalSegment = (totalsObject['total_segments'] as List)
//                 .firstWhere((segment) => segment['code'] == 'subtotal');
//             foundSubtotal = (subtotalSegment['value'] as num?)?.toDouble() ?? 0.0;
//           } catch (e) {
//             if (kDebugMode) print("Subtotal segment not found. Defaulting to 0.");
//             // If subtotal is not found, you might want to use grand_total as a fallback
//             foundSubtotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//           }
//         }
//
//         setState(() {
//           _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//           _subTotal = foundSubtotal; // ✅ SET THE NEW SUBTOTAL VARIABLE
//           _itemsQty = totalsObject['items_qty'] as int? ?? 0;
//
//           double calculatedWeight = 0.0;
//           if (totalsObject.containsKey('items_weight') && totalsObject['items_weight'] != null) {
//             calculatedWeight = (totalsObject['items_weight'] as num).toDouble();
//           } else if (totalsObject.containsKey('weight') && totalsObject['weight'] != null) {
//             calculatedWeight = (totalsObject['weight'] as num).toDouble();
//           } else if (totalsObject['items'] is List) {
//             for (var item_data in (totalsObject['items'] as List)) {
//               if (item_data is Map<String, dynamic>) {
//                 final itemWeight = (item_data['weight'] as num?)?.toDouble() ?? 0.0;
//                 final itemQty = (item_data['qty'] as num?)?.toInt() ?? 1;
//                 calculatedWeight += (itemWeight * itemQty);
//               }
//             }
//           }
//           _cartTotalWeight = calculatedWeight;
//
//           if (kDebugMode) {
//             print("Cart total weight updated: $_cartTotalWeight");
//             print("Subtotal set to: $_subTotal"); // For debugging
//           }
//
//           if (totalsObject['total_segments'] is List) {
//             _fetchTotals = (totalsObject['total_segments'] as List)
//                 .map((segment) => segment as Map<String, dynamic>)
//                 .toList();
//           } else { _fetchTotals = []; }
//           _isCartLoading = false;
//         });
//       } else { throw Exception("Totals data received in unexpected format or user not logged in."); }
//     } catch (e) {
//       if (!mounted) return;
//       if (kDebugMode) print("Error fetching totals: $e");
//       setState(() {
//         _cartError = e.toString(); _isCartLoading = false;
//         _grandTotal = 0.0;
//         _subTotal = 0.0; // Reset on error
//         _itemsQty = 0;
//         _fetchTotals = [];
//         _cartTotalWeight = 0.0;
//       });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading totals: ${e.toString()}")));
//       }
//     }
//   }
//
//   Future<Map<String, dynamic>?> _performFetchTotalApiCallModified() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       if (kDebugMode) print("User not logged in, cannot fetch totals.");
//       return Future.value({'grand_total': 0.0, 'items_qty': 0, 'total_segments': []});
//     }
//
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.get(
//         Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/totals'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
//       );
//       if (response.statusCode == 200) {
//         final decodedBody = json.decode(response.body);
//         if (decodedBody is Map<String, dynamic>) { return decodedBody; }
//         else { throw Exception("Unexpected format for totals response. Expected Map, got: ${decodedBody.runtimeType}"); }
//       } else { throw Exception("Failed to fetch totals: Status ${response.statusCode}, Body: ${response.body}"); }
//     } finally { ioClient.close(); }
//   }
//
//   Future<void> _fetchAndPrintCartItemsDirectly() async {
//     if (!mounted) return;
//     try {
//       final items = await _cartRepository.getCartItems();
//       if (!mounted) return;
//       setState(() { _fetchedCartItems = items; });
//     } catch (e) {
//       if (!mounted) return;
//       if (kDebugMode) print("Error fetching cart items directly: $e");
//       setState(() { _cartError = (_cartError ?? "") + " Cart items error: " + e.toString(); _fetchedCartItems = []; });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading cart: ${e.toString()}")));
//       }
//     }
//   }
//
//   Future<void> _loadLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!mounted) return;
//     setState(() { isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false; });
//   }
//
//
//   // ✅ MODIFIED: Now triggers a shipping fetch immediately.
//   void _onCountryChanged(String? newCountryName) {
//     if (newCountryName == null || newCountryName == _selectedCountry) return;
//
//     Country? newSelectedApiCountry;
//     try {
//       newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
//     } catch (e) {
//       if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
//       return;
//     }
//     //live*
//     // setState(() {
//     //   _selectedApiCountryObject = newSelectedApiCountry;
//     //   _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
//     //   selectedCountryName = newSelectedApiCountry.fullNameEnglish;
//     //   selectedCountryId = newSelectedApiCountry.id;
//     //   _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();
//     //
//     //   _selectedState = null;
//     //   selectedRegionName = '';
//     //   selectedRegionId = '';
//     //   _displayableShippingMethods = [];
//     //   _selectedShippingMethodId = null;
//     //   _isFetchingShippingMethods = false;
//     // });
//
//     setState(() {
//       _selectedApiCountryObject = newSelectedApiCountry;
//       _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
//       selectedCountryName = newSelectedApiCountry.fullNameEnglish;
//       selectedCountryId = newSelectedApiCountry.id;
//
//       // ✅ Create the list of state names and then sort it
//       final stateNames = newSelectedApiCountry.regions.map((r) => r.name).toList();
//       stateNames.sort();
//       _currentStates = stateNames;
//
//       _selectedState = null;
//       selectedRegionName = '';
//       selectedRegionId = '';
//       _displayableShippingMethods = [];
//       _selectedShippingMethodId = null;
//       _isFetchingShippingMethods = false;
//     });
//     // Trigger the fetch with the new country information.
//     _triggerShippingMethodUpdate();
//   }
//
//
//   Future<void> _saveCurrentSelectionsToPrefs() async {
//     if (selectedCountryName.isEmpty) {
//       if (kDebugMode) print("Cannot save prefs: Country Name is empty.");
//       return;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_country_name', selectedCountryName);
//     await prefs.setString('selected_country_id', selectedCountryId);
//
//     if (selectedRegionName.isNotEmpty) {
//       await prefs.setString('selected_region_name', selectedRegionName);
//       await prefs.setString('selected_region_id', selectedRegionId);
//     } else {
//       await prefs.remove('selected_region_name');
//       await prefs.remove('selected_region_id');
//     }
//     await prefs.setDouble('shipping_price', currentShippingCost);
//     await prefs.setString('shipping_method_name', selectedShippingMethodName);
//     await prefs.setString('shipping_carrier_code', carrierCode);
//     await prefs.setString('shipping_method_code', methodCode);
//
//
//     if (kDebugMode) {
//       print("--- Preferences Saved (from CheckoutScreen) ---");
//       print("Saved: Country: $selectedCountryName ($selectedCountryId), Region: $selectedRegionName ($selectedRegionId)");
//       print("Saved Shipping: Method: $selectedShippingMethodName ($carrierCode/$methodCode), Cost: $currentShippingCost");
//     }
//   }
//
//   @override
//   void dispose() {
//     _shippingBloc.close();
//     _emailController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _zipController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _shippingBloc,
//       child: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) async {
//           if (!mounted) return;
//
//           if (state is CountriesLoading) {
//             setState(() {
//               _areCountriesLoading = true;
//               _countriesError = null;
//             });
//           } else if (state is CountriesLoaded) {
//             _apiCountries = state.countries;
//             _areCountriesLoading = false;
//             _initialCountryLoadAttempted = true;
//             _countriesError = null;
//             _loadShippingPreferencesForCheckout();
//           }
//           else if (state is ShippingError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//           else if (state is ShippingInfoSubmittedSuccessfully) {
//             if (kDebugMode) {
//               print("Shipping Info submitted successfully. Navigating to PaymentScreen...");
//             }
//
//             // It checks the country ID from the billing address
//             final countryId = state.billingAddress['country_id'] as String? ?? '';
//
//             final PaymentGatewayType gateway;
//
//             // The condition `countryId.toUpperCase() == 'IN'` will be TRUE
//             if (countryId.toUpperCase() == 'IN') {
//               gateway = PaymentGatewayType.payu; // PayU is selected!
//             } else {
//               gateway = PaymentGatewayType.stripe; // Stripe is selected
//             }
//             final prefs = await SharedPreferences.getInstance();
//             final savedEmail = prefs.getString('user_email');
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => BlocProvider.value(
//                   value: _shippingBloc,
//                   child: PaymentScreen(
//                     paymentMethods: state.paymentMethods,
//                     totals: state.totals,
//                     billingAddress: state.billingAddress,
//                     // ✅ YOU WERE MISSING THIS PARAMETER IN YOUR PROVIDED CODE
//                     selectedGateway: gateway,
//                       guestEmail:savedEmail
//                   ),
//                 ),
//               ),
//             );
//           }
//
//
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Checkout'),
//             leading: IconButton(
//               icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//               onPressed: () {
//                 if (Navigator.canPop(context)) Navigator.pop(context);
//                 else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//               },
//             ),
//           ),
//           backgroundColor: Colors.white,
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: _isPageLoading
//                   ? const Center(child: CircularProgressIndicator(key: ValueKey("main_page_loader")))
//                   : _buildCheckoutForm(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutForm() {
//     final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
//     final sortedCountries = List<Country>.from(_apiCountries)
//       ..sort((a, b) => a.fullNameEnglish.compareTo(b.fullNameEnglish));
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildEstimatedTotal(),
//         const SizedBox(height: 24.0),
//         const Text('Shipping Address', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87)),
//         const SizedBox(height: 20.0),
//
//         if (!isUserLoggedIn) ...[
//           _buildTextFieldWithLabel('Email Address', controller: _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
//           Padding(
//             padding: const EdgeInsets.only(top: 6.0, bottom: 16.0),
//             child: Text('You can create an account after checkout.', style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
//           ),
//           Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
//           const SizedBox(height: 16.0),
//         ],
//
//         _buildTextFieldWithLabel('First Name', controller: _firstNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Last Name', controller: _lastNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('Country', isRequired: true),
//         if (_areCountriesLoading && !_initialCountryLoadAttempted)
//           const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: CircularProgressIndicator(key: ValueKey("country_dropdown_loader"))))
//         else if (_countriesError != null && _apiCountries.isEmpty)
//           Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("Error: $_countriesError", style: const TextStyle(color: Colors.red)))
//         else if (_apiCountries.isEmpty && _initialCountryLoadAttempted)
//             Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("No countries available.", style: TextStyle(color: Colors.grey[700])))
//           else
//
//     DropdownButtonFormField<String>(
//     decoration: InputDecoration(
//     border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//     contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//     ),
//     value: _selectedCountry,
//     isExpanded: true,
//     hint: const Text("Select Country"),
//     items: sortedCountries.map((Country country) {
//     return DropdownMenuItem<String>(
//     value: country.fullNameEnglish,
//     child: Text(country.fullNameEnglish),
//     );
//     }).toList(),
//     onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
//     ),
//             // DropdownButtonFormField<String>(
//             //   decoration: InputDecoration(
//             //     border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             //     enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             //     focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//             //     contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//             //   ),
//             //   value: _selectedCountry,
//             //   isExpanded: true,
//             //   hint: const Text("Select Country"),
//             //   items: _apiCountries.map((Country country) {
//             //     return DropdownMenuItem<String>(
//             //       value: country.fullNameEnglish,
//             //       child: Text(country.fullNameEnglish),
//             //     );
//             //   }).toList(),
//             //   onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
//             // ),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('State/Province', isRequired: true),
//         DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//           ),
//           value: _selectedState,
//           hint: Text(
//               _selectedCountry == null || _selectedCountry!.isEmpty
//                   ? 'Please select a country first'
//                   : (isStateDropdownEnabled ? 'Please select a region...' : 'No regions for selected country'),
//               style: TextStyle(color: Colors.grey[600])
//           ),
//           isExpanded: true,
//           items: _currentStates.map((String regionName) {
//             return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
//           }).toList(),
//           onChanged: isStateDropdownEnabled ? (newRegionName) {
//             if (newRegionName == null) return;
//             setState(() {
//               Region? selectedRegionObject;
//               if (_selectedApiCountryObject != null) {
//                 try {
//                   selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
//                 } catch (e) {
//                   if (kDebugMode) print("Error: Selected region name '$newRegionName' not found.");
//                   selectedRegionObject = null;
//                 }
//               }
//
//               _selectedState = newRegionName;
//
//               if (selectedRegionObject != null) {
//                 selectedRegionName = selectedRegionObject.name;
//                 selectedRegionId = selectedRegionObject.id;
//                 selectedRegionCode = selectedRegionObject.code;
//               } else {
//                 selectedRegionName = '';
//                 selectedRegionId = '';
//                 selectedRegionCode = '';
//               }
//               if (kDebugMode) {
//                 print("Region selected: $selectedRegionName (ID: $selectedRegionId, Code: $selectedRegionCode)");
//               }
//             });
//             _triggerShippingMethodUpdate();
//           } : null,
//           disabledHint: Text(
//               _selectedCountry == null || _selectedCountry!.isEmpty
//                   ? 'Please select a country first'
//                   : 'No regions available',
//               style: TextStyle(color: Colors.grey[500])
//           ),
//         ),
//         const SizedBox(height: 16.0),
//
//         _buildTextFieldWithLabel('Street Address', controller: _streetAddressController, isRequired: true, maxLines: 2),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('City', controller: _cityController, isRequired: true),
//         const SizedBox(height: 16.0),
//
//         _buildTextFieldWithLabel(
//           'Zip/Postal Code',
//           controller: _zipController,
//           isRequired: true,
//           keyboardType: TextInputType.number,
//           onEditingComplete: _triggerShippingMethodUpdate,
//         ),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Phone Number', controller: _phoneController, isRequired: true, keyboardType: TextInputType.phone),
//         const SizedBox(height: 24.0),
//
//         BlocBuilder<ShippingBloc, ShippingState>(
//             builder: (context, blocState) {
//               return _buildShippingMethodsSection(blocState);
//             }
//         ),
//         const SizedBox(height: 24.0),
//         _buildHelpButton(),
//         const SizedBox(height: 20.0),
//       ],
//     );
//   }
//
//   //3/9/2025
//   // Widget _buildEstimatedTotal() {
//   //   // ✅ 1. Get the current currency state
//   //   final currencyState = context.watch<CurrencyBloc>().state;
//   //
//   //   // Default values for safety
//   //   String displaySymbol = '₹';
//   //   double displaySubtotal = _subTotal; // Use the base subtotal from your state
//   //
//   //   // If currency is loaded, calculate the display value
//   //   if (currencyState is CurrencyLoaded) {
//   //     displaySymbol = currencyState.selectedSymbol;
//   //     // Calculate price: (base subtotal in INR) * (selected currency's rate)
//   //     displaySubtotal = _subTotal * currencyState.selectedRate.rate;
//   //   }
//   //   return Container(
//   //     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//   //     decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6.0)),
//   //     child: Row(
//   //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //       children: <Widget>[
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: <Widget>[
//   //             // ✅ MODIFIED: Changed text from "Estimated Total" to "Order Subtotal"
//   //             const Text('Order Subtotal', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87)),
//   //             const SizedBox(height: 4.0),
//   //             _isCartLoading
//   //                 ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black54))
//   //             // ✅ MODIFIED: Display _subTotal instead of _grandTotal
//   //             //     : Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
//   //                 : Text('$displaySymbol${displaySubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
//   //
//   //           ],
//   //         ),
//   //         Row(
//   //           children: <Widget>[
//   //             const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
//   //             const SizedBox(width: 8.0),
//   //             Container(
//   //               padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//   //               decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4.0)),
//   //               child: _isCartLoading
//   //                   ? const Text('...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13))
//   //                   : Text(_itemsQty.toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
//   //             ),
//   //           ],
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
//
//   Widget _buildEstimatedTotal() {
//        // ✅ 1. Get the current currency state
//         final currencyState = context.watch<CurrencyBloc>().state;
//
//         // Default values for safety
//        String displaySymbol = '₹';
//        double displaySubtotal = _subTotal; // Use the base subtotal from your state
//
//        // If currency is loaded, calculate the display value
//        if (currencyState is CurrencyLoaded) {
//          displaySymbol = currencyState.selectedSymbol;
//          // Calculate price: (base subtotal in INR) * (selected currency's rate)
//          displaySubtotal = _subTotal * currencyState.selectedRate.rate;
//        }
//     return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//     decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6.0)),
//     child: Row(
//     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//     children: <Widget>[
//     Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: <Widget>[
//     // ✅ MODIFIED: Changed text from "Estimated Total" to "Order Subtotal"
//     const Text('Order Subtotal', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87)),
//     const SizedBox(height: 4.0),
//     _isCartLoading
//     ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black54))
//     // ✅ MODIFIED: Display _subTotal instead of _grandTotal
//     //     : Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
//              :Text('$displaySymbol${displaySubtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
//
//     ],
//     ),
//     Row(
//     children: <Widget>[
//     const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
//     const SizedBox(width: 8.0),
//     Container(
//     padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//     decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4.0)),
//     child: _isCartLoading
//     ? const Text('...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13))
//         : Text(_itemsQty.toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
//     ),
//     ],
//     ),
//     ],
//     ),
//     );
//     }
//
//   Widget _buildLabel(String label, {bool isRequired = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6.0),
//       child: RichText(
//         text: TextSpan(
//           text: label,
//           style: const TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.w500),
//           children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold))] : [],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextFieldWithLabel(String label, {
//     bool isRequired = false,
//     int maxLines = 1,
//     String? hintText,
//     TextEditingController? controller,
//     TextInputType? keyboardType,
//     void Function()? onEditingComplete
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildLabel(label, isRequired: isRequired),
//         TextField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           onEditingComplete: onEditingComplete,
//           decoration: InputDecoration(
//             hintText: hintText,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//           ),
//           style: const TextStyle(fontSize: 15.0),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTableCell(String text, {bool isHeader = false, TextAlign textAlign = TextAlign.left}) {
//     return TableCell(
//       verticalAlignment: TableCellVerticalAlignment.middle,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//         child: Text(
//           text,
//           style: TextStyle(
//               fontSize: 13.0,
//               fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
//               color: Colors.black87),
//           textAlign: textAlign,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showShippingMethodSelectionDialog(BuildContext context) async {
//     String? tempSelectedShippingId = _selectedShippingMethodId;
//
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return StatefulBuilder(
//           builder: (stfContext, stfSetState) {
//             return AlertDialog(
//               title: const Text('Select Shipping Method'),
//               content: SingleChildScrollView(
//                 child: ListBody(
//                   children: _displayableShippingMethods.map((method) {
//                     return RadioListTile<String>(
//                       title: Text("${method['title']} (${method['carrier']})"),
//                       subtitle: Text(method['price_str'] as String),
//                       value: method['id'] as String,
//                       groupValue: tempSelectedShippingId,
//                       onChanged: (String? value) {
//                         if (value != null) {
//                           stfSetState(() {
//                             tempSelectedShippingId = value;
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                 ),
//                 TextButton(
//                   child: const Text('Select'),
//                   onPressed: () {
//                     if (tempSelectedShippingId != null) {
//                       setState(() {
//                         _selectedShippingMethodId = tempSelectedShippingId!;
//                         final newSelectedMethodData = _displayableShippingMethods.firstWhere(
//                                 (m) => m['id'] == _selectedShippingMethodId
//                         );
//                         currentShippingCost = newSelectedMethodData['price_val'] as double;
//                         selectedShippingMethodName = newSelectedMethodData['title'] as String;
//                         carrierCode = newSelectedMethodData['carrier_code'] as String;
//                         methodCode = newSelectedMethodData['method_code'] as String;
//                       });
//                     }
//                     Navigator.of(dialogContext).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   Widget _buildShippingMethodsSection(ShippingState state) {
//     // ✅ 1. Get the current currency state
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double exchangeRate = 1.0;
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       exchangeRate = currencyState.selectedRate.rate;
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Shipping Methods',
//           style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         const SizedBox(height: 8.0),
//         Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
//         const SizedBox(height: 16.0),
//
//         if (_isFetchingShippingMethods)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.0),
//             child: Center(child: Text("Estimating shipping costs...")),
//           )
//         else if (_displayableShippingMethods.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.0),
//             child: Center(child: Text("Please select a country to estimate shipping.")),
//           )
//         else ...[
//                 () {
//               Map<String, dynamic>? determinedShippingMethod;
//               if (_selectedShippingMethodId != null) {
//                 try {
//                   determinedShippingMethod = _displayableShippingMethods.firstWhere(
//                         (m) => m['id'] == _selectedShippingMethodId,
//                   );
//                 } catch (e) {
//                   if (kDebugMode) print("Error finding selected shipping method ID '$_selectedShippingMethodId'. $e");
//                   determinedShippingMethod = null;
//                 }
//               }
//
//               if (determinedShippingMethod == null) {
//                 // This can happen if the selected ID is no longer in the list after a refresh
//                 return const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(child: Text("Please re-select a shipping method.")),
//                 );
//               }
//               // ✅ 2. Convert the shipping price for display
//               final double baseShippingPrice = determinedShippingMethod['price_val'] as double;
//               final double displayShippingPrice = baseShippingPrice * exchangeRate;
//               return Table(
//                 border: TableBorder.all(color: Colors.grey.shade300, width: 1),
//                 columnWidths: const {
//                   0: IntrinsicColumnWidth(flex: 0.7),
//                   1: FlexColumnWidth(1),
//                   2: FlexColumnWidth(1.2),
//                   3: FlexColumnWidth(1.2),
//                 },
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(color: Colors.grey[100]),
//                     children: [
//                       _buildTableCell('Select Method', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Price', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Method Title', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Carrier Title', isHeader: true, textAlign: TextAlign.center),
//                     ],
//                   ),
//                   TableRow(
//                     children: [
//                       TableCell(
//                         verticalAlignment: TableCellVerticalAlignment.middle,
//                         child: Center(
//                           child: Radio<String>(
//                             value: determinedShippingMethod['id'] as String,
//                             groupValue: _selectedShippingMethodId,
//                             onChanged: null,
//                             activeColor: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                       // _buildTableCell(
//                       //   '₹${(determinedShippingMethod['price_val'] as double).toStringAsFixed(2)}',
//                       //   textAlign: TextAlign.center,
//                       // ),
//                       _buildTableCell(
//                         // ✅ 3. Display the converted price and symbol in the table
//                         '$displaySymbol${displayShippingPrice.toStringAsFixed(2)}',
//                         textAlign: TextAlign.center,
//                       ),
//                       _buildTableCell(
//                         determinedShippingMethod['title'] as String,
//                         textAlign: TextAlign.center,
//                       ),
//                       _buildTableCell(
//                         determinedShippingMethod['carrier'] as String,
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             }(),
//
//             const SizedBox(height: 24.0),
//
//             Align(
//               alignment: Alignment.centerRight,
//               child: BlocBuilder<ShippingBloc, ShippingState>(
//                 builder: (context, state) {
//                   final isSubmitting = state is ShippingInfoSubmitting;
//
//                   // ✅ FIXED: Changed orElse to return Map<String, Object> to match inferred type.
//                   final determinedShippingMethod = _displayableShippingMethods.firstWhere(
//                         (m) => m['id'] == _selectedShippingMethodId,
//                     orElse: () => <String, Object>{}, // The fix is on this line
//                   );
//                   return ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                       textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
//                       disabledBackgroundColor: Colors.grey[700],
//                     ),
//                     // onPressed: isSubmitting ? null : () async {
//                     //   // 1. --- Your existing validation ---
//                     //   if (_firstNameController.text.isEmpty ||
//                     //       _lastNameController.text.isEmpty ||
//                     //       _streetAddressController.text.isEmpty ||
//                     //       _cityController.text.isEmpty ||
//                     //       _zipController.text.isEmpty ||
//                     //       _phoneController.text.isEmpty ||
//                     //       selectedCountryId.isEmpty
//                     //   ) {
//                     //     ScaffoldMessenger.of(context).showSnackBar(
//                     //       const SnackBar(content: Text('Please fill all required fields.')),
//                     //     );
//                     //     return;
//                     //   }
//                     //   if (determinedShippingMethod.isEmpty) {
//                     //     ScaffoldMessenger.of(context).showSnackBar(
//                     //       const SnackBar(content: Text('Please select a shipping method first.')),
//                     //     );
//                     //     return;
//                     //   }
//                     //
//                     //   // 2. --- Your existing data preparation ---
//                     //   _saveCurrentSelectionsToPrefs();
//                     //
//                     //   final prefs = await SharedPreferences.getInstance();
//                     //   final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
//                     //   final finalMethodCode = prefs.getString('method_code') ?? methodCode;
//                     //
//                     //
//                     //   // 3. --- ADD THIS BLOCK TO PRINT THE DATA ---
//                     //   final shippingInfoPayload = {
//                     //     "firstName": _firstNameController.text,
//                     //     "lastName": _lastNameController.text,
//                     //     "streetAddress": _streetAddressController.text,
//                     //     "city": _cityController.text,
//                     //     "zipCode": _zipController.text,
//                     //     "phone": _phoneController.text,
//                     //     "email": _emailController.text.isNotEmpty ? _emailController.text : 'mitesh@gmail.com',
//                     //     "countryId": selectedCountryId,
//                     //     "countryName (for debug)": selectedCountryName, // Good for checking
//                     //     "regionName": selectedRegionName,
//                     //     "regionId": selectedRegionId,
//                     //     "regionCode": selectedRegionCode,
//                     //     "carrierCode": finalCarrierCode,
//                     //     "methodCode": finalMethodCode,
//                     //   };
//                     //
//                     //   if (kDebugMode) {
//                     //     print("--- ✅ SUBMITTING SHIPPING INFO ---");
//                     //     // Using JsonEncoder with an indent gives a nice "pretty print" format
//                     //     final encoder = JsonEncoder.withIndent('  ');
//                     //     print(encoder.convert(shippingInfoPayload));
//                     //     print("----------------------------------");
//                     //   }
//                     //   // --- END OF ADDED BLOCK ---
//                     //
//                     //
//                     //   // 4. --- Your existing call to the BLoC ---
//                     //   context.read<ShippingBloc>().add(
//                     //     SubmitShippingInfo(
//                     //       firstName: _firstNameController.text,
//                     //       lastName: _lastNameController.text,
//                     //       streetAddress: _streetAddressController.text,
//                     //       city: _cityController.text,
//                     //       zipCode: _zipController.text,
//                     //       phone: _phoneController.text,
//                     //       email: _emailController.text.isNotEmpty ? _emailController.text : 'mitesh@gmail.com',
//                     //       countryId: selectedCountryId,
//                     //       regionName: selectedRegionName,
//                     //       regionId: selectedRegionId,
//                     //       regionCode: selectedRegionCode,
//                     //       carrierCode: finalCarrierCode,
//                     //       methodCode: finalMethodCode,
//                     //     ),
//                     //   );
//                     // },
//                     onPressed: isSubmitting ? null : () async {
//                       // 1. --- Your existing validation ---
//                       if (_firstNameController.text.isEmpty ||
//                           _lastNameController.text.isEmpty ||
//                           _streetAddressController.text.isEmpty ||
//                           _cityController.text.isEmpty ||
//                           _zipController.text.isEmpty ||
//                           _phoneController.text.isEmpty ||
//                           selectedCountryId.isEmpty
//                       ) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please fill all required fields.')),
//                         );
//                         return;
//                       }
//                       if (determinedShippingMethod.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please select a shipping method first.')),
//                         );
//                         return;
//                       }
//
//                       // 2. --- Save selections ---
//                       _saveCurrentSelectionsToPrefs();
//
//                       final prefs = await SharedPreferences.getInstance();
//                       final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
//                       final finalMethodCode = prefs.getString('method_code') ?? methodCode;
//
//                       // ✅ 3. --- Save email in SharedPreferences ---
//                       final enteredEmail = _emailController.text.isNotEmpty
//                           ? _emailController.text.trim()
//                           : 'mitesh@gmail.com'; // fallback
//                       await prefs.setString('user_email', enteredEmail);
//                       print("saved email sf>>$enteredEmail");
//
//                       // 4. --- Debug print payload (optional) ---
//                       final shippingInfoPayload = {
//                         "firstName": _firstNameController.text,
//                         "lastName": _lastNameController.text,
//                         "streetAddress": _streetAddressController.text,
//                         "city": _cityController.text,
//                         "zipCode": _zipController.text,
//                         "phone": _phoneController.text,
//                         "email": enteredEmail,
//                         "countryId": selectedCountryId,
//                         "countryName (for debug)": selectedCountryName,
//                         "regionName": selectedRegionName,
//                         "regionId": selectedRegionId,
//                         "regionCode": selectedRegionCode,
//                         "carrierCode": finalCarrierCode,
//                         "methodCode": finalMethodCode,
//                       };
//
//                       if (kDebugMode) {
//                         final encoder = JsonEncoder.withIndent('  ');
//                         print("--- ✅ SUBMITTING SHIPPING INFO ---");
//                         print(encoder.convert(shippingInfoPayload));
//                         print("----------------------------------");
//                       }
//
//                       // 5. --- Call BLoC event ---
//                       context.read<ShippingBloc>().add(
//                         SubmitShippingInfo(
//                           firstName: _firstNameController.text,
//                           lastName: _lastNameController.text,
//                           streetAddress: _streetAddressController.text,
//                           city: _cityController.text,
//                           zipCode: _zipController.text,
//                           phone: _phoneController.text,
//                           email: enteredEmail,
//                           countryId: selectedCountryId,
//                           regionName: selectedRegionName,
//                           regionId: selectedRegionId,
//                           regionCode: selectedRegionCode,
//                           carrierCode: finalCarrierCode,
//                           methodCode: finalMethodCode,
//                         ),
//                       );
//                     },
//
//                     child: isSubmitting
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : const Text('NEXT'),
//                   );
//                   // return ElevatedButton(
//                   //   style: ElevatedButton.styleFrom(
//                   //     backgroundColor: Colors.black,
//                   //     foregroundColor: Colors.white,
//                   //     padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                   //     textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
//                   //     disabledBackgroundColor: Colors.grey[700],
//                   //   ),
//                   //   onPressed: isSubmitting ? null : () async {
//                   //     if (_firstNameController.text.isEmpty ||
//                   //         _lastNameController.text.isEmpty ||
//                   //         _streetAddressController.text.isEmpty ||
//                   //         _cityController.text.isEmpty ||
//                   //         _zipController.text.isEmpty ||
//                   //         _phoneController.text.isEmpty ||
//                   //         selectedCountryId.isEmpty
//                   //     ) {
//                   //       ScaffoldMessenger.of(context).showSnackBar(
//                   //         const SnackBar(content: Text('Please fill all required fields.')),
//                   //       );
//                   //       return;
//                   //     }
//                   //     if (determinedShippingMethod.isEmpty) {
//                   //       ScaffoldMessenger.of(context).showSnackBar(
//                   //         const SnackBar(content: Text('Please select a shipping method first.')),
//                   //       );
//                   //       return;
//                   //     }
//                   //
//                   //     _saveCurrentSelectionsToPrefs();
//                   //
//                   //     final prefs = await SharedPreferences.getInstance();
//                   //     final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
//                   //     final finalMethodCode = prefs.getString('method_code') ?? methodCode;
//                   //
//                   //     context.read<ShippingBloc>().add(
//                   //       SubmitShippingInfo(
//                   //         firstName: _firstNameController.text,
//                   //         lastName: _lastNameController.text,
//                   //         streetAddress: _streetAddressController.text,
//                   //         city: _cityController.text,
//                   //         zipCode: _zipController.text,
//                   //         phone: _phoneController.text,
//                   //         email: _emailController.text.isNotEmpty ? _emailController.text : 'mitesh@gmail.com',
//                   //         countryId: selectedCountryId,
//                   //         regionName: selectedRegionName,
//                   //         regionId: selectedRegionId,
//                   //         regionCode: selectedRegionCode,
//                   //         carrierCode: finalCarrierCode,
//                   //         methodCode: finalMethodCode,
//                   //       ),
//                   //     );
//                   //   },
//                   //   child: isSubmitting
//                   //       ? const SizedBox(
//                   //     height: 20,
//                   //     width: 20,
//                   //     child: CircularProgressIndicator(
//                   //       color: Colors.white,
//                   //       strokeWidth: 2.5,
//                   //     ),
//                   //   )
//                   //       : const Text('NEXT'),
//                   // );
//                 },
//               ),
//             ),
//           ],
//       ],
//     );
//   }
//
//   Widget _buildHelpButton() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: ElevatedButton.icon(
//         onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help button pressed!'))),
//         icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
//         label: const Text('Help', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), elevation: 2.0),
//       ),
//     );
//   }
// }



/////////////////////old


// class CheckoutScreen extends StatefulWidget {
//   @override
//   _CheckoutScreenState createState() => _CheckoutScreenState();
// }
//
// class _CheckoutScreenState extends State<CheckoutScreen> {
//   late ShippingBloc _shippingBloc;
//
//   Country? _selectedApiCountryObject;
//   String? _selectedCountry;
//   List<Country> _apiCountries = [];
//   bool _areCountriesLoading = true;
//   bool _initialCountryLoadAttempted = false;
//   String? _countriesError;
//   int customerId=0;
//   String selectedRegionCode= '';
//   bool _isSubmitting = false;
//   String? _selectedShippingMethodId;
//
//   double _subTotal = 0.0;
//
//   String? _selectedState;
//   List<String> _currentStates = [];
//
//   String selectedCountryName = '';
//   String selectedCountryId = '';
//   String selectedRegionName = '';
//   String selectedRegionId = '';
//   double _cartTotalWeight = 0.0;
//
//   bool isUserLoggedIn = false;
//   double _grandTotal = 0.0;
//   int _itemsQty = 0;
//
//   String selectedShippingMethodName = '';
//   double currentShippingCost = 0.0;
//   String carrierCode = '';
//   String methodCode = '';
//   bool _isFetchingShippingMethods = false;
//
//
//   // This will be our live list for UI and updates
//   List<Map<String, dynamic>> _displayableShippingMethods = [];
//
//   final CartRepository _cartRepository = CartRepository();
//   List<Map<String, dynamic>> _fetchedCartItems = [];
//   List<Map<String, dynamic>> _fetchTotals = [];
//   bool _isCartLoading = false;
//   String? _cartError;
//
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _streetAddressController = TextEditingController();
//   final TextEditingController _cityController = TextEditingController();
//   final TextEditingController _zipController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//
//   bool _isLoadingShippingPrefs = true;
//
//   bool get _isPageLoading => _isLoadingShippingPrefs || (_areCountriesLoading && !_initialCountryLoadAttempted);
//
//
//   // The new shipping method fetcher.
//   Future<List<ShippingMethod>> fetchAvailableShippingMethods({
//     required String countryId,
//     required String regionId,
//     required String postcode,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');
//
//     final payload = {
//       "address": {
//         "country_id": countryId,
//         "region_id": int.tryParse(regionId) ?? 0, // Handles empty regionId
//         "postcode": postcode.isNotEmpty ? postcode : "00000", // Use a placeholder if empty
//         "city": _cityController.text.isNotEmpty ? _cityController.text : "Placeholder",
//         "street": [_streetAddressController.text.isNotEmpty ? _streetAddressController.text : "Placeholder"],
//         "firstname": _firstNameController.text.isNotEmpty ? _firstNameController.text : "Guest",
//         "lastname": _lastNameController.text.isNotEmpty ? _lastNameController.text : "User",
//         "telephone": _phoneController.text.isNotEmpty ? _phoneController.text : "9999999999",
//       }
//     };
//
//     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     final response = await ioClient.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//       body: json.encode(payload),
//     );
//
//     if (kDebugMode) {
//       print("Shipping Estimation Payload: ${json.encode(payload)}");
//       print("Standard Shipping API Response: ${response.body}");
//     }
//
//
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
//     } else {
//       final errorBody = json.decode(response.body);
//       throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
//     }
//   }
//
//
//   // ✅ MODIFIED: Central function to trigger shipping updates. Now only requires a country.
//   Future<void> _triggerShippingMethodUpdate() async {
//     // 1. Validate that we have at least a country.
//     if (selectedCountryId.isEmpty) {
//       if (kDebugMode) {
//         print("Skipping shipping fetch: Country is missing.");
//       }
//       return;
//     }
//
//     // 2. Show a loading indicator in the UI.
//     if(!mounted) return;
//     setState(() {
//       _isFetchingShippingMethods = true;
//     });
//
//     try {
//       // 3. Call the API fetcher function with available data. It will use placeholders for missing info.
//       final List<ShippingMethod> fetchedMethods = await fetchAvailableShippingMethods(
//         countryId: selectedCountryId,
//         regionId: selectedRegionId,
//         postcode: _zipController.text,
//       );
//
//       if(!mounted) return;
//
//       if (fetchedMethods.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No shipping methods available for this address.")),
//         );
//         setState(() {
//           _displayableShippingMethods = [];
//           _selectedShippingMethodId = null;
//           _isFetchingShippingMethods = false;
//         });
//         return;
//       }
//
//       // 4. Transform the API response into the format your UI table expects.
//       final newUiMethods = fetchedMethods.map((method) {
//         return {
//           'id': '${method.carrierCode}_${method.methodCode}', // A unique ID
//           'price_str': '₹${method.amount.toStringAsFixed(2)}',
//           'price_val': method.amount,
//           'title': method.methodTitle,
//           'carrier': method.carrierTitle,
//           'carrier_code': method.carrierCode,
//           'method_code': method.methodCode,
//         };
//       }).toList();
//
//       // 5. Update the state to display the new methods.
//       setState(() {
//         _displayableShippingMethods = newUiMethods;
//
//         if (_displayableShippingMethods.isNotEmpty) {
//           final firstMethod = _displayableShippingMethods.first;
//           _selectedShippingMethodId = firstMethod['id'] as String;
//           currentShippingCost = firstMethod['price_val'] as double;
//           selectedShippingMethodName = firstMethod['title'] as String;
//           carrierCode = firstMethod['carrier_code'] as String;
//           methodCode = firstMethod['method_code'] as String;
//         } else {
//           _selectedShippingMethodId = null;
//         }
//         _isFetchingShippingMethods = false;
//       });
//
//     } catch (e) {
//       if(!mounted) return;
//       if (kDebugMode) print("Error fetching shipping methods: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
//       );
//       // 6. Handle errors by clearing the list and hiding the loader.
//       setState(() {
//         _displayableShippingMethods = [];
//         _selectedShippingMethodId = null;
//         _isFetchingShippingMethods = false;
//       });
//     }
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _shippingBloc = ShippingBloc();
//     _shippingBloc.add(FetchCountries());
//
//     _loadLoginStatus();
//     _fetchAndPrintCartItemsDirectly();
//     _callAndProcessFetchTotal();
//   }
//
//
//   Future<void> _loadShippingPreferencesForCheckout() async {
//     if (!mounted) return;
//     setState(() {
//       _isLoadingShippingPrefs = true;
//     });
//
//     final prefs = await SharedPreferences.getInstance();
//     final String? countryNameFromPrefs = prefs.getString('selected_country_name');
//     final String? countryIdFromPrefs = prefs.getString('selected_country_id');
//     final String? regionNameFromPrefs = prefs.getString('selected_region_name');
//     final String? regionIdFromPrefs = prefs.getString('selected_region_id');
//     final double? shippingPriceFromPrefs = prefs.getDouble('shipping_price');
//     final String? shippingMethodNameFromPrefs = prefs.getString('method_name');
//     final String? carrierCodeFromPrefs = prefs.getString('carrier_code');
//     final String? methodCodeFromPrefs = prefs.getString('method_code');
//
//     if (kDebugMode) {
//       print("--- Loading Shipping Preferences (CheckoutScreen) ---");
//       print("API Countries available: ${_apiCountries.length}, Prefs Country: $countryNameFromPrefs (ID: $countryIdFromPrefs), Prefs Region: $regionNameFromPrefs (ID: $regionIdFromPrefs)");
//       print("Prefs Shipping: Method='$shippingMethodNameFromPrefs', Price='$shippingPriceFromPrefs'");
//     }
//
//     Country? resolvedApiCountry;
//
//     if (countryNameFromPrefs != null && _apiCountries.isNotEmpty) {
//       try {
//         resolvedApiCountry = _apiCountries.firstWhere(
//                 (c) => c.fullNameEnglish == countryNameFromPrefs || (countryIdFromPrefs != null && c.id == countryIdFromPrefs)
//         );
//         if (kDebugMode) print("Found country from prefs in API list: ${resolvedApiCountry.fullNameEnglish}");
//       } catch (e) {
//         if (kDebugMode) print("Country from prefs ('$countryNameFromPrefs') not found in API list.");
//         resolvedApiCountry = null;
//       }
//     }
//
//     if (resolvedApiCountry == null && _selectedApiCountryObject != null && _apiCountries.isNotEmpty) {
//       try {
//         resolvedApiCountry = _apiCountries.firstWhere((c) => c.id == _selectedApiCountryObject!.id);
//         if (kDebugMode) print("Validated current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') with API list.");
//       } catch (e) {
//         if (kDebugMode) print("Current _selectedApiCountryObject ('${_selectedApiCountryObject!.fullNameEnglish}') no longer valid in API list.");
//         resolvedApiCountry = null;
//       }
//     }
//
//     if (resolvedApiCountry == null && _apiCountries.isNotEmpty) {
//       resolvedApiCountry = _apiCountries.first;
//       if (kDebugMode) print("Defaulting to first API country: ${resolvedApiCountry.fullNameEnglish}");
//     }
//
//     List<String> newCurrentStatesList = [];
//     List<Region> regionsForResolvedCountry = [];
//     String finalSelectedCountryDropDownName = _selectedCountry ?? '';
//     String finalSelectedCountryId = selectedCountryId;
//     String finalSelectedCountryFullName = selectedCountryName;
//
//
//     if (resolvedApiCountry != null) {
//       _selectedApiCountryObject = resolvedApiCountry;
//       finalSelectedCountryDropDownName = resolvedApiCountry.fullNameEnglish;
//       finalSelectedCountryId = resolvedApiCountry.id;
//       finalSelectedCountryFullName = resolvedApiCountry.fullNameEnglish;
//       regionsForResolvedCountry = resolvedApiCountry.regions;
//       newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
//     } else if (_apiCountries.isEmpty && countryNameFromPrefs != null) {
//       finalSelectedCountryDropDownName = countryNameFromPrefs;
//       finalSelectedCountryId = countryIdFromPrefs ?? '';
//       finalSelectedCountryFullName = countryNameFromPrefs;
//       _selectedApiCountryObject = null;
//       if (kDebugMode) print("API countries empty. Using country from prefs: $finalSelectedCountryFullName. Regions will be empty.");
//     } else {
//       if (_selectedApiCountryObject != null && _selectedApiCountryObject!.fullNameEnglish == _selectedCountry) {
//         regionsForResolvedCountry = _selectedApiCountryObject!.regions;
//         newCurrentStatesList = regionsForResolvedCountry.map((r) => r.name).toList();
//       } else {
//         _selectedApiCountryObject = null;
//       }
//       if (kDebugMode) print("Could not fully resolve a country with API list. Current dropdown: $_selectedCountry. Regions may be empty or based on previous valid state.");
//     }
//
//     String? finalSelectedStateDropDownName = _selectedState;
//     String finalSelectedRegionStoredId = selectedRegionId;
//     String finalSelectedRegionStoredName = selectedRegionName;
//
//
//     if (regionNameFromPrefs != null && regionsForResolvedCountry.isNotEmpty) {
//       Region? matchedRegionFromPrefs;
//       try {
//         matchedRegionFromPrefs = regionsForResolvedCountry.firstWhere(
//                 (r) => r.name == regionNameFromPrefs || (regionIdFromPrefs != null && r.id == regionIdFromPrefs)
//         );
//       } catch (e) { matchedRegionFromPrefs = null; }
//
//       if (matchedRegionFromPrefs != null) {
//         finalSelectedStateDropDownName = matchedRegionFromPrefs.name;
//         finalSelectedRegionStoredId = matchedRegionFromPrefs.id;
//         finalSelectedRegionStoredName = matchedRegionFromPrefs.name;
//         if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') matched: ${matchedRegionFromPrefs.name} (ID: ${matchedRegionFromPrefs.id})");
//       } else {
//         if (kDebugMode) print("Region from prefs ('$regionNameFromPrefs') not found in available regions for $finalSelectedCountryFullName.");
//         if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
//           finalSelectedStateDropDownName = null;
//           finalSelectedRegionStoredId = '';
//           finalSelectedRegionStoredName = '';
//           if (kDebugMode) print("Resetting selected state as it's not in the new list of states.");
//         }
//       }
//     } else if (finalSelectedStateDropDownName != null && !newCurrentStatesList.contains(finalSelectedStateDropDownName)) {
//       finalSelectedStateDropDownName = null;
//       finalSelectedRegionStoredId = '';
//       finalSelectedRegionStoredName = '';
//       if (kDebugMode) print("Current _selectedState ('$_selectedState') is invalid for the determined country's regions. Resetting.");
//     }
//
//     double loadedShippingCost = 0.0;
//     String loadedShippingMethodName = '';
//     String? loadedSelectedShippingId;
//     String loadedCarrierCode = '';
//     String loadedMethodCode = '';
//
//     if (shippingMethodNameFromPrefs != null && shippingPriceFromPrefs != null && carrierCodeFromPrefs != null && methodCodeFromPrefs != null) {
//       loadedShippingCost = shippingPriceFromPrefs;
//       loadedShippingMethodName = shippingMethodNameFromPrefs;
//       loadedSelectedShippingId = '${carrierCodeFromPrefs}_${methodCodeFromPrefs}';
//       loadedCarrierCode = carrierCodeFromPrefs;
//       loadedMethodCode = methodCodeFromPrefs;
//     }
//
//     if (!mounted) return;
//     setState(() {
//       _selectedCountry = finalSelectedCountryDropDownName.isNotEmpty ? finalSelectedCountryDropDownName : null;
//       this.selectedCountryId = finalSelectedCountryId;
//       this.selectedCountryName = finalSelectedCountryFullName;
//
//       _currentStates = newCurrentStatesList;
//       _selectedState = finalSelectedStateDropDownName;
//
//       this.selectedRegionName = finalSelectedRegionStoredName;
//       this.selectedRegionId = finalSelectedRegionStoredId;
//
//       currentShippingCost = loadedShippingCost;
//       selectedShippingMethodName = loadedShippingMethodName;
//       _selectedShippingMethodId = loadedSelectedShippingId;
//       carrierCode = loadedCarrierCode;
//       methodCode = loadedMethodCode;
//
//       _isLoadingShippingPrefs = false;
//
//       if (kDebugMode) {
//         print("--- setState COMPLETE (Prefs Loading) ---");
//         print("Final _selectedShippingMethodId: $_selectedShippingMethodId");
//       }
//     });
//
//     // ✅ ADDED: Trigger shipping fetch after preferences are loaded.
//     _triggerShippingMethodUpdate();
//   }
//
//
//   Future<void> _callAndProcessFetchTotal() async {
//     if (!mounted) return;
//     setState(() { _isCartLoading = true; _cartError = null; });
//     try {
//       final Map<String, dynamic>? totalsObject = await _performFetchTotalApiCallModified();
//       if (!mounted) return;
//       if (totalsObject != null) {
//         // Find the subtotal from the total_segments array
//         double foundSubtotal = 0.0;
//         if (totalsObject['total_segments'] is List) {
//           try {
//             final subtotalSegment = (totalsObject['total_segments'] as List)
//                 .firstWhere((segment) => segment['code'] == 'subtotal');
//             foundSubtotal = (subtotalSegment['value'] as num?)?.toDouble() ?? 0.0;
//           } catch (e) {
//             if (kDebugMode) print("Subtotal segment not found. Defaulting to 0.");
//             // If subtotal is not found, you might want to use grand_total as a fallback
//             foundSubtotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//           }
//         }
//
//         setState(() {
//           _grandTotal = (totalsObject['grand_total'] as num?)?.toDouble() ?? 0.0;
//           _subTotal = foundSubtotal; // ✅ SET THE NEW SUBTOTAL VARIABLE
//           _itemsQty = totalsObject['items_qty'] as int? ?? 0;
//
//           double calculatedWeight = 0.0;
//           if (totalsObject.containsKey('items_weight') && totalsObject['items_weight'] != null) {
//             calculatedWeight = (totalsObject['items_weight'] as num).toDouble();
//           } else if (totalsObject.containsKey('weight') && totalsObject['weight'] != null) {
//             calculatedWeight = (totalsObject['weight'] as num).toDouble();
//           } else if (totalsObject['items'] is List) {
//             for (var item_data in (totalsObject['items'] as List)) {
//               if (item_data is Map<String, dynamic>) {
//                 final itemWeight = (item_data['weight'] as num?)?.toDouble() ?? 0.0;
//                 final itemQty = (item_data['qty'] as num?)?.toInt() ?? 1;
//                 calculatedWeight += (itemWeight * itemQty);
//               }
//             }
//           }
//           _cartTotalWeight = calculatedWeight;
//
//           if (kDebugMode) {
//             print("Cart total weight updated: $_cartTotalWeight");
//             print("Subtotal set to: $_subTotal"); // For debugging
//           }
//
//           if (totalsObject['total_segments'] is List) {
//             _fetchTotals = (totalsObject['total_segments'] as List)
//                 .map((segment) => segment as Map<String, dynamic>)
//                 .toList();
//           } else { _fetchTotals = []; }
//           _isCartLoading = false;
//         });
//       } else { throw Exception("Totals data received in unexpected format or user not logged in."); }
//     } catch (e) {
//       if (!mounted) return;
//       if (kDebugMode) print("Error fetching totals: $e");
//       setState(() {
//         _cartError = e.toString(); _isCartLoading = false;
//         _grandTotal = 0.0;
//         _subTotal = 0.0; // Reset on error
//         _itemsQty = 0;
//         _fetchTotals = [];
//         _cartTotalWeight = 0.0;
//       });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading totals: ${e.toString()}")));
//       }
//     }
//   }
//
//   Future<Map<String, dynamic>?> _performFetchTotalApiCallModified() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       if (kDebugMode) print("User not logged in, cannot fetch totals.");
//       return Future.value({'grand_total': 0.0, 'items_qty': 0, 'total_segments': []});
//     }
//
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.get(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/totals'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
//       );
//       if (response.statusCode == 200) {
//         final decodedBody = json.decode(response.body);
//         if (decodedBody is Map<String, dynamic>) { return decodedBody; }
//         else { throw Exception("Unexpected format for totals response. Expected Map, got: ${decodedBody.runtimeType}"); }
//       } else { throw Exception("Failed to fetch totals: Status ${response.statusCode}, Body: ${response.body}"); }
//     } finally { ioClient.close(); }
//   }
//
//   Future<void> _fetchAndPrintCartItemsDirectly() async {
//     if (!mounted) return;
//     try {
//       final items = await _cartRepository.getCartItems();
//       if (!mounted) return;
//       setState(() { _fetchedCartItems = items; });
//     } catch (e) {
//       if (!mounted) return;
//       if (kDebugMode) print("Error fetching cart items directly: $e");
//       setState(() { _cartError = (_cartError ?? "") + " Cart items error: " + e.toString(); _fetchedCartItems = []; });
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading cart: ${e.toString()}")));
//       }
//     }
//   }
//
//   Future<void> _loadLoginStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (!mounted) return;
//     setState(() { isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false; });
//   }
//
//
//   // ✅ MODIFIED: Now triggers a shipping fetch immediately.
//   void _onCountryChanged(String? newCountryName) {
//     if (newCountryName == null || newCountryName == _selectedCountry) return;
//
//     Country? newSelectedApiCountry;
//     try {
//       newSelectedApiCountry = _apiCountries.firstWhere((c) => c.fullNameEnglish == newCountryName);
//     } catch (e) {
//       if (kDebugMode) print("Error: Selected country '$newCountryName' not found in API list.");
//       return;
//     }
//
//     setState(() {
//       _selectedApiCountryObject = newSelectedApiCountry;
//       _selectedCountry = newSelectedApiCountry!.fullNameEnglish;
//       selectedCountryName = newSelectedApiCountry.fullNameEnglish;
//       selectedCountryId = newSelectedApiCountry.id;
//       _currentStates = newSelectedApiCountry.regions.map((r) => r.name).toList();
//
//       _selectedState = null;
//       selectedRegionName = '';
//       selectedRegionId = '';
//       _displayableShippingMethods = [];
//       _selectedShippingMethodId = null;
//       _isFetchingShippingMethods = false;
//     });
//
//     // Trigger the fetch with the new country information.
//     _triggerShippingMethodUpdate();
//   }
//
//
//   Future<void> _saveCurrentSelectionsToPrefs() async {
//     if (selectedCountryName.isEmpty) {
//       if (kDebugMode) print("Cannot save prefs: Country Name is empty.");
//       return;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_country_name', selectedCountryName);
//     await prefs.setString('selected_country_id', selectedCountryId);
//
//     if (selectedRegionName.isNotEmpty) {
//       await prefs.setString('selected_region_name', selectedRegionName);
//       await prefs.setString('selected_region_id', selectedRegionId);
//     } else {
//       await prefs.remove('selected_region_name');
//       await prefs.remove('selected_region_id');
//     }
//     await prefs.setDouble('shipping_price', currentShippingCost);
//     await prefs.setString('shipping_method_name', selectedShippingMethodName);
//     await prefs.setString('shipping_carrier_code', carrierCode);
//     await prefs.setString('shipping_method_code', methodCode);
//
//
//     if (kDebugMode) {
//       print("--- Preferences Saved (from CheckoutScreen) ---");
//       print("Saved: Country: $selectedCountryName ($selectedCountryId), Region: $selectedRegionName ($selectedRegionId)");
//       print("Saved Shipping: Method: $selectedShippingMethodName ($carrierCode/$methodCode), Cost: $currentShippingCost");
//     }
//   }
//
//   @override
//   void dispose() {
//     _shippingBloc.close();
//     _emailController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _streetAddressController.dispose();
//     _cityController.dispose();
//     _zipController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider.value(
//       value: _shippingBloc,
//       child: BlocListener<ShippingBloc, ShippingState>(
//         listener: (context, state) {
//           if (!mounted) return;
//
//           if (state is CountriesLoading) {
//             setState(() {
//               _areCountriesLoading = true;
//               _countriesError = null;
//             });
//           } else if (state is CountriesLoaded) {
//             _apiCountries = state.countries;
//             _areCountriesLoading = false;
//             _initialCountryLoadAttempted = true;
//             _countriesError = null;
//             _loadShippingPreferencesForCheckout();
//           }
//           else if (state is ShippingError) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.message), backgroundColor: Colors.red),
//             );
//           }
//           else if (state is ShippingInfoSubmittedSuccessfully) {
//             if (kDebugMode) {
//               print("Shipping Info submitted successfully. Navigating to PaymentScreen...");
//             }
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => BlocProvider.value(
//                   value: _shippingBloc,
//                   child: PaymentScreen(
//                     paymentMethods: state.paymentMethods,
//                     totals: state.totals,
//                     billingAddress: state.billingAddress,
//                   ),
//                 ),
//               ),
//             );
//           }
//
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: const Text('Checkout'),
//             leading: IconButton(
//               icon: Icon(Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back),
//               onPressed: () {
//                 if (Navigator.canPop(context)) Navigator.pop(context);
//                 else Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//               },
//             ),
//           ),
//           body: SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: _isPageLoading
//                   ? const Center(child: CircularProgressIndicator(key: ValueKey("main_page_loader")))
//                   : _buildCheckoutForm(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCheckoutForm() {
//     final bool isStateDropdownEnabled = _selectedApiCountryObject != null && _currentStates.isNotEmpty;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildEstimatedTotal(),
//         const SizedBox(height: 24.0),
//         const Text('Shipping Address', style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87)),
//         const SizedBox(height: 20.0),
//
//         if (!isUserLoggedIn) ...[
//           _buildTextFieldWithLabel('Email Address', controller: _emailController, isRequired: true, keyboardType: TextInputType.emailAddress),
//           Padding(
//             padding: const EdgeInsets.only(top: 6.0, bottom: 16.0),
//             child: Text('You can create an account after checkout.', style: TextStyle(fontSize: 12.0, color: Colors.grey[600])),
//           ),
//           Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
//           const SizedBox(height: 16.0),
//         ],
//
//         _buildTextFieldWithLabel('First Name', controller: _firstNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Last Name', controller: _lastNameController, isRequired: true),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('Country', isRequired: true),
//         if (_areCountriesLoading && !_initialCountryLoadAttempted)
//           const Padding(padding: EdgeInsets.symmetric(vertical: 20.0), child: Center(child: CircularProgressIndicator(key: ValueKey("country_dropdown_loader"))))
//         else if (_countriesError != null && _apiCountries.isEmpty)
//           Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("Error: $_countriesError", style: const TextStyle(color: Colors.red)))
//         else if (_apiCountries.isEmpty && _initialCountryLoadAttempted)
//             Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text("No countries available.", style: TextStyle(color: Colors.grey[700])))
//           else
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//                 enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//                 focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//               ),
//               value: _selectedCountry,
//               isExpanded: true,
//               hint: const Text("Select Country"),
//               items: _apiCountries.map((Country country) {
//                 return DropdownMenuItem<String>(
//                   value: country.fullNameEnglish,
//                   child: Text(country.fullNameEnglish),
//                 );
//               }).toList(),
//               onChanged: _apiCountries.isEmpty ? null : _onCountryChanged,
//             ),
//         const SizedBox(height: 16.0),
//
//         _buildLabel('State/Province', isRequired: true),
//         DropdownButtonFormField<String>(
//           decoration: InputDecoration(
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//           ),
//           value: _selectedState,
//           hint: Text(
//               _selectedCountry == null || _selectedCountry!.isEmpty
//                   ? 'Please select a country first'
//                   : (isStateDropdownEnabled ? 'Please select a region...' : 'No regions for selected country'),
//               style: TextStyle(color: Colors.grey[600])
//           ),
//           isExpanded: true,
//           items: _currentStates.map((String regionName) {
//             return DropdownMenuItem<String>(value: regionName, child: Text(regionName));
//           }).toList(),
//           onChanged: isStateDropdownEnabled ? (newRegionName) {
//             if (newRegionName == null) return;
//             setState(() {
//               Region? selectedRegionObject;
//               if (_selectedApiCountryObject != null) {
//                 try {
//                   selectedRegionObject = _selectedApiCountryObject!.regions.firstWhere((r) => r.name == newRegionName);
//                 } catch (e) {
//                   if (kDebugMode) print("Error: Selected region name '$newRegionName' not found.");
//                   selectedRegionObject = null;
//                 }
//               }
//
//               _selectedState = newRegionName;
//
//               if (selectedRegionObject != null) {
//                 selectedRegionName = selectedRegionObject.name;
//                 selectedRegionId = selectedRegionObject.id;
//                 selectedRegionCode = selectedRegionObject.code;
//               } else {
//                 selectedRegionName = '';
//                 selectedRegionId = '';
//                 selectedRegionCode = '';
//               }
//               if (kDebugMode) {
//                 print("Region selected: $selectedRegionName (ID: $selectedRegionId, Code: $selectedRegionCode)");
//               }
//             });
//             _triggerShippingMethodUpdate();
//           } : null,
//           disabledHint: Text(
//               _selectedCountry == null || _selectedCountry!.isEmpty
//                   ? 'Please select a country first'
//                   : 'No regions available',
//               style: TextStyle(color: Colors.grey[500])
//           ),
//         ),
//         const SizedBox(height: 16.0),
//
//         _buildTextFieldWithLabel('Street Address', controller: _streetAddressController, isRequired: true, maxLines: 2),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('City', controller: _cityController, isRequired: true),
//         const SizedBox(height: 16.0),
//
//         _buildTextFieldWithLabel(
//           'Zip/Postal Code',
//           controller: _zipController,
//           isRequired: true,
//           keyboardType: TextInputType.number,
//           onEditingComplete: _triggerShippingMethodUpdate,
//         ),
//         const SizedBox(height: 16.0),
//         _buildTextFieldWithLabel('Phone Number', controller: _phoneController, isRequired: true, keyboardType: TextInputType.phone),
//         const SizedBox(height: 24.0),
//
//         BlocBuilder<ShippingBloc, ShippingState>(
//             builder: (context, blocState) {
//               return _buildShippingMethodsSection(blocState);
//             }
//         ),
//         const SizedBox(height: 24.0),
//         _buildHelpButton(),
//         const SizedBox(height: 20.0),
//       ],
//     );
//   }
//
//   Widget _buildEstimatedTotal() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//       decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6.0)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               // ✅ MODIFIED: Changed text from "Estimated Total" to "Order Subtotal"
//               const Text('Order Subtotal', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w500, color: Colors.black87)),
//               const SizedBox(height: 4.0),
//               _isCartLoading
//                   ? const Text('Loading...', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black54))
//               // ✅ MODIFIED: Display _subTotal instead of _grandTotal
//                   : Text('₹${_subTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: Colors.black)),
//             ],
//           ),
//           Row(
//             children: <Widget>[
//               const Icon(Icons.shopping_cart_outlined, color: Colors.black54),
//               const SizedBox(width: 8.0),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
//                 decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4.0)),
//                 child: _isCartLoading
//                     ? const Text('...', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 13))
//                     : Text(_itemsQty.toString(), style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13)),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLabel(String label, {bool isRequired = false}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 6.0),
//       child: RichText(
//         text: TextSpan(
//           text: label,
//           style: const TextStyle(fontSize: 14.0, color: Colors.black87, fontWeight: FontWeight.w500),
//           children: isRequired ? [TextSpan(text: ' *', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold))] : [],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextFieldWithLabel(String label, {
//     bool isRequired = false,
//     int maxLines = 1,
//     String? hintText,
//     TextEditingController? controller,
//     TextInputType? keyboardType,
//     void Function()? onEditingComplete
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         _buildLabel(label, isRequired: isRequired),
//         TextField(
//           controller: controller,
//           maxLines: maxLines,
//           keyboardType: keyboardType,
//           onEditingComplete: onEditingComplete,
//           decoration: InputDecoration(
//             hintText: hintText,
//             border: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Colors.grey[400]!)),
//             focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4.0), borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5)),
//             contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//           ),
//           style: const TextStyle(fontSize: 15.0),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTableCell(String text, {bool isHeader = false, TextAlign textAlign = TextAlign.left}) {
//     return TableCell(
//       verticalAlignment: TableCellVerticalAlignment.middle,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//         child: Text(
//           text,
//           style: TextStyle(
//               fontSize: 13.0,
//               fontWeight: isHeader ? FontWeight.w500 : FontWeight.normal,
//               color: Colors.black87),
//           textAlign: textAlign,
//         ),
//       ),
//     );
//   }
//
//   Future<void> _showShippingMethodSelectionDialog(BuildContext context) async {
//     String? tempSelectedShippingId = _selectedShippingMethodId;
//
//     await showDialog<void>(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return StatefulBuilder(
//           builder: (stfContext, stfSetState) {
//             return AlertDialog(
//               title: const Text('Select Shipping Method'),
//               content: SingleChildScrollView(
//                 child: ListBody(
//                   children: _displayableShippingMethods.map((method) {
//                     return RadioListTile<String>(
//                       title: Text("${method['title']} (${method['carrier']})"),
//                       subtitle: Text(method['price_str'] as String),
//                       value: method['id'] as String,
//                       groupValue: tempSelectedShippingId,
//                       onChanged: (String? value) {
//                         if (value != null) {
//                           stfSetState(() {
//                             tempSelectedShippingId = value;
//                           });
//                         }
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//               actions: <Widget>[
//                 TextButton(
//                   child: const Text('Cancel'),
//                   onPressed: () => Navigator.of(dialogContext).pop(),
//                 ),
//                 TextButton(
//                   child: const Text('Select'),
//                   onPressed: () {
//                     if (tempSelectedShippingId != null) {
//                       setState(() {
//                         _selectedShippingMethodId = tempSelectedShippingId!;
//                         final newSelectedMethodData = _displayableShippingMethods.firstWhere(
//                                 (m) => m['id'] == _selectedShippingMethodId
//                         );
//                         currentShippingCost = newSelectedMethodData['price_val'] as double;
//                         selectedShippingMethodName = newSelectedMethodData['title'] as String;
//                         carrierCode = newSelectedMethodData['carrier_code'] as String;
//                         methodCode = newSelectedMethodData['method_code'] as String;
//                       });
//                     }
//                     Navigator.of(dialogContext).pop();
//                   },
//                 ),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
//
//
//   Widget _buildShippingMethodsSection(ShippingState state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Shipping Methods',
//           style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold, color: Colors.black87),
//         ),
//         const SizedBox(height: 8.0),
//         Divider(height: 1, thickness: 0.8, color: Colors.grey[300]),
//         const SizedBox(height: 16.0),
//
//         if (_isFetchingShippingMethods)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.0),
//             child: Center(child: Text("Estimating shipping costs...")),
//           )
//         else if (_displayableShippingMethods.isEmpty)
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 20.0),
//             child: Center(child: Text("Please select a country to estimate shipping.")),
//           )
//         else ...[
//                 () {
//               Map<String, dynamic>? determinedShippingMethod;
//               if (_selectedShippingMethodId != null) {
//                 try {
//                   determinedShippingMethod = _displayableShippingMethods.firstWhere(
//                         (m) => m['id'] == _selectedShippingMethodId,
//                   );
//                 } catch (e) {
//                   if (kDebugMode) print("Error finding selected shipping method ID '$_selectedShippingMethodId'. $e");
//                   determinedShippingMethod = null;
//                 }
//               }
//
//               if (determinedShippingMethod == null) {
//                 // This can happen if the selected ID is no longer in the list after a refresh
//                 return const Padding(
//                   padding: EdgeInsets.symmetric(vertical: 20.0),
//                   child: Center(child: Text("Please re-select a shipping method.")),
//                 );
//               }
//
//               return Table(
//                 border: TableBorder.all(color: Colors.grey.shade300, width: 1),
//                 columnWidths: const {
//                   0: IntrinsicColumnWidth(flex: 0.7),
//                   1: FlexColumnWidth(1),
//                   2: FlexColumnWidth(1.2),
//                   3: FlexColumnWidth(1.2),
//                 },
//                 children: [
//                   TableRow(
//                     decoration: BoxDecoration(color: Colors.grey[100]),
//                     children: [
//                       _buildTableCell('Select Method', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Price', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Method Title', isHeader: true, textAlign: TextAlign.center),
//                       _buildTableCell('Carrier Title', isHeader: true, textAlign: TextAlign.center),
//                     ],
//                   ),
//                   TableRow(
//                     children: [
//                       TableCell(
//                         verticalAlignment: TableCellVerticalAlignment.middle,
//                         child: Center(
//                           child: Radio<String>(
//                             value: determinedShippingMethod['id'] as String,
//                             groupValue: _selectedShippingMethodId,
//                             onChanged: null,
//                             activeColor: Theme.of(context).primaryColor,
//                           ),
//                         ),
//                       ),
//                       _buildTableCell(
//                         '₹${(determinedShippingMethod['price_val'] as double).toStringAsFixed(2)}',
//                         textAlign: TextAlign.center,
//                       ),
//                       _buildTableCell(
//                         determinedShippingMethod['title'] as String,
//                         textAlign: TextAlign.center,
//                       ),
//                       _buildTableCell(
//                         determinedShippingMethod['carrier'] as String,
//                         textAlign: TextAlign.center,
//                       ),
//                     ],
//                   ),
//                 ],
//               );
//             }(),
//
//             const SizedBox(height: 24.0),
//
//             Align(
//               alignment: Alignment.centerRight,
//               child: BlocBuilder<ShippingBloc, ShippingState>(
//                 builder: (context, state) {
//                   final isSubmitting = state is ShippingInfoSubmitting;
//
//                   // ✅ FIXED: Changed orElse to return Map<String, Object> to match inferred type.
//                   final determinedShippingMethod = _displayableShippingMethods.firstWhere(
//                         (m) => m['id'] == _selectedShippingMethodId,
//                     orElse: () => <String, Object>{}, // The fix is on this line
//                   );
//
//                   return ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.black,
//                       foregroundColor: Colors.white,
//                       padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
//                       textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
//                       disabledBackgroundColor: Colors.grey[700],
//                     ),
//                     onPressed: isSubmitting ? null : () async {
//                       if (_firstNameController.text.isEmpty ||
//                           _lastNameController.text.isEmpty ||
//                           _streetAddressController.text.isEmpty ||
//                           _cityController.text.isEmpty ||
//                           _zipController.text.isEmpty ||
//                           _phoneController.text.isEmpty ||
//                           selectedCountryId.isEmpty
//                       ) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please fill all required fields.')),
//                         );
//                         return;
//                       }
//                       if (determinedShippingMethod.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(content: Text('Please select a shipping method first.')),
//                         );
//                         return;
//                       }
//
//                       _saveCurrentSelectionsToPrefs();
//
//                       final prefs = await SharedPreferences.getInstance();
//                       final finalCarrierCode = prefs.getString('carrier_code') ?? carrierCode;
//                       final finalMethodCode = prefs.getString('method_code') ?? methodCode;
//
//                       context.read<ShippingBloc>().add(
//                         SubmitShippingInfo(
//                           firstName: _firstNameController.text,
//                           lastName: _lastNameController.text,
//                           streetAddress: _streetAddressController.text,
//                           city: _cityController.text,
//                           zipCode: _zipController.text,
//                           phone: _phoneController.text,
//                           email: _emailController.text.isNotEmpty ? _emailController.text : 'mitesh@gmail.com',
//                           countryId: selectedCountryId,
//                           regionName: selectedRegionName,
//                           regionId: selectedRegionId,
//                           regionCode: selectedRegionCode,
//                           carrierCode: finalCarrierCode,
//                           methodCode: finalMethodCode,
//                         ),
//                       );
//                     },
//                     child: isSubmitting
//                         ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2.5,
//                       ),
//                     )
//                         : const Text('NEXT'),
//                   );
//                 },
//               ),
//             ),
//           ],
//       ],
//     );
//   }
//
//   Widget _buildHelpButton() {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: ElevatedButton.icon(
//         onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Help button pressed!'))),
//         icon: const Icon(Icons.help_outline, color: Colors.white, size: 20),
//         label: const Text('Help', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
//         style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder(), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), elevation: 2.0),
//       ),
//     );
//   }
// }