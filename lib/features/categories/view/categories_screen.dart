import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/common_app_bar.dart';
import '../../../common/common_bottom_nav_bar.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_event.dart';
import '../../auth/bloc/currency_state.dart';
import '../../auth/view/categories_view_body.dart';
import '../../newin/view/new_in_category_designer.dart';
import '../../newin/view/new_in_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../bloc/megamenu_bloc.dart';
import '../bloc/megamenu_event.dart';
import '../bloc/megamenu_state.dart';
import '../repository/megamenu_repository.dart';
import 'menu_categories_screen.dart';
import 'menu_categories_screen1.dart'; // Make sure this import is correct

// No changes needed here
// class CategoriesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
//       child: CategoriesView(),
//     );
//   }
// }

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ✅ STEP 1: Use the reusable CommonAppBar.
      // We pass a simple Text widget for the title.
      appBar: const CommonAppBar(
        titleWidget: Text('Categories',),
      ),

      // ✅ STEP 2: Provide the Bloc and use the reusable body.
      // This ensures the screen can function independently.
      body: BlocProvider(
        create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
        child: const CategoriesViewBody(),
      ),

      // ✅ STEP 3: Add the reusable bottom navigation bar.
      // We set the index to 1 to highlight the "Categories" icon.
      bottomNavigationBar: const CommonBottomNavBar(
        currentIndex: 1,
      ),
    );
  }
}

class CategoriesView extends StatelessWidget {
  void _navigateToMenuScreen(BuildContext context, String categoryName) {
    final nameLower = categoryName.toLowerCase();

    if (nameLower.contains('designers')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DesignerListScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuCategoriesScreen(categoryName: categoryName),
        ),
      );
    }
  }

  // Widget _buildResponsiveAppBarTitle() {
  //   print("met called>>");
  //   // This BlocBuilder will automatically handle loading, errors, and data states
  //   return BlocBuilder<CurrencyBloc, CurrencyState>(
  //     builder: (context, state) {
  //       // --- Handle Loading and Error States First ---
  //       if (state is CurrencyLoading || state is CurrencyInitial) {
  //         return const Center(
  //           child: SizedBox(
  //             height: 20,
  //             width: 20,
  //             child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
  //           ),
  //         );
  //       }
  //       if (state is CurrencyError) {
  //         return Tooltip(
  //           message: state.message,
  //           child: const Icon(Icons.error_outline, color: Colors.red),
  //         );
  //       }
  //
  //
  //       // --- Handle the Success State ---
  //       if (state is CurrencyLoaded) {
  //         // ✅ Wrap the logo and the dropdown in a Row for side-by-side layout.
  //         return Row(
  //           children: [
  //             // 1. Add the logo as the first item in the Row.
  //             Image.asset('assets/logo.jpeg', height: 30),
  //             const SizedBox(width: 16),
  //
  //
  //             // 2. Wrap the Dropdown in an Expanded widget.
  //             // This tells the dropdown to fill all remaining horizontal space in the AppBar.
  //             // Expanded(
  //             //   child: DropdownButtonHideUnderline(
  //             //     child: DropdownButton<String>(
  //             //       value: state.selectedCurrencyCode,
  //             //       isExpanded: true, // Ensures it fills the Expanded widget
  //             //       icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
  //             //       onChanged: (newCode) {
  //             //         if (newCode != null) {
  //             //           context.read<CurrencyBloc>().add(ChangeCurrency(newCode));
  //             //           _updateCartCurrency(newCode);
  //             //         }
  //             //       },
  //             //       // This builder defines how the selected item looks when the dropdown is CLOSED.
  //             //       selectedItemBuilder: (context) {
  //             //         return state.currencyData.availableCurrencyCodes
  //             //             .map((_) => Align(
  //             //           alignment: Alignment.centerLeft,
  //             //           child: Text(
  //             //             '${state.selectedCurrencyCode} | ${state.selectedSymbol}',
  //             //             style: const TextStyle(
  //             //                 color: Colors.black,
  //             //                 fontWeight: FontWeight.w500,
  //             //                 fontSize: 14 // Adjusted for better fit
  //             //             ),
  //             //             overflow: TextOverflow.ellipsis,
  //             //           ),
  //             //         ))
  //             //             .toList();
  //             //       },
  //             //       // This builds the list of items when the dropdown is OPEN.
  //             //       items: state.currencyData.availableCurrencyCodes.map((code) {
  //             //         return DropdownMenuItem<String>(
  //             //           value: code,
  //             //           child: Text(code),
  //             //         );
  //             //       }).toList(),
  //             //     ),
  //             //   ),
  //             // ),
  //           ],
  //         );
  //       }
  //
  //
  //       // Fallback for any other unhandled state
  //       return const SizedBox.shrink();
  //     },
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: _buildResponsiveAppBarTitle(),
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   // ✅ The 'bottom' property is now REMOVED to hide the TabBar
      //   actions: [
      //     // IconButton(
      //     //   icon: const Icon(Icons.search),
      //     //   onPressed: () {
      //     //     showDialog(
      //     //       context: context,
      //     //       builder: (context) => const SearchScreen1(),
      //     //     );
      //     //   },
      //     // ),
      //     // IconButton(
      //     //   icon: Stack(
      //     //     clipBehavior: Clip.none,
      //     //     children: [
      //     //       const Icon(Icons.shopping_bag_rounded, color: Colors.black),
      //     //       if (cartQty > 0)
      //     //         Positioned(
      //     //           right: -6,
      //     //           top: -6,
      //     //           child: Container(
      //     //             padding: const EdgeInsets.all(2),
      //     //             decoration: BoxDecoration(
      //     //               color: Colors.red,
      //     //               borderRadius: BorderRadius.circular(10),
      //     //             ),
      //     //             constraints:
      //     //             const BoxConstraints(minWidth: 18, minHeight: 18),
      //     //             child: Text(
      //     //               '$cartQty',
      //     //               style: const TextStyle(
      //     //                 color: Colors.white,
      //     //                 fontSize: 12,
      //     //                 fontWeight: FontWeight.bold,
      //     //               ),
      //     //               textAlign: TextAlign.center,
      //     //             ),
      //     //           ),
      //     //         ),
      //     //     ],
      //     //   ),
      //     //   onPressed: () {
      //     //     Navigator.push(
      //     //       context,
      //     //       MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
      //     //     );
      //     //   },
      //     // ),
      //   ],
      // ),
      backgroundColor: Colors.white,
      body: BlocBuilder<MegamenuBloc, MegamenuState>(
        builder: (context, state) {
          if (state is MegamenuLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MegamenuLoaded) {
            final categories = state.menuNames;

            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final name = categories[index];

                return GestureDetector(
                  onTap: () => _navigateToMenuScreen(context, name),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            );
          } else if (state is MegamenuError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No categories found.'));
          }
        },
      ),
      bottomNavigationBar: CommonBottomNavBar(
        // Index 1 corresponds to the "Categories" item in your nav bar.
        currentIndex: 1,
      ),
    );
  }
}

// class CategoriesView extends StatelessWidget {
//   // Map of category names to asset image paths
//   final Map<String, String> categoryImageMap = {
//     'men': 'assets/resize_men.jpg',
//     'women': 'assets/resize_women.jpg',
//     'accessories': 'assets/resize_accessories.jpg',
//     'shoes': 'assets/shoes.jpg',
//     'new in': 'assets/resize_new_in.jpg', // ✅ This mapping will now be used
//     'designers': 'assets/resize_designers.jpg',
//     'jewelry': 'assets/resize_jewelry.jpg',
//     'weddings': 'assets/resize_wedding.jpg',
//     'kids': 'assets/resize_kids.jpg',
//     'sale': 'assets/resize_sale.jpg',
//     'ready to ship': 'assets/resize_readytoship.jpg',
//     'bestsellers': 'assets/resize_bestsellers.jpg'
//   };
//
//   void _navigateToMenuScreen(BuildContext context, String categoryName) {
//     final nameLower = categoryName.toLowerCase();
//
//     // You might want to uncomment this if you have a special screen for "New In"
//     // if (nameLower.contains('new in')) {
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(
//     //       builder: (_) => NewInScreen(selectedCategories: []),
//     //     ),
//     //   );
//     // } else
//
//     if (nameLower.contains('designers')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DesignerListScreen()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MenuCategoriesScreen(categoryName: categoryName),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuNames;
//
//             // ✅ --- KEY CHANGE: Replaced GridView with ListView ---
//             return ListView.builder(
//               padding: const EdgeInsets.all(12.0), // Add some padding around the list
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final name = categories[index];
//                 final normalizedKey = name.trim().toLowerCase();
//                 final imagePath = categoryImageMap[normalizedKey] ?? 'assets/default.jpg';
//
//                 // Each item in the list is a Card with a fixed height
//                 return GestureDetector(
//                   onTap: () => _navigateToMenuScreen(context, name),
//                   child: Card(
//                     elevation: 3,
//                     margin: const EdgeInsets.only(bottom: 12.0), // Space between cards
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     clipBehavior: Clip.antiAlias, // Ensures the image respects the rounded corners
//                     child: SizedBox(
//                       height: 220, // Define a fixed height for each list item
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Image takes up most of the space
//                           Expanded(
//                             child: Image.asset(
//                               imagePath,
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                             ),
//                           ),
//                           // Title is in a padded area at the bottom
//                           Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
//                             child: Text(
//                               name,
//                               style: TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//             // --- END OF CHANGE ---
//
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return Center(child: Text('No categories found.'));
//           }
//         },
//       ),
//     );
//   }
// }





// import 'package:aashniandco/features/newin/view/new_in_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../bloc/megamenu_bloc.dart';
// import '../bloc/megamenu_event.dart';
// import '../bloc/megamenu_state.dart';
//
// import '../repository/megamenu_repository.dart';
// import 'menu_categories_screen.dart';
// import 'package:http/io_client.dart';
//
// class CategoriesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
//       child: CategoriesView(),
//     );
//   }
// }
//
// class CategoriesView extends StatelessWidget {
//   void _navigateToMenuScreen(BuildContext context, String category) {
//     // if (category == 'NEW IN') {
//     //   Navigator.push(
//     //     context,
//     //     MaterialPageRoute(builder: (_) => NewInScreen(selectedCategories: [],)),
//     //   );
//     // }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuNames;
//             return Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: GridView.builder(
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,
//                   mainAxisSpacing: 8,
//                   childAspectRatio: 3 / 2,
//                 ),
//                 itemCount: categories.length,
//                 itemBuilder: (context, index) {
//                   final name = categories[index];
//                   return GestureDetector(
//                     onTap: () => _navigateToMenuScreen(context, name),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.grey[200],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
//                               child: Image.asset(
//                                 "assets/Banner-3.jpeg", // use dynamic if needed
//                                 fit: BoxFit.cover,
//                                 width: double.infinity,
//                               ),
//                             ),
//                           ),
//                           Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Text(
//                               name,
//                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return Center(child: Text('No data'));
//           }
//         },
//       ),
//     );
//   }
// }
