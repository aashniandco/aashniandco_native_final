// import 'package:equatable/equatable.dart';
//
// class Product extends Equatable {
//   final String id;
//   final String sku;
//   final String designerName;
//   final String productName;
//   final String imageUrl;
//   final double price;
//   final String categoryPath;
//
//   const Product({
//     required this.id,
//     required this.sku,
//     required this.designerName,
//     required this.productName,
//     required this.imageUrl,
//     required this.price,
//     required this.categoryPath,
//   });
//
//   // Factory constructor to create a Product from JSON
//   factory Product.fromJson(Map<String, dynamic> json) {
//     String getFirst(dynamic list, [String defaultValue = '']) {
//       if (list is List && list.isNotEmpty) {
//         return list.first.toString();
//       }
//       return defaultValue;
//     }
//
//     // --- SAFER PRICE PARSING ---
//     double parsePrice(dynamic priceValue) {
//       if (priceValue is num) {
//         return priceValue.toDouble();
//       }
//       if (priceValue is String) {
//         return double.tryParse(priceValue) ?? 0.0;
//       }
//       return 0.0;
//     }
//
//     return Product(
//       id: json['prod_en_id']?.toString() ?? '0',
//       sku: json['prod_sku'] ?? 'N/A',
//       designerName: getFirst(json['prod_name'], 'Unknown Designer'),
//       productName: json['short_desc'] ?? 'No name',
//       imageUrl: json['prod_small_img'] ?? '',
//       price: parsePrice(json['actual_price']),
//       categoryPath: json['categoryPath'] ?? '',// Use the safer parsing function
//     );
//   }
//
//   @override
//   List<Object?> get props => [id, sku, designerName, productName, imageUrl, price];
// }



// In your models file (e.g.,product_model.dart)

import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as p;

class SearchResults {
  final List<Product1> products;
  final List<SearchCategory> categories;

  SearchResults({required this.products, required this.categories});
}

// class Product {
//   final String designerName;
//   final String productName;
//   final String sku;// 'name' in the JSON
//   final String url;
//   final String description;
//   final String imageUrl;
//   final String price; // We'll extract the clean price from HTML
//
//   Product({
//     required this.designerName,
//     required this.productName,
//     required this.url,
//     required this.sku,
//     required this.description,
//     required this.imageUrl,
//     required this.price,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     // Helper function to parse the price from the HTML string
//     String _parsePrice(String priceHtml) {
//       try {
//         var document = parse(priceHtml);
//         // Find the innermost <span> with the class 'price'
//         var priceElement = document.querySelector('span.price');
//         return priceElement?.text ?? 'N/A';
//       } catch (e) {
//         return 'N/A';
//       }
//     }
//
//     return Product(
//       designerName: json['name'] ?? 'Unknown Designer',
//        // ✅ FIX: Map 'description' to 'productName'
//       productName: json['description'] ?? 'No name',
//       sku: json['sku'] ?? '', // ✅ FIX: Add 'sku'
//       url: json['url'] ?? '',
//       description: json['description'] ?? 'No description',
//       imageUrl: json['image'] ?? '',
//       price: _parsePrice(json['price'] ?? ''), // Use the helper to clean the price
//     );
//   }
//
//   // ✅ ADD THIS NEW FACTORY for the Product Listing Screen
//   factory Product.fromSolr(Map<String, dynamic> doc) {
//     // Helper to safely get a value that might be in an array
//     String _getFirst(dynamic value) {
//       if (value is List && value.isNotEmpty) {
//         return value.first.toString();
//       }
//       return value?.toString() ?? '';
//     }
//
//     return Product(
//       designerName: _getFirst(doc['designer_name']),
//       productName: _getFirst(doc['prod_name']),
//       sku: _getFirst(doc['prod_sku']),
//       imageUrl: _getFirst(doc['prod_small_img']),
//       // You can format the price here if it comes as a number
//       price: '₹${doc['actual_price_1']?.toStringAsFixed(0) ?? 'N/A'}',
//       description: json['description'] ?? 'No description',
//       // The full URL is not in the Solr response, so we pass an empty string.
//       // You would typically construct this URL in the app based on a 'url_key' field.
//       url: '',
//     );
//   }
//
// }


