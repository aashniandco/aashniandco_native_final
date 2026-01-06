import 'dart:convert';
import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

// Make sure to import your NEW Product model and ApiConstants
import '../../../constants/api_constants.dart';
// This should be the path to your new Product model file
import '../../newin/model/new_in_model.dart';

import 'filtered_products_state.dart';

part 'filtered_products_event.dart';

// In filtered_products_bloc.dart


// Assume you have state and model files:
// part 'filtered_products_state.dart';
// import 'package:your_app/product_model.dart';
// import 'package:your_app/api_constants.dart';

class FilteredProductsBloc extends Bloc<FilteredProductsEvent, FilteredProductsState> {
  // Define your page size as a constant for easy changes.
  static const int _pageSize = 10;

  FilteredProductsBloc() : super(FilteredProductsLoading()) {
    on<FetchFilteredProducts>(_onFetchFilteredProducts,transformer: droppable(),);

    // ✅ ADD THIS EVENT HANDLER
    on<ReportError>((event, emit) {
      emit(FilteredProductsError(event.errorMessage));
    });
  }

  /// Helper to convert our UI sort names into the API's required sort string.
  // String _getSolrSortString(String sortOrder) {
  //   switch (sortOrder) {
  //     case "High to Low":
  //       return "actual_price_1 desc";
  //     case "Low to High":
  //       return "actual_price_1 asc";
  //     case "Latest":
  //     default:
  //     // This default sort string is based on your logs.
  //     // It seems to sort by category position first, then by product ID.
  //     // For a general filter screen, sorting by just prod_en_id might be safer.
  //     // We will use the simpler one for robustness.
  //       return "prod_en_id desc";
  //   }
  // }

  // --- MODIFIED: This function now requires the list of filters ---

  String _getSolrSortString(String sortOrderKey, List<Map<String, dynamic>> selectedFilters) {
    final categoryFilters = selectedFilters.where((f) => f['type'] == 'categories').toList();

    // The logic for positional sort on "Latest" is great! Let's keep it.
    if (sortOrderKey == "Latest" && categoryFilters.length == 1) {
      final categoryId = categoryFilters.first['id'];
      return 'cat_position_1_${categoryId} desc, prod_en_id desc';

    }

    // --- THIS IS THE FIX ---
    // Change the cases to match the values sent by the DropdownButton.
    // switch (sortOrderKey) {
    //   case "price_desc": // <-- FIX
    //     return "actual_price_1 desc";
    //   case "price_asc":  // <-- FIX
    //     return "actual_price_1 asc";
    //   case "Latest":
    //   default:
    //     return "prod_en_id desc";
    // }
    switch (sortOrderKey) {
      case "High to Low":  // <-- CORRECTED
        return "actual_price_1 desc";
      case "Low to High":  // <-- CORRECTED
        return "actual_price_1 asc";
      case "Latest":
      default:
        return "prod_en_id desc";
    }
  }

  //22/8/2025
  // String _getSolrSortString(String sortOrder, List<Map<String, dynamic>> selectedFilters) {
  //   // --- NEW LOGIC STARTS HERE ---
  //
  //   // 1. Identify all selected category filters.
  //   final categoryFilters = selectedFilters.where((f) => f['type'] == 'categories').toList();
  //
  //   // 2. Check if we can use a positional sort.
  //   // We can only do this if the user wants the default sort AND exactly one category is selected.
  //   if (sortOrder == "Latest" && categoryFilters.length == 1) {
  //     final categoryId = categoryFilters.first['id'];
  //     // This is the desired positional sort!
  //     return 'cat_position_1_${categoryId} desc, prod_en_id desc';
  //   }
  //
  //   // --- FALLBACK LOGIC (for all other cases) ---
  //   switch (sortOrder) {
  //     case "High to Low":
  //       return "actual_price_1 desc";
  //     case "Low to High":
  //       return "actual_price_1 asc";
  //     case "Latest":
  //     default:
  //     // This is the fallback for multi-category selections or when user explicitly picks "Latest".
  //       return "prod_en_id desc";
  //   }
  // }

