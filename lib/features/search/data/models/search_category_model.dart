// import 'package:equatable/equatable.dart';
//
// class SearchCategory extends Equatable {
//   final String label; // e.g., "Men /Kurta Sets"
//   final String value; // The filter value for this category
//
//   const SearchCategory({required this.label, required this.value});
//
//   factory SearchCategory.fromJson(Map<String, dynamic> json) {
//     return SearchCategory(
//       label: json['label'] ?? '',
//       value: json['value']?.toString() ?? '',
//     );
//   }
//
//   @override
//   List<Object?> get props => [label, value];
// }