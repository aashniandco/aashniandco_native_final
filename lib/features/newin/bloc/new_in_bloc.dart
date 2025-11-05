// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:aashniandco/features/newin/model/new_in_model.dart';
// import 'package:bloc/bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart';
// import 'package:meta/meta.dart';
//
// import 'new_in_theme_state.dart';
// part 'new_in_theme_event.dart';
//
// class NewInBloc extends Bloc<NewInEvent, NewInState> {
//   NewInBloc() : super(NewInLoading()) {
//     on<FetchNewIn>(_onFetchNewIn);
//   }
//
//   Future<void> _onFetchNewIn(
//       FetchNewIn event, Emitter<NewInState> emit) async {
//     emit(NewInLoading());
//
//     final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");
//
//     try {
//       // Allow bad SSL certs
  //       HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback =
  //           (X509Certificate cert, String host, int port) => true;
  //       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.get(
//         url,
//         headers: {"Connection": "keep-alive"},
//       );
//
//       // print('🔁 Raw Response: ${response.body}');
//
//       if (response.statusCode == 200) {
//         final jsonData = jsonDecode(response.body);
//
//         final List<dynamic> productList = jsonData['products'] ?? [];
//
//         print("Parsed product list length: ${productList.length}");
//
//         final List<NewInProduct> products = productList
//             .map((item) => NewInProduct.fromJson(item))
//             .toList();
//
//         emit(NewInLoaded(products: products));
//       } else {
//         emit(NewInError("Failed to fetch products: ${response.statusCode}"));
//       }
//     } catch (e) {
//       emit(NewInError("Error: $e"));
//     }
//   }
// }


import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/features/newin/model/new_in_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

import 'new_in_state.dart';




part 'new_in_event.dart';




const int _productsPerPage = 20;
const int _newInCategoryId = 1372;

class NewInBloc extends Bloc<NewInEvent, NewInState> {
  NewInBloc() : super(const NewInState()) {
    on<FetchNewInProducts>(_onFetchNewInProducts);
  }

  // This helper function remains the same
  String _getSortParameter(String sortOption) {
    const String tieBreaker = 'prod_en_id asc ';
    switch (sortOption) {
      case "Price: High to Low":
        return 'actual_price_1 desc, $tieBreaker';
      case "Price: Low to High":
        return 'actual_price_1 asc, $tieBreaker';
      case "Latest":
        return 'prod_en_id desc, $tieBreaker';
      case "Default":
      default:
        return 'cat_position_1_${_newInCategoryId} desc, $tieBreaker';
    }
  }

  Future<void> _onFetchNewInProducts(
      FetchNewInProducts event, Emitter<NewInState> emit) async {
    // ... (guards at the top remain the same) ...
    if (state.hasReachedMax && !event.isReset) return;
    if (state.status == NewInStatus.loading && !event.isReset) return;

    try {
      // ... (code to set loading state and build query parameters remains the same) ...
      if (event.isReset) {
        emit(state.copyWith(status: NewInStatus.loading, products: [], hasReachedMax: false));
      } else {
        emit(state.copyWith(status: NewInStatus.loading));
      }

      final int startPosition = event.isReset ? 0 : state.products.length;
      final String sortParam = _getSortParameter(event.sortOption);
      final String filterQuery = 'categories-store-1_id:(${_newInCategoryId}) AND actual_price_1:{0 TO *}';
      final String fieldsToReturn = "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price";
      final String rowCount = "$_productsPerPage";
      final String start = "$startPosition";

      final String solrQueryWithLocalParams =
          "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount' start='$start'}$filterQuery";

      final uri = Uri.parse(ApiConstants.url);
      HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final Map<String, dynamic> body = { "queryParams": { "query": solrQueryWithLocalParams } };

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // --- ADD THIS BLOCK TO PRINT THE RESPONSE CONDITIONALLY ---
      // This `if` condition checks the sortOption from the incoming event.
      if (event.sortOption == "Default") {
        print("\n✅✅✅ DEBUG: API RESPONSE FOR 'DEFAULT' SORT ✅✅✅");
        print("   Status Code: ${response.statusCode}");
        print("   Response Body: ${response.body}"); // Prints the full raw JSON string
        print("✅✅✅ END DEBUG ✅✅✅\n");
      }
      // --- END OF THE ADDED BLOCK ---

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
          final docs = decoded[1]['docs'] as List;
          final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
          final hasReachedMax = newProducts.length < _productsPerPage;
          final updatedProducts = event.isReset ? newProducts : (state.products + newProducts);

          emit(state.copyWith(
            status: NewInStatus.success,
            products: updatedProducts,
            hasReachedMax: hasReachedMax,
            currentSortOption: event.sortOption,
          ));
        } else {
          emit(state.copyWith(status: NewInStatus.failure, errorMessage: "❌ Invalid server response format."));
        }
      } else {
        emit(state.copyWith(status: NewInStatus.failure, errorMessage: "❌ API Error. Status: ${response.statusCode}"));
      }
    } on SocketException {
      emit(state.copyWith(status: NewInStatus.failure, errorMessage: "❌ No internet connection."));
    } catch (e) {
      emit(state.copyWith(status: NewInStatus.failure, errorMessage: "❌ Unexpected error: $e"));
    }
  }
}
//17/7/2025

