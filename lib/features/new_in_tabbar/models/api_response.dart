// lib/models/api_response.dart

import 'dart:convert';

// The main container for the entire API response
class SolrApiResponse {
  final bool success;
  final List<Product> products;
  final List<Filter> filters;
  final int totalCount;
  final Pagination pagination;

  SolrApiResponse({
    required this.success,
    required this.products,
    required this.filters,
    required this.totalCount,
    required this.pagination,
  });

  factory SolrApiResponse.fromJson(Map<String, dynamic> json) {
    return SolrApiResponse(
      success: json['success'] ?? false,
      products: (json['products'] as List<dynamic>?)
          ?.map((item) => Product.fromJson(item))
          .toList() ?? [],
      filters: (json['filters'] as List<dynamic>?)
          ?.map((item) => Filter.fromJson(item))
          .toList() ?? [],
      totalCount: json['total_count'] ?? 0,
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

// Model for a single product
// lib/models/api_response.dart

// ... (SolrApiResponse, Filter, FilterOption, Pagination classes are unchanged)

// Model for a single product
class Product {
  final String id;
  final String sku;
  final String name;
  final String imageUrl;
  final Price price;
  final String designer;
  final String shortDescription;

  // ✅ ADD THE NEW FIELDS
  final String? fullDescription;
  final String? disclaimer;
  final String? deliveryTime;
  final List<String> sizeNames;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.designer,
    required this.shortDescription,

    this.fullDescription,
    this.disclaimer,
    this.deliveryTime,
    required this.sizeNames,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>? ?? {};
    List<String> parsedSizes = [];
    final rawSizes = json['size_name']; // ✅ Corrected from 'size_names' to 'size_name'

    if (rawSizes != null) {
      if (rawSizes is List) {
        // If it's already a list, use it directly.
        parsedSizes = rawSizes.map((e) => e.toString()).toList();
      } else if (rawSizes is String && rawSizes.isNotEmpty) {
        // If it's a comma-separated string, split it.
        parsedSizes = rawSizes.split(',').map((s) => s.trim()).toList();
      }
    }
    return Product(
      id: json['id']?.toString() ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? 'No Name',
      imageUrl: json['image_url'] ?? '',
      price: Price.fromJson(priceData),
      designer: json['designer'] ?? 'Unknown Designer',
      shortDescription: json['short_description'] ?? 'No description available',

      fullDescription: json['full_description'],
      disclaimer: json['disclaimer'],
      deliveryTime: json['delivery_time'],
      // Safely handle the list of sizes
      // ✅ Use the correctly parsed list.
      sizeNames: parsedSizes,
      // sizeNames: (json['size_names'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  // ✅ NEW: Add this method to convert a Product object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      // Mapping our model fields to the template's expected keys
      'prod_en_id': id,
      'prod_sku': sku,
      'name': name, // The template likely uses 'name' for the product title itself
      'designer_name': designer, // Map 'designer' to 'designer_name'
      'short_desc': shortDescription, // Map 'shortDescription' to 'short_desc'

      // Flatten the price object into the key the template expects
      'actual_price_1': price.finalPrice,

      // Map our single image URL to the keys the template might check
      'prod_small_img': imageUrl,
      'prod_thumb_img': imageUrl,

      // Provide null for data we don't have, so the template can handle it
      'prod_desc': fullDescription,
      'size_name': sizeNames.isNotEmpty ? sizeNames : null, // Pass the list of sizes
      'child_delivery_time': deliveryTime,
      'disclaimer': disclaimer,
    };
  }
}


class Price {
  final num finalPrice;
  final String formattedFinalPrice;
  final String currencySymbol;

  Price({
    required this.finalPrice,
    required this.formattedFinalPrice,
    required this.currencySymbol,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      finalPrice: json['final_price'] ?? 0,
      formattedFinalPrice: json['formatted_final_price'] ?? 'N/A',
      currencySymbol: json['currency_symbol'] ?? '',
    );
  }

  // ✅ NEW: Add this method to convert a Price object to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'final_price': finalPrice,
      'formatted_final_price': formattedFinalPrice,
      'currency_symbol': currencySymbol,
    };
  }
}

// Model for a filter group (e.g., Colors, Sizes)
class Filter {
  final String type;
  final String label;
  final List<FilterOption> options;
  final double? minPrice;
  final double? maxPrice;
  final String? currencySymbol;

  Filter({
    required this.type,
    required this.label,
    this.options = const [],
    this.minPrice,
    this.maxPrice,
    this.currencySymbol,
  });

  factory Filter.fromJson(Map<String, dynamic> json) {
    return Filter(
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((item) => FilterOption.fromJson(item))
          .toList() ?? [],
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      currencySymbol: json['currency_symbol'],
    );
  }
}

// Model for a single filter option (e.g., Red, Small)
class FilterOption {
  final String id;
  final String name;

  FilterOption({required this.id, required this.name});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
    );
  }
}

// Model for pagination data
class Pagination {
  final int currentPage;
  final int pageSize;
  final int totalPages;

  Pagination({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      pageSize: json['page_size'] ?? 20,
      totalPages: json['total_pages'] ?? 1,
    );
  }
}

// class Price {
//   final num finalPrice;
//   final String formattedFinalPrice;
//   final String currencySymbol;
//
//   Price({
//     required this.finalPrice,
//     required this.formattedFinalPrice,
//     required this.currencySymbol,
//   });
//
//   factory Price.fromJson(Map<String, dynamic> json) {
//     return Price(
//       finalPrice: json['final_price'] ?? 0,
//       formattedFinalPrice: json['formatted_final_price'] ?? 'N/A',
//       currencySymbol: json['currency_symbol'] ?? '',
//     );
//   }
// }