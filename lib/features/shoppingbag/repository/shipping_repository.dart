// import 'dart:convert';
// import 'dart:io';
//
// import 'package:http/io_client.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ShippingRepository {
//   final IOClient ioClient;
//
//   ShippingRepository()
//       : ioClient = IOClient(
//     HttpClient()..badCertificateCallback = (cert, host, port) => true,
//   );
//
//
//   Future<List<Map<String, dynamic>>> fetchCountries() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
//
//     final response = await ioClient.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('Country data raw response: ${response.body}');
//
//       if (data is List) {
//         // Each item in list: { "id": "IN", "full_name_english": "India", ... }
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception("Invalid country data");
//       }
//     } else {
//       throw Exception("Failed to fetch countries: ${response.body}");
//     }
//   }
//
//
//   Future<double> fetchCartTotalWeight(int customerId) async {
//     print("Checkout init fetchCartTotalWeightcalled>>");
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//     final response = await ioClient.get(
//       Uri.parse('https://stage.aashniandco.com/rest/V1/cart/details/$customerId'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       },
//     );
//
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body) as List<dynamic>;
//       if (data.isEmpty) {
//         return 0.0;
//       }
//       final firstItem = data[0] as Map<String, dynamic>;
//       final weightStr = firstItem['total_cart_weight'];
//       final totalWeight = double.tryParse(weightStr.toString()) ?? 0.0;
//       print("init fetchCartTotalWeightcalled>>$totalWeight");
//       return totalWeight;
//     } else {
//       throw Exception("Failed to fetch cart total weight: ${response.body}");
//     }
//   }
//
//   Future<double?> estimateShipping(String countryId, double cartWeight) async { // Added cartWeight parameter
//     fetchCartTotalWeight();
//     final regionId = 0; // Still hardcoded
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in");
//     }
//
//     // MODIFIED: cartWeight is now part of the URL
//     final shippingUrl =
//         "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId/$cartWeight";
//
//     print('--- ShippingRepository: Attempting to estimate shipping ---');
//     print('Country ID: $countryId, Region ID (hardcoded): $regionId, Cart Weight: $cartWeight'); // Added cartWeight
//     print('Request URL: $shippingUrl');
//     print('Customer Token: $customerToken');
//     print('-------------------------------------------------------------');
//
//     final response = await ioClient.get(
//       Uri.parse(shippingUrl),
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     print('--- ShippingRepository: API Response ---');
//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}');
//     print('--------------------------------------');
//
//     // It's safer to check status code before attempting to decode JSON
//     if (response.statusCode != 200) {
//       print('ShippingRepository: API call failed with status code ${response.statusCode}.');
//       throw Exception("Failed to estimate shipping (HTTP ${response.statusCode}): ${response.body}");
//     }
//
//     final data = jsonDecode(response.body);
//
//     if (data is List && data.length >= 2 && data[0] == true) {
//       final price = data[1];
//       print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
//       if (price != null) {
//         if (price is num) {
//           return price.toDouble();
//         } else if (price is String) {
//           try {
//             return double.parse(price);
//           } catch (e) {
//             print('ShippingRepository: Error parsing price string "$price" to double: $e');
//             throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
//           }
//         } else {
//           throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
//         }
//       } else {
//         throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
//       }
//     } else {
//       print('ShippingRepository: Condition for successful parsing FAILED.');
//       print('  - response.statusCode == 200: ${response.statusCode == 200}'); // Will be true if we reached here
//       print('  - data is List: ${data is List}');
//       if (data is List) {
//         print('  - data.length >= 2: ${data.length >= 2}');
//         if (data.isNotEmpty) { // check if not empty before accessing data[0]
//           print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//         } else {
//           print('  - data is an empty list.');
//         }
//       }
//       throw Exception("Failed to estimate shipping: Unexpected response format - ${response.body}");
//     }
//   }
//
//   // Future<double?> estimateShipping(String countryId) async {
//   //   final regionId = 0; // Still hardcoded
//   //   final prefs = await SharedPreferences.getInstance();
//   //   final customerToken = prefs.getString('user_token');
//   //
//   //   // Potential Exception 1: User not logged in
//   //   if (customerToken == null || customerToken.isEmpty) {
//   //     throw Exception("User not logged in");
//   //   }
//   //
//   //   final shippingUrl =
//   //       "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/$regionId";
//   //
//   //   // Add print statement HERE, BEFORE the API call, to ensure this method is reached and with what data
//   //   print('--- ShippingRepository: Attempting to estimate shipping ---');
//   //   print('Country ID: $countryId, Region ID (hardcoded): $regionId');
//   //   print('Request URL: $shippingUrl');
//   //   print('Customer Token: $customerToken'); // Be careful logging tokens in production
//   //   print('-------------------------------------------------------------');
//   //
//   //
//   //   final response = await ioClient.get( // This line could throw if network error, DNS issue, etc.
//   //     Uri.parse(shippingUrl),
//   //     headers: {
//   //       'Authorization': 'Bearer $customerToken',
//   //       'Content-Type': 'application/json',
//   //     },
//   //   );
//   //
//   //   // Add print statement HERE, AFTER the API call, to see the raw response
//   //   print('--- ShippingRepository: API Response ---');
//   //   print('Status Code: ${response.statusCode}');
//   //   print('Response Body: ${response.body}'); // THIS IS THE MOST IMPORTANT LOG
//   //   print('--------------------------------------');
//   //
//   //   // Potential Exception 2: jsonDecode fails if response.body is not valid JSON
//   //   final data = jsonDecode(response.body);
//   //
//   //   // Potential Exception 3: Conditions not met, leading to the throw
//   //   if (response.statusCode == 200 && data is List && data.length >= 2 && data[0] == true) {
//   //     final price = data[1];
//   //     // This part is also critical: what is `price`?
//   //     print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
//   //     if (price != null) {
//   //       if (price is num) { // int or double
//   //         return price.toDouble();
//   //       } else if (price is String) {
//   //         try {
//   //           return double.parse(price);
//   //         } catch (e) {
//   //           print('ShippingRepository: Error parsing price string "$price" to double: $e');
//   //           // Potential Exception 4: String price not parsable
//   //           throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
//   //         }
//   //       } else {
//   //         // Potential Exception 5: Price is not null, but not num or String
//   //         throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
//   //       }
//   //     } else {
//   //       // Potential Exception 6: Price is null
//   //       throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
//   //     }
//   //   } else {
//   //     // This is the most likely place it's throwing the exception if the API call itself succeeded (no network error)
//   //     // but the response wasn't what you expected.
//   //     print('ShippingRepository: Condition for successful parsing FAILED.');
//   //     print('  - response.statusCode == 200: ${response.statusCode == 200}');
//   //     print('  - data is List: ${data is List}');
//   //     if (data is List) {
//   //       print('  - data.length >= 2: ${data.length >= 2}');
//   //       if (data.length > 0) {
//   //         print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//   //       }
//   //     }
//   //     // Potential Exception 7: API call successful but response format incorrect or indicates failure
//   //     throw Exception("Failed to estimate shipping: ${response.body}");
//   //   }
//   // }
// }