  Future<void> _onFetchFilteredProducts(
      FetchFilteredProducts event, Emitter<FilteredProductsState> emit) async {

    final currentState = state;

    // Pagination Check
    if (event.page != 0 && currentState is FilteredProductsLoaded && currentState.hasReachedEnd) {
      return;
    }

    if (event.page == 0) {
      emit(FilteredProductsLoading());
    }

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      // ---------------------------------------------------------
      // 1. BUILD THE FILTER QUERY LOGIC
      // ---------------------------------------------------------
      Map<String, List<String>> filtersByType = {};
      for (var filter in event.selectedFilters) {
        String type = filter['type'];
        String id = filter['id'];
        if (!filtersByType.containsKey(type)) {
          filtersByType[type] = [];
        }
        filtersByType[type]!.add(id);
      }

      List<String> queryFilters = [];

      filtersByType.forEach((type, ids) {
        String solrField;

        if (type == 'designer_name') {
          // If the ID is the name itself (e.g. "11 Tareng"), use quote syntax
          // Filter out any null or "null" strings to prevent API errors
          final validNames = ids.where((id) => id != 'null' && id.isNotEmpty).toList();
          if (validNames.isNotEmpty) {
            // Creates: designer_name:("11 Tareng" OR "Other Name")
            final joinedNames = validNames.map((n) => '"$n"').join(' OR ');
            queryFilters.add('designer_name:($joinedNames)');
          }
          return; // Skip the rest of the loop
        }


        // --- Price Filter (User Selected) ---
        if (type == 'price') {
          List<String> ranges = [];
          for (var id in ids) {
            List<String> parts = id.split('-');
            if (parts.length == 2) {
              ranges.add('[${parts[0]} TO ${parts[1]}]');
            }
          }
          if (ranges.isNotEmpty) {
            // Use actual_price_1 for accuracy
            queryFilters.add('actual_price_1:(${ranges.join(' OR ')})');
          }
          return;
        }

        // --- Standard Fields ---
        if (type == 'designers') solrField = 'designer_id';
        else if (type == 'categories') solrField = 'categories-store-1_id';
        else if (type == 'colors') solrField = 'color_id';
        else if (type == 'themes') solrField = 'theme_id';
        else if (type == 'sizes') solrField = 'size_id';
        else if (type == 'child_delivery_time') solrField = 'child_delivery_time';
        else if (type == 'a_co_edit') solrField = 'a_co_edit_id';
        else if (type == 'occasions') solrField = 'occasion_id';
        else if (type == 'genders') solrField = 'gender_id';
        else solrField = '${type.replaceAll('_', '')}_id';

        queryFilters.add('$solrField:(${ids.join(' OR ')})');
      });

      // Join filters with AND (Strict filtering)
      String userFiltersString = queryFilters.join(' AND ');

      // --- Permanent Price Safety Check ---
      // Ensures we don't get bad data with 0 price.
      // Combined logic: (User Filters) AND Price Check
      String finalFilterQuery;
      if (userFiltersString.isEmpty) {
        finalFilterQuery = "actual_price_1:[2 TO *]";
      } else {
        finalFilterQuery = "($userFiltersString) AND actual_price_1:[2 TO *]";
      }

      // ---------------------------------------------------------
      // 2. CONSTRUCT API PARAMS (LocalParams Syntax)
      // ---------------------------------------------------------
      const String flParameter =
          "designer_name,actual_price_1,enquire_1,short_desc,prod_en_id,prod_small_img,"
          "color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time";

      // Sort Logic
      String sortParameter = _getSolrSortString(event.sortOrder, event.selectedFilters);
      if(sortParameter.isEmpty || sortParameter.contains("Default")) {
        // Fallback to Category Position if no specific sort is chosen
        // Note: Ensure the ID here matches your category filter (e.g., 6024 or 6023)
        sortParameter = "cat_position_1_6024 desc, prod_en_id desc";
      }

      final String rows = _pageSize.toString();
      final String start = (event.page * _pageSize).toString();

      // The Production API expects this specific syntax: {!sort=...}Query
      final String fullSolrQuery =
          "{!sort='$sortParameter' fl='$flParameter' rows='$rows' start='$start'}$finalFilterQuery";

      final body = {
        "queryParams": {"query": fullSolrQuery}
      };

      final uri = Uri.parse(ApiConstants.url);

      print("🚀 MAKING PROD API REQUEST:>> $fullSolrQuery");

      // ---------------------------------------------------------
      // 3. EXECUTE POST REQUEST
      // ---------------------------------------------------------
      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      // ---------------------------------------------------------
      // 4. PROCESS RESPONSE (API WRAPPER FORMAT)
      // ---------------------------------------------------------
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // API Wrapper Format: List of Maps.
        // Index 0: Header/Params
        // Index 1 (usually): Data with "docs" and "numFound"

        // Find the block that contains 'docs'
        final dataMap = (decoded is List)
            ? decoded.firstWhere((e) => e is Map && e.containsKey('docs'), orElse: () => null)
            : null;

        // Find the block that contains 'numFound' (might be same as dataMap or header)
        int? numFound;
        if (decoded is List) {
          final headerMap = decoded.firstWhere((e) => e is Map && e.containsKey('numFound'), orElse: () => null);
          if (headerMap != null) numFound = headerMap['numFound'];
        }

        print("✅ PROD API numFound: $numFound");

        if (dataMap != null) {
          final docs = dataMap['docs'] as List? ?? [];
          final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
          final hasReachedEnd = newProducts.length < _pageSize;

          final previousProducts =
          (currentState is FilteredProductsLoaded && event.page != 0)
              ? currentState.products
              : <Product>[];

          final allProducts = previousProducts + newProducts;

          emit(FilteredProductsLoaded(
            products: allProducts,
            hasReachedEnd: hasReachedEnd,
            currentSort: event.sortOrder,
            numFound: numFound ?? 0,
          ));
        } else {
          // No docs found
          emit(FilteredProductsLoaded(
            products: [],
            hasReachedEnd: true,
            currentSort: event.sortOrder,
          ));
        }
      } else {
        emit(FilteredProductsError("Failed with status: ${response.statusCode}"));
      }
    } catch (e) {
      emit(FilteredProductsError("An error occurred: $e"));
    }
  }
  // 33
  // Future<void> _onFetchFilteredProducts(
  //     FetchFilteredProducts event, Emitter<FilteredProductsState> emit) async {
  //   final currentState = state;
  //   if (currentState is FilteredProductsLoaded && currentState.hasReachedEnd) return;
  //
  //   if (event.page == 0) {
  //     emit(FilteredProductsLoading());
  //   }
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     // --- Filter Query Building Logic ---
  //     Map<String, List<String>> filtersByType = {};
  //     for (var filter in event.selectedFilters) {
  //       String type = filter['type'];
  //       String id = filter['id'];
  //       if (!filtersByType.containsKey(type)) {
  //         filtersByType[type] = [];
  //       }
  //       filtersByType[type]!.add(id);
  //     }
  //
  //     List<String> queryParts = [];
  //     bool hasPriceFilter = false;
  //
  //     filtersByType.forEach((type, ids) {
  //       String solrField;
  //
  //       // --- Price Range Filter ---
  //       if (type == 'price') {
  //         hasPriceFilter = true;
  //
  //         List<String> ranges = [];
  //         for (var id in ids) {
  //           List<String> parts = id.split('-');
  //           if (parts.length == 2) {
  //             ranges.add('[${parts[0]} TO ${parts[1]}]');
  //           }
  //         }
  //
  //         if (ranges.isNotEmpty) {
  //           queryParts.add('actual_price_1:(${ranges.join(' OR ')})');
  //         }
  //         return;
  //       }
  //
  //       // --- Standard Filters ---
  //       if (type == 'designers') solrField = 'designer_id';
  //       else if (type == 'categories') solrField = 'categories-store-1_id';
  //       else if (type == 'colors') solrField = 'color_id';
  //       else if (type == 'themes') solrField = 'theme_id';
  //       else if (type == 'sizes') solrField = 'size_id';
  //       else if (type == 'child_delivery_time') solrField = 'child_delivery_time';
  //       else if (type == 'a_co_edit') solrField = 'a_co_edit_id';
  //       else if (type == 'occasions') solrField = 'occasion_id';
  //       else solrField = '${type.replaceAll('_', '')}_id';
  //
  //       queryParts.add('$solrField:(${ids.join(' OR ')})');
  //     });
  //
  //     // --- Default Price condition ---
  //     if (!hasPriceFilter) {
  //       queryParts.add('actual_price_1:[2 TO *]');
  //     }
  //
  //     String filterQuery = queryParts.join(' AND ');
  //     if (filterQuery.isEmpty) filterQuery = '*:*';
  //
  //     // --- API Params ---
  //     const String flParameter =
  //         "designer_name,actual_price_1,enquire_1,short_desc,prod_en_id,prod_small_img,"
  //         "color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time";
  //
  //     final String sortParameter =
  //     _getSolrSortString(event.sortOrder, event.selectedFilters);
  //
  //     final String fullSolrQuery =
  //         "{!sort='$sortParameter' fl='$flParameter' rows='$_pageSize' start='${event.page * _pageSize}'}$filterQuery";
  //
  //     final body = {
  //       "queryParams": {"query": fullSolrQuery}
  //     };
  //
  //     final uri = Uri.parse(ApiConstants.url);
  //
  //     // --- Debug Print ---
  //     print("Querying: $fullSolrQuery");
  //
  //     final response = await ioClient.post(
  //       uri,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //
  //       // -------------------------------
  //       // ✅ PRINT RAW SOLR RESPONSE
  //       // -------------------------------
  //       print("SOLR RAW RESPONSE: $decoded");
  //
  //       // -------------------------------
  //       // ✅ EXTRACT numFound
  //       // -------------------------------
  //       int? numFound;
  //       try {
  //         final block = decoded.firstWhere(
  //               (e) => e is Map && e.containsKey('numFound'),
  //           orElse: () => null,
  //         );
  //
  //         if (block != null) {
  //           numFound = block['numFound'];
  //           print("SOLR numFound: $numFound");
  //         }
  //       } catch (e) {
  //         print("numFound parsing failed: $e");
  //       }
  //
  //       final dataMap = decoded.firstWhere(
  //             (element) => element is Map && element.containsKey('docs'),
  //         orElse: () => null,
  //       ) as Map<String, dynamic>?;
  //
  //       if (dataMap != null) {
  //         final docs = dataMap['docs'] as List? ?? [];
  //         final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
  //         final hasReachedEnd = newProducts.length < _pageSize;
  //
  //         final previousProducts =
  //         currentState is FilteredProductsLoaded ? currentState.products : <Product>[];
  //         final allProducts =
  //         (event.page == 0) ? newProducts : previousProducts + newProducts;
  //
  //         emit(FilteredProductsLoaded(
  //           products: allProducts,
  //           hasReachedEnd: hasReachedEnd,
  //           currentSort: event.sortOrder,
  //           numFound: numFound ?? 0,  // ⬅ (optional) add in state if needed
  //         ));
  //       } else {
  //         emit(FilteredProductsLoaded(
  //           products: [],
  //           hasReachedEnd: true,
  //           currentSort: event.sortOrder,
  //         ));
  //       }
  //     } else {
  //       emit(FilteredProductsError("Failed with status: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(FilteredProductsError("An error occurred: $e"));
  //   }
  // }


