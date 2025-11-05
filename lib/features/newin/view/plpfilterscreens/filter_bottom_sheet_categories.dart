
import 'package:flutter/material.dart';

import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import 'generic_filter_screen.dart';

// lib/.../FilterBottomSheetCategories.dart

import 'package:flutter/material.dart';

// ✅ FIX: Import the centralized model
import '../../../categories/model/filter_model.dart';
import '../../../categories/repository/api_service.dart';
import 'generic_filter_screen.dart';

class FilterBottomSheetCategories extends StatefulWidget {
  final String categoryId;
  const FilterBottomSheetCategories({Key? key, required this.categoryId}) : super(key: key);

  @override
  State<FilterBottomSheetCategories> createState() => _FilterBottomSheetCategoriesState();
}

class _FilterBottomSheetCategoriesState extends State<FilterBottomSheetCategories> {
  // ✅ FIX: The future now correctly holds a list of FilterType objects.
  late Future<List<FilterType>> _filterTypesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    // This assignment is now valid as the variable and return types match.
    _filterTypesFuture = _apiService.fetchAvailableFilterTypes(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    print('Fetching filters for Category ID >> ${widget.categoryId}');

    return Container(
      height: 680,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Apply Filters",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, size: 26, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            // ✅ FIX: Use the correct model type for the FutureBuilder.
            child: FutureBuilder<List<FilterType>>(
              future: _filterTypesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No filter options available.'));
                }

                final filterTypes = snapshot.data!;

                return ListView.builder(
                  itemCount: filterTypes.length,
                  itemBuilder: (context, index) {
                    final filterType = filterTypes[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD3D4D3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          filterType.label, // This now correctly reads 'label'
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          final selectedKey = filterType.key; // This now correctly reads 'key'

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GenericFilterScreen(
                                // All arguments are correctly passed.
                                categoryId: widget.categoryId,
                                filterType: selectedKey,
                                appBarTitle: "Select ${filterType.label}",
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.black,
              ),
              child: const Text("Apply", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}