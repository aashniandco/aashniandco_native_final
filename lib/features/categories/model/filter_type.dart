class FilterType {
  final String type; // Machine-readable key: 'colors', 'sizes'
  final String label; // Human-readable label: 'Color', 'Size'

  FilterType({required this.type, required this.label});
}