// 11/12/2025
  // Future<void> _onFetchFilteredProducts(
  //     FetchFilteredProducts event, Emitter<FilteredProductsState> emit) async {
  //   final currentState = state;
  //   if (currentState is FilteredProductsLoaded && currentState.hasReachedEnd) return;
  //
  //   if (event.page == 0) {
  //     emit(FilteredProductsLoading());
  //   }
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     // --- Filter Query Building Logic ---
  //     Map<String, List<String>> filtersByType = {};
  //     for (var filter in event.selectedFilters) {
  //       String type = filter['type'];
  //       String id = filter['id'];
  //       if (!filtersByType.containsKey(type)) { filtersByType[type] = []; }
  //       filtersByType[type]!.add(id);
  //     }
  //
  //     List<String> queryParts = [];
  //     bool hasPriceFilter = false; // 1. Flag to check if user selected price
  //
  //     filtersByType.forEach((type, ids) {
  //       String solrField;
  //
  //       // --- 2. Handle Price Logic Specifically ---
  //       if (type == 'price') {
  //         hasPriceFilter = true;
  //         // The ID from GenericFilterScreen comes as "1000-5000"
  //         // We need to convert it to Solr syntax: actual_price_1:[1000 TO 5000]
  //         List<String> ranges = [];
  //         for (var id in ids) {
  //           List<String> parts = id.split('-');
  //           if (parts.length == 2) {
  //             ranges.add('[${parts[0]} TO ${parts[1]}]');
  //           }
  //         }
  //         if (ranges.isNotEmpty) {
  //           // Add to query parts: actual_price_1:([100 TO 500] OR [1000 TO 2000])
  //           queryParts.add('actual_price_1:(${ranges.join(' OR ')})');
  //         }
  //         return; // Skip the rest of the loop for this iteration
  //       }
  //
  //       // --- Handle Standard Filters ---
  //       if (type == 'designers') { solrField = 'designer_id'; }
  //       else if (type == 'categories') { solrField = 'categories-store-1_id'; }
  //       else if (type == 'colors') { solrField = 'color_id'; }
  //       else if (type == 'themes') { solrField = 'theme_id'; }
  //       else if (type == 'sizes') { solrField = 'size_id'; }
  //       else if (type == 'child_delivery_time') { solrField = 'child_delivery_time'; }
  //       else if (type == 'a_co_edit') { solrField = 'a_co_edit_id'; }
  //       else if (type == 'occasions') { solrField = 'occasion_id'; }
  //       else { solrField = '${type.replaceAll('_', '')}_id'; }
  //
  //       queryParts.add('$solrField:(${ids.join(' OR ')})');
  //     });
  //
  //     // --- 3. Only add Default Price if User didn't filter by price ---
  //     if (!hasPriceFilter) {
  //       queryParts.add('actual_price_1:[2 TO *]');
  //     }
  //
  //     String filterQuery = queryParts.join(' AND ');
  //     if (filterQuery.isEmpty) { filterQuery = '*:*'; }
  //
  //     // --- API Request Body ---
  //     const String flParameter =
  //         "designer_name,actual_price_1,enquire_1,short_desc,prod_en_id,prod_small_img,"
  //         "color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time";
  //
  //     final String sortParameter = _getSolrSortString(event.sortOrder, event.selectedFilters);
  //
  //     final String fullSolrQuery =
  //         "{!sort='$sortParameter' fl='$flParameter' rows='$_pageSize' start='${event.page * _pageSize}'}$filterQuery";
  //
  //     final body = {
  //       "queryParams": { "query": fullSolrQuery }
  //     };
  //
  //     final uri = Uri.parse(ApiConstants.url);
  //
  //     // Log for debugging
  //     print("Querying: $fullSolrQuery");
  //
  //     final response = await ioClient.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       final dataMap = decoded.firstWhere(
  //             (element) => element is Map && element.containsKey('docs'),
  //         orElse: () => null,
  //       ) as Map<String, dynamic>?;
  //
  //       if (dataMap != null) {
  //         final docs = dataMap['docs'] as List? ?? [];
  //         final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
  //         final hasReachedEnd = newProducts.length < _pageSize;
  //
  //         final previousProducts = currentState is FilteredProductsLoaded ? currentState.products : <Product>[];
  //         final allProducts = (event.page == 0) ? newProducts : previousProducts + newProducts;
  //
  //         emit(FilteredProductsLoaded(
  //           products: allProducts,
  //           hasReachedEnd: hasReachedEnd,
  //           currentSort: event.sortOrder,
  //         ));
  //       } else {
  //         emit(FilteredProductsLoaded(products: [], hasReachedEnd: true, currentSort: event.sortOrder));
  //       }
  //     } else {
  //       emit(FilteredProductsError("Failed with status: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(FilteredProductsError("An error occurred: $e"));
  //   }
  // }
  //10/12/2025
  // Future<void> _onFetchFilteredProducts(
  //     FetchFilteredProducts event, Emitter<FilteredProductsState> emit) async {
  //   final currentState = state;
  //   if (currentState is FilteredProductsLoaded && currentState.hasReachedEnd) return;
  //
  //   if (event.page == 0) {
  //     emit(FilteredProductsLoading());
  //   }
  //
  //   try {
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     // --- Filter Query Building Logic (This part is correct and unchanged) ---
  //     Map<String, List<String>> filtersByType = {};
  //     for (var filter in event.selectedFilters) {
  //       String type = filter['type'];
  //       String id = filter['id'];
  //       if (!filtersByType.containsKey(type)) { filtersByType[type] = []; }
  //       filtersByType[type]!.add(id);
  //     }
  //     List<String> queryParts = [];
  //     filtersByType.forEach((type, ids) {
  //       String solrField;
  //       // if (type == 'categories') { solrField = 'categories-store-1_id'; }
  //       // else if (type == 'colors') { solrField = 'color_id'; }
  //       // else if (type == 'themes') { solrField = 'theme_id'; }
  //       // else if (type == 'sizes') { solrField = 'size_id'; }
  //       // else if (type == 'child_delivery_time') { solrField = 'child_delivery_time'; }
  //       // else if (type == 'a_co_edit') { solrField = 'a_co_edit_id'; }
  //       // else if (type == 'occasions') { solrField = 'occasion_id'; }
  //       if (type == 'designers') { solrField = 'designer_id'; }
  //       else if (type == 'categories') { solrField = 'categories-store-1_id'; }
  //       else if (type == 'colors') { solrField = 'color_id'; }
  //       else if (type == 'themes') { solrField = 'theme_id'; }
  //       else if (type == 'sizes') { solrField = 'size_id'; }
  //       else if (type == 'child_delivery_time') { solrField = 'child_delivery_time'; }
  //       else if (type == 'a_co_edit') { solrField = 'a_co_edit_id'; }
  //       else if (type == 'occasions') { solrField = 'occasion_id'; }
  //       else { solrField = '${type.replaceAll('_', '')}_id'; }
  //       queryParts.add('$solrField:(${ids.join(' OR ')})');
  //     });
  //     queryParts.add('actual_price_1:[2 TO *]');
  //     String filterQuery = queryParts.join(' AND ');
  //     if (filterQuery.isEmpty) { filterQuery = '*:*'; }
  //
  //     // --- NEW: API Request Body with Pagination and Server-Side Sorting ---
  //     const String flParameter =
  //         "designer_name,actual_price_1,enquire_1,short_desc,prod_en_id,prod_small_img,"
  //         "color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time";
  //
  //
  //     // --- THIS IS THE KEY CHANGE ---
  //     // Pass the event's selectedFilters to the helper function.
  //     final String sortParameter = _getSolrSortString(event.sortOrder, event.selectedFilters);
  //     // final String sortParameter = _getSolrSortString(event.sortOrder);
  //
  //     final String fullSolrQuery =
  //         "{!sort='$sortParameter' fl='$flParameter' rows='$_pageSize' start='${event.page * _pageSize}'}$filterQuery";
  //
  //     final body = {
  //       "queryParams": { "query": fullSolrQuery }
  //     };
  //
  //     final uri = Uri.parse(ApiConstants.url);
  //
  //     // --- DETAILED LOGGING ---
  //     print("🚀 MAKING API REQUEST");
  //     print("   URL:>> $uri");
  //     print("   Sort Option: ${event.sortOrder}");
  //     print("   Is Reset: ${event.page == 0}");
  //     print("   Request Body:>>> ${jsonEncode(body)}");
  //     print("----------------------------------------------------");
  //
  //     final response = await ioClient.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
  //
  //     print("\n----------------------------------------------------");
  //     print("✅ API RESPONSE RECEIVED");
  //     print("   Status Code: ${response.statusCode}");
  //     // Truncate long response bodies for cleaner logs
  //     final responseBody = response.body;
  //     print("   Response Body: ${responseBody.length > 500 ? responseBody.substring(0, 500) + '...' : responseBody}");
  //     print("----------------------------------------------------");
  //
  //     if (response.statusCode == 200) {
  //       final decoded = jsonDecode(response.body);
  //       final dataMap = decoded.firstWhere(
  //             (element) => element is Map && element.containsKey('docs'),
  //         orElse: () => null,
  //       ) as Map<String, dynamic>?;
  //
  //       if (dataMap != null) {
  //         final docs = dataMap['docs'] as List? ?? [];
  //         final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
  //         final hasReachedEnd = newProducts.length < _pageSize;
  //
  //         final previousProducts = currentState is FilteredProductsLoaded ? currentState.products : <Product>[];
  //         final allProducts = (event.page == 0) ? newProducts : previousProducts + newProducts;
  //
  //         emit(FilteredProductsLoaded(
  //           products: allProducts,
  //           hasReachedEnd: hasReachedEnd,
  //           currentSort: event.sortOrder,
  //         ));
  //       } else {
  //         emit(FilteredProductsLoaded(products: [], hasReachedEnd: true, currentSort: event.sortOrder));
  //       }
  //     } else {
  //       emit(FilteredProductsError("Failed with status: ${response.statusCode}"));
  //     }
  //   } catch (e) {
  //     emit(FilteredProductsError("An error occurred: $e"));
  //   }
  // }
}


