// lib/bloc/wishlist_event.dart

// import 'package:equatable/equatable.dart';
//
// // Abstract base class for all wishlist events
// abstract class WishlistEvent extends Equatable {
//   const WishlistEvent();
//
//   @override
//   List<Object> get props => [];
// }
//
// // Event triggered when the wishlist page is first loaded.
// class WishlistStarted extends WishlistEvent {}
//
// // Event triggered when the user taps the delete button for an item.
// class WishlistItemDeleted extends WishlistEvent {
//   final int itemId;
//
//   const WishlistItemDeleted(this.itemId);
//
//   @override
//   List<Object> get props => [itemId];
// }

// lib/bloc/wishlist_event.dart

import 'package:equatable/equatable.dart';

abstract class WishlistEvent extends Equatable {
  const WishlistEvent();

  @override
  List<Object> get props => [];
}

/// Event to signal the BLoC to fetch wishlist items.
class WishlistStarted extends WishlistEvent {}

/// Event to signal the BLoC to delete an item.
class WishlistItemDeleted extends WishlistEvent {
  final int itemId;

  const WishlistItemDeleted(this.itemId);

  @override
  List<Object> get props => [itemId];
}