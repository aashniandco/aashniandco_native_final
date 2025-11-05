class CategoryFilterItem {
  final String id;
  final String name;
  bool isExpanded;
  bool isSelected;
  final List<CategoryFilterItem> children;

  CategoryFilterItem({
    required this.id,
    required this.name,
    this.isExpanded = false,
    this.isSelected = false,
    required this.children,
  });

  // A factory constructor to create an instance from the API's JSON map
  factory CategoryFilterItem.fromMap(String id, String name, List<CategoryFilterItem> children) {
    return CategoryFilterItem(
      id: id,
      name: name,
      children: children,
    );
  }
}