import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/search/data/repositories/search_repository.dart';
import 'package:aashniandco/features/search/presentation/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/common_app_bar.dart';
import '../../../common/common_bottom_nav_bar.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../categories/bloc/filtered_products_bloc.dart';
import '../../categories/bloc/filtered_products_state.dart';
import '../../categories/repository/api_service.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/product_details_newin.dart';
import '../data/models/product_model.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';
// Import your other necessary files
// import 'package:your_app/services/api_service.dart';
// import 'package:your_app/models/product_model.dart';

class ProductListingScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ProductListingScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We provide the FilteredProductsBloc here. Its lifecycle is tied to this screen.
    return BlocProvider(
      create: (context) => FilteredProductsBloc()
      // ✅ This is the crucial part. As soon as the screen is built,
      // we dispatch the event to fetch products for the given categoryId.
        ..add(FetchFilteredProducts(
          selectedFilters: [
            {'type': 'categories', 'id': categoryId}
          ],
          sortOrder: 'Latest', // Your desired default sort
          page: 0,
        )),
      child: CategoryProductView(
        categoryName: categoryName,
        // We can pass the categoryId down if needed for other features like filtering
        categoryId: categoryId,
      ),
    );
  }
}

// This is the view part, adapted from your MenuCategoriesView
class CategoryProductView extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryProductView({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryProductView> createState() => _CategoryProductViewState();
}

class _CategoryProductViewState extends State<CategoryProductView> {
  final _scrollController = ScrollController();
  String _selectedSort = "Latest";

  bool _isNavBarVisible = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      // To prevent fetching multiple times, we check the current state
      final currentState = context.read<FilteredProductsBloc>().state;
      if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
        context.read<FilteredProductsBloc>().add(FetchFilteredProducts(
          selectedFilters: [{'type': 'categories', 'id': widget.categoryId}],
          sortOrder: _selectedSort,
          page: currentState.products.length ~/ 10, // Calculate next page
        ));
      }
    }
  }


  // void _onScroll() {
  //   // --- Navbar Visibility Logic ---
  //   final direction = _scrollController.position.userScrollDirection;
  //   if (direction == ScrollDirection.reverse) { // User is scrolling down
  //     if (_isNavBarVisible) {
  //       setState(() => _isNavBarVisible = false);
  //     }
  //   } else if (direction == ScrollDirection.forward) { // User is scrolling up
  //     if (!_isNavBarVisible) {
  //       setState(() => _isNavBarVisible = true);
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        // This is a detail screen, so it needs a back button.
        automaticallyImplyLeading: true,
        titleWidget: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          _buildSortHeader(),
          const SizedBox(height: 10),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      // We can add the filter FAB later
      // floatingActionButton: _buildFilterFab(),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        // Animate the height to show/hide the navbar
        height: _isNavBarVisible ? navBarHeight : 0,
        // Use a Wrap to prevent layout errors during animation
        child: Wrap(
          children: const [
            // Use a neutral index like 3 (Wishlist) so a main tab isn't highlighted
            CommonBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSortHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
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
              value: _selectedSort,
              icon: const Icon(Icons.sort, color: Colors.black),
              underline: Container(),
              onChanged: (value) {
                if (value != null && value != _selectedSort) {
                  setState(() => _selectedSort = value);
                  context.read<FilteredProductsBloc>().add(
                    FetchFilteredProducts(
                      selectedFilters: [{'type': 'categories', 'id': widget.categoryId}],
                      sortOrder: _selectedSort,
                      page: 0, // Reset to first page on sort change
                    ),
                  );
                }
              },
              items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
                return DropdownMenuItem<String>(
                  value: sortOption,
                  child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
// in _CategoryProductViewState's _buildProductGrid method

  Widget _buildProductGrid() {
    return BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
      builder: (context, state) {
        if (state is FilteredProductsLoading) {
          // Show shimmer effect on initial load
          return const ProductGridShimmer();
        }
        if (state is FilteredProductsError) {
          return Center(child: Text('Failed to fetch products: ${state.message}'));
        }
        if (state is FilteredProductsLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text("No products found."));
          }
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: state.hasReachedEnd
                ? state.products.length
                : state.products.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.5,
            ),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return ProductGridTile(product: state.products[index]);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  // Widget _buildProductGrid() {
  //   return BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
  //     builder: (context, state) {
  //       if (state is FilteredProductsLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //       if (state is FilteredProductsError) {
  //         return Center(child: Text('Failed to fetch products: ${state.message}'));
  //       }
  //       if (state is FilteredProductsLoaded) {
  //         if (state.products.isEmpty) {
  //           return const Center(child: Text("No products found."));
  //         }
  //         return GridView.builder(
  //           controller: _scrollController,
  //           padding: const EdgeInsets.symmetric(horizontal: 8.0),
  //           itemCount: state.hasReachedEnd
  //               ? state.products.length
  //               : state.products.length + 1, // +1 for loading indicator
  //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //             crossAxisCount: 2,
  //             crossAxisSpacing: 10,
  //             mainAxisSpacing: 10,
  //             childAspectRatio: 0.5, // Adjust to your product tile's aspect ratio
  //           ),
  //           itemBuilder: (context, index) {
  //             if (index >= state.products.length) {
  //               return const Center(child: CircularProgressIndicator());
  //             }
  //             // Replace with your actual ProductGridTile widget
  //             return ProductGridTile(product: state.products[index]);
  //           },
  //         );
  //       }
  //       return const SizedBox.shrink(); // Default empty state
  //     },
  //   );
  // }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: 10, // Display 10 shimmer placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.5,
        ),
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 16,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 14,
                    width: 150,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 16,
                    width: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}
class ProductGridTile extends StatelessWidget {
  const ProductGridTile({
    Key? key,
    required this.product,
  }) : super(key: key);

  final Product product;

  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;

    // --- 3. PREPARE DISPLAY VARIABLES WITH DEFAULTS ---
    String displaySymbol = '₹'; // Default to Rupee
    double displayPrice = product.actualPrice; // Default to the base price

    // --- 4. IF CURRENCY IS LOADED, APPLY CONVERSION ---
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      final rate = currencyState.selectedRate.rate;

      // Calculate the price in the selected currency.
      // The base price from your API (actualPrice) is always in INR.
      displayPrice = product.actualPrice * (rate > 0 ? rate : 1.0);
    }

    return GestureDetector(
      onTap: () {
        // This navigation logic is correct. It converts the Product model
        // back to the Map<String, dynamic> format the detail screen expects.
        final productData = {
          'prod_sku': product.prod_sku,
          'designer_name': product.designerName,
          'short_desc': product.shortDesc,
          'prod_small_img': product.prodSmallImg,
          'actual_price_1': product.actualPrice,
          'prod_desc': product.prodDesc,
          'child_delivery_time': product.deliveryTime,
          'size_name': product.sizeList,
          // ⚠️ IMPORTANT: Ensure your 'Product' model has these fields.
          // I'm assuming the property names are 'patternsName', 'genderName', etc.
          // Please adjust if your model uses different names.
          'patterns_name': product.patterns_name,
          'gender_name': product.gender_name,
          'kid_name': product.kid_name,
        };
        // final productData = {
        //   'prod_sku': product.prod_sku,
        //   'designer_name': product.designerName,
        //   'short_desc': product.shortDesc,
        //   'prod_small_img': product.prodSmallImg,
        //   'actual_price_1': product.actualPrice,
        //   'prod_desc': product.prodDesc,
        //   'child_delivery_time': product.deliveryTime,
        //   'size_name': product.sizeList,
        // };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailNewInDetailScreen(product: productData),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Enhanced Image Section ---
            Flexible(
              child: CachedNetworkImage(
                imageUrl: product.prodSmallImg,
                width: double.infinity,
                fit: BoxFit.cover,
                // A more detailed placeholder that shows loading progress, like the reference
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
                  ),
                ),
                // A more informative error widget, like the reference
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // --- 2. Centered & Styled Text Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  product.designerName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  product.shortDesc,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: Text(
                  '$displaySymbol${displayPrice.toStringAsFixed(0)}',
                  // '₹${product.actualPrice.toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//11/8/2025
// its the whole screen same as productlist screen
// class ProductGridTile extends StatelessWidget {
//   const ProductGridTile({
//     Key? key,
//     required this.product,
//   }) : super(key: key);
//
//   final Product product;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         final productData = {
//           'prod_sku': product.prod_sku,
//           'designer_name': product.designerName,
//           'short_desc': product.shortDesc,
//           'prod_small_img': product.prodSmallImg,
//           'actual_price_1': product.actualPrice,
//           'prod_desc': product.prodDesc,
//           'child_delivery_time': product.deliveryTime,
//           'size_name': product.sizeList,
//         };
//
//         // ✅ PRINT THE ENTIRE MAP
//         print("Navigating with product data: $productData");
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailNewInDetailScreen(
//               product: productData,
//             ),
//           ),
//         );
//       },
//       // onTap: () {
//       //   // ✅ NEW: Navigation logic
//       //   print('Tapped on product: ${product.designerName}');
//       //
//       //   // IMPORTANT: The `autosuggest` API often returns incomplete product data.
//       //   // You will likely need to make another API call on the detail screen
//       //   // using the product's SKU or URL to get the full details (like all sizes).
//       //   // For now, we pass the data we have.
//       //
//       //   Navigator.push(
//       //     context,
//       //     MaterialPageRoute(
//       //       // Navigate to your existing Product Detail Screen
//       //       builder: (_) => ProductDetailNewInDetailScreen(
//       //         // You need to convert your simplified `Product` model
//       //         // back into the Map<String, dynamic> format that the
//       //         // detail screen expects.
//       //         product: {
//       //           'prod_sku': product.prod_sku,
//       //           'designer_name': product.designerName,
//       //           'short_desc': product.shortDesc,
//       //           'prod_small_img': product.prodSmallImg,
//       //           'actual_price_1': product.actualPrice,
//       //           // Add any other fields the detail screen requires, even if they are empty
//       //           'prod_desc': product.prodDesc,
//       //           'child_delivery_time': product.deliveryTime,
//       //           'size_name': product.sizeList, // Start with an empty list of sizes
//       //         },
//       //       ),
//       //     ),
//       //   );
//       // },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Card(
//               margin: EdgeInsets.zero,
//               clipBehavior: Clip.antiAlias,
//               elevation: 0,
//               child: CachedNetworkImage(
//                 imageUrl: product.prodSmallImg,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(color: Colors.grey[200]),
//                 errorWidget: (context, url, error) => Container(
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.error_outline, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.designerName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   product.shortDesc,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[700],
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   // Price is already a formatted String
//                   '₹${product.actualPrice.toStringAsFixed(0)}',
//                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class ProductListingScreen extends StatefulWidget {
//   final String? searchQuery;
//   final String? categoryUrl;
//
//   const ProductListingScreen({
//     Key? key,
//     this.searchQuery,
//     this.categoryUrl,
//   }) : super(key: key);
//
//   @override
//   // This line connects the StatefulWidget to its State class
//   _ProductListingScreenState createState() => _ProductListingScreenState();
// }
//
// class _ProductListingScreenState extends State<ProductListingScreen> {
//   late Future<SearchResults> _productFuture;
//   // ✅ Use your actual repository
//   final SearchRepository _searchRepository = SearchRepository();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProducts();
//     });
//   }
//
// // inside class _ProductListingScreenState
//
// // inside class _ProductListingScreenState
//
//   Future<String> _getCategoryIdFromUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//       if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//
//       print('Fetching category ID for url_key: $urlKey');
//       final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//
//       HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//       final response = await ioClient.get(endpoint);
//
//       if (response.statusCode == 200) {
//         // ✅ --- START OF THE DOUBLE-DECODE FIX ---
//
//         // 1. First decode: This turns the outer JSON `[...]` into a Dart List.
//         final dynamic decodedResponse = json.decode(response.body);
//
//         // 2. Safety Check: Ensure we have a non-empty list and its first item is a String.
//         if (decodedResponse is List && decodedResponse.isNotEmpty && decodedResponse[0] is String) {
//
//           // 3. Extract the string that contains the inner JSON.
//           final String innerJsonString = decodedResponse[0];
//
//           // 4. Second decode: This parses the inner JSON string into the Map we need.
//           final Map<String, dynamic> categoryData = json.decode(innerJsonString);
//
//           final dynamic categoryId = categoryData['cat_id'];
//
//           if (categoryId != null) {
//             print('Successfully fetched category ID: $categoryId');
//             return categoryId.toString();
//           } else {
//             throw Exception('Inner JSON object did not contain a "cat_id".');
//           }
//         } else {
//           throw Exception('API did not return the expected data structure (a list containing a JSON string).');
//         }
//         // ✅ --- END OF THE DOUBLE-DECODE FIX ---
//
//       } else if (response.statusCode == 404) {
//         final errorData = json.decode(response.body);
//         throw Exception('Category not found: ${errorData['message']}');
//       }
//       else {
//         throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error in _getCategoryIdFromUrl: $e");
//       rethrow;
//     }
//   }
//   // Future<String> _getCategoryIdFromUrl(String url) async {
//   //   try {
//   //     final uri = Uri.parse(url);
//   //     final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//   //     if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//   //
//   //     print('Fetching category ID for url_key: $urlKey');
//   //     final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//   //
//   //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //     final response = await ioClient.get(endpoint);
//   //
//   //     if (response.statusCode == 200) {
//   //       // Decode the response body
//   //       final decodedResponse = json.decode(response.body);
//   //
//   //       // ✅ --- START OF FIX ---
//   //       // Check if the decoded response is a List and is not empty
//   //       if (decodedResponse is List && decodedResponse.isNotEmpty) {
//   //
//   //         // Access the first element of the list, which should be the map we want
//   //         final Map<String, dynamic> categoryData = decodedResponse[0];
//   //         final categoryId = categoryData['cat_id'];
//   //
//   //         if (categoryId != null) {
//   //           print('Successfully fetched category ID: $categoryId');
//   //           return categoryId.toString();
//   //         } else {
//   //           throw Exception('API response list did not contain an object with "cat_id".');
//   //         }
//   //       } else {
//   //         // Handle the case where the list is empty or not a list
//   //         throw Exception('API did not return a valid category data list.');
//   //       }
//   //       // ✅ --- END OF FIX ---
//   //
//   //     } else {
//   //       throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print("Error in _getCategoryIdFromUrl: $e");
//   //     rethrow;
//   //   }
//   // }
//   // Future<String> _getCategoryIdFromUrl(String url) async {
//   //   try {
//   //     final uri = Uri.parse(url);
//   //     final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//   //     if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//   //
//   //     print('Fetching category ID for url_key: $urlKey');
//   //     final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//   //
//   //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //     final response = await ioClient.get(endpoint);
//   //
//   //     if (response.statusCode == 200) {
//   //       final categoryData = json.decode(response.body);
//   //       final categoryId = categoryData['cat_id'];
//   //       if (categoryId != null) {
//   //         print('Successfully fetched category ID: $categoryId');
//   //         return categoryId.toString();
//   //       } else {
//   //         throw Exception('API response did not contain a "cat_id".');
//   //       }
//   //     } else {
//   //       throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print("Error in _getCategoryIdFromUrl: $e");
//   //     rethrow;
//   //   }
//   // }
//
//   void _loadProducts() {
//     setState(() {
//       if (widget.categoryUrl != null && widget.categoryUrl!.isNotEmpty) {
//         // Case 1: Navigated from a category click
//         // Get the ID first, then call the repository method with the categoryId
//         _productFuture = _getCategoryIdFromUrl(widget.categoryUrl!)
//             .then((categoryId) => _searchRepository.fetchProductsByCategory(categoryId: categoryId));
//       } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
//         // Case 2: Navigated from "View all results"
//         // Call the repository method directly with the searchQuery
//         _productFuture = _searchRepository.fetchProductsByCategory(searchQuery: widget.searchQuery!);
//       } else {
//         // Fallback case
//         _productFuture = Future.error("No search query or category was provided.");
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String appBarTitle = widget.searchQuery != null && widget.searchQuery!.isNotEmpty
//         ? 'Results for "${widget.searchQuery}"'
//         : 'Products';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appBarTitle),
//       ),
//       body: FutureBuilder<SearchResults>(
//         future: _productFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${snapshot.error}')));
//           }
//           if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
//             return const Center(child: Text('No products found.'));
//           }
//           final products = snapshot.data!.products;
//           return GridView.builder(
//             padding: const EdgeInsets.all(8.0),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.65,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               return ProductGridTile(product: products[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }