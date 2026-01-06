// lib/features/category_products/bloc/category_products_event.dart


// import 'package:equatable/equatable.dart';
// import 'package:flutter/cupertino.dart';
//
// @immutable
// abstract class CategoryProductsEvent {}
//
// // Event to trigger fetching data for a specific category
// class FetchProductsForCategory extends CategoryProductsEvent {
//   final String categoryName;
//
//   FetchProductsForCategory({required this.categoryName});
// }
//
//
//
// enum SortOption { none, latest, priceHighToLow, priceLowToHigh }
//
// abstract class CategoryProductEvent extends Equatable {
//   const CategoryProductEvent();
//   @override
//   List<Object> get props => [];
// }
//
// // Event to fetch the initial list of products FOR A SPECIFIC CATEGORY
// class CategoryProductsFetched extends CategoryProductEvent {
//   final int categoryId;
//   const CategoryProductsFetched({required this.categoryId});
//
//   @override
//   List<Object> get props => [categoryId];
// }
//
// // Event to show the next page of products
// class MoreCategoryProductsRequested extends CategoryProductEvent {}
//
// // Event to sort the list
// class CategorySortChanged extends CategoryProductEvent {
//   final SortOption sortOption;
//   const CategorySortChanged(this.sortOption);
//
//   @override
//   List<Object> get props => [sortOption];
// }



// lib/bloc/category_products/category_products_event.dart



import 'package:equatable/equatable.dart';

abstract class CategoryProductsEvent extends Equatable {
  const CategoryProductsEvent();

  @override
  List<Object> get props => [];
}

// This single event handles initial fetches, sort changes, and pagination.
class FetchProducts extends CategoryProductsEvent {
  final String categoryName;
  final String sortOption; // e.g., "Default", "Price: High to Low"

  // If true, the current list will be cleared and fetched from page 1.
  // Used for the initial load and when the sort option changes.
  final bool isReset;

  // ✅ ADD THIS NEW PROPERTY
  final List<Map<String, String>>? selectedFilters;



  const FetchProducts({
    required this.categoryName,
    required this.sortOption,
    this.isReset = false,
    this.selectedFilters,
  });

  @override
  List<Object> get props => [categoryName, sortOption, isReset];
}

class LoadProducts extends CategoryProductsEvent {}

// lib/features/category_products/bloc/category_products_event.dart

