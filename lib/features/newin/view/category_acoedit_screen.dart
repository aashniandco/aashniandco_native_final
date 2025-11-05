import 'package:aashniandco/features/newin/view/category_result_tes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



class CategoryAcoeditScreen extends StatefulWidget {
  const CategoryAcoeditScreen({super.key});

  @override
  State<CategoryAcoeditScreen> createState() => _CategoryAcoeditScreenState();
}

class _CategoryAcoeditScreenState extends State<CategoryAcoeditScreen> {
  // Data structure for A+CO Edit selection
  final List<Map<String, dynamic>> acoedit = [
    {"name": "Belted Sarees", "isSelected": false, "children": []},
    {"name": "Cotton Kurtas", "isSelected": false, "children": []},
    {"name": "Cult Finds", "isSelected": false, "children": []},
    {"name": "Embellished Tops", "isSelected": false, "children": []},
    {"name": "Exclusive", "isSelected": false, "children": []},
    {"name": "Festive Kurtas", "isSelected": false, "children": []},
    {"name": "Festive Potlis", "isSelected": false, "children": []},
    // Fixed a typo in the original data here ("isExpanded" was broken)
    {"name": "Floral Sarees", "isSelected": false, "children": []},
    {"name": "Heritage Weaves", "isSelected": false, "children": []},
    {"name": "Kurtas Under \$500", "isSelected": false, "children": []},
    {"name": "Lehengas Under \$2000", "isSelected": false, "children": []},
    {"name": "Off The Runway", "isSelected": false, "children": []},
    {"name": "Sustainable Edit", "isSelected": false, "children": []},
    {"name": "The Summer Edit", "isSelected": false, "children": []},
  ];

  // Handler for A+CO Edit selection
  void _onAcoeditSelected(bool? value, int index) {
    setState(() {
      acoedit[index]["isSelected"] = value ?? false;
    });
  }

  // Handler for the "CLEAR ALL" button
  void _clearAllFilters() {
    setState(() {
      for (var item in acoedit) {
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
          "Select A+CO Edit", // Updated title
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
              itemCount: acoedit.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = acoedit[index];
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey(category["name"]),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (value) => _onAcoeditSelected(value, index),
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
              List<Map<String, dynamic>> selectedAcoedit = [];

              for (var cat in acoedit) {
                if (cat["isSelected"] == true) {
                  selectedAcoedit.add({
                    "theme": cat["name"],
                    "acoedit": cat["name"],
                    "id": null,
                  });
                }
              }

              if (selectedAcoedit.isNotEmpty) {
                final selectedNames = selectedAcoedit
                    .map((item) => item["acoedit"] ?? item["subCategory"])
                    .join(", ");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NewInProductsBloc(
                        productRepository: ProductRepository(),
                        subcategory: selectedNames,
                        selectedCategories: selectedAcoedit,
                      ),
                      child: NewInProductsScreen(
                        selectedCategories: selectedAcoedit,
                        subcategory: selectedNames,
                        initialTab: selectedAcoedit.first["acoedit"] ?? '',
                        productListBuilder: (category, sort) {
                          return CategoryResultScreen(
                            selectedCategories: selectedAcoedit,
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please make a selection.")),
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

// 18/7/2025
// class CategoryAcoeditScreen extends StatefulWidget {
//   const CategoryAcoeditScreen ({super.key});
//
//   @override
//   State<CategoryAcoeditScreen> createState() => _CategoryAcoeditScreenState();
// }
//
// class _CategoryAcoeditScreenState extends State<CategoryAcoeditScreen> {
//   final List<Map<String, dynamic>> acoedit = [
//     {"name": "Belted Sarees", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Cotton Kurtas", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Cult Finds", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Embellished Tops", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Exclusive", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Festive Kurtas", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Festive Potlis", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Floral Sarees", "isEx"
//         "panded": false, "isSelected": false, "children": []},
//     {"name": "Heritage Weaves", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Kurtas Under \$500", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Lehengas Under \$2000", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Off The Runway", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "Sustainable Edit", "isExpanded": false, "isSelected": false, "children": []},
//     {"name": "The Summer Edit", "isExpanded": false, "isSelected": false, "children": []},
//
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select A+CO Edit"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: acoedit.length,
//               itemBuilder: (context, index) {
//                 final category = acoedit[index];
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
//                                 acoedit[index]["isSelected"] = value!;
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
//                           acoedit[index]["isExpanded"] = expanded;
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
//                   List<Map<String, dynamic>> selectedacoedit = [];
//
//                   for (var cat in acoedit) {
//                     if (cat["isSelected"] == true) {
//                       selectedacoedit.add({
//                         "theme": cat["name"],
//                         "acoedit": cat["name"],
//                         "id": null,
//                       });
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selectedacoedit.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   if (selectedacoedit.isNotEmpty) {
//                     final selectedNames = selectedacoedit
//                         .map((item) => item["acoedit"] ?? item["subCategory"])
//                         .join(", ");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BlocProvider(
//                           create: (_) => NewInProductsBloc(
//                             productRepository: ProductRepository(),
//                             subcategory: selectedNames,
//                             selectedCategories: selectedacoedit,
//                           ),
//                           child: NewInProductsScreen(
//                             selectedCategories: selectedacoedit,
//                             subcategory: selectedNames,
//                             initialTab: selectedacoedit.first["acoedit"] ?? '',
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: selectedacoedit,
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



