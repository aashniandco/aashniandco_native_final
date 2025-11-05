// // lib/bloc/product_event.dart
//
// import 'package:equatable/equatable.dart';
//
// import 'package:equatable/equatable.dart';
//
// import 'package:aashniandco/features/new_in_tabbar/bloc/product_event.dart';
//
// import '../../categories/bloc/category_products_event.dart';
//
// abstract class ProductEvent extends Equatable {
//   const ProductEvent();
//
//   @override
//   List<Object> get props => [];
// }
//
// /// Event to fetch the initial full list of products
// class ProductsFetched extends ProductEvent {}
//
// /// Event to show the next page of products from memory
// class MoreProductsRequested extends ProductEvent {}
//
// /// Event to sort the full list of products in memory
// class SortChanged extends ProductEvent {
//   final SortOption sortOption;
//
//   const SortChanged(this.sortOption);
//
//   @override
//   List<Object> get props => [sortOption];
// }
//
// /// Event to apply a new filter (will trigger a full re-fetch)
// class FilterToggled extends ProductEvent {
//   final String filterType;
//   final String optionId;
//
//   const FilterToggled({required this.filterType, required this.optionId});
//
//   @override
//   List<Object> get props => [filterType, optionId];
// }
//
// /// Event to clear all filters (will trigger a full re-fetch)
// class FiltersCleared extends ProductEvent {}



// lib/bloc/product_event.dart

import 'package:equatable/equatable.dart';
// ✅ FIXED: Import SortOption from its single source of truth.
import 'product_sorter.dart';

// ❌ DELETED: The duplicate imports and the duplicate enum definition are gone.

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object> get props => [];
}

/// Event to fetch the initial list of products
class ProductsFetched extends ProductEvent {}

/// Event for infinite scrolling
class MoreProductsRequested extends ProductEvent {}

/// Event to change the sorting
class SortChanged extends ProductEvent {
  // This now correctly refers to the one and only SortOption type
  final SortOption sortOption;

  const SortChanged(this.sortOption);

  @override
  List<Object> get props => [sortOption];
}

/// Event to apply a new filter
class FilterToggled extends ProductEvent {
  final String filterType;
  final String optionId;

  const FilterToggled({required this.filterType, required this.optionId});

  @override
  List<Object> get props => [filterType, optionId];
}

/// Event to clear all filters
class FiltersCleared extends ProductEvent {}