// class NewInBloc extends Bloc<NewInEvent, NewInState> {
//   NewInBloc() : super(NewInLoading()) {
//     on<FetchNewIn>(_onFetchNewIn);
//   }
//
//   /// Fetches ALL products for the "New In" category in a single request.
//   Future<void> _onFetchNewIn(
//       FetchNewIn event, Emitter<NewInState> emit) async {
//     // Only show the loading indicator if this is the first time.
//     if (state is! NewInLoaded) {
//       emit(NewInLoading());
//     }
//
//     const int categoryId = 1372;
//
//     // --- Build the query to fetch all items ---
//     final String sortParam = 'cat_position_1_${categoryId} desc';
//     final String filterQuery = 'categories-store-1_id:($categoryId)';
//     final String fieldsToReturn =
//         "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price";
//
//     // Request a very large number of rows to get all products.
//     final String rowCount = "40000";
//
//     final String solrQueryWithLocalParams =
//         "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount'}$filterQuery";
//
//     print("✅ NewInBloc (Fetch All): Final Solr Query: $solrQueryWithLocalParams");
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final Map<String, dynamic> body = {
//         "queryParams": {"query": solrQueryWithLocalParams}
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("✅ NewInBloc Solr Response Status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
//           final docs = decoded[1]['docs'] as List;
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//
//           emit(NewInLoaded(
//             products: products,
//             hasReachedEnd: true, // It's always "true" as we have all data.
//           ));
//         } else {
//           emit(NewInError("❌ Invalid response format from server."));
//         }
//       } else {
//         emit(NewInError("❌ Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(NewInError("❌ No internet connection."));
//     } catch (e) {
//       emit(NewInError("❌ Unexpected error: $e"));
//     }
//   }
// }

//15 july 2025

// class NewInBloc extends Bloc<NewInEvent, NewInState> {
//   // No longer needs a page size.
//   NewInBloc() : super(NewInLoading()) {
//     on<FetchNewIn>(_onFetchNewIn);
//   }
//
//   /// Fetches ALL products for the "New In" category in a single request.
//   /// Pagination has been removed.
//   Future<void> _onFetchNewIn(
//       FetchNewIn event, Emitter<NewInState> emit) async {
//     // Always show a loading indicator on any fetch.
//     emit(NewInLoading());
//
//     const int categoryId = 1372;
//
//     // --- Build the query to fetch all items ---
//     final String sortParam = 'cat_position_1_${categoryId} desc';
//     final String filterQuery = 'categories-store-1_id:($categoryId)';
//     final String fieldsToReturn =
//         "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time,actual_price";
//
//     // Request a very large number of rows to get all products.
//     final String rowCount = "40000";
//
//     // The 'start' parameter is removed as we are not paginating.
//     final String solrQueryWithLocalParams =
//         "{!sort='$sortParam' fl='$fieldsToReturn' rows='$rowCount'}$filterQuery";
//
//     print("✅ NewInBloc (No Pagination): Final Solr Query: $solrQueryWithLocalParams");
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final Map<String, dynamic> body = {
//         "queryParams": {"query": solrQueryWithLocalParams}
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );
//
//       print("✅ NewInBloc Solr Response Status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         if (decoded is List && decoded.length > 1 && decoded[1] is Map && decoded[1]['docs'] is List) {
//           final docs = decoded[1]['docs'] as List;
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//
//           // Emit a single 'Loaded' state. 'hasReachedEnd' is true because we have all items.
//           emit(NewInLoaded(
//             products: products,
//             hasReachedEnd: true, // Always true when not paginating
//           ));
//         } else {
//           emit(NewInError("❌ Invalid response format from server."));
//         }
//       } else {
//         emit(NewInError("❌ Failed to load products. Status code: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(NewInError("❌ No internet connection."));
//     } catch (e) {
//       emit(NewInError("❌ Unexpected error: $e"));
//     }
//   }
// }

// class NewInBloc extends Bloc<NewInEvent,NewInState>{
//   NewInBloc() : super(NewInLoading()) {
//     on<FetchNewIn>(_onFetchNewIn);
//   }
//
//   // Future<void> _onFetchNewIn(
//   //     FetchNewIn event, Emitter<NewInState> emit) async {
//   //   emit(NewInLoading());
//   //
//   //   final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");
//   //
//   //   try {
//   //     // Allow bad SSL certs
//   //         HttpClient httpClient = HttpClient();
//   //         httpClient.badCertificateCallback =
//   //             (X509Certificate cert, String host, int port) => true;
//   //         IOClient ioClient = IOClient(httpClient);
//   //
//   //     final response = await ioClient.get(
//   //       url,
//   //       headers: {"Connection": "keep-alive"},
//   //     );
//   //
//   //     // print('🔁 Raw Response: ${response.body}');
//   //
//   //     if (response.statusCode == 200) {
//   //       final jsonData = jsonDecode(response.body);
//   //
//   //       final List<dynamic> productList = jsonData['products'] ?? [];
//   //
//   //       print("Parsed product list length: ${productList.length}");
//   //
//   //       final List<Product> products = productList
//   //           .map((item) => Product.fromJson(item))
//   //           .toList();
//   //
//   //       emit(NewInLoaded(products: products));
//   //     } else {
//   //       emit(NewInError("Failed to fetch products: ${response.statusCode}"));
//   //     }
//   //   } catch (e) {
//   //     emit(NewInError("Error: $e"));
//   //   }
//   // }
//
//
// //19 june
//
//   // Future<void> _onFetchNewIn(FetchNewIn event, Emitter<NewInState> emit) async {
//   //   final int page = event.page;
//   //   final int pageSize = 10;
//   //   final int start = page * pageSize;
//   //
//   //   try {
//   //     HttpClient httpClient = HttpClient();
//   //     httpClient.badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //
//   //     final uri = Uri.parse(ApiConstants.url);
//   //     final Map<String, dynamic> body = {
//   //       "queryParams": {
//   //         "query": 'categories-store-1_name:("new in")',
//   //         "params": {
//   //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time",
//   //           "rows": "$pageSize",
//   //           "start": "$start",
//   //           "sort": "prod_en_id desc"
//   //         }
//   //       }
//   //     };
//   //
//   //     final response = await ioClient.post(
//   //       uri,
//   //       headers: {"Content-Type": "application/json"},
//   //       body: jsonEncode(body),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final decoded = jsonDecode(response.body);
//   //       print("Decoded response: $decoded"); // Debug: See actual structure
//   //
//   //       List<dynamic> docs = [];
//   //
//   //       // Safely detect response format
//   //       if (decoded is List && decoded.length > 1 && decoded[1] is Map) {
//   //         docs = decoded[1]['docs'] ?? [];
//   //       } else if (decoded is Map && decoded['response'] is Map) {
//   //         docs = decoded['response']['docs'] ?? [];
//   //       } else {
//   //         emit(NewInError("Unexpected response format"));
//   //         return;
//   //       }
//   //
//   //       final List<Product> products = docs.map((doc) => Product.fromJson(doc)).toList();
//   //
//   //       final currentState = state;
//   //       if (currentState is NewInLoaded) {
//   //         final List<Product> allProducts = [
//   //           ...currentState.products,
//   //           ...products
//   //         ];
//   //         emit(NewInLoaded(
//   //           products: allProducts,
//   //           hasReachedEnd: products.length < pageSize,
//   //         ));
//   //       } else {
//   //         emit(NewInLoaded(
//   //           products: products,
//   //           hasReachedEnd: products.length < pageSize,
//   //         ));
//   //       }
//   //     } else {
//   //       emit(NewInError("Failed with status: ${response.statusCode}"));
//   //     }
//   //   } on SocketException {
//   //     emit(NewInError("No internet connection"));
//   //   } catch (e) {
//   //     emit(NewInError("Error: $e"));
//   //   }
//   // }
//
//
// //july
//   Future<void> _onFetchNewIn(
//       FetchNewIn event, Emitter<NewInState> emit) async {
//     emit(NewInLoading());
//
//     final uri = Uri.parse(ApiConstants.url);
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       // Static subcategory
//       final subcategory = 'new in';
//
//       final Map<String, dynamic> body = {
//         "queryParams": {
//           // "query": 'categories-store-1_name:("$subcategory")',
//           "query": "categories-store-1_id:(1372)",
//           "params": {
//             "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time",
//             "rows": "40000",
//             // "sort": "prod_en_id desc"
//             "sort":"cat_position_1_1372 desc"
//           }
//         }
//       };
//
//       final response = await ioClient.post(
//         uri,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//
//       );
//       // ✅ Print full raw response
//       print("Raw Response Body: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//         final secondItem = decoded[1];
//         final docs = secondItem['docs'];
//
//
//
//         if (docs is List) {
//           final products = docs.map((doc) => Product.fromJson(doc)).toList();
//           print ("Response>>New $products");
//           emit(NewInLoaded(products: products));
//         } else {
//           emit(NewInError("Invalid docs format"));
//         }
//       } else {
//         emit(NewInError("Failed with status: ${response.statusCode}"));
//       }
//     } on SocketException {
//       emit(NewInError("No internet connection"));
//     } catch (e) {
//       emit(NewInError("Error: $e"));
//     }
//   }
//
//
//
//   // Future<void> _onFetchNewIn(
//   //     FetchNewIn event, Emitter<NewInState> emit) async {
//   //   emit(NewInLoading());
//   //
//   //   final uri = Uri.parse(ApiConstants.url);
//   //
//   //   try {
//   //     HttpClient httpClient = HttpClient();
//   //     httpClient.badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //
//   //     // Static subcategory
//   //     final subcategory = 'new in';
//   //
//   //     final Map<String, dynamic> body = {
//   //       "queryParams": {
//   //         "query": 'categories-store-1_name:("$subcategory")',
//   //         "params": {
//   //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name",
//   //           "rows": "40000",
//   //           "sort": "prod_en_id desc"
//   //         }
//   //       }
//   //     };
//   //
//   //     final response = await ioClient.post(
//   //       uri,
//   //       headers: {"Content-Type": "application/json"},
//   //       body: jsonEncode(body),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       final decoded = jsonDecode(response.body);
//   //       final secondItem = decoded[1];
//   //       final docs = secondItem['docs'];
//   //
//   //       if (docs is List) {
//   //         final products = docs.map((doc) => Product.fromJson(doc)).toList();
//   //         emit(NewInLoaded(products: products));
//   //       } else {
//   //         emit(NewInError("Invalid docs format"));
//   //       }
//   //     } else {
//   //       emit(NewInError("Failed with status: ${response.statusCode}"));
//   //     }
//   //   }
//   //   catch (e) {
//   //     emit(NewInError("Error: $e"));
//   //   }
//   // }
//
//
//
// // Future<void> _onFetchNewIn(
//   //     FetchNewIn event, Emitter<NewInState> emit) async {
//   //   emit(NewInLoading());
//   //
//   //   final url = Uri.parse(ApiConstants.newIn);
//   //
//   //   try {
//   //     HttpClient httpClient = HttpClient();
//   //     httpClient.badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //
//   //     final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
//   //
//   //     if (response.statusCode == 200) {
//   //       final List<dynamic> responseList = jsonDecode(response.body);
//   //       final Map<String, dynamic> productData = responseList[1];
//   //       final List<dynamic> docs = productData['docs'];
//   //
//   //       final List<Product> products = docs.map((json) => Product.fromJson(json)).toList();
//   //
//   //       emit(NewInLoaded(products: products));
//   //     } else {
//   //       emit(NewInError("Failed to load products"));
//   //     }
//   //   } catch (e) {
//   //     emit(NewInError("Error: $e"));
//   //   }
//   // }
//
// }