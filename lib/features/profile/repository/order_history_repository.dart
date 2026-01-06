import 'dart:convert';
import 'package:aashniandco/constants/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/customer_address_model.dart';
import '../model/order_history.dart';

class OrderHistoryRepository {
  static const String baseUrl = "https://aashniandco.com";

  // In your OrderHistoryRepository.dart

// ... (other imports and the fetchOrders method)

  // In your OrderHistoryRepository.dart

  // Future<OrderDetails11> fetchOrderDetails(String orderId) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('user_token');
  //
  //   if (token == null) {
  //     throw Exception("Authentication Error: Token is missing.");
  //   }
  //
  //   final url = Uri.parse("$baseUrl/rest/V1/aashni/order-details/$orderId");
  //   print("Fetching details from URL: $url");
  //
  //   final response = await http.get(url, headers: {
  //     "Authorization": "Bearer $token",
  //     "Content-Type": "application/json",
  //   });
  //
  //   if (response.statusCode == 200) {
  //     // Decode the response, which we know is a List
  //     final List<dynamic> decodedList = json.decode(response.body);
  //
  //     // ✅ CALL THE NEW FACTORY that understands the list structure
  //     return OrderDetails11.fromKeylessList(decodedList);
  //
  //   } else {
  //     throw Exception(
  //         "API Error: Failed to load order details. Status: ${response.statusCode}, Body: ${response.body}");
  //   }
  // }

  Future<bool> deleteAddress(int addressId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      throw Exception("User not logged in or token is missing");
    }

    // Pass the addressId in the URL as per the webapi.xml definition
    final url = Uri.parse(
        "${ApiConstants.baseUrl}/V1/aashni-mobileapi/customer/address/delete/$addressId");

    print("=== Deleting Address ===");
    print("URL: $url");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      print("Address deleted successfully!");
      return true;
    } else {
      throw Exception(
        "Failed to delete address. Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }

  Future<OrderDetails11> fetchOrderDetails(String orderId, {bool isGuest = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    Uri url;
    Map<String, String> headers = {"Content-Type": "application/json"};

    if (isGuest) {
      // Guest order endpoint
      url = Uri.parse("$baseUrl/rest/V1/guest-carts/$orderId");
    } else {
      // Logged-in user endpoint
      if (token == null) {
        throw Exception("Authentication Error: Token is missing.");
      }
      headers["Authorization"] = "Bearer $token";
      url = Uri.parse("$baseUrl/rest/V1/aashni/order-details/$orderId");
    }

    print("Fetching order details from: $url");

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Guest JSON may be a Map, logged-in JSON may be a List
      if (data is List) {
        return OrderDetails11.fromKeylessList(data);
      } else if (data is Map) {
        // Convert guest JSON to a "keyless list" for compatibility
        final keylessList = [
          data['reserved_order_id'] ?? '',   // incrementId
          data['created_at'] ?? '',          // createdAt
          'Pending',                         // status
          data['billing_address'] ?? {},     // shipTo
          data['billing_address'] ?? {},     // billingAddress
          'N/A',                             // shippingMethod
          {'title': 'Guest Payment'},        // paymentMethod
          data['items'] ?? [],               // items
          {
            'subtotal': (data['currency']['base_currency_code'] ?? 0),
            'shipping': 0,
            'grand_total': 0,
            'currency_code': data['currency']['base_currency_code'] ?? 'INR'
          }
        ];
        return OrderDetails11.fromKeylessList(keylessList);
      } else {
        throw Exception("Unexpected API response format.");
      }
    } else {
      throw Exception(
          "API Error: Failed to load order details. Status: ${response.statusCode}, Body: ${response.body}");
    }
  }


  Future<List<OrderSummary>> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final customerId = prefs.getString('customer_id');

    if (token == null || customerId == null) {
      throw Exception("User not logged in or customer ID is missing");
    }

    final url = Uri.parse("${ApiConstants.baseUrl}/V1/customer/order/$customerId");
    print("Fetching orders from URL: $url");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
    });

    // ✅ A SINGLE, CLEAR IF/ELSE BLOCK
    if (response.statusCode == 200) {
      // This is the SUCCESS path. It returns the list of orders.
      final List<dynamic> ordersJson = json.decode(response.body);
      return ordersJson
          .map((json) => OrderSummary.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      // This is the FAILURE path. It covers ALL other status codes (401, 404, 500, etc.).
      // It throws an exception, which is a valid way to exit the function.
      throw Exception("Failed to load orders: ${response.statusCode} ${response.body}");
    }
    // Now there are no possible paths where the function can end without
    // either returning a value or throwing an exception.
  }

