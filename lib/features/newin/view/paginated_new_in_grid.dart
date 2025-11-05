// lib/widgets/paginated_new_in_grid.dart (A new reusable widget)

import 'package:aashniandco/features/newin/view/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/new_in_bloc.dart';
import '../bloc/new_in_state.dart';

// Assuming you have a ProductCard widget

class PaginatedNewInGrid extends StatefulWidget {
  final String selectedSort;

  const PaginatedNewInGrid({
    Key? key,
    required this.selectedSort,
  }) : super(key: key);

  @override
  State<PaginatedNewInGrid> createState() => _PaginatedNewInGridState();
}

class _PaginatedNewInGridState extends State<PaginatedNewInGrid> {
  final _scrollController = ScrollController();
  bool _isFetching = false;

  // Helper to map the UI sort string to the one the BLoC expects.
  String _mapSortOption(String uiSort) {
    switch (uiSort) {
      case 'High to Low':
        return 'Price: High to Low';
      case 'Low to High':
        return 'Price: Low to High';
      case 'Latest':
        return 'Latest';
      default:
        return 'Default';
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    // We access the BLoC provided by the parent `NewInFilterScreen`
    final bloc = context.read<NewInBloc>();
    if (_isBottom && !_isFetching && !bloc.state.hasReachedMax) {
      setState(() { _isFetching = true; });
      bloc.add(FetchNewInProducts(sortOption: _mapSortOption(widget.selectedSort)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewInBloc, NewInState>(
      listener: (context, state) {
        if (state.status != NewInStatus.loading) {
          setState(() { _isFetching = false; });
        }
      },
      child: BlocBuilder<NewInBloc, NewInState>(
        builder: (context, state) {
          switch (state.status) {
            case NewInStatus.failure:
              return Center(child: Text(state.errorMessage ?? 'Failed to fetch products'));

            case NewInStatus.initial:
            case NewInStatus.loading:
              if (state.products.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              // If loading but we have products, fall through to show them
              // with a loader at the bottom.
              return _buildGridView(context, state);

            case NewInStatus.success:
              if (state.products.isEmpty) {
                return const Center(child: Text("No products found"));
              }
              return _buildGridView(context, state);
          }
        },
      ),
    );
  }

  Widget _buildGridView(BuildContext context, NewInState state) {
    return GridView.builder(
      controller: _scrollController,
      itemCount: state.hasReachedMax ? state.products.length : state.products.length + 1,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.55,
      ),
      itemBuilder: (context, index) {
        if (index >= state.products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final product = state.products[index];
        return ProductCard(product: product);
      },
    );
  }
}