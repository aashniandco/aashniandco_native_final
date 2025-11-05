import 'package:aashniandco/features/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../categories/repository/api_service.dart';
import '../../newin/view/product_details_newin.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';
import '../data/models/product_model.dart';
import '../data/repositories/search_repository.dart';

// Import all the necessary models, blocs, and widgets


class FullSearchResultsScreen extends StatefulWidget {
  final String searchQuery;

  const FullSearchResultsScreen({Key? key, required this.searchQuery}) : super(key: key);

  @override
  State<FullSearchResultsScreen> createState() => _FullSearchResultsScreenState();
}

class _FullSearchResultsScreenState extends State<FullSearchResultsScreen> {
  late final SearchBloc _searchBloc;

  @override
  void initState() {
    super.initState();
    // Each results screen manages its own BLoC
    _searchBloc = SearchBloc(
      // Ensure your SearchBloc is created with the repository it needs
      searchRepository: RepositoryProvider.of<SearchRepository>(context),
    );
    // Immediately trigger a search for the query we received
    _searchBloc.add(SearchQueryChanged(widget.searchQuery));
  }

  @override
  void dispose() {
    _searchBloc.close();
    super.dispose();
  }

  // We need the same navigation logic here as on the search preview screen
  Future<void> _navigateToProductDetails(Product1 product) async {
    if (product.sku.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product details not available.')));
      return;
    }
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));
    try {
      final apiService = RepositoryProvider.of<ApiService>(context);
      final fullProductData = await apiService.fetchProductDetailsBySku(product.sku);
      Navigator.of(context).pop(); // Dismiss dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductDetailNewInDetailScreen(product: fullProductData)),
      );
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss dialog on error
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.searchQuery}"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      backgroundColor: Colors.white,
      body: BlocProvider.value(
        value: _searchBloc,
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            if (state is SearchLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SearchFailure) {
              return Center(child: Text('An error occurred: ${state.error}'));
            }
            if (state is SearchSuccess) {
              if (state.results.products.isEmpty) {
                return const Center(child: Text('No products found for your search.'));
              }
              // Display a full grid of product results
              return GridView.builder(
                padding: const EdgeInsets.all(8.0),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 columns
                  childAspectRatio: 0.65, // Adjust for your tile's appearance
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: state.results.products.length,
                itemBuilder: (context, index) {
                  final product = state.results.products[index];
                  // We reuse the same ProductGridTile1 widget here
                  return ProductGridTile1(
                    product: product,
                    onTap: () => _navigateToProductDetails(product),
                  );
                },
              );
            }
            // Initial state before the first search
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}