import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ shipping_bloc/shipping_event.dart';
import '../model/countries.dart';

class ShippingRepository {
  final IOClient ioClient;
  final String _baseUrl = 'http://aashniandco.com/rest/V1';
  ShippingRepository()
      : ioClient = IOClient(
    HttpClient()..badCertificateCallback = (cert, host, port) => true,
  );

  Future<List<dynamic>> fetchCountries() async {
    final response = await ioClient.get(Uri.parse('$_baseUrl/directory/countries'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load countries');
    }
  }

  Future<double> fetchCartTotalWeight(int customerId) async {
    print("ShippingRepository: fetchCartTotalWeight called for customerId: $customerId");
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    if (customerToken == null || customerToken.isEmpty) {
      throw Exception("User not logged in for fetching cart weight");
    }

    final url = Uri.parse('http://aashniandco.com/rest/V1/cart/details/$customerId');
    print('--- ShippingRepository: Attempting to fetch cart total weight ---');
    print('Request URL: $url');
    print('Customer Token: $customerToken');
    print('-------------------------------------------------------------');

    final response = await this.ioClient.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      },
    );

    print('--- ShippingRepository: API Response for cart details ---');
    print('Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}'); // Enable if needed
    print('---------------------------------------------------------');

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      if (decodedData is List<dynamic>) {
        if (decodedData.isEmpty) {
          print("ShippingRepository: Cart details data is empty, returning 0.0 weight.");
          return 0.0;
        }

        double totalWeight = 0.0;
        for (final item in decodedData) {
          try {
            final weight = double.tryParse(item['weight']?.toString() ?? '0') ?? 0.0;
            totalWeight += weight;
          } catch (e) {
            print("Error parsing weight for item: $item");
          }
        }

        print("ShippingRepository: Total cart weight calculated: $totalWeight");
        return totalWeight;
      } else {
        print("Unexpected data format for cart details: ${decodedData.runtimeType}");
        throw Exception("Invalid cart details format.");
      }
    } else {
      print("Failed to fetch cart details (HTTP ${response.statusCode}): ${response.body}");
      throw Exception("Failed to fetch cart details: ${response.body}");
    }
  }

  Future<int> finalizePayUOrder({
    required String txnid,
    required String currencyCode,
    String? guestQuoteId,
    String? guestEmail,

  }) async {
    if (kDebugMode) print("--- ShippingRepository: Finalizing PayU Order for txnid: $txnid ---");

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {'txnid': txnid, 'currencyCode': currencyCode,};

    if (customerToken != null && customerToken.isNotEmpty) {
      // Logged-in user
      headers['Authorization'] = 'Bearer $customerToken';
      url = Uri.parse('$_baseUrl/aashni/place-order-payu');

      if (kDebugMode) print("Logged-in user. Headers: $headers");
    } else if (guestQuoteId != null && guestEmail != null) {
      // Guest user
      url = Uri.parse('$_baseUrl/aashni/guest-place-order-payu');
      body['guestMaskedId'] = guestQuoteId;
      body['guestEmail'] = guestEmail; // <--- **FIXED HERE: Changed to 'guestEmail'**

      if (kDebugMode) print("Guest user. Body: $body");
    } else {
      throw Exception("No valid session found for finalizing order.");
    }

    // Print the full request info for debugging
    if (kDebugMode) {
      print("Finalize PayU Order URL: $url");
      print("Finalize PayU Order Headers: $headers");
      print("Finalize PayU Order Body: ${json.encode(body)}");
    }

    final response = await ioClient.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (kDebugMode) {
      print("Finalize PayU Order API Response Status: ${response.statusCode}");
      print("Finalize PayU Order API Response Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      return int.parse(response.body.replaceAll('"', ''));
    } else {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to place order after PayU payment.');
      } catch (_) {
        throw Exception('Failed to place order. Invalid server response.');
      }
    }
  }

  // Future<int> finalizePayUOrder({
  //   required String txnid,
  //   String? guestQuoteId,
  //   String? guestEmail,
  // }) async {
  //   if (kDebugMode) print("--- ShippingRepository: Finalizing PayU Order for txnid: $txnid ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   Uri url;
  //   Map<String, String> headers = {'Content-Type': 'application/json'};
  //   Map<String, dynamic> body = {'txnid': txnid};
  //
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     // Logged-in user
  //     headers['Authorization'] = 'Bearer $customerToken';
  //     url = Uri.parse('$_baseUrl/aashni/place-order-payu');
  //
  //     if (kDebugMode) print("Logged-in user. Headers: $headers");
  //   } else if (guestQuoteId != null && guestEmail != null) {
  //     // Guest user
  //     url = Uri.parse('$_baseUrl/aashni/guest-place-order-payu');
  //     body['guestMaskedId'] = guestQuoteId;
  //     body['user_email'] = guestEmail;
  //
  //     if (kDebugMode) print("Guest user. Body: $body");
  //   } else {
  //     throw Exception("No valid session found for finalizing order.");
  //   }
  //
  //   // Print the full request info for debugging
  //   if (kDebugMode) {
  //     print("Finalize PayU Order URL: $url");
  //     print("Finalize PayU Order Headers: $headers");
  //     print("Finalize PayU Order Body: ${json.encode(body)}");
  //   }
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: headers,
  //     body: json.encode(body),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Finalize PayU Order API Response Status: ${response.statusCode}");
  //     print("Finalize PayU Order API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     return int.parse(response.body.replaceAll('"', ''));
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order after PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to place order. Invalid server response.');
  //     }
  //   }
  // }


  // Future<int> finalizePayUOrder({
  //   required String txnid,
  //   String? guestQuoteId,
  //   String? guestEmail,
  // }) async {
  //   if (kDebugMode) print("--- ShippingRepository: Finalizing PayU Order for txnid: $txnid ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   Uri url;
  //   Map<String, String> headers = {'Content-Type': 'application/json'};
  //   Map<String, dynamic> body = {'txnid': txnid};
  //
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     // Logged-in user
  //     headers['Authorization'] = 'Bearer $customerToken';
  //     url = Uri.parse('$_baseUrl/aashni/place-order-payu');
  //   } else if (guestQuoteId != null && guestEmail != null) {
  //     // Guest user
  //     url = Uri.parse('$_baseUrl/aashni/guest-place-order-payu');
  //     body['guestQuoteId'] = guestQuoteId;
  //     body['email'] = guestEmail;
  //   } else {
  //     throw Exception("No valid session found for finalizing order.");
  //   }
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: headers,
  //     body: json.encode(body),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Finalize PayU Order API Response Status: ${response.statusCode}");
  //     print("Finalize PayU Order API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     return int.parse(response.body.replaceAll('"', ''));
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order after PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to place order. Invalid server response.');
  //     }
  //   }
  // }



  //1/10/2025
  // Future<int> finalizePayUOrder(String txnid) async {
  //   if (kDebugMode) print("--- ShippingRepository: Finalizing PayU Order for txnid: $txnid ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in. Cannot finalize order.");
  //   }
  //
  //   // This is the NEW Magento endpoint you need to create
  //   final url = Uri.parse('$_baseUrl/aashni/place-order-payu');
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     // Send the transaction ID to the backend for verification
  //     body: json.encode({'txnid': txnid}),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Finalize PayU Order API Response Status: ${response.statusCode}");
  //     print("Finalize PayU Order API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Expecting the Magento order ID back
  //     return int.parse(response.body.replaceAll('"', ''));
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order after PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to place order. Invalid server response.');
  //     }
  //   }
  // }

  // Future<int> finalizePayUOrder(String txnid) async {
  //   if (kDebugMode) print("--- ShippingRepository: Finalizing PayU Order for txnid: $txnid ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in. Cannot finalize order.");
  //   }
  //
  //   // This is the NEW Magento endpoint you need to create
  //   final url = Uri.parse('$_baseUrl/aashni/place-order-payu');
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     // Send the transaction ID to the backend for verification
  //     body: json.encode({'txnid': txnid}),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Finalize PayU Order API Response Status: ${response.statusCode}");
  //     print("Finalize PayU Order API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Expecting the Magento order ID back
  //     return int.parse(response.body.replaceAll('"', ''));
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order after PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to place order. Invalid server response.');
  //     }
  //   }
  // }





