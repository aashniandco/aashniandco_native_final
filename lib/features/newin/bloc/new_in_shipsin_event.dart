part of 'new_in_shipsin_bloc.dart';

@immutable
abstract class NewInShipsinEvent {}

class FetchProductsByShipsin extends NewInShipsinEvent {
  final String ships;

  FetchProductsByShipsin( this.ships);
}
