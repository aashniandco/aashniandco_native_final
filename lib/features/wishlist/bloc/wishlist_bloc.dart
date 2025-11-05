// lib/bloc/wishlist_bloc.dart

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/wishlist_api_service.dart'; // Correct the import path
import 'wishlist_event.dart';
import 'wishlist_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

// lib/bloc/wishlist_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

import 'wishlist_event.dart';
import 'wishlist_state.dart';

class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
  final WishlistApiService _wishlistApiService;

  WishlistBloc(this._wishlistApiService) : super(WishlistInitial()) {
    on<WishlistStarted>(_onWishlistStarted);
    on<WishlistItemDeleted>(_onWishlistItemDeleted);
  }

  Future<void> _onWishlistStarted(
      WishlistStarted event,
      Emitter<WishlistState> emit,
      ) async {
    emit(WishlistLoading());
    try {
      // 1. Fetch the base wishlist items from the server API
      final List<dynamic> items = await _wishlistApiService.getWishlistItems();

      // 2. Get the locally saved SKU/size mapping from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final skuMapString = prefs.getString('wishlist_variant_skus') ?? '{}';
      final Map<String, dynamic> localSkuMap = json.decode(skuMapString);
      print('[WISHLIST BLOC] Loaded local SKU map: $localSkuMap');

      // 3. Loop through the API items and "enrich" them with our local data
      for (var item in items) {
        // Use the CORRECT KEY 'id' which you found in the raw API response.
        if (item is Map<String, dynamic> &&
            item.containsKey('product') &&
            item['product'] is Map<String, dynamic> &&
            item['product'].containsKey('id')) { // ✅ CHANGED from 'entity_id' to 'id'

          // Use the CORRECT KEY 'id' here as well.
          final String productId = item['product']['id'].toString(); // ✅ CHANGED from 'entity_id' to 'id'

          if (localSkuMap.containsKey(productId)) {
            final localData = localSkuMap[productId];
            item['product']['selected_sku'] = localData['sku'];
            item['product']['selected_size'] = localData['size'];
            // You will now see this success log in your console!
            print('[WISHLIST BLOC] MERGE SUCCESS for Product ID $productId: Size=${localData['size']}');
          } else {
            print('[WISHLIST BLOC] MERGE FAILED for Product ID $productId: Key not in local map.');
          }
        } else {
          // This else block will no longer be triggered
          print('[WISHLIST BLOC DEBUG] Item structure did not match. Item: $item');
        }
      }
      // for (var item in items) {
      //   if (item is Map<String, dynamic> &&
      //       item.containsKey('product') &&
      //       item['product'] is Map<String, dynamic> &&
      //       item['product'].containsKey('entity_id')) {
      //
      //     // The product ID from the wishlist API response
      //     final String productId = item['product']['entity_id'].toString();
      //
      //     // 4. Check if we have local data for this specific product ID
      //     if (localSkuMap.containsKey(productId)) {
      //       final localData = localSkuMap[productId];
      //
      //       // 5. Inject the local SKU and size into the product map
      //       // The UI card will read these new keys.
      //       item['product']['selected_sku'] = localData['sku'];
      //       item['product']['selected_size'] = localData['size'];
      //       print('[WISHLIST BLOC] Merged data for Product ID $productId: SKU=${localData['sku']}, Size=${localData['size']}');
      //     } else {
      //       print('[WISHLIST BLOC] No local data found for Product ID $productId');
      //     }
      //   }
      // }

      // 6. Emit the final, enriched list of items to the UI
      emit(WishlistLoaded(items));

    } on UserNotLoggedInException {
      emit(WishlistUserNotLoggedIn());
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }

  // Future<void> _onWishlistStarted(
  //     WishlistStarted event,
  //     Emitter<WishlistState> emit,
  //     ) async {
  //   emit(WishlistLoading());
  //   try {
  //     final items = await _wishlistApiService.getWishlistItems();
  //     emit(WishlistLoaded(items));
  //   } on UserNotLoggedInException {
  //     // If the user is not logged in, emit the specific state
  //     emit(WishlistUserNotLoggedIn());
  //   } catch (e) {
  //     emit(WishlistError(e.toString()));
  //   }
  // }

  Future<void> _onWishlistItemDeleted(
      WishlistItemDeleted event,
      Emitter<WishlistState> emit,
      ) async {
    try {
      final success = await _wishlistApiService.deleteWishlistItem(event.itemId);
      if (success) {
        // Refresh the list after successful deletion
        add(WishlistStarted());
      } else {
        emit(WishlistError("Failed to delete item. Please try again."));
        // To ensure the UI doesn't stay in a broken state, refetch
        add(WishlistStarted());
      }
    } on UserNotLoggedInException {
      // Handle auth error during deletion as well
      emit(WishlistUserNotLoggedIn());
    } catch (e) {
      emit(WishlistError(e.toString()));
    }
  }
}

// class WishlistBloc extends Bloc<WishlistEvent, WishlistState> {
//   final WishlistApiService _wishlistApiService;
//
//   WishlistBloc(this._wishlistApiService) : super(WishlistInitial()) {
//     // Register the event handlers
//     on<WishlistStarted>(_onWishlistStarted);
//     on<WishlistItemDeleted>(_onWishlistItemDeleted);
//   }
//
//   // Handler for when the wishlist is first requested
//   // In lib/bloc/wishlist_bloc.dart
//
// // ... other imports
//
// // In lib/bloc/wishlist_bloc.dart
//
// // ... other imports
//
// // lib/bloc/wishlist_bloc.dart
//
//   // Future<void> _onWishlistStarted(
//   //     WishlistStarted event,
//   //     Emitter<WishlistState> emit,
//   //     ) async {
//   //   emit(WishlistLoading());
//   //   try {
//   //     final apiItems = await _wishlistApiService.getWishlistItems();
//   //     final prefs = await SharedPreferences.getInstance();
//   //     final variantMapString = prefs.getString('wishlist_variant_skus') ?? '{}';
//   //     final Map<String, dynamic> variantMap = json.decode(variantMapString);
//   //
//   //     print("[BLOC READ] Retrieved full variant map from Prefs: $variantMap");
//   //
//   //     final List<dynamic> enrichedItems = [];
//   //     for (var item in apiItems) {
//   //       final Map<String, dynamic> mutableItem = Map.from(item);
//   //
//   //       // --- THE FINAL, CORRECTED FIX IS HERE ---
//   //       // 1. Safely access the nested 'product' object.
//   //       final productData = mutableItem['product'] as Map<String, dynamic>?;
//   //
//   //       // 2. Get the product's ID from WITHIN the product object using the correct key: 'id'.
//   //       final String productId = productData?['id']?.toString() ?? '';
//   //
//   //       if (productId.isNotEmpty && variantMap.containsKey(productId)) {
//   //         final Map<String, dynamic> savedVariantData = variantMap[productId];
//   //
//   //         // We already have productData, so we can make a mutable copy of it.
//   //         final Map<String, dynamic> mutableProduct = Map.from(productData ?? {});
//   //
//   //         // Inject the saved data
//   //         mutableProduct['selected_sku'] = savedVariantData['sku'];
//   //         mutableProduct['selected_size'] = savedVariantData['size'];
//   //
//   //         mutableItem['product'] = mutableProduct;
//   //         print("[BLOC ENRICH] SUCCESS: Enriched product $productId with SKU: ${savedVariantData['sku']}");
//   //       } else {
//   //         print("[BLOC ENRICH] INFO: Could not find variant info for product ID '$productId'. This is normal if this item has no size selected.");
//   //       }
//   //       enrichedItems.add(mutableItem);
//   //     }
//   //
//   //     emit(WishlistLoaded(enrichedItems));
//   //   } catch (e) {
//   //     emit(WishlistError(e.toString()));
//   //   }
//   // }
//
//   // Inside your WishlistBloc's event handler (e.g., _onWishlistStarted)
//   Future<void> _onWishlistStarted(WishlistStarted event, Emitter<WishlistState> emit) async {
//     emit(WishlistLoading());
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//
//       // Check if the token is missing
//       if (token == null || token.isEmpty) {
//         // If so, emit the new state and stop
//         emit(WishlistUserNotLoggedIn());
//         return;
//       }
//
//       // Otherwise, proceed to fetch the wishlist
//       final items = await _wishlistApiService.fetchWishlist(token); // Pass the token
//       emit(WishlistLoaded(items));
//     } catch (e) {
//       emit(WishlistError(e.toString()));
//     }
//   }
//
//
//   // Handler for when an item deletion is requested
//   Future<void> _onWishlistItemDeleted(
//       WishlistItemDeleted event,
//       Emitter<WishlistState> emit,
//       ) async {
//     // We can check if the current state is `WishlistLoaded`
//     if (state is WishlistLoaded) {
//       try {
//         final success = await _wishlistApiService.deleteWishlistItem(event.itemId);
//         if (success) {
//           // If deletion is successful, trigger a refresh of the wishlist.
//           // This is the cleanest way to ensure the UI is in sync.
//           add(WishlistStarted());
//         } else {
//           // This case is unlikely with your current API service logic but is good practice.
//           emit(WishlistError("Failed to delete item. Please try again."));
//         }
//       } catch (e) {
//         emit(WishlistError(e.toString()));
//       }
//     }
//   }
// }