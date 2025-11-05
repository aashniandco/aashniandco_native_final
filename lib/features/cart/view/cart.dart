//

// 🛒 CartScreen.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> cartItems = [];
  bool isLoading = false;
  final String baseUrl = 'https://stage.aashniandco.com';

  @override
  void initState() {
    super.initState();
    loadCartAndSync();
    checkTokenValidity();
    _fetchMagentoCartItems();
  }

  // void _fetchMagentoCartItems() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final token = prefs.getString('user_token');
  //   if (token != null) {
  //     try {
  //       final items = await getMagentoCartItems(token);
  //       print("Magento Cart Items: $items");
  //     } catch (e) {
  //       print("Error fetching Magento cart items: $e");
  //     }
  //   } else {
  //     print("No user token found");
  //   }
  // }

  void _fetchMagentoCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    if (token != null) {
      try {
        final items = await getMagentoCartItems(token);
        print("Magento Cart Items>>>: $items");

        setState(() {
          cartItems = items.map<Map<String, dynamic>>((item) {
            return {
              'item_id': item['item_id'],
              'quantity': item['qty'],
              'actualPrice': item['price'],
              'prodSmallImg': baseUrl + "/media/catalog/product" + (item['product']['custom_attributes']?.firstWhere((attr) => attr['attribute_code'] == 'small_image', orElse: () => {})?['value'] ?? ''),
              'designer_name': item['name'] ?? '',
              'shortDesc': item['product_type'] ?? '',
            };
          }).toList();
        });
      } catch (e) {
        print("Error fetching Magento cart items: $e");
      }
    } else {
      print("No user token found");
    }
  }


  Future<List<dynamic>> getMagentoCartItems(String token) async {
    final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items');
    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
    final response = await client.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (response.statusCode == 200) {
      return json.decode(response.body) as List<dynamic>;
    } else {
      throw Exception("Failed to fetch cart items");
    }
  }

  Future<void> checkTokenValidity() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');

    if (token == null) {
      print("No user token found");
      return;
    }

    bool valid = await isTokenValid(token);
    print('Is token valid? $valid');
  }

  Future<void> loadCartAndSync() async {
    await loadLocalCartItems();
    await pushLocalCartToMagento();
  }

  Future<void> loadLocalCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final cartStringList = prefs.getStringList('cartItems') ?? [];

    final items = cartStringList
        .map((e) => json.decode(e) as Map<String, dynamic>)
        .map((item) {
      item['quantity'] ??= 1;
      return item;
    }).toList();

    setState(() {
      cartItems = items;
    });
  }

  Future<void> saveCartItems() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedItems = cartItems.map((e) => json.encode(e)).toList();
    await prefs.setStringList('cartItems', encodedItems);
  }

  Future<String> createOrFetchCartId(String token) async {
    final url = Uri.parse('$baseUrl/rest/V1/carts/mine');
    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);

    final response = await client.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body).toString();
    } else {
      throw Exception("Failed to get Magento cart ID");
    }
  }

  Future<Map<String, dynamic>> addItemToMagentoCart({
    required String token,
    required String cartId,
    required String sku,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items');
    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);

    final body = jsonEncode({
      "cartItem": {
        "sku": sku,
        "qty": quantity,
        "quote_id": cartId,
      }
    });

    print("cart item_id$cartId");

    final response = await client.post(
      url,
      headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Contains item_id
    } else {
      throw Exception("Failed to add item $sku to Magento cart");
    }
  }

  Future<void> updateCartItemQtyMagento({
    required String token,
    required int itemId,
    required String sku,
    required int quantity,
  }) async {
    final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items/$itemId');

    final httpClient = HttpClient()
      ..badCertificateCallback = (cert, host, port) => true;
    final client = IOClient(httpClient);

    final body = jsonEncode({
      "cartItem": {
        "item_id": itemId,
        "sku": sku,
        "qty": quantity,
      }
    });

    try {
      final response = await client.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      if (response.statusCode != 200) {
        // Optionally decode response.body for error details
        final responseBody = response.body;
        throw Exception("Failed to update item $sku. Status: ${response.statusCode}. Response: $responseBody");
      }
    } finally {
      client.close();
    }
  }




  // Future<void> deleteCartItemMagento({
  //     required String token,
  //     required int itemId,
  //   }) async {
  //     final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items/$itemId');
  //     print("delete method url:$url");
  //     final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
  //
  //     final response = await client.delete(
  //       url,
  //       headers: {
  //         'Authorization': 'Bearer $token',
  //         'Content-Type': 'application/json',
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print("Item $itemId deleted successfully from cart.");
  //     } else {
  //       print("Error deleting item: ${response.statusCode} - ${response.body}");
  //       throw Exception("Failed to delete cart item $itemId");
  //     }
  //   }

  Future<void> deleteCartItemMagento({
    required String token,
    required int itemId,
  }) async {
    final valid = await isTokenValid(token);
    if (!valid) {
      throw Exception("Token is invalid or expired.");
    }

    final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items/$itemId');
    print("delete method url:$url");
    final client = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);

    final response = await client.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("Item $itemId deleted successfully from cart.");
    } else {
      print("Error deleting item: ${response.statusCode} - ${response.body}");
      throw Exception("Failed to delete cart item $itemId");
    }
  }



  Future<void> pushLocalCartToMagento() async {
    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('user_token');
      print("token>>>$token");

      if (token == null || cartItems.isEmpty) return;

      final cartId = await createOrFetchCartId(token);

      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final sku = item['childSku'] ?? item['sku'];
        final qty = item['quantity'] ?? 1;

        final response = await addItemToMagentoCart(
          token: token,
          cartId: cartId,
          sku: sku,
          quantity: qty,
        );

        cartItems[i]['item_id'] = response['item_id'];
      }

      await saveCartItems();

      // ✅ Wait 5 seconds before clearing local cart
      Future.delayed(const Duration(seconds: 30), () async {
        setState(() {
          cartItems.clear();
        });
        await prefs.remove('cartItems');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cart synced with Magento and local cart cleared")),
          );
        }
      });
    } catch (e) {
      debugPrint('Error syncing cart: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }



  void updateQuantity(int index, int delta) async {
    if (isLoading) return; // Prevent multiple taps

    final item = cartItems[index];
    final itemId = item['item_id'];
    final sku = item['childSku'] ?? item['sku']; // <-- SKU here
    final currentQty = item['quantity'] ?? 1;
    final newQty = (currentQty + delta).clamp(1, 999);

    if (itemId == null) {
      debugPrint('item_id missing for item $sku. Cannot update quantity.');
      return;
    }

    setState(() {
      isLoading = true;
      cartItems[index]['quantity'] = newQty; // Optimistic UI update
    });

    try {
      final prefs = await SharedPreferences.getInstance();

      final token = prefs.getString('user_token');
      print("token update method>>$token");
      if (token == null) throw Exception("User token missing");

      // Pass sku here as well
      await updateCartItemQtyMagento(
        token: token,
        itemId: itemId,
        sku: sku,
        quantity: newQty,
      );

      await saveCartItems();
    } catch (e) {
      debugPrint('Error updating qty: $e');

      // Revert UI on error
      setState(() {
        cartItems[index]['quantity'] = currentQty;
      });
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<bool> isTokenValid(String token) async {
    final url = Uri.parse('$baseUrl/rest/V1/customers/me');

    final httpClient = IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true);
    final response = await httpClient.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    return response.statusCode == 200;
  }





  void removeItem(int index) async {
    if (isLoading) return; // Prevent multiple taps
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('user_token');
    print("Tok>>$token");
    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final itemId = cartItems[index]['item_id'];
      if (itemId == null) {
        debugPrint('item_id missing for removal at index $index');
        setState(() => isLoading = false);
        return;
      }
      await deleteCartItemMagento(token: token, itemId: itemId);

      setState(() => cartItems.removeAt(index));
      await saveCartItems();
    } catch (e) {
      debugPrint('Error removing item: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Widget buildCartItem(Map<String, dynamic> product, int index) {
    final quantity = product['quantity'] ?? 1;
    final price = double.tryParse(product['actualPrice']?.toString() ?? '') ?? 0.0;
    final subtotal = price * quantity;

    return Container(
      key: ValueKey(product['item_id'] ?? index),  // Unique key per item
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              product['prodSmallImg'] ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['designer_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(product['shortDesc'] ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Text('₹ ${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => updateQuantity(index, -1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text(
                      quantity.toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      onPressed: () => updateQuantity(index, 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => removeItem(index),
                      icon: const Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
                Text('Subtotal: ₹ ${subtotal.toStringAsFixed(2)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = cartItems.fold<double>(
      0,
          (sum, item) {
        final price = double.tryParse(item['actualPrice']?.toString() ?? '') ?? 0.0;
        final qty = item['quantity'] ?? 1;
        return sum + price * qty;
      },
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: isLoading && cartItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return buildCartItem(cartItems[index], index);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total: ₹ ${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ElevatedButton(
                  onPressed: () {
                    // Proceed to checkout or next step
                  },
                  child: const Text("Checkout"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}




// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/io_client.dart';
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({Key? key}) : super(key: key);
//
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   List<Map<String, dynamic>> cartItems = [];
//   bool isLoading = false;
//
//   final String baseUrl = 'https://stage.aashniandco.com';
//
//   @override
//   void initState() {
//     super.initState();
//     loadLocalCartItems();
//   }
//
//   Future<void> loadLocalCartItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartStringList = prefs.getStringList('cartItems') ?? [];
//     final items = cartStringList
//         .map((e) => json.decode(e) as Map<String, dynamic>)
//         .toList();
//     setState(() {
//       cartItems = items;
//     });
//   }
//
//   Future<String> createOrFetchCartId(String token) async {
//     final url = Uri.parse('$baseUrl/rest/V1/carts/mine');
//     final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     final ioClient = IOClient(httpClient);
//
//     final response = await ioClient.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );
//
//     if (response.statusCode == 200) {
//       return json.decode(response.body).toString();
//     } else {
//       throw Exception("Failed to get Magento cart ID");
//     }
//   }
//
//   Future<void> addItemToMagentoCart({
//     required String token,
//     required String cartId,
//     required String sku,
//     required int quantity,
//   }) async {
//     final url = Uri.parse('$baseUrl/rest/V1/carts/mine/items');
//     final httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//     final ioClient = IOClient(httpClient);
//
//     final body = jsonEncode({
//       "cartItem": {
//         "sku": sku,
//         "qty": quantity,
//         "quote_id": cartId,
//       }
//     });
//
//     final response = await ioClient.post(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//       body: body,
//     );
//
//     if (response.statusCode != 200) {
//       throw Exception("Failed to add item $sku to Magento cart");
//     }
//   }
//
//   Future<void> pushLocalCartToMagento() async {
//     setState(() {
//       isLoading = true;
//     });
//
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('user_token');
//
//       if (token == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("User not logged in.")),
//         );
//         return;
//       }
//
//       final cartId = await createOrFetchCartId(token);
//       print("Magento cart ID (quote_id): $cartId");
//       for (final item in cartItems) {
//         final sku = item['childSku'] ?? item['sku'];
//         final qty = item['quantity'] ?? 1;
//
//         if (sku != null && sku.toString().isNotEmpty) {
//           await addItemToMagentoCart(
//             token: token,
//             cartId: cartId,
//             sku: sku,
//             quantity: qty,
//           );
//         }
//       }
//
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Cart synced to Magento successfully!")),
//       );
//     } catch (e) {
//       debugPrint('Error syncing cart: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error syncing cart: $e")),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   Widget buildCartItem(Map<String, dynamic> item) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//       child: ListTile(
//         title: Text(item['name'] ?? 'No Name'),
//         subtitle: Text('SKU: ${item['childSku'] ?? item['sku']}'),
//         trailing: Text('Qty: ${item['quantity'] ?? 1}'),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Local Cart'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.sync),
//             onPressed: isLoading ? null : pushLocalCartToMagento,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : cartItems.isEmpty
//           ? const Center(child: Text('Your cart is empty'))
//           : ListView.builder(
//         itemCount: cartItems.length,
//         itemBuilder: (context, index) => buildCartItem(cartItems[index]),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton.icon(
//           icon: const Icon(Icons.cloud_upload),
//           label: const Text('Sync Cart to Magento'),
//           onPressed: isLoading ? null : pushLocalCartToMagento,
//           style: ElevatedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 50),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class CartScreen extends StatefulWidget {
//   const CartScreen({super.key});
//
//   @override
//   State<CartScreen> createState() => _CartScreenState();
// }
//
// class _CartScreenState extends State<CartScreen> {
//   List<Map<String, dynamic>> _cartItems = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCartItems();
//   }
//
//   Future<void> _loadCartItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cartStringList = prefs.getStringList('cartItems') ?? [];
//
//     final decodedCart = cartStringList
//         .map((item) => json.decode(item) as Map<String, dynamic>)
//         .map((item) {
//       item['quantity'] ??= 1; // Default quantity to 1 if not present
//       return item;
//     })
//         .toList();
//
//     setState(() {
//       _cartItems = decodedCart;
//     });
//   }
//
//   Future<void> _saveCartItems() async {
//     final prefs = await SharedPreferences.getInstance();
//     final encodedItems = _cartItems.map((item) => json.encode(item)).toList();
//     await prefs.setStringList('cartItems', encodedItems);
//   }
//
//   void _updateQuantity(int index, int delta) {
//     setState(() {
//       final item = _cartItems[index];
//       item['quantity'] = (item['quantity'] ?? 1) + delta;
//       if (item['quantity'] < 1) item['quantity'] = 1;
//     });
//     _saveCartItems();
//   }
//
//   void _removeItem(int index) {
//     setState(() {
//       _cartItems.removeAt(index);
//     });
//     _saveCartItems();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Cart')),
//       body: _cartItems.isEmpty
//           ? const Center(child: Text('Your cart is empty'))
//           : ListView.builder(
//         itemCount: _cartItems.length,
//         padding: const EdgeInsets.all(12),
//         itemBuilder: (context, index) {
//           final product = _cartItems[index];
//           final quantity = product['quantity'] ?? 1;
//           final price = double.tryParse(product['actualPrice'].toString()) ?? 0.0;
//           final subtotal = price * quantity;
//
//           return Container(
//             margin: const EdgeInsets.only(bottom: 16),
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F8F3),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(color: Colors.grey.shade300),
//             ),
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   child: Image.network(
//                     product['prodSmallImg'] ?? '',
//                     width: 80,
//                     height: 80,
//                     fit: BoxFit.cover,
//                     errorBuilder: (_, __, ___) =>
//                     const Icon(Icons.image_not_supported, size: 60),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         product['designer_name'] ?? 'No name',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${product['short_desc'] ?? ''}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         '${product['childSku'] ?? ''}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Price ₹${price.toStringAsFixed(2)}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: Colors.grey.shade400),
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               children: [
//                                 GestureDetector(
//                                   onTap: () => _updateQuantity(index, -1),
//                                   child: const Icon(Icons.remove, size: 16),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(quantity.toString()),
//                                 const SizedBox(width: 8),
//                                 GestureDetector(
//                                   onTap: () => _updateQuantity(index, 1),
//                                   child: const Icon(Icons.add, size: 16),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Subtotal ₹${subtotal.toStringAsFixed(2)}',
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline),
//                   onPressed: () => _removeItem(index),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
