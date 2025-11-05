import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http; // Import the http package with a prefix
import 'package:shared_preferences/shared_preferences.dart';

// lib/features/shoppingbag/repository/cart_repository.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming you have an AuthRepository.dart file for this import
// import 'package:your_app/repositories/auth_repository.dart';

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming you have an AuthRepository.dart file for this import
// import 'package:your_app/repositories/auth_repository.dart';

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/api_constants.dart';

class CartRepository {
  final IOClient ioClient;
//   final IOClient _client;
  final String _baseUrl = 'https://aashniandco.com/rest/V1';
  CartRepository()
      : ioClient = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );


  Future<void> setCustomShippingPrice(double shippingPrice) async {
    if (kDebugMode) {
      print("--- ShippingRepository: Calling CUSTOM API to set shipping price: $shippingPrice ---");
    }

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for setting custom shipping price");
    }

    // This is the NEW custom API URL you defined in webapi.xml
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/carts/mine/set-shipping-price');

    final response = await this.ioClient.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
      // The body just contains the price
      body: json.encode({"shippingPrice": shippingPrice}),
    );

    if (kDebugMode) {
      print("Custom API Response Status: ${response.statusCode}");
      print("Custom API Response Body: ${response.body}");
    }

    if (response.statusCode != 200) {
      // It failed, throw an exception
      final errorBody = json.decode(response.body);
      throw Exception("Failed to set custom shipping price: ${errorBody['message']}");
    }
  }

  Future<bool> applyCoupon(String couponCode) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    late Uri url;
    late Map<String, dynamic> body;
    late Map<String, String> headers;

    if (customerToken != null && customerToken.isNotEmpty) {
      // ✅ Logged-in user
      url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/cart/apply-coupon');
      body = {'couponCode': couponCode};
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      };
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // ✅ Guest user uses guest-specific endpoint
      url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/guest-cart/apply-coupon-guest');
      body = {'couponCode': couponCode, 'cartId': guestQuoteId};
      headers = {'Content-Type': 'application/json'};
    } else {
      throw Exception("No active session found for applying coupon.");
    }

    final response = await ioClient.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) == true;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to apply coupon.');
    }
  }
  Future<bool> removeCoupon() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    late Uri url;
    late Map<String, dynamic> body;
    late Map<String, String> headers;

    if (customerToken != null && customerToken.isNotEmpty) {
      // ✅ Logged-in user
      url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/cart/remove-coupon');
      body = {};
      headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      };
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // ✅ Guest user
      url = Uri.parse('${ApiConstants.baseUrl}/V1/aashni/guest-cart/remove-coupon');
      body = {'cartId': guestQuoteId};
      headers = {'Content-Type': 'application/json'};
    } else {
      throw Exception("No active session found for removing coupon.");
    }

    final response = await ioClient.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) == true;
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(errorBody['message'] ?? 'Failed to remove coupon.');
    }
  }

  Future<String> ensureGuestCartId() async {
    final prefs = await SharedPreferences.getInstance();
    String? guestQuoteId = prefs.getString('guest_quote_id');

    if (guestQuoteId == null || guestQuoteId.isEmpty) {
      // Create new guest cart
      final newId = await createGuestCart();
      await prefs.setString('guest_quote_id', newId);
      guestQuoteId = newId;
    }

    print("✅ Using guestQuoteId: $guestQuoteId");
    return guestQuoteId!;
  }

  Future<String> createGuestCart() async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts');
    final response = await ioClient.post(url);

    if (response.statusCode == 200) {
      final guestCartId = json.decode(response.body) as String;
      print("🛒 Created new guest cart: $guestCartId");
      return guestCartId;
    } else {
      throw Exception("❌ Failed to create guest cart: ${response.body}");
    }
  }

  Future<List<dynamic>> fetchCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }

    final response = await ioClient.get(
      Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );


    if (response.statusCode == 200) {
      print("cart body: ${response.body}");
      return json.decode(response.body);

    }

    else {
      throw Exception("Failed to fetch cart items: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchTotal() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    http.Response response;

    if (customerToken != null && customerToken.isNotEmpty) {
      // --- PATH FOR LOGGED-IN USERS (No change here) ---
      debugPrint("Fetching totals for LOGGED-IN user.");
      final url = Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/totals');
      response = await ioClient.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $customerToken',
        },
      );

    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // --- ✅ START: ADDED PATH FOR GUEST USERS ---
      debugPrint("Fetching totals for GUEST user with cart ID: $guestQuoteId");
      // Use the standard Magento endpoint for guest cart totals
      final url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId/totals');
      response = await ioClient.get(url);
      // --- ✅ END: ADDED PATH FOR GUEST USERS ---

    } else {
      // This will now only be thrown if there is truly no session.
      throw Exception("No active session found to fetch cart totals.");
    }

    debugPrint("Fetch Totals Response [${response.statusCode}]: ${response.body}");

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final errorBody = json.decode(response.body);
      throw Exception("Failed to fetch cart totals: ${errorBody['message'] ?? response.body}");
    }
  }
  // live*
  // Future<Map<String, dynamic>> fetchTotal() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in");
  //   }
  //
  //   final response = await ioClient.get(
  //     Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/totals'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     print("Total cart weight: ${data['weight']}");
  //     return data;
  //   } else {
  //     throw Exception("Failed to fetch cart total: ${response.body}");
  //   }
  // }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in");
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $customerToken',
    };
  }



  Future<List<Map<String, dynamic>>> getCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    http.Response? response;

    if (customerToken != null && customerToken.isNotEmpty) {
      // --- LOGGED-IN USER ---
      response = await ioClient.get(
        Uri.parse('${ApiConstants.baseUrl}/V1/carts/mine/items'),

        headers: await _getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return (json.decode(response.body) as List).cast<Map<String, dynamic>>();
      } else {
        // A 404 for a logged-in user's cart means it's empty.
        if (response.statusCode == 404) return [];
        throw Exception("Failed to fetch user cart items: ${response.body}");
      }
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // --- GUEST USER ---
      try {
        print("guestQuoteId>>>>>$guestQuoteId");
        // print("guestItemId>>$itemId");
        final guestCart = await fetchGuestCart(guestQuoteId);
        final items = guestCart['items'] as List?;
        return items?.cast<Map<String, dynamic>>() ?? [];
      } catch (e) {
        // If fetching the guest cart fails (e.g., it expired), treat it as empty.
        return [];
      }
    } else {
      // --- NO ACTIVE SESSION ---
      return [];
    }
  }

