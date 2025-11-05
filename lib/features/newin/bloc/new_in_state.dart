// //
// // part of 'new_in_bloc.dart';
// //
// //
// // abstract class NewInState extends Equatable {
// //   @override
// //   List<Object> get props => [];
// // }
// //
// // class NewInLoading extends NewInState {}
// //
// // class NewInLoaded extends NewInState {
// //   final List<NewInProduct> designers;
// //   NewInLoaded(this.designers);
// //
// //   @override
// //   List<Object> get props => [designers];
// // }
// //
// // class NewInError extends NewInState {
// //   final String message;
// //   NewInError(this.message);
// //
// //   @override
// //   List<Object> get props => [message];
// // }
//
//



// An enum for clear, readable status management in the UI.
import 'package:equatable/equatable.dart';

import '../model/new_in_model.dart';

enum NewInStatus { initial, loading, success, failure }

class NewInState extends Equatable {
  const NewInState({
    this.status = NewInStatus.initial,
    this.products = const <Product>[],
    this.hasReachedMax = false,
    this.errorMessage,
    this.currentSortOption = "Default",
  });

  final NewInStatus status;
  final List<Product> products;
  final bool hasReachedMax;
  final String? errorMessage;
  final String currentSortOption;

  NewInState copyWith({
    NewInStatus? status,
    List<Product>? products,
    bool? hasReachedMax,
    String? errorMessage,
    String? currentSortOption,
  }) {
    return NewInState(
      status: status ?? this.status,
      products: products ?? this.products,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSortOption: currentSortOption ?? this.currentSortOption,
    );
  }

  @override
  List<Object?> get props => [status, products, hasReachedMax, errorMessage, currentSortOption];
}
//17/7/2025

// import 'package:aashniandco/features/newin/model/new_in_model.dart';
//
// abstract class NewInState {}
//
// class NewInInitial extends NewInState {}
//
// class NewInLoading extends NewInState {}
//
// class NewInLoaded extends NewInState {
//   final List<Product> products;
//   final bool hasReachedEnd;
//
//   NewInLoaded({required this.products,this.hasReachedEnd = false});
// }
//
// class NewInError extends NewInState {
//   final String message;
//
//   NewInError(this.message);
// }



// //
// // part of 'new_in_bloc.dart';
// //
// //
// // abstract class NewInState extends Equatable {
// //   @override
// //   List<Object> get props => [];
// // }
// //
// // class NewInLoading extends NewInState {}
// //
// // class NewInLoaded extends NewInState {
// //   final List<NewInProduct> designers;
// //   NewInLoaded(this.designers);
// //
// //   @override
// //   List<Object> get props => [designers];
// // }
// //
// // class NewInError extends NewInState {
// //   final String message;
// //   NewInError(this.message);
// //
// //   @override
// //   List<Object> get props => [message];
// // }
//
//
// import 'package:aashniandco/features/newin/model/new_in_model.dart';
//
// abstract class NewInAccessoriesState {}
//
// class NewInAccessoriesInitial extends NewInAccessoriesState {}
//
// class NewInAccessoriesLoading extends NewInAccessoriesState {}
//
// class NewInAccessoriesLoaded extends NewInAccessoriesState {
//   final List<Product> products;
//
//   NewInAccessoriesLoaded({required this.products});
// }
//
// class NewInAccessoriesError extends NewInAccessoriesState {
//   final String message;
//
//   NewInAccessoriesError(this.message);
// }
