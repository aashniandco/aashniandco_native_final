import '../model/new_in_model.dart';

abstract class NewInThemeState {}

class NewInThemeInitial extends NewInThemeState {}

class NewInThemeLoading extends NewInThemeState {}

class NewInThemeLoaded extends NewInThemeState {
  late final List<Product> products;

  NewInThemeLoaded({required this.products});
}

class NewInThemeError extends NewInThemeState {
  final String message;

  NewInThemeError(this.message);
}