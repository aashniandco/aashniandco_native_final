import 'package:flutter/material.dart';

class ProductCardPlaceholder extends StatelessWidget {
  const ProductCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // This card has the same structure and dimensions as your real ProductCard.
    // We use simple grey containers to represent where the image and text will be.
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Placeholder for the image
          AspectRatio(
            aspectRatio: 1.0, // Match the aspect ratio of your product image
            child: Container(
              color: Colors.white, // The shimmer effect will animate over this
            ),
          ),
          // Placeholder for the text content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Designer Name placeholder
                  Container(width: double.infinity, height: 14.0, color: Colors.white),
                  const SizedBox(height: 8.0),
                  // Short Description placeholder
                  Container(width: double.infinity, height: 12.0, color: Colors.white),
                  const SizedBox(height: 4.0),
                  Container(width: 150.0, height: 12.0, color: Colors.white),
                  const SizedBox(height: 8.0),
                  // Price placeholder
                  Container(width: 80.0, height: 14.0, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}