// In: class CartRepository

  Future<double> fetchCartTotalWeight() async {
    try {
      final items = await getCartItems();
      if (items.isEmpty) {
        return 0.0;
      }

      double totalWeight = 0.0;

      // Check if the first item already has weight.
      if (items.first.containsKey('weight') && items.first['weight'] != null) {
        print("✅ Weight found in cart items. Using efficient calculation.");
        for (final item in items) {
          final itemWeight = double.tryParse(item['weight']?.toString() ?? '0.0') ?? 0.0;
          final itemQty = (item['qty'] as num?)?.toInt() ?? 1;
          totalWeight += (itemWeight * itemQty);
        }
      } else {
        // --- WORKAROUND PATH: Weight is missing, fetch it for each item. ---
        print("⚠️ Weight not in cart items. Fetching weight for each SKU (less efficient).");

        final List<Future<void>> weightFutures = [];

        for (final item in items) {
          final itemSku = item['sku'];
          final itemQty = (item['qty'] as num?)?.toInt() ?? 1;

          if (itemSku != null) {
            final uri = Uri.parse('$_baseUrl/products/$itemSku');
            print("🔗 Fetching product data from URL: $uri");

            final future = ioClient.get(uri).then((productResponse) {
              // ✅ --- START OF CHANGE: ADDED DETAILED LOGGING ---
              print("   - Product SKU '$itemSku' Response Status: ${productResponse.statusCode}");

              if (productResponse.statusCode == 200) {
                final productData = json.decode(productResponse.body);

                // More robustly parse the weight, defaulting to 0.0 if null or not a number.
                final itemWeight = (productData['weight'] as num?)?.toDouble() ?? 0.0;

                print("   - ✅ Found weight for '$itemSku': $itemWeight");
                totalWeight += (itemWeight * itemQty);

              } else {
                // Log the error if the product fetch failed
                print("   - ❌ Failed to fetch product data for '$itemSku'. Body: ${productResponse.body}");
              }
              // ✅ --- END OF CHANGE ---
            }).catchError((e) {
              // Catch any errors during the HTTP request itself
              print("   - ❌ Error during API call for '$itemSku': $e");
            });
            weightFutures.add(future);
          }
        }

        // Wait for all the individual product API calls to complete.
        await Future.wait(weightFutures);
      }

      print("✅ Final calculated total cart weight: $totalWeight");
      return totalWeight;

    } catch (e) {
      print("❌ Critical error in fetchCartTotalWeight: $e");
      return 0.0;
    }
  }
  // Future<double> fetchCartTotalWeight() async {
  //   try {
  //     final items = await getCartItems();
  //     if (items.isEmpty) {
  //       return 0.0;
  //     }
  //
  //     double totalWeight = 0.0;
  //
  //     // Check if the first item already has weight. If so, use the efficient method.
  //     if (items.first.containsKey('weight') && items.first['weight'] != null) {
  //       print("✅ Weight found in cart items. Using efficient calculation.");
  //       for (final item in items) {
  //         final itemWeight = double.tryParse(item['weight']?.toString() ?? '0.0') ?? 0.0;
  //         final itemQty = (item['qty'] as num?)?.toInt() ?? 1;
  //         totalWeight += (itemWeight * itemQty);
  //       }
  //     } else {
  //       // --- WORKAROUND PATH: Weight is missing, fetch it for each item. ---
  //       print("⚠️ Weight not in cart items. Fetching weight for each SKU (less efficient).");
  //
  //       // Use Future.wait to make all API calls in parallel for better performance.
  //       final List<Future<void>> weightFutures = [];
  //
  //       for (final item in items) {
  //         final itemSku = item['sku'];
  //         final itemQty = (item['qty'] as num?)?.toInt() ?? 1;
  //
  //         if (itemSku != null) {
  //           final uri = Uri.parse('$_baseUrl/products/$itemSku');
  //           print("🔗 Fetching product data from URL: $uri");
  //
  //           final future = ioClient.get(uri).then((productResponse) {
  //             if (productResponse.statusCode == 200) {
  //               final productData = json.decode(productResponse.body);
  //               final itemWeight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
  //               totalWeight += (itemWeight * itemQty);
  //             }
  //           });
  //           weightFutures.add(future);
  //         }
  //       }
  //
  //       // for (final item in items) {
  //       //   final itemSku = item['sku'];
  //       //   final itemQty = (item['qty'] as num?)?.toInt() ?? 1;
  //       //
  //       //   if (itemSku != null) {
  //       //     final future = ioClient.get(
  //       //       Uri.parse('$_baseUrl/products/$itemSku'),
  //       //
  //       //       // This endpoint is often public, but might need admin token if secured
  //       //       // headers: { 'Authorization': 'Bearer YOUR_ADMIN_TOKEN_IF_NEEDED' }
  //       //     ).then((productResponse) {
  //       //       if (productResponse.statusCode == 200) {
  //       //         final productData = json.decode(productResponse.body);
  //       //         final itemWeight = (productData['weight'] as num?)?.toDouble() ?? 0.0;
  //       //         // Use a lock or thread-safe addition if needed, but for this case direct addition is fine.
  //       //         totalWeight += (itemWeight * itemQty);
  //       //       }
  //       //     });
  //       //     weightFutures.add(future);
  //       //   }
  //       // }
  //       // Wait for all the individual product API calls to complete.
  //       await Future.wait(weightFutures);
  //     }
  //
  //     print("✅ Correctly calculated total cart weight: $totalWeight");
  //     return totalWeight;
  //
  //   } catch (e) {
  //     print("❌ Error calculating total cart weight: $e");
  //     return 0.0;
  //   }
  // }
  // Future<double> fetchCartTotalWeight() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   final guestQuoteId = prefs.getString('guest_quote_id');
  //   final customerId = prefs.getInt('user_customer_id');
  //
  //   if (customerToken != null && customerToken.isNotEmpty && customerId != null) {
  //     // --- LOGGED-IN USER ---
  //     try {
  //       // This is your custom endpoint
  //       final response = await ioClient.get(
  //         Uri.parse('$_baseUrl/cart/details/$customerId'),
  //         headers: await _getAuthHeaders(),
  //       );
  //       if (response.statusCode == 200) {
  //         final data = json.decode(response.body) as List<dynamic>;
  //         if (data.isEmpty) return 0.0;
  //         return double.tryParse(data[0]['total_cart_weight'].toString()) ?? 0.0;
  //       }
  //       return 0.0;
  //     } catch (e) { return 0.0; }
  //   } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
  //     // --- GUEST USER ---
  //     // The standard guest cart API includes the weight
  //     try {
  //       final guestCart = await fetchGuestCart(guestQuoteId);
  //       return (guestCart['items_weight'] as num?)?.toDouble() ?? 0.0;
  //     } catch (e) { return 0.0; }
  //   } else {
  //     // --- NO ACTIVE SESSION ---
  //     return 0.0;
  //   }
  // }

  // Future<Map<String, dynamic>> fetchGuestCart(String guestQuoteId) async {
  //   final url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId');
  //   print("Calling Guest Cart API: $url"); // ✅ Print the full URL
  //
  //   final response = await ioClient.get(url);
  //
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to load guest cart: ${response.body}');
  //   }
  // }

  //19/9/2025
  Future<Map<String, dynamic>> fetchGuestCart(String guestQuoteId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/$guestQuoteId');
    print("Calling Guest Cart API: $url"); // ✅ Print the full URL

    final response = await ioClient.get(url);

    print("Guest Cart Response Status Code: ${response.statusCode}");
    print("Guest Cart Response Status CodeResponse Body: ${response.body}");

    if (response.statusCode == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('guest_quote_id', guestQuoteId);
      print("✅ Saved guest_quote_id to SharedPreferences cart_repository: $guestQuoteId");
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load guest cart: ${response.body}');
    }
  }




  Future<bool> removeItem(int itemId) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    http.Response response;

    if (customerToken != null && customerToken.isNotEmpty) {
      // --- ✅ START: LOGGED-IN USER FIX ---

      final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/cart/item/delete');

      final body = json.encode({
        "item_id": itemId,
      });

      if (kDebugMode) {
        print("Logged-in User Remove Item URL: $url");
        print("Logged-in User Remove Item Body: $body");
      }

      response = await ioClient.post(
        url,
        headers: {
          'Authorization': 'Bearer $customerToken',
          // This header is crucial for Magento to parse the JSON body
          'Content-Type': 'application/json',
        },
        body: body,
      );
      // --- ✅ END: LOGGED-IN USER FIX ---

    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // --- GUEST USER ---
      // Calls your new endpoint: POST /V1/guest-carts/delete-item
      // The PHP function deleteGuestItem($cartId, $itemId) implies query parameters.
      print("guestQuoteId>>$guestQuoteId");
      print("guestItemId>>$itemId");
      final url = Uri.parse('${ApiConstants.baseUrl}/V1/guest-carts/delete-item?cartId=$guestQuoteId&itemId=$itemId');
      response = await ioClient.post(
        url,
        // No authorization header for guests
      );

    } else {
      throw Exception("No active session to remove cart item.");
    }

    if (response.statusCode != 200) {
      final error = json.decode(response.body);
      throw Exception("Failed to remove item: ${error['message'] ?? response.body}");
    }

    // Your backend has two different success response formats. This handles both.
    // Logged-in returns: [true]
    // Guest returns: true
    final resData = jsonDecode(response.body);
    return (resData is bool && resData == true) || (resData is List && resData.isNotEmpty && resData[0] == true);
  }


  Future<int?> updateCartItemQty(int itemId, int qty) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    http.Response response;

    if (customerToken != null && customerToken.isNotEmpty) {
      // --- ✅ START: LOGGED-IN USER FIX ---

      // 1. Define the correct endpoint URL without query parameters.
      final uri = Uri.parse("${ApiConstants.baseUrl}/V1/solr/cart/item/updateQty");

      // 2. Create the raw JSON body.
      final body = json.encode({
        "item_id": itemId,
        "qty": qty,
      });

      if (kDebugMode) {
        print("Logged-in User Cart Update URL: $uri");
        print("Logged-in User Cart Update Body: $body");
      }

      // 3. Make the POST request with the JSON body.
      response = await ioClient.post(
        uri,
        headers: {
          'Authorization': 'Bearer $customerToken',
          'Content-Type': 'application/json',
        },
        body: body, // Send the data in the body
      );
      // --- ✅ END: LOGGED-IN USER FIX ---

    }else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // --- GUEST USER ---
      // Calls your new endpoint: POST /V1/solr/guest-cart/item/updateQty
      // The PHP function updateGuestCartItemQty() uses getContent(), so it expects a JSON body.
      final uri = Uri.parse("${ApiConstants.baseUrl}/V1/solr/guest-cart/item/updateQty");
      final body = json.encode({
        "cart_id": guestQuoteId,
        "item_id": itemId,
        "qty": qty,
      });

      if (kDebugMode) {
        print("Guest Cart Update URL: $uri");
        print("Guest Cart Update Body: $body");
      }

      response = await ioClient.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

    } else {
      throw Exception("No active session to update cart item.");
    }

    if (kDebugMode) {
      print("Update Qty Response [${response.statusCode}]: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Both of your backend functions return the same structure: [true, "message", { 'qty': ... }]
      if (data is List && data.isNotEmpty && data[0] == true) {
        if (data.length > 2 && data[2] is Map && data[2]['qty'] != null) {
          final updatedQty = data[2]['qty'];
          return updatedQty is int ? updatedQty : int.tryParse(updatedQty.toString());
        }
        return qty; // Fallback to the requested qty on success
      } else {
        // Handle the case where data[0] is false
        throw Exception("Failed to update qty: ${data[1]}");
      }
    } else {
      final error = json.decode(response.body);
      throw Exception("Failed to update qty (HTTP ${response.statusCode}): ${error['message'] ?? response.body}");
    }
  }

}

