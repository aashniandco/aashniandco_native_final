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
// class Product {
//   final String id;
//   final String sku;
//   final String name;
//   final String imageUrl;
//   final Price price;
//
//   Product({
//     required this.id,
//     required this.sku,
//     required this.name,
//     required this.imageUrl,
//     required this.price,
//   });
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//
//     final priceData = json['price'] as Map<String, dynamic>? ?? {};
//     return Product(
//       id: json['id'] ?? 0,
//       sku: json['sku'] ?? '',
//       name: json['name'] ?? 'No Name',
//       imageUrl: json['image_url'] ?? '',
//       price: Price.fromJson(priceData),
//     );
//   }
// }

class Product {
  final String id;
  final String sku;
  final String name;
  final String imageUrl;
  final Price price;
  final int position; // 1. ADD THE POSITION PROPERTY

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.position, // 2. ADD IT TO THE CONSTRUCTOR
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final priceData = json['price'] as Map<String, dynamic>? ?? {};

    // This helper function safely handles cases where 'position' might be null,
    // a string ("1"), or an integer (1) in the JSON response.
    int parsePosition(dynamic pos) {
      if (pos == null) return 0; // Default to 0 if not present
      return int.tryParse(pos.toString()) ?? 0; // Use 0 if parsing fails
    }

    return Product(
      // ✅ Corrected Bug: Your 'id' is a String, so we ensure it's parsed as one.
      // id: json['id']?.toString() ?? '0',
      id: json['id']?.toString() ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? 'No Name',
      imageUrl: json['image_url'] ?? '',
      price: Price.fromJson(priceData),
      // 3. PARSE THE POSITION FROM JSON
      // This is the most important part for the fix.
      position: parsePosition(json['position']),
    );
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
}