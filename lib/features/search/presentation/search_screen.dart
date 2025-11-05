import 'package:aashniandco/features/search/presentation/product_list_screennew.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:aashniandco/features/search/data/models/product_model.dart';
import '../../categories/model/api_response.dart';
import '../../categories/repository/api_service.dart';
import '../../newin/view/product_details_newin.dart';
import '../bloc/category_metadata_bloc.dart';
import '../bloc/category_metadata_event.dart';
import '../bloc/category_metadata_state.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import 'package:path/path.dart' as p;
import '../data/models/search_category_model.dart';
import 'package:collection/collection.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart'; // ✅ For groupBy function

// Import all your BLoC and Model files
import '../bloc/search_bloc.dart';

import '../data/models/search_category_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Import all your BLoC and Model files
import '../bloc/search_bloc.dart';

import '../data/models/search_category_model.dart';
import 'package:aashniandco/features/search/data/models/product_model.dart';

import 'full_search_result.dart';

// Note: 'package:collection/collection.dart' is no longer needed.

// class SearchScreen1 extends StatefulWidget {
//   const SearchScreen1({Key? key}) : super(key: key);
//
//   @override
//   State<SearchScreen1> createState() => _SearchScreen1State();
// }
//
// class _SearchScreen1State extends State<SearchScreen1> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     context.read<SearchBloc>().add(SearchQueryChanged(_searchController.text));
//   }
//
//   void _clearSearch() {
//     _searchController.clear();
//     context.read<SearchBloc>().add(const SearchCleared());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Search for products, designers...',
//             border: InputBorder.none,
//             hintStyle: const TextStyle(color: Colors.grey),
//           ),
//           style: const TextStyle(color: Colors.black, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.clear, color: Colors.black),
//             onPressed: _clearSearch,
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: BlocBuilder<SearchBloc, SearchState>(
//         builder: (context, state) {
//           if (state is SearchLoading) {
//             return const Center(child: LinearProgressIndicator(color: Colors.black54));
//           }
//           if (state is SearchFailure) {
//             return Center(child: Text('An error occurred: ${state.error}'));
//           }
//           if (state is SearchSuccess) {
//             if (state.results.categories.isEmpty && state.results.products.isEmpty) {
//               return const Center(child: Text('No results found.'));
//             }
//
//             // --- ❌ REMOVED THE groupBy LOGIC ---
//
//             return ListView(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               children: [
//                 // --- CATEGORIES SECTION (Stays the same) ---
//                 if (state.results.categories.isNotEmpty)
//                   _buildSectionTitle('CATEGORIES'),
//                 if (state.results.categories.isNotEmpty)
//                   ...state.results.categories.map((category) {
//                     return CategoryListTile(category: category);
//                   }).toList(),
//
//                 // Divider (Stays the same)
//                 if (state.results.categories.isNotEmpty && state.results.products.isNotEmpty)
//                   const Divider(height: 32, indent: 16, endIndent: 16),
//
//                 // --- ✅ REVERTED TO A SINGLE PRODUCT LIST SECTION ---
//                 if (state.results.products.isNotEmpty)
//                 // Use a Column to hold the title and the list
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // The image doesn't show a "PRODUCTS" title, so we can omit it
//                       // or add it back if you want it:
//                       // _buildSectionTitle('PRODUCTS'),
//                       _buildHorizontalProductList(state.results.products), // Pass the full list of products
//                     ],
//                   ),
//
//                 const SizedBox(height: 24),
//
//                 // --- VIEW ALL RESULTS BUTTON (Stays the same) ---
//                 if (state.results.products.isNotEmpty)
//                   Center(
//                     child: TextButton(
//                       onPressed: () {
//                         print('View all results for ${_searchController.text}');
//                       },
//                       child: const Text(
//                         'View all results',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             );
//           }
//           // Initial state
//           return const Center(
//             child: Text(
//               'Start typing to search for products.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           );
//         },
//       ),
//     );
//   }


class SearchScreen1 extends StatefulWidget {
  const SearchScreen1({Key? key}) : super(key: key);

  @override
  State<SearchScreen1> createState() => _SearchScreen1State();
}

class _SearchScreen1State extends State<SearchScreen1> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Assuming SearchBloc is provided higher up the widget tree
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    context.read<SearchBloc>().add(SearchQueryChanged(_searchController.text));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const SearchCleared());
  }

  // ✅ 1. ADD THIS NEW METHOD TO HANDLE THE API CALL AND NAVIGATION
  Future<void> _navigateToProductDetails(Product1 product) async {
    // First, check if there's a valid SKU to fetch
    if (product.sku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product details are not available.')),
      );
      return;
    }

    // Show a loading dialog to the user
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Get an instance of your ApiService from the context
      final apiService = RepositoryProvider.of<ApiService>(context);

      // Call the API method to get the complete, detailed product data
      final Map<String, dynamic> fullProductData = await apiService.fetchProductDetailsBySku(product.sku);

      // If the call is successful, dismiss the loading dialog
      Navigator.of(context).pop(); // IMPORTANT: use the dialog's context

      // Now navigate to the detail screen, passing the FULL data
      Navigator.push(
        context, // Use the screen's main context for navigation
        MaterialPageRoute(
          builder: (_) => ProductDetailNewInDetailScreen(
            product: fullProductData,
          ),
        ),
      );
    } catch (e) {
      // If the API call fails, dismiss the loading dialog
      Navigator.of(context).pop();

      // And show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ STEP 1: Provide the CategoryMetadataBloc
    // We provide it here so this screen can listen to its state changes.
    // It gets its ApiService dependency from a RepositoryProvider, which is standard practice.
    return BlocProvider(
      create: (context) => CategoryMetadataBloc(
        apiService: RepositoryProvider.of<ApiService>(context),
      ),
      child: Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Search for products, designers...',
              border: InputBorder.none,
              hintStyle: TextStyle(color: Colors.grey),
            ),
            style: const TextStyle(color: Colors.black, fontSize: 16),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.black),
              onPressed: _clearSearch,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        // ✅ STEP 2: Add a BlocListener for CategoryMetadataBloc
        // This listens for state changes and performs one-time actions like navigation.
        // It's wrapped around the main body content.
        body: BlocListener<CategoryMetadataBloc, CategoryMetadataState>(
          listener: (context, state) {
            // This listener will react to events dispatched from CategoryListTile
            if (state is CategoryMetadataLoading) {
              // Show a loading indicator while the API call is in progress
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );
            }
            if (state is CategoryMetadataLoadSuccess) {
              Navigator.of(context, rootNavigator: true).pop(); // Dismiss the loading dialog

              final String categoryId = state.metadata['pare_cat_id'];
              final String categoryName = state.metadata['cat_name'];

              print('NAVIGATION TRIGGERED BY BLOC: ID: $categoryId, Name: $categoryName');
              // Navigate to the ProductListingScreen with the fetched data
              Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => ProductListingScreen(
                  categoryId: categoryId,
                  categoryName: categoryName,
                ),
              ));
            }
            if (state is CategoryMetadataLoadFailure) {
              Navigator.of(context, rootNavigator: true).pop(); // Dismiss the loading dialog

              // Show an error message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text('Error: ${state.error}'),
                ),
              );
            }
          },
          // The rest of your UI is the child of the listener.
          // It will now listen to the SearchBloc to build itself.
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoading) {
                return const Center(child: LinearProgressIndicator(color: Colors.black54));
              }
              if (state is SearchFailure) {
                return Center(child: Text('An error occurred: ${state.error}'));
              }
              if (state is SearchSuccess) {
                if (state.results.categories.isEmpty && state.results.products.isEmpty) {
                  return const Center(child: Text('No results found.'));
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: [
                    if (state.results.categories.isNotEmpty)
                      _buildSectionTitle('CATEGORIES'),
                    if (state.results.categories.isNotEmpty)
                      ...state.results.categories.map((category) {
                        // ✅ STEP 3: The CategoryListTile now works perfectly here.
                        // When tapped, it will find the CategoryMetadataBloc provided
                        // above and dispatch its event. The BlocListener will catch the result.
                        return CategoryListTile(category: category);
                      }).toList(),

                    if (state.results.categories.isNotEmpty && state.results.products.isNotEmpty)
                      const Divider(height: 32, indent: 16, endIndent: 16),

                    if (state.results.products.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHorizontalProductList(state.results.products),
                        ],
                      ),

                    const SizedBox(height: 24),
              if (state.results.products.isNotEmpty)
              Center(
              child: TextButton(
              // ✅ THIS IS THE NEW LOGIC
              onPressed: () {
              // 1. Get the current search text directly from the controller.
              final String searchText = _searchController.text.trim();

              // 2. Safety check: make sure the search text is not empty.
              if (searchText.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please enter a search term.')),
              );
              return;
              }

              print('--- "View all results" Tapped ---');
              print('Using search text as the category name: "$searchText"');

              // 3. Dispatch the event to the CategoryMetadataBloc,
              //    passing the user's search text as the category name/slug.
              //    Your `fetchCategoryMetadataByName` service method will handle
              //    turning this into the correct URL key.
              context.read<CategoryMetadataBloc>().add(
              FetchCategoryMetadata(categorySlug: searchText),
              );
              },
              child: const Text('View all results', style: TextStyle(color: Colors.black, fontSize: 15)),
              ),
              ),
                  ],
                );
              }
              return const Center(
                child: Text('Start typing to search for products.', style: TextStyle(color: Colors.grey)),
              );
            },
          ),
        ),
      ),
    );
  }
  // Helper widget for section titles
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  // Helper widget for the horizontal product list
  Widget _buildHorizontalProductList(List<Product1> products) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: products.length > 4 ? 4 : products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          print('--- PARSED PRODUCT DATA FOR WIDGET ---');
          print(product.toJson());// Get the product for this tile
          return SizedBox(
            width: 140,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              // Pass the new handler method to the tile's onTap property
              child: ProductGridTile1(
                product: product,
                // ✅ THE FIX IS HERE: Add the 'onTap' parameter
                onTap: () => _navigateToProductDetails(product),
              ),
            ),
          );
        },
      ),
    );
  }

}

