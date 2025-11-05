import 'package:flutter/material.dart';
// ✅✅✅ THIS IS THE MAIN FIX ✅✅✅
// The import now points to the correct api_response.dart file within the new_in_tabbar feature.
// import '../../models/api_response.dart';

// Note: The class name is singular: ProductGridItem
import 'package:flutter/material.dart';
import '../../models/api_response.dart';

class ProductGridItem extends StatelessWidget {
  final Product product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 1.0,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Image.network(
              product.imageUrl,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey[400]),
                );
              },
            ),
          ),

          // Container for all the text details, centered
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Designer Name (styled like your reference)
                Text(
                  product.name.toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // ✅ Short Description (styled like your reference)
                Text(
                  product.shortDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Price (using the formatted price from the Price object)
                Text(
                  product.price.formattedFinalPrice,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}