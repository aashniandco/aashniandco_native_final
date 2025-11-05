import '../model/new_in_model.dart';

abstract class NewInSizeState {}

class NewInSizeInitial extends NewInSizeState {}

class NewInSizeLoading extends NewInSizeState {}

class NewInSizeLoaded extends NewInSizeState {
  late final List<Product> products;

  NewInSizeLoaded({required this.products});
}

class NewInSizeError extends NewInSizeState {
  final String message;

  NewInSizeError(this.message);
}