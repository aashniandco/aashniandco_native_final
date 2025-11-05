// lib/presentation/widgets/filter_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/product_bloc.dart';
import '../../bloc/product_event.dart';
import '../../bloc/product_state.dart';

class FilterDrawer extends StatelessWidget {
  const FilterDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Drawer(
          child: Column(
            children: [
              AppBar(
                title: const Text('Filters'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Clear Filters',
                    onPressed: () {
                      context.read<ProductBloc>().add(FiltersCleared());
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.availableFilters.length,
                  itemBuilder: (ctx, i) {
                    final filter = state.availableFilters[i];
                    return ExpansionTile(
                      title: Text(filter.label),
                      initiallyExpanded: state.selectedFilters.containsKey(filter.type),
                      children: filter.options.map((option) {
                        final isSelected = state.selectedFilters[filter.type]?.contains(option.id) ?? false;
                        return CheckboxListTile(
                          title: Text(option.name),
                          value: isSelected,
                          onChanged: (bool? value) {
                            context.read<ProductBloc>().add(
                                FilterToggled(filterType: filter.type, optionId: option.id));
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}