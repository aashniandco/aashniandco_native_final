import 'package:aashniandco/features/newin/view/product_details_newin.dart';
import 'package:flutter/material.dart';
import '../../../constants/text_styles.dart';
import '../model/new_in_model.dart';
 // Replace with actual import


import 'package:flutter/material.dart';

// class ProductCard extends StatelessWidget {
//   final Product product;
//
//   const ProductCard({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           product.prodSmallImg != null
//               ? Image.network(product.prodSmallImg!, fit: BoxFit.cover, height: 150, width: double.infinity)
//               : Container(height: 150, color: Colors.grey),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text(product.designerName ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: Text(product.shortDesc ?? "", maxLines: 2, overflow: TextOverflow.ellipsis),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Text("₹ ${product.actualPrice}", style: const TextStyle(color: Colors.green)),
//           ),
//         ],
//       ),
//     );
//   }
// }
class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailNewInDetailScreen(product: widget.product.toJson()),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Image.network(
                widget.product.prodSmallImg,
                width: double.infinity,
                height: 550,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 550,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  widget.product.designerName,
                  style: AppTextStyle.designerName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  widget.product.shortDesc,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.shortDescription,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: Text(
                  "₹${widget.product.actualPrice.toStringAsFixed(0)}",
                  style: AppTextStyle.actualPrice,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// class ProductCard extends StatelessWidget {
//   final Product product;
//
//   const ProductCard({super.key, required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       color: Colors.white,
//       elevation: 1,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Flexible(
//             child: Image.network(
//               product.prodSmallImg,
//               width: double.infinity,
//               height: 550,
//               fit: BoxFit.cover,
//               errorBuilder: (context, error, stackTrace) => Container(
//                 height: 550,
//                 color: Colors.grey[300],
//                 alignment: Alignment.center,
//                 child: const Icon(Icons.image_not_supported, size: 50),
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Center(
//               child: Text(
//                 product.designerName,
//                 style: AppTextStyle.designerName,
//                 textAlign: TextAlign.center,
//                 maxLines: 1,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             child: Center(
//               child: Text(
//                 product.shortDesc,
//                 textAlign: TextAlign.center,
//                 style: AppTextStyle.shortDescription,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: Center(
//               child: Text(
//                 "₹${product.actualPrice.toStringAsFixed(0)}",
//                 style: AppTextStyle.actualPrice,
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
