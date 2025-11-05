//
// import 'dart:convert';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:http/io_client.dart';
// import 'package:http/http.dart' as  http;
// import 'package:http/io_client.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:http/io_client.dart';
//
//
// import '../../../constants/api_constants.dart';
// import '../bloc/new_in_color_bloc.dart';
// import '../bloc/new_in_color_state.dart';
// import 'new_in_product_test_screen.dart';
// import 'new_in_products_screen.dart'; // For getApiKeyForSubcategory
//
// class CategoryResultTesScreen extends StatefulWidget {
//   final String selectedColor;
//
//   const CategoryResultTesScreen({super.key, required this.selectedColor});
//
//   @override
//   State<CategoryResultTesScreen> createState() => _CategoryResultTesScreenState();
// }
//
// class _CategoryResultTesScreenState extends State<CategoryResultTesScreen> {
//   late NewInColorBloc _bloc;
//   bool _hasNavigated = false; // To avoid multiple navigations
//
//   @override
//   void initState() {
//     super.initState();
//     _bloc = NewInColorBloc()..add(FetchProductsByColor(widget.selectedColor));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => _bloc,
//       child: BlocListener<NewInColorBloc, NewInColorState>(
//         listener: (context, state) {
//           if (state is NewInColorLoaded && !_hasNavigated) {
//             _hasNavigated = true;
//
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => NewInProductsTestScreen(
//                   subcategory: widget.selectedColor,
//                   selectedCategories: [],
//                   initialTab: widget.selectedColor,
//                   preloadedProducts: state.products,
//                   productListBuilder: (selectedCategory, selectedSort) {
//                     return Container(); // Or your fallback widget
//                   },
//                 ),
//               ),
//             );
//           }
//         },
//         child: Scaffold(
//           appBar: AppBar(title: Text('Loading ${widget.selectedColor}...')),
//           body: BlocBuilder<NewInColorBloc, NewInColorState>(
//             builder: (context, state) {
//               if (state is NewInColorLoading) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               if (state is NewInColorError) {
//                 return Center(child: Text(state.message));
//               }
//
//               // In case the listener hasn't yet navigated
//               if (state is NewInColorLoaded) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//
//               return const Center(child: Text('No products available.'));
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
//
//
// // class CategoryResultTesScreen extends StatefulWidget {
// //   final String selectedColor;
// //
// //   const CategoryResultTesScreen({super.key, required this.selectedColor});
// //
// //   @override
// //   State<CategoryResultTesScreen> createState() => _CategoryResultTesScreenState();
// // }
// // class _CategoryResultTesScreenState extends State<CategoryResultTesScreen> {
// //   List<dynamic> products = [];
// //   bool isLoading = true;
// //   String error = "";
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     fetchProductsByColor(widget.selectedColor);
// //   }
// //
// //   Future<void> fetchProductsByColor(String color) async {
// //     final apiUrl = 'https://stage.aashniandco.com/rest/V1/solr/color?colorName=$color';
// //
// //     try {
// //       HttpClient httpClient = HttpClient();
// //       httpClient.badCertificateCallback = (cert, host, port) => true;
// //       IOClient ioClient = IOClient(httpClient);
// //
// //       final response = await ioClient.get(Uri.parse(apiUrl), headers: {"Connection": "keep-alive"});
// //
// //       if (response.statusCode == 200) {
// //         final jsonData = json.decode(response.body);
// //         setState(() {
// //           products = jsonData[1]['docs'] ?? [];
// //           isLoading = false;
// //         });
// //       } else {
// //         setState(() {
// //           error = 'Failed to load products: ${response.statusCode}';
// //           isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         error = 'Error: $e';
// //         isLoading = false;
// //       });
// //     }
// //   }
// //
// //
// //
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (isLoading) {
// //       return const Scaffold(body: Center(child: CircularProgressIndicator()));
// //     }
// //
// //     if (error.isNotEmpty) {
// //       return Scaffold(body: Center(child: Text(error)));
// //     }
// //
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Results for ${widget.selectedColor}'),
// //       ),
// //       body:  ListView.builder(
// //       itemCount: products.length,
// //       itemBuilder: (context, index) {
// //         final product = products[index];
// //         return ListTile(
// //           title: Text(product['prod_name']?[0] ?? ''),
// //           subtitle: Text('Designer: ${product['designer_name'] ?? ''}'),
// //           leading: Image.network(
// //             product['prod_small_img'] ?? '',
// //             width: 50,
// //             errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
// //           ),
// //           trailing: Text("₹${product['actual_price_1'] ?? ''}"),
// //         );
// //       },
// //     )
// //     ,
// //     );
// //   }
// // }
