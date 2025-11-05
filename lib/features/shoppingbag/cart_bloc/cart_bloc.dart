import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/io_client.dart';
import 'cart_event.dart';
import 'cart_state.dart';

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_event.dart';
import 'cart_state.dart';

// lib/features/shoppingbag/bloc/cart_bloc.dart

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_event.dart';
import 'cart_state.dart';

// lib/features/shoppingbag/bloc/cart_bloc.dart

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_event.dart';
import 'cart_state.dart'; // Make sure this file has the Equatable/copyWith changes

import 'package:aashniandco/features/auth/data/auth_repository.dart';
import 'package:aashniandco/features/shoppingbag/repository/cart_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _cartRepository;
  final AuthRepository _authRepository;

  CartBloc({
    required CartRepository cartRepository,
    required AuthRepository authRepository,
  })  : _cartRepository = cartRepository,
        _authRepository = authRepository,
        super(CartInitial()) {
    on<FetchCartItems>(_onFetchCartItems);
    on<RemoveCartItem>(_onRemoveCartItem);
    on<UpdateCartItemQty>(_onUpdateCartItemQty);
    on<ApplyCoupon>(_onApplyCoupon);
    on<RemoveCoupon>(_onRemoveCoupon);
    on<ClearCouponError>(_onClearCouponError);
  }
  // --- ADD THIS NEW EVENT HANDLER ---
  void _onClearCouponError(ClearCouponError event, Emitter<CartState> emit) {
    final currentState = state;
    if (currentState is CartLoaded) {
      // Emit the same state again, but specifically clearing the error message.
      emit(currentState.copyWith(clearCouponError: true));
    }
  }

  Future<void> _onApplyCoupon(ApplyCoupon event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    try {
      final success = await _cartRepository.applyCoupon(event.couponCode);
      if (success) {
        // On success, just re-fetch the entire cart to get updated totals.
        add(FetchCartItems());
      } else {
        // This is a soft failure, but not a critical error.
        emit(currentState.copyWith(couponError: "Could not apply coupon."));
      }
    } catch (e) {
      // ✅ THE KEY CHANGE: Instead of emitting CartError,
      // emit the EXISTING CartLoaded state with the new couponError message.
      emit(currentState.copyWith(couponError: e.toString()));
    }
  }

  // --- MODIFICATION FOR REMOVE COUPON ---
  Future<void> _onRemoveCoupon(RemoveCoupon event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;
    try {
      final success = await _cartRepository.removeCoupon();
      if (success) {
        add(FetchCartItems());
      } else {
        emit(currentState.copyWith(couponError: "Could not remove coupon."));
      }
    } catch (e) {
      // ✅ SAME CHANGE HERE
      emit(currentState.copyWith(couponError: e.toString()));
    }
  }
  // Future<void> _onApplyCoupon(ApplyCoupon event, Emitter<CartState> emit) async {
  //   // Optionally emit a loading state
  //   // emit(CartLoading());
  //   try {
  //     final success = await _cartRepository.applyCoupon(event.couponCode);
  //     if (success) {
  //       // After applying, fetch the entire cart again to get updated totals
  //       add(FetchCartItems());
  //     } else {
  //       // Handle error, maybe emit a CartError state
  //     }
  //   } catch (e) {
  //     emit(CartError(e.toString()));
  //   }
  // }
  //
  // Future<void> _onRemoveCoupon(RemoveCoupon event, Emitter<CartState> emit) async {
  //   try {
  //     final success = await _cartRepository.removeCoupon();
  //     if (success) {
  //       add(FetchCartItems());
  //     }
  //   } catch (e) {
  //     emit(CartError(e.toString()));
  //   }
  // }
  // // Central helper method to get a complete, consistent cart state.

  Future<CartLoaded> _loadCartData() async {
    print("whnen cart item update called>> ");
    // No need to check for customerId here anymore.

    // Fetch all data in parallel for efficiency
    final results = await Future.wait([
      _cartRepository.getCartItems(),
      _cartRepository.fetchCartTotalWeight(),
      _cartRepository.fetchTotal(), // No longer needs customerId
    ]);

    final items = results[0] as List<Map<String, dynamic>>;
    final weight = results[1] as double;
    final totals = results[2] as Map<String, dynamic>;
    return CartLoaded(items: items, totalCartWeight: weight,totals: totals,);
  }


  //live*
  // Future<CartLoaded> _loadCartData() async {
  //   print("whnen cart item update called>> ");
  //   // No need to check for customerId here anymore.
  //
  //   // Fetch all data in parallel for efficiency
  //   final results = await Future.wait([
  //     _cartRepository.getCartItems(),
  //     _cartRepository.fetchCartTotalWeight(), // No longer needs customerId
  //   ]);
  //
  //   final items = results[0] as List<Map<String, dynamic>>;
  //   final weight = results[1] as double;
  //
  //   return CartLoaded(items: items, totalCartWeight: weight);
  // }

  // Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
  //   emit(CartLoading());
  //   try {
  //     final loadedState = await _loadCartData();
  //     emit(loadedState);
  //   } catch (e) {
  //     emit(CartError(e.toString()));
  //   }
  // }
  Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
    // 1. Immediately signal that loading has started.
    emit(CartLoading());

    try {
      // 2. Attempt to load the cart data as usual.
      final loadedState = await _loadCartData();
      emit(loadedState);

    } catch (e) {
      // 3. ✅ THIS IS THE MODIFIED PART
      // Convert the exception to a string to inspect its content.
      final errorMessage = e.toString();

      // 4. Check if the error is the specific "cart not found" message from your API.
      if (errorMessage.contains("Current customer does not have an active cart")) {

        // This is not a real error for the user; it just means their cart is empty.
        // So, we emit a CartLoaded state with empty data.
        // Your UI will see this and display "Your shopping bag is empty."
        emit(CartLoaded(items: const [], totals: const {}));

      } else {

        // 5. For any other type of error (network failure, server error, etc.),
        // emit the actual CartError state so the user knows something went wrong.
        emit(CartError(errorMessage));
      }
    }
  }
  Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    // 1. Optimistic UI update
    final optimisticItems = List<Map<String, dynamic>>.from(currentState.items)
      ..removeWhere((item) => item['item_id'] == event.itemId);
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. Perform the actual network call
      await _cartRepository.removeItem(event.itemId);

      // 3. After success, fetch ALL fresh data to ensure consistency.
      final finalState = await _loadCartData();
      emit(finalState);
    } catch (e) {
      emit(CartError("Failed to remove item."));
      // On failure, revert to the state before the optimistic update
      emit(currentState);
    }
  }

  Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
    final currentState = state;
    if (currentState is! CartLoaded) return;

    // 1. Optimistic UI update for instant feedback
    final optimisticItems = currentState.items.map((item) {
      if (item['item_id'] == event.itemId) {
        return {...item, 'qty': event.newQty}; // Create a new map with updated qty
      }
      return item;
    }).toList();
    emit(currentState.copyWith(items: optimisticItems, isUpdating: true));

    try {
      // 2. Await the actual API call.
      await _cartRepository.updateCartItemQty(event.itemId, event.newQty);

      // 3. ✅ CORRECTED: After success, call _loadCartData to get the final, consistent state.
      final finalState = await _loadCartData();
      emit(finalState);
    } catch (e) {
      emit(CartError("Failed to update quantity."));
      // On failure, revert to the original state
      emit(currentState);
    }
  }
}

