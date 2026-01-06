
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../newin/model/new_in_model.dart';
import '../../shoppingbag/model/countries.dart';
import '../model/category_data.dart';
import '../model/category_model.dart';
import '../model/filter_model.dart';
import 'package:http/io_client.dart';

import '../model/product_image.dart';
import 'category_mapping.dart';



class ApiService {
  // final String _baseUrl = "https://stage.aashniandco.com/rest/V1";
  // --- NEW METHOD TO FETCH PRODUCTS FROM SOLR ---

  // Inside your ApiService class
  Future<Map<String, double>> fetchPriceRange(String categoryId) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');

    try {
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        double minPrice = 0.0;
        double maxPrice = 10000.0; // Default fallback

        for (var item in rawData) {
          if (item is Map<String, dynamic>) {
            if (item.containsKey('min_price')) {
              minPrice = double.tryParse(item['min_price'].toString()) ?? 0.0;
            }
            if (item.containsKey('max_price')) {
              maxPrice = double.tryParse(item['max_price'].toString()) ?? 10000.0;
            }
          }
        }

        return {'min': minPrice, 'max': maxPrice};
      } else {
        throw Exception('Failed to load price data');
      }
    } catch (e) {
      throw Exception('Error fetching price: $e');
    }
  }
  Future<List<ProductImage>> fetchProductImages(String sku) async {

    final encodedSku = Uri.encodeComponent(sku);
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/products/$encodedSku/images');
    print("ApiService: Fetching images from URL: $url"); // For debugging
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // The API returns a list of JSON objects
        final List<dynamic> jsonList = json.decode(response.body);

        // Map the list of JSON to a list of ProductImage objects
        return jsonList.map((json) => ProductImage.fromJson(json)).toList();
      } else {
        // If the server returns an error response, throw an exception.
        throw Exception('Failed to load product images. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch network errors or other issues
      print('Error fetching product images for SKU $sku: $e');
      // Re-throw the exception to be handled by the UI
      rethrow;
    }
  }






  //13/9/2025

  // Future<Map<String, dynamic>> fetchProductDetailsBySku(String sku) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/product/$sku');
  //   print('Requesting Product Details from: $url');
  //
  //   HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.get(url);
  //
  //     if (response.statusCode == 200) {
  //       // --- THIS IS THE FINAL FIX ---
  //
  //       // Step 1: Decode the initial response.
  //       // This will turn the server's "{\"key\":\"value\"}" into a Dart String: {"key":"value"}
  //       final String innerJsonString = json.decode(response.body);
  //
  //       // Step 2: Decode the inner string to get the final Map.
  //       // This parses the {"key":"value"} string into a proper Map.
  //       final Map<String, dynamic> productData = json.decode(innerJsonString);
  //
  //       print("productData$productData");
  //
  //       return productData;
  //
  //       // --- END OF FIX ---
  //     }
  //     else if (response.statusCode == 404) {
  //       final decodedError = json.decode(response.body);
  //       final errorMessage = decodedError['message'] ?? 'Product with SKU "$sku" not found.';
  //       throw Exception(errorMessage);
  //     }
  //     else {
  //       throw Exception('Failed to load product details: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching product details for SKU "$sku": $e');
  //     throw Exception('Could not load product details. Please try again.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }
// 1️⃣ Fetch product details
//   Future<Map<String, dynamic>> fetchProductDetailsBySku(String sku) async {
//     final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/product/$sku');
//     print('Requesting Product Details from: $url');
//
//     final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     final ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.get(url);
//
//       if (response.statusCode == 200) {
//         final String innerJsonString = json.decode(response.body);
//         print("res>>>>$innerJsonString");
//
//
//         return json.decode(innerJsonString); // return product data only
//       } else if (response.statusCode == 404) {
//         final decodedError = json.decode(response.body);
//         throw Exception(decodedError['message'] ?? 'Product not found');
//       } else {
//         throw Exception('Failed to load product details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching product details: $e');
//       throw Exception('Could not load product details');
//     } finally {
//       ioClient.close();
//     }
//   }

  Future<Map<String, dynamic>> fetchProductDetailsBySku(String sku) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/product/$sku');
    print('Requesting Product Details from: $url');

    final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final String innerJsonString = json.decode(response.body);
        final productData = json.decode(innerJsonString);

        print("res>>>>$productData");

        // ✅ Extract designer_name
        final designerName = productData['designer_name']?.toString() ?? '';
        print("Designer Name: $designerName");

        // Now call your Magento endpoint that fetches designer products
        // if (designerName.isNotEmpty) {
        //   await fetchDesignerData(designerName); // ← Your next API call
        // }

        return productData; // Return full product details
      } else if (response.statusCode == 404) {
        final decodedError = json.decode(response.body);
        throw Exception(decodedError['message'] ?? 'Product not found');
      } else {
        throw Exception('Failed to load product details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product details: $e');
      throw Exception('Could not load product details');
    } finally {
      ioClient.close();
    }
  }

  Future<Map<String, dynamic>> fetchDesignerData(String designerName) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/designer');
    print('Requesting Designer Data from: $url with name $designerName');

    final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    final ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'designerName': designerName}),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        print("Designer Data: $result");
        return result;
      } else {
        throw Exception('Failed to load designer data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching designer data: $e');
      throw Exception('Could not load designer data');
    } finally {
      ioClient.close();
    }
  }


