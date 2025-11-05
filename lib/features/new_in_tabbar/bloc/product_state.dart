import 'package:equatable/equatable.dart';
import '../models/api_response.dart';
import 'product_sorter.dart';


// lib/bloc/product_state.dart
import 'package:equatable/equatable.dart';
import '../models/api_response.dart';
import 'product_sorter.dart';

enum ProductStatus { initial, loading, success, failure, loadingMore }

class ProductState extends Equatable {

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const <Product>[], // This is the VISIBLE list of products
    this.availableFilters = const <Filter>[],
    this.selectedFilters = const <String, List<String>>{},
    this.sortOption = SortOption.none,
    this.hasReachedMax = false,
    this.totalProductsAvailable = 0,
    this.error = '',
    // ✅ NEW: A private field to hold the full list for client-side pagination.
    // We make it private to signal it's for internal BLoC use.
    this.fullProductList = const <Product>[],
  });

  final ProductStatus status;
  final List<Product> products;
  final List<Filter> availableFilters;
  final Map<String, List<String>> selectedFilters;
  final SortOption sortOption;
  final bool hasReachedMax;
  final int totalProductsAvailable;
  final String error;
  // ✅ NEW
  final List<Product> fullProductList;

  // ✅ NEW HELPER: Are we in client-side pagination mode?
  bool get isClientPaginating => fullProductList.isNotEmpty;

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Filter>? availableFilters,
    Map<String, List<String>>? selectedFilters,
    SortOption? sortOption,
    bool? hasReachedMax,
    int? totalProductsAvailable,
    String? error,
    // ✅ NEW
    List<Product>? fullProductList,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      availableFilters: availableFilters ?? this.availableFilters,
      selectedFilters: selectedFilters ?? this.selectedFilters,
      sortOption: sortOption ?? this.sortOption,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      totalProductsAvailable: totalProductsAvailable ?? this.totalProductsAvailable,
      error: error ?? this.error,
      // ✅ NEW
      fullProductList: fullProductList ?? this.fullProductList,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    availableFilters,
    selectedFilters,
    sortOption,
    hasReachedMax,
    totalProductsAvailable,
    error,
    // ✅ NEW
    fullProductList,
  ];
}