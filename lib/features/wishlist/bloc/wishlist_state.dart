// lib/bloc/wishlist_state.dart

// import 'package:equatable/equatable.dart';
//
// // Abstract base class for all wishlist states
// abstract class WishlistState extends Equatable {
//   const WishlistState();
//
//   @override
//   List<Object> get props => [];
// }
//
// // The initial state, before any data is fetched.
// class WishlistInitial extends WishlistState {}
//
// // The state when the wishlist is being fetched from the API.
// class WishlistLoading extends WishlistState {}
//
// // The state when the wishlist has been successfully loaded.
// class WishlistLoaded extends WishlistState {
//   final List<dynamic> wishlistItems;
//
//   const WishlistLoaded(this.wishlistItems);
//
//   @override
//   List<Object> get props => [wishlistItems];
// }
//
// // The state when an error occurs during fetching or deleting.
// class WishlistError extends WishlistState {
//   final String message;
//
//   const WishlistError(this.message);
//
//   @override
//   List<Object> get props => [message];
// }



import 'package:equatable/equatable.dart';

// Abstract base class for all wishlist states
abstract class WishlistState extends Equatable {
  const WishlistState();

  @override
  List<Object> get props => [];
}

// The initial state, before any data is fetched.
class WishlistInitial extends WishlistState {}

// The state when the wishlist is being fetched from the API.
class WishlistLoading extends WishlistState {}

// The state when the wishlist has been successfully loaded.
class WishlistLoaded extends WishlistState {
  final List<dynamic> wishlistItems;

  const WishlistLoaded(this.wishlistItems);

  @override
  List<Object> get props => [wishlistItems];
}

// The state when an error occurs during fetching or deleting.
class WishlistError extends WishlistState {
  final String message;

  const WishlistError(this.message);

  @override
  List<Object> get props => [message];
}

// --- NEW STATE ADDED ---
// This state represents the specific case where the user is not logged in.
// This allows the UI to react specifically to this condition (e.g., navigate to login).
class WishlistUserNotLoggedIn extends WishlistState {}