import 'dart:convert';
import 'dart:io';
import 'package:aashniandco/features/product_details.dart';
import 'package:aashniandco/features/shoppingbag/model/countries.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../common/common_app_bar.dart';
import '../common/common_bottom_nav_bar.dart';
import 'auth/bloc/currency_bloc.dart';
import 'auth/bloc/currency_state.dart';
import 'auth/view/enquiry_form.dart';
import 'categories/bloc/filtered_products_bloc.dart';
import 'categories/repository/api_service.dart';
import 'newin/model/new_in_model.dart';
import 'newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
import 'newin/view/product_details_newin.dart';
import 'package:intl/intl.dart';

import 'package:flutter/rendering.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';

// Assuming you have these files and classes in your project:
// - blocs/currency/currency_bloc.dart (with states like CurrencyLoaded)
// - ui/screens/product_detail_screen.dart (ProductDetailNewInDetailScreen)
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'dart:convert';
import 'dart:io';


import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shimmer/shimmer.dart';

class DesignerDetailScreen extends StatefulWidget {
  final String designerName;
  final String? categoryName; // Make categoryName nullable

  const DesignerDetailScreen({
    Key? key,
    required this.designerName,
    this.categoryName, // Add to constructor
  }) : super(key: key);

  @override
  State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  int? _totalProducts;
  bool isLoading = true;
  List<Product> products = []; // Changed to List<Product>
  String selectedSort = "Latest";
  late Future<Map<String, dynamic>> _categoryMetadata;
  final ApiService _apiService = ApiService(); // Initialize ApiService

  final _scrollController = ScrollController();
  int _currentOffset = 0;
  final int _pageSize = 10;
  bool isFetchingMore = false;
  bool hasMoreData = true;

  bool _isNavBarVisible = true;
  List<Country> _apiCountries = [];

  // List to hold currently active filters, similar to FilteredProductsScreen
  List<Map<String, dynamic>> _currentActiveFilters = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
    // Initialize _currentActiveFilters with the designer filter
    _currentActiveFilters = [
      {'type': 'designer_name', 'value': widget.designerName, 'name': widget.designerName}
    ];
    fetchDesignerDetails();
    _scrollController.addListener(_onScroll);

    // Initialize _categoryMetadata. You might need a more sophisticated way
    // to get a relevant category for a designer, or use a default.
    // For now, let's use a placeholder or the provided categoryName.
    _fetchCategoryMetadata(widget.categoryName ?? 'all',isDesignerScreen: true); // 'all' as a fallback
  }

  void _fetchCategoryMetadata(String categoryName, {bool isDesignerScreen = false}) {
    _categoryMetadata = _apiService.fetchCategoryMetadataByName(categoryName, isDesignerScreen: isDesignerScreen);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // --- Navbar Visibility Logic ---
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) {
      // User is scrolling down
      if (_isNavBarVisible) {
        setState(() => _isNavBarVisible = false);
      }
    } else if (direction == ScrollDirection.forward) {
      // User is scrolling up
      if (!_isNavBarVisible) {
        setState(() => _isNavBarVisible = true);
      }
    }

    // --- Pagination Logic (Your existing code) ---
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200 &&
        !isFetchingMore &&
        hasMoreData) {
      fetchDesignerDetails(isPaginating: true);
    }
  }

  Future<void> _handleRefresh({List<Map<String, dynamic>>? newFilters}) async {
    setState(() {
      products.clear();
      _currentOffset = 0;
      hasMoreData = true;
      isLoading = true;
      _totalProducts = null;
      if (newFilters != null) {
        _currentActiveFilters = newFilters;
      }
    });
    await fetchDesignerDetails();
  }

  String _getSolrSortString() {
    switch (selectedSort) {
      case "High to Low":
        return "actual_price_1 desc";
      case "Low to High":
        return "actual_price_1 asc";
      default:
        return "prod_en_id desc";
    }
  }

  // --- 1. REMOVE FILTER LOGIC ---
  void _removeFilter(Map<String, dynamic> filterToRemove) {
    setState(() {
      _currentActiveFilters.remove(filterToRemove);

      // Reset pagination
      _currentOffset = 0;
      hasMoreData = true;
      isLoading = true;
      products.clear();
      _totalProducts = null;
    });

    // Fetch data again with remaining filters
    fetchDesignerDetails();
  }

  // --- 2. BUILD CHIPS WIDGET ---
  Widget _buildActiveFilterChips() {
    // We want to show chips for everything EXCEPT the base 'designer_name'
    // because that is the context of this screen.
    final visibleFilters = _currentActiveFilters
        .where((f) => f['type'] != 'designer_name')
        .toList();

    if (visibleFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4), // Aligns with grid
        scrollDirection: Axis.horizontal,
        itemCount: visibleFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = visibleFilters[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  filter['name'] ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _removeFilter(filter), // Remove specific filter
                  child: const Icon(Icons.close, size: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterButton() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoryMetadata,
      builder: (context, snapshot) {
        final bool canFilter = snapshot.connectionState == ConnectionState.done &&
            !snapshot.hasError &&
            snapshot.hasData;

        return TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: canFilter
              ? () async {
            final String parentCategoryId = snapshot.data!['pare_cat_id']?.toString() ?? '';

            if (parentCategoryId.isNotEmpty) {
              final result = await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (bottomSheetContext) {
                  return BlocProvider<FilteredProductsBloc>(
                    create: (context) => FilteredProductsBloc(),
                    child: FilterBottomSheetCategories(
                      categoryId: parentCategoryId,
                      initialFilters: _currentActiveFilters,
                      isDesignerScreen: true,

                      // ✅ FIX: Set this to TRUE.
                      // This forces the sheet to POP with data instead of PUSHING a new screen.
                      isFromFilteredScreen: true,
                    ),
                  );
                },
              );

              // ✅ Receive Data Back
              if (result != null) {
                List<Map<String, dynamic>> newFilters = [];

                // Handle response format (might be Map or List depending on your BottomSheet implementation)
                if (result is Map && result.containsKey('filters')) {
                  newFilters = List<Map<String, dynamic>>.from(result['filters']);
                } else if (result is List) {
                  newFilters = List<Map<String, dynamic>>.from(result);
                }

                // ✅ ESSENTIAL: Re-add the Designer Name if it was lost
                // The BottomSheet might clear filters it doesn't know about.
                // We must ensure "11 Tareng" is still in the query.
                bool hasDesigner = newFilters.any((f) => f['type'] == 'designer_name');
                if (!hasDesigner) {
                  newFilters.add({
                    'type': 'designer_name',
                    'id': widget.designerName, // ID is used for comparison
                    'value': widget.designerName,
                    'name': widget.designerName
                  });
                }

                // Trigger local refresh using _buildRequestBody logic
                _handleRefresh(newFilters: newFilters);
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filter not available for this category.")),
              );
            }
          }
              : null,
          icon: const Icon(Icons.filter_list),
          label: Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              color: canFilter ? Colors.black : Colors.grey,
            ),
          ),
        );
      },
    );
  }
