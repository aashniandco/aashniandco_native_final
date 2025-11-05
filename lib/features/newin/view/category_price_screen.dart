import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/newin_products_bloc.dart';
import '../bloc/product_repository.dart';
import 'category_result_screen.dart';
import 'new_in_products_screen.dart';
import 'package:http/http.dart'as http;
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';



class CategoryPriceScreen extends StatefulWidget {
  const CategoryPriceScreen({super.key});

  @override
  State<CategoryPriceScreen> createState() => _CategoryPriceScreenState();
}

class _CategoryPriceScreenState extends State<CategoryPriceScreen> {
  // Data structure for price range selection
  final List<Map<String, dynamic>> price = [
    {"name": "Rs.11 - 50000", "isSelected": false, "children": []},
    {"name": "Rs.50000 - 100000", "isSelected": false, "children": []},
    {"name": "Rs.100000 - 150000", "isSelected": false, "children": []},
    {"name": "Rs.150000 - 200000", "isSelected": false, "children": []},
    {"name": "Rs.200000 - 250000", "isSelected": false, "children": []},
    {"name": "Rs.250000 - 300000", "isSelected": false, "children": []},
    {"name": "Rs.300000 - 350000", "isSelected": false, "children": []},
    {"name": "Rs.350000 - 400000", "isSelected": false, "children": []},
    {"name": "Rs.400000 - 450000", "isSelected": false, "children": []},
    {"name": "Rs.450000 - 500000", "isSelected": false, "children": []},
    {"name": "Rs.50000 - 1500000", "isSelected": false, "children": []}
  ];

  // Handler for price selection
  void _onPriceSelected(bool? value, int index) {
    setState(() {
      price[index]["isSelected"] = value ?? false;
    });
  }

