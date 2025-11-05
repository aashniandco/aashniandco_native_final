
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/view/search_webview_screen.dart';
import '../features/newin/bloc/new_in_products_state.dart';
import '../features/newin/bloc/newin_products_bloc.dart';
import '../features/newin/view/product_card.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   String searchQuery = '';
//
//   @override
//   Widget build(BuildContext context) {
//     final bloc = context.read<NewInProductsBloc>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: TextField(
//           autofocus: true,
//           decoration: const InputDecoration(
//             hintText: 'Search products...',
//             border: InputBorder.none,
//           ),
//           onChanged: (value) {
//             setState(() {
//               searchQuery = value;
//             });
//           },
//         ),
//         backgroundColor: Colors.white,
//         iconTheme: const IconThemeData(color: Colors.black),
//       ),
//       body: BlocBuilder<NewInProductsBloc, NewInProductsState>(
//         builder: (context, state) {
//           if (state is NewInProductsLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is NewInProductsLoaded) {
//             final filteredProducts = state.products.where((product) {
//               return product.designerName.toLowerCase().contains(searchQuery.toLowerCase());
//             }).toList();
//
//             if (filteredProducts.isEmpty) {
//               return const Center(child: Text("No products found."));
//             }
//
//             return GridView.builder(
//               padding: const EdgeInsets.all(12),
//               itemCount: filteredProducts.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisExtent: 270,
//                 crossAxisSpacing: 10,
//                 mainAxisSpacing: 10,
//               ),
//               itemBuilder: (context, index) =>
//                   ProductCard(product: filteredProducts[index]),
//             );
//           } else if (state is NewInProductsError) {
//             return Center(child: Text(state.message));
//           }
//           return const SizedBox.shrink();
//         },
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'search_webview_screen.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final ImagePicker _picker = ImagePicker();
//   final TextEditingController _searchController = TextEditingController();
//   InAppWebViewController? _webViewController;
//   String _searchQuery = '';
//
//   Future<void> _takePhoto() async {
//     final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
//     if (photo != null) {
//       print('Photo taken: ${photo.path}');
//     }
//   }
//
//   Future<void> _pickFromGallery() async {
//     final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
//     if (image != null) {
//       print('Image selected from gallery: ${image.path}');
//     }
//   }
//
//   void _handleSearch(String query) {
//     setState(() {
//       _searchQuery = query.trim();
//     });
//
//     if (_searchQuery.isNotEmpty && _webViewController != null) {
//       final url =
//           "https://www.aashniandco.com/catalogsearch/result/?q=${Uri.encodeComponent(_searchQuery)}";
//       _webViewController!.loadUrl(
//         urlRequest: URLRequest(url: WebUri(url)),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String initialUrl = _searchQuery.isEmpty
//         ? "https://stage.aashniandco.com/"
//         : "https://stage.aashniandco.com/catalogsearch/result/?q=${Uri.encodeComponent(_searchQuery)}";
//
//     return Scaffold(
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: Colors.white,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: TextField(
//           controller: _searchController,
//           decoration: InputDecoration(
//             hintText: 'Search...',
//             border: InputBorder.none,
//             prefixIcon: const Icon(Icons.search, color: Colors.grey),
//             hintStyle: const TextStyle(color: Colors.grey),
//             filled: true,
//             fillColor: Colors.white,
//             contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
//           ),
//           style: const TextStyle(color: Colors.black),
//           onChanged: _handleSearch,
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           // Upload section
//           Container(
//             padding: const EdgeInsets.symmetric(vertical: 16.0),
//             decoration: const BoxDecoration(
//               color: Colors.white,
//               border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Column(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.camera_alt, size: 30),
//                       onPressed: _takePhoto,
//                     ),
//                     const Text("Take a photo", style: TextStyle(fontSize: 12)),
//                   ],
//                 ),
//                 Column(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.photo, size: 30),
//                       onPressed: _pickFromGallery,
//                     ),
//                     const Text("Upload from gallery", style: TextStyle(fontSize: 12)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//
//           // WebView
//           Expanded(
//             child: InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(initialUrl)),
//               initialOptions: InAppWebViewGroupOptions(
//                 crossPlatform: InAppWebViewOptions(javaScriptEnabled: true),
//               ),
//               onWebViewCreated: (controller) {
//                 _webViewController = controller;
//               },
//               shouldOverrideUrlLoading: (controller, navigationAction) async {
//                 final uri = navigationAction.request.url;
//                 if (uri != null && uri.scheme == 'http') {
//                   final secureUri = WebUri(uri.toString().replaceFirst("http://", "https://"));
//                   await controller.loadUrl(urlRequest: URLRequest(url: secureUri));
//                   return NavigationActionPolicy.CANCEL;
//                 }
//                 return NavigationActionPolicy.ALLOW;
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



//16 july 2025
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ImagePicker _picker = ImagePicker();

  // Method to open the camera
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      print('Photo taken: ${photo.path}');
    }
  }

  // Method to open the gallery
  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Image selected from gallery: ${image.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: TextField(
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search, color: Colors.grey),
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
          ),
          style: const TextStyle(color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Take a photo and gallery options container
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1.0),
              ),
            ),
            // child: Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     Column(
            //       children: [
            //         // IconButton(
            //         //   icon: const Icon(Icons.camera_alt, size: 30),
            //         //   onPressed: _takePhoto,
            //         // ),
            //         const Text("Take a photo", style: TextStyle(fontSize: 12)),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         IconButton(
            //           icon: const Icon(Icons.photo, size: 30),
            //           onPressed: _pickFromGallery,
            //         ),
            //         const Text("Upload from gallery", style: TextStyle(fontSize: 12)),
            //       ],
            //     ),
            //   ],
            // ),
          ),
          // ListView for search suggestions
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8.0),
              children: [
                ListTile(
                  title: const Text("Kika Vargas"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.history, color: Colors.grey),
                  onTap: () {
                    print("Kika Vargas selected");
                  },
                ),
                ListTile(
                  title: const Text("Maison Margiela"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Maison Margiela selected");
                  },
                ),
                ListTile(
                  title: const Text("Marla Aaron"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Marla Aaron selected");
                  },
                ),
                ListTile(
                  title: const Text("Savette"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("Savette selected");
                  },
                ),
                ListTile(
                  title: const Text("CALL IT BY YOUR NAME"),
                  subtitle: const Text("Designer"),
                  leading: const Icon(Icons.search, color: Colors.grey),
                  onTap: () {
                    print("CALL IT BY YOUR NAME selected");
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}