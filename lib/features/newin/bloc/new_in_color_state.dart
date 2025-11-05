import '../model/new_in_model.dart';

abstract class NewInColorState {}

class NewInColorInitial extends NewInColorState {}

class NewInColorLoading extends NewInColorState {}

class NewInColorLoaded extends NewInColorState {
  late final List<Product> products;

  NewInColorLoaded({required this.products});
}

class NewInColorError extends NewInColorState {
  final String message;

  NewInColorError(this.message);
}