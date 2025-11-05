


import 'package:equatable/equatable.dart';

abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object?> get props => [];
}

// Event to fetch/refresh data
class FetchProducts extends ProductsEvent {
  final String categoryId;
  final String? sortKey;
  final String? filtersJson;
  final int page;

  const FetchProducts({
    required this.categoryId,
    this.sortKey,
    this.filtersJson,
    this.page = 1,
  });

  @override
  List<Object?> get props => [categoryId, sortKey, filtersJson, page];
}