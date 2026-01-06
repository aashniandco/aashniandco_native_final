
import 'package:flutter/material.dart';

import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import '../../../categories/view/filtered_products_screen.dart';
import 'generic_filter_screen.dart';

// lib/.../FilterBottomSheetCategories.dart

import 'package:flutter/material.dart';

// ✅ FIX: Import the centralized model
import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import 'generic_filter_screen.dart';

class FilterBottomSheetCategories extends StatefulWidget {
  final String categoryId;
  final List<Map<String, dynamic>>? initialFilters;
  final bool isDesignerScreen;
  final bool isFromFilteredScreen;

  const FilterBottomSheetCategories({
    Key? key,
    required this.categoryId,
    this.initialFilters,
    this.isDesignerScreen = false,
    this.isFromFilteredScreen = false
  }) : super(key: key);

  @override
  State<FilterBottomSheetCategories> createState() =>
      _FilterBottomSheetCategoriesState();
}

class _FilterBottomSheetCategoriesState
    extends State<FilterBottomSheetCategories> {
  late Future<List<FilterType>> _filterTypesFuture;
  final ApiService _apiService = ApiService();

  // Stores selections
  final Map<String, List<FilterItem>> _selectedFilters = {};

  @override
  void initState() {
    super.initState();
    _filterTypesFuture =
        _apiService.fetchAvailableFilterTypes(widget.categoryId);
    _restoreSelections();
  }

  void _restoreSelections() {
    if (widget.initialFilters != null) {
      for (var filter in widget.initialFilters!) {
        final String type = filter['type'];
        final String id = filter['id'].toString();
        final String name = filter['name'] ?? '';

        final item = FilterItem(
          id: id,
          name: name,
          isSelected: true,
          children: [],
        );

        if (!_selectedFilters.containsKey(type)) {
          _selectedFilters[type] = [];
        }

        bool alreadyExists = _selectedFilters[type]!.any((element) => element.id == id);

        // Prevent duplicates
        // if (!_selectedFilters[type]!.any((element) => element.id == id)) {
        //   _selectedFilters[type]!.add(item);
        // }

        if (!alreadyExists) {
          _selectedFilters[type]!.add(item);
        }

      }
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedFilters.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Paste your existing UI build code here (Header, List, Button)
    // Ensure the Button calls _applyAllFilters
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24)),
                const Text("FILTER", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                GestureDetector(onTap: () => setState(() => _selectedFilters.clear()), child: const Text("Clear All", style: TextStyle(decoration: TextDecoration.underline))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: FutureBuilder<List<FilterType>>(
              future: _filterTypesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.separated(
                  itemCount: snapshot.data!.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final filterType = snapshot.data![index];

                    // Get the list of selected items for this category (e.g., Color)
                    final selectedItems = _selectedFilters[filterType.key] ?? [];

                    // ✅ LOGIC CHANGE: Join the names together with a comma
                    // Example: "Black, Blue, Gold"
                    String subtitleText = selectedItems.map((e) => e.name).join(", ");

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: Text(
                        filterType.label.toUpperCase(),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                      ),

                      // ✅ UI CHANGE: Display the names instead of the count
                      subtitle: selectedItems.isNotEmpty
                          ? Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitleText,
                          maxLines: 1, // Keep it on one line
                          overflow: TextOverflow.ellipsis, // Add "..." if too long
                          style: const TextStyle(
                            color: Colors.black87, // Dark grey for better visibility
                            fontSize: 13,
                          ),
                        ),
                      )
                          : null,

                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GenericFilterScreen(
                              categoryId: widget.categoryId,
                              filterType: filterType.key,
                              appBarTitle: filterType.label,
                              preSelectedItems: _selectedFilters[filterType.key] ?? [],
                            ),
                          ),
                        );

                        if (result != null && result is List<FilterItem>) {
                          setState(() {
                            _selectedFilters[filterType.key] = result;
                          });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _applyAllFilters, // Calls logic above
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                child: const Text("Show Result", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  //10/12/2025
  // Widget build(BuildContext context) {
  //   // Calculate height to leave some space at top
  //   return Container(
  //     height: MediaQuery.of(context).size.height * 0.9,
  //     decoration: const BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  //     ),
  //     child: Column(
  //       children: [
  //         // --- HEADER: Close | Title | Clear All ---
  //         Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               GestureDetector(
  //                 onTap: () => Navigator.pop(context),
  //                 child: const Icon(Icons.close, size: 24),
  //               ),
  //               const Text(
  //                 "FILTER",
  //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0),
  //               ),
  //               GestureDetector(
  //                 onTap: _clearAllFilters,
  //                 child: const Text(
  //                   "Clear All",
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                     fontSize: 14,
  //                     decoration: TextDecoration.underline,
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         const Divider(height: 1),
  //
  //         // --- BODY: Filter Types List ---
  //         Expanded(
  //           child: FutureBuilder<List<FilterType>>(
  //             future: _filterTypesFuture,
  //             builder: (context, snapshot) {
  //               if (snapshot.connectionState == ConnectionState.waiting) {
  //                 return const Center(child: CircularProgressIndicator());
  //               }
  //               if (snapshot.hasError) {
  //                 return Center(child: Text('Error: ${snapshot.error}'));
  //               }
  //               if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //                 return const Center(child: Text('No filter options available.'));
  //               }
  //
  //               final filterTypes = snapshot.data!;
  //
  //               return ListView.separated(
  //                 itemCount: filterTypes.length,
  //                 separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
  //                 itemBuilder: (context, index) {
  //                   final filterType = filterTypes[index];
  //                   final selectedItems = _selectedFilters[filterType.key] ?? [];
  //
  //                   // Subtitle logic
  //                   String subtitleText = selectedItems.map((e) => e.name).join(", ");
  //
  //                   return ListTile(
  //                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //                     title: Text(
  //                       filterType.label.toUpperCase(), // Uppercase like screenshot
  //                       style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
  //                     ),
  //                     subtitle: selectedItems.isNotEmpty
  //                         ? Padding(
  //                       padding: const EdgeInsets.only(top: 4.0),
  //                       child: Text(
  //                         subtitleText,
  //                         maxLines: 1,
  //                         overflow: TextOverflow.ellipsis,
  //                         style: const TextStyle(color: Colors.black87, fontSize: 13),
  //                       ),
  //                     )
  //                         : null,
  //                     trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
  //                     onTap: () async {
  //                       // Open Drill-down screen
  //                       final result = await Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (_) => GenericFilterScreen(
  //                             categoryId: widget.categoryId,
  //                             filterType: filterType.key,
  //                             appBarTitle: filterType.label,
  //                             preSelectedItems: _selectedFilters[filterType.key] ?? [],
  //                           ),
  //                         ),
  //                       );
  //
  //                       if (result != null && result is List<FilterItem>) {
  //                         setState(() {
  //                           _selectedFilters[filterType.key] = result;
  //                         });
  //                       }
  //                     },
  //                   );
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //
  //         // --- FOOTER: Apply Button ---
  //         Padding(
  //           padding: const EdgeInsets.all(16.0),
  //           child: SizedBox(
  //             width: double.infinity,
  //             height: 50,
  //             child: ElevatedButton(
  //               onPressed: _applyAllFilters,
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: Colors.black,
  //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
  //               ),
  //               child: Text(
  //                 "Show Result",
  //                 // "APPLY ${_countTotalFilters() > 0 ? '(${_countTotalFilters()})' : ''}",
  //                 style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  int _countTotalFilters() {
    int count = 0;
    _selectedFilters.forEach((key, value) => count += value.length);
    return count;
  }

  // Inside FilterBottomSheetCategories class

  //17/12/2025
  void _applyAllFilters() {
    List<Map<String, dynamic>> finalFilterList = [];
    String displayCategoryName = "Filtered Results";
    String navigationCategoryId = widget.categoryId;

    // Collect selected filters
    _selectedFilters.forEach((type, items) {
      for (var item in items) {
        finalFilterList.add({
          "id": item.id,
          "name": item.name,
          "type": type,
        });

        // If specific category is selected, update the ID/Name
        if (type == 'categories' ) {
          displayCategoryName = item.name;
          print("display>>$displayCategoryName");
          navigationCategoryId = item.id;
        }


      }
    });

    if (finalFilterList.isEmpty) {
      Navigator.pop(context, null);
      return;
    }

    // Format for API/Screen
    final List<Map<String, String>> typedFilters = finalFilterList.map((item) {
      return {
        'type': item['type'].toString(),
        'id': item['id'].toString(),
        'name': item['name'].toString(),
      };
    }).toList();

    // ✅ THE HYBRID LOGIC:

    if (widget.isFromFilteredScreen) {
      // SCENARIO A: Already on Filtered Screen.
      // Just close the sheet and return the data.
      Navigator.pop(context, {
        'filters': typedFilters,
        'categoryId': navigationCategoryId,
        'categoryName': displayCategoryName,
      });
    } else {
      // SCENARIO B: First time opening filter.
      // Close sheet (optional, depending on UX) or PUSH the new screen.
      // Usually, we push the screen directly.

      // Note: If you want the bottom sheet to close AND push, use Navigator.pushReplacement or pop then push.
      // Here we push on top:
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => FilteredProductsScreen(
            categoryId: navigationCategoryId,
            categoryName: displayCategoryName,
            selectedFilters: typedFilters,
          ),
        ),
      );
    }
  }

  //10/12/2025
  // void _applyAllFilters() {
  //   List<Map<String, dynamic>> finalFilterList = [];
  //   String displayCategoryName = "Filtered Results";
  //   String navigationCategoryId = widget.categoryId;
  //
  //   _selectedFilters.forEach((type, items) {
  //     for (var item in items) {
  //       finalFilterList.add({
  //         "id": item.id,
  //         "name": item.name,
  //         "type": type,
  //       });
  //
  //       if (type == 'categories') {
  //         displayCategoryName = item.name;
  //         navigationCategoryId = item.id;
  //       }
  //     }
  //   });
  //
  //   if (finalFilterList.isEmpty) {
  //     Navigator.pop(context);
  //     return;
  //   }
  //
  //   // ✅ NEW LOGIC: If this is the Designer Screen, return the data!
  //   if (widget.isDesignerScreen) {
  //     Navigator.pop(context, finalFilterList); // Return the list to _buildFilterButton
  //     return; // Stop execution here
  //   }
  //
  //   // --- Existing Logic for Standard Categories below ---
  //
  //   final List<Map<String, String>> typedFilters = finalFilterList.map((item) {
  //     return {
  //       'type': item['type'].toString(),
  //       'id': item['id'].toString(),
  //       'name': item['name'].toString(),
  //     };
  //   }).toList();
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => FilteredProductsScreen(
  //         categoryId: navigationCategoryId,
  //         categoryName: displayCategoryName,
  //         selectedFilters: typedFilters,
  //       ),
  //     ),
  //   );
  // }
  // void _applyAllFilters() {
  //   List<Map<String, dynamic>> finalFilterList = [];
  //   String displayCategoryName = "Filtered Results";
  //   String navigationCategoryId = widget.categoryId;
  //
  //   _selectedFilters.forEach((type, items) {
  //     for (var item in items) {
  //       finalFilterList.add({
  //         "id": item.id,
  //         "name": item.name,
  //         "type": type,
  //       });
  //
  //       if (type == 'categories') {
  //         displayCategoryName = item.name;
  //         navigationCategoryId = item.id;
  //       }
  //     }
  //   });
  //
  //   if (finalFilterList.isEmpty) {
  //     Navigator.pop(context);
  //     return;
  //   }
  //
  //   final List<Map<String, String>> typedFilters = finalFilterList.map((item) {
  //     return {
  //       'type': item['type'].toString(),
  //       'id': item['id'].toString(),
  //       'name': item['name'].toString(),
  //     };
  //   }).toList();
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (_) => FilteredProductsScreen(
  //         categoryId: navigationCategoryId,
  //         categoryName: displayCategoryName,
  //         selectedFilters: typedFilters,
  //       ),
  //     ),
  //   );
  // }
}

// 5/12/2025
// class FilterBottomSheetCategories extends StatefulWidget {
//   final String categoryId;
//
//   final List<Map<String, dynamic>>? initialFilters;
//   const FilterBottomSheetCategories({Key? key, required this.categoryId  , this.initialFilters,}) : super(key: key);
//
//   @override
//   State<FilterBottomSheetCategories> createState() => _FilterBottomSheetCategoriesState();
// }
//
// class _FilterBottomSheetCategoriesState extends State<FilterBottomSheetCategories> {
//   late Future<List<FilterType>> _filterTypesFuture;
//   final ApiService _apiService = ApiService();
//
//   // Stores selections: Key = filterType (e.g. 'categories'), Value = List of selected items
//   final Map<String, List<FilterItem>> _selectedFilters = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _filterTypesFuture = _apiService.fetchAvailableFilterTypes(widget.categoryId);
//
//     // ✅ ADDED: Restore previous selections if they exist
//     if (widget.initialFilters != null) {
//       for (var filter in widget.initialFilters!) {
//         final String type = filter['type'];
//         final String id = filter['id'].toString();
//         final String name = filter['name'] ?? '';
//
//         // We reconstruct a basic FilterItem so the logic works.
//         // The GenericFilterScreen will use the ID to match against the API list.
//         final item = FilterItem(
//           id: id,
//           name: name,
//           isSelected: true,
//           children: [], // Empty children since we only need ID/Name here
//           // slug: '', // Optional depending on your model
//         );
//
//         if (!_selectedFilters.containsKey(type)) {
//           _selectedFilters[type] = [];
//         }
//
//         // Prevent duplicates
//         if (!_selectedFilters[type]!.any((element) => element.id == id)) {
//           _selectedFilters[type]!.add(item);
//         }
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 680,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Expanded(
//                 child: Text(
//                   "Apply Filters>>",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close, size: 26, color: Colors.grey),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: FutureBuilder<List<FilterType>>(
//               future: _filterTypesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No filter options available.'));
//                 }
//
//                 final filterTypes = snapshot.data!;
//
//                 return ListView.builder(
//                   itemCount: filterTypes.length,
//                   itemBuilder: (context, index) {
//                     final filterType = filterTypes[index];
//                     final selectedItems = _selectedFilters[filterType.key] ?? [];
//
//                     // Create a string to show selected items (e.g., "Dresses, Tops")
//                     String subtitleText = selectedItems.isEmpty
//                         ? "Select options"
//                         : selectedItems.map((e) => e.name).join(", ");
//
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFD3D4D3),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                         title: Text(
//                           filterType.label,
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         // ✅ Show selected items here
//                         subtitle: Text(
//                           subtitleText,
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             color: selectedItems.isNotEmpty ? Colors.black87 : Colors.grey[600],
//                             fontSize: 13,
//                           ),
//                         ),
//                         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () async {
//                           // ✅ Open Generic Screen and Wait for Result
//                           final result = await Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => GenericFilterScreen(
//                                 categoryId: widget.categoryId,
//                                 filterType: filterType.key,
//                                 appBarTitle: "Select>> ${filterType.label}",
//                                 // Pass currently selected items so they remain checked
//                                 preSelectedItems: _selectedFilters[filterType.key] ?? [],
//                               ),
//                             ),
//                           );
//
//                           // ✅ Update state if result returned
//                           if (result != null && result is List<FilterItem>) {
//                             setState(() {
//                               _selectedFilters[filterType.key] = result;
//                             });
//                           }
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () {
//                 // ✅ FINAL APPLY LOGIC
//                 _applyAllFilters();
//               },
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: Colors.black,
//               ),
//               child: const Text("Apply", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _applyAllFilters() {
//     List<Map<String, dynamic>> finalFilterList = [];
//     String displayCategoryName = "Filtered Results";
//     String navigationCategoryId = widget.categoryId;
//
//     // Flatten the map into the list format expected by FilteredProductsScreen
//     _selectedFilters.forEach((type, items) {
//       for (var item in items) {
//         finalFilterList.add({
//           "id": item.id,
//           "name": item.name,
//           "type": type,
//         });
//
//         // Logic to determine main category name/ID for header/API
//         if (type == 'categories') {
//           displayCategoryName = item.name;
//           navigationCategoryId = item.id;
//         }
//       }
//     });
//
//     if (finalFilterList.isEmpty) {
//       // No filters selected, maybe show a toast or apply default
//       Navigator.pop(context); // Or navigate to original category
//       return;
//     }
//
//     // Helper to cast types for the screen
//     final List<Map<String, String>> typedFilters = finalFilterList.map((item) {
//       return {
//         'type': item['type'].toString(),
//         'id': item['id'].toString(),
//         'name': item['name'].toString(),
//       };
//     }).toList();
//
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FilteredProductsScreen(
//           categoryId: navigationCategoryId,
//           categoryName: displayCategoryName,
//           selectedFilters: typedFilters,
//         ),
//       ),
//     );
//   }
// }
// class FilterBottomSheetCategories extends StatefulWidget {
//   final String categoryId;
//   const FilterBottomSheetCategories({Key? key, required this.categoryId}) : super(key: key);
//
//   @override
//   State<FilterBottomSheetCategories> createState() => _FilterBottomSheetCategoriesState();
// }
//
// class _FilterBottomSheetCategoriesState extends State<FilterBottomSheetCategories> {
//   // ✅ FIX: The future now correctly holds a list of FilterType objects.
//   late Future<List<FilterType>> _filterTypesFuture;
//   final ApiService _apiService = ApiService();
//
//   @override
//   void initState() {
//     super.initState();
//     // This assignment is now valid as the variable and return types match.
//     _filterTypesFuture = _apiService.fetchAvailableFilterTypes(widget.categoryId);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print('Fetching filters for Category ID >> ${widget.categoryId}');
//
//     return Container(
//       height: 680,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Expanded(
//                 child: Text(
//                   "Apply Filters>>",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close, size: 26, color: Colors.grey),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             // ✅ FIX: Use the correct model type for the FutureBuilder.
//             child: FutureBuilder<List<FilterType>>(
//               future: _filterTypesFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//                 if (snapshot.hasError) {
//                   return Center(
//                     child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
//                   );
//                 }
//                 if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No filter options available.'));
//                 }
//
//                 final filterTypes = snapshot.data!;
//
//                 return ListView.builder(
//                   itemCount: filterTypes.length,
//                   itemBuilder: (context, index) {
//                     final filterType = filterTypes[index];
//                     return Container(
//                       margin: const EdgeInsets.only(bottom: 10),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFFD3D4D3),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: ListTile(
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         title: Text(
//                           filterType.label, // This now correctly reads 'label'
//                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                         ),
//                         trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//                         onTap: () {
//                           final selectedKey = filterType.key; // This now correctly reads 'key'
//
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => GenericFilterScreen(
//                                 // All arguments are correctly passed.
//                                 categoryId: widget.categoryId,
//
//                                 filterType: selectedKey,
//                                 appBarTitle: "Select ${filterType.label}",
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: Colors.black,
//               ),
//               child: const Text("Apply", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }