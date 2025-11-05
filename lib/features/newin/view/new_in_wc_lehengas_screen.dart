import 'package:aashniandco/features/newin/view/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:aashniandco/features/newin/model/new_in_model.dart';


import '../bloc/new_in_wc_lehengas_bloc.dart';
import '../bloc/new_in_wc_lehengas_event.dart';
import '../bloc/new_in_wc_lehengas_state.dart';
import 'filtered_product_tab_screen.dart';

// class NewInWcLehengasScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInWcLehengasScreen({super.key, required this.selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     return FilteredProductTabScreen(
//       selectedCategories: selectedCategories,
//       initialTab: "Lehengas",
//       productListBuilder: (selectedCategory, selectedSort) {
//         return BlocProvider(
//           create: (_) => NewInWcLehengasBloc()..add(FetchNewInWcLehengas()),
//           child:
//
//           BlocBuilder<NewInWcLehengasBloc, NewInWcLehengasState>(
//             builder: (context, state) {
//               if (state is NewInWcLehengasLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               } else if (state is NewInWcLehengasLoaded) {
//                 if (state.products.isEmpty) {
//                   return const Center(child: Text("No products found"));
//                 }
//
//                 return GridView.builder(
//                   padding: const EdgeInsets.all(8.0),
//                   itemCount: state.products.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2, // 2 items per row
//                     crossAxisSpacing: 10,
//                     mainAxisSpacing: 10,
//                     childAspectRatio: 0.75, // Adjust for height/width ratio
//                   ),
//                   itemBuilder: (context, index) {
//                     final product = state.products[index];
//
//                     return Card(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(product.designerName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                             const SizedBox(height: 4),
//                             Text(product.shortDesc, maxLines: 2, overflow: TextOverflow.ellipsis),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               } else if (state is NewInWcLehengasError) {
//                 return Center(child: Text(state.message));
//               } else {
//                 return const SizedBox.shrink();
//               }
//             },
//           )
//
//           // BlocBuilder<NewInWcLehengasBloc, NewInWcLehengasState>(
//           //   builder: (context, state) {
//           //     if (state is NewInWcLehengasLoading) {
//           //       return Center(child: CircularProgressIndicator());
//           //     } else if (state is NewInWcLehengasLoaded) {
//           //       return ListView.builder(
//           //         itemCount: state.products.length,
//           //         itemBuilder: (context, index) {
//           //           final product = state.products[index];
//           //           return ListTile(
//           //             title: Text(product.designerName),
//           //             subtitle: Text(product.shortDesc),
//           //           );
//           //         },
//           //       );
//           //     } else if (state is NewInWcLehengasError) {
//           //       return Center(child: Text(state.message));
//           //     }
//           //     return SizedBox.shrink();
//           //   },
//           // )
//
//           // BlocBuilder<NewInWcLehengasBloc, NewInWcLehengasState>(
//           //   builder: (context, state) {
//           //     if (state is NewInWcLehengasLoading) {
//           //       return const Center(child: CircularProgressIndicator());
//           //     } else if (state is NewInWcLehengasLoaded) {
//           //       List<Product> products = List.from(state.products);
//           //
//           //       if (selectedSort == 'High to Low') {
//           //         products.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
//           //       } else if (selectedSort == 'Low to High') {
//           //         products.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
//           //       }
//           //
//           //       if (products.isEmpty) {
//           //         return const Center(child: Text("No products found"));
//           //       }
//           //
//           //       return GridView.builder(
//           //         itemCount: products.length,
//           //         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           //           crossAxisCount: 2,
//           //           crossAxisSpacing: 10,
//           //           mainAxisSpacing: 10,
//           //           childAspectRatio: 0.55,
//           //         ),
//           //         itemBuilder: (context, index) {
//           //           final product = products[index];
//           //           return ProductCard(product: product);
//           //         },
//           //       );
//           //     } else if (state is NewInWcLehengasError) {
//           //       return Center(child: Text(state.message));
//           //     } else {
//           //       return const SizedBox.shrink();
//           //     }
//           //   },
//           // ),
//         );
//       },
//     );
//   }
// }
