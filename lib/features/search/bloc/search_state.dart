//
//
// import 'package:equatable/equatable.dart';
//
// import 'package:aashniandco/features/search/data/models/product_model.dart';
//
// abstract class SearchState extends Equatable {
//   const SearchState();
//
//   @override
//   List<Object> get props => [];
// }
//
// // Initial state, before any search is performed
// class SearchInitial extends SearchState {}
//
// // State when the search is in progress (show a loader)
// class SearchLoading extends SearchState {}
//
// // State when the search is successful
// class SearchSuccess extends SearchState {
//   final List<Product> products;
//
//   const SearchSuccess(this.products);
//
//   @override
//   List<Object> get props => [products];
// }
//
// // State when the search fails
// class SearchFailure extends SearchState {
//   final String error;
//
//   const SearchFailure(this.error);
//
//   @override
//   List<Object> get props => [error];
// }


// lib/features/search/bloc/search_state.dart

// Make sure this line exists if you are using 'part' files

import 'package:equatable/equatable.dart';

import '../data/models/product_model.dart';
import '../data/models/search_results_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

// --- THIS IS THE CORRECTED CLASS ---
class SearchSuccess extends SearchState {
  // ✅ It now holds the complete results object, NOT a List<Product>
  final SearchResults results;

  // ✅ The constructor now accepts a SearchResults object
  const SearchSuccess(this.results);

  @override
  List<Object> get props => [results];
}

class SearchFailure extends SearchState {
  final String error;

  const SearchFailure(this.error);

  @override
  List<Object> get props => [error];
}