class Product1 {
  final String designerName;
  final String productName;
  final String sku;
  final String url;
  final String description; // The SINGLE source of truth for the description.
  final String imageUrl;
  final String price;
  final List<String> sizeList;
  final List<String> deliveryTime;

  Product1({
    required this.designerName,
    required this.productName,
    required this.url,
    required this.sku,
    required this.description, // Unified description property.
    required this.imageUrl,
    required this.price,
    required this.sizeList,
    required this.deliveryTime,
  });

  /// Factory for parsing the **autosuggest** API response.
  /// This response seems to contain HTML for the price.
  factory Product1.fromJson(Map<String, dynamic> json) {
    // Helper to parse price from an HTML snippet.
    String _parsePrice(String? priceHtml) {
      if (priceHtml == null || priceHtml.isEmpty) return 'N/A';
      try {
        var document = parse(priceHtml);
        // Safely access the text to avoid crashes if the element is not found.
        return document.querySelector('span.price')?.text.trim() ?? 'N/A';
      } catch (e) {
        return 'N/A'; // Return a default value if parsing fails.
      }
    }

    String extractedSku = json['sku'] ?? '';

    // Step 1: Check if the 'sku' field is already present and valid.
    if (extractedSku.isEmpty) {
      final url = json['url'];
      if (url is String && url.isNotEmpty) {
        try {
          // Step 2: Get the base slug from the URL (e.g., "kasbah-pink-chikankari-kurta-kabjul23d1003")
          String urlSlug = p.basenameWithoutExtension(Uri.parse(url).path);

          // Step 3: Split the slug by hyphens and take the last part.
          final parts = urlSlug.split('-');
          if (parts.isNotEmpty) {
            // This gets "kabjul23d1003" from the list of parts.
            extractedSku = parts.last;
          } else {
            // Fallback in case the slug has no hyphens.
            extractedSku = urlSlug;
          }

        } catch (e) {
          print("Could not parse SKU from URL: $url. Error: $e");
          extractedSku = ''; // Fallback to empty if parsing fails
        }
      }
    }

    // ✅ NEW: Step 4: Convert the final extracted SKU to uppercase.
    // This handles both cases: when the SKU comes directly from json['sku']
    // and when it's extracted from the URL.
    if (extractedSku.isNotEmpty) {
      extractedSku = extractedSku.toUpperCase();
    }

    return Product1(
      designerName: json['name'] ?? 'Unknown Designer',
      // The autosuggest 'description' seems to be the product name.
      productName: json['description'] ?? 'No name',
      // sku: json['sku'] ?? '',
      sku: extractedSku, // Use the extracted SKU!
      url: json['url'] ?? '',
      // We will use the 'description' field as the primary description.
      // If the API provides a dedicated description field, use it. Otherwise, fallback.
      description: json['description'] ?? 'No description available.',
      imageUrl: json['image'] ?? '',
      price: _parsePrice(json['price']),
      // Safely create lists, defaulting to empty if the key is null.
      sizeList: List<String>.from(json['size_name'] ?? []),
      deliveryTime: List<String>.from(json['child_delivery_time'] ?? []),
    );
  }

  /// Factory for parsing the **Solr** search API response.
  /// This response returns plain data, not HTML.
  factory Product1.fromSolr(Map<String, dynamic> doc) {
    // Helper to safely get the first element from a list, or the value itself.
    String _getFirst(dynamic value) {
      if (value is List && value.isNotEmpty) {
        return value.first.toString();
      }
      return value?.toString() ?? '';
    }

    // ✅ NEW HELPER: Safely converts a value to a List<String>.
    // This is the key to fixing the type mismatch errors.
    List<String> _getAsList(dynamic value) {
      if (value is List) {
        // Convert all items in the list to String to be safe.
        return value.map((item) => item.toString()).toList();
      }
      if (value is String) {
        // If Solr returns a single string, wrap it in a list.
        return [value];
      }
      // If null or another type, return an empty list.
      return [];
    }

    // Safely format the price from a number.
    final priceValue = doc['actual_price_1'];
    String formattedPrice = 'N/A';
    if (priceValue is num) {
      formattedPrice = '₹${priceValue.toStringAsFixed(0)}';
    }

    // ✅ Ensure imageUrl is always a full URL
    String rawImageUrl = _getFirst(doc['prod_small_img']);
    String fullImageUrl = '';
    if (rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http')) {
        fullImageUrl = rawImageUrl;
      } else if (rawImageUrl.startsWith('/')) {
        fullImageUrl = 'https://aashniandco.com$rawImageUrl';
      } else {
        // Fallback if the path is relative but doesn't start with '/'
        fullImageUrl = 'https://aashniandco.com/$rawImageUrl';
      }
    }


