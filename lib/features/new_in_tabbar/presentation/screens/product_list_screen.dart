// lib/presentation/screens/product_list_screen.dart


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../newin/view/filter_bottom_sheet.dart';
import '../../../newin/view/product_details_newin.dart';
import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';
import '../../bloc/product_state.dart';
import '../../bloc/product_sorter.dart';
import '../widgets/ filter_drawer.dart';
// Make sure this path is correct
import '../widgets/ product_grid_item.dart';
import '../widgets/bottom_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';
import '../../bloc/product_state.dart';
import '../../bloc/product_sorter.dart';

import '../widgets/bottom_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';
import '../../bloc/product_state.dart';
import '../../bloc/product_sorter.dart';

import '../widgets/bottom_loader.dart';

// ✅ CORRECTED IMPORTS: Point to the actual screen/widget files
import '../../../newin/view/filter_bottom_sheet.dart';
import '../../../newin/view/product_details_newin.dart';


class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<ProductBloc>().add(ProductsFetched());
  }

  dynamic _getAttributeValue(Map<String, dynamic> productDetails, String attributeCode) {
    final attributes = productDetails['custom_attributes'] as List<dynamic>?;
    if (attributes == null) return null;

    final attribute = attributes.firstWhere(
          (attr) => attr['attribute_code'] == attributeCode,
      orElse: () => null,
    );

    return attribute?['value'];
  }
  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) context.read<ProductBloc>().add(MoreProductsRequested());
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Widget _buildHeader(BuildContext context, ProductState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "New In",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<SortOption?>(
              value: state.sortOption == SortOption.none ? null : state.sortOption,
              hint: const Text("Default", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500)),
              icon: const Icon(Icons.sort, color: Colors.black, size: 20),
              style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
              dropdownColor: Colors.white,
              underline: Container(),
              onChanged: (SortOption? newValue) {
                context.read<ProductBloc>().add(SortChanged(newValue ?? SortOption.none));
              },
              items: const [
                DropdownMenuItem(value: null, child: Text("Default")),
                DropdownMenuItem(value: SortOption.latest, child: Text("Latest")),
                DropdownMenuItem(value: SortOption.priceHighToLow, child: Text("High to Low")),
                DropdownMenuItem(value: SortOption.priceLowToHigh, child: Text("Low to High")),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Products")),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          switch (state.status) {
            case ProductStatus.failure:
              return Center(child: Text('Failed to fetch products: ${state.error}'));

            case ProductStatus.success:
            case ProductStatus.loadingMore:
              if (state.products.isEmpty && state.status == ProductStatus.success) {
                return Column(
                  children: [
                    _buildHeader(context, state),
                    const Expanded(child: Center(child: Text('No products found.'))),
                  ],
                );
              }
              return Column(
                children: [
                  _buildHeader(context, state),
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      itemCount: state.hasReachedMax
                          ? state.products.length
                          : state.products.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.55,
                      ),
                      itemBuilder: (BuildContext context, int index) {
                        if (index >= state.products.length) {
                          return !state.hasReachedMax ? const BottomLoader() : const SizedBox.shrink();
                        }
                        // ✅ CORRECTED NAVIGATION LOGIC
                        final product = state.products[index];
                        return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailNewInDetailScreen(
                                        // Use the new toJson() method here
                                        product: product.toJson(),
                                      ),
                                ),
                              );
                            },
                            child: ProductGridItem(product: product));
                      },
                    ),
                  ),
                ],
              );

            case ProductStatus.initial:
            case ProductStatus.loading:
            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            // ✅ CORRECTED BUILDER: Provide the BLoC to the bottom sheet
            builder: (_) {
              return BlocProvider.value(
                value: BlocProvider.of<ProductBloc>(context),
                child: const FilterBottomSheet(),
              );
            },
          );
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.filter_list_alt),
      ),
    );
  }
}