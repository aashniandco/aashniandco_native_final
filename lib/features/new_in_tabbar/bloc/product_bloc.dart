// lib/bloc/product_bloc.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'product_sorter.dart'; // Make sure this contains the ProductSorter class and the SortOptionApiParams extension
import '../api/product_repository.dart';

const int _categoryId = 1372;
const int _apiPageSize = 40;
const int _clientPageSize = 40; // Use a slightly larger page size for fewer network requests

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({required this.productRepository}) : super(const ProductState()) {
    on<ProductsFetched>(_onProductsFetched);
    on<MoreProductsRequested>(_onMoreProductsRequested);
    on<SortChanged>(_onSortChanged);
    on<FilterToggled>(_onFilterToggled);
    on<FiltersCleared>(_onFiltersCleared);
  }

  // In lib/bloc/product_bloc.dart...

  Future<void> _onSortChanged(SortChanged event, Emitter<ProductState> emit) async {
    final newSortOption = event.sortOption;

    // ✅ CHANGE: Add SortOption.latest to the condition for client-side sorting.
    if (newSortOption == SortOption.latest || newSortOption == SortOption.priceHighToLow || newSortOption == SortOption.priceLowToHigh) {
      // --- A: LATEST or PRICE SORT -> Client-side fetch all, then paginate from memory ---

      emit(state.copyWith(status: ProductStatus.loading, sortOption: newSortOption));
      try {
        final response = await productRepository.getProductsAndFilters(
          categoryId: _categoryId,
          filters: state.selectedFilters,
          fetchAll: true, // This fetches all products
          pageSize: 50000,
        );

        // This now correctly sorts by 'latest', 'price high', or 'price low'
        final sortedList = ProductSorter.sort(response.products, newSortOption);

        emit(state.copyWith(
          status: ProductStatus.success,
          products: sortedList.take(_clientPageSize).toList(),
          fullProductList: sortedList,
          availableFilters: response.filters,
          totalProductsAvailable: response.totalCount,
          hasReachedMax: sortedList.length <= _clientPageSize,
        ));
      } catch (e) {
        emit(state.copyWith(status: ProductStatus.failure, error: e.toString()));
      }
    } else {
      // --- B: NONE -> API-side pagination (or default order) ---

      emit(state.copyWith(
        sortOption: newSortOption,
      ));
      add(ProductsFetched());
    }
  }

// ... (the rest of the ProductBloc file remains the same)

  Future<void> _onMoreProductsRequested(MoreProductsRequested event, Emitter<ProductState> emit) async {
    if (state.hasReachedMax || state.status == ProductStatus.loadingMore) return;

    if (state.isClientPaginating) {
      // --- A: Paginate from the client-side list ---
      final currentProducts = state.products;
      final fullList = state.fullProductList;
      final startIndex = currentProducts.length;
      final endIndex = min(startIndex + _clientPageSize, fullList.length);

      if (startIndex >= fullList.length) return;

      final nextPage = fullList.getRange(startIndex, endIndex);

      emit(state.copyWith(
        products: List.of(currentProducts)..addAll(nextPage),
        hasReachedMax: (currentProducts.length + nextPage.length) >= fullList.length,
      ));
    } else {
      // --- B: Paginate from the API (this logic was already correct) ---
      emit(state.copyWith(status: ProductStatus.loadingMore));
      try {
        final nextPage = (state.products.length / _apiPageSize).ceil() + 1;
        final response = await productRepository.getProductsAndFilters(
          categoryId: _categoryId,
          filters: state.selectedFilters,
          sortParams: state.sortOption.apiParams,
          pageSize: _apiPageSize,
          currentPage: nextPage,
          fetchAll: false,
        );
        emit(
          response.products.isEmpty
              ? state.copyWith(hasReachedMax: true, status: ProductStatus.success)
              : state.copyWith(
            status: ProductStatus.success,
            products: List.of(state.products)..addAll(response.products),
            hasReachedMax: response.pagination.currentPage >= response.pagination.totalPages,
          ),
        );
      } catch (e) {
        emit(state.copyWith(status: ProductStatus.failure, error: e.toString()));
      }
    }
  }

  Future<void> _onProductsFetched(ProductsFetched event, Emitter<ProductState> emit) async {
    // This logic is correct.
    emit(state.copyWith(status: ProductStatus.loading, fullProductList: []));
    try {
      final response = await productRepository.getProductsAndFilters(
        categoryId: _categoryId,
        filters: state.selectedFilters,
        sortParams: state.sortOption.apiParams,
        pageSize: _apiPageSize,
        currentPage: 1,
        fetchAll: false,
      );
      emit(state.copyWith(
        status: ProductStatus.success,
        products: response.products,
        availableFilters: response.filters,
        totalProductsAvailable: response.totalCount,
        hasReachedMax: response.pagination.currentPage >= response.pagination.totalPages,
      ));
    } catch (e) {
      emit(state.copyWith(status: ProductStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onFilterToggled(FilterToggled event, Emitter<ProductState> emit) async {
    final newSelectedFilters = Map<String, List<String>>.from(state.selectedFilters);
    final filterKey = event.filterType;
    final option = event.optionId;

    if (!newSelectedFilters.containsKey(filterKey)) {
      newSelectedFilters[filterKey] = [];
    }

    if (newSelectedFilters[filterKey]!.contains(option)) {
      newSelectedFilters[filterKey]!.remove(option);
      if (newSelectedFilters[filterKey]!.isEmpty) {
        newSelectedFilters.remove(filterKey);
      }
    } else {
      newSelectedFilters[filterKey]!.add(option);
    }

    // ✅ FIXED: Use state.copyWith to only update the filters on the current state,
    // preventing a UI reset before fetching the new data.
    emit(state.copyWith(selectedFilters: newSelectedFilters));
    add(ProductsFetched());
  }

  Future<void> _onFiltersCleared(FiltersCleared event, Emitter<ProductState> emit) async {
    // This is correct: we intentionally want to reset everything.
    emit(const ProductState());
    add(ProductsFetched());
  }
}