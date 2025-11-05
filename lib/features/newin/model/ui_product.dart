// lib/models/ui_product.dart

// Model for the nested "price" object
class UiPrice {
  final int finalPrice;
  final int originalPrice;
  final String currencySymbol;
  final String formattedFinalPrice;

  UiPrice({
    required this.finalPrice,
    required this.originalPrice,
    required this.currencySymbol,
    required this.formattedFinalPrice,
  });
}

// Model for the final, clean product structure
class UiProduct {
  final String id;
  final String sku;
  final String name;
  final String designer;

  final String imageUrl;
  final UiPrice price;

  UiProduct({
    required this.id,
    required this.sku,
    required this.name,
    required this.designer,

    required this.imageUrl,
    required this.price,
  });
}