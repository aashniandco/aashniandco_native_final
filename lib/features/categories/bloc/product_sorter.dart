  // lib/features/category_products/bloc/product_sorter.dart

// ✅ This MUST import the Product model that your ProductRepository returns.

import '../../newin/model/new_in_model.dart';

// The single, authoritative definition for SortOption.
enum SortOption { none, latest, priceHighToLow, priceLowToHigh }

// The class that handles client-side price sorting.
class ProductSorter {
  static List<Product> sort(List<Product> products, SortOption option) {
    List<Product> productsToSort = List<Product>.from(products);
    switch (option) {
      case SortOption.priceHighToLow:
      // ✅ It now correctly uses the `price.finalPrice` from the correct model.
        productsToSort.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
        break;
      case SortOption.priceLowToHigh:
        productsToSort.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
        break;
      case SortOption.latest:
      case SortOption.none:
      default:
        break;
    }
    return productsToSort;
  }
}

// ✅ Only ONE definition of the extension.
extension SortOptionApiParams on SortOption {
  Map<String, String> get apiParams {
    switch (this) {
      case SortOption.latest:
        return {'sort': 'new', 'dir': 'desc'};
      case SortOption.priceHighToLow:
      case SortOption.priceLowToHigh:
      case SortOption.none:
      default:
        return {};
    }
  }
}