// class CartRepository {
//   final IOClient _client;
//   final String _baseUrl = 'https://stage.aashniandco.com/rest/V1';
//
//   CartRepository()
//       : _client = IOClient(
//     HttpClient()..badCertificateCallback = (cert, host, port) => true,
//   );
//
//   // Helper for logged-in user API calls
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $customerToken',
//     };
//   }
//
//   // --- Methods for FETCHING cart data ---
//   // (No changes needed in this section)
//
//   Future<Map<String, dynamic>> fetchGuestCart(String guestQuoteId) async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/guest-carts/$guestQuoteId'),
//     );
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load guest cart: ${response.body}');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getCartItems() async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/carts/mine/items'),
//       headers: await _getAuthHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return (json.decode(response.body) as List).cast<Map<String, dynamic>>();
//     } else {
//       throw Exception("Failed to fetch cart items: ${response.body}");
//     }
//   }
//
//   Future<double> fetchCartTotalWeight(int customerId) async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/cart/details/$customerId'),
//       headers: await _getAuthHeaders(),
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List<dynamic>;
//       if (data.isEmpty) return 0.0;
//       final weightStr = data[0]['total_cart_weight'];
//       return double.tryParse(weightStr.toString()) ?? 0.0;
//     } else {
//       return 0.0;
//     }
//   }
//
//   // --- Methods for MODIFYING the cart (Guest + User Logic) ---
//
//   // ✅✅✅ EDITED TO MATCH NEW MAGENTO API ✅✅✅
//   Future<bool> removeItem(int itemId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     http.Response response;
//
//     if (customerToken != null && customerToken.isNotEmpty) {
//       // LOGGED-IN USER (No change here, assuming it works)
//       final url = Uri.parse('$_baseUrl/solr/cart/item/delete?item_id=$itemId');
//       if (kDebugMode) print("DELETE [USER]: $url");
//       response = await _client.post(url, headers: {'Authorization': 'Bearer $customerToken'});
//
//     } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       // GUEST USER - MODIFIED
//       // The endpoint is now a POST to a different URL
//       final url = Uri.parse('$_baseUrl/guest-carts/delete-item');
//
//       // The body now needs to be a JSON object
//       final body = json.encode({
//         "cartId": guestQuoteId,
//         "itemId": itemId,
//       });
//
//       if (kDebugMode) {
//         print("DELETE [GUEST] POST URL: $url");
//         print("DELETE [GUEST] Body: $body");
//       }
//
//       // The method is now POST, not DELETE
//       response = await _client.post(url, headers: {'Content-Type': 'application/json'}, body: body);
//
//     } else {
//       throw Exception("Cannot remove item: No active user or guest session.");
//     }
//
//     if (kDebugMode) {
//       print("DELETE Response Status: ${response.statusCode}");
//       print("DELETE Response Body: ${response.body}");
//     }
//
//     if (response.statusCode == 200) {
//       // Your user-delete API returns a list, your guest-delete returns a boolean.
//       // This handles both cases correctly.
//       final successData = json.decode(response.body);
//       if (successData is bool) {
//         return successData;
//       }
//       if (successData is List && successData.isNotEmpty) {
//         return successData[0] == true;
//       }
//       return false;
//     } else {
//       throw Exception("Failed to remove item. Status: ${response.statusCode}");
//     }
//   }
//
//
//   // ✅✅✅ EDITED TO MATCH NEW MAGENTO API ✅✅✅
//   Future<Map<String, dynamic>> updateCartItemQty(int itemId, int qty) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     http.Response response;
//
//     // This will hold the final response data
//     Map<String, dynamic> responseData = {};
//
//     if (customerToken != null && customerToken.isNotEmpty) {
//       // LOGGED-IN USER (No change here, assuming it works)
//       final url = Uri.parse("$_baseUrl/solr/cart/item/updateQty?item_id=$itemId&qty=$qty");
//       if (kDebugMode) print("UPDATE [USER]: $url");
//       response = await _client.post(url, headers: {'Authorization': 'Bearer $customerToken'});
//
//     } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       // GUEST USER - MODIFIED
//       // The endpoint is now a POST request
//       final url = Uri.parse('$_baseUrl/solr/guest-cart/item/updateQty');
//
//       // The body is a simple JSON object with the required keys
//       final body = json.encode({
//         "cart_id": guestQuoteId,
//         "item_id": itemId,
//         "qty": qty,
//       });
//
//       if (kDebugMode) {
//         print("UPDATE [GUEST] POST URL: $url");
//         print("UPDATE [GUEST] Body: $body");
//       }
//
//       // The method is now POST, not PUT
//       response = await _client.post(url, headers: {'Content-Type': 'application/json'}, body: body);
//
//     } else {
//       throw Exception("Cannot update quantity: No active user or guest session.");
//     }
//
//     if (kDebugMode) {
//       print("UPDATE Response Status: ${response.statusCode}");
//       print("UPDATE Response Body: ${response.body}");
//     }
//
//     if (response.statusCode == 200) {
//       final decodedBody = json.decode(response.body);
//       // Your APIs return a list: [bool, string, data]. We need to parse this.
//       if (decodedBody is List && decodedBody.length >= 3 && decodedBody[0] == true) {
//         // Success case, return the data part
//         responseData = (decodedBody[2] as Map<String, dynamic>?) ?? {};
//       } else if (decodedBody is List) {
//         // Failure case, throw the message part
//         throw Exception("Failed to update quantity: ${decodedBody[1]}");
//       } else {
//         throw Exception("Unexpected response format from server.");
//       }
//       return responseData;
//     } else {
//       throw Exception("Failed to update quantity. Status: ${response.statusCode}");
//     }
//   }
// }