    return Product1(
      designerName: _getFirst(doc['designer_name']),
      productName: _getFirst(doc['prod_name']),
      sku: _getFirst(doc['prod_sku']),
      imageUrl: _getFirst(doc['prod_small_img']),
      price: formattedPrice,
      url: _getFirst(doc['prod_url']), // Assuming 'prod_url' might be in your response

      // ✅ FIX: Unify the description.
      // We take the `prod_desc` list from Solr and join it into a single string.
      description: _getAsList(doc['prod_desc']).join('\n'),

      // ✅ FIX: Use the `_getAsList` helper to correctly create List<String>.
      sizeList: _getAsList(doc['size_name']),
      deliveryTime: _getAsList(doc['child_delivery_time']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      // Use the key names that the ProductDetailNewInDetailScreen expects
      'prod_sku': sku,
      'designer_name': designerName,
      'prod_name': productName,
      'short_desc': description,
      'prod_small_img': imageUrl,
      'actual_price_1': double.tryParse(price.replaceAll('₹', '')) ?? price,
      'prod_desc': description,
      'child_delivery_time': deliveryTime,
      'size_name': sizeList,

      // Add any other keys the detail screen might need, even if they are null or empty.
      // This prevents "key not found" errors on the detail screen.
      'prod_en_id': '', // Example placeholder
    };
  }
}
//8/8/2025
// class Product1 {
// final String designerName;
// final String productName;
// final String sku;
// final String url;
// final String description; // The property for description
// final String imageUrl;
// final String price;
//
// Product1({
//   required this.designerName,
//   required this.productName,
//   required this.url,
//   required this.sku,
//   required this.description,
//   required this.imageUrl,
//   required this.price,
// });
//
// // This factory for the autosuggest response is correct
// factory Product1.fromJson(Map<String, dynamic> json) {
//   String _parsePrice(String priceHtml) {
//     try {
//       var document = parse(priceHtml);
//       var priceElement = document.querySelector('span.price');
//       // What if priceElement is null? .text would crash.
//       // What if it is found but empty?
//       return priceElement?.text ?? 'N/A';
//     } catch (e) {
//       return 'N/A';
//     }
//   }
//   return Product1(
// designerName: json['name'] ?? 'Unknown Designer',
// productName: json['description'] ?? 'No name',
// sku: json['sku'] ?? '',
// url: json['url'] ?? '',
// description: json['description'] ?? 'No description available.', // Added a fallback
// imageUrl: json['image'] ?? '',
// price: _parsePrice(json['price'] ?? ''),
// );
// }
//
// // ✅ THIS IS THE CORRECTED FACTORY
// factory Product1.fromSolr(Map<String, dynamic> doc) {
// String _getFirst(dynamic value) {
// if (value is List && value.isNotEmpty) {
// return value.first.toString();
// }
// return value?.toString() ?? '';
// }
//
// // Safely format the price
// final priceValue = doc['actual_price_1'];
// String formattedPrice = 'N/A';
// if (priceValue is num) {
// // Use a proper currency formatter for better results
// formattedPrice = '₹${priceValue.toStringAsFixed(0)}';
// }
//
// return Product1(
// designerName: _getFirst(doc['designer_name']),
// productName: _getFirst(doc['prod_name']),
// sku: _getFirst(doc['prod_sku']),
// imageUrl: _getFirst(doc['prod_small_img']),
// price: formattedPrice,
// url: _getFirst(doc['prod_url']), // Assuming you might add prod_url to your `fl`
//
// // ✅ FIX: Provide the required 'description' parameter
// description: _getFirst(doc['prod_desc']),
// );
// }
// }


class SearchCategory {
  final String url;
  final String fullPath;
  final String categoryName;
  final String parentPath;

  SearchCategory({
    required this.url,
    required this.fullPath,
    required this.categoryName,
    required this.parentPath,
  });
}