//  Get Address

  Future<List<CustomerAddress>> fetchAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final customerId = prefs.getString('customer_id');

    if (token == null || customerId == null) {
      throw Exception("User not logged in or customer ID is missing");
    }
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/V1/customers/me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final addresses = (data['addresses'] as List)
          .map((a) => CustomerAddress.fromJson(a))
          .toList();
      return addresses;
    } else {
      throw Exception("Failed to load addresses");
    }
  }

  // In OrderHistoryRepository.dart

  // In OrderHistoryRepository.dart

  // In OrderHistoryRepository.dart

  // Future<bool> saveAddress(CustomerAddress address, {String? region, String? regionId}) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('user_token');
  //
  //   if (token == null) {
  //     throw Exception("User not logged in or token is missing");
  //   }
  //
  //   final url = Uri.parse("https://stage.aashniandco.com/rest/V1/aashni/me/address");
  //
  //   final Map<String, dynamic> body = {
  //     "firstname": address.firstname,
  //     "lastname": address.lastname,
  //     "street": address.street.split('\n'),
  //     "city": address.city,
  //     "postcode": address.postcode,
  //     "country_id": address.country,
  //     "telephone": address.telephone,
  //     "is_default_billing": address.isDefaultBilling,
  //     "is_default_shipping": address.isDefaultShipping,
  //     // --- ADD THE REGION DATA IF IT EXISTS ---
  //     if (regionId != null) "region_id": regionId,
  //     if (region != null) "region": region,
  //   };
  //
  //   print("--- SAVING ADDRESS (with Region data) ---");
  //   print("URL: $url");
  //   print("BODY: ${jsonEncode(body)}");
  //
  //   final response = await http.post(
  //     url,
  //     headers: {
  //       "Authorization": "Bearer $token",
  //       "Content-Type": "application/json",
  //     },
  //     body: jsonEncode(body),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     print("Address saved successfully!");
  //     return true;
  //   } else {
  //     throw Exception(
  //         "Failed to save address. Status: ${response.statusCode}, Body: ${response.body}");
  //   }
  // }


  Future<bool> saveAddress(
      CustomerAddress address, {
        String? region,
        String? regionId,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final customerId = prefs.getString('customer_id');

    if (token == null || customerId == null) {
      throw Exception("User not logged in or token is missing");
    }

    final url = Uri.parse(
        "${ApiConstants.baseUrl}/V1/aashni-mobileapi/customer/address/save");

    final Map<String, dynamic> body = {
      "customerId": int.parse(customerId), // ✅ from SharedPreferences
      "firstname": address.firstname,
      "lastname": address.lastname,
      "street": address.street, // API expects single string
      "city": address.city,
      "postcode": address.postcode,
      "countryId": address.country,
      "telephone": address.telephone,
      "isDefaultBilling": address.isDefaultBilling,
      "isDefaultShipping": address.isDefaultShipping,
      if (region != null) "region": region,
      if (regionId != null) "regionId": int.tryParse(regionId),
    };

    print("=== Saving Address ===");
    print("URL: $url");
    print("BODY: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Address saved successfully!");
      return true;
    } else {
      throw Exception(
        "Failed to save address. Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }


  Future<bool> updateAddress(
      CustomerAddress address, {
        String? region,
        String? regionId,
      }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    final customerId = prefs.getString('customer_id');

    if (token == null || customerId == null) {
      throw Exception("User not logged in or token is missing");
    }

    final url = Uri.parse(
        "${ApiConstants.baseUrl}/V1/aashni-mobileapi/customer/address/update");

    final Map<String, dynamic> body = {
      "addressId": address.id, // ✅ Crucial for update
      "customerId": int.parse(customerId),
      "firstname": address.firstname,
      "lastname": address.lastname,
      "street": address.street,
      "city": address.city,
      "postcode": address.postcode,
      "countryId": address.country,
      "telephone": address.telephone,
      "isDefaultBilling": address.isDefaultBilling,
      "isDefaultShipping": address.isDefaultShipping,
      if (region != null) "region": region,
      if (regionId != null) "regionId": int.tryParse(regionId),
    };

    print("=== Updating Address ===");
    print("URL: $url");
    print("BODY: ${jsonEncode(body)}");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print("Address updated successfully!");
      return true;
    } else {
      throw Exception(
        "Failed to update address. Status: ${response.statusCode}, Body: ${response.body}",
      );
    }
  }

  Future<OrderDetails11> fetchGuestOrderDetails({
    required String orderIncrementId,
    required String email,
  }) async {
    final url = Uri.parse("$baseUrl/rest/V1/solr/guest/order");

    print("guesturl>>$url");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "orderIncrementId": orderIncrementId,
        "email": email,
      }),
    );
    print("Response Body: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Magento returns keyless list, parse it:
      return OrderDetails11.fromKeylessList(data);
    } else {
      throw Exception(
          "Failed to fetch guest order. Status: ${response.statusCode}, Body: ${response.body}");
    }
  }



}