// class CartRepository {
//   final IOClient _client;
//   final String _baseUrl = 'https://stage.aashniandco.com/rest/V1';
//
//   CartRepository()
//       : _client = IOClient(
//     HttpClient()..badCertificateCallback = (cert, host, port) => true,
//   );
//
//   // Helper for logged-in user API calls
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $customerToken',
//     };
//   }
//
//   // --- Methods for FETCHING cart data ---
//   // (No changes needed in this section)
//
//   Future<Map<String, dynamic>> fetchGuestCart(String guestQuoteId) async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/guest-carts/$guestQuoteId'),
//     );
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       throw Exception('Failed to load guest cart: ${response.body}');
//     }
//   }
//
//   Future<List<Map<String, dynamic>>> getCartItems() async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/carts/mine/items'),
//       headers: await _getAuthHeaders(),
//     );
//     if (response.statusCode == 200) {
//       return (json.decode(response.body) as List).cast<Map<String, dynamic>>();
//     } else {
//       throw Exception("Failed to fetch cart items: ${response.body}");
//     }
//   }
//
//   Future<double> fetchCartTotalWeight(int customerId) async {
//     final response = await _client.get(
//       Uri.parse('$_baseUrl/cart/details/$customerId'),
//       headers: await _getAuthHeaders(),
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List<dynamic>;
//       if (data.isEmpty) return 0.0;
//       final weightStr = data[0]['total_cart_weight'];
//       return double.tryParse(weightStr.toString()) ?? 0.0;
//     } else {
//       return 0.0;
//     }
//   }
//
//   // --- Methods for MODIFYING the cart (Guest + User Logic) ---
//
//   // ✅✅✅ EDITED TO MATCH NEW MAGENTO API ✅✅✅
//   Future<bool> removeItem(int itemId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     http.Response response;
//
//     if (customerToken != null && customerToken.isNotEmpty) {
//       // LOGGED-IN USER (No change here, assuming it works)
//       final url = Uri.parse('$_baseUrl/solr/cart/item/delete?item_id=$itemId');
//       if (kDebugMode) print("DELETE [USER]: $url");
//       response = await _client.post(url, headers: {'Authorization': 'Bearer $customerToken'});
//
//     } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       // GUEST USER - MODIFIED
//       // The endpoint is now a POST to a different URL
//       final url = Uri.parse('$_baseUrl/guest-carts/delete-item');
//
//       // The body now needs to be a JSON object
//       final body = json.encode({
//         "cartId": guestQuoteId,
//         "itemId": itemId,
//       });
//
//       if (kDebugMode) {
//         print("DELETE [GUEST] POST URL: $url");
//         print("DELETE [GUEST] Body: $body");
//       }
//
//       // The method is now POST, not DELETE
//       response = await _client.post(url, headers: {'Content-Type': 'application/json'}, body: body);
//
//     } else {
//       throw Exception("Cannot remove item: No active user or guest session.");
//     }
//
//     if (kDebugMode) {
//       print("DELETE Response Status: ${response.statusCode}");
//       print("DELETE Response Body: ${response.body}");
//     }
//
//     if (response.statusCode == 200) {
//       // Your user-delete API returns a list, your guest-delete returns a boolean.
//       // This handles both cases correctly.
//       final successData = json.decode(response.body);
//       if (successData is bool) {
//         return successData;
//       }
//       if (successData is List && successData.isNotEmpty) {
//         return successData[0] == true;
//       }
//       return false;
//     } else {
//       throw Exception("Failed to remove item. Status: ${response.statusCode}");
//     }
//   }
//
//
//   // ✅✅✅ EDITED TO MATCH NEW MAGENTO API ✅✅✅
//   Future<Map<String, dynamic>> updateCartItemQty(int itemId, int qty) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     http.Response response;
//
//     // This will hold the final response data
//     Map<String, dynamic> responseData = {};
//
//     if (customerToken != null && customerToken.isNotEmpty) {
//       // LOGGED-IN USER (No change here, assuming it works)
//       final url = Uri.parse("$_baseUrl/solr/cart/item/updateQty?item_id=$itemId&qty=$qty");
//       if (kDebugMode) print("UPDATE [USER]: $url");
//       response = await _client.post(url, headers: {'Authorization': 'Bearer $customerToken'});
//
//     } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       // GUEST USER - MODIFIED
//       // The endpoint is now a POST request
//       final url = Uri.parse('$_baseUrl/solr/guest-cart/item/updateQty');
//
//       // The body is a simple JSON object with the required keys
//       final body = json.encode({
//         "cart_id": guestQuoteId,
//         "item_id": itemId,
//         "qty": qty,
//       });
//
//       if (kDebugMode) {
//         print("UPDATE [GUEST] POST URL: $url");
//         print("UPDATE [GUEST] Body: $body");
//       }
//
//       // The method is now POST, not PUT
//       response = await _client.post(url, headers: {'Content-Type': 'application/json'}, body: body);
//
//     } else {
//       throw Exception("Cannot update quantity: No active user or guest session.");
//     }
//
//     if (kDebugMode) {
//       print("UPDATE Response Status: ${response.statusCode}");
//       print("UPDATE Response Body: ${response.body}");
//     }
//
//     if (response.statusCode == 200) {
//       final decodedBody = json.decode(response.body);
//       // Your APIs return a list: [bool, string, data]. We need to parse this.
//       if (decodedBody is List && decodedBody.length >= 3 && decodedBody[0] == true) {
//         // Success case, return the data part
//         responseData = (decodedBody[2] as Map<String, dynamic>?) ?? {};
//       } else if (decodedBody is List) {
//         // Failure case, throw the message part
//         throw Exception("Failed to update quantity: ${decodedBody[1]}");
//       } else {
//         throw Exception("Unexpected response format from server.");
//       }
//       return responseData;
//     } else {
//       throw Exception("Failed to update quantity. Status: ${response.statusCode}");
//     }
//   }
// }

// class CartRepository {
//   final IOClient ioClient;
//
//   CartRepository()
//       : ioClient = IOClient(
//     HttpClient()..badCertificateCallback = (cert, host, port) => true,
//   );
//
//
//   // Helper to get auth headers for logged-in users
//   Future<Map<String, String>> _getAuthHeaders() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//     return {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $customerToken',
//     };
//   }
//   Future<void> setCustomShippingPrice(double shippingPrice) async {
//     if (kDebugMode) {
//       print("--- ShippingRepository: Calling CUSTOM API to set shipping price: $shippingPrice ---");
//     }
//
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in for setting custom shipping price");
//     }
//
//     // This is the NEW custom API URL you defined in webapi.xml
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/carts/mine/set-shipping-price');
//
//     final response = await this.ioClient.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//       // The body just contains the price
//       body: json.encode({"shippingPrice": shippingPrice}),
//     );
//
//     if (kDebugMode) {
//       print("Custom API Response Status: ${response.statusCode}");
//       print("Custom API Response Body: ${response.body}");
//     }
//
//     if (response.statusCode != 200) {
//       // It failed, throw an exception
//       final errorBody = json.decode(response.body);
//       throw Exception("Failed to set custom shipping price: ${errorBody['message']}");
//     }
//   }
//
//   Future<List<dynamic>> fetchCartItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final response = await ioClient.get(
//       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//
//     if (response.statusCode == 200) {
//       print("cart body: ${response.body}");
//       return json.decode(response.body);
//
//     }
//
//     else {
//       throw Exception("Failed to fetch cart items: ${response.body}");
//     }
//   }
//
//   Future<Map<String, dynamic>> fetchTotal() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final response = await ioClient.get(
//       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/totals'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       print("Total cart weight: ${data['weight']}");
//       return data;
//     } else {
//       throw Exception("Failed to fetch cart total: ${response.body}");
//     }
//   }
//
//
//   Future<List<Map<String, dynamic>>> getCartItems() async {
//     final rawItems = await fetchCartItems();
//     return rawItems.cast<Map<String, dynamic>>();
//   }
//
//
//   Future<double> fetchCartTotalWeight(int customerId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final response = await ioClient.get(
//       Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List<dynamic>;
//       if (data.isEmpty) {
//         return 0.0;
//       }
//       final firstItem = data[0] as Map<String, dynamic>;
//       final weightStr = firstItem['total_cart_weight'];
//       final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
//       return totalWeight;
//     } else {
//       throw Exception("Failed to fetch cart total weight: ${response.body}");
//     }
//   }
//
//
//   Future<bool> removeItem(int itemId) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     final url = Uri.parse(
//       'https://stage.aashniandco.com/rest/V1/solr/cart/item/delete?item_id=$itemId',
//     );
//
//     final response = await ioClient.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//     final resData = jsonDecode(response.body);
//     return resData is List && resData.isNotEmpty && resData[0] == true;
//   }
//
//   Future<int?> updateCartItemQty(int itemId, int qty) async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     final uri = Uri.parse(
//         "https://stage.aashniandco.com/rest/V1/solr/cart/item/updateQty?item_id=$itemId&qty=$qty");
//
//     final response = await ioClient.post(
//       uri,
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data is List && data.isNotEmpty && data[0] == true) {
//         if (data.length > 2 && data[2] is Map && data[2]['qty'] != null) {
//           final updatedQty = data[2]['qty'];
//           return updatedQty is int ? updatedQty : int.tryParse(updatedQty.toString());
//         }
//         return qty;
//       } else {
//         throw Exception("Failed to update qty: ${data[1]}");
//       }
//     } else {
//       throw Exception("HTTP error: ${response.statusCode}");
//     }
//   }
// }