// class FilteredProductsBloc extends Bloc<FilteredProductsEvent, FilteredProductsState> {
//   String _currentSort = "Latest";
//
//   FilteredProductsBloc() : super(FilteredProductsLoading()) {
//     on<FetchFilteredProducts>(_onFetchFilteredProducts);
//     on<SortProducts>(_onSortProducts);
//   }
//
//   List<Product> _sortList(List<Product> products, String sortOrder) {
//     List<Product> productsToSort = List<Product>.from(products);
//     if (sortOrder == "High to Low") {
//       productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//     } else if (sortOrder == "Low to High") {
//       productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//     } else { // "Latest"
//       productsToSort.sort((a, b) {
//         final idA = int.tryParse(a.prod_en_id) ?? 0;
//         final idB = int.tryParse(b.prod_en_id) ?? 0;
//         return idB.compareTo(idA);
//       });
//     }
//     return productsToSort;
//   }
//
//   void _onSortProducts(SortProducts event, Emitter<FilteredProductsState> emit) {
//     if (state is FilteredProductsLoaded) {
//       final currentState = state as FilteredProductsLoaded;
//       _currentSort = event.sortOrder;
//       final sortedProducts = _sortList(currentState.products, _currentSort);
//       emit(FilteredProductsLoaded(
//         products: sortedProducts,
//         hasReachedEnd: currentState.hasReachedEnd,
//         currentSort: _currentSort,
//       ));
//     }
//   }
//
//   // In filtered_products_bloc.dart
//
//   Future<void> _onFetchFilteredProducts(
//       FetchFilteredProducts event, Emitter<FilteredProductsState> emit) async {
//     final currentState = state;
//     if (currentState is FilteredProductsLoaded && currentState.hasReachedEnd) return;
//     if (event.page == 0) {
//       emit(FilteredProductsLoading());
//     }
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       // ... (Query building logic is correct and remains unchanged) ...
//       Map<String, List<String>> filtersByType = {};
//       for (var filter in event.selectedFilters) {
//         String type = filter['type'];
//         String id = filter['id'];
//         if (!filtersByType.containsKey(type)) {
//           filtersByType[type] = [];
//         }
//         filtersByType[type]!.add(id);
//       }
//       List<String> queryParts = [];
//       filtersByType.forEach((type, ids) {
//         String solrField; // Declare the variable
//
//         // Your existing special case - THIS IS GOOD
//         if (type == 'categories') {
//           solrField = 'categories-store-1_id';
//         }
//         // --- ADD THIS NEW SPECIAL CASE ---
//         else if (type == 'colors') {
//           solrField = 'color_id'; // Use the correct singular form
//         }
//         else if (type == 'themes') {
//           solrField = 'theme_id'; // Use the correct singular form
//         }
//         else if (type == 'sizes') {
//           solrField = 'size_id'; // Use the correct singular form
//         }
//         else if (type == 'child_delivery_time') {
//           solrField = 'child_delivery_time'; // Use the correct singular form
//         }
//         else if (type == 'a_co_edit') {
//           solrField = 'a_co_edit_id'; // Use the correct singular form
//         }
//         else if (type == 'occasions') {
//           solrField = 'occasion_id'; // Use the correct singular form
//         }
//         // The default for all other filters (like 'size' -> 'size_id')
//         else {
//           solrField = '${type.replaceAll('_', '')}_id';
//         }
//
//         queryParts.add('$solrField:(${ids.join(' OR ')})');
//       });
// // --- END OF FIX ---
//
//       String solrQuery = queryParts.join(' AND ');
//       if (solrQuery.isEmpty) {
//         solrQuery = '*:*';
//       }
//
//       const String flParameter =
//           "designer_name,actual_price_1,short_desc,prod_en_id,prod_small_img,"
//           "color_name,prod_name,occasion_name,size_name,prod_sku,prod_desc,child_delivery_time";
//
//       final body = {
//         "queryParams": {
//           "query": solrQuery,
//           "params": {
//             "fl": flParameter,
//             "rows": "200000",
//             "start": (event.page * 20).toString(),
//             "sort": "prod_en_id desc"
//           }
//         }
//       };
//
//       final uri = Uri.parse(ApiConstants.url);
//       final response = await ioClient.post(uri, headers: {"Content-Type": "application/json"}, body: jsonEncode(body));
//
//       // FOR DEBUGGING: Add this print statement to see what the server sends when it fails!
//       print("SERVER RESPONSE BODY: ${response.body}");
//
//       if (response.statusCode == 200) {
//         final decoded = jsonDecode(response.body);
//
//         // --- START OF THE NEW, ROBUST PARSING LOGIC ---
//
//         Map<String, dynamic>? dataMap;
//
//         // Check if the response is a list, as expected.
//         if (decoded is List) {
//           // Find the first element in the list that is a Map and contains the 'docs' key.
//           // This is much safer than assuming it's always at index 1.
//           dataMap = decoded
//               .firstWhere(
//                 (element) => element is Map && element.containsKey('docs'),
//             orElse: () => null, // If no such element is found, return null.
//           ) as Map<String, dynamic>?;
//         }
//
//         // Now, proceed only if we successfully found our data map.
//         if (dataMap != null) {
//           final docs = dataMap['docs'] as List? ?? [];
//           final newProducts = docs.map((doc) => Product.fromJson(doc)).toList();
//
//           // A better way to check if we've reached the end.
//           final hasReachedEnd = newProducts.length < 20;
//
//           List<Product> previousProducts = currentState is FilteredProductsLoaded ? currentState.products : [];
//           List<Product> allProducts = (event.page == 0) ? newProducts : previousProducts + newProducts;
//
//           final sortedList = _sortList(allProducts, _currentSort);
//
//           emit(FilteredProductsLoaded(
//             products: sortedList,
//             hasReachedEnd: hasReachedEnd,
//             currentSort: _currentSort,
//           ));
//         } else {
//           // This branch is now taken if NO element with a 'docs' key was found in the response.
//           // This could mean a valid "no results" response. We can treat it as an empty list.
//           if (event.page == 0) {
//             emit(FilteredProductsLoaded(products: [], hasReachedEnd: true, currentSort: _currentSort));
//           } else {
//             // If this was a subsequent page, just signal we've reached the end.
//             final loadedState = currentState as FilteredProductsLoaded;
//             emit(loadedState.copyWith(hasReachedEnd: true));
//           }
//         }
//         // --- END OF THE NEW LOGIC ---
//
//       } else {
//         emit(FilteredProductsError("Failed with status: ${response.statusCode}"));
//       }
//     } catch (e) {
//       // Also print the response body on error to help debug.
//       print("Error during parsing: $e");
//       emit(FilteredProductsError("An error occurred: $e"));
//     }
//   }
// }