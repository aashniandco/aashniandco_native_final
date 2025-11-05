import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../../constants/api_constants.dart';
import '../bloc/order_details_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import '../model/order_details_model.dart';


class OrderRepository {
  // TODO: Replace with your actual Magento URL
  static const String _baseUrl = 'https://aashniandco.com/rest';

  Future<String?> _getCustomerToken() async {
    final prefs = await SharedPreferences.getInstance();
    // TODO: Make sure the key 'customer_token' matches what you use after login
    return prefs.getString('user_token');
  }

  // Future<OrderDetails> fetchOrderDetails(int orderEntityId) async {
  //   if (kDebugMode) print("--- Fetching details for Order Entity ID: $orderEntityId ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User is not logged in.");
  //   }
  //
  //   // Your new endpoint
  //   final url = Uri.parse('$_baseUrl/aashni/order-details/$orderEntityId');
  //   print("url>>entiti$url");
  //
  //   final response = await http.get( // Use your preferred HTTP client
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //   );
  //
  //   if (kDebugMode) {
  //     print("Order Details API Response Status: ${response.statusCode}");
  //     print("Order Details API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Parse the JSON using the model we created
  //     return OrderDetails.fromJson(json.decode(response.body));
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     throw Exception(errorBody['message'] ?? "Failed to load order details.");
  //   }
  // }
//30/9/2025
  Future<OrderDetails> fetchOrderDetails(int orderId) async {

    final token = await _getCustomerToken();
    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/order-details/$orderId');
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);
    final response = await ioClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    // =========================================================================
    // ✅ PRINT THE RAW RESPONSE BODY HERE
    // This will show the exact string the server sent.
    // =========================================================================
    print("--- Raw API Response (Order Details) ---");
    print(response.body);
    print("----------------------------------------");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("--- Decoded Dart Object (Order Details) ---");
      print(data);
      print("-------------------------------------------");
      return OrderDetails.fromJson(data);
    } else {
      // Decode the error message from Magento for better feedback
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ??
          'Failed to load order details.';
      throw Exception(errorMessage);
    }
  }
}