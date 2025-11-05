import 'dart:convert';

import 'package:aashniandco/constants/text_styles.dart';
import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
import 'package:aashniandco/features/newin/bloc/product_te.dart';
import 'package:aashniandco/features/newin/model/new_in_model.dart';
import 'package:aashniandco/features/newin/view/product_details_newin.dart';
import 'package:aashniandco/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/user_preferences_helper.dart';
import 'filter_bottom_sheet.dart';
import '../bloc/new_in_state.dart';

// class NewInScreen extends StatefulWidget {
//   const NewInScreen({super.key});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   String selectedSort = "High to Low";
//
//   @override
//   void initState() {
//     super.initState();
//     context.read<NewInBloc>().add(FetchNewIn());
//   }
//
//   void sortProducts(List<NewInProduct> products) {
//     if (selectedSort == "High to Low") {
//       products.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//     } else {
//       products.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("New >>"),
//           backgroundColor: Colors.white,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.refresh),
//               onPressed: () {
//                 context.read<NewInBloc>().add(FetchNewIn());
//               },
//             )
//           ],
//         ),
//
//       body: BlocBuilder<NewInBloc, NewInState>(
//         builder: (context, state) {
//           if (state is NewInLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInLoaded) {
//             List<NewInProduct> products = state.products;
//             print("Total products in UI: ${products.length}");
//             for (var i = 0; i < products.length && i < 5; i++) {
//               debugPrint("Product $i: ${products[i].shortDesc}, Price: ${products[i].actualPrice}");
//             }
//
//             sortProducts(products);
//
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Sort Dropdown
//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: Container(
//                     height: 35,
//                     margin: const EdgeInsets.all(8),
//                     padding: const EdgeInsets.symmetric(horizontal: 12),
//                     decoration: BoxDecoration(color: Colors.grey),
//                     child: DropdownButton<String>(
//                       value: selectedSort,
//                       icon: const Icon(Icons.sort, color: Colors.black),
//                       style: const TextStyle(color: Colors.white, fontSize: 14),
//                       dropdownColor: Colors.grey,
//                       underline: Container(),
//                       onChanged: (newValue) {
//                         setState(() {
//                           selectedSort = newValue!;
//                         });
//                       },
//                       items: ["High to Low", "Low to High"]
//                           .map<DropdownMenuItem<String>>((String value) {
//                         return DropdownMenuItem<String>(
//                           value: value,
//                           child:
//                           Text(value, style: const TextStyle(color: Colors.black)),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 ),
//
//                 // Product Grid
//                 Expanded(
//                   child: GridView.builder(
//                     padding: const EdgeInsets.all(8),
//                     itemCount: products.length,
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2,
//                       crossAxisSpacing: 10,
//                       mainAxisSpacing: 10,
//                       childAspectRatio: 0.5,
//                     ),
//                     itemBuilder: (context, index) {
//                       final item = products[index];
//
//                       return GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) =>
//                                   ProductDetailScreen(product: item.toJson()),
//                             ),
//                           );
//                         },
//                         child: Card(
//                           color: Colors.white,
//                           elevation: 1,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Flexible(
//                                 child: Image.network(
//                                   item.prodSmallImg.isNotEmpty
//                                       ? item.prodSmallImg
//                                       : item.prodThumbImg,
//                                   width: double.infinity,
//                                   height: 550,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Container(
//                                       width: double.infinity,
//                                       height: 550,
//                                       color: Colors.grey[300],
//                                       alignment: Alignment.center,
//                                       child: const Icon(Icons.image_not_supported,
//                                           size: 50),
//                                     );
//                                   },
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     item.designerName,
//                                     style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold),
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding:
//                                 const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     item.shortDesc,
//                                     textAlign: TextAlign.center,
//                                     style: const TextStyle(fontSize: 12),
//                                     maxLines: 2,
//                                     overflow: TextOverflow.ellipsis,
//                                   ),
//                                 ),
//                               ),
//                               Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                 child: Center(
//                                   child: Text(
//                                     "₹${item.actualPrice}",
//                                     style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           } else if (state is NewInError) {
//             return Center(child: Text(state.message));
//           } else {
//             return const Center(child: Text("Unexpected state"));
//           }
//         },
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Import all your necessary files


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- IMPORTANT: Make sure these import paths are correct for your project ---

// --------------------------------------------------------------------------


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Adjust paths

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart'; // <--- Import the shimmer package