//14/12/2025
//   Widget _buildFilterButton() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadata,
//       builder: (context, snapshot) {
//         // Robust check for filter availability
//         final bool canFilter = snapshot.connectionState == ConnectionState.done &&
//             !snapshot.hasError &&
//             snapshot.hasData;
//
//         return TextButton.icon(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//             padding: EdgeInsets.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           onPressed: canFilter
//               ? () async {
//             final String parentCategoryId = snapshot.data!['pare_cat_id']?.toString() ?? '';
//
//             if (parentCategoryId.isNotEmpty) {
//               // ✅ Wait for the result from the bottom sheet
//               final result = await showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (bottomSheetContext) {
//                   return BlocProvider<FilteredProductsBloc>(
//                     create: (context) => FilteredProductsBloc(),
//                     child: FilterBottomSheetCategories(
//                       categoryId: parentCategoryId,
//                       // Pass current filters so they show as "Selected" in the sheet
//                       initialFilters: _currentActiveFilters,
//                       isDesignerScreen: true,
//                       isFromFilteredScreen: false,
//                     ),
//                   );
//                 },
//               );
//
//               // ✅ Check if we got filters back and refresh
//               if (result != null && result is List) {
//                 print("Filters received: $result");
//                 // Cast to the correct map type
//                 List<Map<String, dynamic>> newFilters =
//                 List<Map<String, dynamic>>.from(result);
//
//                 // Ensure Designer Name stays in the filter list
//                 bool hasDesigner = newFilters.any((f) => f['type'] == 'designer_name');
//                 if (!hasDesigner) {
//                   newFilters.add({
//                     'type': 'designer_name',
//                     'value': widget.designerName,
//                     'name': widget.designerName
//                   });
//                 }
//
//                 _handleRefresh(newFilters: newFilters);
//               }
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Filter not available for this category.")),
//               );
//             }
//           }
//               : null,
//           icon: const Icon(Icons.filter_list),
//           label: Text(
//             'Filter',
//             style: TextStyle(
//               fontSize: 16,
//               color: canFilter ? Colors.black : Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }
  // --- Filter Button Widget ---
  // Widget _buildFilterButton() {
  //   return FutureBuilder<Map<String, dynamic>>(
  //     future: _categoryMetadata,
  //     builder: (context, snapshot) {
  //       // Determine if filtering is possible based on metadata or a reasonable default
  //       // For a designer page, you might want to enable filtering even if category metadata
  //       // isn't perfectly aligned, by always allowing a generic filter.
  //       // Or, more robustly, fetch metadata for a relevant parent category for the designer.
  //       final bool canFilter = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
  //
  //       return TextButton.icon(
  //         style: TextButton.styleFrom(
  //           foregroundColor: Colors.black,
  //           padding: EdgeInsets.zero,
  //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  //         ),
  //         onPressed: canFilter // Only enable if we have category data, or always enable with a generic filter
  //             ? () {
  //           // This is where you'd trigger the FilterBottomSheetCategories.
  //           // You'll need a categoryId to pass to it. For a designer page,
  //           // this might be a common parent category for the designer's products
  //           // or a specific category if the designer only works in one.
  //           final String parentCategoryId = snapshot.hasData
  //               ? snapshot.data!['pare_cat_id']?.toString() ?? ''
  //               : '';
  //
  //           if (parentCategoryId.isNotEmpty) {
  //             showModalBottomSheet(
  //               context: context,
  //               isScrollControlled: true,
  //               backgroundColor: Colors.transparent,
  //               builder: (bottomSheetContext) {
  //                 return BlocProvider<FilteredProductsBloc>(
  //                   create: (context) => FilteredProductsBloc(),
  //                   child: FilterBottomSheetCategories(
  //                     categoryId: parentCategoryId,
  //                     // You might want to pass initial filters here if you plan to persist them
  //                     // on the filter sheet, or apply them back to this screen's state.
  //                     // onApplyFilters: (newFilters) {
  //                     //   _handleRefresh(newFilters: newFilters);
  //                     // },
  //                   ),
  //                 );
  //               },
  //             );
  //           } else {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               const SnackBar(
  //                   content:
  //                   Text("Filter not available for this category.")),
  //             );
  //           }
  //         }
  //             : null, // Disable if cannot filter
  //         icon: const Icon(Icons.filter_list),
  //         label: Text(
  //           'Filter',
  //           style: TextStyle(
  //             fontSize: 16,
  //             color: canFilter ? Colors.black : Colors.grey,
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  // String _buildRequestBody() {
  //   const String fieldsToFetch =
  //       'designer_name,actual_price,prod_name,enquire_1,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
  //   final String sortString = _getSolrSortString();
  //
  //   // Construct the filter query based on _currentActiveFilters
  //   List<String> filterClauses = [];
  //
  //   // Always include the designer filter
  //   filterClauses.add('designer_name:"${widget.designerName}"');
  //   filterClauses.add('actual_price_1:[0.01 TO *]'); // Always filter for valid prices
  //
  //   // Add other active filters
  //   for (var filter in _currentActiveFilters) {
  //     if (filter['type'] == 'categories' && filter['id'] != null) {
  //       filterClauses.add('category_id:"${filter['id']}"');
  //     }
  //     // Add more filter types (e.g., price ranges, sizes) as needed
  //     // based on the structure of your filter objects.
  //     // Example:
  //     // if (filter['type'] == 'price_range') {
  //     //   filterClauses.add('actual_price_1:[${filter['min']} TO ${filter['max']}]');
  //     // }
  //   }
  //
  //   final String combinedFilter = filterClauses.join(' AND ');
  //
  //   final String solrQuery =
  //       "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$combinedFilter";
  //   final Map<String, dynamic> requestBody = {
  //     "queryParams": {"query": solrQuery}
  //   };
  //   return json.encode(requestBody);
  // }

  //31/12/2025
  // String _buildRequestBody() {
  //   const String fieldsToFetch =
  //       'designer_name,actual_price,prod_name,enquire_1,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
  //
  //   // 1. Get Sort String
  //   final String sortString = _getSolrSortString();
  //
  //
  //
  //   // 2. Group filters by type to handle "OR" logic (e.g., Red OR Blue)
  //   Map<String, List<String>> filtersByType = {};
  //
  //   for (var filter in _currentActiveFilters) {
  //     String type = filter['type'];
  //     // Skip designer_name here as we add it manually later
  //     if (type == 'designer_name') continue;
  //
  //     String? id = filter['id']?.toString();
  //     if (id != null) {
  //       if (!filtersByType.containsKey(type)) {
  //         filtersByType[type] = [];
  //       }
  //       filtersByType[type]!.add(id);
  //     }
  //   }
  //
  //   // 3. Build the Filter Clauses
  //   List<String> queryParts = [];
  //
  //   // A. Always filter by the current Designer
  //   queryParts.add('designer_name:"${widget.designerName}"');
  //
  //   // B. Always filter for valid prices
  //   queryParts.add('actual_price_1:[0.01 TO *]');
  //
  //   // C. Process other dynamic filters
  //   filtersByType.forEach((type, ids) {
  //     String solrField;
  //
  //     // ✅ MAP API TYPES TO SOLR FIELDS
  //     // if (type == 'categories') {
  //     //   solrField = 'categories-store-1_id'; // Important for Category filtering
  //     // }
  //
  //     if (type == 'patterns') {
  //       // For designer screens, 'Category' selections come from the 'patterns' key
  //       solrField = 'parent_cat_id';
  //     } else if (type == 'categories') {
  //       solrField = 'categories-store-1_id';
  //     }
  //     else if (type == 'colors') {
  //       solrField = 'color_id';
  //     } else if (type == 'sizes') {
  //       solrField = 'size_id';
  //     } else if (type == 'occasions') {
  //       solrField = 'occasion_id';
  //     } else if (type == 'themes') {
  //       solrField = 'theme_id';
  //     } else if (type == 'child_delivery_time') {
  //       solrField = 'child_delivery_time';
  //     } else {
  //       // Fallback: remove 's' (materials -> material_id) or append _id
  //       if (type.endsWith('s')) {
  //         solrField = '${type.substring(0, type.length - 1)}_id';
  //       } else {
  //         solrField = '${type}_id';
  //       }
  //     }
  //
  //     // Add grouped clause: color_id:(123 OR 456)
  //     queryParts.add('$solrField:(${ids.join(' OR ')})');
  //   });
  //
  //   // 4. Combine everything
  //   final String combinedFilter = queryParts.join(' AND ');
  //
  //   final String solrQuery =
  //       "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$combinedFilter";
  //
  //   final Map<String, dynamic> requestBody = {
  //     "queryParams": {"query": solrQuery}
  //   };
  //
  //   // Debug print to help you see what is being sent
  //   print("generated_solr_query: $solrQuery");
  //
  //   return json.encode(requestBody);
  // }

  String _buildRequestBody() {
    const String fieldsToFetch =
        'designer_name,actual_price,prod_name,enquire_1,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';

    final String sortString = _getSolrSortString();

    // 1. Group filters by type
    Map<String, List<String>> filtersByType = {};
    for (var filter in _currentActiveFilters) {
      String type = filter['type'];
      if (type == 'designer_name') continue;

      String? id = filter['id']?.toString();
      if (id != null) {
        filtersByType.putIfAbsent(type, () => []).add(id);
      }
    }

    // 2. Build the Filter Clauses
    List<String> queryParts = [];

    // A. Always filter by the current Designer
    queryParts.add('designer_name:"${widget.designerName}"');

    // B. Always filter for valid prices
    queryParts.add('actual_price_1:[0.01 TO *]');

    // C. Process dynamic filters with corrected field mappings
    filtersByType.forEach((type, ids) {
      String solrField;

      if (type == 'patterns' || type == 'categories') {
        // ✅ FIX: Use category_ids (most common for Lehenga ID 6092)
        // If category_ids fails in your Solr UI test, change this to 'category_id'
        solrField = 'category_ids';
      } else if (type == 'colors') {
        solrField = 'color_id';
      } else if (type == 'sizes') {
        solrField = 'size_id';
      } else if (type == 'occasions') {
        solrField = 'occasion_id';
      } else if (type == 'themes') {
        solrField = 'theme_id';
      } else if (type == 'child_delivery_time') {
        solrField = 'child_delivery_time';
      } else {
        solrField = type.endsWith('s')
            ? '${type.substring(0, type.length - 1)}_id'
            : '${type}_id';
      }

      // Join IDs with OR logic: field:(ID1 OR ID2)
      queryParts.add('$solrField:(${ids.join(' OR ')})');
    });

    final String combinedFilter = queryParts.join(' AND ');

    // 3. ADD FACETING FOR DESIGNER SPECIFIC FILTERS
    // This tells Solr: "Give me the counts of categories, colors, and sizes
    // ONLY for Aditi Gupta's products."
    final String facetParams =
        "&facet=true"
        "&facet.field=category_ids" // This will return counts for Lehengas, Sarees, etc.
        "&facet.field=color_id"
        "&facet.field=size_id"
        "&facet.mincount=1";

    // 4. Combine into final Solr Query
    // Note: LocalParams {!sort...} must come first, followed by the query and facets
    final String solrQuery =
        "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$combinedFilter$facetParams";

    final Map<String, dynamic> requestBody = {
      "queryParams": {"query": solrQuery}
    };

    print("generated_solr_query: $solrQuery");

    return json.encode(requestBody);
  }
  Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
    if ((_totalProducts != null && products.length >= _totalProducts!) ||
        isFetchingMore) {
      if (_totalProducts != null && products.length >= _totalProducts!) {
        if (hasMoreData) setState(() => hasMoreData = false);
      }
      return;
    }

    setState(() {
      if (isPaginating) {
        isFetchingMore = true;
      } else {
        isLoading = true;
      }
    });

    final String requestBody = _buildRequestBody();
    print("requestBody>>>$requestBody");
    final url = Uri.parse('https://aashniandco.com/rest/V1/solr/search');

    try {
      HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.length > 1 && data[1]['docs'] is List) {
          if (_totalProducts == null) {
            _totalProducts = data[1]['numFound'] as int?;
          }
          List<Product> newProducts = (data[1]['docs'] as List)
              .map((item) => Product.fromJson(item as Map<String, dynamic>))
              .toList();
          if (mounted) {
            setState(() {
              products.addAll(newProducts);
              _currentOffset += newProducts.length;
              if (_totalProducts != null &&
                  products.length >= _totalProducts!) {
                hasMoreData = false;
              }
              if (newProducts.length < _pageSize) {
                hasMoreData = false;
              }
            });
          }
        } else {
          if (mounted) setState(() => hasMoreData = false);
        }
      } else {
        throw Exception(
            'Failed to load designer details: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching designer details: $e');
      if (mounted) setState(() => hasMoreData = false);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
          isFetchingMore = false;
        });
      }
    }
  }

  /// 🟣 Shimmer Grid Placeholder
  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: 6,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.5,
      ),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }

  /// 🟣 Shimmer for pagination loader
  Widget _buildShimmerLoader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        // The back button is needed here, so we enable it.
        automaticallyImplyLeading: true,
        titleWidget: Text(widget.designerName),
      ),
      body: buildBody(),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        // Animate the height to show/hide the navbar
        height: _isNavBarVisible ? navBarHeight : 0,
        // Use a Wrap to prevent layout errors during animation
        child: Wrap(
          children: const [
            // Set a relevant index, or a non-interfering one like 3 (Wishlist)
            CommonBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  // Widget buildBody() {
  //   if (isLoading && products.isEmpty) {
  //     return _buildShimmerGrid();
  //   }
  //
  //   if (products.isEmpty && !isLoading) {
  //     return RefreshIndicator(
  //       onRefresh: _handleRefresh,
  //       child: SingleChildScrollView(
  //         physics: const AlwaysScrollableScrollPhysics(),
  //         child: Container(
  //           height: MediaQuery.of(context).size.height * 0.8,
  //           alignment: Alignment.center,
  //           child: const Text("No products found. Pull to refresh."),
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return RefreshIndicator(
  //     onRefresh: _handleRefresh,
  //     child: Padding(
  //       padding: const EdgeInsets.all(8.0),
  //       child: Column(
  //         children: [
  //           _buildSortHeader(),
  //           const SizedBox(height: 10),
  //           Expanded(
  //             child: GridView.builder(
  //               controller: _scrollController,
  //               itemCount: products.length + (isFetchingMore ? 1 : 0),
  //               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //                 crossAxisCount: 2,
  //                 crossAxisSpacing: 10,
  //                 mainAxisSpacing: 10,
  //                 childAspectRatio: 0.48,
  //               ),
  //               itemBuilder: (context, index) {
  //                 if (index == products.length) {
  //                   // shimmer placeholder instead of circular loader
  //                   return _buildShimmerLoader();
  //                 }
  //                 final item = products[index];
  //                 return _buildProductCard(item);
  //               },
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  Widget buildBody() {
    if (isLoading && products.isEmpty) {
      return _buildShimmerGrid();
    }

    if (products.isEmpty && !isLoading) {
      return RefreshIndicator(
        onRefresh: () => _handleRefresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            alignment: Alignment.center,
            child: const Text("No products found. Pull to refresh."),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _handleRefresh(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 1. Header (Filter & Sort)
            _buildSortHeader(),

            // 2. INSERT CHIPS HERE
            _buildActiveFilterChips(),

            const SizedBox(height: 10),

            // 3. Grid
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                itemCount: products.length + (isFetchingMore ? 1 : 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.48,
                ),
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    return _buildShimmerLoader();
                  }
                  final item = products[index];
                  return _buildProductCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterButton(), // Filter button added here
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: selectedSort,
            icon: const Icon(Icons.sort, color: Colors.black),
            style: const TextStyle(color: Colors.black, fontSize: 14),
            dropdownColor: Colors.white,
            underline: Container(),
            onChanged: (value) {
              if (value != null && value != selectedSort) {
                setState(() => selectedSort = value);
                _handleRefresh(); // Refresh with new sort order
              }
            },
            items: ["Latest", "High to Low", "Low to High"]
                .map((sortOption) => DropdownMenuItem<String>(
              value: sortOption,
              child: Text(sortOption),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product) {
    final currencyState = context.watch<CurrencyBloc>().state;

    String displaySymbol = '₹';
    double basePrice = product.actualPrice ?? 0.0;
    double displayPrice = basePrice;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      displayPrice = basePrice * currencyState.selectedRate.rate;
    }


    bool shouldShowEnquireButton =
        product.enquire1 != null && product.enquire1!.contains(1);
    final NumberFormat priceFormatter = NumberFormat.currency(
      symbol: displaySymbol,
      decimalDigits: 0,
      locale: displaySymbol == '₹'
          ? 'en_IN'
          : displaySymbol == '£'
          ? 'en_GB'
          : 'en_US',
    );



    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailNewInDetailScreen(product: product.toJson()),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              product.prodSmallImg ?? '',
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported,
                      size: 40, color: Colors.grey),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      product.designerName ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.shortDesc ?? "No description",
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (shouldShowEnquireButton)
                      ElevatedButton(
                        onPressed: () {
                          _showEnquiryDialog(context, product,_apiCountries);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          textStyle: const TextStyle(fontSize: 14),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: const Text('Enquire Now'),
                      )
                    else
                      Text(
                          priceFormatter.format(displayPrice),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),

                    // Text(
                      //   "$displaySymbol${displayPrice.toStringAsFixed(0)}",
                      //   style: const TextStyle(
                      //       fontSize: 14, fontWeight: FontWeight.bold),
                      //   textAlign: TextAlign.center,
                      // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _fetchCountries() async {
    print("Countries Method Clicked>>");
    try {
      final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _apiCountries = data.map((e) => Country.fromJson(e)).toList();
          print("_apiCountries>>$_apiCountries");
        });
      } else {
        print('Failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }
  /// Dialog with form + API integration
  ///
  // void _showEnquiryDialog(BuildContext context, Product product) {
  //   final nameController = TextEditingController();
  //   final emailController = TextEditingController();
  //   final countryController = TextEditingController();
  //   final phoneController = TextEditingController();
  //   final queryController = TextEditingController();
  //   final _formKey = GlobalKey<FormState>();
  //   bool isLoading = false;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         Future<void> submitForm() async {
  //           if (!_formKey.currentState!.validate()) return;
  //
  //           setState(() => isLoading = true);
  //
  //           final url = Uri.parse('http://stage.aashniandco.com/rest/V1/solr/submitEnquiry');
  //           final body = jsonEncode({
  //             "name": nameController.text,
  //             "email": emailController.text,
  //             "country": countryController.text,
  //             "phone": phoneController.text,
  //             "query": queryController.text,
  //             "product_name": product.designerName ?? "Unknown Product"
  //           });
  //
  //           try {
  //             final response = await http.post(
  //               url,
  //               headers: {'Content-Type': 'application/json'},
  //               body: body,
  //             );
  //
  //             if (response.statusCode == 200) {
  //               final result = jsonDecode(response.body);
  //               if (result is List && result[0] == true) {
  //                 Navigator.pop(context);
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Enquiry submitted successfully!'),
  //                     backgroundColor: Colors.green,
  //                   ),
  //                 );
  //               } else {
  //                 throw Exception(result);
  //               }
  //             } else {
  //               throw Exception('Server Error: ${response.statusCode}');
  //             }
  //           } catch (e) {
  //             ScaffoldMessenger.of(context).showSnackBar(
  //               SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
  //             );
  //           } finally {
  //             setState(() => isLoading = false);
  //           }
  //         }
  //
  //         return AlertDialog(
  //           title: Text('Enquire about ${product.designerName ?? "this product"}'),
  //           content: SingleChildScrollView(
  //             child: Form(
  //               key: _formKey,
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextFormField(
  //                     controller: nameController,
  //                     decoration: const InputDecoration(labelText: 'Name'),
  //                     validator: (v) =>
  //                     v!.isEmpty ? 'Enter your name' : null,
  //                   ),
  //                   TextFormField(
  //                     controller: emailController,
  //                     decoration: const InputDecoration(labelText: 'Email'),
  //                     validator: (v) =>
  //                     v!.isEmpty ? 'Enter email' : null,
  //                   ),
  //                   TextFormField(
  //                     controller: countryController,
  //                     decoration: const InputDecoration(labelText: 'Country'),
  //                     validator: (v) =>
  //                     v!.isEmpty ? 'Enter country' : null,
  //                   ),
  //                   TextFormField(
  //                     controller: phoneController,
  //                     decoration: const InputDecoration(labelText: 'Phone'),
  //                     keyboardType: TextInputType.phone,
  //                     validator: (v) =>
  //                     v!.isEmpty ? 'Enter phone number' : null,
  //                   ),
  //                   TextFormField(
  //                     controller: queryController,
  //                     decoration: const InputDecoration(labelText: 'Your Query'),
  //                     maxLines: 3,
  //                     validator: (v) =>
  //                     v!.isEmpty ? 'Enter your query' : null,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: isLoading ? null : submitForm,
  //               style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
  //               child: isLoading
  //                   ? const SizedBox(
  //                 height: 18,
  //                 width: 18,
  //                 child: CircularProgressIndicator(
  //                   color: Colors.white,
  //                   strokeWidth: 2,
  //                 ),
  //               )
  //                   : const Text('Submit'),
  //             ),
  //           ],
  //         );
  //       });
  //     },
  //   );
  // }


  void _showEnquiryDialog(BuildContext context, Product product,List<Country> _apiCountries) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final countryController = TextEditingController();
    final phoneController = TextEditingController();
    final queryController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? selectedCountry = countryController.text.isEmpty ? null : countryController.text;

    final sortedCountries = List<Country>.from(_apiCountries)
      ..sort((a, b) => (a.fullNameEnglish ?? '').compareTo(b.fullNameEnglish ?? ''));


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> submitForm() async {
              if (!_formKey.currentState!.validate()) return;

              setState(() => isLoading = true);

              final url = Uri.parse(
                  'https://aashniandco.com/rest/V1/solr/submitEnquiry');
              final body = jsonEncode({
                "name": nameController.text,
                "email": emailController.text,
                "country": countryController.text,
                "phone": phoneController.text,
                "query": queryController.text,
                "product_name": product.designerName ?? "Unknown Product",
              });

              try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: body,
                );

                if (response.statusCode == 200) {
                  final result = jsonDecode(response.body);
                  if (result is List && result[0] == true) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enquiry submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception(result);
                  }
                } else {
                  throw Exception('Server Error: ${response.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enquire Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(

                  product.designerName ?? "This Product",
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildTextField(
                        controller: nameController,
                        label: "Full Name",
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: emailController,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(context, 'Country'),
                        value: selectedCountry,
                        hint: const Text("Select Country"),
                        isExpanded: true,
                        items: sortedCountries
                            .where((country) => country.fullNameEnglish != null)
                            .map((Country country) {
                          return DropdownMenuItem<String>(
                            value: country.fullNameEnglish,
                            child: Text(country.fullNameEnglish ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                            countryController.text = value ?? '';
                          });
                        },
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select your country' : null,
                      ),
              //       DropdownButtonFormField<String>(
              //       decoration: _inputDecoration(context, 'Country'),
              //   value: selectedCountry,
              //   hint: const Text("Select Country"),
              //   isExpanded: true,
              //   items: _apiCountries
              //       .where((country) => country.fullNameEnglish != null)
              //       .map((Country country) {
              //     return DropdownMenuItem<String>(
              //       value: country.fullNameEnglish,
              //       child: Text(country.fullNameEnglish ?? ''),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       selectedCountry = value;
              //       countryController.text = value ?? '';
              //     });
              //   },
              //   validator: (value) => (value == null || value.isEmpty)
              //       ? 'Please select your country'
              //       : null,
              // ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: phoneController,
                        label: "Phone Number",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        controller: queryController,
                        label: "Your Query",
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Reusable textfield builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black54),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 1.2),
        ),
      ),
      validator: (v) =>
      v!.isEmpty ? 'Please enter your ${label.toLowerCase()}' : null,
    );
  }

  /// InputDecoration for dropdown
  InputDecoration _inputDecoration(BuildContext context, String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black54),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.black, width: 1.2),
      ),
    );
  }


