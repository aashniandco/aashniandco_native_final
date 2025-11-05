// lib/features/category_products/bloc/category_products_bloc.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

// Assuming these are defined elsewhere
import 'package:aashniandco/constants/api_constants.dart';

import '../../newin/model/new_in_model.dart';
import '../model/category_data.dart';
import '../repository/category_mapping.dart';
import 'category_products_event.dart';
import 'category_products_state.dart';

//
// class CategoryProductsBloc extends Bloc<CategoryProductsEvent, CategoryProductsState> {
//   CategoryProductsBloc() : super(CategoryProductsLoading()) {
//     on<FetchProductsForCategory>(_onFetchProductsForCategory);
//   }
//
//   Future<void> _onFetchProductsForCategory(
//       FetchProductsForCategory event, Emitter<CategoryProductsState> emit) async {
//     emit(CategoryProductsLoading());
//
//     // ✅ This line now works correctly because the event has 'categoryName'
//     final String categoryName = event.categoryName.toLowerCase();
//     print("Fetching products for category: $categoryName");
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final Map<String, dynamic> body = {
//         "queryParams": {
//           "query": 'categories-store-1_name:("$categoryName")', // Corrected query key
//           "params": {
//             "fl": "designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price_1",
//             "rows": "1400000", // A very high number of rows can impact performance
//             "sort": "prod_en_id desc"
//           }
//         }
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("API Response Body:>> ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         if (decoded is List && decoded.length > 1 && decoded[1]['docs'] is List) {
//           final docs = decoded[1]['docs'] as List;
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//           emit(CategoryProductsLoaded(products: products));
//         } else {
//           emit(CategoryProductsError("Invalid response format from server."));
//         }
//       } else {
//         emit(CategoryProductsError("Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(CategoryProductsError("No internet connection. Please check your network."));
//     } catch (e) {
//       emit(CategoryProductsError("An unexpected error occurred: $e"));
//     }
//   }
//
// }

// lib/features/category_products/bloc/category_products_bloc.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
// Import your event and state files that use the simpler pattern
import 'category_products_event.dart';
import 'category_products_state.dart';
// Import your models and constants
import '../../newin/model/new_in_model.dart'; // Assuming this has your Product model
// Your API constants

// lib/features/category_products/bloc/category_products_bloc.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'category_products_event.dart';
import 'category_products_state.dart';
import '../../newin/model/new_in_model.dart';
import 'filtered_products_bloc.dart';


import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:http/io_client.dart';
import 'package:equatable/equatable.dart';

import 'category_products_event.dart';
import 'category_products_state.dart';


// In your category_products_bloc.dart

import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';


// lib/bloc/category_products/category_products_bloc.dart

import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/io_client.dart';

// --- Your project-specific imports ---
// Adjust path



// lib/bloc/category_products/category_products_bloc.dart

import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/io_client.dart';

// --- Your project-specific imports ---

const int _productsPerPage = 10;

class CategoryProductsBloc extends Bloc<CategoryProductsEvent, CategoryProductsState> {
  CategoryProductsBloc() : super(const CategoryProductsState()) {
    on<FetchProducts>(_onFetchProducts);
  }

  // --- MODIFIED HELPER FUNCTION ---
  String _getSortParameter(String sortOption, int categoryId) {
    const String tieBreaker = 'prod_en_id asc'; // Keep the stable sort tie-breaker

    switch (sortOption) {
      case "Price: High to Low":
      // --- CHANGE THIS LINE ---
      // Sort by the numeric field 'actual_price_1', not 'actual_price'.
        return 'actual_price_1 desc, $tieBreaker';

      case "Price: Low to High":
      // --- AND CHANGE THIS LINE ---
        return 'actual_price_1 asc, $tieBreaker';

      case "Latest":
        return 'prod_en_id desc, $tieBreaker';

      case "Default":
      default:
        return 'cat_position_1_${categoryId} desc, $tieBreaker';
    }

  }


  // Helper function to build the filter string from selected filters
  String _buildFilterQuery(int initialCategoryId, List<Map<String, String>>? filters) {
    // If no filters are applied, just use the initial category ID.
    if (filters == null || filters.isEmpty) {
      return 'categories-store-1_id:($initialCategoryId) AND actual_price_1:{0 TO *}';
    }

    // Group filters by their type (e.g., 'categories', 'designer_name')
    final Map<String, List<String>> groupedFilters = {};
    for (var filter in filters) {
      // Ensure keys exist and are not null before using them.
      final type = filter['type'];
      final id = filter['id'];

      if (type != null && id != null) {
        if (!groupedFilters.containsKey(type)) {
          groupedFilters[type] = [];
        }
        groupedFilters[type]!.add(id);
      }
    }

    // If after processing, the map is empty, fall back to the initial category.
    if (groupedFilters.isEmpty) {
      return 'categories-store-1_id:($initialCategoryId) AND actual_price_1:{0 TO *}';
    }

    // Build the query parts for each filter type.
    final List<String> queryParts = [];
    groupedFilters.forEach((type, ids) {
      // This mapping needs to match your Solr schema field names.
      // Adjust as necessary.
      final String fieldName;
      switch (type) {
        case 'categories':
          fieldName = 'categories-store-1_id';
          break;
        case 'designer_name': // Example for another filter type
          fieldName = 'designer_name_id'; // Or whatever the field is called
          break;
      // Add other cases for 'color', 'occasion', etc.
        default:
        // A safe fallback, though ideally all types should be handled.
          fieldName = '${type}_id';
          break;
      }
      queryParts.add('$fieldName:(${ids.join(' OR ')})');
    });

    // Combine all parts with AND and add the price filter.
    return '${queryParts.join(' AND ')} AND actual_price_1:{0 TO *}';
  }


  Future<void> _onFetchProducts(
      FetchProducts event, Emitter<CategoryProductsState> emit) async {
    // For pagination, if we've already reached the max, do nothing.
    if (state.hasReachedMax && !event.isReset) return;

    try {
      // When a new fetch/reset is triggered:
      if (event.isReset) {
        // Immediately emit a loading state, clear old products, and store the new filters.
        emit(state.copyWith(
          status: CategoryProductsStatus.loading,
          products: [],
          hasReachedMax: false,
          activeFilters: event.selectedFilters,
          currentSortOption: event.sortOption,
        ));
      } else {
        // For pagination, just indicate loading status.
        emit(state.copyWith(status: CategoryProductsStatus.loading));
      }
      final String categoryKey = event.categoryName.toLowerCase();
      final CategoryData? categoryData = CategoryMapping.getDataByName(categoryKey);
      // --- 1. Get Category ID ---
      // final String categoryName = event.categoryName.toLowerCase();
      // final int? categoryId = CategoryMapping.categoryNameToId[categoryName];
      //
      // if (categoryId == null) {
      //   emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Category ID not found for: $categoryName"));
      //   return;
      // }

      if (categoryData == null) {
        // This now correctly handles the case where the simple key isn't in the map.
        emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Category ID not found for: $categoryKey"));
        return;
      }

      final int categoryId = categoryData.id;
      // --- 2. Determine Filters & Position ---
      // Use the filters from the event on a fresh load, or from the state for pagination.
      final currentFilters = event.isReset ? event.selectedFilters : state.activeFilters;
      final int startPosition = event.isReset ? 0 : state.products.length;

      // --- 3. Determine Sort Parameter ---
      // We can only use positional sort if ONE category is selected and NO other filters are active.
      final categoryFilters = currentFilters?.where((f) => f['type'] == 'categories').toList() ?? [];
      final bool canUsePositionalSort = (currentFilters == null || currentFilters.isEmpty) ||
          (categoryFilters.length == 1 && currentFilters.length == 1);

      final String sortParam;
      if (canUsePositionalSort && event.sortOption == "Default") {
        // It's safe to use the positional sort.
        sortParam = _getSortParameter("Default", categoryId);
      } else {
        // In a multi-filter view or with a specific sort selected, positional sort is invalid.
        // Fallback to a non-positional sort. If the user chose a specific sort, use it.
        // Otherwise, default to 'Latest'.
        final sortToUse = event.sortOption == "Default" ? "Latest" : event.sortOption;
        sortParam = _getSortParameter(sortToUse, categoryId);
      }

      // --- 4. Build Final Query ---
      final String filterQuery = _buildFilterQuery(categoryId, currentFilters);

      // --- START OF THE FIX ---
      // This is the permanent filter to hide products where the price is 0 or 1.
      // It checks both possible price fields to be safe.
      final String priceFilter = "(actual_price:[2 TO *] AND actual_price_1:[2 TO *])";

      // Combine the user's filters (like color/size) with our permanent price filter.
      String finalFilterQuery;
      if (filterQuery == '*:*' || filterQuery.isEmpty) {
        // If there are no other filters, our price filter is the only rule.
        finalFilterQuery = priceFilter;
      } else {
        // If there are other filters, we combine them with an AND.
        finalFilterQuery = "($filterQuery) AND $priceFilter";
      }
      // --- END OF THE FIX ---

      final String fieldsToReturn = "designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price_1";
      final String rowCount = "$_productsPerPage";
      final String start = "$startPosition";

      final String solrQueryWithLocalParams =
          "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount' start='$start'}$filterQuery";

      // --- 5. Make API Call ---
      final uri = Uri.parse(ApiConstants.url);
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);
      final Map<String, dynamic> body = { "queryParams": { "query": solrQueryWithLocalParams } };
      final String encodedBody = jsonEncode(body);

      print("🚀 MAKING API REQUEST:>> $encodedBody");

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: encodedBody,
      );

      print("✅ API RESPONSE>> [${response.statusCode}]: ${response.body.substring(0, 300)}...");

      // --- 6. Process Response ---
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
          final docs = decoded[1]['docs'] as List;
          final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
          final hasReachedMax = newProducts.length < _productsPerPage;

          // If it was a reset, replace the products. Otherwise, append them.
          final updatedProducts = event.isReset ? newProducts : (state.products + newProducts);

          emit(state.copyWith(
            status: CategoryProductsStatus.success,
            products: updatedProducts,
            hasReachedMax: hasReachedMax,
          ));
        } else {
          emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Invalid response format from server."));
        }
      } else {
        emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ API Error. Status: ${response.statusCode}"));
      }
    } on SocketException {
      emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ No internet connection."));
    } catch (e) {
      emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Unexpected error: $e"));
    }
  }

  // Future<void> _onFetchProducts(
  //     FetchProducts event, Emitter<CategoryProductsState> emit) async {
  //   if (state.hasReachedMax && !event.isReset) return;
  //
  //   try {
  //     if (event.isReset) {
  //       emit(state.copyWith(status: CategoryProductsStatus.loading, products: [], hasReachedMax: false,activeFilters: event.selectedFilters,));
  //     }
  //
  //     final String categoryName = event.categoryName.toLowerCase();
  //     final int? categoryId = CategoryMapping.categoryNameToId[categoryName];
  //
  //     if (categoryId == null) {
  //       emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Category ID not found for: $categoryName"));
  //       return;
  //     }
  //
  //     // Use the filters from the event on a fresh load, or from the state for pagination
  //     final currentFilters = event.isReset ? event.selectedFilters : state.activeFilters;
  //
  //
  //
  //     final int startPosition = event.isReset ? 0 : state.products.length;
  //
  //     final String sortParam = _getSortParameter(event.sortOption, categoryId);
  //     final String filterQuery = 'categories-store-1_id:(${categoryId}) AND actual_price_1:{0 TO *}';
  //     final String fieldsToReturn = "designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price_1";
  //     final String rowCount = "$_productsPerPage";
  //     final String start = "$startPosition";
  //
  //     final String solrQueryWithLocalParams =
  //         "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount' start='$start'}$filterQuery";
  //
  //     final uri = Uri.parse(ApiConstants.url);
  //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final Map<String, dynamic> body = { "queryParams": { "query": solrQueryWithLocalParams } };
  //     final String encodedBody = jsonEncode(body);
  //
  //     // --- DEBUGGING PRINTS ---
  //     print("----------------------------------------------------");
  //     print("🚀 MAKING API REQUEST");
  //     print("   URL:>> $uri");
  //     print("   Sort Option: ${event.sortOption}");
  //     print("   Is Reset: ${event.isReset}");
  //     print("   Request Body: $encodedBody");
  //     print("----------------------------------------------------");
  //
  //
  //     final response = await ioClient.post(
  //       uri,
  //       headers: {"Content-Type": "application/json"},
  //       body: encodedBody,
  //     );
  //
  //     // --- HERE IS THE KEY CHANGE: PRINT THE RAW RESPONSE ---
  //     print("\n----------------------------------------------------");
  //     print("✅ API RESPONSE RECEIVED");
  //     print("   Status Code: ${response.statusCode}");
  //     print("   Response Body: ${response.body}"); // This will print the full raw JSON string
  //     print("----------------------------------------------------");
  //
  //
  //     if (response.statusCode == 200) {
  //       // Now we attempt to parse the body we just printed
  //       final decoded = jsonDecode(response.body);
  //
  //       if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
  //         final docs = decoded[1]['docs'] as List;
  //         final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
  //
  //         final hasReachedMax = newProducts.length < _productsPerPage;
  //         final updatedProducts = event.isReset
  //             ? newProducts
  //             : (state.products + newProducts);
  //
  //         emit(state.copyWith(
  //           status: CategoryProductsStatus.success,
  //           products: updatedProducts,
  //           hasReachedMax: hasReachedMax,
  //           currentSortOption: event.sortOption,
  //         ));
  //       } else {
  //         // If this error occurs, check the "Response Body" printout to see why the format is wrong.
  //         emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Invalid response format from server."));
  //       }
  //     } else {
  //       emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ API Error. Status: ${response.statusCode}"));
  //     }
  //   } on SocketException {
  //     emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ No internet connection."));
  //   } catch (e) {
  //     // This will catch errors during jsonDecode if the response body is not valid JSON.
  //     emit(state.copyWith(status: CategoryProductsStatus.failure, errorMessage: "❌ Unexpected error: $e"));
  //   }
  // }
}

//17/7/2025
// class CategoryProductsBloc extends Bloc<CategoryProductsEvent, CategoryProductsState> {
//   CategoryProductsBloc() : super(CategoryProductsLoading()) {
//     on<FetchProductsForCategory>(_onFetchProductsForCategory);
//   }
//
//   Future<void> _onFetchProductsForCategory(
//       FetchProductsForCategory event, Emitter<CategoryProductsState> emit) async {
//     emit(CategoryProductsLoading());
//
//     final String categoryName = event.categoryName.toLowerCase();
//     final int? categoryId = CategoryMapping.categoryNameToId[categoryName];
//
//     if (categoryId == null) {
//       emit(CategoryProductsError("❌ Category ID not found for: $categoryName"));
//       return;
//     }
//
//     // --- STEP 1: DEFINE ALL PARAMETERS AS STRINGS ---
//     final String sortParam = 'cat_position_1_${categoryId} desc';
//     final String filterQuery = 'categories-store-1_id:(${categoryId})';
//     final String fieldsToReturn = "designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price_1";
//     final String rowCount = "1400000"; // Be cautious with such a high number
//
//     // --- STEP 2: BUILD THE SOLR QUERY WITH LOCAL PARAMS ---
//     // This is the key. We are building a single string that contains all instructions.
//     // The syntax {!...} embeds parameters directly into the query.
//     // Note the single quotes around the sort value because it contains a space.
//     final String solrQueryWithLocalParams =
//         "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount'}$filterQuery";
//
//     print("✅ Final Solr Query String being sent: $solrQueryWithLocalParams");
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       // --- STEP 3: USE THE SIMPLEST WORKING BODY STRUCTURE ---
//       // We send ONLY the 'query' field, containing our perfectly crafted string.
//       // This is the only thing the API gateway seems to process correctly.
//       final Map<String, dynamic> body = {
//         "queryParams": {
//           "query": solrQueryWithLocalParams,
//         }
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("✅ BLoC Solr Response: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         // The parsing logic for the custom LIST response remains the same
//         if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
//           final docs = decoded[1]['docs'] as List;
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//           emit(CategoryProductsLoaded(products: products));
//         } else {
//           emit(CategoryProductsError("❌ Invalid response format from server."));
//         }
//       } else {
//         emit(CategoryProductsError("❌ Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(CategoryProductsError("❌ No internet connection. Please check your network."));
//     } catch (e) {
//       emit(CategoryProductsError("❌ Unexpected error: $e"));
//     }
//   }
// }
//

// class CategoryProductsBloc extends Bloc<CategoryProductsEvent, CategoryProductsState> {
//   CategoryProductsBloc() : super(CategoryProductsLoading()) {
//     on<FetchProductsForCategory>(_onFetchProductsForCategory);
//   }
//
//   Future<void> _onFetchProductsForCategory(
//       FetchProductsForCategory event, Emitter<CategoryProductsState> emit) async {
//     emit(CategoryProductsLoading());
//
//     // ✅ This line now works correctly because the event has 'categoryName'
//     final String categoryName = event.categoryName.toLowerCase();
//     print("Fetching products for category: $categoryName");
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final Map<String, dynamic> body = {
//         "queryParams": {
//           "query": 'categories-store-1_name:("$categoryName")', // Corrected query key
//           "params": {
//             "fl": "designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price_1",
//             "rows": "1400000", // A very high number of rows can impact performance
//             "sort": "prod_en_id desc"
//           }
//         }
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("API Response Body:>> ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         if (decoded is List && decoded.length > 1 && decoded[1]['docs'] is List) {
//           final docs = decoded[1]['docs'] as List;
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//           emit(CategoryProductsLoaded(products: products));
//         } else {
//           emit(CategoryProductsError("Invalid response format from server."));
//         }
//       } else {
//         emit(CategoryProductsError("Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(CategoryProductsError("No internet connection. Please check your network."));
//     } catch (e) {
//       emit(CategoryProductsError("An unexpected error occurred: $e"));
//     }
//   }
//
// }