// class CartBloc extends Bloc<CartEvent, CartState> {
//   final CartRepository _cartRepository;
//   final AuthRepository _authRepository; // This was missing from the snippet
//
//   CartBloc({
//     required CartRepository cartRepository,
//     required AuthRepository authRepository,
//   })  : _cartRepository = cartRepository,
//         _authRepository = authRepository,
//         super(CartInitial()) {
//     on<FetchCartItems>(_onFetchCartItems);
//     on<RemoveCartItem>(_onRemoveCartItem);
//     on<UpdateCartItemQty>(_onUpdateCartItemQty);
//   }
//
//   /// Centralized method to get the current cart state from the server.
//   /// It intelligently fetches the correct cart and calculates the total weight.
//   Future<CartLoaded> _getCurrentCartState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerId = prefs.getInt('user_customer_id');
//
//     if (customerId != null) {
//       // --- CASE 1: LOGGED-IN USER ---
//       final results = await Future.wait([
//         _cartRepository.getCartItems(),
//         _cartRepository.fetchCartTotalWeight(customerId),
//       ]);
//       final items = results[0] as List<Map<String, dynamic>>;
//       final weight = results[1] as double;
//       return CartLoaded(items: items, totalCartWeight: weight);
//     } else {
//       // --- CASE 2: GUEST USER ---
//       final guestQuoteId = prefs.getString('guest_quote_id');
//       if (guestQuoteId == null || guestQuoteId.isEmpty) {
//         return const CartLoaded(items: [], totalCartWeight: 0.0);
//       }
//
//       final guestCartData = await _cartRepository.fetchGuestCart(guestQuoteId);
//       final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(guestCartData['items'] ?? []);
//
//       // Get weight from totals if available, otherwise calculate manually as a fallback.
//       double totalWeight = (guestCartData['items_weight'] as num?)?.toDouble() ?? 0.0;
//       if (totalWeight == 0.0 && items.isNotEmpty) {
//         for (var item in items) {
//           final itemWeight = (item['weight'] as num?)?.toDouble() ?? 0.0;
//           final itemQty = (item['qty'] as num?)?.toDouble() ?? 1.0;
//           totalWeight += itemWeight * itemQty;
//         }
//       }
//       return CartLoaded(items: items, totalCartWeight: totalWeight);
//     }
//   }
//
//   /// Handler to fetch the initial cart items.
//   Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
//     emit(CartLoading());
//     try {
//       final loadedState = await _getCurrentCartState();
//       emit(loadedState);
//     } catch (e) {
//       emit(CartError("Failed to load cart: ${e.toString()}"));
//     }
//   }
//
//   /// ✅ CORRECTED: Optimistic update for removing an item.
//   Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
//     // 'state' is an instance variable available in every Bloc event handler.
//     final currentState = state;
//     if (currentState is! CartLoaded) return;
//
//     // 1. OPTIMISTIC UI UPDATE:
//     // Create a new list without the removed item.
//     final optimisticItems = List<Map<String, dynamic>>.from(currentState.items)
//       ..removeWhere((item) => item['item_id'] == event.itemId);
//
//     // Immediately emit the new state with the updated item list.
//     emit(currentState.copyWith(items: optimisticItems, isUpdating: true));
//
//     try {
//       // 2. BACKGROUND API CALL:
//       // '_cartRepository' is an instance variable of the CartBloc class.
//       await _cartRepository.removeItem(event.itemId);
//
//       // 3. FINAL REFRESH:
//       // On success, fetch the authoritative state from the server to sync totals/weight.
//       // '_getCurrentCartState' is a method within this same CartBloc class.
//       final finalState = await _getCurrentCartState();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to remove item."));
//       // On failure, revert to the state before the optimistic update.
//       emit(currentState);
//     }
//   }
//
//   /// ✅ CORRECTED: Optimistic update for changing quantity.
//   Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
//     final currentState = state;
//     if (currentState is! CartLoaded) return;
//
//     // 1. OPTIMISTIC UI UPDATE:
//     final optimisticItems = currentState.items.map((item) {
//       if (item['item_id'] == event.itemId) {
//         return {...item, 'qty': event.newQty};
//       }
//       return item;
//     }).toList();
//
//     emit(currentState.copyWith(items: optimisticItems, isUpdating: true));
//
//     try {
//       // 2. BACKGROUND API CALL:
//       await _cartRepository.updateCartItemQty(event.itemId, event.newQty);
//
//       // 3. FINAL REFRESH:
//       final finalState = await _getCurrentCartState();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to update quantity."));
//       // On failure, revert.
//       emit(currentState);
//     }
//   }
// }


