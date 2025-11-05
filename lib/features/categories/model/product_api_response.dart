// lib/models/product_api_response.dart

import '../../newin/model/new_in_model.dart';
  // Assuming your Product model is in here

// Main response object from the API
class ProductsAndFiltersResponse {
  final List<Product> products;
  final List<ApiFilter> filters;
  final PaginationInfo pagination;
  final int totalCount;

  ProductsAndFiltersResponse({
    required this.products,
    required this.filters,
    required this.pagination,
    required this.totalCount,
  });

  factory ProductsAndFiltersResponse.fromJson(Map<String, dynamic> json) {
    return ProductsAndFiltersResponse(
      products: (json['products'] as List<dynamic>?)
          ?.map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList() ??
          [],
      filters: (json['filters'] as List<dynamic>?)
          ?.map((f) => ApiFilter.fromJson(f as Map<String, dynamic>))
          .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>? ?? {}),
      totalCount: json['total_count'] as int? ?? 0,
    );
  }
}

// Represents the pagination block in the API response
class PaginationInfo {
  final int currentPage;
  final int pageSize;
  final int totalPages;

  PaginationInfo({
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['current_page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 0,
    );
  }
}

// Represents a single filter group (e.g., "Color", "Size")
class ApiFilter {
  final String name; // e.g., "color_filter"
  final String label; // e.g., "Color"
  final List<FilterOption> options;

  ApiFilter({required this.name, required this.label, required this.options});

  factory ApiFilter.fromJson(Map<String, dynamic> json) {
    return ApiFilter(
      name: json['name'] as String? ?? '',
      label: json['label'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => FilterOption.fromJson(o as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

// Represents a single option within a filter (e.g., "Red", "Large")
class FilterOption {
  final String label;
  final String value; // This is the ID you'll send back to the API
  final int count;

  FilterOption({required this.label, required this.value, required this.count});

  factory FilterOption.fromJson(Map<String, dynamic> json) {
    return FilterOption(
      label: json['label'] as String? ?? '',
      value: json['value']?.toString() ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}