// ... inside _DesignerDetailScreenState
  // Widget _buildProductCard(Product product) {
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //
  //   String displaySymbol = '₹';
  //   double basePrice = product.actualPrice ?? 0.0;
  //   double displayPrice = basePrice;
  //
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     displayPrice = basePrice * currencyState.selectedRate.rate;
  //   }
  //
  //   // Check if enquire_1 exists and contains the integer 1
  //   // Now product.enquire1 is List<int>? so .contains(1) works directly
  //   bool shouldShowEnquireButton = product.enquire1 != null && product.enquire1!.contains(1);
  //
  //   return GestureDetector(
  //     onTap: () {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) =>
  //               ProductDetailNewInDetailScreen(product: product.toJson()),
  //         ),
  //       );
  //     },
  //     child: Card(
  //       color: Colors.white,
  //       elevation: 1,
  //       clipBehavior: Clip.antiAlias,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Image.network(
  //             product.prodSmallImg ?? product.prodSmallImg ?? '',
  //             height: 250,
  //             fit: BoxFit.cover,
  //             errorBuilder: (context, error, stackTrace) {
  //               return Container(
  //                 height: 250,
  //                 color: Colors.grey[200],
  //                 alignment: Alignment.center,
  //                 child: const Icon(Icons.image_not_supported,
  //                     size: 40, color: Colors.grey),
  //               );
  //             },
  //           ),
  //           Expanded(
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start, // <-- Changed from center
  //                 crossAxisAlignment: CrossAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     product.designerName ?? "Unknown",
  //                     style: const TextStyle(
  //                         fontSize: 14, fontWeight: FontWeight.bold),
  //                     textAlign: TextAlign.center,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     product.shortDesc ?? "No description",
  //                     textAlign: TextAlign.center,
  //                     style:
  //                     const TextStyle(fontSize: 12, color: Colors.black),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   if (shouldShowEnquireButton) // Conditional rendering
  //                     ElevatedButton(
  //                       onPressed: () {
  //                         print('Enquire about product: ${product.designerName}');
  //                         // Navigator.push(
  //                         //   context,
  //                         //   MaterialPageRoute(
  //                         //     builder: (_) => const EnquiryFormWebView(productName: 'IQBAL HUSSAIN'),
  //                         //   ),
  //                         // );
  //                         showDialog(
  //                           context: context,
  //                           builder: (context) => AlertDialog(
  //                             title: const Text('Product Enquiry'),
  //                             content: Text('You are enquiring about ${product.designerName ?? "this product"}.'),
  //                             actions: [
  //                               TextButton(
  //                                 onPressed: () => Navigator.pop(context),
  //                                 child: const Text('OK'),
  //                               ),
  //                             ],
  //                           ),
  //                         );
  //                       },
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: Colors.black,
  //                         foregroundColor: Colors.white,
  //                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //                         textStyle: const TextStyle(fontSize: 14),
  //                         shape: const RoundedRectangleBorder(
  //                           borderRadius: BorderRadius.zero, // ✅ Makes corners sharp
  //                         ),
  //                       ),
  //                       child: const Text('Enquire Now'),
  //                     )
  //
  //                   else
  //                     Text(
  //                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
  //                       style: const TextStyle(
  //                           fontSize: 14, fontWeight: FontWeight.bold),
  //                       textAlign: TextAlign.center,
  //                     ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