//   Future<double?> estimateShipping(String countryId, double cartWeight) async {
//     // fetchCartTotalWeight(); // REMOVE THIS LINE - This was the source of your error.
//     // The cartWeight is passed as a parameter.
// print("called>>>>>>>>>>>");
//     final regionId = 0; // Still hardcoded
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//
//     if (customerToken == null || customerToken.isEmpty) {
//       throw Exception("User not logged in for estimating shipping");
//     }
//
//     final shippingUrl =
//         "https://stage.aashniandco.com/rest/V1/aashni/shipping-rate/$countryId/0?weight=$cartWeight";
//
//     print('--- ShippingRepository: Attempting to estimate shipping ---');
//     print('Country ID: $countryId, Region ID (hardcoded): $regionId, Cart Weight: $cartWeight');
//     print('Request URL>>>>>: $shippingUrl');
//     print('Customer Token: $customerToken');
//     print('-------------------------------------------------------------');
//
//     final response = await this.ioClient.get( // Use this.ioClient
//       Uri.parse(shippingUrl),
//       headers: {
//         'Authorization': 'Bearer $customerToken',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     print('--- ShippingRepository: API Response for shipping estimate ---');
//     print('Status Code: ${response.statusCode}');
//     print('Response Body: ${response.body}'); // Log the full body for shipping estimate
//     print('----------------------------------------------------------');
//
//     if (response.statusCode != 200) {
//       print('ShippingRepository: Estimate shipping API call failed with status code ${response.statusCode}.');
//       throw Exception("Failed to estimate shipping (HTTP ${response.statusCode}): ${response.body}");
//     }
//
//     final data = jsonDecode(response.body);
//
//     if (data is List && data.length >= 2 && data[0] == true) {
//       final price = data[1];
//       print('ShippingRepository: Price from API before conversion: $price (Type: ${price.runtimeType})');
//       if (price != null) {
//         if (price is num) {
//           return price.toDouble();
//         } else if (price is String) {
//           try {
//             return double.parse(price);
//           } catch (e) {
//             print('ShippingRepository: Error parsing price string "$price" to double: $e');
//             throw Exception("Failed to estimate shipping: Invalid price format in response - ${response.body}");
//           }
//         } else {
//           throw Exception("Failed to estimate shipping: Price is of unexpected type ${price.runtimeType} - ${response.body}");
//         }
//       } else {
//         throw Exception("Failed to estimate shipping: Price from API is null - ${response.body}");
//       }
//     } else {
//       print('ShippingRepository: Condition for successful parsing FAILED for shipping estimate.');
//       print('  - data is List: ${data is List}');
//       if (data is List) {
//         print('  - data.length >= 2: ${data.length >= 2}');
//         if (data.isNotEmpty) {
//           print('  - data[0] == true: ${data[0] == true} (Actual data[0]: ${data[0]}, Type: ${data[0].runtimeType})');
//         } else {
//           print('  - data is an empty list.');
//         }
//       }
//       throw Exception("Failed to estimate shipping: Unexpected response format - ${response.body}");
//     }
//   }
///////////14 june



  // Future<List<Map<String, dynamic>>> fetchAvailableShippingMethods({
  //   required String countryId,
  //   required String regionId,
  //   required String regionCode,
  //   required String regionName,
  //   required String postcode,
  //   required String city,
  //   required String street,
  //   required String firstname,
  //   required String lastname,
  //   required String telephone,
  // }) async {
  //   if (kDebugMode) {
  //     print("--- ShippingRepository: Fetching available shipping methods ---");
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in");
  //   }
  //
  //   // Construct the payload for the API
  //   final payload = {
  //     "address": {
  //       "region": regionName,
  //       "region_id": int.tryParse(regionId) ?? 0,
  //       "region_code": regionCode,
  //       "country_id": countryId,
  //       "postcode": postcode,
  //       "city": city,
  //       "street": [street],
  //       "firstname": firstname,
  //       "lastname": lastname,
  //       "telephone": telephone,
  //     }
  //   };
  //
  //   if (kDebugMode) {
  //     print("Request Payload: ${json.encode(payload)}");
  //   }
  //
  //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');
  //   final response = await this.ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode(payload),
  //   );
  //
  //   if (kDebugMode) {
  //     print("API Response Status: ${response.statusCode}");
  //     print("API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     final List<dynamic> responseData = json.decode(response.body);
  //     // Convert the list of dynamic to a list of maps
  //     return responseData.map((item) => item as Map<String, dynamic>).toList();
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
  //   }
  // }

  // 🔄 REPLACE your old estimateShipping method with this one.
