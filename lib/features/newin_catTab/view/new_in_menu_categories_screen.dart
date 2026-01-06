
// lib/features/newin/view/menu_categories_screen.dart (or your path)
// lib/features/newin/view/menu_categories_screen.dart (or your path)
import 'package:aashniandco/features/newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../categories/bloc/category_products_bloc.dart';
import '../../categories/bloc/category_products_event.dart';
import '../../categories/bloc/category_products_state.dart';
import '../../newin/bloc/product_repository.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/filter_bottom_sheet.dart';
import '../../newin/view/product_details_newin.dart';

// Make sure to import your actual Product model
// import 'package:aashniandco/models/product_model.dart';

// lib/features/newin/view/menu_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Assuming your filter bottom sheet exists, import it here
// import 'package:aashniandco/widgets/filter_bottom_sheet.dart';

// Make sure to import your actual Product model



import '../repository/api_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Make sure these import paths are correct for your project structure
// Your filter sheet
import '../../newin/model/new_in_model.dart'; // Your Product model


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


class MenuCategoriesScreen1 extends StatelessWidget {
  final String categoryName;

  const MenuCategoriesScreen1({
    Key? key,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide the BLoC to the widget tree.
    // It will be accessible by all children of this Scaffold.
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
  const MenuCategoriesView({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<MenuCategoriesView> createState() => _MenuCategoriesViewState();
}

class _MenuCategoriesViewState extends State<MenuCategoriesView> {
  final _scrollController = ScrollController();
  String _selectedSort = "Default";

  // --- NEW ---
  // Flag to prevent multiple fetch requests while one is already in progress.
  bool _isFetching = false;

  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _categoryMetadataFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _categoryMetadataFuture = _apiService.fetchCategoryMetadataByName(widget.categoryName);
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

  // --- MODIFIED ---
  // The scroll listener now uses the `_isFetching` guard.
  void _onScroll() {
    // Only dispatch a new event if we are at the bottom AND not already fetching data.
    if (_isBottom && !_isFetching) {
      // Set the flag to true immediately to block subsequent triggers.
      setState(() {
        _isFetching = true;
      });
      // Dispatch the event to fetch the next page.
      context.read<CategoryProductsBloc>().add(FetchProducts(
        categoryName: widget.categoryName,
        sortOption: _selectedSort,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.categoryName, style: const TextStyle(color: Colors.black45)),
      // ),
      // --- MODIFIED ---
      // The body is wrapped in a BlocListener to reset the `_isFetching` flag.
      body: BlocListener<CategoryProductsBloc, CategoryProductsState>(
        listener: (context, state) {
          // When the BLoC state changes to success or failure, it means the fetch
          // operation is complete. We can now reset the flag to allow new fetches.
          if (state.status == CategoryProductsStatus.success || state.status == CategoryProductsStatus.failure) {
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
              Expanded(
                child: _buildProductGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFilterFab(),
    );
  }

  Widget _buildSortHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.categoryName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                setState(() {
                  _selectedSort = value;
                });
                context.read<CategoryProductsBloc>().add(
                  FetchProducts(
                    categoryName: widget.categoryName,
                    sortOption: _selectedSort,
                    isReset: true,
                  ),
                );
              }
            },
            items: [
              "Default", "Latest", "Price: High to Low", "Price: Low to High"
            ].map((sortOption) {
              return DropdownMenuItem<String>(
                value: sortOption,
                child: Text(sortOption, style: const TextStyle(color: Colors.black, fontSize: 14)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<CategoryProductsBloc, CategoryProductsState>(
      builder: (context, state) {
        switch (state.status) {
          case CategoryProductsStatus.failure:
            return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));

          case CategoryProductsStatus.success:
            if (state.products.isEmpty) {
              return const Center(child: Text("No products found in this category."));
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
                  // Show the bottom loading spinner only if we are actively fetching.
                  return _isFetching
                      ? const Center(child: CircularProgressIndicator())
                      : const SizedBox.shrink(); // Otherwise, show nothing.
                }
                final item = state.products[index];
                return _buildProductCard(item);
              },
            );

          case CategoryProductsStatus.initial:
          case CategoryProductsStatus.loading:
          // Show a full-screen loader only if the product list is empty (initial load).
            if (state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            // If we are loading but have products, it's a pagination load,
            // so we fall through to the success case which shows the list and a bottom loader.
            // This is handled by the `_isFetching` check in the success case.
            // So we can just reuse the success builder.
            // Fallthrough is not directly supported, so just copy the success case.
            return GridView.builder(
              controller: _scrollController,
              itemCount: state.products.length + 1,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (context, index) {
                if (index >= state.products.length) {
                  return const Center(child: CircularProgressIndicator());
                }
                final item = state.products[index];
                return _buildProductCard(item);
              },
            );
        }
      },
    );
  }

  Widget _buildProductCard(Product item) {
    // ✅ 1. Watch the global CurrencyBloc state
    final currencyState = context.watch<CurrencyBloc>().state;

    // Default values for safety
    String displaySymbol = '₹';
    double displayPrice = item.actualPrice ?? 0.0;

    // ✅ 2. If currency is loaded, calculate the price
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      // Calculate price: (base price in INR) * (selected currency's rate)
      displayPrice = (item.actualPrice ?? 0.0) * currencyState.selectedRate.rate;
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
                  child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
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
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.shortDesc ?? "No description",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      // ✅ 3. Display the calculated price and symbol
                      "$displaySymbol${displayPrice.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  Widget _buildFilterFab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoryMetadataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done || snapshot.hasError) {
          return FloatingActionButton(
            onPressed: null,
            backgroundColor: Colors.grey,
            child: snapshot.connectionState == ConnectionState.waiting
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.filter_list_alt, color: Colors.black54),
          );
        }
        final categoryData = snapshot.data!;
        final String parentCategoryId = categoryData['pare_cat_id']?.toString() ?? '';
        return FloatingActionButton(
          onPressed: () {
            if (parentCategoryId.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<CategoryProductsBloc>(context),
                  child: FilterBottomSheetCategories(
                    categoryId: parentCategoryId,
                    isFromFilteredScreen: false,


                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Filter not available for this category.")),
              );
            }
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.filter_list_alt, color: Colors.black),
        );
      },
    );
  }
}