// 2️⃣ Fetch suggestions by short description
// 2️⃣ Fetch suggestions by short description with request/response logging

  Future<List<Map<String, dynamic>>> fetchSuggestionsByShortDesc(String query) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/suggestbyshortdesc');
    print("url>>>>$url");
    final body = jsonEncode({'skuData': query});

    print('Requesting suggestions with body: $body');

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // --- 💡 ROBUST RESPONSE HANDLING 💡 ---

        // Case 1: The API returned a direct list of products (from our complex query).
        if (data is List) {
          print('✅ API returned a direct list of products.');
          return List<Map<String, dynamic>>.from(data);
        }

        // Case 2: The API returned the structured suggestion object.
        if (data is Map<String, dynamic>) {
          // Check for the "not found" message from the original logic.
          if (data.containsKey('success') && data['success'] == false) {
            print('✅ API returned "No product found" message.');
            return []; // Return empty list
          }

          // Prioritize the 'related_items' list if it's available and not empty.
          if (data.containsKey('related_items') && (data['related_items'] as List).isNotEmpty) {
            print('✅ API returned structured response. Using "related_items".');
            return List<Map<String, dynamic>>.from(data['related_items']);
          }

          // As a fallback, use the 'items' list.
          if (data.containsKey('items')) {
            print('✅ API returned structured response. Using fallback "items".');
            return List<Map<String, dynamic>>.from(data['items']);
          }
        }

        // If the structure is something else entirely, return an empty list.
        print('⚠️ Unexpected JSON structure from API.');
        return [];

      } else {
        print('API Error: Failed to load suggestions with status code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception during fetchSuggestionsByShortDesc: $e');
      return [];
    }
  }

  // Future<List<Map<String, dynamic>>> fetchSuggestionsByShortDesc(String query) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/suggestbyshortdesc');
  //   final body = jsonEncode({'skuData': query});
  //
  //   print('Requesting suggestions with body: $body');
  //
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: body,
  //     );
  //
  //     print('Response status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final decoded = json.decode(response.body);
  //
  //       // ✅ Case 1: valid result list with products
  //       if (decoded is List && decoded.length >= 5 && decoded[4] is List) {
  //         final items = List<Map<String, dynamic>>.from(decoded[4]);
  //         print('✅ Found ${items.length} "You may also like" products');
  //         return items;
  //       }
  //
  //       // ✅ Case 2: valid result but no product found
  //       if (decoded is List && decoded.length >= 2 && decoded[0] == false) {
  //         print('ℹ️ No related products found for "$query"');
  //         return [];
  //       }
  //
  //       // ⚠️ Fallback
  //       print('⚠️ Unexpected JSON structure: $decoded');
  //       return [];
  //     } else {
  //       final decodedError = json.decode(response.body);
  //       throw Exception(decodedError['message'] ?? 'Error fetching suggestions');
  //     }
  //   } catch (e) {
  //     print('❌ Error fetching suggestions: $e');
  //     throw Exception('Could not fetch product suggestions');
  //   } finally {
  //     ioClient.close();
  //   }
  // }

//   Future<List<Map<String, dynamic>>> fetchSuggestionsByShortDesc(String query) async {
//     final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/suggestbyshortdesc');
//     final body = jsonEncode({'skuData': query});
//
//     print('Requesting suggestions with body: $body'); // Print request
//
//     final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     final ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );
//
//       print('Response status: ${response.statusCode}'); // Print status
//       print('Response body: ${response.body}'); // Print full response
//
//       if (response.statusCode == 200) {
//         final decoded = json.decode(response.body);
//         if (decoded is List && decoded.length >= 3) {
//           return List<Map<String, dynamic>>.from(decoded[2]);
//         } else {
//           return [];
//         }
//       } else {
//         final decodedError = json.decode(response.body);
//         throw Exception(decodedError['message'] ?? 'Error fetching suggestions');
//       }
//     } catch (e) {
//       print('Error fetching suggestions: $e');
//       throw Exception('Could not fetch product suggestions');
//     } finally {
//       ioClient.close();
//     }
//   }




//13/9/2025
  // Future<Map<String, dynamic>> fetchProductDetailsBySku(String sku) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/product/$sku');
  //   print('Requesting Product Details from: $url');
  //
  //   HttpClient httpClient = HttpClient()
  //     ..badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.get(url);
  //
  //     if (response.statusCode == 200) {
  //       // Step 1: Decode the initial response.
  //       final String innerJsonString = json.decode(response.body);
  //
  //       // Step 2: Decode again to get a Map.
  //       final Map<String, dynamic> productData = json.decode(innerJsonString);
  //
  //       print("productData: $productData");
  //
  //       final shortDesc = productData['short_desc'] ?? '';
  //
  //       String secondLastWord = '';
  //       if (shortDesc.isNotEmpty) {
  //         final words = shortDesc.split(' ');
  //
  //         if (words.length >= 2) {
  //           secondLastWord = words[words.length - 2]; // second last word
  //         } else {
  //           secondLastWord = shortDesc; // fallback if only 1 word
  //         }
  //
  //         print("secondLastWord: $secondLastWord"); // print it here
  //       } else {
  //         print("No short description found.");
  //       }
  //
  //       return productData;
  //     } else if (response.statusCode == 404) {
  //       final decodedError = json.decode(response.body);
  //       final errorMessage = decodedError['message'] ?? 'Product with SKU "$sku" not found.';
  //       throw Exception(errorMessage);
  //     } else {
  //       throw Exception('Failed to load product details: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching product details for SKU "$sku": $e');
  //     throw Exception('Could not load product details. Please try again.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }
  //
  //
  // Future<List<Map<String, dynamic>>> fetchSuggestionsByShortDesc(String query) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/suggestbyshortdesc');
  //
  //   // Prepare POST payload
  //   final body = jsonEncode({'skuData': query});
  //
  //   // Allow self-signed certificates if needed
  //   final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //   final ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: body,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final decoded = json.decode(response.body);
  //       // Magento returns: [true, "query", [...products...]]
  //       if (decoded is List && decoded.length >= 3) {
  //         final List<dynamic> items = decoded[2];
  //         // Ensure each item is a Map<String, dynamic>
  //         return items.map<Map<String, dynamic>>((item) => Map<String, dynamic>.from(item)).toList();
  //       } else {
  //         return [];
  //       }
  //     } else {
  //       final decodedError = json.decode(response.body);
  //       final errorMessage = decodedError['message'] ?? 'Error fetching suggestions.';
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e) {
  //     if (kDebugMode) print('Error fetching suggestions: $e');
  //     throw Exception('Could not fetch product suggestions. Please try again.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }

  /// Fetches the list of available filter types (e.g., Designer, Color) for a category.
  Future<List<FilterType>> fetchAvailableFilterTypes(String categoryId) async {
    // Whitelist of filters to display, in the desired order.
    const Map<String, String> allowedFiltersMap = {

      'themes': 'Themes',
      'categories': 'Category',
      'genders': 'Gender',
      'designers': 'Designer',
      'colors': 'Color',
      'sizes': 'Size',
      // 'delivery_times': 'Delivery',
      'child_delivery_time': 'Delivery',
      'price': 'Price',
      'a_co_edit': 'A+CO Edits',
      'occasions': 'Occasions'
    };

    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');
   print("url>>>$url");
    try {
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);

        // ✅ FIX: Consistently parse the API response by getting the first key of each map object.
        // This logic now matches the parsing strategy in `fetchGenericFilter`.
        final availableApiKeys = rawData
            .whereType<Map<String, dynamic>>()
            .where((item) => item.isNotEmpty) // Ensure the map isn't empty
            .map((item) => item.keys.first)
            .toSet(); // e.g., {'sizes', 'colors', 'occasions', 'child_categories'}

        final List<FilterType> result = [];
        for (var entry in allowedFiltersMap.entries) {
          final String filterKey = entry.key;
          final String label = entry.value;

        //   // Check if our whitelisted filter key is present in the API response
        //   if (availableApiKeys.contains(filterKey)) {
        //     // ✅ FIX: Create FilterType instance using 'key' to match the model
        //     result.add(FilterType(key: filterKey, label: label));
        //   }
        // }

          // 2. CHECK: logic to map internal 'child_delivery_time' to API's 'delivery_times'
          String apiCheckKey = filterKey;
          if (filterKey == 'child_delivery_time') {
            apiCheckKey = 'delivery_times';
          }

          if (filterKey == 'price') {
            apiCheckKey = 'min_price';
          }

          if (availableApiKeys.contains(apiCheckKey)) {
            result.add(FilterType(key: filterKey, label: label));
          }
        }
        return result;
      } else {
        throw Exception('Failed to load filter types: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filter types: $e');
      throw Exception('An error occurred while loading filters.');
    }
  }

  /// Fetches the specific items for a given filter type (e.g., all available Designers).
