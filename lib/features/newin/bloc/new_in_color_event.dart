part of 'new_in_color_bloc.dart';

@immutable
abstract class NewInColorEvent {}

class FetchProductsByColor extends NewInColorEvent {
  final String color;

  FetchProductsByColor(this.color);
}
