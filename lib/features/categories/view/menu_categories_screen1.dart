
// lib/features/newin/view/menu_categories_screen.dart (or your path)
// lib/features/newin/view/menu_categories_screen.dart (or your path)
import 'package:aashniandco/features/newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/common_bottom_nav_bar.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../newin/bloc/product_repository.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/filter_bottom_sheet.dart';
import '../../newin/view/product_details_newin.dart';
import '../bloc/category_products_bloc.dart';
import '../bloc/category_products_event.dart';
import '../bloc/category_products_state.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/rendering.dart';

// Make sure to import your actual Product model
// import 'package:aashniandco/models/product_model.dart';

// lib/features/newin/view/menu_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Assuming your filter bottom sheet exists, import it here
// import 'package:aashniandco/widgets/filter_bottom_sheet.dart';

// Make sure to import your actual Product model


import '../bloc/category_products_bloc.dart';
import '../bloc/category_products_event.dart';
import '../bloc/category_products_state.dart';
import '../repository/api_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Make sure these import paths are correct for your project structure
// Your filter sheet
import '../../newin/model/new_in_model.dart'; // Your Product model
import '../bloc/category_products_bloc.dart';
import '../bloc/category_products_event.dart';
import '../bloc/category_products_state.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


// Make sure these import paths are correct for your project structure
 // Reuse your loader




// This new stateless widget contains the UI that depends on the BLoC.
// This is a cleaner pattern than putting everything in the main build method.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- YOUR PROJECT IMPORTS ---
          // Your detail screen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- YOUR PROJECT IMPORTS ---
// Make sure these paths are correct for your project structure


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'guest_cart_webview.dart';

// Import your blocs, models, and services
// import 'category_products_bloc.dart';
// import 'currency_bloc.dart';
// import 'api_service.dart';
// import 'product.dart';
// import 'product_detail_new_in_detail_screen.dart';
// import 'filter_bottom_sheet_categories.dart';

class MenuCategoriesScreen extends StatelessWidget {
  final String categoryName;
  final String? guestQuoteId;

  const MenuCategoriesScreen({
    Key? key,
    required this.categoryName,
    this.guestQuoteId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CategoryProductsBloc()
        ..add(FetchProducts(
          categoryName: categoryName,
          sortOption: "Default",
          isReset: true,
        )),
      child: MenuCategoriesView(categoryName: categoryName),
    );
  }
}

class MenuCategoriesView extends StatefulWidget {
  final String categoryName;
  const MenuCategoriesView({Key? key, required this.categoryName})
      : super(key: key);

  @override
  State<MenuCategoriesView> createState() => _MenuCategoriesViewState();
}

class _MenuCategoriesViewState extends State<MenuCategoriesView> {
  final _scrollController = ScrollController();
  String _selectedSort = "Default";
  bool _isFetching = false;
  late TabController _mainTabController;

