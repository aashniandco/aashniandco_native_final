// lib/config/category_data.dart

class CategoryData {
  final int id;         // The ID for product filtering (e.g., 3374)
  final String urlKey;   // The correct URL key for the API (e.g., "womens-clothing")
  final String name;     // The display name (e.g., "Women")

  const CategoryData({
    required this.id,
    required this.urlKey,
    required this.name,
  });
}