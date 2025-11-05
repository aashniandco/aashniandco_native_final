

import 'package:equatable/equatable.dart';

import '../../newin/model/new_in_model.dart';
import '../model/product_api_response.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {}
class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  final List<ApiFilter> filters;
  final PaginationInfo pagination;
  final int totalCount;

  const ProductsLoaded({
    required this.products,
    required this.filters,
    required this.pagination,
    required this.totalCount,
  });

  @override
  List<Object> get props => [products, filters, pagination, totalCount];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError(this.message);
  @override
  List<Object> get props => [message];
}