  bool _isNavBarVisible =true;
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _categoryMetadata;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _categoryMetadata =
        _apiService.fetchCategoryMetadataByName(widget.categoryName);
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
    // --- Navbar Visibility Logic ---
    // Check if the user is scrolling down (hiding the top of the list)
    if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      if (_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = false;
        });
      }
    }
    // Check if the user is scrolling up (revealing the top of the list)
    else if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      if (!_isNavBarVisible) {
        setState(() {
          _isNavBarVisible = true;
        });
      }
    }


    if (_isBottom && !_isFetching) {
      setState(() {
        _isFetching = true;
      });
      context.read<CategoryProductsBloc>().add(FetchProducts(
        categoryName: widget.categoryName,
        sortOption: _selectedSort,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
        Text(widget.categoryName, style: const TextStyle(color: Colors.black)),
      ),
      body: BlocListener<CategoryProductsBloc, CategoryProductsState>(
        listener: (context, state) {
          if (state.status == CategoryProductsStatus.success ||
              state.status == CategoryProductsStatus.failure) {
            setState(() {
              _isFetching = false;
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSortHeader(),
              const SizedBox(height: 10),
              Expanded(child: _buildProductGrid()),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
        // Animate the height to show/hide the navbar
        height: _isNavBarVisible ? navBarHeight : 0,
        // Use a Wrap to prevent layout errors while the container is shrinking.
        child: Wrap(
          children: const [
            CommonBottomNavBar(currentIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildSortHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterButton(),
        DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSort,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
            onChanged: (value) {
              if (value != null && value != _selectedSort) {
                setState(() => _selectedSort = value);
                context.read<CategoryProductsBloc>().add(
                  FetchProducts(
                    categoryName: widget.categoryName,
                    sortOption: _selectedSort,
                    isReset: true,
                  ),
                );
              }
            },
            selectedItemBuilder: (BuildContext context) {
              return [
                "Default",
                "Latest",
                "Price: High to Low",
                "Price: Low to High"
              ].map((item) {
                return Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Sort By",
                          style: TextStyle(color: Colors.black, fontSize: 12)),
                      Text(_selectedSort,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 14)),
                    ],
                  ),
                );
              }).toList();
            },
            items: [
              "Default",
              "Latest",
              "Price: High to Low",
              "Price: Low to High"
            ].map((sortOption) {
              return DropdownMenuItem<String>(
                value: sortOption,
                child: Text(sortOption),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoryMetadata,
      builder: (context, snapshot) {
        final bool canFilter =
            snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError;

        return TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: canFilter
              ? () {
            final categoryData = snapshot.data!;
            final String parentCategoryId =
                categoryData['pare_cat_id']?.toString() ?? '';
            if (parentCategoryId.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<CategoryProductsBloc>(context),
                  child: FilterBottomSheetCategories(
                    categoryId: parentCategoryId,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                    Text("Filter not available for this category.")),
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

  Widget _buildProductGrid() {
    return BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
      builder: (context, state) {
        switch (state.status) {
          case CategoryProductsStatus.failure:
            return Center(
                child: Text(state.errorMessage ?? 'Failed to fetch products'));

          case CategoryProductsStatus.success:
            if (state.products.isEmpty) {
              return const Center(
                  child: Text("No products found in this category."));
            }
            return GridView.builder(
              controller: _scrollController,
              itemCount: state.hasReachedMax
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
                  return _buildShimmerCard(); // shimmer for pagination
                }
                final item = state.products[index];
                return _buildProductCard(item);
              },
            );

          case CategoryProductsStatus.initial:
          case CategoryProductsStatus.loading:
            if (state.products.isEmpty) {
              return GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.5,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => _buildShimmerCard(),
              );
            }
            return GridView.builder(
              controller: _scrollController,
              itemCount: state.products.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.5,
              ),
              itemBuilder: (context, index) {
                if (index >= state.products.length) {
                  return _buildShimmerCard(); // shimmer for bottom load
                }
                final item = state.products[index];
                return _buildProductCard(item);
              },
            );
        }
      },
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 250,
              color: Colors.grey[300],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 14,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      height: 12,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 14,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
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
// 24/9/2025
  Widget _buildProductCard(Product item) {
    final currencyState = context.watch<CurrencyBloc>().state;

    String displaySymbol = '₹';
    double displayPrice = item.actualPrice ?? 0.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      displayPrice =
          (item.actualPrice ?? 0.0) * currencyState.selectedRate.rate;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailNewInDetailScreen(product: item.toJson()),
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
              item.prodSmallImg ?? '',
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image,
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
                      item.designerName ?? "Unknown Designer",
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.shortDesc ?? "No description",
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

  // Widget _buildProductCard(Product item) {
  //   final currencyState = context.watch<CurrencyBloc>().state;
  //
  //   String displaySymbol = '₹';
  //   double displayPrice = item.actualPrice ?? 0.0;
  //
  //   if (currencyState is CurrencyLoaded) {
  //     displaySymbol = currencyState.selectedSymbol;
  //     displayPrice = (item.actualPrice ?? 0.0) * currencyState.selectedRate.rate;
  //   }
  //
  //   String generateUrlKey(Product item) {
  //     String sanitize(String text) {
  //       return text
  //           .toLowerCase()
  //           .replaceAll(RegExp(r'[^\w\s-]'), '')
  //           .replaceAll(' ', '-');
  //     }
  //
  //     final designer = sanitize(item.designerName ?? '');
  //     final desc = sanitize(item.shortDesc ?? '');
  //     final sku = sanitize(item.prod_sku ?? '');
  //     return '$designer-$desc-$sku.html';
  //   }
  //
  //   return GestureDetector(
  //     onTap: () async {
  //       final prefs = await SharedPreferences.getInstance();
  //       final userToken = prefs.getString('user_token');
  //
  //       if (userToken == null || userToken.isEmpty) {
  //         // Guest → WebView
  //         final urlKey = generateUrlKey(item);
  //         final productUrl = "https://stage.aashniandco.com/$urlKey";
  //
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => GuestProductWebViewScreen(
  //               productUrl: productUrl,
  //               title: item.designerName ?? "Product Details",
  //             ),
  //           ),
  //         );
  //       } else {
  //         // Logged-in → native product details
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) =>
  //                 ProductDetailNewInDetailScreen(product: item.toJson()),
  //           ),
  //         );
  //       }
  //     },
  //     child: Card(
  //       color: Colors.white,
  //       elevation: 1,
  //       clipBehavior: Clip.antiAlias,
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.stretch,
  //         children: [
  //           Image.network(
  //             item.prodSmallImg ?? '',
  //             height: 250,
  //             fit: BoxFit.cover,
  //             errorBuilder: (context, error, stackTrace) {
  //               return Container(
  //                 height: 250,
  //                 color: Colors.grey[200],
  //                 alignment: Alignment.center,
  //                 child: const Icon(Icons.broken_image,
  //                     size: 40, color: Colors.grey),
  //               );
  //             },
  //           ),
  //           Expanded(
  //             child: Padding(
  //               padding: const EdgeInsets.all(8.0),
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Text(
  //                     item.designerName ?? "Unknown Designer",
  //                     style: const TextStyle(
  //                         fontSize: 14, fontWeight: FontWeight.bold),
  //                     textAlign: TextAlign.center,
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   const SizedBox(height: 4),
  //                   Text(
  //                     item.shortDesc ?? "No description",
  //                     textAlign: TextAlign.center,
  //                     style: const TextStyle(fontSize: 12, color: Colors.grey),
  //                     maxLines: 2,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                   const SizedBox(height: 8),
  //                   Text(
  //                     "$displaySymbol${displayPrice.toStringAsFixed(0)}",
  //                     style: const TextStyle(
  //                         fontSize: 14, fontWeight: FontWeight.bold),
  //                     textAlign: TextAlign.center,
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

//27/09/2025 Webview Guest
//   Widget _buildProductCard(Product item) {
//     final String? guestQuoteId;
//     final currencyState = context.read<CurrencyBloc>().state;
//
//     // Determine selected currency and conversion rate
//     final selectedCurrency = currencyState is CurrencyLoaded
//         ? currencyState.selectedCurrencyCode
//         : 'INR';
//
//     final conversionRate = currencyState is CurrencyLoaded
//         ? currencyState.selectedRate.rate
//         : 1.0;
//
//     final displayPrice = (item.actualPrice ?? 0.0) * conversionRate;
//
//     String generateUrlKey(Product item) {
//       String sanitize(String text) {
//         return text
//             .toLowerCase()
//             .replaceAll(RegExp(r'[^\w\s-]'), '')
//             .replaceAll(' ', '-');
//       }
//
//       final designer = sanitize(item.designerName ?? '');
//       final desc = sanitize(item.shortDesc ?? '');
//       final sku = sanitize(item.prod_sku ?? '');
//       return '$designer-$desc-$sku.html';
//     }
//
//     return GestureDetector(
//       onTap: () async {
//         final prefs = await SharedPreferences.getInstance();
//         final userToken = prefs.getString('user_token');
//
//         if (userToken == null || userToken.isEmpty) {
//           // Guest → WebView
//           final urlKey = generateUrlKey(item);
//
//           // ✅ Append currency parameter to URL
//           final productUrl =
//               "https://stage.aashniandco.com/$urlKey?currency=$selectedCurrency";
//
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => GuestProductWebViewScreen(
//                 productUrl: productUrl,
//                 title: item.designerName ?? "Product Details",
//
//               ),
//             ),
//           );
//         } else {
//           // Logged-in → native product details
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) =>
//                   ProductDetailNewInDetailScreen(product: item.toJson()),
//             ),
//           );
//         }
//       },
//       child: Card(
//         color: Colors.white,
//         elevation: 1,
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               item.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.broken_image,
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
//                       item.designerName ?? "Unknown Designer",
//                       style: const TextStyle(
//                           fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item.shortDesc ?? "No description",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "$selectedCurrency ${displayPrice.toStringAsFixed(0)}",
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




}


//12/9/2025,  22/8/2025
// class MenuCategoriesScreen extends StatelessWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Provide the BLoC to the widget tree.
//     // It will be accessible by all children of this Scaffold.
//     return BlocProvider(
//       create: (context) => CategoryProductsBloc()
//         ..add(FetchProducts(
//           categoryName: categoryName,
//           sortOption: "Default",
//           isReset: true,
//         )),
//       child: MenuCategoriesView(categoryName: categoryName),
//     );
//   }
// }
//
// class MenuCategoriesView extends StatefulWidget {
//   final String categoryName;
//   const MenuCategoriesView({Key? key, required this.categoryName}) : super(key: key);
//
//   @override
//   State<MenuCategoriesView> createState() => _MenuCategoriesViewState();
// }
//
// class _MenuCategoriesViewState extends State<MenuCategoriesView> {
//   final _scrollController = ScrollController();
//   String _selectedSort = "Default";
//
//   // Flag to prevent multiple fetch requests while one is already in progress.
//   bool _isFetching = false;
//
//   final ApiService _apiService = ApiService();
//   late Future<Map<String, dynamic>> _categoryMetadataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
//   }
//
//   @override
//   void dispose() {
//     _scrollController
//       ..removeListener(_onScroll)
//       ..dispose();
//     super.dispose();
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   void _onScroll() {
//     // Only dispatch a new event if we are at the bottom AND not already fetching data.
//     if (_isBottom && !_isFetching) {
//       // Set the flag to true immediately to block subsequent triggers.
//       setState(() {
//         _isFetching = true;
//       });
//       // Dispatch the event to fetch the next page.
//       context.read<CategoryProductsBloc>().add(FetchProducts(
//         categoryName: widget.categoryName,
//         sortOption: _selectedSort,
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.categoryName, style: const TextStyle(color: Colors.black)),
//       ),
//       // The body is wrapped in a BlocListener to reset the `_isFetching` flag.
//       body: BlocListener<CategoryProductsBloc, CategoryProductsState>(
//         listener: (context, state) {
//           // When the BLoC state changes to success or failure, it means the fetch
//           // operation is complete. We can now reset the flag to allow new fetches.
//           if (state.status == CategoryProductsStatus.success || state.status == CategoryProductsStatus.failure) {
//             setState(() {
//               _isFetching = false;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildSortHeader(),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: _buildProductGrid(),
//               ),
//             ],
//           ),
//         ),
//       ),
//       // floatingActionButton: _buildFilterFab(),
//     );
//   }
//
//   Widget _buildSortHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Left side: This now calls the correct filter button widget
//         _buildFilterButton(),
//
//         // Right side: This dropdown code is correct and remains
//         DropdownButtonHideUnderline(
//           child: DropdownButton<String>(
//             value: _selectedSort,
//             icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
//             onChanged: (value) {
//               if (value != null && value != _selectedSort) {
//                 setState(() { _selectedSort = value; });
//                 context.read<CategoryProductsBloc>().add(
//                   FetchProducts(
//                     categoryName: widget.categoryName,
//                     sortOption: _selectedSort,
//                     isReset: true,
//                   ),
//                 );
//               }
//             },
//             selectedItemBuilder: (BuildContext context) {
//               return ["Default", "Latest", "Price: High to Low", "Price: Low to High"]
//                   .map<Widget>((String item) {
//                 return Align(
//                   alignment: Alignment.centerRight,
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Text("Sort By", style: TextStyle(color: Colors.grey, fontSize: 12)),
//                       Text(_selectedSort, style: const TextStyle(color: Colors.black, fontSize: 14)),
//                     ],
//                   ),
//                 );
//               }).toList();
//             },
//             items: [
//               "Default", "Latest", "Price: High to Low", "Price: Low to High"
//             ].map((sortOption) {
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
//   /// This NEW method returns a TextButton for the header.
//   /// It contains the logic from your old _buildFilterFab.
//   Widget _buildFilterButton() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadataFuture,
//       builder: (context, snapshot) {
//         final bool canFilter = snapshot.connectionState == ConnectionState.done && !snapshot.hasError;
//
//         return TextButton.icon(
//           style: TextButton.styleFrom(
//             foregroundColor: Colors.black,
//             padding: EdgeInsets.zero,
//             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//           ),
//           onPressed: canFilter ? () {
//             final categoryData = snapshot.data!;
//             final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//             if (parentCategoryId.isNotEmpty) {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => BlocProvider.value(
//                   value: BlocProvider.of<CategoryProductsBloc>(context),
//                   child: FilterBottomSheetCategories(
//                     categoryId: parentCategoryId,
//                   ),
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Filter not available for this category.")),
//               );
//             }
//           } : null,
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
//   // Widget _buildSortHeader() {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       Text(
//   //         widget.categoryName,
//   //         style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //       ),
//   //       Container(
//   //         height: 35,
//   //         padding: const EdgeInsets.symmetric(horizontal: 12),
//   //         decoration: BoxDecoration(
//   //           color: Colors.grey[200],
//   //           borderRadius: BorderRadius.circular(6),
//   //         ),
//   //         child: DropdownButton<String>(
//   //           value: _selectedSort,
//   //           icon: const Icon(Icons.sort, color: Colors.black),
//   //           underline: Container(),
//   //           onChanged: (value) {
//   //             if (value != null && value != _selectedSort) {
//   //               setState(() {
//   //                 _selectedSort = value;
//   //               });
//   //               context.read<CategoryProductsBloc>().add(
//   //                 FetchProducts(
//   //                   categoryName: widget.categoryName,
//   //                   sortOption: _selectedSort,
//   //                   isReset: true,
//   //                 ),
//   //               );
//   //             }
//   //           },
//   //           items: [
//   //             "Default", "Latest", "Price: High to Low", "Price: Low to High"
//   //           ].map((sortOption) {
//   //             return DropdownMenuItem<String>(
//   //               value: sortOption,
//   //               child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
//   //             );
//   //           }).toList(),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }
//
//   Widget _buildProductGrid() {
//     return BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//       builder: (context, state) {
//         switch (state.status) {
//           case CategoryProductsStatus.failure:
//             return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));
//
//           case CategoryProductsStatus.success:
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found in this category."));
//             }
//             return GridView.builder(
//               controller: _scrollController,
//               itemCount: state.hasReachedMax
//                   ? state.products.length
//                   : state.products.length + 1,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 if (index >= state.products.length) {
//                   // Show the bottom loading spinner only if we are actively fetching.
//                   return _isFetching
//                       ? const Center(child: CircularProgressIndicator())
//                       : const SizedBox.shrink(); // Otherwise, show nothing.
//                 }
//                 final item = state.products[index];
//                 return _buildProductCard(item);
//               },
//             );
//
//           case CategoryProductsStatus.initial:
//           case CategoryProductsStatus.loading:
//           // Show a full-screen loader only if the product list is empty (initial load).
//             if (state.products.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             // If we are loading but have products, it's a pagination load.
//             return GridView.builder(
//               controller: _scrollController,
//               itemCount: state.products.length + 1,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 if (index >= state.products.length) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final item = state.products[index];
//                 return _buildProductCard(item);
//               },
//             );
//         }
//       },
//     );
//   }
//
//   // --- MODIFIED WIDGET ---
//   Widget _buildProductCard(Product item) {
//     // 1. Watch the global CurrencyBloc state. This widget will rebuild
//     //    whenever the currency state changes.
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     // Default values for safety, assuming base currency is INR (₹).
//     String displaySymbol = '₹';
//     double displayPrice = item.actualPrice ?? 0.0;
//
//     // 2. If currency is loaded, calculate the new price and get the symbol.
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       // Calculate price: (base price in INR) * (selected currency's rate)
//       displayPrice = (item.actualPrice ?? 0.0) * currencyState.selectedRate.rate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ProductDetailNewInDetailScreen(product: item.toJson()),
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
//               item.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
//                       item.designerName ?? "Unknown Designer",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item.shortDesc ?? "No description",
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
//
//   // Widget _buildFilterFab() {
//   //   return FutureBuilder<Map<String, dynamic>>(
//   //     future: _categoryMetadataFuture,
//   //     builder: (context, snapshot) {
//   //       if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
//   //         return FloatingActionButton(
//   //           onPressed: null,
//   //           backgroundColor: Colors.grey,
//   //           child: snapshot.connectionState == ConnectionState.waiting
//   //               ? const CircularProgressIndicator(color: Colors.white)
//   //               : const Icon(Icons.filter_list_alt, color: Colors.black54),
//   //         );
//   //       }
//   //       final categoryData = snapshot.data!;
//   //       final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//   //       return FloatingActionButton(
//   //         onPressed: () {
//   //           if (parentCategoryId.isNotEmpty) {
//   //             showModalBottomSheet(
//   //               context: context,
//   //               isScrollControlled: true,
//   //               backgroundColor: Colors.transparent,
//   //               builder: (_) => BlocProvider.value(
//   //                 value: BlocProvider.of<CategoryProductsBloc>(context),
//   //                 child: FilterBottomSheetCategories(
//   //                   categoryId: parentCategoryId,
//   //                 ),
//   //               ),
//   //             );
//   //           } else {
//   //             ScaffoldMessenger.of(context).showSnackBar(
//   //               const SnackBar(content: Text("Filter not available for this category.")),
//   //             );
//   //           }
//   //         },
//   //         backgroundColor: Colors.white,
//   //         child: const Icon(Icons.filter_list_alt, color: Colors.black),
//   //       );
//   //     },
//   //   );
//   // }
// }


// 18/8/2025

// class MenuCategoriesScreen extends StatelessWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Provide the BLoC to the widget tree.
//     // It will be accessible by all children of this Scaffold.
//     return BlocProvider(
//       create: (context) => CategoryProductsBloc()
//         ..add(FetchProducts(
//           categoryName: categoryName,
//           sortOption: "Default",
//           isReset: true,
//         )),
//       child: MenuCategoriesView(categoryName: categoryName),
//     );
//   }
// }
//
// class MenuCategoriesView extends StatefulWidget {
//   final String categoryName;
//   const MenuCategoriesView({Key? key, required this.categoryName}) : super(key: key);
//
//   @override
//   State<MenuCategoriesView> createState() => _MenuCategoriesViewState();
// }
//
// class _MenuCategoriesViewState extends State<MenuCategoriesView> {
//   final _scrollController = ScrollController();
//   String _selectedSort = "Default";
//
//   // --- NEW ---
//   // Flag to prevent multiple fetch requests while one is already in progress.
//   bool _isFetching = false;
//
//   final ApiService _apiService = ApiService();
//   late Future<Map<String, dynamic>> _categoryMetadataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_onScroll);
//     _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
//   }
//
//   @override
//   void dispose() {
//     _scrollController
//       ..removeListener(_onScroll)
//       ..dispose();
//     super.dispose();
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   // --- MODIFIED ---
//   // The scroll listener now uses the `_isFetching` guard.
//   void _onScroll() {
//     // Only dispatch a new event if we are at the bottom AND not already fetching data.
//     if (_isBottom && !_isFetching) {
//       // Set the flag to true immediately to block subsequent triggers.
//       setState(() {
//         _isFetching = true;
//       });
//       // Dispatch the event to fetch the next page.
//       context.read<CategoryProductsBloc>().add(FetchProducts(
//         categoryName: widget.categoryName,
//         sortOption: _selectedSort,
//       ));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.categoryName, style: const TextStyle(color: Colors.red)),
//       ),
//       // --- MODIFIED ---
//       // The body is wrapped in a BlocListener to reset the `_isFetching` flag.
//       body: BlocListener<CategoryProductsBloc, CategoryProductsState>(
//         listener: (context, state) {
//           // When the BLoC state changes to success or failure, it means the fetch
//           // operation is complete. We can now reset the flag to allow new fetches.
//           if (state.status == CategoryProductsStatus.success || state.status == CategoryProductsStatus.failure) {
//             setState(() {
//               _isFetching = false;
//             });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildSortHeader(),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: _buildProductGrid(),
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: _buildFilterFab(),
//     );
//   }
//
//   Widget _buildSortHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           widget.categoryName,
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         ),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: _selectedSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != _selectedSort) {
//                 setState(() {
//                   _selectedSort = value;
//                 });
//                 context.read<CategoryProductsBloc>().add(
//                   FetchProducts(
//                     categoryName: widget.categoryName,
//                     sortOption: _selectedSort,
//                     isReset: true,
//                   ),
//                 );
//               }
//             },
//             items: [
//               "Default", "Latest", "Price: High to Low", "Price: Low to High"
//             ].map((sortOption) {
//               return DropdownMenuItem<String>(
//                 value: sortOption,
//                 child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProductGrid() {
//     return BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//       builder: (context, state) {
//         switch (state.status) {
//           case CategoryProductsStatus.failure:
//             return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));
//
//           case CategoryProductsStatus.success:
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found in this category."));
//             }
//             return GridView.builder(
//               controller: _scrollController,
//               itemCount: state.hasReachedMax
//                   ? state.products.length
//                   : state.products.length + 1,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 if (index >= state.products.length) {
//                   // Show the bottom loading spinner only if we are actively fetching.
//                   return _isFetching
//                       ? const Center(child: CircularProgressIndicator())
//                       : const SizedBox.shrink(); // Otherwise, show nothing.
//                 }
//                 final item = state.products[index];
//                 return _buildProductCard(item);
//               },
//             );
//
//           case CategoryProductsStatus.initial:
//           case CategoryProductsStatus.loading:
//           // Show a full-screen loader only if the product list is empty (initial load).
//             if (state.products.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             // If we are loading but have products, it's a pagination load,
//             // so we fall through to the success case which shows the list and a bottom loader.
//             // This is handled by the `_isFetching` check in the success case.
//             // So we can just reuse the success builder.
//             // Fallthrough is not directly supported, so just copy the success case.
//             return GridView.builder(
//               controller: _scrollController,
//               itemCount: state.products.length + 1,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.50,
//               ),
//               itemBuilder: (context, index) {
//                 if (index >= state.products.length) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final item = state.products[index];
//                 return _buildProductCard(item);
//               },
//             );
//         }
//       },
//     );
//   }
//
//   Widget _buildProductCard(Product item) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) =>
//                 ProductDetailNewInDetailScreen(product: item.toJson()),
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
//               item.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) {
//                 return Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
//                       item.designerName ?? "Unknown Designer",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       item.shortDesc ?? "No description",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 12, color: Colors.grey),
//                       maxLines: 2, overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
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
//
//   Widget _buildFilterFab() {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadataFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
//           return FloatingActionButton(
//             onPressed: null,
//             backgroundColor: Colors.grey,
//             child: snapshot.connectionState == ConnectionState.waiting
//                 ? const CircularProgressIndicator(color: Colors.white)
//                 : const Icon(Icons.filter_list_alt, color: Colors.black54),
//           );
//         }
//         final categoryData = snapshot.data!;
//         final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//         return FloatingActionButton(
//           onPressed: () {
//             if (parentCategoryId.isNotEmpty) {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (_) => BlocProvider.value(
//                   value: BlocProvider.of<CategoryProductsBloc>(context),
//                   child: FilterBottomSheetCategories(
//                     categoryId: parentCategoryId,
//                   ),
//                 ),
//               );
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text("Filter not available for this category.")),
//               );
//             }
//           },
//           backgroundColor: Colors.white,
//           child: const Icon(Icons.filter_list_alt, color: Colors.black),
//         );
//       },
//     );
//   }
// }



//17/7/2025

// class MenuCategoriesScreen extends StatefulWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   State<MenuCategoriesScreen> createState() => _MenuCategoriesScreenState();
// }
// class _MenuCategoriesScreenState extends State<MenuCategoriesScreen> {
//   String selectedSort = "Default";
//
//   // This list holds the pristine, original data from the API,
//   // which is already sorted by the "Default" order.
//   List<Product> originalProducts = [];
//
//   // This list holds the products currently displayed in the UI (can be re-sorted).
//   List<Product> displayedProducts = [];
//
//   final ApiService _apiService = ApiService();
//   late Future<Map<String, dynamic>> _categoryMetadataFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
//   }
//
//   // This method handles all sorting logic on the client-side.
//   void applySort() {
//     // Create a mutable copy of the original list to perform sorting on.
//     List<Product> productsToSort = List.from(originalProducts);
//
//     // Apply the selected sort logic.
//     // NOTE: We don't need a case for "Default" because 'productsToSort'
//     // is already in the default order from the API.
//     if (selectedSort == "Price: High to Low") {
//       productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//     } else if (selectedSort == "Price: Low to High") {
//       productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//     } else if (selectedSort == "Latest") {
//       productsToSort.sort((a, b) {
//         // Your existing complex 'Latest' sorting logic remains here
//         int getSortableValue(String? sku) {
//           if (sku == null || sku.isEmpty) return 0;
//           const monthMap = {
//             'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
//             'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
//           };
//           final RegExp datePattern = RegExp(r'(JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)([0-9]{2})');
//           final match = datePattern.firstMatch(sku.toUpperCase());
//           if (match != null) {
//             try {
//               String monthStr = match.group(1)!;
//               String yearStr = match.group(2)!;
//               String sequencePart = sku.substring(match.end);
//               String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');
//               if (sequenceDigits.isNotEmpty) {
//                 int year = int.parse(yearStr) + 2000;
//                 int month = monthMap[monthStr]!;
//                 int sequence = int.parse(sequenceDigits);
//                 return (year * 10000000) + (month * 100000) + sequence;
//               }
//             } catch (e) { /* Fall through */ }
//           }
//           String numericPart = sku.replaceAll(RegExp(r'[^0-9]'), '');
//           if (numericPart.isNotEmpty) {
//             return int.tryParse(numericPart) ?? 0;
//           }
//           return 0;
//         }
//         final valA = getSortableValue(a.prod_en_id);
//         final valB = getSortableValue(b.prod_en_id);
//         return valB.compareTo(valA);
//       });
//     }
//
//     // Update the state to refresh the UI with the final sorted list.
//     setState(() {
//       displayedProducts = productsToSort;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.categoryName, style: TextStyle(color: Colors.black45)),
//       ),
//       body: BlocProvider(
//         create: (context) => CategoryProductsBloc()
//           ..add(FetchProductsForCategory(categoryName: widget.categoryName)),
//         child: BlocListener<CategoryProductsBloc, CategoryProductsState>(
//           listener: (context, state) {
//             if (state is CategoryProductsLoaded) {
//               // --- KEY CHANGE ---
//               // 1. When data is loaded, save it to our 'originalProducts' list.
//               setState(() {
//                 originalProducts = state.products;
//                 // 2. Initially, the displayed list is the same as the original.
//                 displayedProducts = state.products;
//               });
//             }
//           },
//           child: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//             builder: (context, state) {
//               // --- UI LOGIC CHANGES ---
//               if (state is CategoryProductsLoading && displayedProducts.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (state is CategoryProductsError) {
//                 return Center(child: Text(state.message));
//               }
//               if (displayedProducts.isEmpty && state is CategoryProductsLoaded) {
//                 return const Center(child: Text("No products found in this category."));
//               }
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     Row(
//                       // ... (Your existing Row with Dropdown is correct)
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.categoryName,
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         Container(
//                           height: 35,
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: DropdownButton<String>(
//                             value: selectedSort,
//                             icon: const Icon(Icons.sort, color: Colors.black),
//                             style: const TextStyle(fontSize: 14),
//                             dropdownColor: Colors.white,
//                             underline: Container(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 setState(() {
//                                   selectedSort = value;
//                                 });
//                                 // Call applySort to update the UI with the new selection.
//                                 applySort();
//                               }
//                             },
//                             items: [
//                               "Default",
//                               "Latest",
//                               "Price: High to Low",
//                               "Price: Low to High"
//                             ].map((sortOption) {
//                               return DropdownMenuItem<String>(
//                                 value: sortOption,
//                                 child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       // Use the 'displayedProducts' list for the GridView
//                       child: GridView.builder(
//                         itemCount: displayedProducts.length,
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 0.55,
//                         ),
//                         itemBuilder: (context, index) {
//                           final item = displayedProducts[index];
//                           // ... (The rest of your GridView.builder is correct)
//                           return GestureDetector(
//                             onTap: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProductDetailNewInDetailScreen(product: item.toJson()),
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               color: Colors.white,
//                               elevation: 1,
//                               clipBehavior: Clip.antiAlias,
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Image.network(
//                                     item.prodSmallImg ?? '',
//                                     width: double.infinity,
//                                     height: 250,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: 250,
//                                         color: Colors.grey[200],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
//                                       );
//                                     },
//                                   ),
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           item.designerName ?? "Unknown Designer",
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                           textAlign: TextAlign.center,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           item.shortDesc ?? "No description",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//       floatingActionButton: FutureBuilder<Map<String, dynamic>>(
//         future: _categoryMetadataFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
//             return FloatingActionButton(
//               onPressed: null,
//               backgroundColor: Colors.grey,
//               child: snapshot.connectionState == ConnectionState.waiting
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Icon(Icons.filter_list_alt, color: Colors.black54),
//             );
//           }
//           final categoryData = snapshot.data!;
//           final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//           return FloatingActionButton(
//             onPressed: () {
//               if (parentCategoryId.isNotEmpty) {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (context) => FilterBottomSheetCategories(
//                     categoryId: parentCategoryId,
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Filter not available for this category.")),
//                 );
//               }
//             },
//             backgroundColor: Colors.white,
//             child: const Icon(Icons.filter_list_alt, color: Colors.black),
//           );
//         },
//       ),
//     );
//   }
// }

// 1. Converted to a StatefulWidget to manage sorting state
// class MenuCategoriesScreen extends StatefulWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   State<MenuCategoriesScreen> createState() => _MenuCategoriesScreenState();
// }
//
// class _MenuCategoriesScreenState extends State<MenuCategoriesScreen> {
//   // 2. State variables for sorting
//   String selectedSort = "Latest";
//   List<Product> sortedProducts = [];
//
//   // ✅ NEW STATE VARIABLES FOR ASYNC DATA
//   final ApiService _apiService = ApiService();
//   late Future<Map<String, dynamic>> _categoryMetadataFuture;
//
//
//
//   // 3. Sorting logic adapted from your example
//   // 3. Sorting logic adapted from your reference
//   // 3. Sorting logic adapted from your reference
//   // 3. Sorting logic with added DEBUGGING
// // 3. Sorting logic adapted from your reference
//
//   void sortProducts(List<Product> products) {
//     // Create a mutable copy of the product list to sort
//     List<Product> productsToSort = List<Product>.from(products);
//
//     if (selectedSort == "High to Low") {
//       productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//     } else if (selectedSort == "Low to High") {
//       productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//     } else { // Default to "Latest"
//       // --- FINAL LOGIC THAT MIMICS YOUR WEBSITE'S BEHAVIOR ---
//       productsToSort.sort((a, b) {
//
//         // This helper function can now handle all 3 formats:
//         // 1. Modern Date-based SKUs (SRKAUG2403)
//         // 2. Legacy Alphanumeric SKUs (Dhr006382)
//         // 3. Legacy Simple Numeric IDs (635065)
//         int getSortableValue(String? id) {
//           if (id == null || id.isEmpty) {
//             return 0;
//           }
//
//           // --- Priority 1: Check for the Modern Date-based format FIRST. ---
//           // This is the most reliable way to determine "newness".
//           const monthMap = {
//             'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
//             'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
//           };
//
//           // Use a regular expression to find the date pattern
//           final RegExp datePattern = RegExp(r'[A-Z]{3}([0-9]{2})');
//           final match = datePattern.firstMatch(id.toUpperCase());
//
//           if (match != null && monthMap.containsKey(id.substring(match.start, match.start + 3))) {
//             try {
//               String monthStr = id.substring(match.start, match.start + 3);
//               String yearStr = match.group(1)!;
//               // Find what's left for the sequence number
//               String sequencePart = id.substring(match.end);
//               String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');
//
//               if (sequenceDigits.isNotEmpty) {
//                 int year = int.parse(yearStr) + 2000;
//                 int month = monthMap[monthStr]!;
//                 int sequence = int.parse(sequenceDigits);
//                 // Return a very large number to ensure these are always sorted highest
//                 return (year * 10000000) + (month * 100000) + sequence;
//               }
//             } catch (e) { /* Fall through to legacy parsing */ }
//           }
//
//           // --- Priority 2: Fallback for Legacy SKUs (Dhr006382 or 635065) ---
//           // If it's not a modern SKU, extract any numbers we can find.
//           String numericPart = id.replaceAll(RegExp(r'[^0-9]'), '');
//           if (numericPart.isNotEmpty) {
//             return int.tryParse(numericPart) ?? 0;
//           }
//
//           // If all else fails
//           return 0;
//         }
//
//         final valA = getSortableValue(a.prod_en_id);
//         final valB = getSortableValue(b.prod_en_id);
//
//         return valB.compareTo(valA);
//       });
//     }
//
//     // Update the state to trigger a rebuild
//     setState(() {
//       sortedProducts = productsToSort;
//     });
//   }
//   // void sortProducts(List<Product> products) {
//   //   // Create a mutable copy of the product list to sort
//   //   List<Product> productsToSort = List<Product>.from(products);
//   //
//   //   if (selectedSort == "High to Low") {
//   //     productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//   //   } else if (selectedSort == "Low to High") {
//   //     productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//   //   } else { // Default to "Latest"
//   //     // --- UNIVERSAL SORT LOGIC FOR INCONSISTENT prod_en_id ---
//   //     productsToSort.sort((a, b) {
//   //
//   //       // This "smart" helper function can handle both simple numbers AND complex SKUs.
//   //       int getSortableValue(String? id) {
//   //         if (id == null || id.isEmpty) {
//   //           return 0; // Invalid ID, sort to bottom
//   //         }
//   //
//   //         // --- Step 1: Try to parse as a simple number first. ---
//   //         // This handles IDs like "635065".
//   //         final simpleId = int.tryParse(id);
//   //         if (simpleId != null) {
//   //           return simpleId;
//   //         }
//   //
//   //         // --- Step 2: If it's not a simple number, try parsing it as a complex SKU. ---
//   //         // This handles IDs like "SWJJUL24D2026".
//   //         // It will only run if the int.tryParse above fails.
//   //         if (id.length < 9) return 0; // Complex SKU is too short
//   //
//   //         const monthMap = {
//   //           'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
//   //           'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
//   //         };
//   //
//   //         try {
//   //           String monthStr = id.substring(3, 6).toUpperCase();
//   //           String yearStr = id.substring(6, 8);
//   //           String sequencePart = id.substring(8);
//   //           String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');
//   //
//   //           if (sequenceDigits.isEmpty) return 0;
//   //
//   //           int year = int.parse(yearStr) + 2000;
//   //           int month = monthMap[monthStr] ?? 0;
//   //           int sequence = int.parse(sequenceDigits);
//   //
//   //           // The large number ensures date-based SKUs are always "newer"
//   //           // than the simple number IDs from the older system.
//   //           return (year * 10000000) + (month * 100000) + sequence;
//   //
//   //         } catch (e) {
//   //           // If all parsing attempts fail, sort it to the bottom.
//   //           return 0;
//   //         }
//   //       }
//   //
//   //       // --- THE CRITICAL PART ---
//   //       // We now call our universal helper function on prod_en_id.
//   //       final valA = getSortableValue(a.prod_en_id);
//   //       final valB = getSortableValue(b.prod_en_id);
//   //
//   //       return valB.compareTo(valA);
//   //     });
//   //   }
//   //
//   //   // Update the state to trigger a rebuild with the sorted list
//   //   setState(() {
//   //     sortedProducts = productsToSort;
//   //   });
//   // }
//
// //   void sortProducts(List<Product> products) {
// //     // Create a mutable copy of the product list to sort
// //     List<Product> productsToSort = List<Product>.from(products);
// //
// //     if (selectedSort == "High to Low") {
// //       // Sort by price, highest first
// //       productsToSort.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
// //     } else if (selectedSort == "Low to High") {
// //       // Sort by price, lowest first
// //       productsToSort.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
// //     } else { // Default to "Latest"
// //       // *** NEW LOGIC FOR "LATEST" BASED ON YOUR REFERENCE ***
// //       // This logic sorts the products by their SKU (prodEnId) in descending numerical order.
// //       productsToSort.sort((a, b) {
// //         // Safely parse the SKU string to an integer. If it's not a valid number
// //         // or is null, it defaults to 0.
// //         // Note: We use 'prodEnId' to match the property in your Product model on this screen.
// //         final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
// //         final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
// //
// //         // By comparing B to A, we get a descending sort order.
// //         // The product with the higher ID (idB) will come first.
// //         return idB.compareTo(idA);
// //       });
// //     }
// //
// //     // Update the state to trigger a rebuild with the sorted list
// //     setState(() {
// //       sortedProducts = productsToSort;
// //     });
// //   }
//
//   @override
//   void initState() {
//     super.initState();
//     // Start the metadata fetch when the screen loads
//     _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return Scaffold(
//       appBar: AppBar(
//         // The AppBar title remains dynamic
//         title: Text(widget.categoryName,style: TextStyle(color: Colors.green),),
//       ),
//       // 4. BlocProvider is now in the body to trigger the fetch once
//       body: BlocProvider(
//         create: (context) => CategoryProductsBloc()
//           ..add(FetchProductsForCategory(categoryName: widget.categoryName)),
//
//         // 5. BlocListener is used to react to data loading without rebuilding the whole screen
//         child: BlocListener<CategoryProductsBloc, CategoryProductsState>(
//           listener: (context, state) {
//             if (state is CategoryProductsLoaded) {
//               // When products are loaded, sort them based on the current selection
//               sortProducts(state.products);
//             }
//           },
//           // 6. BlocBuilder handles UI changes for loading/error and the main content
//           child: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//             builder: (context, state) {
//               if (state is CategoryProductsLoading && sortedProducts.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (state is CategoryProductsError) {
//                 return Center(child: Text(state.message));
//               }
//
//               if (sortedProducts.isEmpty && state is CategoryProductsLoaded) {
//                 return const Center(child: Text("No products found in this category."));
//               }
//
//               // The main UI structure from your example
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     // Header Row with Title and Sort Dropdown
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           widget.categoryName, // Dynamic title
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         Container(
//                           height: 35,
//                           padding: const EdgeInsets.symmetric(horizontal: 12),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[200],
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: DropdownButton<String>(
//                             value: selectedSort,
//                             icon: const Icon(Icons.sort, color: Colors.black),
//                             style: const TextStyle(fontSize: 14),
//                             dropdownColor: Colors.white,
//                             underline: Container(),
//                             onChanged: (value) {
//                               if (value != null) {
//                                 selectedSort = value;
//                                 // Re-sort the existing list when the user changes selection
//                                 if (state is CategoryProductsLoaded) {
//                                   sortProducts(state.products);
//                                 }
//                               }
//                             },
//                             items: ["Latest", "High to Low", "Low to High"]
//                                 .map((sortOption) {
//                               return DropdownMenuItem<String>(
//                                 value: sortOption,
//                                 child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//
//                     // Product Grid
//                     Expanded(
//                       child: GridView.builder(
//                         itemCount: sortedProducts.length,
//                         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 0.55, // Adjusted for better layout
//                         ),
//                         itemBuilder: (context, index) {
//                           final item = sortedProducts[index];
//                           return GestureDetector(
//                             onTap: () {
//                               // TODO: Implement navigation to product detail screen
//                               // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: item)));
//                               print("Tapped on ${item.designerName}");
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) =>
//                                       ProductDetailNewInDetailScreen(product: item.toJson()),
//                                 ),
//                               );
//                             },
//                             child: Card(
//                               color: Colors.white,
//                               elevation: 1,
//                               clipBehavior: Clip.antiAlias, // Ensures image respects border radius
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Image.network(
//                                     item.prodSmallImg ?? '', // Use correct property name
//                                     width: double.infinity,
//                                     height: 250, // Fixed height for consistency
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: 250,
//                                         color: Colors.grey[200],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
//                                       );
//                                     },
//                                   ),
//
//                                   Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           item.designerName ?? "Unknown Designer",
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                           textAlign: TextAlign.center,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Text(
//                                           item.shortDesc ?? "No description",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(fontSize: 12, color: Colors.grey),
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Text(
//                                           "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}", // Use actualPrice1
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//
//       // Floating Filter Button from your example
//       floatingActionButton: FutureBuilder<Map<String, dynamic>>(
//         future: _categoryMetadataFuture,
//         builder: (context, snapshot) {
//           // If data is loading or has an error, show a disabled button
//           if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
//             return FloatingActionButton(
//               onPressed: null, // Disabled
//               backgroundColor: Colors.grey,
//               child: snapshot.connectionState == ConnectionState.waiting
//                   ? const CircularProgressIndicator(color: Colors.white)
//                   : const Icon(Icons.filter_list_alt, color: Colors.black54),
//             );
//           }
//
//           // Data is loaded, we can get the ID!
//           final categoryData = snapshot.data!;
//           // final String categoryId = categoryData['cat_id']?.toString() ?? '';
//           final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//           // Show the enabled button
//           return FloatingActionButton(
//             onPressed: () {
//               if (parentCategoryId.isNotEmpty) {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (context) => FilterBottomSheetCategories(
//                     // Pass the dynamically fetched ID
//                     categoryId: parentCategoryId,
//                   ),
//                 );
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("Filter not available for this category.")),
//                 );
//               }
//             },
//             backgroundColor: Colors.white,
//             child: const Icon(Icons.filter_list_alt, color: Colors.black),
//           );
//         },
//       ),
//     );
//   }
// }

// class MenuCategoriesScreen extends StatelessWidget {
//   final String categoryName;
//
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(categoryName),
//       ),
//       // 1. Wrap the body with BlocProvider to create and provide the BLoC
//       body: BlocProvider(
//         create: (context) => CategoryProductsBloc()
//         // 2. Immediately add the event to start fetching data
//           ..add(FetchProductsForCategory(categoryName: categoryName)),
//         child: BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
//           builder: (context, state) {
//             // 3. Build UI based on the current state
//             if (state is CategoryProductsLoading) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (state is CategoryProductsLoaded) {
//               // If there are no products, show a message
//               if (state.products.isEmpty) {
//                 return const Center(
//                   child: Text('No products found in this category.'),
//                 );
//               }
//               // Display the products in a list or grid
//               return ListView.builder(
//                 itemCount: state.products.length,
//                 itemBuilder: (context, index) {
//                   final product = state.products[index];
//
//                   // ✅ CORRECTED: Use the actual property names from your Product model
//                   // These names should match the fields from the API response.
//                   return ListTile(
//                     leading: product.prodSmallImg != null && product.prodSmallImg!.isNotEmpty
//                         ? Image.network(product.prodSmallImg!)
//                         : const Icon(Icons.broken_image), // Placeholder for missing image
//
//                     title: Text(product.designerName ?? 'Unnamed Product'), // Use 'prodName' instead of 'name'
//
//                     subtitle: Text(product.designerName ?? 'No designer'), // This one was likely correct
//
//                     trailing: Text(
//                         product.actualPrice?.toString() ?? 'N/A' // Use 'actualPrice1' instead of 'price'
//                     ),
//                   );
//                 },
//               );
//             } else if (state is CategoryProductsError) {
//               return Center(child: Text(state.message));
//             } else {
//               return const Center(child: Text('Something went wrong.'));
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
//
//
// import 'package:flutter/material.dart';
//
// class MenuCategoriesScreen extends StatelessWidget {
//   // 1. Declare a final variable to hold the category name
//   final String categoryName;
//
//   // 2. Add it to the constructor as a required parameter
//   const MenuCategoriesScreen({
//     Key? key,
//     required this.categoryName,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // 3. Use the categoryName dynamically, for example, in the AppBar title
//       appBar: AppBar(
//         title: Text(categoryName),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               'Sub-categories for',
//               style: Theme.of(context).textTheme.headlineSmall,
//             ),
//             SizedBox(height: 8),
//             Text(
//               categoryName,
//               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             // TODO: Here you would typically use this 'categoryName'
//             // to fetch and display the sub-categories or products
//             // associated with it, likely using another BLoC.
//           ],
//         ),
//       ),
//     );
//   }
// }