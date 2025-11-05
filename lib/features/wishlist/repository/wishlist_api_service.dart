// // lib/services/wishlist_api_service.dart
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class WishlistApiService {
//   final String _baseUrl = "https://stage.aashniandco.com/rest";
//
//   // Helper to create an HTTP client that trusts self-signed certs
//   http.Client _getHttpClient() {
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     return IOClient(httpClient);
//   }
//
//   // Helper to get the customer token
//   Future<String?> _getCustomerToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('user_token');
//   }
//
//   /// Adds a product to the customer's wishlist.
//   /// Corresponds to: POST /V1/wishlist/add/:productId
//   Future<bool> addToWishlist(int productId) async {
//     final token = await _getCustomerToken();
//     if (token == null) throw Exception('User not logged in');
//
//     print("token wishist>$token");
//     final client = _getHttpClient();
//     final response = await client.post(
//       Uri.parse('$_baseUrl/V1/wishlist/add/$productId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       print('Product $productId added to wishlist.');
//       return true;
//     } else {
//       print('Failed to add to wishlist: ${response.body}');
//       throw Exception('Failed to add to wishlist');
//     }
//   }
//
//   /// Fetches all items from the customer's wishlist.
//   /// ASSUMPTION: Uses a standard Magento endpoint. Change if your endpoint is different.
//   Future<List<dynamic>> getWishlistItems() async {
//     final token = await _getCustomerToken();
//     if (token == null) {
//       // Use print for immediate visibility in debug console
//       print('WISHLIST API ERROR: User not logged in. Token is null.');
//       throw Exception('User not logged in');
//     }
//
//     final client = _getHttpClient();
//     final url = Uri.parse('$_baseUrl/V1/wishlist');
//
//     try {
//       final response = await client.get(
//         url,
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Content-Type': 'application/json',
//         },
//       );
//
//       // ======================= DETAILED LOGGING =======================
//       print('--- WISHLIST API RESPONSE ---');
//       print('URL: $url');
//       print('Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');
//       print('-----------------------------');
//       // ===============================================================
//
//       if (response.statusCode == 200) {
//         // The response body is the raw JSON string
//         final dynamic decodedData = json.decode(response.body);
//
//         // Your API returns a direct list `[...]`, which is correct.
//         if (decodedData is List) {
//           // Success! Return the list.
//           return decodedData;
//         } else {
//           // This would happen if the API returned an object `{...}` instead of a list.
//           print('WISHLIST PARSE ERROR: Expected a List but got ${decodedData.runtimeType}');
//           throw Exception('Invalid data format received from server.');
//         }
//       } else {
//         // The server responded with an error status code (e.g., 401, 404, 500)
//         print('WISHLIST API ERROR: Server returned status code ${response.statusCode}');
//         throw Exception('Failed to load wishlist items. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       // This catches network errors, JSON parsing errors, etc.
//       print('WISHLIST CATCH BLOCK ERROR: $e');
//       throw Exception('An error occurred while fetching the wishlist: $e');
//     }
//   }
//
//
//   /// Deletes an item from the customer's wishlist.
//   /// Corresponds to: DELETE /V1/wishlist/delete/:itemId
//   // lib/services/wishlist_api_service.dart
//
// // ... (other functions)
//
//   /// Deletes an item from the customer's wishlist.
//   /// Corresponds to: DELETE /V1/wishlist/delete/:itemId
//   // in lib/services/wishlist_api_service.dart
//
//   // In lib/services/wishlist_api_service.dart
//
//   Future<bool> deleteWishlistItem(int itemId) async {
//     final token = await _getCustomerToken();
//
//     print("token del>>$token");
//     if (token == null) {
//       // Use print for immediate visibility in debug console
//       print('WISHLIST API ERROR: User not logged in. Token is null.');
//       throw Exception('User not logged in');
//     }
//     // --- CHANGE 1: Update the URL to match the Magento API endpoint ---
//     final url = Uri.parse('$_baseUrl/V1/wishlist/delete');
//
//     // NOTE: You need a valid customer authorization token for this to work.
//     // This is just a placeholder. Replace with your actual token logic.
//
//
//     try {
//       final client = _getHttpClient();
//       final response = await client.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         // --- CHANGE 2: Update the JSON body key from 'item' to 'itemId' ---
//         body: json.encode({'itemId': itemId}),
//       );
//
//       // Check for a successful response code. Magento often returns 200 for this.
//       if (response.statusCode == 200) {
//         // Magento's delete endpoint might return a simple `true` or a JSON object.
//         // Let's handle both possibilities for robustness.
//         final dynamic responseData = json.decode(response.body);
//
//         // Case 1: The response is a simple boolean `true`
//         if (responseData == true) {
//           print('Successfully deleted item $itemId.');
//           return true;
//         }
//
//         // Case 2: The response is a JSON object like `[{"success": true, ...}]`
//         // (This depends on custom modules, but is a good pattern to check)
//         if (responseData is List && responseData.isNotEmpty) {
//           final result = responseData[0];
//           if (result is Map && result['success'] == true) {
//             print('Successfully deleted item $itemId.');
//             return true;
//           } else {
//             // The operation failed logically. Use the server's message.
//             throw Exception(result['message'] ?? 'Failed to delete item from server.');
//           }
//         }
//
//         // If it's a 200 OK but the body doesn't indicate success, treat as failure.
//         print('Server returned 200 but body did not confirm success: ${response.body}');
//         throw Exception('Failed to confirm item deletion.');
//
//       } else {
//         // Handle non-200 responses (e.g., 401 Unauthorized, 404 Not Found, 500 Server Error)
//         // Try to decode an error message from the body if possible.
//         String errorMessage = 'Server error: ${response.statusCode}';
//         try {
//           final errorData = json.decode(response.body);
//           if (errorData['message'] != null) {
//             errorMessage = errorData['message'];
//           }
//         } catch (_) {
//           // Could not parse JSON, use the raw body if it's not too long.
//           errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
//         }
//         throw Exception(errorMessage);
//       }
//     } catch (e) {
//       print('Error in deleteWishlistItem: $e');
//       rethrow; // Pass the exception up to the UI to be displayed
//     }
//   }
// }


// lib/services/wishlist_api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Custom exception for when an operation requires a logged-in user but none is found.
class UserNotLoggedInException implements Exception {
  final String message;
  UserNotLoggedInException([this.message = 'User is not logged in. Please log in to continue.']);

  @override
  String toString() => message;
}


class WishlistApiService {
  final String _baseUrl = "https://aashniandco.com/rest";

  // Helper to create an HTTP client that trusts self-signed certs
  http.Client _getHttpClient() {
    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    return IOClient(httpClient);
  }

  // Helper to get the customer token
  Future<String?> _getCustomerToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_token');
  }

  Future<bool> isUserLoggedIn() async {
    final token = await _getCustomerToken();
    return token != null && token.isNotEmpty;
  }

  /// Adds a product to the customer's wishlist.
  Future<bool> addToWishlist(int productId) async {
    final token = await _getCustomerToken();
    // CHANGE: Throw specific exception
    if (token == null) throw UserNotLoggedInException();

    final client = _getHttpClient();
    final response = await client.post(
      Uri.parse('$_baseUrl/V1/wishlist/add/$productId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Failed to add to wishlist: ${response.body}');
    }
  }

  /// Fetches all items from the customer's wishlist.
  Future<List<dynamic>> getWishlistItems() async {
    final token = await _getCustomerToken();
    // CHANGE: Throw specific exception instead of a generic one.
    if (token == null) {
      print('WISHLIST API: Token is null. Throwing UserNotLoggedInException.');
      throw UserNotLoggedInException();
    }

    final client = _getHttpClient();
    final url = Uri.parse('$_baseUrl/V1/wishlist');

    try {
      final response = await client.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final dynamic decodedData = json.decode(response.body);
        print('-----> RAW WISHLIST API RESPONSE: $decodedData');

        if (decodedData is List) {
          return decodedData;
        } else {
          throw Exception('Invalid data format received from server.');
        }
      } else if (response.statusCode == 401) {
        // Handle cases where token is invalid/expired
        throw UserNotLoggedInException('Your session has expired. Please log in again.');
      }
      else {
        throw Exception('Failed to load wishlist items. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Re-throw our custom exception if it's already the right type
      if (e is UserNotLoggedInException) rethrow;
      print('WISHLIST CATCH BLOCK ERROR: $e');
      throw Exception('An error occurred while fetching the wishlist: $e');
    }
  }

  /// Deletes an item from the customer's wishlist.
  Future<bool> deleteWishlistItem(int itemId) async {
    final token = await _getCustomerToken();
    if (token == null) throw UserNotLoggedInException();

    // ✅ Print itemId for debugging
    print('Deleting wishlist item with ID: $itemId');

    final url = Uri.parse('$_baseUrl/V1/wishlist/delete/$itemId'); // itemId in URL
    final client = _getHttpClient();

    try {
      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        print('Wishlist deletion response: $responseData');
        return true;
      } else if (response.statusCode == 401) {
        throw UserNotLoggedInException('Your session has expired. Please log in again.');
      } else {
        throw Exception('Failed to delete item. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      if (e is UserNotLoggedInException) rethrow;
      print('Error in deleteWishlistItem: $e');
      rethrow;
    }
  }

 // Currency Conversion code for testing



//   private function convertBatch(array $data, string $currencyFrom, array $currenciesTo): array
//   {
//   $accessKey = $this->scopeConfig->getValue(self::API_KEY_CONFIG_PATH, ScopeInterface::SCOPE_STORE);
//
//   if (empty($accessKey)) {
//   $this->_messages[] = __('No API Key was specified or an invalid API Key was specified.');
//   $data[$currencyFrom] = $this->makeEmptyResponse($currenciesTo);
//   return $data;
//   }
//
//   $currenciesStr = implode(',', $currenciesTo);
//   $url = str_replace(
//   ['{{ACCESS_KEY}}', '{{CURRENCY_FROM}}', '{{CURRENCY_TO}}'],
//   [$accessKey, $currencyFrom, $currenciesStr],
//   self::CURRENCY_CONVERTER_URL
//   );
//   // phpcs:ignore Magento2.Functions.DiscouragedFunction
//   set_time_limit(0);
//   try {
//   $response = $this->getServiceResponse($url);
//   } finally {
//   ini_restore('max_execution_time');
//   }
//
//   if (!$this->validateResponse($response, $currencyFrom)) {
//   $data[$currencyFrom] = $this->makeEmptyResponse($currenciesTo);
//   return $data;
//   }
//
//   foreach ($currenciesTo as $currencyTo) {
//   if ($currencyFrom == $currencyTo) {
//   $data[$currencyFrom][$currencyTo] = $this->_numberFormat(1);
//   } else {
//   if (empty($response['rates'][$currencyTo])) {
//   $serviceHost =  $this->getServiceHost($url);
//   $this->_messages[] = __('We can\'t retrieve a rate from %1 for %2.', $serviceHost, $currencyTo);
//   $data[$currencyFrom][$currencyTo] = null;
//   } else {
//   $data[$currencyFrom][$currencyTo] = $this->_numberFormat(
//   (double)$response['rates'][$currencyTo]
//   );
//   }
//   }
//   }
//   return $data;
// }



}