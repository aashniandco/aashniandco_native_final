// import '../models/api_response.dart';
//
// /// Enum to define the available sorting options.
// /// `none` represents the default, unsorted order from the API.
// enum SortOption { none, latest, priceHighToLow, priceLowToHigh }
//
// /// A utility class with a static method to handle all client-side sorting.
// class ProductSorter {
//   /// The main public method to sort a list of products based on a selected option.
//   /// It takes a list of products and a [SortOption] and returns a new sorted list.
//   static List<Product> sort(List<Product> products, SortOption option) {
//     // Create a mutable copy to avoid modifying the original list that was passed in.
//     List<Product> productsToSort = List<Product>.from(products);
//
//     switch (option) {
//       case SortOption.priceHighToLow:
//       // Sorts by the numeric finalPrice in descending order.
//         productsToSort.sort((a, b) => b.price.finalPrice.compareTo(a.price.finalPrice));
//         break;
//       case SortOption.priceLowToHigh:
//       // Sorts by the numeric finalPrice in ascending order.
//         productsToSort.sort((a, b) => a.price.finalPrice.compareTo(b.price.finalPrice));
//         break;
//       case SortOption.latest:
//       // Sorts by the complex SKU-based logic.
//         productsToSort.sort((a, b) {
//           final valA = _getSortableValue(a.sku);
//           final valB = _getSortableValue(b.sku);
//           // Compare B to A for descending order (newest first).
//           return valB.compareTo(valA);
//         });
//         break;
//       case SortOption.none:
//       default:
//       // For 'none' or any other case, do not sort. Return the original order.
//       // This is handled by simply returning the unsorted copy.
//         break;
//     }
//     return productsToSort;
//   }
//
//   /// A private helper method to parse a product SKU and return a numeric,
//   /// sortable value. It intelligently handles multiple SKU formats.
//   static int _getSortableValue(String? id) {
//     if (id == null || id.isEmpty) {
//       return 0; // Return 0 for invalid or missing SKUs.
//     }
//
//     // --- Priority 1: Modern Date-based format (e.g., AANJUL24F003) ---
//     // This is the most reliable format for determining "newness".
//     const monthMap = {
//       'JAN': 1, 'FEB': 2, 'MAR': 3, 'APR': 4, 'MAY': 5, 'JUN': 6,
//       'JUL': 7, 'AUG': 8, 'SEP': 9, 'OCT': 10, 'NOV': 11, 'DEC': 12
//     };
//
//     // Regex to find a pattern of (3 letters)(2 numbers) in the SKU.
//     final RegExp datePattern = RegExp(r'[A-Z]{3}([0-9]{2})');
//     final match = datePattern.firstMatch(id.toUpperCase());
//
//     if (match != null && monthMap.containsKey(id.substring(match.start, match.start + 3))) {
//       try {
//         String monthStr = id.substring(match.start, match.start + 3);
//         String yearStr = match.group(1)!;
//         // The rest of the string is the sequence part.
//         String sequencePart = id.substring(match.end);
//         // Extract only the digits from the sequence part.
//         String sequenceDigits = sequencePart.replaceAll(RegExp(r'[^0-9]'), '');
//
//         if (sequenceDigits.isNotEmpty) {
//           int year = int.parse(yearStr) + 2000;
//           int month = monthMap[monthStr]!;
//           int sequence = int.parse(sequenceDigits);
//           // Create a large, sortable integer (e.g., YYYYMMSSSSS) to ensure
//           // these SKUs are always considered "newer" than legacy numeric IDs.
//           return (year * 10000000) + (month * 100000) + sequence;
//         }
//       } catch (e) {
//         // If parsing fails for any reason, fall through to the legacy parsing.
//       }
//     }
//
//     // --- Priority 2: Legacy SKUs (e.g., Dhr006382 or 635065) ---
//     // If it's not a modern SKU, extract all numeric parts from the string.
//     String numericPart = id.replaceAll(RegExp(r'[^0-9]'), '');
//     if (numericPart.isNotEmpty) {
//       return int.tryParse(numericPart) ?? 0;
//     }
//
//     // If all parsing attempts fail, return 0.
//     return 0;
//   }
// }


import '../models/api_response.dart';

/// Enum to define the available sorting options.
/// `none` represents the default, unsorted order from the API.