// WIDGET FOR A CATEGORY TILE
class CategoryListTile extends StatelessWidget {
  const CategoryListTile({Key? key, required this.category}) : super(key: key);
  final SearchCategory category;

  @override
  Widget build(BuildContext context) {
    final parts = category.fullPath.split('/');
    final lastPart = parts.isNotEmpty ? parts.removeLast().trim() : '';
    final firstPart = parts.join(' / ').trim();

    return ListTile(
      // onTap: () {
      //   // --- THIS IS THE CORRECT NAVIGATION LOGIC ---
      //
      //   print('Tapped on category: ${category.fullPath}');
      //   print('Navigating with URL: ${category.url}');

      onTap: () {
        print('Tapped on category: ${category.fullPath}');
        print('Navigating with URL: ${category.url}');

        // 1. Parse the URL
        final uri = Uri.parse(category.url);
        final extractedSlug = p.basenameWithoutExtension(uri.path);
        // 2. Get the last segment of the path (e.g., "anarkalis-kurtas.html")
        print('Dispatching FetchCategoryMetadata event with slug: $extractedSlug');

        context.read<CategoryMetadataBloc>().add(
          FetchCategoryMetadata(categorySlug: extractedSlug),
        );

        // Navigate to the ProductListingScreen, passing the category's URL.
        // The ProductListingScreen is already set up to handle this parameter.
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => ProductListingScreen(
        //       categoryUrl: category.url,
        //     ),
        //   ),
        // );
        // --- END OF CORRECT LOGIC ---
      },
      title: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 16, color: Colors.black),
          children: [
            if (firstPart.isNotEmpty)
              TextSpan(text: '$firstPart / '),
            TextSpan(
              text: lastPart,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductGridTile1 extends StatelessWidget {
  const ProductGridTile1({
    Key? key,
    required this.product,
    required this.onTap, // ✅ 1. ADD a required onTap callback
  }) : super(key: key);

  final Product1 product;
  final VoidCallback onTap; // ✅ 2. DECLARE the callback property

  @override
  Widget build(BuildContext context) {
    // ✅ 3. The GestureDetector now simply calls the provided onTap callback.
    //    All navigation logic has been removed from this widget.
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              elevation: 0,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl.isNotEmpty
                    ? product.imageUrl
                    : 'https://aashniandco.com/pub/static/frontend/_view/en_US/Magento_Catalog/images/product/placeholder.png',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.error_outline, color: Colors.grey),
                ),
              )


              ,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.designerName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  product.description, // Using productName for the second line
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  product.price,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// class ProductGridTile1 extends StatelessWidget {
//   const ProductGridTile1({
//     Key? key,
//     required this.product,
//   }) : super(key: key);
//
//   final Product1 product;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         // ✅ NEW: Navigation logic
//         print('Tapped on product: ${product.designerName}');
//         print('Navigating with Product SKU: "${product.sku}"');
//
//         print('Navigating with Product SKU: "${product.sizeList}"');
//         // IMPORTANT: The `autosuggest` API often returns incomplete product data.
//         // You will likely need to make another API call on the detail screen
//         // using the product's SKU or URL to get the full details (like all sizes).
//         // For now, we pass the data we have.
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             // Navigate to your existing Product Detail Screen
//             builder: (_) => ProductDetailNewInDetailScreen(
//               // You need to convert your simplified `Product` model
//               // back into the Map<String, dynamic> format that the
//               // detail screen expects.
//
//               product: product.toJson(),
//               // product: {
//               //   'prod_sku': product.sku,
//               //   'designer_name': product.designerName,
//               //   'short_desc': product.description,
//               //   'prod_small_img': product.imageUrl,
//               //   'actual_price_1': double.tryParse(product.price.replaceAll('₹', '')) ?? product.price,
//               //   // Add any other fields the detail screen requires, even if they are empty
//               //   'prod_desc': product.description,
//               //   'child_delivery_time': product.deliveryTime.isNotEmpty ? product.deliveryTime.first : null,
//               //   'size_name': product.sizeList, // Start with an empty list of sizes
//               // },
//             ),
//           ),
//         );
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Card(
//               margin: EdgeInsets.zero,
//               clipBehavior: Clip.antiAlias,
//               elevation: 0,
//               child: CachedNetworkImage(
//                 imageUrl: product.imageUrl,
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
//                   product.designerName,
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
//                   product.price as String,
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
// class CategoryListTile extends StatelessWidget {
//   const CategoryListTile({Key? key, required this.category}) : super(key: key);
//   final SearchCategory category;
//
//   @override
//   Widget build(BuildContext context) {
//     // final parts = category.label.split('/');
//     // final lastPart = parts.isNotEmpty ? parts.removeLast().trim() : '';
//     // final firstPart = parts.join(' / ').trim();
//     final parts = category.fullPath.split('/');
//     final lastPart = parts.isNotEmpty ? parts.removeLast().trim() : '';
//     final firstPart = parts.join(' / ').trim();
//
//     return ListTile(
//       onTap: () {
//         print('Tapped on category: ${category.fullPath}');
//       },
//       title: RichText(
//         text: TextSpan(
//           style: const TextStyle(fontSize: 16, color: Colors.black),
//           children: [
//             if (firstPart.isNotEmpty)
//               TextSpan(text: '$firstPart / '),
//             TextSpan(
//               text: lastPart,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// WIDGET FOR A PRODUCT TILE IN THE GRID/HORIZONTAL LIST
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
//         onTap: () {
//           // ✅ NEW: Navigation logic
//           print('Tapped on product: ${product.productName}');
//
//           // IMPORTANT: The `autosuggest` API often returns incomplete product data.
//           // You will likely need to make another API call on the detail screen
//           // using the product's SKU or URL to get the full details (like all sizes).
//           // For now, we pass the data we have.
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               // Navigate to your existing Product Detail Screen
//               builder: (_) => ProductDetailNewInDetailScreen(
//                 // You need to convert your simplified `Product` model
//                 // back into the Map<String, dynamic> format that the
//                 // detail screen expects.
//                 product: {
//                   'prod_sku': product.sku,
//                   'designer_name': product.designerName,
//                   'short_desc': product.productName,
//                   'prod_small_img': product.imageUrl,
//                   'actual_price_1': product.price.replaceAll('₹', '').replaceAll(',', ''), // Clean the price
//                   // Add any other fields the detail screen requires, even if they are empty
//                   'prod_desc': '',
//                   'child_delivery_time': '',
//                   'size_name': [], // Start with an empty list of sizes
//                 },
//               ),
//             ),
//           );
//         },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Card(
//               margin: EdgeInsets.zero,
//               clipBehavior: Clip.antiAlias,
//               elevation: 0,
//               child: CachedNetworkImage(
//                 imageUrl: product.imageUrl,
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
//                   product.productName,
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
//                   product.price,
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

// class SearchScreen1 extends StatefulWidget {
//   const SearchScreen1({Key? key}) : super(key: key);
//
//   @override
//   State<SearchScreen1> createState() => _SearchScreen1State();
// }
//
// class _SearchScreen1State extends State<SearchScreen1> {
//   final TextEditingController _searchController = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _searchController.addListener(_onSearchChanged);
//   }
//
//   @override
//   void dispose() {
//     _searchController.removeListener(_onSearchChanged);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   void _onSearchChanged() {
//     // Add the event to the BLoC every time the text changes
//     context.read<SearchBloc>().add(SearchQueryChanged(_searchController.text));
//   }
//
//   void _clearSearch() {
//     _searchController.clear();
//     context.read<SearchBloc>().add(const SearchCleared());
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 1,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: TextField(
//           controller: _searchController,
//           autofocus: true,
//           decoration: InputDecoration(
//             hintText: 'Search for products, designers...',
//             border: InputBorder.none,
//             hintStyle: const TextStyle(color: Colors.grey),
//           ),
//           style: const TextStyle(color: Colors.black, fontSize: 16),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.clear, color: Colors.black),
//             onPressed: _clearSearch,
//           ),
//         ],
//       ),
//       backgroundColor: Colors.white,
//       body: BlocBuilder<SearchBloc, SearchState>(
//         builder: (context, state) {
//           if (state is SearchLoading) {
//             return const Center(child: LinearProgressIndicator(color: Colors.black54));
//           }
//           if (state is SearchFailure) {
//             return Center(child: Text('An error occurred: ${state.error}'));
//           }
//           if (state is SearchSuccess) {
//             // Check if there are no results at all
//             if (state.results.categories.isEmpty && state.results.products.isEmpty) {
//               return const Center(child: Text('No results found.'));
//             }
//
//             // --- ✅ NEW LOGIC: GROUP PRODUCTS BY CATEGORY PATH ---
//             final groupedProducts = groupBy(
//               state.results.products,
//                   (Product product) => product.categoryPath,
//             );
//
//             return ListView(
//               padding: const EdgeInsets.symmetric(vertical: 16.0),
//               children: [
//                 // --- CATEGORIES SECTION (from API filters) ---
//                 if (state.results.categories.isNotEmpty)
//                   _buildSectionTitle('CATEGORIES'),
//                 if (state.results.categories.isNotEmpty)
//                   ...state.results.categories.map((category) {
//                     return CategoryListTile(category: category);
//                   }).toList(),
//
//                 // Divider
//                 if (state.results.categories.isNotEmpty && state.results.products.isNotEmpty)
//                   const Divider(height: 32, indent: 16, endIndent: 16),
//
//                 // --- PRODUCTS SECTION (Now built from grouped data) ---
//                 if (state.results.products.isNotEmpty)
//                 // Loop through each group (Key = categoryPath, Value = List<Product>)
//                   ...groupedProducts.entries.map((entry) {
//                     final categoryPath = entry.key;
//                     final productsInGroup = entry.value;
//
//                     // Return a Column containing the title and the horizontal list
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Only show a title if the path is not empty
//                         if (categoryPath.isNotEmpty)
//                           _buildSectionTitle(categoryPath.toUpperCase()),
//
//                         // The horizontal list for this specific group
//                         _buildHorizontalProductList(productsInGroup),
//
//                         const SizedBox(height: 16), // Space between groups
//                       ],
//                     );
//                   }).toList(),
//
//                 const SizedBox(height: 8),
//
//                 // --- VIEW ALL RESULTS BUTTON ---
//                 Center(
//                   child: TextButton(
//                     onPressed: () {
//                       print('View all results for ${_searchController.text}');
//                       // TODO: Navigate to the full product listing page with the search query
//                     },
//                     child: const Text(
//                       'View all results',
//                       style: TextStyle(
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             );
//           }
//           // Initial state
//           return const Center(
//             child: Text(
//               'Start typing to search for products.',
//               style: TextStyle(color: Colors.grey),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // Helper widget for section titles
//   Widget _buildSectionTitle(String title) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
//       child: Text(
//         title,
//         style: const TextStyle(
//           color: Colors.black,
//           fontWeight: FontWeight.bold,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
//
//   // Helper widget for the horizontal product list
//   Widget _buildHorizontalProductList(List<Product> products) {
//     return SizedBox(
//       height: 250, // Define a fixed height for the horizontal list
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//         itemCount: products.length,
//         itemBuilder: (context, index) {
//           return SizedBox(
//             width: 150, // Define a fixed width for each product card
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 4.0),
//               child: ProductGridTile(product: products[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // WIDGET FOR A CATEGORY TILE
// class CategoryListTile extends StatelessWidget {
//   const CategoryListTile({Key? key, required this.category}) : super(key: key);
//   final SearchCategory category;
//
//   @override
//   Widget build(BuildContext context) {
//     // Split the label to style the last part bold
//     final parts = category.label.split('/');
//     final lastPart = parts.isNotEmpty ? parts.removeLast().trim() : '';
//     final firstPart = parts.join(' / ').trim();
//
//     return ListTile(
//       onTap: () {
//         print('Tapped on category: ${category.label}');
//         // TODO: Navigate to product listing page with this category filter
//       },
//       title: RichText(
//         text: TextSpan(
//           style: const TextStyle(fontSize: 16, color: Colors.black),
//           children: [
//             if (firstPart.isNotEmpty)
//               TextSpan(text: '$firstPart / '),
//             TextSpan(
//               text: lastPart,
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // WIDGET FOR A PRODUCT TILE IN THE GRID/HORIZONTAL LIST
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
//         print('Tapped on product: ${product.sku}');
//         // TODO: Navigate to the Product Detail Page
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // --- IMAGE ---
//           Expanded(
//             child: Card(
//               margin: EdgeInsets.zero,
//               clipBehavior: Clip.antiAlias,
//               child: CachedNetworkImage(
//                 imageUrl: product.imageUrl,
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
//           // --- TEXT CONTENT ---
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
//                   product.productName,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[700],
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '₹${product.price.toStringAsFixed(0)}',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 13,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }