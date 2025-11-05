
import 'package:flutter/material.dart';
import 'package:aashniandco/constants/api_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:aashniandco/features/newin/bloc/product_repository.dart';
import 'package:aashniandco/features/newin/bloc/new_in_bloc.dart';
import '../bloc/new_in_products_event.dart';
import '../bloc/newin_products_bloc.dart';
import 'new_in_products_screen.dart';

class CategoryResultScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCategories;

  const CategoryResultScreen({super.key, required this.selectedCategories});

  void _navigateToScreen(BuildContext context, String subcategory) {
    final subcategoryKey = ApiConstants.getApiKeyForSubcategory(subcategory);

    print("Subcategory tapped: $subcategory");
    print("Matched key from ApiConstants: $subcategoryKey");


    if (subcategoryKey != null) {
      // Wrap the NewInProductsScreen with BlocProvider
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => NewInProductsBloc(
              productRepository: ProductRepository(),
              subcategory: subcategory,
              selectedCategories: selectedCategories,
            )..add(FetchProductsEvent()), // Trigger fetch when navigating
            child: NewInProductsScreen(
              subcategory: subcategory,
              selectedCategories: selectedCategories,
              initialTab: subcategory,
              productListBuilder: (selectedCategory, selectedSort) {
                // Return a widget to show products
                return CategoryResultScreen(selectedCategories: selectedCategories);
              },
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No screen implemented for this subcategory."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Filtered Results")),
      body: ListView.builder(
        itemCount: selectedCategories.length,
        itemBuilder: (context, index) {
          final item = selectedCategories[index];
          final subcategory = item["subCategory"] ?? item["category"] ?? "Unknown";

          return ListTile(
            title: Text(subcategory),
            subtitle: item["id"] != null ? Text("ID: ${item["id"]}") : null,
            leading: const Icon(Icons.label),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _navigateToScreen(context, subcategory),
          );
        },
      ),
    );
  }
}



// import 'package:flutter/material.dart';
//
// // class CategoryResultScreen extends StatelessWidget {
// //   final List<Map<String,dynamic>> selectedCategories;
// //
// //   const CategoryResultScreen({super.key, required this.selectedCategories});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: const Text("Filtered Results")),
// //       body: ListView.builder(
// //         itemCount: selectedCategories.length,
// //         itemBuilder: (context, index) {
// //           final item= selectedCategories[index];
// //           return ListTile(
// //             title: Text(item["subCategory"]?? item["category"]),
// //             subtitle: item["id"] != null ? Text("ID: ${item["id"]}") : null,
// //             leading: const Icon(Icons.label),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
//
//
// import 'package:flutter/material.dart';
// import 'package:aashniandco/constants/api_constants.dart';
//
// // Import other category screens as needed...
//
// import 'package:flutter/material.dart';
// import 'package:aashniandco/constants/api_constants.dart';
//
// import 'new_in_products_screen.dart';
// import 'new_in_wc_lehengas_screen.dart';
//
// // Import other screens as needed
//
// import 'package:flutter/material.dart';
// import 'package:aashniandco/constants/api_constants.dart';
// import 'new_in_wc_lehengas_screen.dart';
//
// class CategoryResultScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const CategoryResultScreen({super.key, required this.selectedCategories});
//
//   void _navigateToScreen(BuildContext context, String subcategory) {
//     final subcategoryKey = ApiConstants.getApiKeyForSubcategory(subcategory);
//
//     print("Subcategory tapped: $subcategory");
//     print("Matched key from ApiConstants: $subcategoryKey");
//
//     if (subcategoryKey != null) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => NewInProductsScreen(
//             subcategory: subcategory,
//             selectedCategories: selectedCategories,
//             initialTab: subcategory,
//             productListBuilder: (selectedCategory, selectedSort) {
//               // Return a widget to show products. You can replace this with your actual implementation.
//               return CategoryResultScreen(selectedCategories: selectedCategories);
//             },
//           ),
//         ),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("No screen implemented for this subcategory."),
//         ),
//       );
//     }
//   }
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Filtered Results")),
//       body: ListView.builder(
//         itemCount: selectedCategories.length,
//         itemBuilder: (context, index) {
//           final item = selectedCategories[index];
//           final subcategory = item["subCategory"] ?? item["category"] ?? "Unknown";
//
//           return ListTile(
//             title: Text(subcategory),
//             subtitle: item["id"] != null ? Text("ID: ${item["id"]}") : null,
//             leading: const Icon(Icons.label),
//             trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () => _navigateToScreen(context, subcategory),
//           );
//         },
//       ),
//     );
//   }
// }
//
//
