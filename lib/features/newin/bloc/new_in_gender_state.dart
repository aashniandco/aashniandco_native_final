import '../model/new_in_model.dart';

abstract class NewInGenderState {}

class NewInGenderInitial extends NewInGenderState {}

class NewInGenderLoading extends NewInGenderState {}

class NewInGenderLoaded extends NewInGenderState {
  late final List<Product> products;

  NewInGenderLoaded({required this.products});
}

class NewInGenderError extends NewInGenderState {
  final String message;

  NewInGenderError(this.message);
}