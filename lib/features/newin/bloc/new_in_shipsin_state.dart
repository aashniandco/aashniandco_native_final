import '../model/new_in_model.dart';

abstract class NewInShipsinState {}

class NewInShipsinInitial extends NewInShipsinState {}

class NewInShipsinLoading extends NewInShipsinState {}

class NewInShipsinLoaded extends NewInShipsinState {
  late final List<Product> products;

  NewInShipsinLoaded({required this.products});
}

class NewInShipsinError extends NewInShipsinState {
  final String message;

  NewInShipsinError(this.message);
}