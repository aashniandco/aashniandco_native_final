
import 'package:aashniandco/constants/text_styles.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart';
import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
import 'package:aashniandco/features/newin/bloc/product_te.dart';
import 'package:aashniandco/features/newin/model/new_in_model.dart';
import 'package:aashniandco/features/newin/view/paginated_new_in_grid.dart';
import 'package:aashniandco/features/product_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../common/dialog.dart';
import '../../auth/view/auth_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../categories/view/categories_screen.dart';
import '../../designer/bloc/designers_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../bloc/new_in_accessories_bloc.dart';
import '../bloc/new_in_accessories_state.dart';
import 'filter_bottom_sheet.dart';
import '../bloc/new_in_state.dart';

import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import 'new_in_screen.dart'; // For NewInScreen

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'filtered_product_tab_screen.dart';
// Make sure your BLoC is imported correctly
import 'product_card.dart'; // The reusable product card widget


// lib/screens/new_in_filter_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Adjust paths


class NewInFilterScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCategories;

  const NewInFilterScreen({super.key, required this.selectedCategories});

  // Helper to map UI sort option to the BLoC's expected string.
  // This could also live inside the stateful widget if preferred.
  String _mapSortOption(String uiSort) {
    switch (uiSort) {
      case 'High to Low':
        return 'Price: High to Low';
      case 'Low to High':
        return 'Price: Low to High';
      case 'Latest':
        return 'Latest';
      default:
        return 'Default';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilteredProductTabScreen(
      selectedCategories: selectedCategories,
      initialTab: "New In",
      productListBuilder: (selectedCategory, selectedSort) {
        // --- KEY CHANGES HERE ---
        // 1. Use BlocProvider to create and provide the NewInBloc.
        // 2. Use a Key to ensure the BLoC is recreated when the sort option changes.
        // 3. Dispatch the correct initial event with the mapped sort option.
        return BlocProvider(
          key: ValueKey(selectedSort), // IMPORTANT: This forces a new BLoC on sort change
          create: (_) => NewInBloc()
            ..add(FetchNewInProducts(
              sortOption: _mapSortOption(selectedSort),
              isReset: true,
            )),
          // 4. The child is our new, self-contained, stateful widget.
          child: PaginatedNewInGrid(selectedSort: selectedSort),
        );
      },
    );
  }
}

//17/7/2025
// class NewInFilterScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInFilterScreen({super.key, required this.selectedCategories});
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return FilteredProductTabScreen(
//       selectedCategories: selectedCategories,
//       initialTab: "New In",
//       productListBuilder: (selectedCategory, selectedSort) {
//         return BlocProvider(
//           create: (_) => NewInBloc()..add(FetchNewIn()),
//           child: BlocBuilder<NewInBloc, NewInState>(
//             builder: (context, state) {
//               if (state is NewInLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is NewInLoaded) {
//                 /// Sort products here based on selectedSort
//                 List<Product> products = List.from(state.products);
//
//                 if (selectedSort == 'High to Low') {
//                   products.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//                 } else if (selectedSort == 'Low to High') {
//                   products.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//                 }
//
//                 if (products.isEmpty) {
//                   return const Center(child: Text("No products found"));
//                 }
//
//                 return GridView.builder(
//                   itemCount: products.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.55,
//                   ),
//                   itemBuilder: (context, index) {
//                     final product = products[index];
//                     return ProductCard(product: product);
//                   },
//                 );
//               } else if (state is NewInError) {
//                 return Center(child: Text(state.message));
//               } else {
//                 return const SizedBox.shrink();
//               }
//             },
//           ),
//         );
//       },
//     );
//   }
//
//
// }


// class NewInFilterScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInFilterScreen({super.key, required this.selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedText = selectedCategories.isNotEmpty
//         ? selectedCategories[0]["category"]
//         : "No Category Selected";
//
//     final bool isLoading = false; // Replace with your real authState check
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: 1,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Image.asset(
//             'assets/logo.jpeg',
//             height: 30,
//           ),
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           bottom: const TabBar(
//             labelColor: Colors.black,
//             indicatorColor: Colors.black,
//             unselectedLabelColor: Colors.grey,
//             labelPadding: EdgeInsets.symmetric(horizontal: 0),
//             tabs: [
//               Tab(child: Text("Exclusives", style: TextStyle(fontSize: 14))),
//               Tab(child: Text("New In", style: TextStyle(fontSize: 14))),
//               Tab(child: Text("Categories", style: TextStyle(fontSize: 14))),
//               Tab(child: Text("Designers", style: TextStyle(fontSize: 14))),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (BuildContext context) => const SearchScreen(),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.shopping_bag_rounded),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => ShoppingBagScreen(),
//                   ),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//           children: [
//             // 1. Exclusives tab
//             HomeScreen(),
//
//             // 2. New In tab with selected filter applied
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           "Filtered by: $selectedText",
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const NewInScreen(selectedCategories: []),
//                             ),
//                           );
//                         },
//                         child: const Text("Clear Filter"),
//                       )
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: NewInScreen(
//                     selectedCategories: selectedCategories,
//                   ),
//                 ),
//               ],
//             ),
//
//             // 3. Categories tab
//             CategoriesPage(),
//
//             // 4. Designers tab
//             DesignersScreen(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//             BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//             BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//           ],
//           onTap: (index) {
//             switch (index) {
//               case 0:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthScreen()),
//                       (Route<dynamic> route) => false,
//                 );
//                 break;
//               case 1:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const WishlistScreen()),
//                       (Route<dynamic> route) => false,
//                 );
//                 break;
//               case 2:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AccountScreen()),
//                       (Route<dynamic> route) => false,
//                 );
//                 break;
//             }
//           },
//         ),
//       ),
//     );
//   }
// }


// class NewInFilterScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInFilterScreen({super.key, required this.selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     // Safely get the category name (in your case it'll be "Women's Clothing")
//     final selectedText = selectedCategories.isNotEmpty
//         ? selectedCategories[0]["category"]
//         : "No Category Selected";
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("New In Filter"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Center(
//         child: Text(
//           "Selected Category: $selectedText",
//           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//     );
//   }
// }
