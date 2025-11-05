part of 'filtered_products_bloc.dart';

//
// abstract class FilteredProductsEvent {}
//
// // Event to fetch products based on filters and page number
// class FetchFilteredProducts extends FilteredProductsEvent {
//   final List<Map<String, dynamic>> selectedFilters;
//   final int page;
//
//   FetchFilteredProducts({required this.selectedFilters, this.page = 0});
// }
//
// // Event to sort the currently loaded products
// class SortProducts extends FilteredProductsEvent {
//   final String sortOrder;
//
//   SortProducts(this.sortOrder);
// }



abstract class FilteredProductsEvent extends Equatable {
  const FilteredProductsEvent();
  @override
  List<Object> get props => [];
}

/// The single, powerful event to fetch, paginate, and sort products.
class FetchFilteredProducts extends FilteredProductsEvent {
  final List<Map<String, dynamic>> selectedFilters;
  final int page;
  final String sortOrder;

  const FetchFilteredProducts({
    required this.selectedFilters,
    required this.page,
    required this.sortOrder,
  });

  @override
  List<Object> get props => [selectedFilters, page, sortOrder];
}

// ✅ ADD THIS NEW EVENT CLASS
class ReportError extends FilteredProductsEvent {
  final String errorMessage;

  const ReportError(this.errorMessage);


}