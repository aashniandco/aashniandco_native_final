// lib/presentation/widgets/product_grid_item.dart

import 'package:flutter/material.dart';

import '../../newin/model/new_in_model.dart'; // Make sure this path is correct

// lib/presentation/widgets/product_grid_item.dart

// ... (imports)

import 'package:flutter/material.dart';
// ✅ IMPORT THE CORRECT MODEL that is used by MenuCategoriesScreen


class ProductGridItem extends StatelessWidget {
  // ✅ The type is now the Product model from your 'newin' feature
  final Product product;

  const ProductGridItem({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // You can add navigation logic here if needed
        // For example:
        // Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)));
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias, // Ensures image respects border radius
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Changed from start for image
          children: <Widget>[
            // --- Image Section ---
            // The Expanded widget ensures the image takes up the available vertical space.
            Expanded(
              child: Image.network(
                // ✅ USE THE CORRECT IMAGE PROPERTY: prodSmallImg
                product.prodSmallImg ?? '',
                fit: BoxFit.cover, // Ensures the image covers the area
                // A loading builder can provide a better UX
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                },
                // An error builder handles cases where the image fails to load
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                  );
                },
              ),
            ),

            // --- Details Section ---
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // We can use the designer name for a bolder title
                  Text(
                    // ✅ USE THE CORRECT NAME PROPERTY: designerName
                    product.designerName ?? 'Unknown Designer',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1, // Keep it to one line
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // And the short description for more detail
                  Text(
                    // ✅ USE THE CORRECT DESCRIPTION PROPERTY: shortDesc
                    product.shortDesc ?? 'No description',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 2, // Allow up to two lines
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Price
                  Text(
                    // ✅ USE THE CORRECT PRICE PROPERTY: actualPrice
                    // We format it to look like currency.
                    "₹${product.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
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