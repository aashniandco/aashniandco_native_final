import 'package:aashniandco/features/newin/bloc/newin_products_bloc.dart';
import 'package:aashniandco/features/newin/bloc/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';




class CategoryShipinScreen extends StatefulWidget {
  const CategoryShipinScreen({super.key});

  @override
  State<CategoryShipinScreen> createState() => _CategoryShipinScreenState();
}

class _CategoryShipinScreenState extends State<CategoryShipinScreen> {
  // Data structure for shipping time selection
  final List<Map<String, dynamic>> shipin = [
    {"name": "Immediate", "isSelected": false, "children": []},
    {"name": "1-2 Weeks", "isSelected": false, "children": []},
    {"name": "2-4 Weeks", "isSelected": false, "children": []},
    {"name": "4-6 Weeks", "isSelected": false, "children": []},
    {"name": "6-8 Weeks", "isSelected": false, "children": []},
    {"name": "8 Weeks", "isSelected": false, "children": []},
  ];

  // Handler for shipping time selection
  void _onShipinSelected(bool? value, int index) {
    setState(() {
      shipin[index]["isSelected"] = value ?? false;
    });
  }

  // Handler for the "CLEAR ALL" button
  void _clearAllFilters() {
    setState(() {
      for (var item in shipin) {
        item["isSelected"] = false;
      }
    });
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
          "Select Ships In", // Updated title
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
              itemCount: shipin.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = shipin[index];
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey(category["name"]),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (value) => _onShipinSelected(value, index),
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
                    // Empty list hides the expansion arrow
                    children: const <Widget>[],
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
              List<Map<String, dynamic>> selectedShipsin = [];

              for (var cat in shipin) {
                if (cat["isSelected"] == true) {
                  selectedShipsin.add({
                    "theme": cat["name"],
                    "shipin": cat["name"],
                    "id": null,
                  });
                }
              }

              if (selectedShipsin.isNotEmpty) {
                // **FIXED**: Correctly maps the "shipin" key instead of "color"
                final selectedNames = selectedShipsin
                    .map((item) => item["shipin"] ?? item["subCategory"])
                    .join(", ");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NewInProductsBloc(
                        productRepository: ProductRepository(),
                        subcategory: selectedNames,
                        selectedCategories: selectedShipsin,
                      ),
                      child: NewInProductsScreen(
                        selectedCategories: selectedShipsin,
                        subcategory: selectedNames,
                        initialTab: selectedShipsin.first["shipin"] ?? '',
                        productListBuilder: (category, sort) {
                          return CategoryResultScreen(
                            selectedCategories: selectedShipsin,
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select at least one shipping time.")),
                );
              }
            },
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

// class CategoryShipinScreen extends StatefulWidget {
//   const CategoryShipinScreen({super.key});
//
//   @override
//   State<CategoryShipinScreen> createState() => _CategoryShipinScreenState();
// }
//
// class _CategoryShipinScreenState extends State<CategoryShipinScreen> {
//
//   final List <Map<String,dynamic>>shipin= [
//
//     {
//
//       "name": "Immediate",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "1-2 Weeks",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     }
//     ,
//
//     {
//       "name": "2-4 Weeks",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "4-6 Weeks",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "6-8 Weeks",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "8 Weeks",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar:AppBar(
//         title: Text("Select Ships In"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: shipin.length,
//               itemBuilder: (context, index) {
//                 final category = shipin[index];
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
//                                 shipin[index]["isSelected"] = value!;
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
//                           shipin[index]["isExpanded"] = expanded;
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
//                   List<Map<String, dynamic>> selectedShipsin = [];
//
//                   // Populate selected categories and subcategories
//                   for (var cat in shipin) {
//                     if (cat["isSelected"] == true) {
//                       // selected.add({"theme": cat["name"], "id": null});
//                       selectedShipsin.add({
//                         "theme": cat["name"],
//                         "shipin": cat["name"], // 👈 Add this line
//                         "id": null,
//                       });
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selectedShipsin.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   if (selectedShipsin.isNotEmpty) {
//                     final selectedNames = selectedShipsin
//                         .map((item) => item["color"] ?? item["subCategory"])
//                         .join(", ");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BlocProvider(
//                           create: (_) => NewInProductsBloc(
//                             productRepository: ProductRepository(),
//                             subcategory: selectedNames,
//                             selectedCategories: selectedShipsin,
//                           ),
//                           child: NewInProductsScreen(
//                             selectedCategories: selectedShipsin,
//                             subcategory: selectedNames,
//                             initialTab: selectedShipsin.first["shipin"] ?? '',
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: selectedShipsin,
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     );
//                   }
//                 },
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
// }