// This method now returns a List of ShippingMethod objects.

  /// ✅ CORE LOGIC: Fetches shipping methods for EITHER a guest or a logged-in user.
  Future<List<ShippingMethod>> fetchAvailableShippingMethods({
    required String countryId,
    required String regionId,
    required String postcode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    print("guestQuoteId>>");
    final effectivePostcode = postcode.isNotEmpty ? postcode : "00000";
    // ✅ 1. --- ENHANCED DEBUGGING ---
    print("--- [Repository] Attempting to fetchAvailableShippingMethods ---");
    print("   - Customer Token: ${customerToken != null && customerToken.isNotEmpty ? 'EXISTS' : 'NULL or EMPTY'}");
    print("   - Guest Quote ID: ${guestQuoteId != null && guestQuoteId.isNotEmpty ? guestQuoteId : 'NULL or EMPTY'}");
    print("-----------------------------------------------------------------");
    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Determine the correct API endpoint based on the user's session
    if (customerToken != null && customerToken.isNotEmpty) {
      // --- LOGGED-IN USER ---
      url = Uri.parse('$_baseUrl/carts/mine/estimate-shipping-methods');
      headers['Authorization'] = 'Bearer $customerToken';
      print("Shipping Est: Using LOGGED-IN user endpoint.");
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      // --- GUEST USER ---
      url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId/estimate-shipping-methods');
      print("Shipping Est: Using GUEST cart endpoint for quote ID: $guestQuoteId");
    } else {
      // No active cart session, cannot fetch methods.
      print("Shipping Est: No active user or guest session found.");
      return [];
    }

    final body = json.encode({
      'address': {
        'country_id': countryId,
        'region_id': int.tryParse(regionId) ?? 0,
        'postcode': postcode,
      }
    });

    // ✅ 4. --- MORE DEBUGGING ---
    print("   - Request URL: $url");
    print("   - Request Body: $body");
    print("-----------------------------------------------------------------");

    final response = await ioClient.post(url, headers: headers, body: body);
    // ✅ 5. --- LOG THE RESPONSE ---
    print("--- [Repository] API Response Received ---");
    print("   - Status Code: ${response.statusCode}");
    print("   - Response Body: ${response.body}");
    print("------------------------------------------");
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ShippingMethod.fromJson(json)).where((m) => m.available).toList();
    } else {
      print("Failed to estimate shipping. Status: ${response.statusCode}, Body: ${response.body}");
      throw Exception('Failed to estimate shipping methods');
    }
  }

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
//     // This is the standard Magento endpoint
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/estimate-shipping-methods');
//
//     // The payload requires the shipping address
//     final payload = {
//       "address": {
//         "country_id": countryId,
//         "region_id": int.tryParse(regionId) ?? 0,
//         "postcode": postcode.isNotEmpty ? postcode : "00000", // Use a placeholder if empty
//         // You can add more address fields here if needed by other shipping methods
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
//     print("Standard Shipping API Response: ${response.body}");
//
//     if (response.statusCode == 200) {
//       final List<dynamic> responseData = json.decode(response.body);
//       // Map the JSON response to your new ShippingMethod model
//       return responseData.map((data) => ShippingMethod.fromJson(data)).toList();
//     } else {
//       final errorBody = json.decode(response.body);
//       throw Exception(errorBody['message'] ?? "Failed to fetch shipping methods.");
//     }
//   }