// Assuming your other imports for BLoC, models, and other screens are here
// ...

class NewInScreen extends StatelessWidget {
  const NewInScreen({super.key, required List selectedCategories});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewInBloc()
        ..add(const FetchNewInProducts(sortOption: "Default", isReset: true)),
      child: const NewInView(),
    );
  }
}

class NewInView extends StatefulWidget {
  const NewInView({super.key});

  @override
  State<NewInView> createState() => _NewInViewState();
}

class _NewInViewState extends State<NewInView> with AutomaticKeepAliveClientMixin<NewInView> {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();
  bool _isFetching = false;
  String _selectedSortOption = "Default";
  final List<String> _sortOptions = ["Default", "Latest", "Price: High to Low", "Price: Low to High"];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom && !_isFetching) {
      setState(() { _isFetching = true; });
      context.read<NewInBloc>().add(FetchNewInProducts(sortOption: _selectedSortOption));
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: BlocListener<NewInBloc, NewInState>(
        listener: (context, state) {
          if (state.status == NewInStatus.success || state.status == NewInStatus.failure) {
            setState(() { _isFetching = false; });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              _buildSortHeader(),
              const SizedBox(height: 10),
              Expanded(child: _buildProductGrid()), // This now uses shimmer
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFilterFab(),
    );
  }

  Widget _buildSortHeader() {
    // This widget remains unchanged
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("New In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                setState(() { _selectedSortOption = value; });
                context.read<NewInBloc>().add(FetchNewInProducts(
                  sortOption: _selectedSortOption,
                  isReset: true,
                ));
              }
            },
            items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
          ),
        ),
      ],
    );
  }

  /// **(REFACTORED)** Builds the grid, now with shimmer effect for initial loads.
  Widget _buildProductGrid() {
    return BlocBuilder<NewInBloc, NewInState>(
      builder: (context, state) {
        switch (state.status) {
          case NewInStatus.failure:
            return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));

        // MERGED `initial` and `loading` (when empty) to show shimmer
          case NewInStatus.initial:
          case NewInStatus.loading:
            if (state.products.isEmpty) {
              // This is an initial load (or a reset), show the shimmer effect.
              return _buildShimmerGrid();
            }
            // If loading but products exist, it's pagination.
            // Fallthrough to the success case to show the list with a loader.
            return _buildGridView(context, state, isLoading: true);

          case NewInStatus.success:
            if (state.products.isEmpty) {
              return const Center(child: Text("No products found"));
            }
            return _buildGridView(context, state, isLoading: false);
        }
      },
    );
  }

  /// **(NEW HELPER)** Extracted GridView builder for reuse.
  Widget _buildGridView(BuildContext context, NewInState state, {required bool isLoading}) {
    return GridView.builder(
      controller: _scrollController,
      // The itemCount depends on whether we have reached the end or are currently loading more.
      itemCount: (isLoading || !state.hasReachedMax)
          ? state.products.length + 1
          : state.products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.5,
      ),
      itemBuilder: (context, index) {
        if (index >= state.products.length) {
          // This is the loader at the bottom.
          return const Center(child: CircularProgressIndicator());
        }
        final item = state.products[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildProductCard(Product item) {
    // This widget remains unchanged
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ProductDetailNewInDetailScreen(product: item.toJson()),
        ));
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 3,
              child: Image.network(
                item.prodSmallImg ?? '',
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      item.designerName ?? "Unknown Designer",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.shortDesc ?? "No description",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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

  /// **(NEW)** Builds the shimmer loading placeholder for the grid.
  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // Disable scrolling during shimmer
        itemCount: 8, // Display 8 shimmer placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.5, // MUST BE THE SAME as the real grid
        ),
        itemBuilder: (context, index) => _buildShimmerProductCard(),
      ),
    );
  }

  /// **(NEW)** Builds a single placeholder card for the shimmer effect.
  Widget _buildShimmerProductCard() {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image placeholder (respecting the flex factor)
          Flexible(
            flex: 3,
            child: Container(color: Colors.white),
          ),
          // Text placeholders (respecting the flex factor)
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(width: 100, height: 14, color: Colors.white),
                  Column(
                    children: [
                      Container(width: 130, height: 12, color: Colors.white),
                      const SizedBox(height: 4),
                      Container(width: 110, height: 12, color: Colors.white),
                    ],
                  ),
                  Container(width: 60, height: 14, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildFilterFab() {
    // This widget remains unchanged
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
          builder: (context) => const FilterBottomSheet(),
        );
      },
      backgroundColor: Colors.white,
      child: const Icon(Icons.filter_list_alt),
    );
  }
}

/////18/7/2025
// The main screen widget now provides the BLoC.
// class NewInScreen extends StatelessWidget {
//   const NewInScreen({super.key, required List selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       // The BLoC is created and the initial fetch event is added here.
//       create: (context) => NewInBloc()
//         ..add(const FetchNewInProducts(sortOption: "Default", isReset: true)),
//       child: const NewInView(), // The UI is built in a separate stateful widget
//     );
//   }
// }
//
// class NewInView extends StatefulWidget {
//   const NewInView({super.key});
//
//   @override
//   State<NewInView> createState() => _NewInViewState();
// }
//
// class _NewInViewState extends State<NewInView> with AutomaticKeepAliveClientMixin<NewInView> {
//   @override
//   bool get wantKeepAlive => true;
//
//   // --- State variables are now much simpler ---
//   final ScrollController _scrollController = ScrollController();
//   bool _isFetching = false;
//   String _selectedSortOption = "Default";
//   final List<String> _sortOptions = ["Default", "Latest", "Price: High to Low", "Price: Low to High"];
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
//   bool get _isBottom {
//     if (!_scrollController.hasClients) return false;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final currentScroll = _scrollController.position.pixels;
//     return currentScroll >= (maxScroll * 0.9);
//   }
//
//   void _onScroll() {
//     if (_isBottom && !_isFetching) {
//       setState(() { _isFetching = true; });
//       context.read<NewInBloc>().add(FetchNewInProducts(sortOption: _selectedSortOption));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context); // Required by AutomaticKeepAliveClientMixin
//     return Scaffold(
//       body: BlocListener<NewInBloc, NewInState>(
//         listener: (context, state) {
//           // Reset the fetch guard when loading completes
//           if (state.status == NewInStatus.success || state.status == NewInStatus.failure) {
//             setState(() { _isFetching = false; });
//           }
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               _buildSortHeader(),
//               const SizedBox(height: 10),
//               Expanded(child: _buildProductGrid()),
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
//         const Text("New In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
//                 // Dispatch event to BLoC to fetch a new, sorted list
//                 context.read<NewInBloc>().add(FetchNewInProducts(
//                   sortOption: _selectedSortOption,
//                   isReset: true,
//                 ));
//               }
//             },
//             items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildProductGrid() {
//     return BlocBuilder<NewInBloc, NewInState>(
//       builder: (context, state) {
//         // We handle each case explicitly to satisfy null-safety and avoid errors.
//         switch (state.status) {
//           case NewInStatus.failure:
//             return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));
//
//           case NewInStatus.initial:
//           // The initial state should always show a loading indicator.
//             return const Center(child: CircularProgressIndicator());
//
//           case NewInStatus.loading:
//           // If we are loading BUT the product list is already populated,
//           // it means we are paginating. We should show the existing grid
//           // with a loader at the bottom.
//           // If the product list is empty, it's an initial load, show a center spinner.
//             if (state.products.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             // Fallthrough logic is achieved by just building the same success widget
//             // since the state still contains the old list of products.
//             return GridView.builder(
//               controller: _scrollController,
//               itemCount: state.products.length + 1, // Always show space for the loader
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 if (index >= state.products.length) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 final item = state.products[index];
//                 return _buildProductCard(item);
//               },
//             );
//
//           case NewInStatus.success:
//             if (state.products.isEmpty) {
//               return const Center(child: Text("No products found"));
//             }
//             return GridView.builder(
//               controller: _scrollController,
//               // The itemCount depends on whether we have reached the end.
//               itemCount: state.hasReachedMax ? state.products.length : state.products.length + 1,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.5,
//               ),
//               itemBuilder: (context, index) {
//                 // If it's the last item and we haven't reached the max, show the loader.
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
//         Navigator.push(context, MaterialPageRoute(
//           builder: (context) => ProductDetailNewInDetailScreen(product: item.toJson()),
//         ));
//       },
//       child: Card(
//         color: Colors.white,
//         elevation: 1,
//         clipBehavior: Clip.antiAlias,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Flexible(
//               flex: 3,
//               child: Image.network(
//                 item.prodSmallImg ?? '',
//                 fit: BoxFit.cover,
//                 errorBuilder: (c, e, s) => Container(
//                   color: Colors.grey[200],
//                   alignment: Alignment.center,
//                   child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//                 ),
//               ),
//             ),
//             Flexible(
//               flex: 2,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       item.designerName ?? "Unknown Designer",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                       textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       item.shortDesc ?? "No description",
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(fontSize: 12, color: Colors.black54),
//                       maxLines: 2, overflow: TextOverflow.ellipsis,
//                     ),
//                     Text(
//                       "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
//                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
//     return FloatingActionButton(
//       onPressed: () {
//         showModalBottomSheet(
//           context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
//           builder: (context) => const FilterBottomSheet(),
//         );
//       },
//       backgroundColor: Colors.white,
//       child: const Icon(Icons.filter_list_alt),
//     );
//   }
// }
/////18/7/2025 -end////
//17/7/2025
// class NewInScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//   const NewInScreen({super.key, required this.selectedCategories});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> with AutomaticKeepAliveClientMixin<NewInScreen> {
//
//   // --- Step 1: Override wantKeepAlive ---
//   // This tells Flutter to keep this widget's state alive.
//   @override
//   bool get wantKeepAlive => true;
//
//   // --- State Variables (No changes here) ---
//   String selectedSortOption = "Default";
//   List<Product> _serverOrderList = [];
//   List<Product> _currentlySortedList = [];
//   List<Product> displayedProducts = [];
//   final int _pageSize = 20;
//   int _localPageIndex = 0;
//   bool _isLoadingMore = false;
//   final ScrollController _scrollController = ScrollController();
//   final List<String> _sortOptions = [
//     "Default",
//     "Latest",
//     "Price: High to Low",
//     "Price: Low to High"
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     // --- Step 2: Make initState Smarter ---
//     // Only fetch data if the BLoC hasn't already loaded it.
//     // This prevents re-fetching if the widget is ever rebuilt for other reasons.
//     if (context.read<NewInBloc>().state is! NewInLoaded) {
//       context.read<NewInBloc>().add(FetchNewIn());
//     }
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
//     if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
//       _loadMoreLocalData();
//     }
//   }
//
//   void _loadMoreLocalData() {
//     if (_isLoadingMore || displayedProducts.length >= _currentlySortedList.length) {
//       return;
//     }
//     setState(() { _isLoadingMore = true; });
//     Future.delayed(const Duration(milliseconds: 300), () {
//       if (!mounted) return;
//       _localPageIndex++;
//       final int startIndex = _localPageIndex * _pageSize;
//       int endIndex = startIndex + _pageSize;
//       if (endIndex > _currentlySortedList.length) {
//         endIndex = _currentlySortedList.length;
//       }
//       if (startIndex < _currentlySortedList.length) {
//         setState(() {
//           displayedProducts.addAll(_currentlySortedList.getRange(startIndex, endIndex));
//         });
//       }
//       setState(() { _isLoadingMore = false; });
//     });
//   }
//
//   void _applySort(String option) {
//     List<Product> listToSort = List.from(_serverOrderList);
//     switch (option) {
//       case "Latest":
//         listToSort.sort((a, b) => (int.tryParse(b.prod_en_id ?? '0') ?? 0).compareTo(int.tryParse(a.prod_en_id ?? '0') ?? 0));
//         break;
//       case "Price: High to Low":
//         listToSort.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//         break;
//       case "Price: Low to High":
//         listToSort.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//         break;
//       case "Default":
//       default:
//         break;
//     }
//     setState(() {
//       selectedSortOption = option;
//       _currentlySortedList = listToSort;
//       _localPageIndex = 0;
//       displayedProducts = _currentlySortedList.take(_pageSize).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // --- Step 3: Add super.build(context) ---
//     // This is required by the AutomaticKeepAliveClientMixin.
//     super.build(context);
//
//     return Scaffold(
//       body: BlocConsumer<NewInBloc, NewInState>(
//         listener: (context, state) {
//           if (state is NewInLoaded && _serverOrderList.isEmpty) {
//             // Only populate the lists if they are empty, preventing overwrites.
//             setState(() {
//               _serverOrderList = state.products;
//               _currentlySortedList = List.from(_serverOrderList);
//               _localPageIndex = 0;
//               displayedProducts = _currentlySortedList.take(_pageSize).toList();
//             });
//           }
//         },
//         builder: (context, state) {
//           if (state is NewInLoading && displayedProducts.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (state is NewInError) {
//             return Center(child: Text(state.message));
//           }
//           if (displayedProducts.isEmpty) {
//             // Check if the state is loaded but our list is still empty
//             if (state is NewInLoaded) {
//               return const Center(child: Text("No products found"));
//             }
//             // Otherwise, it might still be loading initially
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           bool hasMore = displayedProducts.length < _currentlySortedList.length;
//
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text("New In", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                     Container(
//                       height: 40,
//                       padding: const EdgeInsets.symmetric(horizontal: 12),
//                       decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
//                       child: DropdownButton<String>(
//                         value: selectedSortOption,
//                         icon: const Icon(Icons.sort, color: Colors.black),
//                         underline: Container(),
//                         onChanged: (value) { if (value != null) _applySort(value); },
//                         items: _sortOptions.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10),
//                 Expanded(
//                   child: GridView.builder(
//                     controller: _scrollController,
//                     itemCount: displayedProducts.length + (hasMore ? 1 : 0),
//                     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.5,
//                     ),
//                     itemBuilder: (context, index) {
//                       if (index == displayedProducts.length) {
//                         return const Center(child: CircularProgressIndicator());
//                       }
//                       final item = displayedProducts[index];
//                     return GestureDetector(
//
//                           onTap: () {
//                             Navigator.push(context, MaterialPageRoute(
//                               builder: (context) => ProductDetailNewInDetailScreen(product: item.toJson()),
//                             ));
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 1,
//                             clipBehavior: Clip.antiAlias,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 // Product Image
//                                 Flexible(
//                                   flex: 3,
//                                   child: Image.network(
//                                     item.prodSmallImg ?? '',
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         color: Colors.grey[200],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 // Product Details Section
//                                 Flexible(
//                                   flex: 2,
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(8.0),
//                                     child: Column(
//                                       mainAxisAlignment: MainAxisAlignment.spaceAround,
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         // Designer Name
//                                         Text(
//                                           item.designerName ?? "Unknown Designer",
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                           textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
//                                         ),
//                                         // Short Description
//                                         Text(
//                                           item.shortDesc ?? "No description available",
//                                           textAlign: TextAlign.center,
//                                           style: const TextStyle(fontSize: 12, color: Colors.black54),
//                                           maxLines: 2, overflow: TextOverflow.ellipsis,
//                                         ),
//                                         // Price
//                                         Text(
//                                           "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
//                                           style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                         ),
//                                       ],
//                                     ),
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
//
//
//           // Fallback for any unhandled state
//         return const SizedBox.shrink();
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
//             builder: (context) => const FilterBottomSheet(),
//           );
//         },
//         backgroundColor: Colors.white,
//         child: const Icon(Icons.filter_list_alt),
//       ),
//     );
//   }
// }
///15 july 2025
// class NewInScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//   const NewInScreen({super.key, required this.selectedCategories});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   String selectedSort = "Latest";
//   List<dynamic> sortedProducts = [];
//   String firstName = '';
//   String lastName = '';
//   int currentPage = 0;
//   int nextPage = 0;
//   bool hasReachedEnd = false;
//
//   final ScrollController _scrollController = ScrollController();
//
//   bool _isFetching = false;
//
//
//   @override
//   void initState() {
//     super.initState();
//     final selectedData = widget.selectedCategories;
//     debugPrint("Selected Categories: $selectedData");
//     // context.read<NewInBloc>().add(FetchNewIn(page: nextPage));
//     context.read<NewInBloc>().add(FetchNewIn());
//
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !hasReachedEnd) {
//         context.read<NewInBloc>().add(FetchNewIn(page: currentPage + 1));
//       }
//     });
//
//
//     _loadUserNames();
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
//   void sortProducts(List<Product> products) {
//     sortedProducts = List<Product>.from(products);
//     if (selectedSort == "High to Low") {
//       sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//     } else if (selectedSort == "Low to High") {
//       sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//     } else if (selectedSort == "Latest") {
//       sortedProducts.sort((a, b) {
//         final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
//         final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
//         return idB.compareTo(idA);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<NewInBloc, NewInState>(
//         builder: (context, state) {
//           if (state is NewInLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInError) {
//             return Center(child: Text(state.message));
//           } else if (state is NewInLoaded) {
//             _isFetching = false;
//             sortProducts(state.products);
//
//             if (sortedProducts.isEmpty) {
//               return const Center(child: Text("No products found"));
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   // Header Row
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "New In",
//                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                           dropdownColor: Colors.white,
//                           underline: Container(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSort = value!;
//                               sortProducts(state.products);
//                             });
//                           },
//                           items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   // Product Grid
//                   Expanded(
//                     child: GridView.builder(
//                       controller: _scrollController,
//
//                       itemCount: state.hasReachedEnd
//                           ? sortedProducts.length
//                           : sortedProducts.length + 1,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.5,
//                       ),
//                       itemBuilder: (context, index) {
//                         if (index >= sortedProducts.length) {
//                           // Loader item
//                           return const Padding(
//                             padding: EdgeInsets.all(16),
//                             child: Center(child: CircularProgressIndicator()),
//                           );
//                         }
//
//                         final item = sortedProducts[index];
//                         return GestureDetector(
//                           onTap: () {
//                             print("Designer Data: ${jsonEncode(item.toJson())}");
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) =>
//                                     ProductDetailNewInDetailScreen(product: item.toJson()),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Product Image
//                                 Flexible(
//                                   child: Image.network(
//                                     item.prodSmallImg ?? item.prodThumbImg ?? '',
//                                     width: double.infinity,
//                                     height: 550,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: 550,
//                                         color: Colors.grey[300],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.image_not_supported, size: 50),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // Designer Name
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item.designerName ?? "Unknown",
//                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Short Description
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item.shortDesc ?? "No description",
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(fontSize: 12),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Price
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
//                                       style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }
//                       ,
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox();
//         },
//       ),
//
//       // Floating Filter Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => const FilterBottomSheet(),
//           );
//         },
//         child: const Icon(Icons.filter_list_alt),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
// }

// class NewInScreen extends StatefulWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//   const NewInScreen({super.key, required this.selectedCategories});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   String selectedSort = "Latest";
//   // List<dynamic> products = [];
//   List<dynamic> sortedProducts = [];
//
//   @override
//   void initState() {
//     super.initState();
//     final selectedData = widget.selectedCategories;
//
//     // Example: Filter products based on category/subCategory if needed
//     debugPrint("Selected Categories: $selectedData");
//     context.read<NewInBloc>().add(FetchNewIn());
//   }
//
//   // void sortProducts(List<Product> products) {
//   //   sortedProducts = List<Product>.from(products); // Clone
//   //   if (selectedSort == "Latest") {
//   //     sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//   //   } else {
//   //     sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//   //   }
//   // }
//
//   void sortProducts(List<Product> products) {
//     sortedProducts = List<Product>.from(products); // Clone the list
//     if (selectedSort == "High to Low") {
//       sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//     } else if (selectedSort == "Low to High") {
//       sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//     } else if (selectedSort == "Latest") {
//       sortedProducts.sort((a, b) {
//         final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
//         final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
//         return idB.compareTo(idA);
//       });
//     }
//   }
//
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<NewInBloc, NewInState>(
//         builder: (context, state) {
//           if (state is NewInLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInError) {
//             return Center(child: Text(state.message));
//           } else if (state is NewInLoaded) {
//             sortProducts(state.products);
//
//             if (sortedProducts.isEmpty) {
//               return const Center(child: Text("No products found"));
//             }
//
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   /// Header Row with "New In" and Sort Dropdown
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         "New In",
//                         style: TextStyle(
//                           fontSize: 18,
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
//                           style: const TextStyle(color: Colors.white, fontSize: 14),
//                           dropdownColor: Colors.white,
//                           underline: Container(),
//                           onChanged: (value) {
//                             setState(() {
//                               selectedSort = value!;
//                               sortProducts(state.products);
//                             });
//                           },
//                           items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
//                             return DropdownMenuItem<String>(
//                               value: sortOption,
//                               child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),
//
//                   Expanded(
//                     child: GridView.builder(
//                       itemCount: sortedProducts.length,
//                       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2, // 2 items per row
//                         crossAxisSpacing: 10,
//                         mainAxisSpacing: 10,
//                         childAspectRatio: 0.5, // Decrease this to increase height
//                       ),
//                       itemBuilder: (context, index) {
//                         final item = sortedProducts[index];
//                         return GestureDetector(
//                           onTap: () {
//                             print("Designer Data: ${jsonEncode(item)}");
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => ProductDetailNewInDetailScreen(product: item),
//                               ),
//                             );
//                           },
//                           child: Card(
//                             color: Colors.white,
//                             elevation: 1,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 // Increased Image Height
//                                 Flexible(
//                                   child: Image.network(
//                                     item['prod_small_img'] ?? item['prod_thumb_img'] ?? '',
//                                     width: double.infinity,
//                                     height: 550, // Increase height
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) {
//                                       return Container(
//                                         width: double.infinity,
//                                         height: 550, // Match the height
//                                         color: Colors.grey[300],
//                                         alignment: Alignment.center,
//                                         child: const Icon(Icons.image_not_supported, size: 50),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//
//                                 // Designer Name
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item['designer_name'] ?? "Unknown",
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                       maxLines: 1,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Short Description
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       item['short_desc'] ?? "No description",
//                                       textAlign: TextAlign.center,
//                                       style: const TextStyle(fontSize: 12),
//                                       maxLines: 2,
//                                       overflow: TextOverflow.ellipsis,
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Price
//                                 Padding(
//                                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Center(
//                                     child: Text(
//                                       "₹${item['actual_price_1'] ?? 'N/A'}",
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   )
//                   /// Grid of Products
//                   // Expanded(
//                   //   child: GridView.builder(
//                   //     itemCount: sortedProducts.length,
//                   //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   //       crossAxisCount: 2,
//                   //       crossAxisSpacing: 10,
//                   //       mainAxisSpacing: 10,
//                   //       childAspectRatio: 0.55,
//                   //     ),
//                   //     itemBuilder: (context, index) {
//                   //       final item = sortedProducts[index];
//                   //       // final product = sortedProducts[index];
//                   //       return GestureDetector(
//                   //         onTap: () {
//                   //           Navigator.push(
//                   //             context,
//                   //             MaterialPageRoute(
//                   //               builder: (context) =>
//                   //                   ProductDetailNewInDetailScreen(product: item),
//                   //             ),
//                   //           );
//                   //         },
//                   //         child: Card(
//                   //           color: Colors.white,
//                   //           elevation: 1,
//                   //           child: Column(
//                   //             crossAxisAlignment: CrossAxisAlignment.start,
//                   //             children: [
//                   //               Flexible(
//                   //                 child: Image.network(
//                   //                   product.prodSmallImg,
//                   //                   width: double.infinity,
//                   //                   height: 550,
//                   //                   fit: BoxFit.cover,
//                   //                   errorBuilder: (context, error, stackTrace) {
//                   //                     return Container(
//                   //                       height: 550,
//                   //                       color: Colors.grey[300],
//                   //                       alignment: Alignment.center,
//                   //                       child: const Icon(Icons.image_not_supported, size: 50),
//                   //                     );
//                   //                   },
//                   //                 ),
//                   //               ),
//                   //               const SizedBox(height: 8),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     product.designerName,
//                   //                     style: AppTextStyle.designerName,
//                   //                     textAlign: TextAlign.center,
//                   //                     maxLines: 1,
//                   //                     overflow: TextOverflow.ellipsis,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     product.shortDesc,
//                   //                     textAlign: TextAlign.center,
//                   //                     style: AppTextStyle.shortDescription,
//                   //                     maxLines: 2,
//                   //                     overflow: TextOverflow.ellipsis,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //               Padding(
//                   //                 padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   //                 child: Center(
//                   //                   child: Text(
//                   //                     "₹${product.actualPrice.toStringAsFixed(0)}",
//                   //                     style: AppTextStyle.actualPrice,
//                   //                     textAlign: TextAlign.center,
//                   //                   ),
//                   //                 ),
//                   //               ),
//                   //             ],
//                   //           ),
//                   //         ),
//                   //       );
//                   //     },
//                   //   ),
//                   // ),
//                 ],
//               ),
//             );
//           }
//           return const SizedBox();
//         },
//       ),
//
//       /// Floating Filter Button
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showModalBottomSheet(
//             context: context,
//             isScrollControlled: true,
//             backgroundColor: Colors.transparent,
//             builder: (context) => const FilterBottomSheet(),
//           );
//         },
//         child: const Icon(Icons.filter_list_alt),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
//
// }



