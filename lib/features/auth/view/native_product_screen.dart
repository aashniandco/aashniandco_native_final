import 'package:flutter/material.dart';

import '../../categories/repository/api_service.dart';
import '../../search/presentation/product_list_screennew.dart';
import 'package:path/path.dart' as p;
class NativeCategoryScreen extends StatefulWidget {
  final String url;

  const NativeCategoryScreen({super.key, required this.url});

  @override
  State<NativeCategoryScreen> createState() => _NativeCategoryScreenState();
}

class _NativeCategoryScreenState extends State<NativeCategoryScreen> {
  final ApiService _apiService = ApiService();

  // State variables to manage the UI
  bool _isLoading = true;
  String? _errorMessage;
  String? _extractedSlug;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to allow the initial frame to build before navigating.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAndNavigate();
    });
  }

  Future<void> _fetchAndNavigate() async {
    try {
      // 1. Parse the URL to get the slug (e.g., "masaba")
      final uri = Uri.parse(widget.url);
      final slug = p.basenameWithoutExtension(uri.path);
      setState(() {
        _extractedSlug = slug;
      });
      print('Dispatching FetchCategoryMetadata event with slug: $slug');

      // 2. Fetch the metadata from the API
      final metadata = await _apiService.fetchCategoryMetadataByName(slug);

      // --- This logic mirrors your Bloc's success state ---
      // NOTE: The log shows 'pare_cat_id' is used for navigation.
      // The API for "masaba" returns [..., 1448, 1375], where 1448 is parent_id
      // and 1375 is cat_id. We follow the logic from your prompt.
      final String categoryId = metadata['pare_cat_id'];
      final String categoryName = metadata['cat_name'];

      print('NAVIGATION TRIGGERED: ID: $categoryId, Name: $categoryName');

      // 3. Navigate to the ProductListingScreen, replacing this handler screen.
      // Using pushReplacement is better so the user doesn't hit "back" to this loading screen.
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ProductListingScreen(
          categoryId: categoryId,
          categoryName: categoryName,
        ),
      ));

    } catch (e) {
      // If anything fails, update the UI to show the error.
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Loading Category..."),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isLoading
              ? const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text("Fetching category details..."),
            ],
          )
              : Column( // Error State UI
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 80),
              const SizedBox(height: 20),
              const Text(
                "Failed to Load Category",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Could not fetch details for "$_extractedSlug".',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage ?? "An unknown error occurred.",
                style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class NativeProductScreen extends StatelessWidget {
//   // This screen accepts the URL of the product/banner that was clicked.
//   final String url;
//
//   const NativeProductScreen({super.key, required this.url});
//
//   @override
//   Widget build(BuildContext context) {
//     // You can parse the URL here to get a product ID, name, etc.
//     // For this example, we just display the full URL.
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Native Product Page"),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
//               const SizedBox(height: 20),
//               const Text(
//                 "Navigation Intercepted!",
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "Instead of the WebView navigating, we have opened this native Flutter screen with the following link:",
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 url,
//                 style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue),
//                 textAlign: TextAlign.center,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }