// lib/screens/wishlist_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/login/view/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_event.dart';
import '../../auth/bloc/currency_state.dart';
import '../../auth/services/currency_helper.dart';
import '../../auth/services/currency_service.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../repository/wishlist_api_service.dart';
 // <-- IMPORTANT: Make sure this path is correct

// lib/screens/wishlist_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';
import '../repository/wishlist_api_service.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';
import '../repository/wishlist_api_service.dart';

import 'package:flutter/material.dart';

import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';
import '../repository/wishlist_api_service.dart';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

// lib/screens/wishlist_screen.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

import '../../shoppingbag/shopping_bag.dart'; // Assuming path is correct


class WishlistScreen1 extends StatelessWidget {




  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
          WishlistBloc(WishlistApiService())..add(WishlistStarted()),
        ),
        BlocProvider(
          create: (context) =>
          CurrencyBloc(CurrencyService())..add(FetchCurrencyData()),
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          automaticallyImplyLeading: true,
          title: const Text(
            'Wish List',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          centerTitle: true,
          actions: [
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.shopping_bag_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
                );
              },
            ),
          ],
        ),
        body: WishlistBody(),
      ),
    );
  }
}




// class WishlistScreen1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) =>
//       WishlistBloc(WishlistApiService())..add(WishlistStarted()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//           appBar: AppBar(
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             elevation: 0,
//             automaticallyImplyLeading: true, // ✅ let Flutter add back button if possible
//             title: const Text(
//               'Wish List',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//             ),
//             centerTitle: true,
//             actions: [
//               IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_outlined),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//
//         body: WishlistBody(),
//       ),
//     );
//   }
// }

// class WishlistScreen1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => WishlistBloc(WishlistApiService())..add(WishlistStarted()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0,
//           title: const Text(
//             'Wish List',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//           ),
//           centerTitle: true,
//           actions: [
//             IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//             IconButton(
//               icon: const Icon(Icons.shopping_bag_outlined),
//               onPressed: () {
//                 Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//               },
//             ),
//           ],
//         ),
//
//         // appBar: AppBar(
//         //   backgroundColor: Colors.white,
//         //   foregroundColor: Colors.black,
//         //   elevation: 0,
//         //   leading: IconButton(
//         //     icon: const Icon(Icons.arrow_back),
//         //     onPressed:(){
//         //   Navigator.push(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => AuthScreen()),
//         //   );
//         //     }
//         //     ,
//         //   ),
//         //   title: const Text('Wish List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
//         //   centerTitle: true,
//         //   actions: [
//         //     IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//         //     IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {
//         //       Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//         //     }),
//         //   ],
//         // ),
//         body: WishlistBody(),
//       ),
//     );
//   }
// }

class WishlistBody extends StatelessWidget {
  Future<void> _confirmAndRemoveItem(BuildContext context, int itemId) async {
    // ... (rest of this function is unchanged)
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Remove Item'),
        content: const Text('Are you sure you want to remove this item?'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('REMOVE')),
        ],
      ),
    );

    if (confirm == true) {
      context.read<WishlistBloc>().add(WishlistItemDeleted(itemId));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use BlocConsumer to handle both UI building and state-based actions like navigation.
    return BlocConsumer<WishlistBloc, WishlistState>(
      listener: (context, state) {
        if (state is WishlistError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred: ${state.message}'),
              backgroundColor: Colors.red.shade700,
            ),
          );
        }
        // --- NEW: Listen for the not-logged-in state ---
        if (state is WishlistUserNotLoggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to view your wishlist.'),
              backgroundColor: Colors.orange,
            ),
          );
          // Navigate to the login screen, replacing the current screen.
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => LoginScreen1()),
          );
        }
      },
      builder: (context, state) {
        if (state is WishlistInitial || state is WishlistLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // --- NEW: Build a specific UI for not-logged-in users ---
        if (state is WishlistUserNotLoggedIn) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.login_rounded, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'You are not logged in',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Log in to see your saved items and enjoy a personalized shopping experience.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginScreen1()),
                      );
                    },
                    child: const Text('GO TO LOGIN'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is WishlistLoaded) {
          final items = state.wishlistItems;
          if (items.isEmpty) {
            return const Center(child: Text('Your wishlist is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          // --- This is the original UI for a loaded wishlist ---
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  children: [
                    Text("Wish List (${items.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.black12),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 12.0, mainAxisSpacing: 16.0, childAspectRatio: 0.55,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = item['product'] as Map<String, dynamic>? ?? {};
                    final int itemId = int.tryParse(item['wishlist_item_id']?.toString() ?? '') ?? 0;

                    return _WishlistItemCard(
                      product: product,
                      itemId: itemId,
                      onRemove: () => _confirmAndRemoveItem(context, itemId),
                    );
                  },
                ),
              ),
            ],
          );
        }

        if (state is WishlistError) {
          return Center(child: Text('Failed to load wishlist: ${state.message}'));
        }

        return const Center(child: Text('Something went wrong.'));
      },
    );
  }
}


// _WishlistItemCard remains unchanged
// ... (Previous code remains unchanged)

// ... (Previous code remains unchanged)

class _WishlistItemCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final int itemId;
  final VoidCallback onRemove;

  const _WishlistItemCard({
    Key? key,
    required this.product,
    required this.itemId,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<_WishlistItemCard> createState() => _WishlistItemCardState();
}


class _WishlistItemCardState extends State<_WishlistItemCard> {
  bool _isAddingToCart = false;

  // -------------------- Helper Methods --------------------
  double getConvertedPrice(num? basePrice, num? wishlistConvertedPrice, CurrencyState currencyState) {
    double price = basePrice?.toDouble() ?? 0.0;

    // If wishlist item has saved converted price, use it
    if (wishlistConvertedPrice != null) {
      price = wishlistConvertedPrice.toDouble();
    } else if (currencyState is CurrencyLoaded) {
      // Otherwise, apply current currency conversion
      price *= currencyState.selectedRate.rate;
    }
    return price;
  }

  String getCurrencySymbol(CurrencyState currencyState) {
    if (currencyState is CurrencyLoaded) {
      return currencyState.selectedSymbol;
    }
    return '₹';
  }

  Future<void> _handleAddToCart(String simpleSku) async {
    setState(() => _isAddingToCart = true);
    HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
    IOClient ioClient = IOClient(httpClient);

    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');
      if (customerToken == null || customerToken.isEmpty) throw Exception('User not logged in.');

      // Get or create quoteId
      String? quoteId;
      try {
        final cartResponse = await ioClient.get(
          Uri.parse('https://aashniandco.com/rest/V1/carts/mine'),
          headers: {'Authorization': 'Bearer $customerToken'},
        );
        if (cartResponse.statusCode == 200) {
          quoteId = json.decode(cartResponse.body)['id'].toString();
        } else {
          throw Exception();
        }
      } catch (_) {
        final createCartResponse = await ioClient.post(
          Uri.parse('https://aashniandco.com/rest/V1/carts/mine'),
          headers: {'Authorization': 'Bearer $customerToken'},
        );
        if (createCartResponse.statusCode == 200) {
          quoteId = json.decode(createCartResponse.body).toString();
        } else {
          throw Exception('Error creating cart.');
        }
      }
      if (quoteId == null) throw Exception('Could not get or create a cart.');

      // Add to cart
      final addToCartResponse = await ioClient.post(
        Uri.parse('https://aashniandco.com/rest/V1/carts/mine/items'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
        body: json.encode({"cartItem": {"sku": simpleSku, "qty": 1, "quote_id": quoteId}}),
      );

      if (addToCartResponse.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product added to cart")));
        Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
      } else {
        throw Exception('Failed to add product to cart: ${addToCartResponse.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isAddingToCart = false);
    }
  }

  void _initiateAddToCart() {
    if (_isAddingToCart) return;
    final simpleSku = widget.product['selected_sku']?.toString();
    if (simpleSku == null || simpleSku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add this item to wishlist again with a size selected.')));
      return;
    }
    _handleAddToCart(simpleSku);
  }

  // -------------------- Build Method --------------------
  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;

    const String mediaBaseUrl = "https://aashniandco.com/pub/media/catalog/product";
    final String imagePath = widget.product['image']?.toString() ?? '';
    final String imageUrl = imagePath.isNotEmpty ? '$mediaBaseUrl$imagePath' : 'https://via.placeholder.com/150';
    final String color = widget.product['color']?.toString() ?? 'Beige';
    final String skuToDisplay = widget.product['selected_sku']?.toString() ?? 'SKU not available';
    final bool isNetSustain = widget.product['is_net_sustain'] == true;

    // -------------------- Converted Price --------------------
    final basePrice = widget.product['price'] as num?;
    final wishlistConvertedPrice = widget.product['converted_price'] as num?; // From wishlist
    final displayPrice = getConvertedPrice(basePrice, wishlistConvertedPrice, currencyState);
    final displaySymbol = getCurrencySymbol(currencyState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product['name']?.toString() ?? 'Unnamed Product', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700])),
                  Text(color, style: TextStyle(color: Colors.grey[700])),
                  Text(skuToDisplay, style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(
                    '$displaySymbol${displayPrice.toStringAsFixed(0)}', // Show converted price
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (isNetSustain)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(border: Border.all(color: Colors.green.shade700), borderRadius: BorderRadius.circular(4)),
                      child: Text('Net Sustain', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            icon: _isAddingToCart
                ? Container(width: 18, height: 18, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.shopping_bag_outlined, size: 18),
            label: Text(_isAddingToCart ? 'ADDING...' : 'Add to Bag'),
            onPressed: _isAddingToCart ? null : _initiateAddToCart,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black54),
            ),
          ),
        ),
      ],
    );
  }
}