// ... rest of your _DesignerDetailScreenState class
}
// class DesignerDetailScreen extends StatefulWidget {
//   final String designerName;
//   final String? categoryName; // Potentially add for filtering context
//
//   const DesignerDetailScreen({
//     Key? key,
//     required this.designerName,
//     this.categoryName, // Added
//   }) : super(key: key);
//
//   @override
//   State<DesignerDetailScreen> createState() => _DesignerDetailScreenState();
// }
//
// class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
//   int? _totalProducts;
//   bool isLoading = true;
//   List<Product> products = []; // Changed to List<Product>
//   String selectedSort = "Latest";
//   late Future<Map<String, dynamic>> _categoryMetadata;
//   final ApiService _apiService = ApiService(); // Initialize ApiService
//
//   final _scrollController = ScrollController();
//   int _currentOffset = 0;
//   final int _pageSize = 10;
//   bool isFetchingMore = false;
//   bool hasMoreData = true;
//
//   bool _isNavBarVisible = true;
//
//   // List to hold currently active filters, similar to FilteredProductsScreen
//   List<Map<String, dynamic>> _currentActiveFilters = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize _currentActiveFilters with the designer filter
//     _currentActiveFilters = [
//       {'type': 'designer_name', 'value': widget.designerName, 'name': widget.designerName}
//     ];
//     fetchDesignerDetails();
//     _scrollController.addListener(_onScroll);
//
//     // Initialize _categoryMetadata. You might need a more sophisticated way
//     // to get a relevant category for a designer, or use a default.
//     // For now, let's use a placeholder or the provided categoryName.
//     _fetchCategoryMetadata(widget.categoryName ?? 'all',isDesignerScreen: true); // 'all' as a fallback
//   }
//
//   void _fetchCategoryMetadata(String categoryName, {bool isDesignerScreen = false}) {
//     _categoryMetadata = _apiService.fetchCategoryMetadataByName(categoryName, isDesignerScreen: isDesignerScreen);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     // --- Navbar Visibility Logic ---
//     final direction = _scrollController.position.userScrollDirection;
//     if (direction == ScrollDirection.reverse) {
//       // User is scrolling down
//       if (_isNavBarVisible) {
//         setState(() => _isNavBarVisible = false);
//       }
//     } else if (direction == ScrollDirection.forward) {
//       // User is scrolling up
//       if (!_isNavBarVisible) {
//         setState(() => _isNavBarVisible = true);
//       }
//     }
//
//     // --- Pagination Logic (Your existing code) ---
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         !isFetchingMore &&
//         hasMoreData) {
//       fetchDesignerDetails(isPaginating: true);
//     }
//   }
//
//   Future<void> _handleRefresh({List<Map<String, dynamic>>? newFilters}) async {
//     setState(() {
//       products.clear();
//       _currentOffset = 0;
//       hasMoreData = true;
//       isLoading = true;
//       _totalProducts = null;
//       if (newFilters != null) {
//         _currentActiveFilters = newFilters;
//       }
//     });
//     await fetchDesignerDetails();
//   }
//
//   String _getSolrSortString() {
//     switch (selectedSort) {
//       case "High to Low":
//         return "actual_price_1 desc";
//       case "Low to High":
//         return "actual_price_1 asc";
//       default:
//         return "prod_en_id desc";
//     }
//   }
//
//   // --- Filter Button Widget ---
//   Widget _buildFilterButton() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadata,
//       builder: (context, snapshot) {
//         // Determine if filtering is possible based on metadata or a reasonable default
//         // For a designer page, you might want to enable filtering even if category metadata
//         // isn't perfectly aligned, by always allowing a generic filter.
//         // Or, more robustly, fetch metadata for a relevant parent category for the designer.
//         final bool canFilter = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
//
//         return TextButton.icon(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//             padding: EdgeInsets.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           onPressed: canFilter // Only enable if we have category data, or always enable with a generic filter
//               ? () {
//             // This is where you'd trigger the FilterBottomSheetCategories.
//             // You'll need a categoryId to pass to it. For a designer page,
//             // this might be a common parent category for the designer's products
//             // or a specific category if the designer only works in one.
//             final String parentCategoryId = snapshot.hasData
//                 ? snapshot.data!['pare_cat_id']?.toString() ?? ''
//                 : '';
//
//             if (parentCategoryId.isNotEmpty) {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (bottomSheetContext) {
//                   return BlocProvider<FilteredProductsBloc>(
//                     create: (context) => FilteredProductsBloc(),
//                     child: FilterBottomSheetCategories(
//                       categoryId: parentCategoryId,
//
//                     ),
//                   );
//                 },
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content:
//                     Text("Filter not available for this category.")),
//               );
//             }
//           }
//               : null, // Disable if cannot filter
//           icon: const Icon(Icons.filter_list),
//           label: Text(
//             'Filter',
//             style: TextStyle(
//               fontSize: 16,
//               color: canFilter ? Colors.black : Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   String _buildRequestBody() {
//     const String fieldsToFetch =
//         'designer_name,actual_price,prod_name,enquire_1,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
//     final String sortString = _getSolrSortString();
//
//     // Construct the filter query based on _currentActiveFilters
//     List<String> filterClauses = [];
//
//     // Always include the designer filter
//     filterClauses.add('designer_name:"${widget.designerName}"');
//     filterClauses.add('actual_price_1:[0.01 TO *]'); // Always filter for valid prices
//
//     // Add other active filters
//     for (var filter in _currentActiveFilters) {
//       if (filter['type'] == 'categories' && filter['id'] != null) {
//         filterClauses.add('category_id:"${filter['id']}"');
//       }
//       // Add more filter types (e.g., price ranges, sizes) as needed
//       // based on the structure of your filter objects.
//       // Example:
//       // if (filter['type'] == 'price_range') {
//       //   filterClauses.add('actual_price_1:[${filter['min']} TO ${filter['max']}]');
//       // }
//     }
//
//     final String combinedFilter = filterClauses.join(' AND ');
//
//     final String solrQuery =
//         "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$combinedFilter";
//     final Map<String, dynamic> requestBody = {
//       "queryParams": {"query": solrQuery}
//     };
//     return json.encode(requestBody);
//   }
//
//   Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
//     if ((_totalProducts != null && products.length >= _totalProducts!) ||
//         isFetchingMore) {
//       if (_totalProducts != null && products.length >= _totalProducts!) {
//         if (hasMoreData) setState(() => hasMoreData = false);
//       }
//       return;
//     }
//
//     setState(() {
//       if (isPaginating) {
//         isFetchingMore = true;
//       } else {
//         isLoading = true;
//       }
//     });
//
//     final String requestBody = _buildRequestBody();
//     print("requestBody>>>$requestBody");
//     final url = Uri.parse('https://aashniandco.com/rest/V1/solr/search');
//
//     try {
//       HttpClient httpClient = HttpClient()
//         ..badCertificateCallback =
//             (X509Certificate cert, String host, int port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data is List && data.length > 1 && data[1]['docs'] is List) {
//           if (_totalProducts == null) {
//             _totalProducts = data[1]['numFound'] as int?;
//           }
//           List<Product> newProducts = (data[1]['docs'] as List)
//               .map((item) => Product.fromJson(item as Map<String, dynamic>))
//               .toList();
//           if (mounted) {
//             setState(() {
//               products.addAll(newProducts);
//               _currentOffset += newProducts.length;
//               if (_totalProducts != null &&
//                   products.length >= _totalProducts!) {
//                 hasMoreData = false;
//               }
//               if (newProducts.length < _pageSize) {
//                 hasMoreData = false;
//               }
//             });
//           }
//         } else {
//           if (mounted) setState(() => hasMoreData = false);
//         }
//       } else {
//         throw Exception(
//             'Failed to load designer details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching designer details: $e');
//       if (mounted) setState(() => hasMoreData = false);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isFetchingMore = false;
//         });
//       }
//     }
//   }
//
//   /// 🟣 Shimmer Grid Placeholder
//   Widget _buildShimmerGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: 6,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.5,
//       ),
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   /// 🟣 Shimmer for pagination loader
//   Widget _buildShimmerLoader() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Container(
//           height: 100,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double navBarHeight =
//         kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
//     return Scaffold(
//       backgroundColor: Colors.red,
//       appBar: CommonAppBar(
//         // The back button is needed here, so we enable it.
//         automaticallyImplyLeading: true,
//         titleWidget: Text(widget.designerName),
//       ),
//       body: buildBody(),
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//         // Animate the height to show/hide the navbar
//         height: _isNavBarVisible ? navBarHeight : 0,
//         // Use a Wrap to prevent layout errors during animation
//         child: Wrap(
//           children: const [
//             // Set a relevant index, or a non-interfering one like 3 (Wishlist)
//             CommonBottomNavBar(currentIndex: 0),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildBody() {
//     if (isLoading && products.isEmpty) {
//       return _buildShimmerGrid();
//     }
//
//     if (products.isEmpty && !isLoading) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             alignment: Alignment.center,
//             child: const Text("No products found. Pull to refresh."),
//           ),
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             _buildSortHeader(),
//             const SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 controller: _scrollController,
//                 itemCount: products.length + (isFetchingMore ? 1 : 0),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.5,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (index == products.length) {
//                     // shimmer placeholder instead of circular loader
//                     return _buildShimmerLoader();
//                   }
//                   final item = products[index];
//                   return _buildProductCard(item);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildFilterButton(), // Filter button added here
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: selectedSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             style: const TextStyle(color: Colors.black, fontSize: 14),
//             dropdownColor: Colors.white,
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != selectedSort) {
//                 setState(() => selectedSort = value);
//                 _handleRefresh(); // Refresh with new sort order
//               }
//             },
//             items: ["Latest", "High to Low", "Low to High"]
//                 .map((sortOption) => DropdownMenuItem<String>(
//               value: sortOption,
//               child: Text(sortOption),
//             ))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProductCard(Product product) { // Changed parameter to Product
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     String displaySymbol = '₹';
//     double basePrice = product.actualPrice ?? 0.0;
//     double displayPrice = basePrice;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       displayPrice = basePrice * currencyState.selectedRate.rate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ProductDetailNewInDetailScreen(product: product.toJson()),
//           ),
//         );
//       },
//       child: Card(
//         color: Colors.white,
//         elevation: 1,
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               product.prodSmallImg ?? product.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_not_supported,
//                       size: 40, color: Colors.grey),
//                 );
//               },
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       product.designerName ?? "Unknown",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       product.shortDesc ?? "No description",
//                       textAlign: TextAlign.center,
//                       style:
//                       const TextStyle(fontSize: 12, color: Colors.black),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//8/11/2025
// class DesignerDetailScreen extends StatefulWidget {
//   final String designerName;
//   const DesignerDetailScreen({super.key, required this.designerName});
//
//   @override
//   _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
// }

// class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
//   int? _totalProducts;
//   bool isLoading = true;
//   List<dynamic> products = [];
//   String selectedSort = "Latest";
//   late Future<Map<String, dynamic>> _categoryMetadata;
//
//   final _scrollController = ScrollController();
//   int _currentOffset = 0;
//   final int _pageSize = 10;
//   bool isFetchingMore = false;
//   bool hasMoreData = true;
//
//   bool _isNavBarVisible = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDesignerDetails();
//     _scrollController.addListener(_onScroll);
//   }
//
//
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // void _onScroll() {
//   //   if (_scrollController.position.pixels >=
//   //       _scrollController.position.maxScrollExtent - 200 &&
//   //       !isFetchingMore &&
//   //       hasMoreData) {
//   //     fetchDesignerDetails(isPaginating: true);
//   //   }
//   // }
//
//   void _onScroll() {
//     // --- Navbar Visibility Logic ---
//     final direction = _scrollController.position.userScrollDirection;
//     if (direction == ScrollDirection.reverse) { // User is scrolling down
//       if (_isNavBarVisible) {
//         setState(() => _isNavBarVisible = false);
//       }
//     } else if (direction == ScrollDirection.forward) { // User is scrolling up
//       if (!_isNavBarVisible) {
//         setState(() => _isNavBarVisible = true);
//       }
//     }
//
//     // --- Pagination Logic (Your existing code) ---
//     if (_scrollController.position.pixels >=
//         _scrollController.position.maxScrollExtent - 200 &&
//         !isFetchingMore &&
//         hasMoreData) {
//       fetchDesignerDetails(isPaginating: true);
//     }
//   }
//
//
//   Future<void> _handleRefresh() async {
//     setState(() {
//       products.clear();
//       _currentOffset = 0;
//       hasMoreData = true;
//       isLoading = true;
//       _totalProducts = null;
//     });
//     await fetchDesignerDetails();
//   }
//
//   String _getSolrSortString() {
//     switch (selectedSort) {
//       case "High to Low":
//         return "actual_price_1 desc";
//       case "Low to High":
//         return "actual_price_1 asc";
//       default:
//         return "prod_en_id desc";
//     }
//   }
//
//   Widget _buildFilterButton() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadata,
//       builder: (context, snapshot) {
//         final bool canFilter =
//             snapshot.connectionState == ConnectionState.done &&
//                 !snapshot.hasError;
//
//         return TextButton.icon(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//             padding: EdgeInsets.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           onPressed: canFilter
//               ? () {
//             final categoryData = snapshot.data!;
//             final String parentCategoryId =
//                 categoryData['pare_cat_id']?.toString() ?? '';
//             if (parentCategoryId.isNotEmpty) {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => BlocProvider.value(
//                   value: BlocProvider.of<FilteredProductsBloc>(context),
//                   child: FilterBottomSheetCategories(
//                     categoryId: parentCategoryId,
//                   ),
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                     content:
//                     Text("Filter not available for this category.")),
//               );
//             }
//           }
//               : null,
//           icon: const Icon(Icons.filter_list),
//           label: Text(
//             'Filter',
//             style: TextStyle(
//               fontSize: 16,
//               color: canFilter ? Colors.black : Colors.grey,
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//
//   String _buildRequestBody() {
//     const String fieldsToFetch =
//         'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
//     final String sortString = _getSolrSortString();
//     //live*
//     // final String filter = 'designer_name:"${widget.designerName}"';
//     final String filter = 'designer_name:"${widget.designerName}" AND actual_price_1:[0.01 TO *]';
//     final String solrQuery =
//         "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$filter";
//     final Map<String, dynamic> requestBody = {
//       "queryParams": {"query": solrQuery}
//     };
//     return json.encode(requestBody);
//   }
//
//   Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
//     if ((_totalProducts != null && products.length >= _totalProducts!) ||
//         isFetchingMore) {
//       if (_totalProducts != null && products.length >= _totalProducts!) {
//         if (hasMoreData) setState(() => hasMoreData = false);
//       }
//       return;
//     }
//
//     setState(() {
//       if (isPaginating) {
//         isFetchingMore = true;
//       } else {
//         isLoading = true;
//       }
//     });
//
//     final String requestBody = _buildRequestBody();
//     final url = Uri.parse('https://aashniandco.com/rest/V1/solr/search');
//
//     try {
//       HttpClient httpClient = HttpClient()
//         ..badCertificateCallback =
//             (X509Certificate cert, String host, int port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data is List && data.length > 1 && data[1]['docs'] is List) {
//           if (_totalProducts == null) {
//             _totalProducts = data[1]['numFound'] as int?;
//           }
//           List<dynamic> newProducts = data[1]['docs'];
//           if (mounted) {
//             setState(() {
//               products.addAll(newProducts);
//               _currentOffset += newProducts.length;
//               if (_totalProducts != null &&
//                   products.length >= _totalProducts!) {
//                 hasMoreData = false;
//               }
//               if (newProducts.length < _pageSize) {
//                 hasMoreData = false;
//               }
//             });
//           }
//         } else {
//           if (mounted) setState(() => hasMoreData = false);
//         }
//       } else {
//         throw Exception(
//             'Failed to load designer details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching designer details: $e');
//       if (mounted) setState(() => hasMoreData = false);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isFetchingMore = false;
//         });
//       }
//     }
//   }
//
//   /// 🟣 Shimmer Grid Placeholder
//   Widget _buildShimmerGrid() {
//     return GridView.builder(
//       padding: const EdgeInsets.all(8),
//       itemCount: 6,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 2,
//         crossAxisSpacing: 10,
//         mainAxisSpacing: 10,
//         childAspectRatio: 0.5,
//       ),
//       itemBuilder: (context, index) {
//         return Shimmer.fromColors(
//           baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//           child: Container(
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   /// 🟣 Shimmer for pagination loader
//   Widget _buildShimmerLoader() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Container(
//           height: 100,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CommonAppBar(
//         // The back button is needed here, so we enable it.
//         automaticallyImplyLeading: true,
//         titleWidget: Text(widget.designerName),
//       ),
//
//       body: buildBody(),
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//         // Animate the height to show/hide the navbar
//         height: _isNavBarVisible ? navBarHeight : 0,
//         // Use a Wrap to prevent layout errors during animation
//         child: Wrap(
//           children: const [
//             // Set a relevant index, or a non-interfering one like 3 (Wishlist)
//             CommonBottomNavBar(currentIndex: 3),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget buildBody() {
//     if (isLoading && products.isEmpty) {
//       return _buildShimmerGrid();
//     }
//
//     if (products.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             alignment: Alignment.center,
//             child: const Text("No products found. Pull to refresh."),
//           ),
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             _buildSortHeader(),
//             const SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 controller: _scrollController,
//                 itemCount: products.length + (isFetchingMore ? 1 : 0),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.5,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (index == products.length) {
//                     // shimmer placeholder instead of circular loader
//                     return _buildShimmerLoader();
//                   }
//                   final item = products[index];
//                   return _buildProductCard(item);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         _buildFilterButton(),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: selectedSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             style: const TextStyle(color: Colors.black, fontSize: 14),
//             dropdownColor: Colors.white,
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != selectedSort) {
//                 setState(() => selectedSort = value);
//                 _handleRefresh();
//               }
//             },
//             items: ["Latest", "High to Low", "Low to High"]
//                 .map((sortOption) => DropdownMenuItem<String>(
//               value: sortOption,
//               child: Text(sortOption),
//             ))
//                 .toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProductCard(Map<String, dynamic> item) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     String displaySymbol = '₹';
//     double basePrice = (item['actual_price_1'] as num?)?.toDouble() ?? 0.0;
//     double displayPrice = basePrice;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       displayPrice = basePrice * currencyState.selectedRate.rate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ProductDetailNewInDetailScreen(product: item),
//           ),
//         );
//       },
//       child: Card(
//         color: Colors.white,
//         elevation: 1,
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               item['prod_image_url'] ?? item['prod_small_img'] ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_not_supported,
//                       size: 40, color: Colors.grey),
//                 );
//               },
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       item['designer_name'] ?? "Unknown",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item['short_desc'] ?? "No description",
//                       textAlign: TextAlign.center,
//                       style:
//                       const TextStyle(fontSize: 12, color: Colors.black),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class DesignerDetailScreen extends StatefulWidget {
//   final String designerName;
//   const DesignerDetailScreen({super.key, required this.designerName});
//
//   @override
//   _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
// }
//
// class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
//   // --- STATE VARIABLES ---
//   int? _totalProducts;
//   bool isLoading = true;
//   List<dynamic> products = []; // Single list, sorted by the server
//   String selectedSort = "Latest";
//
//   // --- PAGINATION STATE VARIABLES ---
//   final _scrollController = ScrollController();
//   int _currentOffset = 0;
//   final int _pageSize = 10; // How many items to fetch per page
//   bool isFetchingMore = false;
//   bool hasMoreData = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDesignerDetails();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
//         !isFetchingMore &&
//         hasMoreData) {
//       fetchDesignerDetails(isPaginating: true);
//     }
//   }
//
//   /// Handles refreshing the list, used for pull-to-refresh and changing sort order.
//   Future<void> _handleRefresh() async {
//     setState(() {
//       products.clear();
//       _currentOffset = 0;
//       hasMoreData = true;
//       isLoading = true;
//       _totalProducts = null;
//     });
//     await fetchDesignerDetails();
//   }
//
//   /// Converts our dropdown selection into the API's required sort string.
//   String _getSolrSortString() {
//     switch (selectedSort) {
//       case "High to Low":
//         return "actual_price_1 desc";
//       case "Low to High":
//         return "actual_price_1 asc";
//       case "Latest":
//       default:
//         return "prod_en_id desc";
//     }
//   }
//
//   /// Builds the complex JSON request body for the POST request.
//   String _buildRequestBody() {
//     const String fieldsToFetch =
//         'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
//     final String sortString = _getSolrSortString();
//     final String filter = 'designer_name:"${widget.designerName}"';
//     final String solrQuery =
//         "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$filter";
//     final Map<String, dynamic> requestBody = {
//       "queryParams": {"query": solrQuery}
//     };
//     return json.encode(requestBody);
//   }
//
//   /// Fetches designer products from the API using a POST request.
//   Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
//     if ((_totalProducts != null && products.length >= _totalProducts!) || isFetchingMore) {
//       if (_totalProducts != null && products.length >= _totalProducts!) {
//         if (hasMoreData) setState(() => hasMoreData = false);
//       }
//       return;
//     }
//
//     setState(() {
//       if (isPaginating) {
//         isFetchingMore = true;
//       } else {
//         isLoading = true;
//       }
//     });
//
//     final String requestBody = _buildRequestBody();
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/search');
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data is List && data.length > 1 && data[1]['docs'] is List) {
//           if (_totalProducts == null) {
//             _totalProducts = data[1]['numFound'] as int?;
//           }
//           List<dynamic> newProducts = data[1]['docs'];
//           if (mounted) {
//             setState(() {
//               products.addAll(newProducts);
//               _currentOffset += newProducts.length;
//               if (_totalProducts != null && products.length >= _totalProducts!) {
//                 hasMoreData = false;
//               }
//               if (newProducts.length < _pageSize) {
//                 hasMoreData = false;
//               }
//             });
//           }
//         } else {
//           if (mounted) setState(() => hasMoreData = false);
//         }
//       } else {
//         throw Exception('Failed to load designer details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching designer details: $e');
//       if (mounted) setState(() => hasMoreData = false);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isFetchingMore = false;
//         });
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.designerName)),
//       body: buildBody(),
//     );
//   }
//
//   Widget buildBody() {
//     if (isLoading && products.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (products.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             alignment: Alignment.center,
//             child: const Text("No products found. Pull to refresh."),
//           ),
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             _buildSortHeader(),
//             const SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 controller: _scrollController,
//                 itemCount: products.length + (isFetchingMore ? 1 : 0),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.5,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (index == products.length) {
//                     return const Center(
//                       child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
//                     );
//                   }
//                   final item = products[index];
//                   // Call the helper method to build the card
//                   return _buildProductCard(item);
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.end,
//       children: [
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: selectedSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             style: const TextStyle(color: Colors.black, fontSize: 14),
//             dropdownColor: Colors.white,
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != selectedSort) {
//                 setState(() => selectedSort = value);
//                 _handleRefresh();
//               }
//             },
//             items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//               return DropdownMenuItem<String>(
//                 value: sortOption,
//                 child: Text(sortOption),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // --- NEW WIDGET WITH CURRENCY LOGIC ---
//   Widget _buildProductCard(Map<String, dynamic> item) {
//     // 1. Watch the global CurrencyBloc state. This widget will now rebuild
//     //    whenever the currency changes.
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     // Default values, assuming base currency is INR (₹).
//     String displaySymbol = '₹';
//     double basePrice = (item['actual_price_1'] as num?)?.toDouble() ?? 0.0;
//     double displayPrice = basePrice;
//
//     // 2. If currency is loaded, calculate the new price and get the symbol.
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       // Calculate price: (base price in INR) * (selected currency's rate)
//       displayPrice = basePrice * currencyState.selectedRate.rate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailNewInDetailScreen(product: item),
//           ),
//         );
//       },
//       child: Card(
//         color: Colors.white,
//         elevation: 1,
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch, // Changed for better layout
//           children: [
//             Image.network(
//               item['prod_image_url'] ?? item['prod_small_img'] ?? '',
//               height: 250, // Give image a fixed height
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//                 );
//               },
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
//                   children: [
//                     Text(
//                       item['designer_name'] ?? "Unknown",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item['short_desc'] ?? "No description",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       maxLines: 2, overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       // 3. Display the calculated price and symbol.
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//18/8/2025
// The main screen widget
// class DesignerDetailScreen extends StatefulWidget {
//   final String designerName;
//   const DesignerDetailScreen({super.key, required this.designerName});
//
//   @override
//   _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
// }
//
// class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
//   // --- STATE VARIABLES ---
//   int? _totalProducts;
//   bool isLoading = true;
//   List<dynamic> products = []; // Single list, sorted by the server
//   String selectedSort = "Latest";
//
//   // --- PAGINATION STATE VARIABLES ---
//   final _scrollController = ScrollController();
//   int _currentOffset = 0;
//   final int _pageSize = 10; // How many items to fetch per page
//   bool isFetchingMore = false;
//   bool hasMoreData = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDesignerDetails();
//     _scrollController.addListener(_onScroll);
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 &&
//         !isFetchingMore &&
//         hasMoreData) {
//       fetchDesignerDetails(isPaginating: true);
//     }
//   }
//
//   /// Handles refreshing the list, used for pull-to-refresh and changing sort order.
//   Future<void> _handleRefresh() async {
//     setState(() {
//       products.clear();
//       _currentOffset = 0;
//       hasMoreData = true;
//       isLoading = true;
//       _totalProducts = null;
//     });
//     await fetchDesignerDetails();
//   }
//
//   /// Converts our dropdown selection into the API's required sort string.
//   String _getSolrSortString() {
//     switch (selectedSort) {
//       case "High to Low":
//         return "actual_price_1 desc";
//       case "Low to High":
//         return "actual_price_1 asc";
//       case "Latest":
//       default:
//       // Using 'prod_en_id desc' as a good proxy for "Latest".
//       // The API log shows a more complex sort string which could also be used.
//         return "prod_en_id desc";
//     }
//   }
//
//   /// Builds the complex JSON request body for the POST request.
//   ///
//   String _buildRequestBody() {
//     // Add 'prod_image_url' to the list of fields to fetch
//     const String fieldsToFetch =
//         'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
//
//     final String sortString = _getSolrSortString();
//
//     // Corrected filter: Only search by designer name
//     final String filter = 'designer_name:"${widget.designerName}"';
//
//     final String solrQuery =
//         "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$filter";
//
//     final Map<String, dynamic> requestBody = {
//       "queryParams": {"query": solrQuery}
//     };
//     return json.encode(requestBody);
//   }
//   // String _buildRequestBody() {
//   //   const String fieldsToFetch =
//   //       'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,actual_price_1';
//   //
//   //   final String sortString = _getSolrSortString();
//   //   final String filter = 'designer_name:"${widget.designerName}" AND actual_price_1:{0 TO *}';
//   //
//   //   // Construct the full Solr query string.
//   //   final String solrQuery =
//   //       "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$filter";
//   //
//   //   final Map<String, dynamic> requestBody = {
//   //     "queryParams": {"query": solrQuery}
//   //   };
//   //   return json.encode(requestBody);
//   // }
//
//   /// Fetches designer products from the API using a POST request.
//   ///
//   Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
//     if ((_totalProducts != null && products.length >= _totalProducts!) || isFetchingMore) {
//       if (_totalProducts != null && products.length >= _totalProducts!) {
//         if (hasMoreData) setState(() => hasMoreData = false);
//       }
//       return;
//     }
//
//     setState(() {
//       if (isPaginating) {
//         isFetchingMore = true;
//       } else {
//         isLoading = true;
//       }
//     });
//
//     final String requestBody = _buildRequestBody();
//     final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/search');
//
//     print("🚀 MAKING API REQUEST to ${url.path}");
//     print("   Request Body: $requestBody");
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: requestBody,
//       );
//
//       print("✅ API RESPONSE RECEIVED with Status: ${response.statusCode}");
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data is List && data.length > 1 && data[1]['docs'] is List) {
//           if (_totalProducts == null) {
//             _totalProducts = data[1]['numFound'] as int?;
//             print("Total products found for this designer: $_totalProducts");
//           }
//
//           List<dynamic> newProducts = data[1]['docs'];
//
//           // ===============================================================
//           // UPDATED PRINT LOGIC STARTS HERE
//           // ===============================================================
//           print("\n--- 📄 Printing Details for Page (Offset: $_currentOffset) ---");
//           for (var product in newProducts) {
//             // Use null-aware operators (??) as a safeguard in case a field is missing
//             final sku = product['prod_sku'] ?? 'SKU not available';
//             final shortDesc = product['short_desc'] ?? 'Description not available';
//             final imageUrl = product['prod_small_img'] ?? 'Image URL not available'; // Extract image URL
//
//             // Print in a more readable, multi-line format
//             print("  - SKU: $sku");
//             print("    Desc: $shortDesc");
//             print("    Image URL: $imageUrl");
//             print("    --------------------");
//           }
//           print("--- End of Page Details ---\n");
//           // ===============================================================
//           // UPDATED PRINT LOGIC ENDS HERE
//           // ===============================================================
//
//           if (mounted) {
//             setState(() {
//               products.addAll(newProducts);
//               _currentOffset += newProducts.length;
//
//               if (_totalProducts != null && products.length >= _totalProducts!) {
//                 hasMoreData = false;
//               }
//               if (newProducts.length < _pageSize) {
//                 hasMoreData = false;
//               }
//             });
//           }
//         } else {
//           if (mounted) setState(() => hasMoreData = false);
//         }
//       } else {
//         throw Exception('Failed to load designer details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching designer details: $e');
//       if (mounted) setState(() => hasMoreData = false);
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//           isFetchingMore = false;
//         });
//       }
//     }
//   }
//   // Future<void> fetchDesignerDetails({bool isPaginating = false}) async {
//   //   if ((_totalProducts != null && products.length >= _totalProducts!) || isFetchingMore) {
//   //     if (_totalProducts != null && products.length >= _totalProducts!) {
//   //       if (hasMoreData) setState(() => hasMoreData = false);
//   //     }
//   //     return;
//   //   }
//   //
//   //   setState(() {
//   //     if (isPaginating) {
//   //       isFetchingMore = true;
//   //     } else {
//   //       isLoading = true;
//   //     }
//   //   });
//   //
//   //   final url = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/search');
//   //   final String requestBody = _buildRequestBody();
//   //
//   //   print("🚀 MAKING API REQUEST to ${url.path}");
//   //   print("   Request Body: $requestBody");
//   //
//   //   try {
//   //     HttpClient httpClient = HttpClient();
//   //     httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //
//   //     // Use POST instead of GET
//   //     final response = await ioClient.post(
//   //       url,
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: requestBody,
//   //     );
//   //
//   //     print("✅ API RESPONSE RECEIVED with Status: ${response.statusCode}");
//   //
//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //
//   //       if (data is List && data.length > 1 && data[1]['docs'] is List) {
//   //         if (_totalProducts == null) {
//   //           _totalProducts = data[1]['numFound'] as int?;
//   //         }
//   //         List<dynamic> newProducts = data[1]['docs'];
//   //         if (mounted) {
//   //           setState(() {
//   //             products.addAll(newProducts);
//   //             _currentOffset += newProducts.length;
//   //
//   //             if (_totalProducts != null && products.length >= _totalProducts!) {
//   //               hasMoreData = false;
//   //             }
//   //             if (newProducts.length < _pageSize) {
//   //               hasMoreData = false;
//   //             }
//   //           });
//   //         }
//   //       } else {
//   //         if (mounted) setState(() => hasMoreData = false);
//   //       }
//   //     } else {
//   //       throw Exception('Failed to load designer details: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print('Exception fetching designer details: $e');
//   //     if (mounted) setState(() => hasMoreData = false);
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() {
//   //         isLoading = false;
//   //         isFetchingMore = false;
//   //       });
//   //     }
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.designerName)),
//       body: buildBody(),
//     );
//   }
//
//   Widget buildBody() {
//     if (isLoading && products.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }
//     if (products.isEmpty) {
//       return RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Container(
//             height: MediaQuery.of(context).size.height * 0.8,
//             alignment: Alignment.center,
//             child: const Text("No products found. Pull to refresh."),
//           ),
//         ),
//       );
//     }
//
//     return RefreshIndicator(
//       onRefresh: _handleRefresh,
//       child: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "",
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 ),
//                 Container(
//                   height: 35,
//                   padding: const EdgeInsets.symmetric(horizontal: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[200],
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: DropdownButton<String>(
//                     value: selectedSort,
//                     icon: const Icon(Icons.sort, color: Colors.black),
//                     style: const TextStyle(color: Colors.black, fontSize: 14),
//                     dropdownColor: Colors.white,
//                     underline: Container(),
//                     onChanged: (value) {
//                       if (value != null && value != selectedSort) {
//                         setState(() {
//                           selectedSort = value;
//                         });
//                         // Changing sort now triggers a full refresh from the server.
//                         _handleRefresh();
//                       }
//                     },
//                     items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                       return DropdownMenuItem<String>(
//                         value: sortOption,
//                         child: Text(sortOption),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),
//             Expanded(
//               child: GridView.builder(
//                 controller: _scrollController,
//                 itemCount: products.length + (isFetchingMore ? 1 : 0),
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.5,
//                 ),
//                 itemBuilder: (context, index) {
//                   if (index == products.length) {
//                     return const Center(
//                       child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
//                     );
//                   }
//                   final item = products[index];
//                   return GestureDetector(
//                     onTap: () {
//                       print("Tapped Product: ${jsonEncode(item['name'])}");
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => ProductDetailNewInDetailScreen(product: item),
//                         ),
//                       );
//                     },
//                     child: Card(
//                       color: Colors.white,
//                       elevation: 1,
//                       clipBehavior: Clip.antiAlias,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Flexible(
//                             child:
//                             Image.network(
//                               item['prod_image_url'] ?? item['prod_small_img'] ?? '', // Use the best URL
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                               // THIS IS THE CRUCIAL PART FOR DEBUGGING
//                               errorBuilder: (context, error, stackTrace) {
//                                 // This will print the exact error to the console
//                                 print("❌ FAILED TO LOAD IMAGE for SKU ${item['prod_sku']}. Error: $error");
//                                 return Container(
//                                   width: double.infinity,
//                                   color: Colors.grey[200],
//                                   alignment: Alignment.center,
//                                   child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//                                 );
//                               },
//                               loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                 if (loadingProgress == null) return child;
//                                 return Center(
//                                   child: CircularProgressIndicator(
//                                     value: loadingProgress.expectedTotalBytes != null
//                                         ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                         : null,
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Center(
//                               child: Text(
//                                 item['designer_name'] ?? "Unknown",
//                                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: Center(
//                               child: Text(
//                                 item['short_desc'] ?? "No description",
//                                 textAlign: TextAlign.center, style: const TextStyle(fontSize: 12),
//                                 maxLines: 2, overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8.0),
//                             child: Center(
//                               child: Text(
//                                 "₹${(item['actual_price_1'] as num?)?.toStringAsFixed(0) ?? 'N/A'}",
//                                 style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                 textAlign: TextAlign.center,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class DesignerDetailScreen extends StatefulWidget {
//   final String designerName;
//   DesignerDetailScreen({required this.designerName});
//
//   @override
//   _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
// }
//
// class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
//   bool isLoading = true;
//   List<dynamic> products = []; // Holds the original fetched product list
//   List<dynamic> sortedProducts = []; // Holds the list to be displayed and sorted
//   String selectedSort = "Latest"; // Default sorting order
//
//   @override
//   void initState() {
//     super.initState();
//     fetchDesignerDetails(widget.designerName);
//   }
//
//   Future<void> fetchDesignerDetails(String designerName) async {
//     // Using Uri.encodeComponent to handle names with spaces or special characters
//     final encodedName = Uri.encodeComponent(designerName);
//     final String url = 'https://stage.aashniandco.com/rest/V1/solr/designer?designer_name=$encodedName';
//
//     try {
//       HttpClient httpClient = HttpClient();
//       httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
//       IOClient ioClient = IOClient(httpClient);
//       final response = await ioClient.get(Uri.parse(url));
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data is List && data.length > 1 && data[1]['docs'] is List) {
//           List<dynamic> allProducts = data[1]['docs'];
//           List<dynamic> filteredProducts = allProducts.where((product) {
//             var price = product['actual_price_1'];
//             return price != null && (price is num && price > 0);
//           }).toList();
//
//           setState(() {
//             products = filteredProducts;
//             sortProducts(); // Apply initial sorting
//             isLoading = false;
//           });
//         } else {
//           throw Exception("Unexpected API response format");
//         }
//       } else {
//         throw Exception('Failed to load designer details: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Exception fetching designer details: $e');
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }
//
//   void sortProducts() {
//     // Always sort from the original 'products' list to ensure correctness
//     sortedProducts = List<dynamic>.from(products);
//
//     if (selectedSort == "High to Low") {
//       sortedProducts.sort((a, b) => (b['actual_price_1'] ?? 0).compareTo(a['actual_price_1'] ?? 0));
//     } else if (selectedSort == "Low to High") {
//       sortedProducts.sort((a, b) => (a['actual_price_1'] ?? 0).compareTo(b['actual_price_1'] ?? 0));
//     } else if (selectedSort == "Latest") {
//       // Sort by entity_id in descending order to get the latest products first
//       sortedProducts.sort((a, b) {
//         final idA = int.tryParse(a['entity_id']?.toString() ?? '0') ?? 0;
//         final idB = int.tryParse(b['entity_id']?.toString() ?? '0') ?? 0;
//         return idB.compareTo(idA);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.designerName),
//         backgroundColor: Colors.white,
//         elevation: 1.0,
//       ),
//       body: buildBody(),
//     );
//   }
//
//   Widget buildBody() {
//     if (isLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (sortedProducts.isEmpty) {
//       return const Center(child: Text("No products found"));
//     }
//
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Column(
//         children: [
//           // Header Row
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               // Text(
//               //   "${sortedProducts.length} Items",
//               //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//               // ),
//               Text(
//                ""
//               ),
//               Container(
//                 height: 35,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: DropdownButton<String>(
//                   value: selectedSort,
//                   icon: const Icon(Icons.sort, color: Colors.black),
//                   style: const TextStyle(color: Colors.white, fontSize: 14),
//                   dropdownColor: Colors.white,
//                   underline: Container(), // Hides the default underline
//                   onChanged: (value) {
//                     setState(() {
//                       selectedSort = value!;
//                       sortProducts();
//                     });
//                   },
//                   items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                     return DropdownMenuItem<String>(
//                       value: sortOption,
//                       child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//
//           // Product Grid
//           Expanded(
//             child: GridView.builder(
//               itemCount: sortedProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 final item = sortedProducts[index];
//                 return GestureDetector(
//                   onTap: () {
//                     print("Designer Data: ${jsonEncode(item)}");
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         // ProductDetailNewInDetailScreen(product: item.toJson()),
//                         builder: (context) => ProductDetailNewInDetailScreen(product: item),
//                       ),
//                     );
//                   },
//                   child: Card(
//                     color: Colors.white,
//                     elevation: 1,
//                     clipBehavior: Clip.antiAlias, // Ensures content respects card corners
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Product Image
//                         Flexible(
//                           child: Image.network(
//                             item['prod_small_img'] ?? item['prod_thumb_img'] ?? '',
//                             width: double.infinity,
//                             height: 550,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 width: double.infinity,
//                                 height: 550,
//                                 color: Colors.grey[300],
//                                 alignment: Alignment.center,
//                                 child: const Icon(Icons.image_not_supported, size: 50),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//
//                         // Designer Name
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Center(
//                             child: Text(
//                               item['designer_name'] ?? "Unknown",
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//
//                         // Short Description
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Center(
//                             child: Text(
//                               item['short_desc'] ?? "No description",
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(fontSize: 12),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//
//                         // Price
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Center(
//                             child: Text(
//                               "₹${(item['actual_price_1'] as num?)?.toStringAsFixed(0) ?? 'N/A'}",
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }