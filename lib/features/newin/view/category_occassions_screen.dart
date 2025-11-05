import 'package:aashniandco/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CategoryOccassionsScreen extends StatefulWidget {
  const CategoryOccassionsScreen({super.key});

  @override
  State<CategoryOccassionsScreen> createState() => _CategoryOccassionsScreenState();
}

class _CategoryOccassionsScreenState extends State<CategoryOccassionsScreen> {
  // Data structure for occasion selection
  final List<Map<String, dynamic>> occassions = [
    {"name": "Bridesmaid", "isSelected": false, "children": []},
    {"name": "Cocktail", "isSelected": false, "children": []},
    {"name": "Engagement", "isSelected": false, "children": []},
    {"name": "Festive", "isSelected": false, "children": []},
    {"name": "Mehendi & Haldi", "isSelected": false, "children": []},
    {"name": "Party", "isSelected": false, "children": []},
    {"name": "Puja", "isSelected": false, "children": []},
    {"name": "Reception", "isSelected": false, "children": []},
    {"name": "Resort", "isSelected": false, "children": []},
    {"name": "Sangeet", "isSelected": false, "children": []},
    {"name": "Wedding", "isSelected": false, "children": []},
  ];

  // Handler for occasion selection
  void _onOccassionSelected(bool? value, int index) {
    setState(() {
      occassions[index]["isSelected"] = value ?? false;
    });
  }

  // Handler for the "CLEAR ALL" button
  void _clearAllFilters() {
    setState(() {
      for (var item in occassions) {
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
          "Select Occasions", // Updated title
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
              itemCount: occassions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = occassions[index];
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey(category["name"]),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (value) => _onOccassionSelected(value, index),
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
              List<Map<String, dynamic>> selectedOccassions = [];

              for (var cat in occassions) {
                if (cat["isSelected"] == true) {
                  selectedOccassions.add({
                    "theme": cat["name"],
                    "occassions": cat["name"],
                    "id": null,
                  });
                }
              }

              if (selectedOccassions.isNotEmpty) {
                final selectedNames = selectedOccassions
                    .map((item) => item["occassions"] ?? item["subCategory"])
                    .join(", ");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NewInProductsBloc(
                        productRepository: ProductRepository(),
                        subcategory: selectedNames,
                        selectedCategories: selectedOccassions,
                      ),
                      child: NewInProductsScreen(
                        selectedCategories: selectedOccassions,
                        subcategory: selectedNames,
                        initialTab: selectedOccassions.first["occassions"] ?? '',
                        productListBuilder: (category, sort) {
                          return CategoryResultScreen(
                            selectedCategories: selectedOccassions,
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select at least one occasion.")),
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

// 18/8/2025
// class CategoryOccassionsScreen extends StatefulWidget {
//   const CategoryOccassionsScreen({super.key});
//
//   @override
//   State<CategoryOccassionsScreen> createState() => _CategoryOccassionsScreenState();
// }
//
// class _CategoryOccassionsScreenState extends State<CategoryOccassionsScreen> {
//
//
//
//
//
//   final List<Map<String, dynamic>> occassions = [
//     {"name": "Bridesmaid", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Cocktail", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Engagement", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Festive", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Mehendi & Haldi", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Party", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Puja", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Reception", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Resort", "isExpanded": false, "isSelected": false,"children": []},
//     {"name": "Sangeet", "isExpanded": false, "isSelected": false,"children": [] },
//     {"name": "Wedding", "isExpanded": false, "isSelected": false,"children": [] },
//
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Occassions"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: occassions.length,
//               itemBuilder: (context, index) {
//                 final category = occassions[index];
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
//                                 occassions[index]["isSelected"] = value!;
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
//                           occassions[index]["isExpanded"] = expanded;
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
//                 onPressed: () {
//                   List<Map<String, dynamic>> selectedoccassions = [];
//
//                   for (var cat in occassions) {
//                     if (cat["isSelected"] == true) {
//                       selectedoccassions.add({
//                         "theme": cat["name"],
//                         "occassions": cat["name"],
//                         "id": null,
//                       });
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selectedoccassions.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   if (selectedoccassions.isNotEmpty) {
//                     final selectedNames = selectedoccassions
//                         .map((item) => item["occassions"] ?? item["subCategory"])
//                         .join(", ");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BlocProvider(
//                           create: (_) => NewInProductsBloc(
//                             productRepository: ProductRepository(),
//                             subcategory: selectedNames,
//                             selectedCategories: selectedoccassions,
//                           ),
//                           child: NewInProductsScreen(
//                             selectedCategories: selectedoccassions,
//                             subcategory: selectedNames,
//                             initialTab: selectedoccassions.first["occassions"] ?? '',
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: selectedoccassions,
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                     );
//                     ;
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
