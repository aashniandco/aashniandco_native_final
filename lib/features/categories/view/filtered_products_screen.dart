import 'package:aashniandco/features/categories/repository/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
// Import your new BLoC and related files
import '../../../common/common_app_bar.dart';
import '../../../common/common_bottom_nav_bar.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
// import '../../newin_catTab/repository/api_service.dart';
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../bloc/filtered_products_state.dart'; // Reuse the Product model
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import your BLoC, models, and other necessary files
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart'; // Reuse the Product model
import '../../newin/view/product_details_newin.dart'; // For navigation to detail screen
import 'dart:convert'; // For jsonEncode in onTap
import 'package:intl/intl.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/product_details_newin.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert'; // For jsonEncode in onTap

// Import your BLoC, models, and other necessary files
import '../bloc/filtered_products_bloc.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/product_details_newin.dart';



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Assuming you have these files and classes in your project:
// - blocs/filtered_products/filtered_products_bloc.dart (with states and events)
// - blocs/currency/currency_bloc.dart (with states like CurrencyLoaded)
// - models/product_model.dart (the Product class)
// - ui/screens/product_detail_screen.dart (ProductDetailNewInDetailScreen)

class FilteredProductsScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName; // Added categoryName
  final List<Map<String, dynamic>> selectedFilters;

  const FilteredProductsScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName, // Added categoryName
    required this.selectedFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
    if (appBarTitle.length > 2500) appBarTitle = 'Filtered Results';

    return BlocProvider(
      create: (context) => FilteredProductsBloc(),
      child: _FilteredProductsView(
        headerTitle: appBarTitle,
        categoryId: categoryId,
        categoryName: categoryName, // Pass categoryName
        selectedFilters: selectedFilters,
      ),
    );
  }
}

class _FilteredProductsView extends StatefulWidget {
  final String headerTitle;
  final String categoryId;
  final String categoryName; // Added categoryName
  final List<Map<String, dynamic>> selectedFilters;

  const _FilteredProductsView({
    required this.headerTitle,
    required this.categoryId,
    required this.categoryName, // Added categoryName
    required this.selectedFilters,
  });

  @override
  State<_FilteredProductsView> createState() => _FilteredProductsViewState();
}

class _FilteredProductsViewState extends State<_FilteredProductsView> {
  final ScrollController _scrollController = ScrollController();
  late List<Map<String, dynamic>> _allFilters;

  int _currentPage = 0;
  bool _isLoadingMore = false;

  late String _currentCategoryId;
  late String _currentCategoryName;

  bool _isNavBarVisible = true;
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _categoryMetadata;

  @override
  void initState() {
    super.initState();

    _currentCategoryId = widget.categoryId;
    _currentCategoryName = widget.categoryName;

    List<Map<String, dynamic>> allActiveFilters = List.from(widget.selectedFilters);

    // Logic for Designers (Specific ID check)
    bool isSpecificDesigner = (_currentCategoryId == "1375" && _currentCategoryName != "Designers");
    if (isSpecificDesigner) {
      bool hasDesignerFilter = allActiveFilters.any((f) => f['type'] == 'designer_name');
      if (!hasDesignerFilter) {
        allActiveFilters.add({
          'id': _currentCategoryName,
          'type': 'designer_name',
          'name': _currentCategoryName
        });
      }
    }

    // Ensure Category filter exists
    bool hasCategoryFilter = allActiveFilters.any((filter) => filter['type'] == 'categories');
    if (!hasCategoryFilter) {
      allActiveFilters.insert(0, {'id': widget.categoryId, 'type': 'categories'});
    }
    _allFilters = allActiveFilters;

    context.read<FilteredProductsBloc>().add(
      FetchFilteredProducts(
        selectedFilters: _allFilters,
        page: _currentPage,
        sortOrder: "Latest",
      ),
    );

    _scrollController.addListener(_onScroll);
    _fetchCategoryMetadata(widget.categoryName);
  }

  // --- ✅ FIXED: CLOSE SCREEN WHEN LAST FILTER REMOVED ---
  void _removeFilter(int index) {
    setState(() {
      _allFilters.removeAt(index);
    });

    // 1. Check if filters are empty
    if (_allFilters.isEmpty) {
      // If no filters are left, GO BACK to the previous screen (Menu/Home)
      Navigator.pop(context);
      return;
    }

    // 2. If filters still exist, fetch new data
    setState(() {
      _currentPage = 0;
    });

    context.read<FilteredProductsBloc>().add(
      FetchFilteredProducts(
        selectedFilters: _allFilters,
        page: 0,
        sortOrder: "Latest",
      ),
    );
  }

