import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/bloc/currency_bloc.dart';
import '../auth/bloc/currency_state.dart';
import '../categories/repository/api_service.dart';
 // ✅ Import your CurrencyBloc

class CartItemWidget extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onDelete;

  const CartItemWidget({
    Key? key,
    required this.item,
    required this.onAdd,
    required this.onRemove,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<CartItemWidget> createState() => _CartItemWidgetState();
}

// ... (imports and placeholder classes remain the same)

class _CartItemWidgetState extends State<CartItemWidget> {
  final ApiService _apiService = ApiService();
  String? _imageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProductImage();
  }

  Future<void> _fetchProductImage() async {
    final String? fullSku = widget.item['sku'];
    if (fullSku == null || fullSku.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // ✅ CORE LOGIC CHANGE IS HERE:
    // Split the SKU by the hyphen and take the first part.
    // .trim() is added to remove any accidental whitespace.
    final String baseSku = fullSku.split('-').first.trim();

    // Add print statements for easy debugging
    print("CartItemWidget: Original SKU from cart is '$fullSku'");
    print("CartItemWidget: Extracted base SKU for image fetch is '$baseSku'");

    try {
      // Now, call the API using the cleaned, base SKU
      final images = await _apiService.fetchProductImages(baseSku);

      if (mounted) {
        setState(() {
          if (images.isNotEmpty) {
            _imageUrl = images.first.imageUrl;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching image for base SKU $baseSku: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // This build method does not need any changes.
    // It will automatically use the _imageUrl fetched by the logic above.

    final currencyState = context.watch<CurrencyBloc>().state;
    String displaySymbol = '₹';
    double exchangeRate = 1.0;
    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      exchangeRate = currencyState.selectedRate.rate;
    }
    final price = (double.tryParse(widget.item['price'].toString()) ?? 0.0) * exchangeRate;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 100,
              height: 120,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              )
                  : Container(
                decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.image, color: Colors.grey, size: 40),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item['name'] ?? 'Product Name', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Text(
                    'SKU : ${widget.item['sku'] ?? 'sku'}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),
                  Text('$displaySymbol${price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.remove), onPressed: widget.onRemove, iconSize: 18),
                            Text('${widget.item['qty'] ?? 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.add), onPressed: widget.onAdd, iconSize: 18),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: widget.onDelete),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
//22/8/2025
// class CartItemWidget extends StatelessWidget {
//   final Map<String, dynamic> item;
//   final VoidCallback onDelete;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;
//
//   const CartItemWidget({
//     Key? key,
//     required this.item,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onDelete,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     // --- Image URL Logic ---
//     // The key from Magento's cart API is usually 'product_image' inside 'extension_attributes'
//     final imageUrl = item['extension_attributes']?[''];
//
//     // --- Currency Conversion Logic ---
//     final currencyState = context.watch<CurrencyBloc>().state;
//     String displaySymbol = '₹';
//     double exchangeRate = 1.0;
//     if (currencyState is CurrencyLoaded) {
//       displaySymbol = currencyState.selectedSymbol;
//       exchangeRate = currencyState.selectedRate.rate;
//     }
//     final price = (double.tryParse(item['price'].toString()) ?? 0.0) * exchangeRate;
//     final itemTotal = price * (item['qty'] ?? 1);
//
//     return Card(
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ✅ 1. ADD THE IMAGE WIDGET
//             if (imageUrl != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.network(
//                   imageUrl,
//                   width: 100,
//                   height: 120,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       width: 100,
//                       height: 120,
//                       color: Colors.grey.shade200,
//                       child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                     );
//                   },
//                 ),
//               )
//             else
//             // Fallback if no image URL is provided
//               Container(
//                 width: 100,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade200,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(Icons.image, color: Colors.grey, size: 40),
//               ),
//
//             const SizedBox(width: 16),
//
//             // ✅ 2. ARRANGE OTHER DETAILS IN AN EXPANDED COLUMN
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     item['name'] ?? 'Product Name',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'SKU: ${item['sku'] ?? 'N/A'}',
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '$displaySymbol${price.toStringAsFixed(2)}',
//                     style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                   ),
//                   const SizedBox(height: 12),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       // Quantity Selector
//                       Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.grey.shade300),
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         child: Row(
//                           children: [
//                             IconButton(icon: const Icon(Icons.remove), onPressed: onRemove, iconSize: 18),
//                             Text('${item['qty'] ?? 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                             IconButton(icon: const Icon(Icons.add), onPressed: onAdd, iconSize: 18),
//                           ],
//                         ),
//                       ),
//                       // Delete Button
//                       IconButton(
//                         icon: const Icon(Icons.delete_outline, color: Colors.red),
//                         onPressed: onDelete,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // Widget build(BuildContext context) {
//   //   final imageUrl = item['extension_attributes']?['product_image'];
//   //   // ✅ 1. Get the current currency state from the global BLoC
//   //   final currencyState = context.watch<CurrencyBloc>().state;
//   //
//   //   // --- Prepare variables ---
//   //   final int qty = item['qty'] ?? 1;
//   //   // This is the BASE price in INR from your API
//   //   final double basePrice = double.tryParse(item['price'].toString()) ?? 0.0;
//   //
//   //   // ✅ 2. Set default and then calculate the display values
//   //   String displaySymbol = '₹'; // Default symbol
//   //   double displayPrice = basePrice; // Default price
//   //
//   //   if (currencyState is CurrencyLoaded) {
//   //     displaySymbol = currencyState.selectedSymbol;
//   //     // Calculate price: (base price in INR) * (selected currency's rate)
//   //     displayPrice = basePrice * currencyState.selectedRate.rate;
//   //   }
//   //
//   //   // Calculate subtotal using the converted display price
//   //   final double displaySubtotal = displayPrice * qty;
//   //
//   //   return Container(
//   //     margin: const EdgeInsets.only(bottom: 12),
//   //     padding: const EdgeInsets.all(12),
//   //     decoration: BoxDecoration(
//   //       color: const Color(0xFFF5F7F2),
//   //       borderRadius: BorderRadius.circular(16),
//   //       border: Border.all(color: Colors.grey.shade300),
//   //     ),
//   //     child: Row(
//   //       crossAxisAlignment: CrossAxisAlignment.start,
//   //       children: [
//   //         ClipRRect(
//   //           borderRadius: BorderRadius.circular(12),
//   //           child: Image.network(
//   //             item['prodSmallImg'] ?? '',
//   //             width: 80,
//   //             height: 80,
//   //             fit: BoxFit.cover,
//   //             errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
//   //           ),
//   //         ),
//   //         const SizedBox(width: 12),
//   //         Expanded(
//   //           child: Column(
//   //             crossAxisAlignment: CrossAxisAlignment.start,
//   //             children: [
//   //               Text(
//   //                 item['name'] ?? '',
//   //                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//   //               ),
//   //               const SizedBox(height: 4),
//   //               Text("SKU: ${item['sku'] ?? ''}",
//   //                   style: const TextStyle(fontSize: 13, color: Colors.grey)),
//   //               const SizedBox(height: 4),
//   //
//   //               // ✅ 3. Display the converted price and symbol
//   //               Text("Price : $displaySymbol${displayPrice.toStringAsFixed(0)}",
//   //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//   //
//   //               const SizedBox(height: 8),
//   //               Row(
//   //                 children: [
//   //                   IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
//   //                   Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//   //                   IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
//   //                   const Spacer(),
//   //                   IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
//   //                 ],
//   //               ),
//   //
//   //               // ✅ 3. Display the converted subtotal and symbol
//   //               Text("Subtotal : $displaySymbol${displaySubtotal.toStringAsFixed(0)}",
//   //                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
// class CartItemWidget extends StatelessWidget
// {
//   final Map<String, dynamic> item;
//   final VoidCallback onDelete;
//   final VoidCallback onAdd;
//   final VoidCallback onRemove;
//
//   const CartItemWidget({
//     Key? key,
//     required this.item,
//     required this.onAdd,
//     required this.onRemove,
//     required this.onDelete,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final qty = item['qty'] ?? 1;
//     final price = double.tryParse(item['price'].toString()) ?? 0.0;
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F7F2),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(12),
//             child: Image.network(
//               item['prodSmallImg'] ?? '',
//               width: 80,
//               height: 80,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item['name'] ?? '',
//                   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text("SKU: ${item['sku'] ?? ''}",
//                     style: const TextStyle(fontSize: 13, color: Colors.grey)),
//                 const SizedBox(height: 4),
//                 Text("Price : ₹${price.toStringAsFixed(0)}",
//                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     IconButton(onPressed: onRemove, icon: const Icon(Icons.remove)),
//                     Text('$qty', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
//                     const Spacer(),
//                     IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline)),
//                   ],
//                 ),
//                 Text("Subtotal : ₹${(price * qty).toStringAsFixed(0)}",
//                     style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
