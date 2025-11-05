

import '../model/new_in_model.dart';

// abstract class NewInProductsState {}
//
// class NewInProductsInitial extends NewInProductsState {}
//
// class NewInProductsLoading extends NewInProductsState {}
//
// class NewInProductsLoaded extends NewInProductsState {
//   final List<Product> products;
//   NewInProductsLoaded(this.products);
// }
//
// class NewInProductsError extends NewInProductsState {
//   final String message;
//   NewInProductsError(this.message);
// }

abstract class NewInProductsState {}

class NewInProductsInitial extends NewInProductsState {}

class NewInProductsLoading extends NewInProductsState {}

class NewInProductsLoaded extends NewInProductsState {
  final List<Product> products;

  NewInProductsLoaded(this.products); // then no changes needed
}

class NewInProductsError extends NewInProductsState {
  final String message;

  NewInProductsError({required this.message});
}