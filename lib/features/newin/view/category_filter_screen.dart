import 'package:aashniandco/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle

// Import your BLoC and other necessary screens
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:aashniandco/logic/bloc/new_in/new_in_products_bloc.dart';
// import 'package:aashniandco/data/repository/product_repository.dart';
// import 'package:aashniandco/features/newin/view/new_in_products_screen.dart';
// import 'package:aashniandco/features/newin/view/category_result_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemUiOverlayStyle

// UNCOMMENT these imports when you integrate this into your project
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:aashniandco/logic/bloc/new_in/new_in_products_bloc.dart';
// import 'package:aashniandco/data/repository/product_repository.dart';
// import 'package:aashniandco/features/newin/view/new_in_products_screen.dart';
// import 'package:aashniandco/features/newin/view/category_result_screen.dart';


class CategoryFilterScreen extends StatefulWidget {
  const CategoryFilterScreen({super.key});
  //
  @override
  State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  // The full data structure as provided
  final List<Map<String, dynamic>> filter = [
    {"name": "Accessories", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Bags", "isSelected": false, "id": 101},
        {"name": "Shoes", "isSelected": false, "id": 102},
        {"name": "Scarves & Stoles", "isSelected": false, "id": 103},
        {"name": "Belts", "isSelected": false, "id": 104},
      ],},
    {"name": "Jewelry", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Earrings", "isSelected": false, "id": 101},
        {"name": "Necklaces", "isSelected": false, "id": 102},
        {"name": "Jewelry Sets", "isSelected": false, "id": 103},
        {"name": "Bangles & Bracelets", "isSelected": false, "id": 104},
        {"name": "Nose rings", "isSelected": false, "id": 105},
        {"name": "Hair Accessories", "isSelected": false, "id": 106},
        {"name": "Hand Harness", "isSelected": false, "id": 107},
        {"name": "Fine Jewelry", "isSelected": false, "id": 108},
        {"name": "Rings", "isSelected": false, "id": 109},
        {"name": "Foot Harness", "isSelected": false, "id": 110},
        {"name": "Brooches", "isSelected": false, "id": 111},
      ], },
    {"name": "Kidswear", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets for Boys", "isSelected": false, "id": 201},
        {"name": "Lehengas", "isSelected": false, "id": 202},
        {"name": "Dresses", "isSelected": false, "id": 203},
        {"name": "Shararas", "isSelected": false, "id": 204},
        {"name": "Kurta Sets for Girls", "isSelected": false, "id": 205},
        {"name": "Bandi Set", "isSelected": false, "id": 206},
        {"name": "Shirts", "isSelected": false, "id": 207},
        {"name": "Jackets", "isSelected": false, "id": 208},
        {"name": "Co-ord set", "isSelected": false, "id": 209},
        {"name": "Kids Accessories", "isSelected": false, "id": 210},
        {"name": "Dhoti sets", "isSelected": false, "id": 211},
        {"name": "Crop Top And Skirt Sets", "isSelected": false, "id": 212},
        {"name": "Anarkalis", "isSelected": false, "id": 213},
        {"name": "Bandhgalas", "isSelected": false, "id": 214},
        {"name": "Gowns", "isSelected": false, "id": 215},
        {"name": "Jumpsuit", "isSelected": false, "id": 216},
        {"name": "Sherwanis", "isSelected": false, "id": 217},
        {"name": "Achkan", "isSelected": false, "id": 218},
        {"name": "Bags", "isSelected": false, "id": 219},
        {"name": "Sarees", "isSelected": false, "id": 220},
        {"name": "Tops", "isSelected": false, "id": 221},
        {"name": "Skirts", "isSelected": false, "id": 222},
        {"name": "Pants", "isSelected": false, "id": 223},
      ] },
    {"name": "Men", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets", "isSelected": false, "id": 301},
        {"name": "Men's Accessories", "isSelected": false, "id": 302},
        {"name": "Sherwanis", "isSelected": false, "id": 303},
        {"name": "Jackets", "isSelected": false, "id": 304},
        {"name": "Kurtas", "isSelected": false, "id": 305},
        {"name": "Shirts", "isSelected": false, "id": 306},
        {"name": "Bandi Sets", "isSelected": false, "id": 307},
        {"name": "Shoes", "isSelected": false, "id": 308},
        {"name": "Bandhgalas", "isSelected": false, "id": 309},
        {"name": "Blazers", "isSelected": false, "id": 310},
        {"name": "Bandis", "isSelected": false, "id": 311},
        {"name": "Trousers", "isSelected": false, "id": 312},
        {"name": "Nehru Jackets", "isSelected": false, "id": 313},
        {"name": "Co-ords", "isSelected": false, "id": 314},
      ] },
    {"name": "Women's Clothing", "isExpanded": false, "isSelected": false,
      "children": [
        {"name": "Kurta Sets", "isSelected": false, "id": 401},
        {"name": "Lehengas", "isSelected": false, "id": 402},
        {"name": "Saris", "isSelected": false, "id": 403},
        {"name": "Dresses", "isSelected": false, "id": 404},
        {"name": "Co-ords", "isSelected": false, "id": 405},
        {"name": "Jackets", "isSelected": false, "id": 406},
        {"name": "Sharara Sets", "isSelected": false, "id": 407},
        {"name": "Tops", "isSelected": false, "id": 408},
        {"name": "Anarkalis", "isSelected": false, "id": 409},
        {"name": "Kaftans", "isSelected": false, "id": 410},
        {"name": "Gowns", "isSelected": false, "id": 411},
        {"name": "Pants", "isSelected": false, "id": 412},
        {"name": "Capes", "isSelected": false, "id": 413},
        {"name": "Tunics & Kurtis", "isSelected": false, "id": 414},
        {"name": "Jumpsuits", "isSelected": false, "id": 415},
        {"name": "Kurtas", "isSelected": false, "id": 416},
        {"name": "Skirts", "isSelected": false, "id": 417},
        {"name": "Palazzo Sets", "isSelected": false, "id": 418},
        {"name": "Beach", "isSelected": false, "id": 419},
      ]},
  ];

  void _onParentSelected(bool? value, int index) {
    setState(() {
      filter[index]["isSelected"] = value!;
      for (var child in (filter[index]["children"] as List)) {
        child["isSelected"] = value;
      }
    });
  }

  void _onChildSelected(bool? value, int parentIndex, int childIndex) {
    setState(() {
      (filter[parentIndex]["children"] as List)[childIndex]["isSelected"] = value!;
      if (!value!) {
        filter[parentIndex]["isSelected"] = false;
      } else {
        // Optional: check if all children are selected to auto-select parent
        final children = filter[parentIndex]["children"] as List;
        final allChildrenSelected = children.every((child) => child["isSelected"] == true);
        if (allChildrenSelected) {
          filter[parentIndex]["isSelected"] = true;
        }
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      for (var category in filter) {
        category["isSelected"] = false;
        for (var child in (category["children"] as List)) {
          child["isSelected"] = false;
        }
      }
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> selectedFilter = [];
    for (var cat in filter) {
      // Logic for adding selected parent categories
      if (cat["isSelected"] == true) {
        selectedFilter.add({"theme": cat["name"], "filter": cat["name"], "id": null});
      } else { // If parent isn't selected, check for individual children
        for (var child in (cat["children"] as List)) {
          if (child["isSelected"] == true) {
            selectedFilter.add({"theme": cat["name"], "subCategory": child["name"], "id": child["id"]});
          }
        }
      }
    }

    if (selectedFilter.isNotEmpty) {
      final selectedNames = selectedFilter
          .map((item) => item["subCategory"] ?? item["filter"])
          .where((name) => name != null)
          .join(", ");

      final selectedSubcategory = selectedFilter
          .firstWhere((item) => item["subCategory"] != null, orElse: () => {});

      // Your existing navigation logic
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (_) => BlocProvider(
      //       create: (_) => NewInProductsBloc(
      //         productRepository: ProductRepository(),
      //         subcategory: selectedNames,
      //         selectedCategories: selectedFilter,
      //       ),
      //       child: NewInProductsScreen(
      //         selectedCategories: selectedFilter,
      //         subcategory: selectedSubcategory["subCategory"] ?? '',
      //         initialTab: selectedFilter.first["filter"] ?? '',
      //         productListBuilder: (category, sort) {
      //           return CategoryResultScreen(
      //             selectedCategories: selectedFilter,
      //           );
      //         },
      //       ),
      //     ),
      //   ),
      // );

      print("Applying filters with data: $selectedFilter");
      Navigator.pop(context); // Example action: just go back
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No categories selected.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          "Category",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text(
              "CLEAR ALL",
              style: TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: filter.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = filter[index];
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey(category["name"]),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (value) => _onParentSelected(value, index),
                          activeColor: Colors.black,
                        ),
                        Expanded(
                          child: Text(
                            category["name"],
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onExpansionChanged: (expanded) {
                      setState(() => filter[index]["isExpanded"] = expanded);
                    },
                    initiallyExpanded: category["isExpanded"],
                    children: (category["children"] as List).asMap().entries.map((entry) {
                      final childIndex = entry.key;
                      final child = entry.value;
                      return ListTile(
                        contentPadding: const EdgeInsets.only(left: 32, right: 16),
                        dense: true,
                        title: Text(child["name"] ?? ""),
                        leading: Checkbox(
                          value: child["isSelected"] ?? false,
                          onChanged: (value) => _onChildSelected(value, index, childIndex),
                          activeColor: Colors.black,
                        ),
                        onTap: () {
                          _onChildSelected(!(child["isSelected"] ?? false), index, childIndex);
                        },
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
          _buildBottomActionBar(),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              List<Map<String, dynamic>> selectedFilter = [];

              for (var cat in filter) {
                if (cat["isSelected"] == true) {
                  selectedFilter.add({
                    "theme": cat["name"],
                    "filter": cat["name"],
                    "id": null,
                  });
                }
                for (var child in cat["children"]) {
                  if (child["isSelected"] == true) {
                    selectedFilter.add({
                      "theme": cat["name"],
                      "subCategory": child["name"],
                      "id": child["id"]
                    });
                  }
                }
              }

              if (selectedFilter.isNotEmpty) {
                // Collecting selected subcategories for navigation
                final selectedNames = selectedFilter
                    .map((item) => item["subCategory"] ?? item["filter"])
                    .where((name) => name != null)
                    .join(", ");

                // Check if "Bags" is in selected subcategories
                // final selectedSubcategory = selectedFilter
                //     .firstWhere((item) => item["subCategory"] == "Bags", orElse: () => {});
// Get the first valid selected subcategory
                final selectedSubcategory = selectedFilter
                    .firstWhere(
                      (item) => item["subCategory"] != null,
                  orElse: () => {}, // Return an empty map if no subcategory is selected
                );

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NewInProductsBloc(
                        productRepository: ProductRepository(),
                        subcategory: selectedNames,
                        selectedCategories: selectedFilter,
                      ),
                      child: NewInProductsScreen(
                        selectedCategories: selectedFilter,
                        subcategory: selectedSubcategory["subCategory"] ?? '',
                        initialTab: selectedFilter.first["filter"] ?? '',
                        productListBuilder: (category, sort) {
                          return CategoryResultScreen(
                            selectedCategories: selectedFilter,
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },

            // onPressed: () {
            //   List<Map<String, dynamic>> selectedFilter = [];
            //
            //   for (var cat in filter) {
            //     if (cat["isSelected"] == true) {
            //       selectedFilter.add({
            //         "theme": cat["name"],
            //         "filter": cat["name"],
            //         "id": null,
            //       });
            //     }
            //     for (var child in cat["children"]) {
            //       if (child["isSelected"] == true) {
            //         selectedFilter.add({
            //           "theme": cat["name"],
            //           "subCategory": child["name"],
            //           "id": child["id"]
            //         });
            //       }
            //     }
            //   }
            //
            //   if (selectedFilter.isNotEmpty) {
            //     // Collecting selected subcategories for navigation
            //     final selectedNames = selectedFilter
            //         .map((item) => item["subCategory"] ?? item["filter"])
            //         .where((name) => name != null)
            //         .join(", ");
            //
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (_) => BlocProvider(
            //           create: (_) => NewInProductsBloc(
            //             productRepository: ProductRepository(),
            //             subcategory: selectedNames,
            //             selectedCategories: selectedFilter,
            //           ),
            //           child: NewInProductsScreen(
            //             selectedCategories: selectedFilter,
            //             subcategory: selectedNames,
            //             initialTab: selectedFilter.first["filter"] ?? '',
            //             productListBuilder: (category, sort) {
            //               return CategoryResultScreen(
            //                 selectedCategories: selectedFilter,
            //               );
            //             },
            //           ),
            //         ),
            //       ),
            //     );
            //   }
            // },
            child: const Text(
              "Apply",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
// class CategoryFilterScreen extends StatefulWidget {
//   const CategoryFilterScreen({super.key});
//
//   @override
//   State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
// }
//
// class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
//
//
//
//
//
//   final List<Map<String, dynamic>> filter = [
//     {"name": "Accessories", "isExpanded": false, "isSelected": false,
//       "children": [
//         {"name": "Bags", "isSelected": false, "id": 101},
//         {"name": "Shoes", "isSelected": false, "id": 102},
//         {"name": "Scarves & Stoles", "isSelected": false, "id": 103},
//         {"name": "Belts", "isSelected": false, "id": 104},
//       ],},
//     {"name": "Jewelry", "isExpanded": false, "isSelected": false,
//       "children": [
//         {"name": "Earrings", "isSelected": false, "id": 101},
//         {"name": "Necklaces", "isSelected": false, "id": 102},
//         {"name": "Jewelry Sets", "isSelected": false, "id": 103},
//         {"name": "Bangles & Bracelets", "isSelected": false, "id": 104},
//         {"name": "Nose rings", "isSelected": false, "id": 101},
//         {"name": "Hair Accessories", "isSelected": false, "id": 102},
//         {"name": "Hand Harness", "isSelected": false, "id": 103},
//         {"name": "Fine Jewelry", "isSelected": false, "id": 104},
//         {"name": "Rings", "isSelected": false, "id": 101},
//         {"name": "Foot Harness", "isSelected": false, "id": 102},
//         {"name": "Brooches", "isSelected": false, "id": 103},
//
//
//
//       ], },
//     {"name": "Kidswear", "isExpanded": false, "isSelected": false,
//       "children": [
//         {"name": "Kurta Sets for Boys", "isSelected": false, "id": 201},
//         {"name": "Lehengas", "isSelected": false, "id": 202},
//         {"name": "Dresses", "isSelected": false, "id": 203},
//         {"name": "Shararas", "isSelected": false, "id": 204},
//         {"name": "Kurta Sets for Girls", "isSelected": false, "id": 205},
//         {"name": "Bandi Set", "isSelected": false, "id": 206},
//         {"name": "Shirts", "isSelected": false, "id": 207},
//         {"name": "Jackets", "isSelected": false, "id": 208},
//         {"name": "Co-ord set", "isSelected": false, "id": 209},
//         {"name": "Kids Accessories", "isSelected": false, "id": 210},
//         {"name": "Dhoti sets", "isSelected": false, "id": 211},
//         {"name": "Crop Top And Skirt Sets", "isSelected": false, "id": 212},
//         {"name": "Anarkalis", "isSelected": false, "id": 213},
//         {"name": "Bandhgalas", "isSelected": false, "id": 214},
//         {"name": "Gowns", "isSelected": false, "id": 215},
//         {"name": "Jumpsuit", "isSelected": false, "id": 216},
//         {"name": "Sherwanis", "isSelected": false, "id": 217},
//         {"name": "Achkan", "isSelected": false, "id": 218},
//         {"name": "Bags", "isSelected": false, "id": 219},
//         {"name": "Sarees", "isSelected": false, "id": 220},
//         {"name": "Tops", "isSelected": false, "id": 221},
//         {"name": "Skirts", "isSelected": false, "id": 222},
//         {"name": "Pants", "isSelected": false, "id": 223},
//       ] },
//
//     {"name": "Men", "isExpanded": false, "isSelected": false,
//       "children": [
//         {"name": "Kurta Sets", "isSelected": false, "id": 301},
//         {"name": "Men's Accessories", "isSelected": false, "id": 302},
//         {"name": "Sherwanis", "isSelected": false, "id": 303},
//         {"name": "Jackets", "isSelected": false, "id": 304},
//         {"name": "Kurtas", "isSelected": false, "id": 305},
//         {"name": "Shirts", "isSelected": false, "id": 306},
//         {"name": "Bandi Sets", "isSelected": false, "id": 307},
//         {"name": "Shoes", "isSelected": false, "id": 308},
//         {"name": "Bandhgalas", "isSelected": false, "id": 309},
//         {"name": "Blazers", "isSelected": false, "id": 310},
//         {"name": "Bandis", "isSelected": false, "id": 311},
//         {"name": "Trousers", "isSelected": false, "id": 312},
//         {"name": "Nehru Jackets", "isSelected": false, "id": 313},
//         {"name": "Co-ords", "isSelected": false, "id": 314},
//       ] },
//
//     {"name": "Women's Clothing", "isExpanded": false, "isSelected": false,
//       "children": [
//         {"name": "Kurta Sets", "isSelected": false, "id": 401},
//         {"name": "Lehengas", "isSelected": false, "id": 402},
//         {"name": "Saris", "isSelected": false, "id": 403},
//         {"name": "Dresses", "isSelected": false, "id": 404},
//         {"name": "Co-ords", "isSelected": false, "id": 405},
//         {"name": "Jackets", "isSelected": false, "id": 406},
//         {"name": "Sharara Sets", "isSelected": false, "id": 407},
//         {"name": "Tops", "isSelected": false, "id": 408},
//         {"name": "Anarkalis", "isSelected": false, "id": 409},
//         {"name": "Kaftans", "isSelected": false, "id": 410},
//         {"name": "Gowns", "isSelected": false, "id": 411},
//         {"name": "Pants", "isSelected": false, "id": 412},
//         {"name": "Capes", "isSelected": false, "id": 413},
//         {"name": "Tunics & Kurtis", "isSelected": false, "id": 414},
//         {"name": "Jumpsuits", "isSelected": false, "id": 415},
//         {"name": "Kurtas", "isSelected": false, "id": 416},
//         {"name": "Skirts", "isSelected": false, "id": 417},
//         {"name": "Palazzo Sets", "isSelected": false, "id": 418},
//         {"name": "Beach", "isSelected": false, "id": 419},
//       ]},
//
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Category"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: filter.length,
//               itemBuilder: (context, index) {
//                 final category = filter[index];
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD3D4D3),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         blurRadius: 4,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Theme(
//                     data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                     child: ExpansionTile(
//                       tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//                       childrenPadding: const EdgeInsets.only(bottom: 12),
//                       title: Row(
//                         children: [
//                           Checkbox(
//                             value: category["isSelected"],
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 filter[index]["isSelected"] = value!;
//                               });
//                             },
//                           ),
//                           Expanded(
//                             child: Text(
//                               category["name"],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       initiallyExpanded: category["isExpanded"],
//                       onExpansionChanged: (bool expanded) {
//                         setState(() {
//                           filter[index]["isExpanded"] = expanded;
//                         });
//                       },
//                       children: (category["children"] as List).map<Widget>((child) {
//                         return Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                           child: Row(
//                             children: [
//                               Checkbox(
//                                 value: child["isSelected"] ?? false,
//                                 onChanged: (bool? value) {
//                                   setState(() {
//                                     child["isSelected"] = value!;
//                                   });
//                                 },
//                               ),
//                               Expanded(child: Text(child["name"] ?? "")),
//                             ],
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           /// Apply Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//     onPressed: () {
//     List<Map<String, dynamic>> selectedFilter = [];
//
//     for (var cat in filter) {
//     if (cat["isSelected"] == true) {
//     selectedFilter.add({
//     "theme": cat["name"],
//     "filter": cat["name"],
//     "id": null,
//     });
//     }
//     for (var child in cat["children"]) {
//     if (child["isSelected"] == true) {
//     selectedFilter.add({
//     "theme": cat["name"],
//     "subCategory": child["name"],
//     "id": child["id"]
//     });
//     }
//     }
//     }
//
//     if (selectedFilter.isNotEmpty) {
//     // Collecting selected subcategories for navigation
//     final selectedNames = selectedFilter
//         .map((item) => item["subCategory"] ?? item["filter"])
//         .where((name) => name != null)
//         .join(", ");
//
//     // Check if "Bags" is in selected subcategories
//     // final selectedSubcategory = selectedFilter
//     //     .firstWhere((item) => item["subCategory"] == "Bags", orElse: () => {});
// // Get the first valid selected subcategory
//       final selectedSubcategory = selectedFilter
//           .firstWhere(
//             (item) => item["subCategory"] != null,
//         orElse: () => {}, // Return an empty map if no subcategory is selected
//       );
//
//     Navigator.push(
//     context,
//     MaterialPageRoute(
//     builder: (_) => BlocProvider(
//     create: (_) => NewInProductsBloc(
//     productRepository: ProductRepository(),
//     subcategory: selectedNames,
//     selectedCategories: selectedFilter,
//     ),
//     child: NewInProductsScreen(
//     selectedCategories: selectedFilter,
//     subcategory: selectedSubcategory["subCategory"] ?? '',
//     initialTab: selectedFilter.first["filter"] ?? '',
//     productListBuilder: (category, sort) {
//     return CategoryResultScreen(
//     selectedCategories: selectedFilter,
//     );
//     },
//     ),
//     ),
//     ),
//     );
//     }
//     },
//
//     // onPressed: () {
//                 //   List<Map<String, dynamic>> selectedFilter = [];
//                 //
//                 //   for (var cat in filter) {
//                 //     if (cat["isSelected"] == true) {
//                 //       selectedFilter.add({
//                 //         "theme": cat["name"],
//                 //         "filter": cat["name"],
//                 //         "id": null,
//                 //       });
//                 //     }
//                 //     for (var child in cat["children"]) {
//                 //       if (child["isSelected"] == true) {
//                 //         selectedFilter.add({
//                 //           "theme": cat["name"],
//                 //           "subCategory": child["name"],
//                 //           "id": child["id"]
//                 //         });
//                 //       }
//                 //     }
//                 //   }
//                 //
//                 //   if (selectedFilter.isNotEmpty) {
//                 //     // Collecting selected subcategories for navigation
//                 //     final selectedNames = selectedFilter
//                 //         .map((item) => item["subCategory"] ?? item["filter"])
//                 //         .where((name) => name != null)
//                 //         .join(", ");
//                 //
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => BlocProvider(
//                 //           create: (_) => NewInProductsBloc(
//                 //             productRepository: ProductRepository(),
//                 //             subcategory: selectedNames,
//                 //             selectedCategories: selectedFilter,
//                 //           ),
//                 //           child: NewInProductsScreen(
//                 //             selectedCategories: selectedFilter,
//                 //             subcategory: selectedNames,
//                 //             initialTab: selectedFilter.first["filter"] ?? '',
//                 //             productListBuilder: (category, sort) {
//                 //               return CategoryResultScreen(
//                 //                 selectedCategories: selectedFilter,
//                 //               );
//                 //             },
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     );
//                 //   }
//                 // },
//                 child: const Text(
//                   "Apply",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     appBar: AppBar(
//   //       title: const Text("Select Category"),
//   //       backgroundColor: Colors.white,
//   //       foregroundColor: Colors.black,
//   //       elevation: 1,
//   //     ),
//   //     body: Column(
//   //       children: [
//   //         Expanded(
//   //           child: ListView.builder(
//   //             itemCount: filter.length,
//   //             itemBuilder: (context, index) {
//   //               final category = filter[index];
//   //               return Container(
//   //                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//   //                 decoration: BoxDecoration(
//   //                   color: const Color(0xFFD3D4D3),
//   //                   borderRadius: BorderRadius.circular(12),
//   //                   boxShadow: [
//   //                     BoxShadow(
//   //                       color: Colors.grey.withOpacity(0.15),
//   //                       blurRadius: 4,
//   //                       offset: const Offset(0, 3),
//   //                     ),
//   //                   ],
//   //                 ),
//   //                 child: Theme(
//   //                   data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//   //                   child: ExpansionTile(
//   //                     tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//   //                     childrenPadding: const EdgeInsets.only(bottom: 12),
//   //                     title: Row(
//   //                       children: [
//   //                         Checkbox(
//   //                           value: category["isSelected"],
//   //                           onChanged: (bool? value) {
//   //                             setState(() {
//   //                               filter[index]["isSelected"] = value!;
//   //                             });
//   //                           },
//   //                         ),
//   //                         Expanded(
//   //                           child: Text(
//   //                             category["name"],
//   //                             style: const TextStyle(
//   //                               fontWeight: FontWeight.w600,
//   //                               fontSize: 16,
//   //                             ),
//   //                           ),
//   //                         ),
//   //                       ],
//   //                     ),
//   //                     initiallyExpanded: category["isExpanded"],
//   //                     onExpansionChanged: (bool expanded) {
//   //                       setState(() {
//   //                         filter[index]["isExpanded"] = expanded;
//   //                       });
//   //                     },
//   //                     children: (category["children"] as List).map<Widget>((child) {
//   //                       return Padding(
//   //                         padding: const EdgeInsets.symmetric(horizontal: 16),
//   //                         child: Row(
//   //                           children: [
//   //                             Checkbox(
//   //                               value: child["isSelected"] ?? false,
//   //                               onChanged: (bool? value) {
//   //                                 setState(() {
//   //                                   child["isSelected"] = value!;
//   //                                 });
//   //                               },
//   //                             ),
//   //                             Expanded(child: Text(child["name"] ?? "")),
//   //                           ],
//   //                         ),
//   //                       );
//   //                     }).toList(),
//   //                   ),
//   //                 ),
//   //               );
//   //             },
//   //           ),
//   //         ),
//   //
//   //         /// Apply Button
//   //         Padding(
//   //           padding: const EdgeInsets.all(16.0),
//   //           child: SizedBox(
//   //             width: double.infinity,
//   //             child: ElevatedButton(
//   //               style: ElevatedButton.styleFrom(
//   //                 backgroundColor: Colors.black,
//   //                 padding: const EdgeInsets.symmetric(vertical: 16),
//   //                 shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(12),
//   //                 ),
//   //               ),
//   //
//   //               onPressed: () {
//   //                 List<Map<String, dynamic>> selectedFilter = [];
//   //
//   //                 for (var cat in filter) {
//   //                   if (cat["isSelected"] == true) {
//   //                     selectedFilter.add({
//   //                       "theme": cat["name"],
//   //                       "filter": cat["name"],
//   //                       "id": null,
//   //                     });
//   //                   }
//   //                   for (var child in cat["children"]) {
//   //                     if (child["isSelected"] == true) {
//   //                       selectedFilter.add({
//   //                         "theme": cat["name"],
//   //                         "subCategory": child["name"],
//   //                         "id": child["id"]
//   //                       });
//   //                     }
//   //                   }
//   //                 }
//   //
//   //                 if (selectedFilter.isNotEmpty) {
//   //                   // Collecting selected subcategories for navigation
//   //                   final selectedNames = selectedFilter
//   //                       .map((item) => item["subCategory"] ?? item["filter"])
//   //                       .where((name) => name != null)
//   //                       .join(", ");
//   //
//   //
//   //                   Navigator.push(
//   //                     context,
//   //                     MaterialPageRoute(
//   //                       builder: (_) => BlocProvider(
//   //                         create: (_) => NewInProductsBloc(
//   //                           productRepository: ProductRepository(),
//   //                           subcategory: selectedNames,
//   //                           selectedCategories: selectedFilter,
//   //                         ),
//   //                         child: NewInProductsScreen(
//   //                           selectedCategories: selectedFilter,
//   //                           subcategory: selectedNames,
//   //                           initialTab: selectedFilter.first["filter"] ?? '',
//   //                           productListBuilder: (category, sort) {
//   //                             return CategoryResultScreen(
//   //                               selectedCategories: selectedFilter,
//   //                             );
//   //                           },
//   //                         ),
//   //                       ),
//   //                     ),
//   //                   );
//   //                 }
//   //               },
//   //
//   //               // onPressed: () {
//   //               //   List<Map<String, dynamic>> selectedFilter = [];
//   //               //
//   //               //   for (var cat in filter) {
//   //               //     if (cat["isSelected"] == true) {
//   //               //       selectedFilter.add({
//   //               //         "theme": cat["name"],
//   //               //         "filter": cat["name"],
//   //               //         "id": null,
//   //               //       });
//   //               //     }
//   //               //     for (var child in cat["children"]) {
//   //               //       if (child["isSelected"] == true) {
//   //               //         selectedFilter.add({
//   //               //           "theme": cat["name"],
//   //               //           "subCategory": child["name"],
//   //               //           "id": child["id"]
//   //               //         });
//   //               //       }
//   //               //     }
//   //               //   }
//   //               //
//   //               //   if (selectedFilter.isNotEmpty) {
//   //               //     final selectedNames = selectedFilter
//   //               //         .map((item) => item["filter"] ?? item["subCategory"])
//   //               //         .join(", ");
//   //               //
//   //               //     Navigator.push(
//   //               //       context,
//   //               //       MaterialPageRoute(
//   //               //         builder: (_) => BlocProvider(
//   //               //           create: (_) => NewInProductsBloc(
//   //               //             productRepository: ProductRepository(),
//   //               //             subcategory: selectedNames,
//   //               //             selectedCategories: selectedFilter,
//   //               //           ),
//   //               //           child: NewInProductsScreen(
//   //               //             selectedCategories: selectedFilter,
//   //               //             subcategory: selectedNames,
//   //               //             initialTab: selectedFilter.first["filter"] ?? '',
//   //               //             productListBuilder: (category, sort) {
//   //               //               return CategoryResultScreen(
//   //               //                 selectedCategories: selectedFilter,
//   //               //               );
//   //               //             },
//   //               //           ),
//   //               //         ),
//   //               //       ),
//   //               //     );
//   //               //     ;
//   //               //   }
//   //               // },
//   //               child: const Text(
//   //                 "Apply",
//   //                 style: TextStyle(fontSize: 16, color: Colors.white),
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }


// class CategoryColorScreen extends StatefulWidget {
//   const CategoryColorScreen({super.key});
//
//   @override
//   State<CategoryColorScreen> createState() => _CategoryColorScreenState();
// }
//
// class _CategoryColorScreenState extends State<CategoryColorScreen> {
//
//   final List <Map<String,dynamic>>color= [
//
//     {
//
//       "name": "Black",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "Blue",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Brown",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Burgundy",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Green",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Grey",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Metallic",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Multicolor",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Neutrals",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Orange",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Peach",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Pink",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Print",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Purple",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Red",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Gold",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Silver",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "White",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Yellow",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar:AppBar(
//         title: Text("Select Theme"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: color.length,
//               itemBuilder: (context, index) {
//                 final category = color[index];
//                 return Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD3D4D3),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.15),
//                         blurRadius: 4,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Theme(
//                     data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
//                     child: ExpansionTile(
//                       tilePadding: const EdgeInsets.symmetric(horizontal: 16),
//                       childrenPadding: const EdgeInsets.only(bottom: 12),
//                       title: Row(
//                         children: [
//                           Checkbox(
//                             value: category["isSelected"],
//                             onChanged: (bool? value) {
//                               setState(() {
//                                 color[index]["isSelected"] = value!;
//                                 if (value) {
//                                   for (var child in category["children"]) {
//                                     child["isSelected"] = false;
//                                   }
//                                 }
//                               });
//                             },
//                           ),
//                           Expanded(
//                             child: Text(
//                               category["name"],
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.w600,
//                                 fontSize: 16,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       trailing: const SizedBox.shrink(),
//                       initiallyExpanded: category["isExpanded"],
//                       onExpansionChanged: (bool expanded) {
//                         setState(() {
//                           color[index]["isExpanded"] = expanded;
//                         });
//                       },
//
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           /// Apply Button
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//
//                 onPressed: () {
//                   List<Map<String, dynamic>> selected = [];
//
//                   // Populate selected categories and subcategories
//                   for (var cat in color) {
//                     if (cat["isSelected"] == true) {
//                       // selected.add({"theme": cat["name"], "id": null});
//
//                       selected.add({
//                         "theme": cat["name"],
//                         "color": cat["name"], // 👈 Add this line
//                         "id": null,
//                       });
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selected.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//
//                   // Build selected subcategories
//                   final List<Map<String, dynamic>> selectedSubcategories = [];
//                   for (final mainCategory in color) {
//                     for (final sub in mainCategory['children']) {
//                       if (sub['isSelected'] == true) {
//                         selectedSubcategories.add({
//                           "subCategory": sub['name'],
//                           "id": sub['id'],
//                           "isSelected": true,
//                         });
//                       }
//                     }
//                   }
//
//                   if (selected.any((item) => item["subCategory"] != null)) {
//                     // ✅ Navigate if any subcategory is selected
//                     final selectedSubcategoryNames = selected
//                         .where((item) => item["subCategory"] != null)
//                         .map((e) => e["subCategory"] as String)
//                         .toList();
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: selectedSubcategoryNames.join(", "),
//                           initialTab: selectedSubcategoryNames.isNotEmpty
//                               ? selectedSubcategoryNames.first
//                               : '',
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selectedSubcategories,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   } else if (selected.length == 1 && selected[0]["id"] == null) {
//                     // ✅ Navigate when only theme (like Contemporary or Ethnic) is selected
//                     String themeName = selected[0]["theme"];
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: themeName,
//                           initialTab: themeName,
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: [],
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 }
//                 ,
//
//                 child: const Text(
//                   "Apply",
//                   style: TextStyle(fontSize: 16, color: Colors.white),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }
//