// In your ApiService class

// In your ApiService class

// In your ApiService.dart file

// In your ApiService.dart file


  Future<List<FilterItem>> fetchGenericFilter({
    required String categoryId,
    required String filterType, // This will come in as 'child_delivery_time'
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');

    try {
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final response = await ioClient.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        final List<FilterItem> itemList = [];
        Map<String, dynamic> childCategoriesData = {};

        // Pre-scan for child categories
        if (filterType == 'categories') {
          for (var item in rawData) {
            if (item is Map<String, dynamic> && item.containsKey('child_categories')) {
              childCategoriesData = item['child_categories'];
              break;
            }
          }
        }

        // ✅ 3. DETERMINE JSON KEY:
        // The app asks for 'child_delivery_time', but we must read 'delivery_times' from JSON.
        String jsonKeyToRead = filterType;
        if (filterType == 'child_delivery_time') {
          jsonKeyToRead = 'delivery_times';
        }

        for (var item in rawData) {
          if (item is! Map<String, dynamic>) continue;

          // Check using the mapped key
          if (item.containsKey(jsonKeyToRead)) {
            final dynamic filterValue = item[jsonKeyToRead];

            if (filterValue is Map<String, dynamic>) {
              filterValue.forEach((key, value) {
                // Default logic
                String finalId = key;
                String finalName = value.toString();

                // Handle pipe separator (ID|Name)
                if (value.toString().contains('|')) {
                  final parts = value.toString().split('|');
                  if (parts.length == 2) {
                    finalId = parts[0].trim();
                    finalName = parts[1].trim();
                  }
                }

                // ✅ 4. SPECIAL ID LOGIC FOR DELIVERY:
                // Solr requires the string value (e.g. "1-2 Weeks") for this field, not the ID (2).
                if (filterType == 'child_delivery_time') {
                  finalId = '"$finalName"'; // Set ID = Name (with quotes)
                }

                // Child Categories Logic
                List<FilterItem> children = [];
                if (filterType == 'categories' && childCategoriesData.containsKey(key)) {
                  final Map<String, dynamic> childMap = childCategoriesData[key];
                  childMap.forEach((childId, childName) {
                    children.add(FilterItem(id: childId, name: childName));
                  });
                }

                itemList.add(FilterItem(id: finalId, name: finalName, children: children));
              });
            }
          }
        }

        // Remove duplicates
        final seenNames = <String>{};
        final uniqueList = <FilterItem>[];
        for (final item in itemList) {
          final normalizedName = item.name.trim().toLowerCase();
          if (!seenNames.contains(normalizedName)) {
            seenNames.add(normalizedName);
            uniqueList.add(item);
          }
        }

        return uniqueList;
      } else {
        throw Exception('Failed to load filter: Status code ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching filter type "$filterType": $e');
      throw Exception('Failed to load filter data.');
    }
  }
  //8/12/2025

  // Future<List<FilterItem>> fetchGenericFilter({
  //   required String categoryId,
  //   required String filterType,
  // }) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');
  //
  //   try {
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //     final response = await ioClient.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> rawData = json.decode(response.body);
  //       final List<FilterItem> itemList = [];
  //       Map<String, dynamic> childCategoriesData = {};
  //
  //       print("\n===============================");
  //       print("🔍 RAW FILTER RESPONSE (PRETTY)");
  //       print("===============================");
  //       for (var i = 0; i < rawData.length; i++) {
  //         print('---- Item $i ----');
  //         print(const JsonEncoder.withIndent('  ').convert(rawData[i]));
  //       }
  //
  //       // ✅ STEP 1 (FIXED): Pre-scan for child categories FIRST
  //       // This loop ensures childCategoriesData is populated before we need it.
  //       if (filterType == 'categories') {
  //         for (var item in rawData) {
  //           if (item is Map<String, dynamic> && item.containsKey('child_categories')) {
  //             childCategoriesData = item['child_categories'];
  //             print("\n📦 Child Categories Mapping Found and Stored.");
  //             break; // We found it, no need to keep looping for this task
  //           }
  //         }
  //       }
  //
  //       // 3. SETUP: Determine which key to look for in the JSON
  //       // If app requests 'child_delivery_time', we must look for 'delivery_times' in JSON
  //       String actualJsonKey = filterType;
  //       if (filterType == 'child_delivery_time') {
  //         actualJsonKey = 'delivery_times';
  //       }
  //
  //       // ✅ STEP 2 (ORIGINAL LOGIC): Now, process all items
  //       for (var item in rawData) {
  //         if (item is! Map<String, dynamic>) continue;
  //
  //         // Note: The logic that was here to find children is now removed,
  //         // as we have already done it in the pre-scan loop above.
  //
  //         // Handle other nested filter types (this is fine)
  //         if (filterType == 'delivery_times' && item.containsKey('child_delivery_time')) {
  //           filterType = 'child_delivery_time';
  //         }
  //
  //         // Process the main filter key
  //         if (item.containsKey(filterType)) {
  //           print("\nFound filter data for '$filterType'. Determining format...");
  //           final dynamic filterValue = item[filterType];
  //
  //           if (filterValue is Map<String, dynamic>) {
  //             print("Parsing as Map format...");
  //             filterValue.forEach((key, value) {
  //               final parts = value.toString().split('|');
  //               String finalId;
  //               String finalName;
  //
  //               if (parts.length == 2) {
  //                 finalId = parts[0].trim();
  //                 finalName = parts[1].trim();
  //               } else {
  //                 finalId = key;
  //                 finalName = value.toString();
  //               }
  //
  //               // Handle children for categories
  //               List<FilterItem> children = [];
  //               // NOW, this check will work because childCategoriesData is already populated!
  //               if (filterType == 'categories' && childCategoriesData.containsKey(key)) {
  //                 final Map<String, dynamic> childMap = childCategoriesData[key];
  //                 childMap.forEach((childId, childName) {
  //                   children.add(FilterItem(id: childId, name: childName));
  //                 });
  //               }
  //
  //               itemList.add(FilterItem(id: finalId, name: finalName, children: children));
  //               // This log will now show the correct child count
  //               print("✅ Added parent '${finalName}' with ${children.length} children.");
  //             });
  //           }
  //           // ... (The rest of your list processing logic is fine)
  //         }
  //       }
  //
  //       // ... (The rest of your function: deduplication and sorting, is fine and does not need changes)
  //       // ✅ STEP 4: Remove duplicates (case-insensitive)
  //       final seenNames = <String>{};
  //       final uniqueList = <FilterItem>[];
  //       for (final item in itemList) {
  //         final normalizedName = item.name.trim().toLowerCase();
  //         if (!seenNames.contains(normalizedName)) {
  //           seenNames.add(normalizedName);
  //           uniqueList.add(item);
  //         }
  //       }
  //
  //       // ✅ STEP 5: Sort (custom or default)
  //       // ... sorting logic ...
  //
  //
  //       print("\n===============================");
  //       print("📊 FINAL FILTER SUMMARY");
  //       print("===============================");
  //       for (final item in uniqueList) {
  //         print("🧩 ${item.name} (${item.id}) → ${item.children.length} children");
  //       }
  //
  //       print('✅ Filtered list: ${uniqueList.length} unique items (sorted)');
  //       return uniqueList;
  //
  //     } else {
  //       throw Exception('Failed to load filter: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('❌ Error fetching filter type "$filterType": $e');
  //     throw Exception('Failed to load filter data.');
  //   }
  // }


  //3/11/2025
  // Future<List<FilterItem>> fetchGenericFilter({
  //   required String categoryId,
  //   required String filterType,
  // }) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');
  //
  //   try {
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //     final response = await ioClient.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> rawData = json.decode(response.body);
  //       final List<FilterItem> itemList = [];
  //       Map<String, dynamic> childCategoriesData = {};
  //
  //       for (var item in rawData) {
  //         if (item is! Map<String, dynamic>) continue;
  //
  //         if (filterType == 'categories' && item.containsKey('child_categories')) {
  //           childCategoriesData = item['child_categories'];
  //         }
  //
  //         if (filterType == 'delivery_times' && item.containsKey('child_delivery_time')) {
  //           filterType = 'child_delivery_time';
  //         }
  //
  //         if (item.containsKey(filterType)) {
  //           print("Found filter data for '$filterType'. Determining format...");
  //           final dynamic filterValue = item[filterType];
  //
  //           // --- FORMAT 1: MAP ---
  //           if (filterValue is Map<String, dynamic>) {
  //             print("Parsing as Map format.");
  //             filterValue.forEach((key, value) {
  //               final parts = value.toString().split('|');
  //
  //               String finalId;
  //               String finalName;
  //
  //               if (parts.length == 2) {
  //                 finalId = parts[0].trim();
  //                 finalName = parts[1].trim();
  //               } else {
  //                 finalId = key;
  //                 finalName = value.toString();
  //               }
  //
  //               List<FilterItem> children = [];
  //               if (filterType == 'categories' && childCategoriesData.containsKey(key)) {
  //                 final Map<String, dynamic> childMap = childCategoriesData[key];
  //                 childMap.forEach((childId, childName) {
  //                   children.add(FilterItem(id: childId, name: childName));
  //                 });
  //               }
  //
  //               itemList.add(FilterItem(id: finalId, name: finalName, children: children));
  //             });
  //           }
  //
  //           // --- FORMAT 2: LIST ---
  //           else if (filterValue is List) {
  //             print("Parsing as List format.");
  //             for (var option in filterValue) {
  //               if (option is Map<String, dynamic>) {
  //                 final String? id = option['id']?.toString();
  //                 final String? name = option['name']?.toString();
  //                 if (id != null && name != null) {
  //                   itemList.add(FilterItem(id: id, name: name));
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //
  //       // ✅ STEP 1: REMOVE DUPLICATES (case-insensitive)
  //       final seenNames = <String>{};
  //       final uniqueList = <FilterItem>[];
  //       for (final item in itemList) {
  //         final normalizedName = item.name.trim().toLowerCase();
  //         if (!seenNames.contains(normalizedName)) {
  //           seenNames.add(normalizedName);
  //           uniqueList.add(item);
  //         }
  //       }
  //
  //       // ✅ STEP 2: SMART SORTING
  //       if (filterType.toLowerCase() == 'size') {
  //         // 🧩 Custom size sorting order
  //         final customOrder = [
  //           "XSmall",
  //           "Small",
  //           "Medium",
  //           "Large",
  //           "XLarge",
  //           "XXLarge",
  //           "3XLarge",
  //           "4XLarge",
  //           "5XLarge",
  //           "6XLarge",
  //           "Free Size",
  //           "0-3 Months",
  //           "3-6 Months",
  //           "6-9 Months",
  //           "9-12 Months",
  //           "1-2 Years",
  //           "2-3 Years",
  //           "3-4 Years",
  //           "4-5 Years",
  //           "5-6 Years",
  //           "6-7 Years",
  //           "7-8 Years",
  //           "8-9 Years",
  //           "9-10 Years",
  //           "10-11 Years",
  //           "11-12 Years",
  //           "12-13 Years",
  //           "13-14 Years",
  //           "14-15 Years",
  //           "15-16 Years",
  //         ];
  //
  //         int _customIndex(String name) {
  //           final index = customOrder.indexWhere(
  //                   (e) => e.toLowerCase().trim() == name.toLowerCase().trim());
  //           return index == -1 ? 9999 : index;
  //         }
  //
  //         uniqueList.sort((a, b) {
  //           final aIndex = _customIndex(a.name);
  //           final bIndex = _customIndex(b.name);
  //           if (aIndex != bIndex) return aIndex.compareTo(bIndex);
  //           return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  //         });
  //       } else {
  //         // 🧮 Default numeric/alphabetic sorting
  //         int _extractLeadingNumber(String text) {
  //           final match = RegExp(r'(\d+)').firstMatch(text);
  //           return match != null ? int.tryParse(match.group(1)!) ?? 9999 : 9999;
  //         }
  //
  //         uniqueList.sort((a, b) {
  //           final aNum = _extractLeadingNumber(a.name);
  //           final bNum = _extractLeadingNumber(b.name);
  //           if (aNum != bNum) return aNum.compareTo(bNum);
  //           return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  //         });
  //       }
  //
  //       print('Filtered list: ${uniqueList.length} unique items (sorted properly)');
  //       print("unique List>> $uniqueList");
  //       return uniqueList;
  //     } else {
  //       throw Exception('Failed to load filter: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching filter type "$filterType": $e');
  //     throw Exception('Failed to load filter data.');
  //   }
  // }




//live*
  // Future<List<FilterItem>> fetchGenericFilter({
  //   required String categoryId,
  //   required String filterType,
  // }) async {
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category/$categoryId/filters');
  //
  //   try {
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //     final response = await ioClient.get(url);
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> rawData = json.decode(response.body);
  //       final List<FilterItem> itemList = [];
  //       Map<String, dynamic> childCategoriesData = {};
  //
  //       for (var item in rawData) {
  //         if (item is! Map<String, dynamic>) continue;
  //
  //         if (filterType == 'categories' && item.containsKey('child_categories')) {
  //           childCategoriesData = item['child_categories'];
  //         }
  //
  //         if (item.containsKey(filterType)) {
  //           print("Found filter data for>> '$filterType'. Determining format...");
  //           final dynamic filterValue = item[filterType]; // Use 'dynamic' to hold either Map or List
  //
  //           // ✅ NEW: CHECK THE FORMAT OF THE DATA
  //
  //           // --- FORMAT 1: The value is a MAP (like for 'sizes', 'designers') ---
  //           if (filterValue is Map<String, dynamic>) {
  //             print("Parsing as Map format.");
  //             final Map<String, dynamic> filterData = filterValue;
  //             filterData.forEach((key, value) {
  //               final String valueString = value.toString();
  //               final parts = valueString.split('|');
  //
  //               String finalId;
  //               String finalName;
  //
  //               if (parts.length == 2) {
  //                 finalId = parts[0].trim();
  //                 finalName = parts[1].trim();
  //               } else {
  //                 finalId = key;
  //                 finalName = valueString;
  //               }
  //
  //               List<FilterItem> children = [];
  //               if (filterType == 'categories' && childCategoriesData.containsKey(key)) {
  //                 final Map<String, dynamic> childMap = childCategoriesData[key];
  //                 childMap.forEach((childId, childName) {
  //                   children.add(FilterItem(id: childId, name: childName));
  //                 });
  //               }
  //
  //               itemList.add(FilterItem(id: finalId, name: finalName, children: children));
  //             });
  //           }
  //           // --- FORMAT 2: The value is a LIST (like for 'occasions') ---
  //           else if (filterValue is List) {
  //             print("Parsing as List format.");
  //             final List<dynamic> filterList = filterValue;
  //             for (var option in filterList) {
  //               if (option is Map<String, dynamic>) {
  //                 final String? id = option['id']?.toString();
  //                 final String? name = option['name']?.toString();
  //
  //                 if (id != null && name != null) {
  //                   itemList.add(FilterItem(id: id, name: name));
  //                 }
  //               }
  //             }
  //           }
  //         }
  //       }
  //       return itemList;
  //     } else {
  //       throw Exception('Failed to load filter: Status code ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error fetching filter type "$filterType": $e');
  //     throw Exception('Failed to load filter data.');
  //   }
  // }


  // ✅ NEW METHOD TO FETCH CATEGORY METADATA
  // ✅ FINAL ROBUST METHOD - HANDLES UNEXPECTED ARRAY RESPONSE


  Future<String?> fetchRepresentativeCategoryIdForDesigner(String designerName) async {
    // This is a simplified example.
    // Ideally, your backend would have an endpoint like:
    // /V1/solr/designer-representative-category/{designerName}
    // which returns a category ID that can be used for filtering.

    // For now, let's try to simulate based on your existing setup.
    // Option A: Try to find a global "all products" category ID
    // If your system has a top-level category that acts as a container for ALL products,
    // and fetching filters for it works, use that.
    try {
      // Attempt to get metadata for a known generic category like 'all-products' or 'fashion'
      // You need to replace 'YOUR_GLOBAL_CATEGORY_ID' or 'YOUR_GLOBAL_CATEGORY_NAME'
      // with an actual category in your system that represents a broad range.
      // For example, if you have a "Women" category (ID: 123) that contains all women's wear,
      // and your designer primarily sells women's wear, you could use that.
      final globalCategoryMetadata = await fetchCategoryMetadataByName('women'); // Example, replace with actual
      if (globalCategoryMetadata.containsKey('cat_id')) {
        print('Using global category ID for designer filters: ${globalCategoryMetadata['cat_id']}');
        return globalCategoryMetadata['cat_id'].toString();
      }
    } catch (e) {
      print('Failed to get global category metadata for designer: $e');
    }

    // Option B: If 'all' was intended to work as a generic ID, but it returns 404,
    // you need to fix your backend to handle a generic 'all' or 'default' category ID.
    // If 'all' is supposed to represent the highest level, you might need a special ID for it.
    // For the purpose of getting _some_ filters, let's try a hardcoded one if known.
    // For example, if '1372' (New In) actually works for broad filters, you might use it
    // as a temporary fallback, but this is less ideal.
    // return '1372'; // Not ideal, but a placeholder if 'new-in' has broad filters.

    // Option C: A more sophisticated approach would involve:
    // 1. Fetching a sample of products by the designer.
    // 2. Extracting their category IDs.
    // 3. Finding the most common *parent* category ID among them.
    // This is too complex for a quick fix here.

    // For now, let's just return a placeholder or null if a suitable ID isn't found easily.
    // You MUST ensure your `fetchAvailableFilterTypes` can handle the ID you return here.
    return null; // Or a specific ID known to work for general filters.
  }
  // In your ApiService class
  Future<Map<String, dynamic>> fetchCategoryMetadataByName(String categoryName, {bool isDesignerScreen = false}) async {

    if (categoryName == "Filtered Results") {
      print("⚠️ Skipping metadata fetch for 'Filtered Results'. Returning mock data.");
      return {
        'cat_name': 'Filtered Results',
        'cat_id': '0', // Dummy ID
        'pare_cat_id': '0',
        'cat_level': 0,
        'cat_url_key': 'filtered-results'
      };
    }

    if (kDebugMode) {
      print('--- fetchCategoryMetadataByName CALLED ---');
      print('Input categoryName: "$categoryName"');
      print('isDesignerScreen: $isDesignerScreen'); // Added for debugging
    }

    String urlKey;

    // --- NEW LOGIC HERE ---
    if (isDesignerScreen) {
      urlKey = 'designers';
      if (kDebugMode) {
        print("Detected designer screen. Using specific urlKey: 'designers'");
      }
    } else {
      final CategoryData? categoryData = CategoryMapping.getDataByName(categoryName);
      if (categoryData != null) {
        if (kDebugMode) {
          print("Found mapping for '$categoryName'. Using correct urlKey: '${categoryData.urlKey}'");
        }
        urlKey = categoryData.urlKey;
      } else {
        if (kDebugMode) {
          print("No mapping found for '$categoryName'. Generating urlKey dynamically.");
        }
        urlKey = categoryName
            .toLowerCase()
            .replaceAll("'", "")
            .replaceAll('&', 'and')
            .replaceAll(RegExp(r'[\s_]+'), '-')
            .replaceAll(RegExp(r'[^a-z0-9-]'), '');
      }
    }
    // --- END NEW LOGIC ---


    if (urlKey.isEmpty) {
      if (kDebugMode) {
        print("Generated urlKey is empty. Using a default 'all-products' if applicable.");
      }
      urlKey = 'all-products';
    }

    final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category-by-url-key/$urlKey');
    if (kDebugMode) {
      print('Requesting Category Metadata from URL: $url');
    }

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(url);

      if (kDebugMode) {
        print('Response Status Code for "$urlKey": ${response.statusCode}');
        print('Response Body for "$urlKey": ${response.body}');
      }

      if (response.statusCode == 200) {
        final dynamic decodedBody = json.decode(response.body);
        Map<String, dynamic> finalCategoryData;

        if (decodedBody is List && decodedBody.length >= 5) {
          if (kDebugMode) {
            print("API returned a List for '$urlKey'. Parsing based on fixed order.");
          }
          finalCategoryData = {
            'cat_name': decodedBody[0].toString(),
            'cat_level': decodedBody[1],
            'cat_url_key': decodedBody[2].toString(),
            'pare_cat_id': decodedBody[3].toString(),
            'cat_id': decodedBody[4].toString(),
          };
        } else if (decodedBody is Map<String, dynamic>) {
          if (kDebugMode) {
            print("API returned a Map for '$urlKey' as expected.");
          }
          finalCategoryData = decodedBody;
        } else {
          throw Exception('API for "$urlKey" returned an unexpected data format that could not be parsed.');
        }

        if (finalCategoryData['cat_url_key']?.toLowerCase() == 'new-in' ||
            finalCategoryData['cat_name']?.toLowerCase() == 'new in') {
          if (kDebugMode) {
            print("🟡 Overriding category ID for 'New In' to 1372 for '$urlKey'");
          }
          finalCategoryData['cat_id'] = '1372';
        }

        if (kDebugMode) {
          print('Parsed Category Metadata for "$urlKey": $finalCategoryData');
          print('pare_cat_id for "$urlKey": ${finalCategoryData['pare_cat_id']}');
          print('--- END fetchCategoryMetadataByName ---');
        }
        return finalCategoryData;

      } else {
        String errorMessage = 'Category not found for urlKey: $urlKey (Original name: $categoryName)';
        try {
          final decodedError = json.decode(response.body);
          if (decodedError['message'] != null) { errorMessage = decodedError['message']; }
        } catch (_) { errorMessage = response.body; }
        if (kDebugMode) {
          print('API Error for "$urlKey": $errorMessage');
          print('--- END fetchCategoryMetadataByName (Error) ---');
        }
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('--- ERROR FETCHING CATEGORY METADATA for "$urlKey" ---');
        print('Exception Type: ${e.runtimeType}');
        print('Exception Object: $e');
        print('Stack Trace: \n$stackTrace');
        print('--- END ERROR ---');
      }
      throw Exception('Could not load category details for "$categoryName". Please check the debug console.');
    } finally {
      ioClient.close();
    }
  }




  // Future<Map<String, dynamic>> fetchCategoryMetadataByName(String categoryName) async {
  //   if (kDebugMode) {
  //     print('--- fetchCategoryMetadataByName CALLED ---');
  //     print('Input categoryName: "$categoryName"');
  //   }
  //
  //   final CategoryData? categoryData = CategoryMapping.getDataByName(categoryName);
  //   String urlKey;
  //
  //   if (categoryData != null) {
  //     if (kDebugMode) {
  //       print("Found mapping for '$categoryName'. Using correct urlKey: '${categoryData.urlKey}'");
  //     }
  //     urlKey = categoryData.urlKey;
  //   } else {
  //     if (kDebugMode) {
  //       print("No mapping found for '$categoryName'. Generating urlKey dynamically.");
  //     }
  //     urlKey = categoryName
  //         .toLowerCase()
  //         .replaceAll("'", "")
  //         .replaceAll('&', 'and')
  //         .replaceAll(RegExp(r'[\s_]+'), '-')
  //         .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  //   }
  //
  //   if (urlKey.isEmpty) {
  //     if (kDebugMode) {
  //       print("Generated urlKey is empty. Using a default 'all-products' if applicable.");
  //     }
  //     urlKey = 'all-products';
  //   }
  //
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category-by-url-key/$urlKey');
  //   if (kDebugMode) {
  //     print('Requesting Category Metadata from URL: $url');
  //   }
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.get(url);
  //
  //     if (kDebugMode) {
  //       print('Response Status Code for "$urlKey": ${response.statusCode}');
  //       print('Response Body for "$urlKey": ${response.body}');
  //     }
  //
  //     if (response.statusCode == 200) {
  //       final dynamic decodedBody = json.decode(response.body);
  //       Map<String, dynamic> finalCategoryData;
  //
  //       if (decodedBody is List && decodedBody.length >= 5) {
  //         if (kDebugMode) {
  //           print("API returned a List for '$urlKey'. Parsing based on fixed order.");
  //         }
  //         finalCategoryData = {
  //           'cat_name': decodedBody[0].toString(),
  //           'cat_level': decodedBody[1],
  //           'cat_url_key': decodedBody[2].toString(),
  //           'pare_cat_id': decodedBody[3].toString(),
  //           'cat_id': decodedBody[4].toString(),
  //         };
  //       } else if (decodedBody is Map<String, dynamic>) {
  //         if (kDebugMode) {
  //           print("API returned a Map for '$urlKey' as expected.");
  //         }
  //         finalCategoryData = decodedBody;
  //       } else {
  //         throw Exception('API for "$urlKey" returned an unexpected data format that could not be parsed.');
  //       }
  //
  //       if (finalCategoryData['cat_url_key']?.toLowerCase() == 'new-in' ||
  //           finalCategoryData['cat_name']?.toLowerCase() == 'new in') {
  //         if (kDebugMode) {
  //           print("🟡 Overriding category ID for 'New In' to 1372 for '$urlKey'");
  //         }
  //         finalCategoryData['cat_id'] = '1372';
  //       }
  //
  //       if (kDebugMode) {
  //         print('Parsed Category Metadata for "$urlKey": $finalCategoryData');
  //         print('pare_cat_id for "$urlKey": ${finalCategoryData['pare_cat_id']}');
  //         print('--- END fetchCategoryMetadataByName ---');
  //       }
  //       return finalCategoryData;
  //
  //     } else {
  //       String errorMessage = 'Category not found for urlKey: $urlKey (Original name: $categoryName)';
  //       try {
  //         final decodedError = json.decode(response.body);
  //         if (decodedError['message'] != null) { errorMessage = decodedError['message']; }
  //       } catch (_) { errorMessage = response.body; }
  //       if (kDebugMode) {
  //         print('API Error for "$urlKey": $errorMessage');
  //         print('--- END fetchCategoryMetadataByName (Error) ---');
  //       }
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e, stackTrace) {
  //     if (kDebugMode) {
  //       print('--- ERROR FETCHING CATEGORY METADATA for "$urlKey" ---');
  //       print('Exception Type: ${e.runtimeType}');
  //       print('Exception Object: $e');
  //       print('Stack Trace: \n$stackTrace');
  //       print('--- END ERROR ---');
  //     }
  //     throw Exception('Could not load category details for "$categoryName". Please check the debug console.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }
  //

  //8/11/2025
  // Future<Map<String, dynamic>> fetchCategoryMetadataByName(String categoryName) async {
  //   // --- NEW LOGIC STARTS HERE ---
  //
  //   // 1. Look up the correct data from our reliable local map first.
  //   final CategoryData? categoryData = CategoryMapping.getDataByName(categoryName);
  //
  //   String urlKey;
  //
  //   if (categoryData != null) {
  //     // 2. If we found a mapping, use its GUARANTEED correct urlKey.
  //     print("Found mapping for '$categoryName'. Using correct urlKey: '${categoryData.urlKey}'");
  //     urlKey = categoryData.urlKey;
  //   } else {
  //     // 3. If no mapping exists (for a sub-category, for example), fall back to the old dynamic generation.
  //     // This makes your function robust for both top-level and deeper categories.
  //     print("No mapping found for '$categoryName'. Generating urlKey dynamically.");
  //     urlKey = categoryName
  //         .toLowerCase()
  //         .replaceAll("'", "")
  //         .replaceAll('&', 'and')
  //         .replaceAll(RegExp(r'[\s_]+'), '-')
  //         .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  //   }
  //
  //   // --- END OF NEW LOGIC ---
  //
  //   // The rest of the function now uses the 'urlKey' variable, which will be correct.
  //   final url = Uri.parse('${ApiConstants.baseUrl}/V1/solr/category-by-url-key/$urlKey');
  //   print('Requesting Category Metadata from URL:>> $url');
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.get(url);
  //
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body:category-by-url-key ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final dynamic decodedBody = json.decode(response.body);
  //
  //       // --- PARSING LOGIC FOR THE SPECIFIC ARRAY RESPONSE ---
  //       if (decodedBody is List && decodedBody.length >= 5) {
  //         print("API returned a List. Parsing based on fixed order.");
  //         // --- Parse default data from API ---
  //         String catName = decodedBody[0].toString();
  //         int catLevel = decodedBody[1];
  //         String catUrlKey = decodedBody[2].toString();
  //         String pareCatId = decodedBody[3].toString();
  //         String catId = decodedBody[4].toString();
  //
  //         // --- Custom override for "New In" ---
  //         if (catUrlKey.toLowerCase() == 'new-in' || catName.toLowerCase() == 'new in') {
  //           print("🟡 Overriding category ID for 'New In' to 1372");
  //           catId = '1372'; // ✅ Forced override
  //         }
  //
  //         return {
  //           'cat_name': decodedBody[0].toString(),
  //           'cat_level': decodedBody[1],
  //           'cat_url_key': decodedBody[2].toString(),
  //           'pare_cat_id': decodedBody[3].toString(),
  //           'cat_id': decodedBody[4].toString(),
  //         };
  //       } else if (decodedBody is Map<String, dynamic>) {
  //         print("API returned a Map as expected.");
  //         return decodedBody;
  //       } else {
  //         throw Exception('API returned an unexpected data format that could not be parsed.');
  //       }
  //     } else {
  //       String errorMessage = 'Category not found: $categoryName';
  //       try {
  //         final decodedError = json.decode(response.body);
  //         if (decodedError['message'] != null) { errorMessage = decodedError['message']; }
  //       } catch (_) { errorMessage = response.body; }
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e, stackTrace) {
  //     print('--- ERROR FETCHING CATEGORY METADATA ---');
  //     print('Exception Type: ${e.runtimeType}');
  //     print('Exception Object: $e');
  //     print('Stack Trace: \n$stackTrace');
  //     print('--- END ERROR ---');
  //     throw Exception('Could not load category details. Please check the debug console.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }
  // Future<Map<String, dynamic>> fetchCategoryMetadataByName(String categoryName) async {
  //   final urlKey = categoryName
  //       .toLowerCase()
  //       .replaceAll("'", "")
  //       .replaceAll('&', 'and')
  //       .replaceAll(RegExp(r'[\s_]+'), '-')
  //       .replaceAll(RegExp(r'[^a-z0-9-]'), '');
  //
  //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
  //   print('Requesting Category Metadata from URL: $url');
  //
  //   HttpClient httpClient = HttpClient();
  //   httpClient.badCertificateCallback = (cert, host, port) => true;
  //   IOClient ioClient = IOClient(httpClient);
  //
  //   try {
  //     final response = await ioClient.get(url);
  //
  //     print('Response Status Code: ${response.statusCode}');
  //     print('Response Body:category-by-url-key ${response.body}');
  //
  //     if (response.statusCode == 200) {
  //       final dynamic decodedBody = json.decode(response.body);
  //
  //       // --- PARSING LOGIC FOR THE SPECIFIC ARRAY RESPONSE ---
  //       if (decodedBody is List && decodedBody.length >= 5) {
  //         print("API returned a List. Parsing based on fixed order.");
  //
  //         // Manually build the Map that the app expects, based on the known order.
  //         // ["Men", 2, "men", 1381, 1371]
  //         //  [0]    [1]   [2]    [3]    [4]
  //         // We use .toString() to be safe with types.
  //         return {
  //           'cat_name': decodedBody[0].toString(),
  //           'cat_level': decodedBody[1], // Assuming this is an int
  //           'cat_url_key': decodedBody[2].toString(),
  //           'pare_cat_id': decodedBody[3].toString(),
  //           'cat_id': decodedBody[4].toString(), // This is the crucial ID
  //         };
  //
  //       } else if (decodedBody is Map<String, dynamic>) {
  //         // Fallback for if the API ever gets fixed to return a proper map
  //         print("API returned a Map as expected.");
  //         return decodedBody;
  //       } else {
  //         // If the response is neither a valid list nor a map, throw an error.
  //         throw Exception('API returned an unexpected data format that could not be parsed.');
  //       }
  //
  //     } else {
  //       // ... existing error handling for non-200 status codes ...
  //       String errorMessage = 'Category not found: $categoryName';
  //       try {
  //         final decodedError = json.decode(response.body);
  //         if (decodedError['message'] != null) { errorMessage = decodedError['message']; }
  //       } catch (_) { errorMessage = response.body; }
  //       throw Exception(errorMessage);
  //     }
  //   } catch (e, stackTrace) {
  //     // ... existing catch block ...
  //     print('--- ERROR FETCHING CATEGORY METADATA ---');
  //     print('Exception Type: ${e.runtimeType}');
  //     print('Exception Object: $e');
  //     print('Stack Trace: \n$stackTrace');
  //     print('--- END ERROR ---');
  //     throw Exception('Could not load category details. Please check the debug console.');
  //   } finally {
  //     ioClient.close();
  //   }
  // }




}


// class ApiService {
//   // ✅ DEFINE YOUR WHITELIST OF FILTERS TO DISPLAY
//   // These are the 'keys' from the API response.
//   static const List<String> _allowedFilterKeys = [
//     'themes',
//     'categories', // The key for the "Category" filter
//     'designers',
//     'colors',
//     'sizes',
//     'delivery_times', // The key for the "Delivery" or "Ships In" filter
//     'price',
//     'a_co_edit', // The key for the "A+CO Edits" filter
//     'occasions'
//   ];
//
//   // Fetches and parses the filter options from your Magento API.
//   Future<List<FilterOption>> fetchFilterOptions(String categoryId) async {
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category/$categoryId/filters');
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//       final response = await ioClient.get(url);
//
//       if (response.statusCode == 200) {
//         final List<dynamic> rawData = json.decode(response.body);
//         final List<FilterOption> allOptions = [];
//
//         const excludeKeys = ['child_categories', 'min_price', 'max_price', 'curr_symb'];
//
//         // First, parse ALL filters from the API response
//         for (var item in rawData) {
//           if (item is Map<String, dynamic>) {
//             final key = item.keys.first;
//             if (!excludeKeys.contains(key)) {
//               // Generate a more user-friendly label
//               String label;
//               if (key == 'categories') {
//                 label = 'Category';
//               } else if (key == 'delivery_times') {
//                 label = 'Delivery';
//               } else if (key == 'a_co_edit') {
//                 label = 'A+CO Edits';
//               } else {
//                 label = key.replaceAll('_', ' ').split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
//               }
//
//               allOptions.add(FilterOption(key: key, label: label));
//             }
//           }
//         }
//
//         // ✅ NOW, FILTER THE LIST TO ONLY INCLUDE THE ALLOWED KEYS
//         final List<FilterOption> filteredOptions = allOptions.where((option) {
//           return _allowedFilterKeys.contains(option.key);
//         }).toList();
//
//         // Optional: Sort the filtered list to match your desired order
//         filteredOptions.sort((a, b) {
//           final indexA = _allowedFilterKeys.indexOf(a.key);
//           final indexB = _allowedFilterKeys.indexOf(b.key);
//           return indexA.compareTo(indexB);
//         });
//
//         return filteredOptions;
//
//       } else {
//         throw Exception('Failed to load filters: Status code ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching filters: $e');
//       throw Exception('Failed to load filters. Please check your connection.');
//     }
//   }
//
//   Future<List<CategoryFilterItem>> fetchCategoryFilters(String categoryId) async {
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category/$categoryId/filters');
//
//     try {
//       final response = await ioClient.get(url);
//
//       if (response.statusCode == 200) {
//         final List<dynamic> rawData = json.decode(response.body);
//
//         // Find the 'categories' and 'child_categories' objects from the API response array
//         Map<String, dynamic> categoriesData = {};
//         Map<String, dynamic> childCategoriesData = {};
//
//         for (var item in rawData) {
//           if (item is Map<String, dynamic>) {
//             if (item.containsKey('categories')) {
//               categoriesData = item['categories'];
//             }
//             if (item.containsKey('child_categories')) {
//               childCategoriesData = item['child_categories'];
//             }
//           }
//         }
//
//         if (categoriesData.isEmpty) {
//           return []; // No categories found
//         }
//
//         // Build the hierarchical list
//         final List<CategoryFilterItem> categoryList = [];
//
//         categoriesData.forEach((parentId, parentName) {
//           final List<CategoryFilterItem> children = [];
//
//           // Check if this parent has children defined in the 'child_categories' map
//           if (childCategoriesData.containsKey(parentId)) {
//             final Map<String, dynamic> childMap = childCategoriesData[parentId];
//             childMap.forEach((childId, childName) {
//               // Create a child item with an empty children list
//               children.add(CategoryFilterItem.fromMap(childId, childName, []));
//             });
//           }
//
//           // Create the parent item with its processed children
//           categoryList.add(CategoryFilterItem.fromMap(parentId, parentName, children));
//         });
//
//         return categoryList;
//
//       } else {
//         throw Exception('Failed to load category filters: Status code ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching category filters: $e');
//       throw Exception('Failed to load category filters. Please check your connection.');
//     }
//   }
// }