// class CartBloc extends Bloc<CartEvent, CartState> {
//   final CartRepository _cartRepository;
//   final AuthRepository _authRepository;
//
//   CartBloc({
//     required CartRepository cartRepository,
//     required AuthRepository authRepository,
//   })  : _cartRepository = cartRepository,
//         _authRepository = authRepository,
//         super(CartInitial()) {
//     on<FetchCartItems>(_onFetchCartItems);
//     on<RemoveCartItem>(_onRemoveCartItem);
//     on<UpdateCartItemQty>(_onUpdateCartItemQty);
//   }
//
//   /// Centralized method to get the current cart state.
//   /// It intelligently fetches the correct cart and calculates the total weight.
//   Future<CartLoaded> _getCurrentCartState() async {
//     final prefs = await SharedPreferences.getInstance();
//     final customerId = prefs.getInt('user_customer_id');
//
//     if (customerId != null) {
//       // --- CASE 1: LOGGED-IN USER ---
//       final results = await Future.wait([
//         _cartRepository.getCartItems(),
//         _cartRepository.fetchCartTotalWeight(customerId),
//       ]);
//       final items = results[0];
//       final weight = results[1];
//       return CartLoaded(items: items, totalCartWeight: weight);
//     } else {
//       // --- CASE 2: GUEST USER ---
//       final guestQuoteId = prefs.getString('guest_quote_id');
//       if (guestQuoteId == null || guestQuoteId.isEmpty) {
//         return CartLoaded(items: [], totalCartWeight: 0.0);
//       }
//
//       final guestCartData = await _cartRepository.fetchGuestCart(guestQuoteId);
//       final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(guestCartData['items'] ?? []);
//
//       // The guest cart API includes weight in the totals segment.
//       // We can also calculate manually as a fallback.
//       double totalWeight = (guestCartData['items_weight'] as num?)?.toDouble() ?? 0.0;
//       if (totalWeight == 0.0) {
//         for (var item in items) {
//           final itemWeight = (item['weight'] as num?)?.toDouble() ?? 0.0;
//           final itemQty = (item['qty'] as num?)?.toDouble() ?? 1.0;
//           totalWeight += itemWeight * itemQty;
//         }
//       }
//       return CartLoaded(items: items, totalCartWeight: totalWeight);
//     }
//   }
//
//   Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
//     emit(CartLoading());
//     try {
//       final loadedState = await _getCurrentCartState();
//       emit(loadedState);
//     } catch (e) {
//       emit(CartError("Failed to load cart: ${e.toString()}"));
//     }
//   }
//
//   /// ✅ CORRECTED: "Load -> Modify -> Reload" pattern
//   Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
//     final currentState = state;
//     // Show a loading indicator to prevent user from multiple clicks
//     // and provide feedback.
//     emit(CartLoading());
//
//     try {
//       // 1. Perform the actual network call using the updated repository.
//       await _cartRepository.removeItem(event.itemId);
//
//       // 2. After success, re-fetch the ENTIRE cart state to get the updated weight.
//       final finalState = await _getCurrentCartState();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to remove item."));
//       // On failure, revert to the state before the action.
//       if (currentState is CartLoaded) {
//         emit(currentState);
//       }
//     }
//   }
//
//   /// ✅ CORRECTED: "Load -> Modify -> Reload" pattern
//   Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
//     final currentState = state;
//     emit(CartLoading());
//
//     try {
//       // 1. Perform the actual network call.
//       await _cartRepository.updateCartItemQty(event.itemId, event.newQty);
//
//       // 2. After success, re-fetch the ENTIRE cart state.
//       final finalState = await _getCurrentCartState();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to update quantity."));
//       // On failure, revert to the state before the action.
//       if (currentState is CartLoaded) {
//         emit(currentState);
//       }
//     }
//   }
// }

// class CartBloc extends Bloc<CartEvent, CartState> {
//   final CartRepository _cartRepository;
//   final AuthRepository _authRepository;
//
//   CartBloc({
//     required CartRepository cartRepository,
//     required AuthRepository authRepository,
//   })  : _cartRepository = cartRepository,
//         _authRepository = authRepository,
//         super(CartInitial()) {
//     on<FetchGuestCartItems>(_onFetchGuestCartItems);
//     on<FetchCartItems>(_onFetchCartItems);
//     on<RemoveCartItem>(_onRemoveCartItem);
//     on<UpdateCartItemQty>(_onUpdateCartItemQty);
//   }
//
//   // Central helper method to get a complete, consistent cart state.
//   Future<CartLoaded> _loadCartData() async {
//     final prefs = await SharedPreferences.getInstance();
//     // ✅ Use the correct key and handle null case
//     final customerId = prefs.getInt('user_customer_id');
//
//     if (customerId == null) {
//       // If user is not logged in, return an empty cart state
//       return  CartLoaded(items: [], totalCartWeight: 0.0);
//     }
//
//     // Fetch all data in parallel for efficiency
//     final results = await Future.wait([
//       _cartRepository.getCartItems(),
//       _cartRepository.fetchCartTotalWeight(customerId),
//     ]);
//
//     final items = results[0] as List<Map<String, dynamic>>;
//     final weight = results[1] as double;
//
//     return CartLoaded(items: items, totalCartWeight: weight);
//   }
//
//   Future<void> _onFetchCartItems(FetchCartItems event, Emitter<CartState> emit) async {
//     emit(CartLoading());
//     try {
//       final loadedState = await _loadCartData();
//       emit(loadedState);
//     } catch (e) {
//       emit(CartError(e.toString()));
//     }
//   }
//
//   // In your CartBloc...
//
//   Future<void> _onFetchGuestCartItems(FetchGuestCartItems event, Emitter<CartState> emit) async {
//     emit(CartLoading());
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final guestQuoteId = prefs.getString('guest_quote_id');
//
//       if (guestQuoteId == null || guestQuoteId.isEmpty) {
//         emit(CartLoaded(items: [], totalCartWeight: 0.0));
//         return;
//       }
//
//       HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//
//       final response = await ioClient.get(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/guest-carts/$guestQuoteId'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         // ✅✅✅ THIS IS THE FIX ✅✅✅
//         // We cast the List<dynamic> from the JSON to the specific type our state expects.
//         // We also provide a fallback '?? []' in case 'items' is null.
//         final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(data['items'] ?? []);
//
//         // TODO: Calculate total weight if the guest cart API provides it.
//         // This might involve iterating through the 'items' list.
//         double totalWeight = 0.0;
//
//         emit(CartLoaded(items: items, totalCartWeight: totalWeight));
//       } else {
//         throw Exception('Failed to load guest cart: ${response.body}');
//       }
//     } catch (e) {
//       emit(CartError(e.toString()));
//     }
//   }
//
//   Future<void> _onRemoveCartItem(RemoveCartItem event, Emitter<CartState> emit) async {
//     final currentState = state;
//     if (currentState is! CartLoaded) return;
//
//     // 1. Optimistic UI update
//     final optimisticItems = List<Map<String, dynamic>>.from(currentState.items)
//       ..removeWhere((item) => item['item_id'] == event.itemId);
//     emit(currentState.copyWith(items: optimisticItems, isUpdating: true));
//
//     try {
//       // 2. Perform the actual network call
//       await _cartRepository.removeItem(event.itemId);
//
//       // 3. After success, fetch ALL fresh data to ensure consistency.
//       final finalState = await _loadCartData();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to remove item."));
//       // On failure, revert to the state before the optimistic update
//       emit(currentState);
//     }
//   }
//
//   Future<void> _onUpdateCartItemQty(UpdateCartItemQty event, Emitter<CartState> emit) async {
//     final currentState = state;
//     if (currentState is! CartLoaded) return;
//
//     // 1. Optimistic UI update for instant feedback
//     final optimisticItems = currentState.items.map((item) {
//       if (item['item_id'] == event.itemId) {
//         return {...item, 'qty': event.newQty}; // Create a new map with updated qty
//       }
//       return item;
//     }).toList();
//     emit(currentState.copyWith(items: optimisticItems, isUpdating: true));
//
//     try {
//       // 2. Await the actual API call.
//       await _cartRepository.updateCartItemQty(event.itemId, event.newQty);
//
//       // 3. ✅ CORRECTED: After success, call _loadCartData to get the final, consistent state.
//       final finalState = await _loadCartData();
//       emit(finalState);
//     } catch (e) {
//       emit(CartError("Failed to update quantity."));
//       // On failure, revert to the original state
//       emit(currentState);
//     }
//   }
// }