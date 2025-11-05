import 'package:aashniandco/features/newin/view/product_card.dart';
import 'package:aashniandco/features/newin/view/shimmer_layout/ShimmerGrid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/dialog.dart';
import '../../../constants/user_preferences_helper.dart';
import '../../auth/view/auth_screen.dart';
import '../../auth/view/login_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../categories/view/categories_screen.dart';
import '../../designer/bloc/designers_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../bloc/new_in_products_event.dart';
import '../bloc/new_in_products_state.dart';
import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import '../model/new_in_model.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart'; // <--- Import the shimmer package

// Assuming your other imports are here (Bloc, Repository, ProductCard, etc.)
// ...

import 'dart:async'; // <--- Import for Timer
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

// Assuming your other imports are here (Bloc, Repository, ProductCard, etc.)
// ...

class NewInProductsScreen extends StatefulWidget {
  final String subcategory;
  final List<Map<String, dynamic>> selectedCategories;
  final String initialTab;
  final Widget Function(String selectedCategory, String selectedSort) productListBuilder;

  const NewInProductsScreen({
    super.key,
    required this.selectedCategories,
    required this.initialTab,
    required this.productListBuilder,
    required this.subcategory,
  });

  @override
  State<NewInProductsScreen> createState() => _NewInProductsScreenState();
}

class _NewInProductsScreenState extends State<NewInProductsScreen> {
  String _selectedSortOption = "Latest";
  final List<String> _sortOptions = ["Latest", "High to Low", "Low to High"];

  // --- (NEW) STATE FOR DELAYED MESSAGE ---
  Timer? _emptyStateTimer;
  bool _canShowEmptyMessage = false;

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed to prevent memory leaks
    _emptyStateTimer?.cancel();
    super.dispose();
  }
  // --- END NEW STATE ---

  @override
  Widget build(BuildContext context) {
    // Data logic remains the same...
    final selectedText = widget.selectedCategories
        .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"] ?? e["gender"] ?? e["color"] ?? e["size"] ?? e["shipin"] ?? e["acoedit"] ?? e["occassions"] ?? e["price"] ?? e["filter"])
        .whereType<String>()
        .join(", ");

    final genders = widget.selectedCategories.map((e) => e['gender']).whereType<String>().toSet().toList();
    final themes = widget.selectedCategories.map((e) => e['theme']).whereType<String>().toSet().toList();
    final colors = widget.selectedCategories.map((e) => e['color']).whereType<String>().toSet().toList();
    final sizes = widget.selectedCategories.map((e) => e['size']).whereType<String>().toSet().toList();
    final shipin = widget.selectedCategories.map((e) => e['shipin']).whereType<String>().toSet().toList();
    final acoedit = widget.selectedCategories.map((e) => e['acoedit']).whereType<String>().toSet().toList();
    final occassions = widget.selectedCategories.map((e) => e['occassions']).whereType<String>().toSet().toList();
    final price = widget.selectedCategories.map((e) => e['price']).whereType<String>().toSet().toList();
    final filter = widget.selectedCategories.map((e) => e['filter']).whereType<String>().toSet().toList();

    return BlocProvider(
      create: (_) {
        final bloc = NewInProductsBloc(
          productRepository: ProductRepository(),
          subcategory: widget.subcategory,
          selectedCategories: widget.selectedCategories,
        );

        if (shipin.isNotEmpty) bloc.add(FetchProductsByShipsinEvent(shipin));
        if (genders.isNotEmpty) bloc.add(FetchProductsByGendersEvent(genders));
        if (colors.isNotEmpty) bloc.add(FetchProductsByColorsEvent(colors));
        if (themes.isNotEmpty) bloc.add(FetchProductsByThemesEvent(themes));
        if (sizes.isNotEmpty) bloc.add(FetchProductsBySizesEvent(sizes));
        if (acoedit.isNotEmpty) bloc.add(FetchProductsByAcoEditEvent(acoedit));
        if (occassions.isNotEmpty) bloc.add(FetchProductsByOccassionsEvent(occassions));
        if (price.isNotEmpty) bloc.add(FetchProductsByPricesEvent(price));
        if (filter.isNotEmpty) bloc.add(FetchProductsByCategoryFilterEvent(filter));
        if (widget.subcategory.isNotEmpty) bloc.add(FetchProductsBySubcategoryFilterEvent([widget.subcategory]));

        bloc.add(SortProductsEvent(SortOrder.latest));

        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.subcategory.isNotEmpty ? widget.subcategory : "Filtered Results"),
          elevation: 1,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSortHeader(context, selectedText),
              const SizedBox(height: 10),
              Expanded(child: _buildProductGrid()),
            ],
          ),
        ),
        floatingActionButton: _buildFilterFab(context),
      ),
    );
  }

  Widget _buildSortHeader(BuildContext context, String title) {
    // This widget remains unchanged
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 10),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
          child: DropdownButton<String>(
            value: _selectedSortOption,
            icon: const Icon(Icons.sort, color: Colors.black),
            underline: Container(),
            onChanged: (value) {
              if (value != null && value != _selectedSortOption) {
                setState(() {
                  _selectedSortOption = value;
                  // Reset the empty message flag when user re-sorts
                  _canShowEmptyMessage = false;
                  _emptyStateTimer?.cancel();
                });
                final sortOrder = value == "High to Low"
                    ? SortOrder.highToLow
                    : value == "Low to High"
                    ? SortOrder.lowToHigh
                    : SortOrder.latest;
                context.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
              }
            },
            items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
          ),
        ),
      ],
    );
  }

  /// **(REFACTORED)** Now uses BlocConsumer to handle the delayed message.
  Widget _buildProductGrid() {
    return BlocConsumer<NewInProductsBloc, NewInProductsState>(
      // The LISTENER handles side effects, like starting a timer.
      // It does NOT rebuild the widget.
      listener: (context, state) {
        // Always cancel the previous timer when a new state arrives.
        _emptyStateTimer?.cancel();

        if (state is NewInProductsLoaded && state.products.isEmpty) {
          // If the loaded state has no products, start a 20-second timer.
          _emptyStateTimer = Timer(const Duration(seconds: 20), () {
            // After 20 seconds, if the widget is still on screen...
            if (mounted) {
              // ...set the flag to true and trigger a rebuild to show the message.
              setState(() {
                _canShowEmptyMessage = true;
              });
            }
          });
        }
      },
      // The BUILDER handles building the UI based on the state.
      builder: (context, state) {
        if (state is NewInProductsLoaded) {
          if (state.products.isNotEmpty) {
            // If we have products, display them.
            return GridView.builder(
              padding: const EdgeInsets.only(top: 4, bottom: 16),
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) => ProductCard(product: state.products[index]),
            );
          } else {
            // Products are empty. Check if we are allowed to show the message yet.
            if (_canShowEmptyMessage) {
              // Timer has finished, show the message.
              return const Center(child: Text("No products found for this filter."));
            } else {
              // Timer is still running, continue to show the shimmer.
              return _buildShimmerGrid();
            }
          }
        } else if (state is NewInProductsError) {
          return Center(child: Text(state.message));
        }

        // For any other state (Initial, Loading), show the shimmer effect.
        return _buildShimmerGrid();
      },
    );
  }

  // --- Helper widgets for Shimmer and FAB remain the same ---

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: 8,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) => _buildShimmerProductCard(),
      ),
    );
  }

  Widget _buildShimmerProductCard() {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 180, color: Colors.white),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 5),
                Container(width: double.infinity, height: 14, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 80, height: 16, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      child: const Icon(Icons.filter_list),
      tooltip: 'Change Filters',
    );
  }
}
//18/7/2025
// class NewInProductsScreen extends StatefulWidget {
//   final String subcategory;
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab;
//   final Widget Function(String selectedCategory, String selectedSort) productListBuilder;
//
//   const NewInProductsScreen({
//     super.key,
//     required this.selectedCategories,
//     required this.initialTab,
//     required this.productListBuilder,
//     required this.subcategory,
//   });
//
//   @override
//   State<NewInProductsScreen> createState() => _NewInProductsScreenState();
// }
//
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String _selectedSortOption = "Latest";
//   final List<String> _sortOptions = ["Latest", "High to Low", "Low to High"];
//
//   @override
//   Widget build(BuildContext context) {
//     // --- DATA LOGIC: This part remains the same ---
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"] ?? e["gender"] ?? e["color"] ?? e["size"] ?? e["shipin"] ?? e["acoedit"] ?? e["occassions"] ?? e["price"] ?? e["filter"])
//         .whereType<String>()
//         .join(", ");
//
//     final genders = widget.selectedCategories.map((e) => e['gender']).whereType<String>().toSet().toList();
//     final themes = widget.selectedCategories.map((e) => e['theme']).whereType<String>().toSet().toList();
//     final colors = widget.selectedCategories.map((e) => e['color']).whereType<String>().toSet().toList();
//     final sizes = widget.selectedCategories.map((e) => e['size']).whereType<String>().toSet().toList();
//     final shipin = widget.selectedCategories.map((e) => e['shipin']).whereType<String>().toSet().toList();
//     final acoedit = widget.selectedCategories.map((e) => e['acoedit']).whereType<String>().toSet().toList();
//     final occassions = widget.selectedCategories.map((e) => e['occassions']).whereType<String>().toSet().toList();
//     final price = widget.selectedCategories.map((e) => e['price']).whereType<String>().toSet().toList();
//     final filter = widget.selectedCategories.map((e) => e['filter']).whereType<String>().toSet().toList();
//
//     return BlocProvider(
//       // --- BLOC LOGIC: This creation and event dispatching logic remains the same ---
//       create: (_) {
//         final bloc = NewInProductsBloc(
//           productRepository: ProductRepository(),
//           subcategory: widget.subcategory,
//           selectedCategories: widget.selectedCategories,
//         );
//
//         if (shipin.isNotEmpty) bloc.add(FetchProductsByShipsinEvent(shipin));
//         if (genders.isNotEmpty) bloc.add(FetchProductsByGendersEvent(genders));
//         if (colors.isNotEmpty) bloc.add(FetchProductsByColorsEvent(colors));
//         if (themes.isNotEmpty) bloc.add(FetchProductsByThemesEvent(themes));
//         if (sizes.isNotEmpty) bloc.add(FetchProductsBySizesEvent(sizes));
//         if (acoedit.isNotEmpty) bloc.add(FetchProductsByAcoEditEvent(acoedit));
//         if (occassions.isNotEmpty) bloc.add(FetchProductsByOccassionsEvent(occassions));
//         if (price.isNotEmpty) bloc.add(FetchProductsByPricesEvent(price));
//         if (filter.isNotEmpty) bloc.add(FetchProductsByCategoryFilterEvent(filter));
//         if (widget.subcategory.isNotEmpty) bloc.add(FetchProductsBySubcategoryFilterEvent([widget.subcategory]));
//
//         bloc.add(SortProductsEvent(SortOrder.latest));
//
//         return bloc;
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.subcategory.isNotEmpty ? widget.subcategory : "Filtered Results"),
//           elevation: 1,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildSortHeader(context, selectedText),
//               const SizedBox(height: 10),
//               Expanded(child: _buildProductGrid()), // This now handles shimmer
//             ],
//           ),
//         ),
//         floatingActionButton: _buildFilterFab(context),
//       ),
//     );
//   }
//
//   /// Builds the header row with the title and sort dropdown.
//   Widget _buildSortHeader(BuildContext context, String title) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           height: 40,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
//           child: DropdownButton<String>(
//             value: _selectedSortOption,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(),
//             onChanged: (value) {
//               if (value != null && value != _selectedSortOption) {
//                 setState(() { _selectedSortOption = value; });
//                 final sortOrder = value == "High to Low"
//                     ? SortOrder.highToLow
//                     : value == "Low to High"
//                     ? SortOrder.lowToHigh
//                     : SortOrder.latest;
//                 context.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//               }
//             },
//             items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// **(REFACTORED)** Builds the product grid or a shimmer layout based on BLoC state.
//   Widget _buildProductGrid() {
//     return BlocBuilder<NewInProductsBloc, NewInProductsState>(
//       builder: (context, state) {
//         // --- SUCCESS STATE ---
//         if (state is NewInProductsLoaded) {
//           if (state.products.isEmpty) {
//             // Data has loaded, but the list is empty
//             return const Center(child: Text("No products found for this filter."));
//           }
//           // Data has loaded successfully, show the actual product grid
//           return GridView.builder(
//             padding: const EdgeInsets.only(top: 4, bottom: 16),
//             itemCount: state.products.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.65, // Adjust this for your ProductCard's aspect ratio
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemBuilder: (context, index) => ProductCard(product: state.products[index]),
//           );
//         }
//         // --- ERROR STATE ---
//         else if (state is NewInProductsError) {
//           return Center(child: Text(state.message));
//         }
//         // --- LOADING & INITIAL STATES ---
//         // For any other state (like Initial or Loading), show the shimmer effect.
//         // This prevents any "No products found" message from flashing on screen initially.
//         return _buildShimmerGrid();
//       },
//     );
//   }
//
//   /// **(NEW)** Builds the shimmer loading placeholder for the grid.
//   Widget _buildShimmerGrid() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: GridView.builder(
//         padding: const EdgeInsets.only(top: 4, bottom: 16),
//         itemCount: 8, // Display 8 shimmer placeholders
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 2,
//           childAspectRatio: 0.65, // MUST BE THE SAME as the real grid
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//         ),
//         itemBuilder: (context, index) => _buildShimmerProductCard(),
//       ),
//     );
//   }
//
//   /// **(NEW)** Builds a single placeholder card for the shimmer effect.
//   Widget _buildShimmerProductCard() {
//     return Card(
//       elevation: 1,
//       clipBehavior: Clip.antiAlias, // Ensures content is clipped to the card's rounded corners
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Image placeholder
//           Container(
//             height: 180, // Adjust height to match your ProductCard image
//             color: Colors.white,
//           ),
//           // Text placeholders
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Container(width: double.infinity, height: 14, color: Colors.white),
//                 const SizedBox(height: 5),
//                 Container(width: double.infinity, height: 14, color: Colors.white),
//                 const SizedBox(height: 8),
//                 Container(width: 80, height: 16, color: Colors.white),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//   /// Builds the FAB to go back to the filter selection.
//   Widget _buildFilterFab(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         Navigator.of(context).pop();
//       },
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//       child: const Icon(Icons.filter_list),
//       tooltip: 'Change Filters',
//     );
//   }
// }

// class NewInProductsScreen extends StatefulWidget {
//   final String subcategory;
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab; // This is now less relevant but kept for compatibility
//   final Widget Function(String selectedCategory, String selectedSort) productListBuilder;
//
//   const NewInProductsScreen({
//     super.key,
//     required this.selectedCategories,
//     required this.initialTab,
//     required this.productListBuilder,
//     required this.subcategory,
//   });
//
//   @override
//   State<NewInProductsScreen> createState() => _NewInProductsScreenState();
// }
//
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   // --- UI State ---
//   String _selectedSortOption = "Latest";
//   final List<String> _sortOptions = ["Latest", "High to Low", "Low to High"];
//   // We no longer need firstName/lastName for this specific UI
//
//   @override
//   Widget build(BuildContext context) {
//     // --- DATA LOGIC: This part remains the same ---
//     // Extract a descriptive title from the selected filters.
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"] ?? e["gender"] ?? e["color"] ?? e["size"] ?? e["shipin"] ?? e["acoedit"] ?? e["occassions"] ?? e["price"] ?? e["filter"])
//         .whereType<String>()
//         .join(", ");
//
//     // Extract all filter types. This logic is preserved.
//     final genders = widget.selectedCategories.map((e) => e['gender']).whereType<String>().toSet().toList();
//     final themes = widget.selectedCategories.map((e) => e['theme']).whereType<String>().toSet().toList();
//     final colors = widget.selectedCategories.map((e) => e['color']).whereType<String>().toSet().toList();
//     final sizes = widget.selectedCategories.map((e) => e['size']).whereType<String>().toSet().toList();
//     final shipin = widget.selectedCategories.map((e) => e['shipin']).whereType<String>().toSet().toList();
//     final acoedit = widget.selectedCategories.map((e) => e['acoedit']).whereType<String>().toSet().toList();
//     final occassions = widget.selectedCategories.map((e) => e['occassions']).whereType<String>().toSet().toList();
//     final price = widget.selectedCategories.map((e) => e['price']).whereType<String>().toSet().toList();
//     final filter = widget.selectedCategories.map((e) => e['filter']).whereType<String>().toSet().toList();
//
//     return BlocProvider(
//       // --- BLOC LOGIC: This creation and event dispatching logic remains the same ---
//       create: (_) {
//         final bloc = NewInProductsBloc(
//           productRepository: ProductRepository(),
//           subcategory: widget.subcategory,
//           selectedCategories: widget.selectedCategories,
//         );
//
//         // Dispatch events based on the filters passed to the screen.
//         if (shipin.isNotEmpty) bloc.add(FetchProductsByShipsinEvent(shipin));
//         if (genders.isNotEmpty) bloc.add(FetchProductsByGendersEvent(genders));
//         if (colors.isNotEmpty) bloc.add(FetchProductsByColorsEvent(colors));
//         if (themes.isNotEmpty) bloc.add(FetchProductsByThemesEvent(themes));
//         if (sizes.isNotEmpty) bloc.add(FetchProductsBySizesEvent(sizes));
//         if (acoedit.isNotEmpty) bloc.add(FetchProductsByAcoEditEvent(acoedit));
//         if (occassions.isNotEmpty) bloc.add(FetchProductsByOccassionsEvent(occassions));
//         if (price.isNotEmpty) bloc.add(FetchProductsByPricesEvent(price));
//         if (filter.isNotEmpty) bloc.add(FetchProductsByCategoryFilterEvent(filter));
//         if (widget.subcategory.isNotEmpty) bloc.add(FetchProductsBySubcategoryFilterEvent([widget.subcategory]));
//
//         // Default sort event
//         bloc.add(SortProductsEvent(SortOrder.latest));
//
//         return bloc;
//       },
//       // --- UI: This part is completely refactored ---
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.subcategory.isNotEmpty ? widget.subcategory : "Filtered Results"),
//           elevation: 1,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildSortHeader(context, selectedText),
//               const SizedBox(height: 10),
//               Expanded(child: _buildProductGrid()),
//             ],
//           ),
//         ),
//         floatingActionButton: _buildFilterFab(context),
//       ),
//     );
//   }
//
//   /// Builds the header row with the title and sort dropdown.
//   Widget _buildSortHeader(BuildContext context, String title) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(
//             title,
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             overflow: TextOverflow.ellipsis,
//             maxLines: 1,
//           ),
//         ),
//         const SizedBox(width: 10),
//         Container(
//           height: 40,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
//           child: DropdownButton<String>(
//             value: _selectedSortOption,
//             icon: const Icon(Icons.sort, color: Colors.black),
//             underline: Container(), // Hides the default underline
//             onChanged: (value) {
//               if (value != null && value != _selectedSortOption) {
//                 setState(() { _selectedSortOption = value; });
//                 final sortOrder = value == "High to Low"
//                     ? SortOrder.highToLow
//                     : value == "Low to High"
//                     ? SortOrder.lowToHigh
//                     : SortOrder.latest;
//                 // Dispatch event to BLoC to fetch a new, sorted list
//                 context.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//               }
//             },
//             items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Builds the main grid of products.
//   Widget _buildProductGrid() {
//     return BlocBuilder<NewInProductsBloc, NewInProductsState>(
//       builder: (context, state) {
//         if (state is NewInProductsLoading) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (state is NewInProductsLoaded) {
//           if (state.products.isEmpty) {
//             return const Center(child: Text("No products found for this filter."));
//           }
//           return GridView.builder(
//             padding: const EdgeInsets.only(top: 4, bottom: 16),
//             itemCount: state.products.length,
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.65, // Adjust this for your ProductCard's aspect ratio
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//             ),
//             itemBuilder: (context, index) => ProductCard(product: state.products[index]),
//           );
//         } else if (state is NewInProductsError) {
//           return Center(child: Text(state.message));
//         }
//         return const Center(child: Text("Select a filter to see products."));
//       },
//     );
//   }
//
//   /// Builds the FAB to go back to the filter selection.
//   Widget _buildFilterFab(BuildContext context) {
//     return FloatingActionButton(
//       onPressed: () {
//         // Pops the current screen to go back to the filter selection screen
//         Navigator.of(context).pop();
//       },
//       backgroundColor: Colors.black,
//       foregroundColor: Colors.white,
//       child: const Icon(Icons.filter_list),
//       tooltip: 'Change Filters',
//     );
//   }
// }

// /18/7/2025
// class NewInProductsScreen extends StatefulWidget {
//
//   final String subcategory;
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab;
//   final Widget Function(String selectedCategory, String selectedSort) productListBuilder;
//
//   const NewInProductsScreen({
//     super.key,
//     required this.selectedCategories,
//     required this.initialTab,
//     required this.productListBuilder,
//     required this.subcategory,
//   });
//
//
//
//   @override
//   State<NewInProductsScreen> createState() => _NewInProductsScreenState();
// }
//
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String selectedSort = "Latest";
//
//   String firstName = '';
//   String lastName = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadUserNames();
//     // Trigger the default sort to show "Latest" data
//     context.read<NewInProductsBloc>().add(SortProductsEvent(SortOrder.latest));
//
//     // Fetch products based on the selected subcategory (e.g., "Bags")
//     // context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryFilterEvent(widget.subcategory));
//     // context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryEvent(widget.subcategory));
//
//     context.read<NewInProductsBloc>().add(FetchProductsBySubcategoryFilterEvent(widget.subcategory));
//   }
//
//   Future<void> _loadUserNames() async {
//     final fName = await UserPreferences.getFirstName();
//     final lName = await UserPreferences.getLastName();
//     setState(() {
//       firstName = fName;
//       lastName = lName;
//     });
//   }
//   @override
//   Widget build(BuildContext context) {
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
//         .whereType<String>()
//         .join(", ");
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf("New In");
//
//     final genders = widget.selectedCategories
//         .map((e) => e['gender'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final themes = widget.selectedCategories
//         .map((e) => e['theme'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final colors = widget.selectedCategories
//         .map((e) => e['color'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final sizes = widget.selectedCategories
//         .map((e) => e['size'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final shipin = widget.selectedCategories
//         .map((e) => e['shipin'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final acoedit = widget.selectedCategories
//         .map((e) => e['acoedit'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final occassions = widget.selectedCategories
//         .map((e) => e['occassions'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final price = widget.selectedCategories
//         .map((e) => e['price'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final filter = widget.selectedCategories
//         .map((e) => e['filter'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     final subcat_filter= widget.selectedCategories
//         .map((e) => e['subcat_filter'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     return BlocProvider(
//       create: (_) {
//         final bloc = NewInProductsBloc(
//           productRepository: ProductRepository(),
//           subcategory: widget.subcategory,
//           selectedCategories: widget.selectedCategories,
//         );
//
//         if (shipin.isNotEmpty) {
//           print("🎯 Fetching by SHIPSIN: $shipin");
//           bloc.add(FetchProductsByShipsinEvent(shipin));
//         }
//
//         if (genders.isNotEmpty) {
//           print("🎯 Fetching by GENDERS: $genders");
//           bloc.add(FetchProductsByGendersEvent(genders));
//         }
//
//         if (colors.isNotEmpty) {
//           print("🎯 Fetching by COLORS: $colors");
//           bloc.add(FetchProductsByColorsEvent(colors));
//         }
//
//         if (themes.isNotEmpty) {
//           print("🎯 Fetching by THEMES: $themes");
//           bloc.add(FetchProductsByThemesEvent(themes));
//         }
//
//         if (sizes.isNotEmpty) {
//           print("🎯 Fetching by SIZES: $sizes");
//           bloc.add(FetchProductsBySizesEvent(sizes));
//         }
//
//         if (acoedit.isNotEmpty) {
//           print("🎯 Fetching by acoedit: $acoedit");
//           bloc.add(FetchProductsByAcoEditEvent(acoedit));
//         }
//
//         if (occassions.isNotEmpty) {
//           print("🎯 Fetching by occassions: $occassions");
//           bloc.add(FetchProductsByOccassionsEvent(occassions));
//         }
//
//         if (price.isNotEmpty) {
//           print("🎯 Fetching by price: $price");
//           bloc.add(FetchProductsByPricesEvent(price));
//         }
//
//         if (filter.isNotEmpty) {
//           print("🎯 Fetching by cat_filter: $filter");
//           bloc.add(FetchProductsByCategoryFilterEvent(filter));
//         }
//
//         // Send subcategory-specific event like "Bags"
//
//
//         if (widget.subcategory.isNotEmpty) {
//           bloc.add(FetchProductsBySubcategoryFilterEvent([widget.subcategory]));
//         }
//
//         return bloc;
//       },
//       child: DefaultTabController(
//         length: 4,
//         initialIndex: initialIndex,
//         child: Scaffold(
//
//           appBar: AppBar(
//             title:
//             Column(
//               children: [
//                 Image.asset('assets/logo.jpeg', height: 30),
//                 const SizedBox(width: 10), // space between image and text
//                 // Text("Welcome $firstName $lastName", style: const TextStyle(fontSize: 14, color: Colors.black,fontWeight: FontWeight.bold)),
//               ],
//             ),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(kToolbarHeight),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   double screenWidth = constraints.maxWidth;
//                   double fontSize = screenWidth > 360 ? 13 : 10;
//
//                   return TabBar(
//                     isScrollable: false,
//                     labelColor: Colors.black,
//                     indicatorColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: tabTitles.map((title) {
//                       return Tab(
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: fontSize),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const SearchScreen(),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//               HomeScreen(),
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           selectedText,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         Builder(
//                           builder: (innerContext) {
//                             return Container(
//                               height: 35,
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: DropdownButton<String>(
//                                 value: selectedSort,
//                                 icon: const Icon(Icons.sort, color: Colors.black),
//                                 style: const TextStyle(color: Colors.black, fontSize: 14),
//                                 dropdownColor: Colors.white,
//                                 underline: const SizedBox(),
//                                 onChanged: (value) {
//                                   if (value != null) {
//                                     setState(() {
//                                       selectedSort = value;
//                                     });
//
//                                     final sortOrder = value == "High to Low"
//                                         ? SortOrder.highToLow
//                                         : value == "Low to High"
//                                         ? SortOrder.lowToHigh
//                                         : SortOrder.latest;
//
//                                     innerContext.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//                                   }
//                                 },
//                                 items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                                   return DropdownMenuItem<String>(
//                                     value: sortOption,
//                                     child: Text(sortOption),
//                                   );
//                                 }).toList(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//                       builder: (context, state) {
//                         if (state is NewInProductsLoading) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (state is NewInProductsLoaded) {
//                           return GridView.builder(
//                             padding: const EdgeInsets.all(12),
//                             itemCount: state.products.length,
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               mainAxisExtent: 270,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemBuilder: (context, index) =>
//                                 ProductCard(product: state.products[index]),
//                           );
//                         } else if (state is NewInProductsError) {
//                           return Center(child: Text(state.message));
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//               CategoriesPage(),
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const WishlistScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AccountScreen()),
//                         (route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


// class NewInProductsScreen extends StatefulWidget {
//   final String subcategory;
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab;
//
//   final Widget Function(String selectedCategory, String selectedSort) productListBuilder;
//
//   const NewInProductsScreen({super.key,  required this.selectedCategories,
//
//     required this.initialTab,
//     required this.productListBuilder,required this.subcategory});
//
//   @override
//   State<NewInProductsScreen> createState() => _NewInProductsScreenState();
// }
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String selectedSort = "Latest";
//
//   @override
//   void initState() {
//     super.initState();
//     // Trigger the default sort to show "Latest" data
//     context.read<NewInProductsBloc>().add(SortProductsEvent(SortOrder.latest));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
//         .whereType<String>()
//         .join(", ");
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf("New In");
//
//     //************** add all direct calls categories
//     // final gender = widget.selectedCategories
//     //     .map((e) => e['gender'])
//     //     .whereType<String>()
//     //     .firstOrNull ?? "Women"; // fallback if nothing is found
//
//
//
//
//     final genders = widget.selectedCategories
//         .map((e) => e['gender'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     // if (genders.isEmpty) genders.add("Women"); // Fallback
//
//     print("🧍 Genders selected: $genders");
//
//     final themes = widget.selectedCategories
//         .map((e) => e['theme'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//
//     // if (themes.isEmpty) themes.add("Ethnic"); // Fallback
//
//     print("🧍 Themes selected: $themes");
//     //************** add all direct calls categories
//     final colors = widget.selectedCategories
//         .map((e) => e['color'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Colors selected: $colors");
//
//     final sizes = widget.selectedCategories
//         .map((e) => e['size'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Sizes selected: $sizes");
//
//     final shipin = widget.selectedCategories
//         .map((e) => e['shipin'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 Shipin selected: $shipin");
//
//     final acoedit = widget.selectedCategories
//         .map((e) => e['acoedit'])
//         .whereType<String>()
//         .toSet()
//         .toList();
//     print("🧍 acoedit selected: $acoedit");
//
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialIndex,
//       child: BlocProvider(
//         create: (_) {
//           final bloc = NewInProductsBloc(
//             productRepository: ProductRepository(),
//             subcategory: widget.subcategory,
//             selectedCategories: widget.selectedCategories,
//           );
//           if (shipin.isNotEmpty) {
//             print("🎯 Fetching by SHIPSIN: $shipin");
//             bloc.add(FetchProductsByShipsinEvent(shipin));
//           }
//
//           if (genders.isNotEmpty) {
//             print("🎯 Fetching by GENDERS: $genders");
//             bloc.add(FetchProductsByGendersEvent(genders));
//           }
//
//           if (colors.isNotEmpty) {
//             print("🎯 Fetching by COLORS: $colors");
//             bloc.add(FetchProductsByColorsEvent(colors));
//           }
//
//           if (themes.isNotEmpty) {
//             print("🎯 Fetching by THEMES: $themes");
//             bloc.add(FetchProductsByThemesEvent(themes));
//           }
//
//           if (sizes.isNotEmpty) {
//             print("🎯 Fetching by SIZES: $sizes");
//             bloc.add(FetchProductsBySizesEvent(sizes));
//           }
//
//           if (acoedit.isNotEmpty) {
//             print("🎯 Fetching by acoedit: $acoedit");
//             bloc.add(FetchProductsByAcoEditEvent(acoedit));
//           }
//           return bloc;
//         },
//         child: Scaffold(
//           appBar: AppBar(
//             title: Image.asset('assets/logo.jpeg', height: 30),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(kToolbarHeight),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   double screenWidth = constraints.maxWidth;
//                   double fontSize = screenWidth > 360 ? 13 : 10;
//
//                   return TabBar(
//                     isScrollable: false,
//                     labelColor: Colors.black,
//                     indicatorColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: tabTitles.map((title) {
//                       return Tab(
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: fontSize),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const SearchScreen(),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//
//               HomeScreen(),
//
//               // ✅ New In Products Tab
//               Column(
//                 children: [
//
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           selectedText,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//
//                         // ✅ Wrap DropdownButton in Builder to get correct context
//                         Builder(
//                           builder: (innerContext) {
//                             return Container(
//                               height: 35,
//                               padding: const EdgeInsets.symmetric(horizontal: 12),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(6),
//                               ),
//                               child: DropdownButton<String>(
//                                 value: selectedSort,
//                                 icon: const Icon(Icons.sort, color: Colors.black),
//                                 style: const TextStyle(color: Colors.black, fontSize: 14),
//                                 dropdownColor: Colors.white,
//                                 underline: const SizedBox(),
//                                 onChanged: (value) {
//                                   if (value != null) {
//                                     setState(() {
//                                       selectedSort = value;
//                                     });
//
//                                     final sortOrder = value == "High to Low"
//                                         ? SortOrder.highToLow
//                                         : value == "Low to High"
//                                         ? SortOrder.lowToHigh
//                                         : SortOrder.latest;
//
//
//                                     innerContext.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//                                   }
//                                 },
//                                 items: ["Latest","High to Low", "Low to High"].map((sortOption) {
//                                   return DropdownMenuItem<String>(
//                                     value: sortOption,
//                                     child: Text(sortOption),
//                                   );
//                                 }).toList(),
//                               ),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//                       builder: (context, state) {
//                         if (state is NewInProductsLoading) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (state is NewInProductsLoaded) {
//                           return GridView.builder(
//                             padding: const EdgeInsets.all(12),
//                             itemCount: state.products.length,
//                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 2,
//                               mainAxisExtent: 270,
//                               crossAxisSpacing: 10,
//                               mainAxisSpacing: 10,
//                             ),
//                             itemBuilder: (context, index) =>
//                                 ProductCard(product: state.products[index]),
//                           );
//                         } else if (state is NewInProductsError) {
//                           return Center(child: Text(state.message));
//                         }
//                         return const SizedBox.shrink();
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//               CategoriesPage(),
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const WishlistScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AccountScreen()),
//                         (route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
// class _NewInProductsScreenState extends State<NewInProductsScreen> {
//   String selectedSort = "High to Low";
//
//
//   @override
//   Widget build(BuildContext context) {
//     // final selectedText = widget.selectedCategories.isNotEmpty
//     //     ? (widget.selectedCategories[0]["subCategory"] ?? widget.selectedCategories[0]["category"])
//     //     : "No Category Selected";
//     final selectedText = widget.selectedCategories
//         .map((e) => e["subCategory"] ?? e["category"] ?? e["theme"])
//         .whereType<String>()
//         .join(", ");
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf("New In");
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialIndex,
//       child: BlocProvider(
//         // create: (_) => NewInProductsBloc(
//         //   productRepository: ProductRepository(),
//         //   subcategory: widget.subcategory,
//         // )
//
//         create: (_) => NewInProductsBloc(
//           productRepository: ProductRepository(),
//           subcategory: widget.subcategory,
//           selectedCategories: widget.selectedCategories,
//         )
//
//           ..add(FetchProductsEvent()),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Image.asset('assets/logo.jpeg', height: 30),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(kToolbarHeight),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   double screenWidth = constraints.maxWidth;
//                   double fontSize = screenWidth > 360 ? 13 : 10;
//
//                   return TabBar(
//                     isScrollable: false,
//                     labelColor: Colors.black,
//                     indicatorColor: Colors.black,
//                     unselectedLabelColor: Colors.grey,
//                     tabs: tabTitles.map((title) {
//                       return Tab(
//                         child: Text(
//                           title,
//                           style: TextStyle(fontSize: fontSize),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       );
//                     }).toList(),
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => const SearchScreen(),
//                   );
//                 },
//               ),
//
//
//
//
//
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//               HomeScreen(),
//
//               /// New In Tab (Product List)
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "$selectedText",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       Container(
//                         height: 35,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: Colors.grey[300],
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         child: DropdownButton<String>(
//                           value: selectedSort,
//                           icon: const Icon(Icons.sort, color: Colors.black),
//                           style: const TextStyle(color: Colors.black, fontSize: 14),
//                           dropdownColor: Colors.white,
//                           underline: const SizedBox(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSort = value!;
//                               final sortOrder = selectedSort == "High to Low"
//                                   ? SortOrder.highToLow
//                                   : SortOrder.lowToHigh;
//                               context.read<NewInProductsBloc>().add(SortProductsEvent(sortOrder));
//                             });
//                           },
//                           items: ["High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//                     builder: (context, state) {
//                       if (state is NewInProductsLoading) {
//                         return const Center(child: CircularProgressIndicator());
//                       } else if (state is NewInProductsLoaded) {
//                         return GridView.builder(
//                           padding: const EdgeInsets.all(12),
//                           itemCount: state.products.length,
//                           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             mainAxisExtent: 270,
//                             crossAxisSpacing: 10,
//                             mainAxisSpacing: 10,
//                           ),
//                           itemBuilder: (context, index) =>
//                               ProductCard(product: state.products[index]),
//                         );
//                       } else if (state is NewInProductsError) {
//                         return Center(child: Text(state.message));
//                       }
//                       return const SizedBox.shrink();
//                     },
//                   ),
//                 ),
//               ],
//             ),
//
//
//               CategoriesPage(),
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const WishlistScreen()),
//                         (route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AccountScreen()),
//                         (route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