// class _WishlistItemCardState extends State<_WishlistItemCard> {
//   bool _isAddingToCart = false;
//
//
//   Future<void> _handleAddToCart(String simpleSku) async {
//     setState(() {
//       _isAddingToCart = true;
//     });
//     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final customerToken = prefs.getString('user_token');
//       if (customerToken == null || customerToken.isEmpty) throw Exception('User not logged in.');
//
//       String? quoteId;
//       try {
//         final cartResponse = await ioClient.get(
//           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
//           headers: {'Authorization': 'Bearer $customerToken'},
//         );
//         if (cartResponse.statusCode == 200) {
//           quoteId = json.decode(cartResponse.body)['id'].toString();
//         } else {
//           throw Exception();
//         }
//       } catch (e) {
//         final createCartResponse = await ioClient.post(
//           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
//           headers: {'Authorization': 'Bearer $customerToken'},
//         );
//         if (createCartResponse.statusCode == 200) {
//           quoteId = json.decode(createCartResponse.body).toString();
//         } else {
//           throw Exception('Error creating cart.');
//         }
//       }
//       if (quoteId == null) throw Exception('Could not get or create a cart.');
//
//       final addToCartResponse = await ioClient.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
//         body: json.encode({"cartItem": {"sku": simpleSku, "qty": 1, "quote_id": quoteId}}),
//       );
//
//       if (addToCartResponse.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product added to cart")));
//         Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//       } else {
//         throw Exception('Failed to add product to cart: ${addToCartResponse.body}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isAddingToCart = false;
//         });
//       }
//     }
//   }
//
//   void _initiateAddToCart() {
//     if (_isAddingToCart) return;
//     final String? simpleSku = widget.product['selected_sku']?.toString();
//     if (simpleSku == null || simpleSku.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add this item to wishlist again with a size selected.')));
//       return;
//     }
//     _handleAddToCart(simpleSku);
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Watch for currency state changes
//
//
//     final currencyState = context.watch<CurrencyBloc>().state;
//
//     const String mediaBaseUrl = "https://stage.aashniandco.com/pub/media/catalog/product";
//     final String imagePath = widget.product['image']?.toString() ?? '';
//     final String imageUrl = imagePath.isNotEmpty ? '$mediaBaseUrl$imagePath' : 'https://via.placeholder.com/150';
//     final String color = widget.product['color']?.toString() ?? 'Beige';
//     final String selectedSize = widget.product['selected_size']?.toString() ?? 'N/A';
//
//     final String skuToDisplay = widget.product['selected_sku']?.toString() ?? 'SKU not available';
//     final bool isNetSustain = widget.product['is_net_sustain'] == true;
//
//     // Default currency values
//     String displaySymbol = '₹';
//     double displayPrice = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
//
//     print("displayPrice$displayPrice");
//     // Apply currency conversion if CurrencyLoaded state is available
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       double basePrice = (widget.product['price'] as num?)?.toDouble() ?? 0.0;
//       double rate = currencyState.selectedRate.rate;
//       displayPrice = basePrice * rate;
//
//       print("displayPrice after conversion$displayPrice");
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//               height: 200,
//               width: double.infinity,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 height: 200,
//                 width: double.infinity,
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//               ),
//             ),
//             Positioned(
//               top: 4,
//               right: 4,
//               child: GestureDetector(
//                 onTap: widget.onRemove,
//                 child: Container(
//                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
//                   child: const Icon(Icons.close, size: 20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.product['name']?.toString() ?? 'Unnamed Product',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   Text(color, style: TextStyle(color: Colors.grey[700])),
//
//                   Text(
//                     skuToDisplay,
//                     style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
//                   ),
//
//                   const SizedBox(height: 4),
//                   Text(
//                     '$displaySymbol${displayPrice.toStringAsFixed(0)}', // Use the converted price and symbol
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   if (isNetSustain)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(border: Border.all(color: Colors.green.shade700), borderRadius: BorderRadius.circular(4)),
//                       child: Text('Net Sustain', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             icon: _isAddingToCart
//                 ? Container(width: 18, height: 18, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
//                 : const Icon(Icons.shopping_bag_outlined, size: 18),
//             label: Text(_isAddingToCart ? 'ADDING...' : 'Add to Bag'),
//             onPressed: _isAddingToCart ? null : _initiateAddToCart,
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.black,
//               side: const BorderSide(color: Colors.black54),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class WishlistScreen1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => WishlistBloc(
//         WishlistApiService(),
//       )..add(WishlistStarted()),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0,
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: const Text('Wish List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
//           centerTitle: true,
//           actions: [
//             IconButton(icon: const Icon(Icons.search), onPressed: () {}),
//             IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//             }),
//           ],
//         ),
//         body: WishlistBody(),
//       ),
//     );
//   }
// }
//
// class WishlistBody extends StatelessWidget {
//   Future<void> _confirmAndRemoveItem(BuildContext context, int itemId) async {
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('Remove Item'),
//         content: const Text('Are you sure you want to remove this item?'),
//         actions: <Widget>[
//           TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
//           TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('REMOVE')),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       context.read<WishlistBloc>().add(WishlistItemDeleted(itemId));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<WishlistBloc, WishlistState>(
//       listener: (context, state) {
//         if (state is WishlistError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('An error occurred: ${state.message}'),
//               backgroundColor: Colors.red.shade700,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is WishlistInitial || state is WishlistLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state is WishlistLoaded) {
//           final items = state.wishlistItems;
//           if (items.isEmpty) {
//             return const Center(child: Text('Your wishlist is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)));
//           }
//
//           return Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                 child: Row(
//                   children: [
//                     Text("Wish List (${items.length})", style: const TextStyle(fontWeight: FontWeight.bold)),
//                     const Icon(Icons.arrow_drop_down),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Colors.black12),
//               Expanded(
//                 child: GridView.builder(
//                   padding: const EdgeInsets.all(12.0),
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2, crossAxisSpacing: 12.0, mainAxisSpacing: 16.0, childAspectRatio: 0.55,
//                   ),
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final item = items[index];
//                     final product = item['product'] as Map<String, dynamic>? ?? {};
//                     final int itemId = int.tryParse(item['wishlist_item_id']?.toString() ?? '') ?? 0;
//
//                     return _WishlistItemCard(
//                       product: product,
//                       itemId: itemId,
//                       onRemove: () => _confirmAndRemoveItem(context, itemId),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         }
//
//         if (state is WishlistError) {
//           return Center(child: Text('Failed to load wishlist: ${state.message}'));
//         }
//
//         return const Center(child: Text('Something went wrong.'));
//       },
//     );
//   }
// }
//
// class _WishlistItemCard extends StatefulWidget {
//   final Map<String, dynamic> product;
//   final int itemId;
//   final VoidCallback onRemove;
//
//   const _WishlistItemCard({
//     Key? key,
//     required this.product,
//     required this.itemId,
//     required this.onRemove,
//   }) : super(key: key);
//
//   @override
//   State<_WishlistItemCard> createState() => _WishlistItemCardState();
// }
//
// class _WishlistItemCardState extends State<_WishlistItemCard> {
//   bool _isAddingToCart = false;
//
//   Future<void> _handleAddToCart(String simpleSku) async {
//     setState(() { _isAddingToCart = true; });
//     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final customerToken = prefs.getString('user_token');
//       if (customerToken == null || customerToken.isEmpty) throw Exception('User not logged in.');
//
//       String? quoteId;
//       try {
//         final cartResponse = await ioClient.get(
//           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
//           headers: {'Authorization': 'Bearer $customerToken'},
//         );
//         if (cartResponse.statusCode == 200) {
//           quoteId = json.decode(cartResponse.body)['id'].toString();
//         } else { throw Exception(); }
//       } catch (e) {
//         final createCartResponse = await ioClient.post(
//           Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine'),
//           headers: {'Authorization': 'Bearer $customerToken'},
//         );
//         if (createCartResponse.statusCode == 200) {
//           quoteId = json.decode(createCartResponse.body).toString();
//         } else { throw Exception('Error creating cart.'); }
//       }
//       if (quoteId == null) throw Exception('Could not get or create a cart.');
//
//       final addToCartResponse = await ioClient.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/carts/mine/items'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $customerToken'},
//         body: json.encode({"cartItem": {"sku": simpleSku, "qty": 1, "quote_id": quoteId}}),
//       );
//
//       if (addToCartResponse.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Product added to cart")));
//         Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
//       } else {
//         throw Exception('Failed to add product to cart: ${addToCartResponse.body}');
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
//     } finally {
//       if (mounted) {
//         setState(() { _isAddingToCart = false; });
//       }
//     }
//   }
//
//   void _initiateAddToCart() {
//     if (_isAddingToCart) return;
//     final String? simpleSku = widget.product['selected_sku']?.toString();
//     if (simpleSku == null || simpleSku.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add this item to wishlist again with a size selected.')));
//       return;
//     }
//     _handleAddToCart(simpleSku);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     const String mediaBaseUrl = "https://stage.aashniandco.com/pub/media/catalog/product";
//     final String imagePath = widget.product['image']?.toString() ?? '';
//     final String imageUrl = imagePath.isNotEmpty ? '$mediaBaseUrl$imagePath' : 'https://via.placeholder.com/150';
//     final String color = widget.product['color']?.toString() ?? 'Beige';
//
//     final String simpleSkuToDisplay = widget.product['selected_sku']?.toString() ?? 'Select size on PDP';
//
//     final bool isNetSustain = widget.product['is_net_sustain'] == true;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Stack(
//           children: [
//             Image.network(
//               imageUrl, fit: BoxFit.cover, height: 200, width: double.infinity,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 height: 200, width: double.infinity, color: Colors.grey[200],
//                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//               ),
//             ),
//             Positioned(
//               top: 4, right: 4,
//               child: GestureDetector(
//                 onTap: widget.onRemove,
//                 child: Container(
//                   decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
//                   child: const Icon(Icons.close, size: 20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.product['name']?.toString() ?? 'Unnamed Product',
//                     maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   Text(color, style: TextStyle(color: Colors.grey[700])),
//
//                   Text(
//                     simpleSkuToDisplay,
//                     style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold),
//                   ),
//
//                   const SizedBox(height: 4),
//                   Text(
//                     '₹${widget.product['price']?.toString() ?? '0.00'}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   if (isNetSustain)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(border: Border.all(color: Colors.green.shade700), borderRadius: BorderRadius.circular(4)),
//                       child: Text('Net Sustain', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             icon: _isAddingToCart
//                 ? Container(width: 18, height: 18, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
//                 : const Icon(Icons.shopping_bag_outlined, size: 18),
//             label: Text(_isAddingToCart ? 'ADDING...' : 'Add to Bag'),
//             onPressed: _isAddingToCart ? null : _initiateAddToCart,
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.black, side: const BorderSide(color: Colors.black54),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// class WishlistScreen1 extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => WishlistBloc(WishlistApiService())..add(WishlistStarted()),
//       child: Scaffold(
//         // Set background color to white to match the design
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           // 1. UPDATED APPBAR
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0, // Remove shadow for a flatter look
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: const Text(
//             'Wish List',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
//           ),
//           centerTitle: true,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 // TODO: Implement search functionality
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.shopping_bag_outlined),
//               onPressed: () {
//                 // TODO: Implement navigation to shopping bag
//               },
//             ),
//           ],
//         ),
//         body: WishlistBody(),
//       ),
//     );
//   }
// }
//
// class WishlistBody extends StatelessWidget {
//   Future<void> _confirmAndRemoveItem(BuildContext context, int itemId) async {
//     // This dialog logic remains the same
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('Remove Item'),
//         content: const Text('Are you sure you want to remove this item?'),
//         actions: <Widget>[
//           TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('CANCEL')),
//           TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('REMOVE')),
//         ],
//       ),
//     );
//
//     if (confirm == true) {
//       context.read<WishlistBloc>().add(WishlistItemDeleted(itemId));
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<WishlistBloc, WishlistState>(
//       listener: (context, state) {
//         if (state is WishlistError) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Failed to perform action: ${state.message}'),
//               backgroundColor: Colors.red.shade700,
//             ),
//           );
//         }
//       },
//       builder: (context, state) {
//         if (state is WishlistInitial || state is WishlistLoading) {
//           return const Center(child: CircularProgressIndicator());
//         }
//
//         if (state is WishlistLoaded) {
//           final items = state.wishlistItems;
//
//           if (items.isEmpty) {
//             return const Center(child: Text('Your wishlist is empty.', style: TextStyle(fontSize: 18, color: Colors.grey)));
//           }
//
//           // 2. WRAP EVERYTHING IN A COLUMN TO ADD THE SUB-HEADER
//           return Column(
//             children: [
//               // 3. SUB-HEADER WIDGET
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           "Wish List (${items.length})", // Dynamic item count
//                           style: const TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         const Icon(Icons.arrow_drop_down),
//                       ],
//                     ),
//                     // IconButton(
//                     //   icon: const Icon(Icons.notifications_none_outlined),
//                     //   onPressed: () {
//                     //     // TODO: Implement notifications functionality
//                     //   },
//                     // ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Colors.black12),
//               // 4. GRIDVIEW TAKES THE REMAINING SPACE
//               Expanded(
//                 child: GridView.builder(
//                   padding: const EdgeInsets.all(12.0),
//                   // 5. CONFIGURE THE GRID
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,         // Two columns
//                     crossAxisSpacing: 12.0,    // Spacing between columns
//                     mainAxisSpacing: 16.0,     // Spacing between rows
//                     childAspectRatio: 0.55,    // Adjust aspect ratio for card height
//                   ),
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     // Extract data safely
//                     final item = items[index];
//                     if (item is! Map<String, dynamic>) {
//                       return const Center(child: Text("Invalid"));
//                     }
//                     final product = item['product'] as Map<String, dynamic>? ?? {};
//                     final int itemId = int.tryParse(item['wishlist_item_id']?.toString() ?? '') ?? 0;
//
//                     // 6. BUILD THE NEW GRID ITEM CARD
//                     return _buildGridItemCard(context, product, itemId);
//                   },
//                 ),
//               ),
//             ],
//           );
//         }
//
//         if (state is WishlistError) {
//           return Center(child: Text('Error: ${state.message}'));
//         }
//
//         return const Center(child: Text('Something went wrong.'));
//       },
//     );
//   }
//
//   // 7. NEW WIDGET FOR THE GRID ITEM CARD
//   // In lib/screens/wishlist_screen.dart -> class WishlistBody
//
// // Replace the old method with this new, corrected one.
//   // In lib/screens/wishlist_screen.dart -> class WishlistBody
//
//   Widget _buildGridItemCard(BuildContext context, Map<String, dynamic> product, int itemId) {
//     const String mediaBaseUrl = "https://stage.aashniandco.com/pub/media/catalog/product";
//     final String imagePath = product['image']?.toString() ?? '';
//     final String imageUrl = imagePath.isNotEmpty ? '$mediaBaseUrl$imagePath' : 'https://via.placeholder.com/150';
//
//     final String brand = product['brand']?.toString().toUpperCase() ?? 'BRAND';
//     final String color = product['color']?.toString() ?? 'Beige';
//     final String size = product['size']?.toString() ?? 'One size';
//     final bool isNetSustain = product['is_net_sustain'] == true;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 1. IMAGE (Fixed Height) - No changes here
//         Stack(
//           children: [
//             Image.network(
//               imageUrl,
//               fit: BoxFit.cover,
//               height: 200,
//               width: double.infinity,
//
//               errorBuilder: (context, error, stackTrace) => Container(
//                 height: 200,
//                 width: 200,
//                 color: Colors.grey[200],
//                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//               ),
//             ),
//             Positioned(
//               top: 4,
//               right: 4,
//               child: GestureDetector(
//                 onTap: () => _confirmAndRemoveItem(context, itemId),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.8),
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(Icons.close, size: 20),
//                 ),
//               ),
//             ),
//           ],
//         ),
//
//         // 2. MIDDLE CONTENT (Now scrollable)
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
//             // **** THE FIX IS HERE ****
//             // Wrap the inner Column with a SingleChildScrollView
//             child: SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   // Text(
//                   //   brand,
//                   //   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                   // ),
//                   Text(
//                     product['name']?.toString() ?? 'Unnamed Product',
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(color: Colors.grey[700]),
//                   ),
//                   Text(color, style: TextStyle(color: Colors.grey[700])),
//                   // Text('Size: $size', style: TextStyle(color: Colors.grey[700])),
//                   const SizedBox(height: 4),
//                   Text(
//                     '₹${product['price']?.toString() ?? '0.00'}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   if (isNetSustain)
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.green.shade700),
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         'Net Sustain',
//                         style: TextStyle(color: Colors.green.shade700, fontSize: 12),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//
//         // 3. BOTTOM BUTTON (Fixed Height) - No changes here
//         SizedBox(
//           width: double.infinity,
//           child: OutlinedButton.icon(
//             icon: const Icon(Icons.shopping_bag_outlined, size: 18),
//             label: const Text('Add to Bag'),
//             onPressed: () {
//               // TODO: Implement Add to Bag functionality
//             },
//             style: OutlinedButton.styleFrom(
//               foregroundColor: Colors.black,
//               side: const BorderSide(color: Colors.black54),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
// class WishlistScreen1 extends StatefulWidget {
//   @override
//   WishlistScreen1State createState() => WishlistScreen1State();
// }
//
// class WishlistScreen1State extends State<WishlistScreen1> {
//   final WishlistApiService _apiService = WishlistApiService();
//   late Future<List<dynamic>> _wishlistFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadWishlist();
//   }
//
//   // Reloads the wishlist data from the API
//   void _loadWishlist() {
//     setState(() {
//       _wishlistFuture = _apiService.getWishlistItems();
//     });
//   }
//
//   // Handles the logic for removing an item
//   Future<void> _removeItem(int itemId) async {
//     // Show a confirmation dialog before deleting
//     final bool? confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) => AlertDialog(
//         title: const Text('Remove Item'),
//         content: const Text('Are you sure you want to remove this item from your wishlist?'),
//         actions: <Widget>[
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('CANCEL'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('REMOVE'),
//           ),
//         ],
//       ),
//     );
//
//     // If the user did not confirm, do nothing.
//     if (confirm != true) {
//       return;
//     }
//
//     // If confirmed, proceed with deletion.
//     try {
//       final success = await _apiService.deleteWishlistItem(itemId);
//       if (success) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Item removed from wishlist')),
//         );
//         // Refresh the list to show the item has been removed
//         _loadWishlist();
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to remove item: ${e.toString()}')),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Wishlist'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 1,
//       ),
//       body: FutureBuilder<List<dynamic>>(
//         future: _wishlistFuture,
//         builder: (context, snapshot) {
//           // 1. Show a loading indicator while fetching data
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//
//           // 2. Show an error message if the fetch failed
//           if (snapshot.hasError) {
//             return Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Text(
//                   'Error loading wishlist: ${snapshot.error}',
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             );
//           }
//
//           // 3. Ensure the data exists and is a List
//           if (!snapshot.hasData || snapshot.data is! List) {
//             return const Center(
//               child: Text(
//                 'Your wishlist is empty or the data is invalid.',
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           }
//
//           final List<dynamic> items = snapshot.data!;
//
//           // 4. Show a message if the list is empty
//           if (items.isEmpty) {
//             return const Center(
//               child: Text(
//                 'Your wishlist is empty.',
//                 style: TextStyle(fontSize: 18, color: Colors.grey),
//               ),
//             );
//           }
//
//           // 5. Build the list of wishlist items
//           return ListView.builder(
//             itemCount: items.length,
//             itemBuilder: (context, index) {
//               // Get the item at the current index.
//               // It's expected to be a Map.
//               final item = items[index];
//               if (item is! Map<String, dynamic>) {
//                 // If an item in the list isn't a Map, show an error for that item.
//                 return const ListTile(title: Text("Invalid item format"));
//               }
//
//               // Safely extract product data.
//               final product = item['product'] as Map<String, dynamic>? ?? {};
//
//               // SAFELY PARSE THE ITEM ID from String to int. THIS IS THE CRITICAL FIX.
//               final dynamic rawItemId = item['wishlist_item_id'];
//               final int itemId = int.tryParse(rawItemId?.toString() ?? '') ?? 0;
//
//               // Construct the full image URL.
//               const String mediaBaseUrl = "https://stage.aashniandco.com/pub/media/catalog/product";
//               final String imagePath = product['image']?.toString() ?? '';
//               final String imageUrl = imagePath.isNotEmpty
//                   ? '$mediaBaseUrl$imagePath'
//                   : 'https://via.placeholder.com/150'; // Fallback image
//
//               return Card(
//                 margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                 elevation: 2,
//                 child: Padding(
//                   padding: const EdgeInsets.all(12.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Product Image
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(8.0),
//                         child: Image.network(
//                           imageUrl,
//                           width: 100,
//                           height: 120,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) =>
//                               Container(
//                                 width: 100,
//                                 height: 120,
//                                 color: Colors.grey[200],
//                                 child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                               ),
//                         ),
//                       ),
//                       const SizedBox(width: 15),
//                       // Product Details
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               product['name']?.toString() ?? 'Unnamed Product',
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 fontSize: 16,
//                               ),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                             const SizedBox(height: 5),
//                             Text(
//                               'SKU: ${product['sku']?.toString() ?? 'N/A'}',
//                               style: TextStyle(color: Colors.grey[600], fontSize: 13),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               '₹${product['price']?.toString() ?? '0.00'}',
//                               style: const TextStyle(
//                                 fontSize: 16,
//                                 color: Colors.black,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       // Delete Button
//                       IconButton(
//                         icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
//                         onPressed: () {
//                           // Ensure we don't try to delete an item with an invalid ID
//                           if (itemId > 0) {
//                             _removeItem(itemId);
//                           } else {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('Cannot remove item: Invalid ID.')),
//                             );
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }