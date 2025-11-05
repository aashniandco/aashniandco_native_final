// // A simple model to represent a single filter option from the API.
// class FilterOption {
//   final String key;
//   final String label;
//
//   FilterOption({required this.key, required this.label});
// }


class FilterItem {
  final String id;
  final String name;
  bool isExpanded;
  bool isSelected;
  final List<FilterItem> children;

  FilterItem({
    required this.id,
    required this.name,
    this.children = const [],
    this.isSelected = false,
    this.isExpanded = false,
  });
}

class FilterType {
  final String key; // e.g., 'categories', 'designers'
  final String label; // e.g., 'Category', 'Designer'

  FilterType({required this.key, required this.label});
}