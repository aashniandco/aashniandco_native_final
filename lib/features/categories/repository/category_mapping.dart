// class CategoryMapping {
//   static const Map<String, int> categoryNameToId = {
//     "men": 1381,
//     "new in": 1372,
//     "womens-clothing": 3374,
//     "accessories": 1374,
//     "sale":1392,
//     "jewelry":6023,
//     "kids":1380,
//     "ready to ship":6018,
//     "bestsellers":5593
//
//
//     // ✅ Add other categories and their Solr IDs here
//   };
// }



// lib/config/category_mapping.dart
// Import the new model

import '../model/category_data.dart';

class CategoryMapping {

  // The key is the simple, lowercase string from your UI ("women").
  // The value is the rich data object containing everything we need.
  static final Map<String, CategoryData> data = {
    'women': const CategoryData(
      id: 3374,
      urlKey: 'womens-clothing', // <-- We correctly store "womens-clothing" here!
      name: "Women",
    ),
    'men': const CategoryData(
      id: 1381,
      urlKey: 'men',
      name: "Men",
    ),
    'new in': const CategoryData(
      id: 1371,
      urlKey: 'new-in',
      name: "New In",
    ),
    'accessories': const CategoryData(
      id: 1374,
      urlKey: 'accessories',
      name: 'Accessories',
    ),

    'sale': const CategoryData(
      id: 1392,
      urlKey: 'sale',
      name: 'Sale',
    ),

    'jewelry': const CategoryData(
      id: 6023,
      urlKey: 'jewelry',
      name: 'Jewelry',
    ),
    'kids': const CategoryData(
      id: 1380,
      urlKey: 'kids',
      name: 'Kids',
    ),


    'ready to ship': const CategoryData(
      id: 6018,
      urlKey: 'ready to ship',
      name: 'Ready to ship',
    ),

    'bestsellers': const CategoryData(
      id: 5593,
      urlKey: 'bestsellers',
      name: 'Bestsellers',
    ),



    // ... add all other top-level categories here
  };

  /// Helper function to easily get the data object by its common name.
  static CategoryData? getDataByName(String categoryName) {
    return data[categoryName.toLowerCase()];
  }
}