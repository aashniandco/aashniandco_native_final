

import 'package:equatable/equatable.dart';

abstract class CategoryMetadataEvent extends Equatable {
  const CategoryMetadataEvent();
  @override
  List<Object> get props => [];
}

// Event dispatched when a user taps a category tile
class FetchCategoryMetadata extends CategoryMetadataEvent {
  final String categorySlug; // e.g., "anarkalis-kurtas"

  const FetchCategoryMetadata({required this.categorySlug});

  @override
  List<Object> get props => [categorySlug];
}