// ✅ REPLACE your repository method with this corrected

  Future<Map<String, dynamic>> submitShippingInformation(SubmitShippingInfo event) async {
    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Select the correct endpoint
    if (customerToken != null && customerToken.isNotEmpty) {
      url = Uri.parse('$_baseUrl/carts/mine/shipping-information');
      headers['Authorization'] = 'Bearer $customerToken';
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId/shipping-information');
    } else {
      throw Exception("No active cart session to submit shipping info.");
    }

    final addressInfo = {
      "addressInformation": {
        "shipping_address": {
          "countryId": event.countryId,
          "regionId": int.tryParse(event.regionId),
          "regionCode": event.regionCode,
          "region": event.regionName,
          "street": [event.streetAddress],
          "postcode": event.zipCode,
          "city": event.city,
          "firstname": event.firstName,
          "lastname": event.lastName,
          "email": event.email, // Email is required for guests
          "telephone": event.phone,
        },
        "billing_address": { // Assuming same as shipping for now
          "countryId": event.countryId,
          "regionId": int.tryParse(event.regionId),
          "regionCode": event.regionCode,
          "region": event.regionName,
          "street": [event.streetAddress],
          "postcode": event.zipCode,
          "city": event.city,
          "firstname": event.firstName,
          "lastname": event.lastName,
          "email": event.email,
          "telephone": event.phone,
        },
        "shipping_method_code": event.methodCode,
        "shipping_carrier_code": event.carrierCode,
      }
    };

    final response = await ioClient.post(url, headers: headers, body: json.encode(addressInfo));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit shipping information: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> initiatePayUPayment({
    required String currencyCode, // ✅ Added currencyCode parameter
  }) async {
    if (kDebugMode) print("--- ShippingRepository: Initiating PayU Payment ---");

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');
    final guestEmail = prefs.getString('user_email');

    print("PayU Called");
    print("sharedprefguestQuoteId $guestQuoteId");
    print("sharedprefguestEmail $guestEmail");

    Uri url;
    Map<String, String> headers = {'Content-Type': 'application/json'};
    Map<String, dynamic> body = {
      'currencyCode': currencyCode, // ✅ Always include currencyCode
    };

    if (customerToken != null && customerToken.isNotEmpty) {
      // ✅ Logged-in user
      print("--- Initiating PayU for LOGGED-IN user ---");
      url = Uri.parse('$_baseUrl/solr/generate-payu-hash');
      headers['Authorization'] = 'Bearer $customerToken';
    } else if (guestQuoteId != null && guestQuoteId.isNotEmpty && guestEmail != null && guestEmail.isNotEmpty) {
      // ✅ Guest user
      print("--- Initiating PayU for GUEST user ---");
      url = Uri.parse('$_baseUrl/aashni/guest-generate-payu-hash');
      body['guestMaskedId'] = guestQuoteId;
      body['guestEmail'] = guestEmail;
    } else {
      throw Exception("No valid session found for PayU payment.");
    }

    if (kDebugMode) {
      print("PayU Hash Request URL: $url");
      print("PayU Hash Request Headers: $headers");
      print("PayU Hash Request Body: ${json.encode(body)}");
    }

    final response = await ioClient.post(
      url,
      headers: headers,
      body: json.encode(body),
    );

    if (kDebugMode) {
      print("Initiate PayU Payment Response Status: ${response.statusCode}");
      print("Initiate PayU Payment Response Body: ${response.body}");
    }

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      Map<String, dynamic> payUData;

      // Handle array or map response (depending on backend format)
      if (responseData is List && responseData.length >= 10) {
        payUData = {
          'key': responseData[0],
          'txnid': responseData[1],
          'amount': responseData[2],
          'productinfo': responseData[3],
          'firstname': responseData[4],
          'email': responseData[5],
          'phone': responseData[6],
          'surl': responseData[7],
          'furl': responseData[8],
          'hash': responseData[9],
        };
      } else if (responseData is Map<String, dynamic>) {
        payUData = responseData;
      } else {
        throw Exception('Failed to initiate PayU payment. Invalid server response.');
      }

      return payUData;
    } else {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to initiate PayU payment.');
      } catch (_) {
        throw Exception('Failed to initiate PayU payment. Invalid server response.');
      }
    }
  }

  // Future<Map<String, dynamic>> initiatePayUPayment() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   final guestQuoteId = prefs.getString('guest_quote_id');
  //   final guestEmail= prefs.getString('user_email');
  //   print("PayU Called");
  //   print("sharedprefguestQuoteId $guestQuoteId");
  //   print("sharedprefguestEamil $guestEmail");
  //
  //
  //   Uri url;
  //   Map<String, String> headers = {'Content-Type': 'application/json'};
  //   Map<String, dynamic> body = {};
  //
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     // Logged-in user
  //     url = Uri.parse('$_baseUrl/solr/generate-payu-hash');
  //     headers['Authorization'] = 'Bearer $customerToken';
  //   } else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
  //     // Guest user (email not required anymore)
  //     url = Uri.parse('$_baseUrl/aashni/guest-generate-payu-hash');
  //
  //     body = {
  //       'guestMaskedId': guestQuoteId,
  //       'guestEmail': guestEmail
  //     };
  //   } else {
  //     throw Exception("No valid session found for PayU payment.");
  //   }
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: headers,
  //     body: json.encode(body),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Initiate PayU Payment Response Status: ${response.statusCode}");
  //     print("Initiate PayU Payment Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //
  //     Map<String, dynamic> payUData;
  //
  //     // Handle array response (list of values) or map response
  //     if (responseData is List && responseData.length >= 10) {
  //       payUData = {
  //         'key': responseData[0],
  //         'txnid': responseData[1],
  //         'amount': responseData[2],
  //         'productinfo': responseData[3],
  //         'firstname': responseData[4],
  //         'email': responseData[5],
  //         'phone': responseData[6],
  //         'surl': responseData[7],
  //         'furl': responseData[8],
  //         'hash': responseData[9],
  //       };
  //     } else if (responseData is Map<String, dynamic>) {
  //       payUData = responseData;
  //     } else {
  //       throw Exception('Failed to initiate PayU payment. Invalid server response.');
  //     }
  //
  //     return payUData;
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to initiate PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to initiate PayU payment. Invalid server response.');
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>> initiatePayUPayment() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   final guestEmail = prefs.getString('guest_email');
  //   final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //   print("PayU Called");
  //
  //   print("sharedprefguestQuoteId$guestQuoteId");
  //
  //   Uri url;
  //   Map<String, String> headers = {'Content-Type': 'application/json'};
  //   Map<String, dynamic> body = {};
  //
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     url = Uri.parse('$_baseUrl/solr/generate-payu-hash');
  //     headers['Authorization'] = 'Bearer $customerToken';
  //   } else if (guestQuoteId != null && guestEmail != null) {
  //     url = Uri.parse('$_baseUrl/aashni/guest-generate-payu-hash');
  //     body = {
  //       'guestQuoteId': guestQuoteId,
  //
  //     };
  //   } else {
  //     throw Exception("No valid session found for PayU payment.");
  //   }
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: headers,
  //     body: json.encode(body),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Initiate PayU Payment Response Status: ${response.statusCode}");
  //     print("Initiate PayU Payment Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // ===========================
  //     final responseData = json.decode(response.body);
  //
  //     Map<String, dynamic> payUData;
  //
  //     if (responseData is List && responseData.length >= 10) {
  //       payUData = {
  //         'key': responseData[0],
  //         'txnid': responseData[1],
  //         'amount': responseData[2],
  //         'productinfo': responseData[3],
  //         'firstname': responseData[4],
  //         'email': responseData[5],
  //         'phone': responseData[6],
  //         'surl': responseData[7],
  //         'furl': responseData[8],
  //         'hash': responseData[9],
  //       };
  //     } else if (responseData is Map<String, dynamic>) {
  //       payUData = responseData;
  //     } else {
  //       throw Exception('Failed to initiate PayU payment. Invalid server response.');
  //     }
  //     // ===========================
  //
  //     return payUData;
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to initiate PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to initiate PayU payment. Invalid server response.');
  //     }
  //   }
  // }


  // Future<Map<String, dynamic>> initiatePayUPayment() async {
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   final guestEmail = prefs.getString('guest_email');
  //   final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //   print("Payu Called");
  //   print("sharedprefguestEmail$guestEmail");
  //   print("sharedprefguestQuoteId$guestQuoteId");
  //
  //   Uri url;
  //   Map<String, String> headers = {'Content-Type': 'application/json'};
  //   Map<String, dynamic> body = {};
  //
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     // Logged-in user
  //     url = Uri.parse('$_baseUrl/solr/generate-payu-hash');
  //     headers['Authorization'] = 'Bearer $customerToken';
  //   } else if (guestQuoteId != null && guestEmail != null) {
  //     // Guest user
  //     url = Uri.parse('$_baseUrl/aashni/guest-generate-payu-hash');
  //     body = {
  //       'guestQuoteId': guestQuoteId,
  //       'email': guestEmail,
  //     };
  //   } else {
  //     throw Exception("No valid session found for PayU payment.");
  //   }
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: headers,
  //     body: json.encode(body),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Initiate PayU Payment Response Status: ${response.statusCode}");
  //     print("Initiate PayU Payment Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> data = json.decode(response.body);
  //     return data;
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to initiate PayU payment.');
  //     } catch (_) {
  //       throw Exception('Failed to initiate PayU payment. Invalid server response.');
  //     }
  //   }
  // }

  // Future<Map<String, dynamic>> initiatePayUPayment() async {
  //   if (kDebugMode) print("--- ShippingRepository: Initiating PayU Payment ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("Cannot initiate PayU payment. User is not logged in.");
  //   }
  //
  //   final url = Uri.parse('$_baseUrl/solr/generate-payu-hash');
  //
  //   final response = await ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode({}),
  //   );
  //
  //   if (kDebugMode) {
  //     print("PayU Hash API Response Status: ${response.statusCode}");
  //     print("PayU Hash API Response Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Decode the response body. It could be a List or a Map.
  //     final dynamic decodedData = json.decode(response.body);
  //
  //     // ------------------- ✅ THE FIX IS HERE -------------------
  //     // Check if the API incorrectly returned a List.
  //     if (decodedData is List && decodedData.length >= 10) {
  //       if (kDebugMode) {
  //         print("API returned a List. Rebuilding it into a Map.");
  //       }
  //       // Manually reconstruct the Map from the List.
  //       // This function now fulfills its promise of returning a Map.
  //       return {
  //         'key': decodedData[0],
  //         'txnid': decodedData[1],
  //         'amount': decodedData[2],
  //         'productinfo': decodedData[3],
  //         'firstname': decodedData[4],
  //         'email': decodedData[5],
  //         'phone': decodedData[6],
  //         'surl': decodedData[7],
  //         'furl': decodedData[8],
  //         'hash': decodedData[9],
  //       };
  //     }
  //     // Check if the API correctly returned a Map.
  //     else if (decodedData is Map<String, dynamic>) {
  //       return decodedData;
  //     }
  //     // If it's neither, throw an error.
  //     else {
  //       throw Exception("Received unexpected data format from PayU API.");
  //     }
  //     // ------------------- ✅ END OF FIX -------------------
  //
  //   } else {
  //     try {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to prepare PayU transaction.');
  //     } catch (_) {
  //       throw Exception('Failed to prepare PayU transaction. Invalid server response.');
  //     }
  //   }
  // }
  // Future<Map<String, dynamic>> submitShippingInformation(SubmitShippingInfo event) async {
  //   if (kDebugMode) {
  //     print("--- ShippingRepository: Submitting shipping information ---");
  //   }
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null || customerToken.isEmpty) {
  //     throw Exception("User not logged in for submitting shipping info");
  //   }
  //
  //   // This part is fine. It builds the address object.
  //   final addressPayload = {
  //     "region": event.regionName,
  //     "region_id": int.tryParse(event.regionId) ?? 0,
  //     "region_code": event.regionCode,
  //     "country_id": event.countryId,
  //     "street": [event.streetAddress],
  //     "postcode": event.zipCode,
  //     "city": event.city,
  //     "firstname": event.firstName,
  //     "lastname": event.lastName,
  //     "email": event.email.isNotEmpty ? event.email : "mitesh@gmail.com",
  //     "telephone": event.phone,
  //   };
  //
  //   // ✅ --- START OF THE FIX ---
  //   // The structure of the main request body needs to be corrected.
  //   final Map<String, dynamic> requestBody = {
  //     "addressInformation": {
  //       "shipping_address": addressPayload,
  //       "billing_address": addressPayload, // Using the same address for billing
  //
  //       // The keys must be prefixed with "shipping_" and be at this level.
  //       "shipping_carrier_code": event.carrierCode,
  //       "shipping_method_code": event.methodCode,
  //     }
  //   };
  //   // ✅ --- END OF THE FIX ---
  //
  //   if (kDebugMode) {
  //     print("Final Payload Check: ${json.encode(requestBody)}");
  //   }
  //
  //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/shipping-information');
  //   final response = await this.ioClient.post(
  //     url,
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode(requestBody),
  //   );
  //
  //   if (kDebugMode) {
  //     print("API Response Status: ${response.statusCode}");
  //     print("API Response Body: ${response.body}");
  //     print("---------------------------------------------------------");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body) as Map<String, dynamic>;
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     // Check for a more specific error message from Magento
  //     String errorMessage = 'Failed to save address. Please check the details and try again.';
  //     if (errorBody['message'] != null) {
  //       errorMessage = errorBody['message'];
  //       // Check for parameter details which can be very helpful
  //       if (errorBody['parameters'] != null && errorBody['parameters'] is Map) {
  //         errorMessage += " Details: ${errorBody['parameters']}";
  //       }
  //     }
  //     throw Exception(errorMessage);
  //   }
  // }

// In your shipping_repository.dart

// ✅ REPLACE your existing method with this more robust version

  // ✅ REPLACE your entire repository method with this one.

  // ✅ REPLACE your repository method with this one, which includes the new debugging step.

  // ✅ REPLACE your repository method with this corrected version

  // lib/features/shoppingbag/repository/shipping_repository.dart


  // In your ShippingRepository class
//9/10/2025
//   Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
//     if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");
//
//     final prefs = await SharedPreferences.getInstance();
//     final customerToken = prefs.getString('user_token');
//     final guestQuoteId = prefs.getString('guest_quote_id');
//
//     // --- LOGGED-IN USER PATH ---
//     if (customerToken != null && customerToken.isNotEmpty) {
//       print("--- Submitting payment for LOGGED-IN user ---");
//       final headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $customerToken',
//       };
//
//       // ✅ THE FIX IS HERE: Add the currencyCode to the payload.
//       final payload = {
//         "paymentMethodCode": event.paymentMethodCode,
//         "billingAddress": event.billingAddress,
//         "paymentMethodNonce": event.paymentMethodNonce,
//         "currencyCode": event.currencyCode, // <-- Add this line
//       };
//
//       print("  Currency Code: ${event.currencyCode}");
//       if (kDebugMode) {
//         // It's helpful to log the payload to confirm the currency is being sent
//         print("Placing Order with Payload: ${json.encode(payload)}");
//       }
//
//       final response = await ioClient.post(
//         Uri.parse('$_baseUrl/aashni/place-order'), // Your custom endpoint
//         headers: headers,
//         body: json.encode(payload),
//       );
//
//       if (response.statusCode == 200) {
//         return int.parse(json.decode(response.body).toString());
//       } else {
//         final errorBody = json.decode(response.body);
//         throw Exception(errorBody['message'] ?? 'Failed to place order.');
//       }
//     }
//     // --- GUEST USER PATH ---
//     else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
//       print("--- Submitting payment for GUEST user ---");
//
//       // For guests, the standard Magento API has a different way to set currency.
//       // It's usually done when the cart is created or when the shipping address is set.
//       // However, we can try to set it via a custom header. Your backend may need to be
//       // adjusted to handle this for guests.
//       final url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId/payment-information');
//
//       final payload = {
//         "paymentMethod": {
//           "method": event.paymentMethodCode,
//           "po_number": null,
//           "additional_data": {
//             "cc_stripejs_token": event.paymentMethodNonce
//           }
//         },
//         "billingAddress": event.billingAddress,
//         "email": event.billingAddress['email']
//       };
//
//       print("Guest Payment Payload: ${json.encode(payload)}");
//
//       // For guests, we send the currency via a header.
//       // Your Magento backend will need to be customized to read this header for guest checkouts.
//       final response = await ioClient.post(
//         url,
//         headers: {
//           'Content-Type': 'application/json',
//           'X-Store-Currency': event.currencyCode, // ✅ Send currency for guests via header
//         },
//         body: json.encode(payload),
//       );
//
//       if (kDebugMode) {
//         print("Guest Payment Response Status: ${response.statusCode}");
//         print("Guest Payment Response Body: ${response.body}");
//       }
//
//       if (response.statusCode == 200) {
//         return int.parse(response.body.replaceAll('"', ''));
//       } else {
//         final errorBody = json.decode(response.body);
//         throw Exception(errorBody['message'] ?? 'Failed to place order for guest.');
//       }
//
//     } else {
//       throw Exception("No active cart session found to place order.");
//     }
//   }

  Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
    if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");

    final prefs = await SharedPreferences.getInstance();
    final customerToken = prefs.getString('user_token');
    final guestQuoteId = prefs.getString('guest_quote_id');

    // -------------------------
    // LOGGED-IN USER PATH
    // -------------------------
    if (customerToken != null && customerToken.isNotEmpty) {
      if (kDebugMode) print("--- Submitting payment for LOGGED-IN user ---");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $customerToken',
      };

      final payload = {
        "paymentMethodCode": event.paymentMethodCode,
        "billingAddress": event.billingAddress,
        "paymentMethodNonce": event.paymentMethodNonce,
        "currencyCode": event.currencyCode,
      };

      if (kDebugMode) print("Payload: ${json.encode(payload)}");

      final response = await ioClient.post(
        Uri.parse('$_baseUrl/aashni/place-order'),
        headers: headers,
        body: json.encode(payload),
      );

      if (response.statusCode == 200) {
        return int.parse(json.decode(response.body).toString());
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to place order.');
      }
    }

    // -------------------------
    // GUEST USER PATH
    // -------------------------
    else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
      if (kDebugMode) print("--- Submitting payment for GUEST user ---");

      final url = Uri.parse('$_baseUrl/aashni/place-guest-order');

      final payload = {
        "guestQuoteId": guestQuoteId,
        "paymentMethodCode": event.paymentMethodCode,
        "billingAddress": event.billingAddress,
        "paymentMethodNonce": event.paymentMethodNonce,
        "currencyCode": event.currencyCode,
      };

      if (kDebugMode) print("Guest Payload: ${json.encode(payload)}");

      final response = await ioClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (kDebugMode) {
        print("Guest Payment Response Status: ${response.statusCode}");
        print("Guest Payment Response Body: ${response.body}");
      }

      if (response.statusCode == 200) {
        return int.parse(response.body.replaceAll('"', ''));
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to place order for guest.');
      }
    } else {
      throw Exception("No active cart session found to place order.");
    }
  }

  //14/8/2025
  // Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
  //   if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   final guestQuoteId = prefs.getString('guest_quote_id');
  //
  //   // This is a custom endpoint, so the logic might be slightly different,
  //   // but the principle of checking the session is the same.
  //   // We assume your custom endpoint `/aashni/place-order` can handle both.
  //   // If not, you'd need a separate one like `/aashni/guest/place-order`.
  //
  //   // --- LOGGED-IN USER PATH ---
  //   if (customerToken != null && customerToken.isNotEmpty) {
  //     print("--- Submitting payment for LOGGED-IN user ---");
  //     final headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     };
  //
  //     final payload = {
  //       "paymentMethodCode": event.paymentMethodCode,
  //       "billingAddress": event.billingAddress,
  //       "paymentMethodNonce": event.paymentMethodNonce,
  //     };
  //
  //     final response = await ioClient.post(
  //       Uri.parse('$_baseUrl/aashni/place-order'), // Your custom endpoint
  //       headers: headers,
  //       body: json.encode(payload),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return int.parse(json.decode(response.body).toString());
  //     } else {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order.');
  //     }
  //   }
  //   // --- GUEST USER PATH ---
  //   else if (guestQuoteId != null && guestQuoteId.isNotEmpty) {
  //     print("--- Submitting payment for GUEST user ---");
  //
  //     // For guests, we must call the standard Magento `/guest-carts/{cartId}/payment-information` endpoint
  //     // which returns the Order ID.
  //     final url = Uri.parse('$_baseUrl/guest-carts/$guestQuoteId/payment-information');
  //
  //     // The payload for the standard guest API needs the email.
  //     // Your billingAddress already contains it from the previous screen.
  //     final payload = {
  //       "paymentMethod": {
  //         "method": event.paymentMethodCode,
  //         "po_number": null,
  //         "additional_data": {
  //           // Stripe payment nonce/ID goes here for standard Magento Stripe modules
  //           "cc_stripejs_token": event.paymentMethodNonce
  //         }
  //       },
  //       "billingAddress": event.billingAddress,
  //       "email": event.billingAddress['email']
  //     };
  //
  //     print("Guest Payment Payload: ${json.encode(payload)}");
  //
  //     final response = await ioClient.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'}, // No token for guests
  //       body: json.encode(payload),
  //     );
  //
  //     if (kDebugMode) {
  //       print("Guest Payment Response Status: ${response.statusCode}");
  //       print("Guest Payment Response Body: ${response.body}");
  //     }
  //
  //     if (response.statusCode == 200) {
  //       // The standard API returns the order ID directly in the body, often quoted.
  //       return int.parse(response.body.replaceAll('"', ''));
  //     } else {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order for guest.');
  //     }
  //
  //   } else {
  //     throw Exception("No active cart session found to place order.");
  //   }
  // }
}