  void _fetchCategoryMetadata(String categoryName) {
    _categoryMetadata = _apiService.fetchCategoryMetadataByName(categoryName);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final direction = _scrollController.position.userScrollDirection;
    if (direction == ScrollDirection.reverse && _isNavBarVisible) {
      setState(() => _isNavBarVisible = false);
    } else if (direction == ScrollDirection.forward && !_isNavBarVisible) {
      setState(() => _isNavBarVisible = true);
    }

    if (_isBottom) {
      if (_isLoadingMore) return;

      final currentState = context.read<FilteredProductsBloc>().state;

      if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
        setState(() {
          _isLoadingMore = true;
          _currentPage++;
        });

        context.read<FilteredProductsBloc>().add(
          FetchFilteredProducts(
            selectedFilters: _allFilters,
            page: _currentPage,
            sortOrder: currentState.currentSort,
          ),
        );
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;

    return Scaffold(
      // --- ✅ FIXED: APP BAR TITLE IS NOW STATIC (Menu Name) ---
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        titleWidget: Text(
          _currentCategoryName, // ✅ Shows "Women's Clothing", "Jewellery", etc.
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 16, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,

      body: BlocListener<FilteredProductsBloc, FilteredProductsState>(
        listener: (context, state) {
          if (state is FilteredProductsLoaded || state is FilteredProductsError) {
            setState(() {
              _isLoadingMore = false;
            });
          }
        },
        child: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
          builder: (context, state) {
            // --- SUCCESS STATE ---
            if (state is FilteredProductsLoaded) {
              return Column(
                children: [
                  // Sort/Filter Buttons Header
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildSortHeader(state),
                  ),

                  // Chip List
                  _buildActiveFilterChips(),

                  // Product Grid
                  if (state.products.isEmpty)
                    const Expanded(
                        child: Center(child: Text("No products found."))
                    )
                  else
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: GridView.builder(
                          controller: _scrollController,
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
                              return _buildShimmerCard();
                            }
                            final product = state.products[index];
                            return _buildProductCard(product);
                          },
                        ),
                      ),
                    ),
                ],
              );
            }

            // --- ERROR STATE ---
            if (state is FilteredProductsError) {
              return Center(child: Text(state.message));
            }

            // --- LOADING STATE ---
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
          },
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: _isNavBarVisible ? navBarHeight : 0,
        child: Wrap(
          children: const [
            CommonBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  // --- Sort Header ---
  Widget _buildSortHeader(FilteredProductsLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFilterButton(),
        Container(
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(6),
          ),
          child: DropdownButton<String>(
            value: state.currentSort,
            icon: const Icon(Icons.sort, color: Colors.black),
            underline: Container(),
            onChanged: (value) {
              if (value != null && value != state.currentSort) {
                setState(() {
                  _currentPage = 0;
                });
                context.read<FilteredProductsBloc>().add(
                  FetchFilteredProducts(
                    selectedFilters: _allFilters,
                    page: 0,
                    sortOrder: value,
                  ),
                );
              }
            },
            items: const [
              DropdownMenuItem(value: "Latest", child: Text("Latest", style: TextStyle(color: Colors.black, fontSize: 14))),
              DropdownMenuItem(value: "Hight to Low", child: Text("Price: High to Low", style: TextStyle(color: Colors.black, fontSize: 14))),
              DropdownMenuItem(value: "Low to High", child: Text("Price: Low to High", style: TextStyle(color: Colors.black, fontSize: 14))),
            ],
          ),
        ),
      ],
    );
  }

  // --- Filter Button ---
  Widget _buildFilterButton() {
    if (widget.categoryName == "Filtered Results") {
      return _enabledFilterButton(widget.categoryId);
    }
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoryMetadata,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return TextButton.icon(
            onPressed: null,
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            label: const Text('Filter', style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }
        if (snapshot.hasData && !snapshot.hasError) {
          final categoryData = snapshot.data!;
          final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
          return _enabledFilterButton(parentCategoryId.isNotEmpty ? parentCategoryId : widget.categoryId);
        }
        return _enabledFilterButton(widget.categoryId);
      },
    );
  }

  Widget _enabledFilterButton(String targetCategoryId) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: Colors.black,
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: () async {
        final result = await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => BlocProvider.value(
            value: BlocProvider.of<FilteredProductsBloc>(context),
            child: FilterBottomSheetCategories(
              categoryId: targetCategoryId,
              initialFilters: _allFilters,
              isFromFilteredScreen: true,
            ),
          ),
        );

        if (result != null && result is Map<String, dynamic>) {
          final List<Map<String, dynamic>> newFilters = List<Map<String, dynamic>>.from(result['filters']);
          final String newCatId = result['categoryId'] ?? _currentCategoryId;
          final String newCatName = result['categoryName'] ?? _currentCategoryName;

          setState(() {
            _allFilters = newFilters;
            _currentCategoryId = newCatId;
            _currentCategoryName = newCatName;
            _currentPage = 0;
            _updateTitle();
          });

          _fetchCategoryMetadata(newCatName);

          context.read<FilteredProductsBloc>().add(
            FetchFilteredProducts(
              selectedFilters: _allFilters,
              page: 0,
              sortOrder: "Latest",
            ),
          );
        }
      },
      icon: const Icon(Icons.filter_list),
      label: const Text('Filter', style: TextStyle(fontSize: 16, color: Colors.black)),
    );
  }

  void _updateTitle() {
    // Only used if you wanted to update a local variable,
    // but we are now using _currentCategoryName in the AppBar directly.
  }

  //17/12/2025
  // --- Chips ---
  // Widget _buildActiveFilterChips() {
  //   if (_allFilters.isEmpty) return const SizedBox.shrink();
  //
  //   return Container(
  //     height: 50,
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: ListView.separated(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       scrollDirection: Axis.horizontal,
  //       itemCount: _allFilters.length,
  //       separatorBuilder: (context, index) => const SizedBox(width: 8),
  //       itemBuilder: (context, index) {
  //         final filter = _allFilters[index];
  //         return Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(20),
  //             border: Border.all(color: Colors.grey[300]!),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               Text(
  //                 filter['name'] ?? '',
  //                 style: const TextStyle(fontSize: 13, color: Colors.black87),
  //               ),
  //               const SizedBox(width: 6),
  //               GestureDetector(
  //                 onTap: () => _removeFilter(index), // Remove logic
  //                 child: const Icon(Icons.close, size: 16, color: Colors.grey),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildActiveFilterChips() {
    // 1. FILTER the list to only show items that HAVE a name.
    // This removes that "ghost" X icon caused by the category filter in initState.
    final visibleFilters = _allFilters.where((filter) =>
    filter.containsKey('name') &&
        filter['name'] != null &&
        filter['name'].toString().isNotEmpty
    ).toList();

    if (visibleFilters.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 50,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: visibleFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = visibleFilters[index];

          // Identify the correct index in the master list for deletion
          final masterIndex = _allFilters.indexOf(filter);

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
                // 2. FILTER NAME FIRST
                Text(
                  filter['name'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 8),
                // 3. CIRCULAR X ICON SECOND (Matches your "Boots" image)
                GestureDetector(
                  onTap: () => _removeFilter(masterIndex),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF333333), // Dark circular background
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 12, // Small white cross
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Updated Chips with X before Name ---
  // Widget _buildActiveFilterChips() {
  //   if (_allFilters.isEmpty) return const SizedBox.shrink();
  //
  //   return Container(
  //     height: 50,
  //     width: double.infinity,
  //     padding: const EdgeInsets.symmetric(vertical: 8),
  //     child: ListView.separated(
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       scrollDirection: Axis.horizontal,
  //       // Removed the +1 to ensure you don't get an extra "X" box at the start
  //       itemCount: _allFilters.length,
  //       separatorBuilder: (context, index) => const SizedBox(width: 8),
  //       itemBuilder: (context, index) {
  //         final filter = _allFilters[index];
  //
  //         return Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(20),
  //             border: Border.all(color: Colors.grey[300]!),
  //           ),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               // 1. FILTER NAME FIRST
  //               Text(
  //                 filter['name'] ?? '',
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   color: Colors.black87,
  //                   fontWeight: FontWeight.w400,
  //                 ),
  //               ),
  //               const SizedBox(width: 8),
  //               // 2. CIRCULAR X ICON SECOND
  //               GestureDetector(
  //                 onTap: () => _removeFilter(index),
  //                 child: Container(
  //                   padding: const EdgeInsets.all(2),
  //                   decoration: const BoxDecoration(
  //                     color: Color(0xFF333333), // Dark grey/black circle
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: const Icon(
  //                     Icons.close,
  //                     size: 12, // Small white cross
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }

  // --- Shimmer ---
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
            Container(height: 250, color: Colors.grey[300]),
            Expanded(child: Container(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // --- Product Card ---
  Widget _buildProductCard(Product product) {
    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double displayPrice = product.actualPrice ?? 0.0;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      final rate = currencyState.selectedRate.rate;
      displayPrice = (product.actualPrice ?? 0.0) * (rate > 0 ? rate : 1.0);
    }

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
            builder: (context) => ProductDetailNewInDetailScreen(product: product.toJson()),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        elevation: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              product.prodSmallImg ?? '',
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, color: Colors.grey),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(product.designerName ?? "Unknown", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(product.shortDesc ?? "No description", style: const TextStyle(fontSize: 12, color: Colors.black), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Text(
                      priceFormatter.format(displayPrice),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),

                    //2/1/2026
                    // Text("$displaySymbol${displayPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
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

//14/12/2025
// class FilteredProductsScreen extends StatelessWidget {
//   final String categoryId;
//   final String categoryName; // Added categoryName
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.categoryName, // Added categoryName
//     required this.selectedFilters,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 2500) appBarTitle = 'Filtered Results';
//
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc(),
//       child: _FilteredProductsView(
//         headerTitle: appBarTitle,
//         categoryId: categoryId,
//         categoryName: categoryName, // Pass categoryName
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }
//
// class _FilteredProductsView extends StatefulWidget {
//   final String headerTitle;
//   final String categoryId;
//   final String categoryName; // Added categoryName
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     required this.headerTitle,
//     required this.categoryId,
//     required this.categoryName, // Added categoryName
//     required this.selectedFilters,
//   });
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//   // late final List<Map<String, dynamic>> _allFilters;
//   late List<Map<String, dynamic>> _allFilters;
//
//   int _currentPage = 0;
//   bool _isLoadingMore = false;
//
//   late String _currentCategoryId;
//   late String _currentCategoryName;
//
//   String _displayTitle = "";
//
//
//   bool _isNavBarVisible = true;
//   final ApiService _apiService = ApiService(); // Initialize ApiService
//   late Future<Map<String, dynamic>> _categoryMetadata; // Declare Future
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     _currentCategoryId = widget.categoryId;
//     _currentCategoryName = widget.categoryName;
//
//     List<Map<String, dynamic>> allActiveFilters =
//     List.from(widget.selectedFilters);
//
//
//     bool isSpecificDesigner = (_currentCategoryId == "1375" && _currentCategoryName != "Designers");
//
//     if (isSpecificDesigner) {
//       // 1. Ensure we filter by the DESIGNER NAME
//       bool hasDesignerFilter = allActiveFilters.any((f) => f['type'] == 'designer_name');
//       if (!hasDesignerFilter) {
//         allActiveFilters.add({
//           'id': _currentCategoryName, // e.g. "11 Tareng"
//           'type': 'designer_name', // This triggers the specific query in Bloc
//           'name': _currentCategoryName
//         });
//       }}
//     bool hasCategoryFilter =
//     allActiveFilters.any((filter) => filter['type'] == 'categories');
//     if (!hasCategoryFilter) {
//       allActiveFilters
//           .insert(0, {'id': widget.categoryId, 'type': 'categories'});
//     }
//     _allFilters = allActiveFilters;
//
//     _updateTitle();
//
//     context.read<FilteredProductsBloc>().add(
//       FetchFilteredProducts(
//         selectedFilters: _allFilters,
//         page: _currentPage,
//         sortOrder: "Latest",
//       ),
//     );
//
//     _scrollController.addListener(_onScroll);
//     _fetchCategoryMetadata(widget.categoryName);
//     // Fetch category metadata using categoryName
//     // _categoryMetadata =
//     //     _apiService.fetchCategoryMetadataByName(widget.categoryName);
//   }
//
//   void _fetchCategoryMetadata(String categoryName) {
//     _categoryMetadata = _apiService.fetchCategoryMetadataByName(categoryName);
//     // You might want to trigger a setState here if you want to rebuild
//     // the FutureBuilder immediately after updating _categoryMetadata.
//     // However, since it's a Future, the FutureBuilder will react when it resolves.
//   }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   // void _onScroll() {
//   //   // --- Navbar Visibility Logic ---
//   //   final direction = _scrollController.position.userScrollDirection;
//   //   if (direction == ScrollDirection.reverse) {
//   //     // User is scrolling down
//   //     if (_isNavBarVisible) {
//   //       setState(() => _isNavBarVisible = false);
//   //     }
//   //   } else if (direction == ScrollDirection.forward) {
//   //     // User is scrolling up
//   //     if (!_isNavBarVisible) {
//   //       setState(() => _isNavBarVisible = true);
//   //     }
//   //   }
//   //
//   //   // --- Pagination Logic (Your existing code) ---
//   //   if (_isBottom) {
//   //     final currentState = context.read<FilteredProductsBloc>().state;
//   //     if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//   //       final nextPage = _currentPage + 1;
//   //       setState(() => _currentPage = nextPage);
//   //       context.read<FilteredProductsBloc>().add(
//   //         FetchFilteredProducts(
//   //           selectedFilters: _allFilters,
//   //           page: nextPage,
//   //           sortOrder: currentState.currentSort,
//   //         ),
//   //       );
//   //     }
//   //   }
//   // }
//
//   // bool get _isBottom {
//   //   if (!_scrollController.hasClients) return false;
//   //   final maxScroll = _scrollController.position.maxScrollExtent;
//   //   final currentScroll = _scrollController.position.pixels;
//   //   return currentScroll >= (maxScroll * 0.9);
//   // }
//
//   void _onScroll() {
//     // --- Navbar Logic ---
//     final direction = _scrollController.position.userScrollDirection;
//     if (direction == ScrollDirection.reverse && _isNavBarVisible) {
//       setState(() => _isNavBarVisible = false);
//     } else if (direction == ScrollDirection.forward && !_isNavBarVisible) {
//       setState(() => _isNavBarVisible = true);
//     }
//
//     // --- ✅ FIX 2: Correct Pagination Logic ---
//     if (_isBottom) {
//       // 1. Check if we are ALREADY loading. If yes, STOP.
//       if (_isLoadingMore) return;
//
//       final currentState = context.read<FilteredProductsBloc>().state;
//
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//
//         // 2. Set the lock to TRUE immediately
//         setState(() {
//           _isLoadingMore = true;
//           _currentPage++; // Increment page safely once
//         });
//
//         // 3. Trigger the event
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: _allFilters,
//             page: _currentPage,
//             sortOrder: currentState.currentSort,
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   void _updateTitle() {
//     // Get all names from the filter list
//     // We use a Set to avoid duplicates if the API returns weird data
//     final names = _allFilters
//         .map((f) => f['name'].toString())
//         .where((name) => name.isNotEmpty && name != 'null')
//         .toSet()
//         .toList();
//
//     String newTitle = names.join(', ');
//
//     // Fallback if empty
//     if (newTitle.isEmpty) {
//       newTitle = "Filtered Results";
//     }
//
//     // Update the local variable (no setState needed if called inside initState)
//     _displayTitle = newTitle;
//   }
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     final double navBarHeight =
//         kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
//
//     return Scaffold(
//       appBar: CommonAppBar(
//         automaticallyImplyLeading: true,
//         titleWidget: Text(
//           _displayTitle,
//           maxLines: 1,
//           overflow: TextOverflow.ellipsis,
//           style: const TextStyle(fontSize: 16, color: Colors.black), // Ensure text fits
//         ),
//         // titleWidget: Text(widget.headerTitle),
//       ),
//       backgroundColor: Colors.white,
//
//       // ✅ 1. Wrap body in BlocListener
//       body: BlocListener<FilteredProductsBloc, FilteredProductsState>(
//         listener: (context, state) {
//           if (state is FilteredProductsLoaded ||
//               state is FilteredProductsError) {
//             // When data arrives or fails, release the lock so we can scroll again
//             setState(() {
//               _isLoadingMore = false;
//             });
//           }
//         },
//         child: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//           builder: (context, state) {
//             // --- SUCCESS STATE ---
//             if (state is FilteredProductsLoaded) {
//               if (state.products.isEmpty) {
//                 return const Center(
//                     child: Text("No products found for this filter."));
//               }
//
//               return Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   children: [
//                     _buildSortHeader(state),
//                     const SizedBox(height: 10),
//                     Expanded(
//                       child: GridView.builder(
//                         controller: _scrollController,
//                         itemCount: state.hasReachedEnd
//                             ? state.products.length
//                             : state.products.length + 1,
//                         gridDelegate:
//                         const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2,
//                           crossAxisSpacing: 10,
//                           mainAxisSpacing: 10,
//                           childAspectRatio: 0.5,
//                         ),
//                         itemBuilder: (context, index) {
//                           if (index >= state.products.length) {
//                             // Shimmer for pagination loading
//                             return _buildShimmerCard();
//                           }
//                           final product = state.products[index];
//                           return _buildProductCard(product);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//
//             // --- ERROR STATE ---
//             if (state is FilteredProductsError) {
//               return Center(child: Text(state.message));
//             }
//
//             // --- INITIAL / LOADING STATE ---
//             return GridView.builder(
//               padding: const EdgeInsets.all(8),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//                 childAspectRatio: 0.5,
//               ),
//               itemCount: 6,
//               itemBuilder: (context, index) => _buildShimmerCard(),
//             );
//           },
//         ),
//       ), // ✅ CLOSE BLOC LISTENER HERE
//
//       // ✅ 2. Now bottomNavigationBar is inside Scaffold
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//         height: _isNavBarVisible ? navBarHeight : 0,
//         child: Wrap(
//           children: const [
//             CommonBottomNavBar(currentIndex: 0),
//           ],
//         ),
//       ),
//     ); // ✅ CLOSE SCAFFOLD HERE
//   }
//   // Widget build(BuildContext context) {
//   //   final double navBarHeight =
//   //       kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
//   //
//   //   return Scaffold(
//   //
//   //     appBar: CommonAppBar(
//   //       automaticallyImplyLeading: true,
//   //       titleWidget: Text(widget.headerTitle),
//   //     ),
//   //     backgroundColor: Colors.white,
//   //     body:
//   //
//   //     BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//   //       builder: (context, state) {
//   //         // --- ✅ 1. SUCCESS STATE ---
//   //         if (state is FilteredProductsLoaded) {
//   //           if (state.products.isEmpty) {
//   //             return const Center(
//   //                 child: Text("No products found for this filter."));
//   //           }
//   //
//   //           return Padding(
//   //             padding: const EdgeInsets.all(8.0),
//   //             child: Column(
//   //               children: [
//   //                 _buildSortHeader(state),
//   //                 const SizedBox(height: 10),
//   //                 Expanded(
//   //                   child: GridView.builder(
//   //                     controller: _scrollController,
//   //                     itemCount: state.hasReachedEnd
//   //                         ? state.products.length
//   //                         : state.products.length + 1,
//   //                     gridDelegate:
//   //                     const SliverGridDelegateWithFixedCrossAxisCount(
//   //                       crossAxisCount: 2,
//   //                       crossAxisSpacing: 10,
//   //                       mainAxisSpacing: 10,
//   //                       childAspectRatio: 0.5,
//   //                     ),
//   //                     itemBuilder: (context, index) {
//   //                       if (index >= state.products.length) {
//   //                         // ✅ shimmer for pagination loading
//   //                         return _buildShimmerCard();
//   //                       }
//   //                       final product = state.products[index];
//   //                       return _buildProductCard(product);
//   //                     },
//   //                   ),
//   //                 ),
//   //               ],
//   //             ),
//   //           );
//   //         }
//   //
//   //         // --- ✅ 2. ERROR STATE ---
//   //         if (state is FilteredProductsError) {
//   //           return Center(child: Text(state.message));
//   //         }
//   //
//   //         // --- ✅ 3. INITIAL / LOADING STATE ---
//   //         return GridView.builder(
//   //           padding: const EdgeInsets.all(8),
//   //           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//   //             crossAxisCount: 2,
//   //             crossAxisSpacing: 10,
//   //             mainAxisSpacing: 10,
//   //             childAspectRatio: 0.5,
//   //           ),
//   //           itemCount: 6,
//   //           itemBuilder: (context, index) => _buildShimmerCard(),
//   //         );
//   //       },
//   //     ),
//   //     bottomNavigationBar: AnimatedContainer(
//   //       duration: const Duration(milliseconds: 250),
//   //       curve: Curves.easeOut,
//   //       // Animate the height to show/hide the navbar
//   //       height: _isNavBarVisible ? navBarHeight : 0,
//   //       // Use a Wrap to prevent layout errors during animation
//   //       child: Wrap(
//   //         children: const [
//   //           // Use a neutral index like 3 so a main tab isn't highlighted
//   //           CommonBottomNavBar(currentIndex: 0),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildSortHeader(FilteredProductsLoaded state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         // Filter button added here
//         _buildFilterButton(),
//         // Flexible(
//         //   child: Text(
//         //     widget.headerTitle,
//         //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         //     overflow: TextOverflow.ellipsis,
//         //   ),
//         // ),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: state.currentSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != state.currentSort) {
//                 setState(() {
//                   _currentPage = 0;
//                 });
//                 context.read<FilteredProductsBloc>().add(
//                   FetchFilteredProducts(
//                     selectedFilters: _allFilters,
//                     page: 0,
//                     sortOrder: value,
//                   ),
//                 );
//               }
//             },
//             items: const [
//               DropdownMenuItem(
//                 value: "Latest",
//                 child:
//                 Text("Latest", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem(
//                 value: "Hight to Low",
//                 child: Text("Price: High to Low",
//                     style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem(
//                 value: "Low to High",
//                 child: Text("Price: Low to High",
//                     style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Inside _FilteredProductsViewState
//
//   // Inside _FilteredProductsViewState
//
// // --- Filter Button Widget ---
//   Widget _buildFilterButton() {
//     // 1. FAST PATH: If name is "Filtered Results", we know the API will fail (404).
//     // Directly enable the button using the current category ID.
//     if (widget.categoryName == "Filtered Results") {
//       return _enabledFilterButton(widget.categoryId);
//     }
//
//     return FutureBuilder<Map<String, dynamic>>(
//       future: _categoryMetadata,
//       builder: (context, snapshot) {
//         // 2. LOADING STATE
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return TextButton.icon(
//             onPressed: null,
//             icon: const Icon(Icons.filter_list, color: Colors.grey),
//             label: const Text('Filter', style: TextStyle(fontSize: 16, color: Colors.grey)),
//           );
//         }
//
//         // 3. SUCCESS STATE
//         if (snapshot.hasData && !snapshot.hasError) {
//           final categoryData = snapshot.data!;
//           // Try to get parent ID (original logic), but fallback to current ID if missing
//           final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
//
//           // If parent ID exists, use it. Otherwise use the current categoryId.
//           return _enabledFilterButton(
//               parentCategoryId.isNotEmpty ? parentCategoryId : widget.categoryId
//           );
//         }
//
//         // 4. ERROR STATE (Fallback):
//         // If API fails (e.g. 404 not found), don't disable the button.
//         // Just use the ID we already have.
//         return _enabledFilterButton(widget.categoryId);
//       },
//     );
//   }
//
//   // Inside _FilteredProductsViewState class
// //10F
//   Widget _enabledFilterButton(String targetCategoryId) {
//     return TextButton.icon(
//       style: TextButton.styleFrom(
//         foregroundColor: Colors.black,
//         padding: EdgeInsets.zero,
//         tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//       ),
//       onPressed: () async {
//         // ✅ 1. Await the result from the bottom sheet
//         final result = await showModalBottomSheet(
//           context: context,
//           isScrollControlled: true,
//           backgroundColor: Colors.transparent,
//           builder: (_) => BlocProvider.value(
//             value: BlocProvider.of<FilteredProductsBloc>(context),
//             child: FilterBottomSheetCategories(
//               categoryId: targetCategoryId,
//               initialFilters: _allFilters,
//               // ✅ 2. THIS IS THE KEY FIX:
//               // You MUST set this to true, or it will behave like the Home screen
//               isFromFilteredScreen: true,
//             ),
//           ),
//         );
//
//         // ✅ 3. Update the CURRENT screen instead of navigating
//         if (result != null && result is Map<String, dynamic>) {
//           final List<Map<String, dynamic>> newFilters =
//           List<Map<String, dynamic>>.from(result['filters']);
//
//           final String newCatId = result['categoryId'] ?? _currentCategoryId;
//           final String newCatName = result['categoryName'] ?? _currentCategoryName;
//
//           setState(() {
//             _allFilters = newFilters;
//             _currentCategoryId = newCatId; // Update local tracking
//             _currentCategoryName = newCatName;
//             _currentPage = 0; // Reset pagination
//             // Update ID if category changed (optional)
//             // widget.categoryId = result['categoryId'];
//             _updateTitle();
//           });
//
//           _fetchCategoryMetadata(newCatName);
//
//           // Refresh the data on THIS screen
//           context.read<FilteredProductsBloc>().add(
//             FetchFilteredProducts(
//               selectedFilters: _allFilters,
//               page: 0,
//               sortOrder: "Latest", // Or your current sort variable
//             ),
//           );
//         }
//       },
//       icon: const Icon(Icons.filter_list),
//       label: const Text(
//         'Filter',
//         style: TextStyle(fontSize: 16, color: Colors.black),
//       ),
//     );
//   }
//   //10/12/2025
//   // Helper method to create the clickable button
//   // Widget _enabledFilterButton(String targetCategoryId) {
//   //   return TextButton.icon(
//   //     style: TextButton.styleFrom(
//   //       foregroundColor: Colors.black,
//   //       padding: EdgeInsets.zero,
//   //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//   //     ),
//   //     onPressed: () {
//   //       showModalBottomSheet(
//   //         context: context,
//   //         isScrollControlled: true,
//   //         backgroundColor: Colors.transparent,
//   //         builder: (_) => BlocProvider.value(
//   //           value: BlocProvider.of<FilteredProductsBloc>(context),
//   //           child: FilterBottomSheetCategories(
//   //             categoryId: targetCategoryId,
//   //             initialFilters: _allFilters,
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //     icon: const Icon(Icons.filter_list),
//   //     label: const Text(
//   //       'Filter',
//   //       style: TextStyle(
//   //         fontSize: 16,
//   //         color: Colors.black,
//   //       ),
//   //     ),
//   //   );
//   // }
// //5/12/2025
//   // --- Filter Button Widget ---
//   // Widget _buildFilterButton() {
//   //   return FutureBuilder<Map<String, dynamic>>(
//   //     future: _categoryMetadata,
//   //     builder: (context, snapshot) {
//   //       final bool canFilter =
//   //           snapshot.connectionState == ConnectionState.done &&
//   //               !snapshot.hasError;
//   //
//   //       return TextButton.icon(
//   //         style: TextButton.styleFrom(
//   //           foregroundColor: Colors.black,
//   //           padding: EdgeInsets.zero,
//   //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//   //         ),
//   //         onPressed: canFilter
//   //             ? () {
//   //           final categoryData = snapshot.data!;
//   //           final String parentCategoryId =
//   //               categoryData['pare_cat_id']?.toString() ?? '';
//   //           if (parentCategoryId.isNotEmpty) {
//   //             showModalBottomSheet(
//   //               context: context,
//   //               isScrollControlled: true,
//   //               backgroundColor: Colors.transparent,
//   //               builder: (_) => BlocProvider.value(
//   //                 value: BlocProvider.of<FilteredProductsBloc>(context),
//   //                 child: FilterBottomSheetCategories(
//   //                   categoryId: parentCategoryId,
//   //                   initialFilters: _allFilters,
//   //                 ),
//   //               ),
//   //             );
//   //           } else {
//   //             ScaffoldMessenger.of(context).showSnackBar(
//   //               const SnackBar(
//   //                   content:
//   //                   Text("Filter not available for this category.")),
//   //             );
//   //           }
//   //         }
//   //             : null,
//   //         icon: const Icon(Icons.filter_list),
//   //         label: Text(
//   //           'Filter',
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             color: canFilter ? Colors.black : Colors.grey,
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//
//   // --- ✅ SHIMMER CARD PLACEHOLDER ---
//   Widget _buildShimmerCard() {
//     return Card(
//       color: Colors.white,
//       elevation: 1,
//       clipBehavior: Clip.antiAlias,
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Container(height: 250, color: Colors.grey[300]),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 14,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Container(
//                       height: 12,
//                       width: double.infinity,
//                       margin: const EdgeInsets.symmetric(vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     Container(
//                       height: 12,
//                       width: double.infinity,
//                       margin: const EdgeInsets.symmetric(vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       height: 14,
//                       width: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
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
//   // --- ✅ PRODUCT CARD WITH CURRENCY SUPPORT ---
//   Widget _buildProductCard(Product product) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     String displaySymbol = '₹';
//     double displayPrice = product.actualPrice ?? 0.0;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       final rate = currencyState.selectedRate.rate;
//       displayPrice = (product.actualPrice ?? 0.0) * (rate > 0 ? rate : 1.0);
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
//         clipBehavior: Clip.antiAlias,
//         elevation: 1,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               product.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (c, e, s) => Container(
//                 height: 250,
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.broken_image, color: Colors.grey),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       product.designerName ?? "Unknown Designer",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       product.shortDesc ?? "No description",
//                       style: const TextStyle(fontSize: 12, color: Colors.black),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(
//                           fontWeight: FontWeight.bold, fontSize: 14),
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

//*
//7/11/2025
// class FilteredProductsScreen extends StatelessWidget {
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.selectedFilters,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 25) appBarTitle = 'Filtered Results';
//
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc(),
//       child: _FilteredProductsView(
//         headerTitle: appBarTitle,
//         categoryId: categoryId,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }
//
// class _FilteredProductsView extends StatefulWidget {
//   final String headerTitle;
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     required this.headerTitle,
//     required this.categoryId,
//     required this.selectedFilters,
//   });
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//   late final List<Map<String, dynamic>> _allFilters;
//   int _currentPage = 0;
//
//   bool _isNavBarVisible = true;
//
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     List<Map<String, dynamic>> allActiveFilters = List.from(widget.selectedFilters);
//     bool hasCategoryFilter = allActiveFilters.any((filter) => filter['type'] == 'categories');
//     if (!hasCategoryFilter) {
//       allActiveFilters.insert(0, {'id': widget.categoryId, 'type': 'categories'});
//     }
//     _allFilters = allActiveFilters;
//
//     context.read<FilteredProductsBloc>().add(
//       FetchFilteredProducts(
//         selectedFilters: _allFilters,
//         page: _currentPage,
//         sortOrder: "Latest",
//       ),
//     );
//
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
//   // void _onScroll() {
//   //   if (_isBottom) {
//   //     final currentState = context.read<FilteredProductsBloc>().state;
//   //     if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//   //       final nextPage = _currentPage + 1;
//   //       setState(() {
//   //         _currentPage = nextPage;
//   //       });
//   //       context.read<FilteredProductsBloc>().add(
//   //         FetchFilteredProducts(
//   //           selectedFilters: _allFilters,
//   //           page: nextPage,
//   //           sortOrder: currentState.currentSort,
//   //         ),
//   //       );
//   //     }
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
//     if (_isBottom) {
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         final nextPage = _currentPage + 1;
//         setState(() => _currentPage = nextPage);
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: _allFilters,
//             page: nextPage,
//             sortOrder: currentState.currentSort,
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   //
//   // Widget _buildFilterButton() {
//   //   return FutureBuilder<Map<String, dynamic>>(
//   //     future: _categoryMetadata,
//   //     builder: (context, snapshot) {
//   //       final bool canFilter =
//   //           snapshot.connectionState == ConnectionState.done &&
//   //               !snapshot.hasError;
//   //
//   //       return TextButton.icon(
//   //         style: TextButton.styleFrom(
//   //           foregroundColor: Colors.black,
//   //           padding: EdgeInsets.zero,
//   //           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//   //         ),
//   //         onPressed: canFilter
//   //             ? () {
//   //           final categoryData = snapshot.data!;
//   //           final String parentCategoryId =
//   //               categoryData['pare_cat_id']?.toString() ?? '';
//   //           if (parentCategoryId.isNotEmpty) {
//   //             showModalBottomSheet(
//   //               context: context,
//   //               isScrollControlled: true,
//   //               backgroundColor: Colors.transparent,
//   //               builder: (_) => BlocProvider.value(
//   //                 value: BlocProvider.of<FilteredProductsBloc>(context),
//   //                 child: FilterBottomSheetCategories(
//   //                   categoryId: parentCategoryId,
//   //                 ),
//   //               ),
//   //             );
//   //           } else {
//   //             ScaffoldMessenger.of(context).showSnackBar(
//   //               const SnackBar(
//   //                   content:
//   //                   Text("Filter not available for this category.")),
//   //             );
//   //           }
//   //         }
//   //             : null,
//   //         icon: const Icon(Icons.filter_list),
//   //         label: Text(
//   //           'Filter',
//   //           style: TextStyle(
//   //             fontSize: 16,
//   //             color: canFilter ? Colors.black : Colors.grey,
//   //           ),
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     final double navBarHeight = kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
//
//     return Scaffold(
//       backgroundColor: Colors.red,
//       appBar: CommonAppBar(
//         // This is a sub-screen, so it needs a back button.
//         automaticallyImplyLeading: true,
//         titleWidget: Text(widget.headerTitle),
//       ),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           // --- ✅ 1. SUCCESS STATE ---
//           if (state is FilteredProductsLoaded) {
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   _buildSortHeader(state),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: GridView.builder(
//                       controller: _scrollController,
//                       itemCount: state.hasReachedEnd
//                           ? state.products.length
//                           : state.products.length + 1,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.5,
//                       ),
//                       itemBuilder: (context, index) {
//                         if (index >= state.products.length) {
//                           // ✅ shimmer for pagination loading
//                           return _buildShimmerCard();
//                         }
//                         final product = state.products[index];
//                         return _buildProductCard(product);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           // --- ✅ 2. ERROR STATE ---
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//
//           // --- ✅ 3. INITIAL / LOADING STATE ---
//           return GridView.builder(
//             padding: const EdgeInsets.all(8),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 0.5,
//             ),
//             itemCount: 6,
//             itemBuilder: (context, index) => _buildShimmerCard(),
//           );
//         },
//       ),
//       bottomNavigationBar: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),
//         curve: Curves.easeOut,
//         // Animate the height to show/hide the navbar
//         height: _isNavBarVisible ? navBarHeight : 0,
//         // Use a Wrap to prevent layout errors during animation
//         child: Wrap(
//           children: const [
//             // Use a neutral index like 3 so a main tab isn't highlighted
//             CommonBottomNavBar(currentIndex: 3),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSortHeader(FilteredProductsLoaded state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Flexible(
//           child: Text(
//             widget.headerTitle,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[200],
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: DropdownButton<String>(
//             value: state.currentSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != state.currentSort) {
//                 setState(() {
//                   _currentPage = 0;
//                 });
//                 context.read<FilteredProductsBloc>().add(
//                   FetchFilteredProducts(
//                     selectedFilters: _allFilters,
//                     page: 0,
//                     sortOrder: value,
//                   ),
//                 );
//               }
//             },
//             items: const [
//               DropdownMenuItem(
//                 value: "Latest",
//                 child: Text("Latest", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem(
//                 value: "Hight to Low",
//                 child: Text("Price: High to Low", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem(
//                 value: "Low to High",
//                 child: Text("Price: Low to High", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // --- ✅ SHIMMER CARD PLACEHOLDER ---
//   Widget _buildShimmerCard() {
//     return Card(
//       color: Colors.white,
//       elevation: 1,
//       clipBehavior: Clip.antiAlias,
//       child: Shimmer.fromColors(
//         baseColor: Colors.grey.shade300,
//         highlightColor: Colors.grey.shade100,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Container(height: 250, color: Colors.grey[300]),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       height: 14,
//                       width: 100,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 6),
//                     Container(
//                       height: 12,
//                       width: double.infinity,
//                       margin: const EdgeInsets.symmetric(vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     Container(
//                       height: 12,
//                       width: double.infinity,
//                       margin: const EdgeInsets.symmetric(vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     Container(
//                       height: 14,
//                       width: 60,
//                       decoration: BoxDecoration(
//                         color: Colors.grey[300],
//                         borderRadius: BorderRadius.circular(4),
//                       ),
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
//   // --- ✅ PRODUCT CARD WITH CURRENCY SUPPORT ---
//   Widget _buildProductCard(Product product) {
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     String displaySymbol = '₹';
//     double displayPrice = product.actualPrice ?? 0.0;
//
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       final rate = currencyState.selectedRate.rate;
//       displayPrice = (product.actualPrice ?? 0.0) * (rate > 0 ? rate : 1.0);
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailNewInDetailScreen(product: product.toJson()),
//           ),
//         );
//       },
//       child: Card(
//         color: Colors.white,
//         clipBehavior: Clip.antiAlias,
//         elevation: 1,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               product.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (c, e, s) => Container(
//                 height: 250,
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.broken_image, color: Colors.grey),
//               ),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       product.designerName ?? "Unknown Designer",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                       textAlign: TextAlign.center,
//                       maxLines: 1,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       product.shortDesc ?? "No description",
//                       style: const TextStyle(fontSize: 12, color: Colors.black),
//                       textAlign: TextAlign.center,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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


// old
// class FilteredProductsScreen extends StatelessWidget {
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.selectedFilters,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 25) appBarTitle = 'Filtered Results';
//
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc(),
//       child: _FilteredProductsView(
//         headerTitle: appBarTitle,
//         categoryId: categoryId,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }
//
// class _FilteredProductsView extends StatefulWidget {
//   final String headerTitle;
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     required this.headerTitle,
//     required this.categoryId,
//     required this.selectedFilters,
//   });
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//   late final List<Map<String, dynamic>> _allFilters;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     List<Map<String, dynamic>> allActiveFilters = List.from(widget.selectedFilters);
//     bool hasCategoryFilter = allActiveFilters.any((filter) => filter['type'] == 'categories');
//     if (!hasCategoryFilter) {
//       allActiveFilters.insert(0, {'id': widget.categoryId, 'type': 'categories'});
//     }
//     _allFilters = allActiveFilters;
//
//     context.read<FilteredProductsBloc>().add(
//       FetchFilteredProducts(
//         selectedFilters: _allFilters,
//         page: _currentPage,
//         sortOrder: "Latest",
//       ),
//     );
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
//     if (_isBottom) {
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         final nextPage = _currentPage + 1;
//         setState(() {
//           _currentPage = nextPage;
//         });
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: _allFilters,
//             page: nextPage,
//             sortOrder: currentState.currentSort,
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.headerTitle)),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           // --- NEW, CLEANER BUILD LOGIC ---
//
//           // 1. Handle the main success case first.
//           if (state is FilteredProductsLoaded) {
//             // If the successful load resulted in no products, show a message.
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//             // Otherwise, build the grid.
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   _buildSortHeader(state),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: GridView.builder(
//                       controller: _scrollController,
//                       itemCount: state.hasReachedEnd ? state.products.length : state.products.length + 1,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.5),
//                       itemBuilder: (context, index) {
//                         if (index >= state.products.length) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         final product = state.products[index];
//                         // Call the new helper widget for the product card
//                         return _buildProductCard(product);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           // 2. Handle the error case.
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//
//           // 3. Handle all other cases (Initial, Loading) as a full-screen loader.
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
//
//   Widget _buildSortHeader(FilteredProductsLoaded state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Flexible(
//             child: Text(widget.headerTitle,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis)),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
//           child: DropdownButton<String>(
//             // --- FIX 1: Use the backend-friendly value ---
//             value: state.currentSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != state.currentSort) {
//                 setState(() {
//                   _currentPage = 0; // Reset page counter
//                 });
//                 context.read<FilteredProductsBloc>().add(
//                   FetchFilteredProducts(
//                     selectedFilters: _allFilters,
//                     page: 0,
//                     sortOrder: value, // Pass the new backend-friendly value
//                   ),
//                 );
//               }
//             },
//             // --- FIX 2: Map backend keys to user-friendly text ---
//             items: const [
//               DropdownMenuItem<String>(
//                 value: "Latest", // This will become 'prod_en_id desc'
//                 child: Text("Latest", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem<String>(
//                 value: "price_desc", // This will become 'actual_price_1 desc'
//                 child: Text("Price: High to Low", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//               DropdownMenuItem<String>(
//                 value: "price_asc", // This will become 'actual_price_1 asc'
//                 child: Text("Price: Low to High", style: TextStyle(color: Colors.black, fontSize: 14)),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//   // Helper widget for the top header with title and sort dropdown
//   // Widget _buildSortHeader(FilteredProductsLoaded state) {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       Flexible(
//   //           child: Text(widget.headerTitle,
//   //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//   //               overflow: TextOverflow.ellipsis)),
//   //       Container(
//   //         height: 35,
//   //         padding: const EdgeInsets.symmetric(horizontal: 12),
//   //         decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
//   //         child: DropdownButton<String>(
//   //           value: state.currentSort,
//   //           icon: const Icon(Icons.sort, color: Colors.black),
//   //           underline: Container(),
//   //           onChanged: (value) {
//   //             if (value != null && value != state.currentSort) {
//   //               setState(() {
//   //                 _currentPage = 0; // Reset page counter
//   //               });
//   //               context.read<FilteredProductsBloc>().add(
//   //                 FetchFilteredProducts(
//   //                   selectedFilters: _allFilters,
//   //                   page: 0,
//   //                   sortOrder: value,
//   //                 ),
//   //               );
//   //             }
//   //           },
//   //           // Using more descriptive sort options
//   //           items: ["Latest", "Price: High to Low", "Price: Low to High"].map((sortOption) {
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
//   // --- NEW WIDGET TO HANDLE CURRENCY CONVERSION AND BUILD THE PRODUCT CARD ---
//   Widget _buildProductCard(Product product) {
//     // 1. Watch the global CurrencyBloc state.
//     // This requires a CurrencyBloc to be provided higher up in your widget tree.
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     // Default values, assuming base currency is INR (₹).
//     String displaySymbol = '₹';
//     double displayPrice = product.actualPrice ?? 0.0;
//
//     // 2. If currency is loaded, calculate the new price and symbol.
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       // Ensure rate is not zero to avoid division by zero errors, though unlikely.
//       final rate = currencyState.selectedRate.rate;
//       displayPrice = (product.actualPrice ?? 0.0) * (rate > 0 ? rate : 1.0);
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailNewInDetailScreen(product: product.toJson()),
//           ),
//         );
//       },
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         elevation: 1,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch, // Makes image stretch
//           children: [
//             Image.network(
//               product.prodSmallImg ?? '', // Null-safe image URL
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (c, e, s) => Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.broken_image, color: Colors.grey)),
//             ),
//             Expanded( // Allows the text section to fill the remaining space
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center, // Center aligns content vertically
//                   children: [
//                     Text(product.designerName ?? "Unknown Designer",
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis),
//                     const SizedBox(height: 4),
//                     Text(product.shortDesc ?? "No description",
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis),
//                     const SizedBox(height: 8),
//                     Text(
//                       // 3. Display the calculated price and symbol.
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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

//21/8/2025
// class FilteredProductsScreen extends StatelessWidget {
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.selectedFilters,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 25) appBarTitle = 'Filtered Results';
//
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc(),
//       child: _FilteredProductsView(
//         headerTitle: appBarTitle,
//         categoryId: categoryId,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }
//
// class _FilteredProductsView extends StatefulWidget {
//   final String headerTitle;
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     required this.headerTitle,
//     required this.categoryId,
//     required this.selectedFilters,
//   });
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//   late final List<Map<String, dynamic>> _allFilters;
//   int _currentPage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//
//     List<Map<String, dynamic>> allActiveFilters = List.from(widget.selectedFilters);
//     bool hasCategoryFilter = allActiveFilters.any((filter) => filter['type'] == 'categories');
//
//     if (!hasCategoryFilter) {
//       allActiveFilters.insert(0, {'id': widget.categoryId, 'type': 'categories'});
//     }
//
//     _allFilters = allActiveFilters;
//
//     context.read<FilteredProductsBloc>().add(
//       FetchFilteredProducts(
//         selectedFilters: _allFilters,
//         page: _currentPage,
//         sortOrder: "Latest",
//       ),
//     );
//
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
//     if (_isBottom) {
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         final nextPage = _currentPage + 1;
//         setState(() {
//           _currentPage = nextPage;
//         });
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: _allFilters,
//             page: nextPage,
//             sortOrder: currentState.currentSort,
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.headerTitle)),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           // --- CORRECTED LOGIC ---
//
//           // 1. Handle the main success case first.
//           if (state is FilteredProductsLoaded) {
//             // If the successful load resulted in no products, show a message.
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//             // Otherwise, build the grid.
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   _buildSortHeader(state),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: GridView.builder(
//                       controller: _scrollController,
//                       // The item count logic for the bottom loader is already correct here.
//                       itemCount: state.hasReachedEnd ? state.products.length : state.products.length + 1,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.5),
//                       itemBuilder: (context, index) {
//                         if (index >= state.products.length) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         final product = state.products[index];
//                         return _buildProductCard(product);
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//
//           // 2. Handle the error case.
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//
//           // 3. Handle all other cases (Initial, Loading) as a full-screen loader.
//           // This is the "initial load" state.
//           return const Center(child: CircularProgressIndicator());
//         },
//       ),
//     );
//   }
//
//   Widget _buildSortHeader(FilteredProductsLoaded state) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Flexible(
//             child: Text(widget.headerTitle,
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                 overflow: TextOverflow.ellipsis)),
//         Container(
//           height: 35,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
//           child: DropdownButton<String>(
//             value: state.currentSort,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != state.currentSort) {
//                 setState(() {
//                   _currentPage = 0; // Reset page counter
//                 });
//                 context.read<FilteredProductsBloc>().add(
//                   FetchFilteredProducts(
//                     selectedFilters: _allFilters,
//                     page: 0, // Fetch the first page
//                     sortOrder: value, // With the new sort order
//                   ),
//                 );
//               }
//             },
//             items: ["Latest", "Price: High to Low", "Price: Low to High"].map((sortOption) {
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
//   // --- NEW WIDGET TO HANDLE CURRENCY CONVERSION ---
//   Widget _buildProductCard(Product product) {
//     // 1. Watch the global CurrencyBloc state.
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     // Default values, assuming base currency is INR (₹).
//     String displaySymbol = '₹';
//     double displayPrice = product.actualPrice ?? 0.0;
//
//     // 2. If currency is loaded, calculate the new price and symbol.
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       displayPrice = (product.actualPrice ?? 0.0) * currencyState.selectedRate.rate;
//     }
//
//     return GestureDetector(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ProductDetailNewInDetailScreen(product: product.toJson()),
//           ),
//         );
//       },
//       child: Card(
//         clipBehavior: Clip.antiAlias,
//         elevation: 1,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Image.network(
//               product.prodSmallImg ?? '',
//               height: 250,
//               fit: BoxFit.cover,
//               errorBuilder: (c, e, s) => Container(
//                   height: 250,
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.broken_image, color: Colors.grey)),
//             ),
//             Expanded(
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(product.designerName ?? "Unknown Designer",
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                         textAlign: TextAlign.center,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis),
//                     const SizedBox(height: 4),
//                     Text(product.shortDesc ?? "No description",
//                         style: const TextStyle(fontSize: 12, color: Colors.grey),
//                         textAlign: TextAlign.center,
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis),
//                     const SizedBox(height: 8),
//                     Text(
//                       // 3. Display the calculated price and symbol.
//                       "$displaySymbol${displayPrice.toStringAsFixed(0)}",
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
// The parent widget's only jobs are to receive data and provide the BLoC.
// class FilteredProductsScreen extends StatelessWidget {
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({
//     Key? key,
//     required this.categoryId,
//     required this.selectedFilters,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 25) appBarTitle = 'Filtered Results';
//
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc(),
//       child: _FilteredProductsView(
//         headerTitle: appBarTitle,
//         categoryId: categoryId,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }
//
// class _FilteredProductsView extends StatefulWidget {
//   final String headerTitle;
//   final String categoryId;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     required this.headerTitle,
//     required this.categoryId,
//     required this.selectedFilters,
//   });
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//   late final List<Map<String, dynamic>> _allFilters;
//   // A simple page counter for robust pagination
//   int _currentPage = 0;
//
//   @override
//   // In _FilteredProductsViewState
//
//   @override
//   void initState() {
//     super.initState();
//
//     // --- NEW, SMARTER LOGIC ---
//     // Start with the filters selected from the previous screen.
//     List<Map<String, dynamic>> allActiveFilters = List.from(widget.selectedFilters);
//
//     // Check if a 'categories' filter is already present among the selected ones.
//     // The 'any' method checks if at least one element satisfies the condition.
//     bool hasCategoryFilter = allActiveFilters.any((filter) => filter['type'] == 'categories');
//
//     // If NO category filter was passed from the filter screen,
//     // it means we should use the base categoryId as the primary category filter.
//     if (!hasCategoryFilter) {
//       allActiveFilters.insert(0, {'id': widget.categoryId, 'type': 'categories'});
//     }
//
//     // Now, _allFilters contains the correct, de-duplicated list of filters.
//     _allFilters = allActiveFilters;
//     // --- END OF NEW LOGIC ---
//
//     // Trigger the initial fetch for page 0
//     context.read<FilteredProductsBloc>().add(
//       FetchFilteredProducts(
//         selectedFilters: _allFilters, // Pass the corrected list
//         page: _currentPage,
//         sortOrder: "Latest", // Default sort order
//       ),
//     );
//
//     _scrollController.addListener(_onScroll);
//   }
//   // void initState() {
//   //   super.initState();
//   //
//   //   final baseCategoryFilter = {'id': widget.categoryId, 'type': 'categories'};
//   //   _allFilters = [baseCategoryFilter, ...widget.selectedFilters];
//   //
//   //   // Trigger the initial fetch for page 0
//   //   context.read<FilteredProductsBloc>().add(
//   //     FetchFilteredProducts(
//   //       selectedFilters: _allFilters,
//   //       page: _currentPage, // Start at page 0
//   //       sortOrder: "Latest", // Default sort order
//   //     ),
//   //   );
//   //
//   //   _scrollController.addListener(_onScroll);
//   // }
//
//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _onScroll() {
//     if (_isBottom) {
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         // Dispatch event for the NEXT page
//         final nextPage = _currentPage + 1;
//         setState(() {
//           _currentPage = nextPage;
//         });
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: _allFilters,
//             page: nextPage, // Use the new page number
//             sortOrder: currentState.currentSort, // Keep the current sort order
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.headerTitle)),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           if (state is FilteredProductsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//           if (state is FilteredProductsLoaded) {
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(widget.headerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                       Container(
//                         height: 35,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
//                         child: DropdownButton<String>(
//                           value: state.currentSort,
//                           icon: const Icon(Icons.sort, color: Colors.black),
//                           underline: Container(),
//                           onChanged: (value) {
//                             // --- THIS IS THE KEY CHANGE FOR SORTING ---
//                             // It now triggers a full reset fetch from the server.
//                             if (value != null && value != state.currentSort) {
//                               setState(() {
//                                 _currentPage = 0; // Reset page counter
//                               });
//                               context.read<FilteredProductsBloc>().add(
//                                 FetchFilteredProducts(
//                                   selectedFilters: _allFilters,
//                                   page: 0, // Fetch the first page
//                                   sortOrder: value, // With the new sort order
//                                 ),
//                               );
//                             }
//                           },
//                           items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//                   Expanded(
//                     child: GridView.builder(
//                       controller: _scrollController,
//                       itemCount: state.hasReachedEnd ? state.products.length : state.products.length + 1,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 0.5),
//                       itemBuilder: (context, index) {
//                         if (index >= state.products.length) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         final product = state.products[index];
//                         return GestureDetector(
//                           onTap: () {
//                             Navigator.push(context, MaterialPageRoute(builder: (context) =>
//                                 ProductDetailNewInDetailScreen(product: product.toJson()),
//                             ));
//                           },
//                           child: Card(
//                             clipBehavior: Clip.antiAlias,
//                             elevation: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Image.network(
//                                   product.prodSmallImg,
//                                   width: double.infinity, height: 250, fit: BoxFit.cover,
//                                   errorBuilder: (c, e, s) => Container(width: double.infinity, height: 250, color: Colors.grey[200], child: const Icon(Icons.broken_image, color: Colors.grey)),
//                                 ),
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       Text(product.designerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
//                                       const SizedBox(height: 4),
//                                       Text(product.shortDesc, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
//                                       const SizedBox(height: 8),
//                                       Text("₹${product.actualPrice.toStringAsFixed(0)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }

// class FilteredProductsScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const FilteredProductsScreen({Key? key, required this.selectedFilters}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // Create a title based on selected filters for the AppBar
//     String appBarTitle = selectedFilters.map((f) => f['name']).join(', ');
//     if (appBarTitle.length > 30) appBarTitle = 'Filtered Results';
//
//     // ✅ LIFT THE BLOCPROVIDER UP
//     // The BlocProvider now wraps the entire screen.
//     return BlocProvider(
//       create: (context) => FilteredProductsBloc()
//         ..add(FetchFilteredProducts(selectedFilters: selectedFilters)),
//       child: _FilteredProductsView(
//         appBarTitle: appBarTitle,
//         selectedFilters: selectedFilters,
//       ),
//     );
//   }
// }

// // Create a new private widget for the view to get the correct context
// class _FilteredProductsView extends StatefulWidget {
//   final String appBarTitle;
//   final List<Map<String, dynamic>> selectedFilters;
//
//   const _FilteredProductsView({
//     Key? key,
//     required this.appBarTitle,
//     required this.selectedFilters
//   }) : super(key: key);
//
//   @override
//   State<_FilteredProductsView> createState() => _FilteredProductsViewState();
// }
//
// class _FilteredProductsViewState extends State<_FilteredProductsView> {
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
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
//     if (_isBottom) {
//       // ✅ THIS NOW WORKS
//       // The context here is a descendant of the BlocProvider.
//       final currentState = context.read<FilteredProductsBloc>().state;
//       if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
//         context.read<FilteredProductsBloc>().add(
//           FetchFilteredProducts(
//             selectedFilters: widget.selectedFilters,
//             page: (currentState.products.length / 20).ceil(),
//           ),
//         );
//       }
//     }
//   }
//
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.appBarTitle)),
//       body: BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
//         builder: (context, state) {
//           if (state is FilteredProductsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is FilteredProductsError) {
//             return Center(child: Text(state.message));
//           }
//           if (state is FilteredProductsLoaded) {
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found for this filter."));
//             }
//             return Column(
//               children: [
//                 Expanded(
//                   child: GridView.builder(
//                     controller: _scrollController,
//                     itemCount: state.hasReachedEnd
//                         ? state.products.length
//                         : state.products.length + 1,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, childAspectRatio: 0.55),
//                     itemBuilder: (context, index) {
//                       if (index >= state.products.length) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       final product = state.products[index];
//                       // Return your standard product card widget
//                       return Card(child: Center(child: Text(product.designerName ?? '')));
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }