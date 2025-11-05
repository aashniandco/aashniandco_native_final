import 'package:aashniandco/common/dialog.dart';
import 'package:aashniandco/features/auth/view/wishlist_screen.dart';
import 'package:aashniandco/features/shoppingbag/shopping_bag.dart';
import 'package:flutter/material.dart';

import '../../auth/view/auth_screen.dart';
import '../../auth/view/login_screen.dart';
import '../../categories/view/categories_screen.dart';
import '../../designer/bloc/designers_screen.dart';
import '../model/new_in_model.dart';

class FilteredProductTabScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCategories;
  final String initialTab;
  final Widget Function(String selectedCategory, String selectedSort) productListBuilder;

  const FilteredProductTabScreen({
    super.key,
    required this.selectedCategories,
    required this.initialTab,
    required this.productListBuilder,
  });

  @override
  State<FilteredProductTabScreen> createState() => _FilteredProductTabScreenState();
}

class _FilteredProductTabScreenState extends State<FilteredProductTabScreen> {
  String selectedSort = 'High to Low';

  List<Product> sortedProducts = [];

  void sortProducts(List<Product> products) {
    sortedProducts = List<Product>.from(products); // Clone
    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
    } else {
      sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = widget.selectedCategories.isNotEmpty
        ? (widget.selectedCategories[0]["subCategory"] ?? widget.selectedCategories[0]["category"])
        : "No Category Selected";


    final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
    final initialIndex = tabTitles.indexOf(widget.initialTab);

    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex >= 0 ? initialIndex : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/logo.jpeg', height: 30),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double fontSize = screenWidth > 360 ? 13 : 10;

                return TabBar(
                  isScrollable: false,
                  labelColor: Colors.black,
                  indicatorColor: Colors.black,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: "Exclusives"),
                    Tab(text: "New In"),
                    Tab(text: "Categories"),
                    Tab(text: "Designers"),
                  ].map((tab) {
                    return Tab(
                      child: Text(
                        tab.text!,
                        style: TextStyle(fontSize: fontSize),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => const SearchScreen(),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.shopping_bag_rounded),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            HomeScreen(),

            /// New In Tab
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          " Filtered by:>>"
                              " $selectedText",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FilteredProductTabScreen(
                                selectedCategories: [],
                                initialTab: widget.initialTab,
                                productListBuilder: widget.productListBuilder,
                              ),
                            ),
                          );
                        },
                        child: TextButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AuthScreen(initialTabindex: 1),
                              ),
                                  (Route<dynamic> route) => false, // 👈 removes all previous routes
                            );

                            // Navigator.pushReplacement(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (_) => AuthScreen(initialTabindex: 1,)
                            //   ),
                            // );
                          },
                          child: const Text("Clear Filter"),
                        ),

                      )
                    ],
                  ),
                ),

                /// Sort Dropdown
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       const Text("Sort by: "),
                //       DropdownButton<String>(
                //         value: selectedSort,
                //         onChanged: (value) {
                //           setState(() {
                //             selectedSort = value!;
                //           });
                //         },
                //         items: ['High to Low', 'Low to High'].map((String sortOption) {
                //           return DropdownMenuItem<String>(
                //             value: sortOption,
                //             child: Text(sortOption),
                //           );
                //         }).toList(),
                //       ),
                //     ],
                //   ),
                // ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    height: 35,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: Colors.grey),
                    child: DropdownButton<String>(
                      value: selectedSort,
                      icon: const Icon(Icons.sort, color: Colors.black),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      dropdownColor: Colors.grey,
                      underline: Container(),
                      onChanged: (value) {
                        setState(() {
                          selectedSort = value!;
                          // sortProducts(state.products);
                        });
                      },
                      items: ["High to Low", "Low to High"].map((sortOption) {
                        return DropdownMenuItem<String>(
                          value: sortOption,
                          child: Text(sortOption, style: const TextStyle(color: Colors.black)),
                        );
                      }).toList(),
                    ),
                  ),
                ),


                /// Product List
                Expanded(
                  child: widget.productListBuilder(selectedText, selectedSort),
                ),
              ],
            ),

            CategoriesPage(),
            DesignersScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                );
                break;
              case 1:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      (route) => false,
                );
                break;
              case 2:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                      (route) => false,
                );
                break;
            }
          },
        ),
      ),
    );
  }
}


// class FilteredProductTabScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//   final String initialTab;
//   final Widget Function(String selectedCategory) productListBuilder;
//
//   const FilteredProductTabScreen({
//     super.key,
//     required this.selectedCategories,
//     required this.initialTab,
//     required this.productListBuilder,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedText = selectedCategories.isNotEmpty
//         ? selectedCategories[0]["category"]
//         : "No Category Selected";
//
//     final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];
//     final initialIndex = tabTitles.indexOf(initialTab);
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialIndex >= 0 ? initialIndex : 1,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Image.asset('assets/logo.jpeg', height: 30),
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           bottom:PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: LayoutBuilder(
//           builder: (context, constraints) {
//             double screenWidth = constraints.maxWidth;
//             double fontSize = screenWidth > 360 ? 13 : 10;
//
//             return TabBar(
//               isScrollable: false,
//               labelColor: Colors.black,
//               indicatorColor: Colors.black,
//               unselectedLabelColor: Colors.grey,
//               tabs: const [
//                 Tab(text: "Exclusives"),
//                 Tab(text: "New In"),
//                 Tab(text: "Categories"),
//                 Tab(text: "Designers"),
//               ].map((tab) {
//                 return Tab(
//                   child: Text(
//                     tab.text!,
//                     style: TextStyle(fontSize: fontSize),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 );
//               }).toList(),
//             );
//           },
//         ),
//       ),
//
//       actions: [
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => const SearchScreen(),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.shopping_bag_rounded),
//               onPressed: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//               },
//             ),
//           ],
//         ),
//         body: TabBarView(
//           children: [
//             HomeScreen(),
//             Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(12),
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
//                               builder: (_) => FilteredProductTabScreen(
//                                 selectedCategories: [],
//                                 initialTab: initialTab,
//                                 productListBuilder: productListBuilder,
//                               ),
//                             ),
//                           );
//                         },
//                         child: const Text("Clear Filter"),
//                       )
//                     ],
//                   ),
//                 ),
//                 Expanded(child: productListBuilder(selectedText)),
//               ],
//             ),
//             CategoriesPage(),
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
//                       (route) => false,
//                 );
//                 break;
//               case 1:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const WishlistScreen()),
//                       (route) => false,
//                 );
//                 break;
//               case 2:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AccountScreen()),
//                       (route) => false,
//                 );
//                 break;
//             }
//           },
//         ),
//       ),
//     );
//   }
// }