  // Handler for the "CLEAR ALL" button
  void _clearAllFilters() {
    setState(() {
      for (var item in price) {
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
          "Select Price", // Updated title
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
              itemCount: price.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final category = price[index];
                return Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    key: PageStorageKey(category["name"]),
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
                    title: Row(
                      children: [
                        Checkbox(
                          value: category["isSelected"],
                          onChanged: (value) => _onPriceSelected(value, index),
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
              List<Map<String, dynamic>> selectedPrice = [];

              for (var cat in price) {
                if (cat["isSelected"] == true) {
                  selectedPrice.add({
                    "theme": cat["name"],
                    "price": cat["name"],
                    "id": null,
                  });
                }
              }

              if (selectedPrice.isNotEmpty) {
                final selectedNames = selectedPrice
                    .map((item) => item["price"] ?? item["subCategory"])
                    .join(", ");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => NewInProductsBloc(
                        productRepository: ProductRepository(),
                        subcategory: selectedNames,
                        selectedCategories: selectedPrice,
                      ),
                      child: NewInProductsScreen(
                        selectedCategories: selectedPrice,
                        subcategory: selectedNames,
                        initialTab: selectedPrice.first["price"] ?? '',
                        productListBuilder: (category, sort) {
                          return CategoryResultScreen(
                            selectedCategories: selectedPrice,
                          );
                        },
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select a price range.")),
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

//18/7/2025

// class CategoryPriceScreen extends StatefulWidget {
//   const CategoryPriceScreen({super.key});
//
//   @override
//   State<CategoryPriceScreen> createState() => _CategoryPriceScreenState();
// }
//
// class _CategoryPriceScreenState extends State<CategoryPriceScreen> {
//   final List<Map<String, dynamic>> price = [
//     {
//       "name": "Rs.11 - 50000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.50000 - 100000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.100000 - 150000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.150000 - 200000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Rs.200000 - 250000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.250000 - 300000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.300000 - 350000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Rs.350000 - 400000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Rs.400000 - 450000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//     {
//       "name": "Rs.450000 - 500000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     },
//
//     {
//       "name": "Rs.50000 - 1500000",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     }
//
//
//   ];
//
//   // List<Map<String, dynamic>> fetchedProducts = [];
//   //
//   // Future<List<dynamic>> fetchProductsByGender(String genderName) async {
//   //   const String url = "https://stage.aashniandco.com/rest/V1/solr/search";
//   //
//   //   try {
//   //     HttpClient httpClient = HttpClient();
//   //     httpClient.badCertificateCallback = (cert, host, port) => true;
//   //
//   //     IOClient ioClient = IOClient(httpClient);
//   //
//   //     final Map<String, dynamic> body = {
//   //       "queryParams": {
//   //         "query": 'gender_name:("$genderName")',
//   //         "params": {
//   //           "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,color_name",
//   //           "rows": "100"
//   //         }
//   //       }
//   //     };
//   //
//   //     final response = await ioClient.post(
//   //       Uri.parse(url),
//   //       headers: {
//   //         "Content-Type": "application/json",
//   //       },
//   //       body: jsonEncode(body),
//   //     );
//   //
//   //     print("📡 Status Code: ${response.statusCode}");
//   //     print("📨 Raw Body: ${response.body}");
//   //
//   //     if (response.statusCode == 200) {
//   //       final decoded = jsonDecode(response.body);
//   //
//   //       if (decoded is List) {
//   //         final Map<String, dynamic>? docsWrapper = decoded.firstWhere(
//   //               (e) => e is Map<String, dynamic> && e.containsKey('docs'),
//   //           orElse: () => {},
//   //         );
//   //         return docsWrapper?['docs'] ?? [];
//   //       } else {
//   //         throw Exception("Unexpected response format");
//   //       }
//   //     } else {
//   //       throw Exception("Failed to fetch products: ${response.statusCode}");
//   //     }
//   //   } catch (e) {
//   //     print("❌ Error fetching data: $e");
//   //     return [];
//   //   }
//   // }
//   //
//
//   @override
//   @override
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Select Price"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: price.length,
//               itemBuilder: (context, index) {
//                 final category = price[index];
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
//                                 price[index]["isSelected"] = value!;
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
//                           price[index]["isExpanded"] = expanded;
//                         });
//                       },
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
//                   List<Map<String, dynamic>> selectedPrice = [];
//
//                   for (var cat in price) {
//                     if (cat["isSelected"] == true) {
//                       // selected.add({"theme": cat["name"], "id": null});
//                       selectedPrice.add({
//                         "theme": cat["name"],
//                         "price": cat["name"], // 👈 Add this line
//                         "id": null,
//                       });
//                     }
//                     for (var child in cat["children"]) {
//                       if (child["isSelected"] == true) {
//                         selectedPrice.add({
//                           "theme": cat["name"],
//                           "subCategory": child["name"],
//                           "id": child["id"]
//                         });
//                       }
//                     }
//                   }
//
//                   if (selectedPrice.isNotEmpty) {
//                     final selectedNames = selectedPrice
//                         .map((item) => item["price"] ?? item["subCategory"])
//                         .join(", ");
//
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => BlocProvider(
//                           create: (_) => NewInProductsBloc(
//                             productRepository: ProductRepository(),
//                             subcategory: selectedNames,
//                             selectedCategories: selectedPrice,
//                           ),
//                           child: NewInProductsScreen(
//                             selectedCategories: selectedPrice,
//                             subcategory: selectedNames,
//                             initialTab: selectedPrice.first["price"] ?? '',
//                             productListBuilder: (category, sort) {
//                               return CategoryResultScreen(
//                                 selectedCategories: selectedPrice,
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
// class CategoryGenderScreen extends StatefulWidget {
//   const CategoryGenderScreen({super.key});
//
//   @override
//   State<CategoryGenderScreen> createState() => _CategoryGenderScreenState();
// }
//
// class _CategoryGenderScreenState extends State<CategoryGenderScreen> {
//
//   final List <Map<String,dynamic>>gender= [
//
//     {
//
//       "name": "Men",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//
//     },
//
//     {
//       "name": "Women",
//       "isExpanded": false,
//       "isSelected": false,
//       "children": [],
//     }
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       appBar:AppBar(
//         title: Text("Select Gender"),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               itemCount: gender.length,
//               itemBuilder: (context, index) {
//                 final category = gender[index];
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
//                                 gender[index]["isSelected"] = value!;
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
//                           gender[index]["isExpanded"] = expanded;
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
//                   for (var cat in gender) {
//                     if (cat["isSelected"] == true) {
//                       selected.add({"theme": cat["name"], "id": null});
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
//                   // // Build selected subcategories
//                   // final List<Map<String, dynamic>> selectedSubcategories = [];
//                   // for (final mainCategory in gender) {
//                   //   for (final sub in mainCategory['children']) {
//                   //     if (sub['isSelected'] == true) {
//                   //       selectedSubcategories.add({
//                   //         "subCategory": sub['name'],
//                   //         "id": sub['id'],
//                   //         "isSelected": true,
//                   //       });
//                   //     }
//                   //   }
//                   // }
//                   //
//                   // if (selected.any((item) => item["subCategory"] != null)) {
//                   //   // ✅ Navigate if any subcategory is selected
//                   //   final selectedSubcategoryNames = selected
//                   //       .where((item) => item["subCategory"] != null)
//                   //       .map((e) => e["subCategory"] as String)
//                   //       .toList();
//                   //
//                   //   Navigator.push(
//                   //     context,
//
//                   final selectedThemes = selected
//                       .where((item) => item["id"] == null && item["theme"] != null)
//                       .map((e) => e["theme"] as String)
//                       .toList();
//
//
//                   final selectedSubcategories = selected
//                       .where((item) => item["subCategory"] != null)
//                       .map((item) => {
//                     "subCategory": item["subCategory"],
//                     "id": item["id"],
//                     "isSelected": true,
//                   })
//                       .toList();
//
//
//                   final subcategoryText = selectedSubcategories.map((e) => e["subCategory"]).join(", ");
//                   final themeText = selectedThemes.join(", ");
//
//
//                   // Combine both if needed
//                   final combinedText = [
//                     if (themeText.isNotEmpty) themeText,
//                     if (subcategoryText.isNotEmpty) subcategoryText
//                   ].join(" • ");
//
//
//                   if (selected.isNotEmpty) {
//                     Navigator.push(
//                       context,
//
//                       MaterialPageRoute(
//                         builder: (_) => NewInProductsScreen(
//                           selectedCategories: selected,
//                           subcategory: combinedText,
//                           initialTab: selectedThemes.isNotEmpty
//                               ? selectedThemes.first
//                               : (selectedSubcategories.isNotEmpty
//                               ? selectedSubcategories.first["subCategory"]
//                               : ''),
//                           productListBuilder: (category, sort) {
//                             return CategoryResultScreen(
//                               selectedCategories: selectedSubcategories,
//                             );
//                           },
//                         ),
//                       ),
//                     );
//                   }
//                 }
//
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
