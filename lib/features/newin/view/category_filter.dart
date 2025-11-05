// import 'package:aashniandco/features/newin/view/new_in_filter_screen.dart';
//
// import 'package:flutter/material.dart';
//
// import 'package:aashniandco/features/newin/view/new_in_filter_accessories_screen.dart';
//
// import '../../../constants/api_constants.dart';
// import 'category_result_screen.dart';
// import 'new_in_products_screen.dart';
// import 'new_in_wc_lehengas_screen.dart';
//
//
//
// // Dummy screen to display selected categories
//
// class CategoryFilterScreen extends StatefulWidget {
//   const CategoryFilterScreen({super.key});
//
//   @override
//   State<CategoryFilterScreen> createState() => _CategoryFilterScreenState();
// }
//
// class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
//   final List<Map<String, dynamic>> categories = [
//
//
//     {
//
//
//
//       "name": "Accessories",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [
//         {"id": 1408, "name": "ScarvesStoles", "isSelected": false},
//         {"id": 1407, "name": "Bags", "isSelected": false},
//         {"id": 1498, "name": "Belts", "isSelected": false},
//         {"id": 1409, "name": "Shoes", "isSelected": false},
//         {"id": 2071, "name": "Masks", "isSelected": false}
//
//       ]
//     },
//     {
//       "name": "Women's Clothing",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [
//         {"id": 2295, "name": "Lehengas", "isSelected": false},
//         {"id": 4454, "name": "KurtaSets", "isSelected": false},
//         {"id": 2297, "name": "Sarees", "isSelected": false},
//         {"id": 2299, "name": "Tops", "isSelected": false},
//         {"id": 4046, "name": "Kaftans", "isSelected": false},
//         {"id": 3264, "name": "Gowns", "isSelected": false},
//         {"id": 3247, "name": "Pants", "isSelected": false},
//         {"id": 3293, "name": "TunicsKurtis", "isSelected": false},
//         {"id": 4491, "name": "Capes", "isSelected": false},
//         {"id": 3027, "name": "Jumpsuits", "isSelected": false},
//         {"id": 4450, "name": "Kurtas", "isSelected": false},
//         {"id": 3219, "name": "Skirts", "isSelected": false},
//         {"id": 4460, "name": "Palazzo Sets", "isSelected": false},
//         {"id": 2596, "name": "Beach", "isSelected": false},
//         // {"id": 3973, "name": "Loungewear", "isSelected": false}
//       ]
//     },
//
//
//
//     {
//       "name": "Men",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [
//         {"id": 2588, "name": "KurtaSets", "isSelected": false},
//         {"id": 2590, "name": "Sherwanis", "isSelected": false},
//         {"id": 2595, "name": "Jackets", "isSelected": false},
//         {"id": 2591, "name": "MensAccessories", "isSelected": false},
//         {"id": 2587, "name": "Kurtas", "isSelected": false},
//         {"id": 2593, "name": "Shirts", "isSelected": false},
//         {"id": 2594, "name": "KurtaSets", "isSelected": false},
//
//         {"id": 2589, "name": "Bandis", "isSelected": false},
//
//         {"id": 2594, "name": "Trousers", "isSelected": false},
//
//
//       ]
//     },
//
//
//     {
//       "name": "Jewelry",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [
//         {"id": 2588, "name": "Earrings", "isSelected": false},
//         {"id": 2590, "name": "BanglesBracelets", "isSelected": false},
//         {"id": 2595, "name": "FineJewelry", "isSelected": false},
//         {"id": 2591, "name": "HandHarness", "isSelected": false},
//         {"id": 2587, "name": "Rings", "isSelected": false},
//         {"id": 2593, "name": "FootHarness", "isSelected": false},
//         {"id": 2594, "name": "Brooches", "isSelected": false},
//         {"id": 3174, "name": "Giftboxes", "isSelected": false},
//
//
//
//       ]
//     }
// ,
//
//     {
//       "name": "Kidswear",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [
//         {"id": 2588, "name": "Kurta Sets for Boys", "isSelected": false},
//         {"id": 2590, "name": "Shararas", "isSelected": false},
//         {"id": 2595, "name": "Dresses", "isSelected": false},
//         {"id": 2591, "name": "KidsAccessories", "isSelected": false},
//         {"id": 2587, "name": "Shirts", "isSelected": false},
//         {"id": 2593, "name": "Jackets", "isSelected": false},
//         {"id": 2594, "name": "Coordset", "isSelected": false},
//         {"id": 3174, "name": "Anarkalis", "isSelected": false},
//
// {"id": 2588, "name": "Gowns",  "isSelected": false},
// {"id": 2590, "name": "Achkan", "isSelected": false},
// {"id": 2595, "name": "Nightwear", "isSelected": false},
// {"id": 2591, "name": "Bandhgalas", "isSelected": false},
// {"id": 2587, "name": "Dhotisets", "isSelected": false},
// {"id": 2593, "name": "Jumpsuit", "isSelected": false},
// {"id": 2594, "name": "Sherwanis", "isSelected": false},
// {"id": 3174, "name": "Pants", "isSelected": false},
//
//
// {"id": 2588, "name": "Bags","isSelected":  false},
// {"id": 2590, "name": "Tops", "isSelected": false},
// {"id": 2595, "name": "Skirts", "isSelected": false},
// {"id": 2591, "name": "Sarees", "isSelected": false},
//
//
//
//       ]
//     },
//
//
//
//
//   ];
//
//
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
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final category = categories[index];
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
//                                 categories[index]["isSelected"] = value!;
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
//                       initiallyExpanded: category["isExpanded"],
//                       onExpansionChanged: (bool expanded) {
//                         setState(() {
//                           categories[index]["isExpanded"] = expanded;
//                         });
//                       },
//                       children: List.generate(
//                         category["children"].length,
//                             (childIndex) {
//                           final child = category["children"][childIndex];
//                           return Padding(
//                             padding: const EdgeInsets.only(left: 60.0, top: 4, bottom: 4, right: 16),
//                             child: Row(
//                               children: [
//                                 Checkbox(
//                                   value: child["isSelected"],
//                                   onChanged: (bool? value) {
//                                     setState(() {
//                                       child["isSelected"] = value!;
//                                       final anyChildSelected = category["children"]
//                                           .any((c) => c["isSelected"] == true);
//                                       categories[index]["isSelected"] = false;
//                                     });
//                                   },
//                                 ),
//                                 Text(
//                                   child["name"],
//                                   style: const TextStyle(fontSize: 15),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
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
//                 // onPressed: () {
//                 //   List<Map<String, dynamic>> selected = [];
//                 //
//                 //   for (var cat in categories) {
//                 //     if (cat["isSelected"] == true) {
//                 //       selected.add({"category": cat["name"], "id": null});
//                 //     }
//                 //     for (var child in cat["children"]) {
//                 //       if (child["isSelected"] == true) {
//                 //         selected.add({
//                 //           "category": cat["name"],
//                 //           "subCategory": child["name"],
//                 //           "id": child["id"]
//                 //         });
//                 //       }
//                 //     }
//                 //   }
//                 //
//                 //   // Navigate based on number of selected items
//                 //   if (selected.length == 1 &&
//                 //       selected[0]["id"] == null &&
//                 //       selected[0]["category"] == "Women's Clothing") {
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => NewInFilterScreen(selectedCategories: selected),
//                 //       ),
//                 //     );
//                 //   } else if (selected.length == 1 &&
//                 //       selected[0]["id"] == null &&
//                 //       selected[0]["category"] == "Accessories") {
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => NewInFilterAccessoriesScreen(
//                 //           selectedCategories: selected,
//                 //         ),
//                 //       ),
//                 //     );
//                 //   } else if (selected.any((item) => item["subCategory"] != null)) {
//                 //     // Extract all subcategories
//                 //     final selectedSubcategories = selected
//                 //         .where((item) => item["subCategory"] != null)
//                 //         .map((e) => e["subCategory"] as String)
//                 //         .toList();
//                 //
//                 //     Navigator.push(
//                 //       context,
//                 //       MaterialPageRoute(
//                 //         builder: (_) => NewInProductsScreen(
//                 //           selectedCategories: selected,
//                 //           subcategory: selectedSubcategories.join(", "), // Or pass list
//                 //           initialTab: selectedSubcategories.first,
//                 //           productListBuilder: (category, sort) {
//                 //             return CategoryResultScreen(
//                 //               selectedCategories: selected,
//                 //             );
//                 //           },
//                 //         ),
//                 //       ),
//                 //     );
//                 //   }
//                 // }
//                 onPressed: () {
//                   List<Map<String, dynamic>> selected = [];
//
//                   // Populate selected categories and subcategories
//                   for (var cat in categories) {
//                     if (cat["isSelected"] == true) {
//                       selected.add({"category": cat["name"], "id": null});
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selected.add({
//                           "category": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   // Build selected subcategories
//                   final List<Map<String, dynamic>> selectedSubcategories = [];
//                   for (final mainCategory in categories) {
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
//                   // Navigate based on number of selected items
//                   if (selected.length == 1 &&
//                       selected[0]["id"] == null &&
//                       selected[0]["category"] == "Women's Clothing") {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInFilterScreen(selectedCategories: selected),
//                       ),
//                     );
//                   } else if (selected.length == 1 &&
//                       selected[0]["id"] == null &&
//                       selected[0]["category"] == "Accessories") {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => NewInFilterAccessoriesScreen(
//                           selectedCategories: selected,
//                         ),
//                       ),
//                     );
//                   } else if (selected.any((item) => item["subCategory"] != null)) {
//                     // Extract all subcategories
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
//                           subcategory: selectedSubcategoryNames.join(", "), // Or pass list
//                           initialTab: selectedSubcategoryNames.isNotEmpty
//                               ? selectedSubcategoryNames.first
//                               : '',
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selectedSubcategories, // Pass selectedSubcategories
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 },
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
