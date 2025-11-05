// import 'package:aashniandco/features/newin/model/new_in_model.dart';
// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:http/io_client.dart';
// import 'dart:convert';
// import 'dart:io';
//
// class NewInScreen extends StatefulWidget {
//   const NewInScreen({super.key});
//
//   @override
//   State<NewInScreen> createState() => _NewInScreenState();
// }
//
// class _NewInScreenState extends State<NewInScreen> {
//   bool isLoading = true;
//   List<Product> products = [];
//   String selectedSort = "High to Low";
//
//   @override
//   void initState() {
//     super.initState();
//     fetchProducts();
//   }
//
//   Future<void> fetchProducts() async {
//     final url = Uri.parse("https://stage.aashniandco.com/rest/V1/solr/newin");
//     HttpClient httpClient = HttpClient();
//     httpClient.badCertificateCallback = (cert, host, port) => true;
//     IOClient ioClient = IOClient(httpClient);
//
//     try {
//       final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
//       if (response.statusCode == 200) {
//         final List<dynamic> responseList = jsonDecode(response.body);
//         final Map<String, dynamic> productData = responseList[1];
//         final List<dynamic> docs = productData['docs'];
//
//         final fetchedProducts = docs.map((json) => Product.fromJson(json)).toList();
//
//         setState(() {
//           products = fetchedProducts;
//           sortProducts();
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load products');
//       }
//     } catch (e) {
//       print("Error: $e");
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }
//
//   void sortProducts() {
//     setState(() {
//       if (selectedSort == "High to Low") {
//         products.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
//       } else {
//         products.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : products.isEmpty
//           ? const Center(child: Text("No products found"))
//           : Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             // Sort Dropdown
//             Align(
//               alignment: Alignment.centerRight,
//               child: Container(
//                 height: 35,
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 decoration: BoxDecoration(color: Colors.grey),
//                 child: DropdownButton<String>(
//                   value: selectedSort,
//                   icon: const Icon(Icons.sort, color: Colors.black),
//                   style: const TextStyle(color: Colors.white, fontSize: 14),
//                   dropdownColor: Colors.grey,
//                   underline: Container(),
//                   onChanged: (value) {
//                     setState(() {
//                       selectedSort = value!;
//                       sortProducts();
//                     });
//                   },
//                   items: ["High to Low", "Low to High"].map((sortOption) {
//                     return DropdownMenuItem<String>(
//                       value: sortOption,
//                       child: Text(sortOption, style: const TextStyle(color: Colors.black)),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),
//
//             // Product Grid
//             Expanded(
//               child: GridView.builder(
//                 itemCount: products.length,
//                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 10,
//                   mainAxisSpacing: 10,
//                   childAspectRatio: 0.55,
//                 ),
//                 itemBuilder: (context, index) {
//                   final product = products[index];
//                   return Card(
//                     color: Colors.white,
//                     elevation: 1,
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Image
//                         Flexible(
//                           child: Image.network(
//                             product.prodSmallImg,
//                             width: double.infinity,
//                             height: 550,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Container(
//                                 height: 550,
//                                 color: Colors.grey[300],
//                                 alignment: Alignment.center,
//                                 child: const Icon(Icons.image_not_supported, size: 50),
//                               );
//                             },
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//
//                         // Designer Name
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Center(
//                             child: Text(
//                               product.designerName,
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center,
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//
//                         // Short Description
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                           child: Center(
//                             child: Text(
//                               product.shortDesc,
//                               textAlign: TextAlign.center,
//                               style: const TextStyle(fontSize: 12),
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ),
//
//                         // Price
//                         Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 8.0),
//                           child: Center(
//                             child: Text(
//                               "₹${product.actualPrice.toStringAsFixed(0)}",
//                               style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           // TODO: Implement your filter logic here, like opening a modal or navigating to a filter screen
//           showModalBottomSheet(
//             context: context,
//             builder: (context) => const FilterBottomSheet(), // You can create a custom widget
//           );
//         },
//         label: const Text('Filter'),
//         icon: const Icon(Icons.filter_list_alt),
//         backgroundColor: Colors.white,
//       ),
//     );
//   }
// }
//
// class FilterBottomSheet extends StatelessWidget {
//   const FilterBottomSheet({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       height: 300,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text("Apply Filters", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 20),
//           // Add your filter controls here
//           ElevatedButton(
//             onPressed: () {
//               // Apply filters logic
//               Navigator.pop(context);
//             },
//             child: const Text("Apply"),
//           )
//         ],
//       ),
//     );
//   }
// }