/// A utility class with a static method to handle all client-side sorting.
// class ProductSorter {
//   /// The main public method to sort a list of products based on a selected option.
//   /// It takes a list of products and a [SortOption] and returns a new sorted list.
//   static List<Product> sort(List<Product> products, SortOption option) {
//     // Create a mutable copy to avoid modifying the original list that was passed in.
//     List<Product> productsToSort = List<Product>.from(products);
//
//     switch (option) {
//       case SortOption.priceHighToLow:
//       // Sorts by the numeric finalPrice in descending order.
//         productsToSort.sort((a, b) => b.price.finalPrice.compareTo(a.price.finalPrice));
//         break;
//
//       case SortOption.priceLowToHigh:
//       // Sorts by the numeric finalPrice in ascending order.
//         productsToSort.sort((a, b) => a.price.finalPrice.compareTo(b.price.finalPrice));
//         break;
//
//     // ✅ --- START OF THE CHANGE ---
//       case SortOption.latest:
//       // This now implements your desired logic.
//       // It sorts by the numeric `id` in descending order (newest first).
//       // Since `product.id` is already an `int`, no parsing is needed.
//         productsToSort.sort((a, b) => b.id.compareTo(a.id));
//         break;
//     // ✅ --- END OF THE CHANGE ---
//
//       case SortOption.none:
//       default:
//       // For 'none' or any other case, do not sort. Return the original order.
//         break;
//     }
//     return productsToSort;
//   }
//
// // ✅ The complex `_getSortableValue` helper method has been removed as it is no longer needed.
// }


// lib/bloc/product_sorter.dart

// Enum to define the available sorting options for the UI.
// lib/bloc/product_sorter.dart
 // Add `tuple: ^2.0.1` to your pubspec.yaml

// Or create your own simple class to avoid a dependency:
// lib/bloc/product_sorter.dart

// No need for a custom class or tuple anymore.
// We can go back to the simpler setup.

// lib/bloc/product_sorter.dart

// Make sure to import the Product model definition.
// The path might be different for your project structure.
import '../models/api_response.dart';

// =========================================================================
// HYBRID SORTING STRATEGY
// -------------------------------------------------------------------------
// This file defines the logic for a hybrid sorting approach:
//
// 1. API-Side Sorting ('latest'):
//    - The API is efficient at sorting by creation date ('new').
//    - We send parameters via `SortOptionApiParams` and let the server handle it.
//    - This is fast and supports proper pagination from the server.
//
// 2. Client-Side Sorting ('price'):
//    - The API might not support sorting by price, or it might be complex.
//    - We fetch the ENTIRE list of products without sorting parameters.
//    - The `ProductSorter` class then sorts this complete list on the client.
//    - The BLoC is responsible for paginating from this client-side list.
// =========================================================================


/// Defines the sorting options available in the UI.
/// This should be the ONLY definition of `SortOption` in the entire app.
// lib/bloc/product_sorter.dart

// Make sure to import the Product model definition.
import '../models/api_response.dart';

// Defines the sorting options available in the UI.
enum SortOption {
  none,
  latest,
  priceHighToLow,
  priceLowToHigh
}

/// A utility class to handle CLIENT-SIDE sorting of products.
// ... inside lib/bloc/product_sorter.dart

/// A utility class to handle CLIENT-SIDE sorting of products.
class ProductSorter {
  /// Sorts a list of products.
  static List<Product> sort(List<Product> products, SortOption option) {
    // Create a mutable copy to avoid modifying the original list.
    final List<Product> productsToSort = List.from(products);

    switch (option) {
      case SortOption.latest:
      // ✅✅✅ CORRECTED SORT LOGIC ✅✅✅
        productsToSort.sort((a, b) {
          // Safely parse the string IDs into integers.
          // If parsing fails (e.g., for a non-numeric ID), use 0 as a default.
          final int idA = int.tryParse(a.id) ?? 0;
          final int idB = int.tryParse(b.id) ?? 0;
          // Compare B to A for descending order (newest first).
          return idB.compareTo(idA);
        });
        break;

      case SortOption.priceHighToLow:
      // Sorts by finalPrice in descending order.
        productsToSort.sort((a, b) => b.price.finalPrice.compareTo(a.price.finalPrice));
        break;

      case SortOption.priceLowToHigh:
      // Sorts by finalPrice in ascending order.
        productsToSort.sort((a, b) => a.price.finalPrice.compareTo(b.price.finalPrice));
        break;

      case SortOption.none:
      default:
      // Do nothing for 'none'.
        break;
    }
    return productsToSort;
  }
}

// ... (the SortOptionApiParams extension remains the same)

/// Extension to get the correct API parameters for a given sort option.
extension SortOptionApiParams on SortOption {
  Map<String, String> get apiParams {
    switch (this) {
    // ✅ CHANGE: 'latest' no longer sends API parameters.
    // By returning an empty map, we ensure the BLoC fetches the full,
    // unsorted list, which we can then sort on the client.
      case SortOption.latest:
      case SortOption.priceHighToLow:
      case SortOption.priceLowToHigh:
      case SortOption.none:
      default:
        return {}; // Return an empty map for all client-side or no-op sorts.
    }
  }
}