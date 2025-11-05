import 'dart:convert';
import 'dart:io';
import 'package:aashniandco/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../common/common_app_bar.dart';
import '../common/common_bottom_nav_bar.dart';
import 'auth/bloc/currency_bloc.dart';
import 'auth/bloc/currency_state.dart';
import 'newin/view/product_details_newin.dart';

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


class DesignerDetailScreen extends StatefulWidget {
  final String designerName;
  const DesignerDetailScreen({super.key, required this.designerName});

  @override
  _DesignerDetailScreenState createState() => _DesignerDetailScreenState();
}

class _DesignerDetailScreenState extends State<DesignerDetailScreen> {
  int? _totalProducts;
  bool isLoading = true;
  List<dynamic> products = [];
  String selectedSort = "Latest";

  final _scrollController = ScrollController();
  int _currentOffset = 0;
  final int _pageSize = 10;
  bool isFetchingMore = false;
  bool hasMoreData = true;

  bool _isNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    fetchDesignerDetails();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels >=
  //       _scrollController.position.maxScrollExtent - 200 &&
  //       !isFetchingMore &&
  //       hasMoreData) {
  //     fetchDesignerDetails(isPaginating: true);
  //   }
  // }

  void _onScroll() {
    // --- Navbar Visibility Logic ---
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse) { // User is scrolling down
      if (_isNavBarVisible) {
        setState(() => _isNavBarVisible = false);
      }
    } else if (direction == ScrollDirection.forward) { // User is scrolling up
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


  Future<void> _handleRefresh() async {
    setState(() {
      products.clear();
      _currentOffset = 0;
      hasMoreData = true;
      isLoading = true;
      _totalProducts = null;
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



  String _buildRequestBody() {
    const String fieldsToFetch =
        'designer_name,actual_price,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,prod_image_url,short_desc,actual_price_1';
    final String sortString = _getSolrSortString();
    //live*
    // final String filter = 'designer_name:"${widget.designerName}"';
    final String filter = 'designer_name:"${widget.designerName}" AND actual_price_1:[0.01 TO *]';
    final String solrQuery =
        "{!sort='$sortString' fl='$fieldsToFetch' rows='$_pageSize' start='$_currentOffset'}$filter";
    final Map<String, dynamic> requestBody = {
      "queryParams": {"query": solrQuery}
    };
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
          List<dynamic> newProducts = data[1]['docs'];
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
    final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
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
            CommonBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }


  Widget buildBody() {
    if (isLoading && products.isEmpty) {
      return _buildShimmerGrid();
    }

    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
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
      onRefresh: _handleRefresh,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSortHeader(),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                controller: _scrollController,
                itemCount: products.length + (isFetchingMore ? 1 : 0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (context, index) {
                  if (index == products.length) {
                    // shimmer placeholder instead of circular loader
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
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
                _handleRefresh();
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

  Widget _buildProductCard(Map<String, dynamic> item) {
    final currencyState = context.watch<CurrencyBloc>().state;

    String displaySymbol = '₹';
    double basePrice = (item['actual_price_1'] as num?)?.toDouble() ?? 0.0;
    double displayPrice = basePrice;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      displayPrice = basePrice * currencyState.selectedRate.rate;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailNewInDetailScreen(product: item),
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
              item['prod_image_url'] ?? item['prod_small_img'] ?? '',
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['designer_name'] ?? "Unknown",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['short_desc'] ?? "No description",
                      textAlign: TextAlign.center,
                      style:
                      const TextStyle(fontSize: 12, color: Colors.black),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "$displaySymbol${displayPrice.toStringAsFixed(0)}",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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