///old

  // Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
  //   if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null) throw Exception("User not logged in.");
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $customerToken',
  //   };
  //
  //   try {
  //     // This debugging is fine, leave it as is.
  //     final cartDetailsResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
  //       headers: headers,
  //     );
  //     if (cartDetailsResponse.statusCode == 200) {
  //       final cartData = json.decode(cartDetailsResponse.body);
  //       final cartId = cartData['id'];
  //       if (kDebugMode) print("✅ Cart ID: $cartId");
  //     }
  //
  //     final paymentMethodsResponse = await ioClient.get(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/payment-methods'),
  //       headers: headers,
  //     );
  //     if (kDebugMode) print("✅ Payment methods: ${paymentMethodsResponse.body}");
  //
  //     // --- This sanitation logic is correct ---
  //     Map<String, dynamic> sanitizedBillingAddress = Map.from(event.billingAddress);
  //     if (sanitizedBillingAddress['street'] is Set) {
  //       if (kDebugMode) print("Warning: 'street' field was a Set. Converting to List.");
  //       sanitizedBillingAddress['street'] = (sanitizedBillingAddress['street'] as Set).toList();
  //     }
  //
  //     // ✅ START OF THE FIX: Correctly build the payload
  //     final payload = {
  //       "paymentMethodCode": event.paymentMethodCode,
  //       "billingAddress": sanitizedBillingAddress,
  //       // The backend function is expecting a top-level parameter
  //       // named 'paymentMethodNonce', not a nested object.
  //       "paymentMethodNonce": event.paymentMethodNonce
  //     };
  //     // final payload = {
  //     //   "paymentMethodCode": event.paymentMethodCode,
  //     //   "billingAddress": sanitizedBillingAddress,
  //     //   "paymentMethodData": {
  //     //     "type": "card",
  //     //     "card": {
  //     //       "token": event.paymentMethodNonce
  //     //     }
  //     //   }
  //     // };
  //
  //     // ✅ END OF THE FIX
  //
  //     if (kDebugMode) print("Final Corrected Payload: ${json.encode(payload)}");
  //
  //     final response = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/aashni/place-order'),
  //       headers: headers,
  //       body: json.encode(payload),
  //     );
  //
  //     if (kDebugMode) {
  //       print("Payment API Status (POST): ${response.statusCode}");
  //       print("Payment API Body (POST): ${response.body}");
  //     }
  //
  //     if (response.statusCode == 200) {
  //       final responseBody = json.decode(response.body);
  //       return int.parse(responseBody.toString());
  //     } else {
  //       final errorBody = json.decode(response.body);
  //       throw Exception(errorBody['message'] ?? 'Failed to place order.');
  //     }
  //
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       print("❌ Exception during payment info submission: $e");
  //       print("StackTrace: $stackTrace");
  //     }
  //     rethrow;
  //   }
  // }

// Future<int> submitPaymentInformation(SubmitPaymentInfo event) async {
  //   if (kDebugMode) print("--- ShippingRepository: Submitting Payment Info ---");
  //   final prefs = await SharedPreferences.getInstance();
  //   final customerToken = prefs.getString('user_token');
  //   if (customerToken == null) throw Exception("User not logged in.");
  //
  //   final payload = {
  //     "paymentMethod": {"method": event.paymentMethodCode},
  //     "billing_address": event.billingAddress
  //   };
  //
  //   if (kDebugMode) print("Payment Payload: ${json.encode(payload)}");
  //
  //   final response = await ioClient.post(
  //     Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/payment-information'),
  //     headers: {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $customerToken',
  //     },
  //     body: json.encode(payload),
  //   );
  //
  //   if (kDebugMode) {
  //     print("Payment API Status: ${response.statusCode}");
  //     print("Payment API Body: ${response.body}");
  //   }
  //
  //   if (response.statusCode == 200) {
  //     // Magento returns the order ID directly in the response body
  //     return int.parse(response.body);
  //   } else {
  //     final errorBody = json.decode(response.body);
  //     throw Exception(errorBody['message'] ?? 'Failed to place order.');
  //   }
  // }

  // Optional: An orchestrating method
  // This is how you would typically use the above methods together.
  // Future<double?> getFullShippingEstimateForCustomer(String countryId, int customerId) async {
  //   try {
  //     print("ShippingRepository: Orchestrating full shipping estimate for country $countryId, customer $customerId");
  //     // Step 1: Fetch cart total weight
  //     double weight = await fetchCartTotalWeight(customerId);
  //
  //     // Step 2: Estimate shipping with the fetched weight
  //     double? shippingCost = await estimateShipping(countryId, weight);
  //     return shippingCost;
  //   } catch (e) {
  //     print("ShippingRepository: Error in getFullShippingEstimateForCustomer: $e");
  //     rethrow; // Or handle more gracefully, e.g., return null
  //   }
  // }

// This is the method you will call from your UI or BLoC.
// It orchestrates the entire process.
//   Future<double?> getFullShippingEstimateForCustomer(String countryId, int customerId) async {
//     try {
//       print("ShippingRepository: Starting the full shipping estimate process...");
//
//       // STEP 1: Call fetchCartTotalWeight and AWAIT the result.
//       // The `await` keyword gets the `double` value out of the `Future<double>`.
//       // The result is stored in the `weight` variable.
//       print("Step 1: Fetching cart total weight for customer $customerId...");
//       double weight = await fetchCartTotalWeight(customerId);
//       print("Step 1 complete. Fetched weight: $weight");
//
//       // If the cart is empty (weight is 0), you might want to return 0 immediately
//       // to avoid an unnecessary API call.
//       if (weight == 0.0) {
//         print("Cart weight is 0. Returning 0 for shipping cost.");
//         return 0.0;
//       }
//
//       // STEP 2: Call estimateShipping, passing the `weight` variable from Step 1.
//       // Await the final result.
//       print("Step 2: Estimating shipping for country $countryId with weight $weight...");
//       double? shippingCost = await estimateShipping(countryId, weight);
//       print("Step 2 complete. Estimated shipping cost: $shippingCost");
//
//       // STEP 3: Return the final calculated shipping cost.
//       return shippingCost;
//
//     } catch (e) {
//       // If anything fails in either Step 1 or Step 2, the error is caught here.
//       print("ShippingRepository: An error occurred during the shipping estimate process: $e");
//       // rethrow the error so the UI layer can know something went wrong.
//       rethrow;
//     }
//   }
