import 'package:aashniandco/features/newin/model/ui_product.dart';
import 'package:intl/intl.dart'; // Add this import for number formatting
 // Import your new models

// 1. ADD THESE TWO IMPORTS AT THE TOP OF THE FILE
import 'package:intl/intl.dart';
// Adjust this path if your ui_product.dart file is elsewhere

// 1. ADD THESE IMPORTS
import 'package:intl/intl.dart';
// Make sure this path correctly points to your ui_product.dart file

// This class represents the RAW data from Solr
class Product {
  // 2. VERIFY THESE FIELDS EXIST
  // Every field used in `toUiProduct` below MUST be defined here.
  final String? designerName;
  final double? actualPrice;
  final String? prodName;
  final String? prod_en_id;
  final String? prod_sku;
  final String? prodSmallImg;
  final String? shortDesc;

  Product({
    this.designerName,
    this.actualPrice,
    this.prodName,
    this.prod_en_id,
    this.prod_sku,
    this.prodSmallImg,
    this.shortDesc,
  });

  // This factory correctly parses the RAW Solr JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      designerName: json['designer_name'],
      actualPrice: (json['actual_price_1'] as num?)?.toDouble(),
      prodName: json['prod_name'] is List ? json['prod_name'][0] : json['prod_name'],
      prod_en_id: json['prod_en_id'],
      prod_sku: json['prod_sku'],
      prodSmallImg: json['prod_small_img'],
      shortDesc: json['short_desc'],
    );
  }

  // 3. THIS IS THE METHOD THAT WAS MISSING OR MISPLACED
  // It converts the raw `Product` object into a clean `UiProduct` object.
  UiProduct toUiProduct() {
    final formatCurrency = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    final uiPrice = UiPrice(
      finalPrice: actualPrice?.toInt() ?? 0,
      originalPrice: actualPrice?.toInt() ?? 0,
      currencySymbol: '₹',
      formattedFinalPrice: formatCurrency.format(actualPrice ?? 0),
    );

    return UiProduct(
      id: prod_en_id ?? '',
      sku: prod_sku ?? '',
      name: designerName ?? prodName ?? 'Unknown',
      designer: designerName ?? 'Unknown',

      imageUrl: '${prodSmallImg ?? ''}?w=400',
      price: uiPrice,
    );
  }
}// <-- This is the end of your Product class