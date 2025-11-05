// models/product_image.dart

class ProductImage {
  final String sku;
  final String imageUrl;
  final String? label;
  final int position;
  final bool isDisabled;

  ProductImage({
    required this.sku,
    required this.imageUrl,
    this.label,
    required this.position,
    required this.isDisabled,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      sku: json['sku'] ?? '',
      imageUrl: json['image_url'] ?? '',
      label: json['label'],
      position: (json['position'] as num?)?.toInt() ?? 0,
      isDisabled: (json['disabled'] as bool?) ?? false,
    );
  }
}