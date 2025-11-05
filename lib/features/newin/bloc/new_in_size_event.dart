part of 'new_in_size_bloc.dart';

@immutable
abstract class NewInSizeEvent {}

class FetchProductsBySize extends NewInSizeEvent {
  final String size;

  FetchProductsBySize(this.size);
}
