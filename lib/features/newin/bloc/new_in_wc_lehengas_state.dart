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
import 'package:aashniandco/features/newin/model/new_in_model.dart';

abstract class NewInWcLehengasState {}

class NewInWcLehengasInitial extends NewInWcLehengasState {}

class NewInWcLehengasLoading extends NewInWcLehengasState {}

class NewInWcLehengasLoaded extends NewInWcLehengasState {
  final List<Product> products;

  NewInWcLehengasLoaded({required this.products});
}

class NewInWcLehengasError extends NewInWcLehengasState {
  final String message;

  NewInWcLehengasError(this.message);
}
