// lib/features/category_products/bloc/category_products_state.dart


// lib/bloc/category_products/category_products_state.dart



// Enum to represent the current status, making it easy for the UI to build.
import 'package:equatable/equatable.dart';

import '../../newin/model/new_in_model.dart';

enum CategoryProductsStatus { initial, loading, success, failure }

class CategoryProductsState extends Equatable {
  const CategoryProductsState({
    this.status = CategoryProductsStatus.initial,
    this.products = const <Product>[],
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentSortOption = "Default",
    this.activeFilters,

  });

  final CategoryProductsStatus status;
  final List<Product> products;
  final bool hasReachedMax; // Will be true when the last page is loaded
  final String? errorMessage;
  final String currentSortOption;

  final List<Map<String, String>>? activeFilters;
  // To track the current sort

  // copyWith allows creating a new state instance by modifying the old one.
  CategoryProductsState copyWith({
    CategoryProductsStatus? status,
    List<Product>? products,
    bool? hasReachedMax,
    String? errorMessage,
    String? currentSortOption,
    List<Map<String, String>>? activeFilters,
  }) {
    return CategoryProductsState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSortOption: currentSortOption ?? this.currentSortOption,
      activeFilters: activeFilters ?? this.activeFilters,

    );
  }

  @override
  List<Object?> get props => [status, products, hasReachedMax, errorMessage, currentSortOption];
}

class CategoryProductsError extends CategoryProductsState {
  final String message;
  CategoryProductsError(this.message);
}

//17/07/2025
// import '../../newin/model/new_in_model.dart';
//
// abstract class CategoryProductsState {}
//
// class CategoryProductsInitial extends CategoryProductsState {}
// class CategoryProductsLoading extends CategoryProductsState {}
//
// class CategoryProductsLoaded extends CategoryProductsState {
//   final List<Product> products; // Assuming you have a Product model
//
//   CategoryProductsLoaded({required this.products});
// }
//
// class CategoryProductsError extends CategoryProductsState {
//   final String message;
//
//   CategoryProductsError(this.message);
// }




// lib/features/category_products/bloc/category_products_state.dart
// lib/features/category_products/bloc/category_products_state.dart

