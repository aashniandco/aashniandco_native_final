import 'package:aashniandco/features/newin/view/shimmer_layout/productCard_placeholder.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
// Make sure to import your placeholder card
// Adjust the import path as needed

class ShimmerGrid extends StatelessWidget {
  const ShimmerGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: GridView.builder(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        itemCount: 8, // Display a fixed number of placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.65, // Must match the real grid's aspect ratio
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) => const ProductCardPlaceholder(),
      ),
    );
  }
}