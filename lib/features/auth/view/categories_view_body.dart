
import 'package:aashniandco/features/categories/bloc/megamenu_event.dart';
import 'package:flutter/material.dart';

import '../../../widgets/no_internet_widget.dart';
import '../../categories/bloc/megamenu_bloc.dart';
import '../../categories/bloc/megamenu_state.dart';
import '../../categories/model/megamenu_model.dart';
import '../../categories/view/menu_categories_screen1.dart';
import '../../newin/view/new_in_category_designer.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'native_product_screen.dart';
/// This widget contains ONLY the UI for the list of categories.
/// It does NOT have a Scaffold, AppBar, or BottomNavigationBar.
// class CategoriesViewBody extends StatelessWidget {
//   const CategoriesViewBody({super.key});
//
//   void _navigateToMenuScreen(BuildContext context, String categoryName) {
//     final nameLower = categoryName.toLowerCase();
//
//     if (nameLower.contains('designers')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DesignerListScreen()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MenuCategoriesScreen(categoryName: categoryName),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white, // 🔥 Makes full screen white
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuNames;
//             return ListView.builder(
//               padding: const EdgeInsets.all(12.0),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final name = categories[index];
//                 return GestureDetector(
//                   onTap: () => _navigateToMenuScreen(context, name),
//                   child: Card(
//                     elevation: 2,
//                     margin: const EdgeInsets.only(bottom: 10.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     color: Colors.white, // ✅ Card color also white (optional)
//                     child: Container(
//                       height: 70,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black, // ensure text visible
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return const Center(child: Text('No categories found.'));
//           }
//         },
//       ),
//     );
//   }
//
// // Widget build(BuildContext context) {
//   //
//   //   // This BlocBuilder and ListView is the core content.
//   //   return BlocBuilder<MegamenuBloc, MegamenuState>(
//   //     builder: (context, state) {
//   //       if (state is MegamenuLoading) {
//   //         return const Center(child: CircularProgressIndicator());
//   //       } else if (state is MegamenuLoaded) {
//   //         final categories = state.menuNames;
//   //         return ListView.builder(
//   //
//   //           padding: const EdgeInsets.all(12.0),
//   //           itemCount: categories.length,
//   //           itemBuilder: (context, index) {
//   //             final name = categories[index];
//   //             return GestureDetector(
//   //               onTap: () => _navigateToMenuScreen(context, name),
//   //               child: Card(
//   //                 elevation: 2,
//   //                 margin: const EdgeInsets.only(bottom: 10.0),
//   //                 shape: RoundedRectangleBorder(
//   //                   borderRadius: BorderRadius.circular(10),
//   //                 ),
//   //                 color: Colors.white,
//   //                 child: Container(
//   //                   height: 70,
//   //                   alignment: Alignment.center,
//   //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//   //                   child: Text(
//   //                     name,
//   //                     style: const TextStyle(
//   //                       fontSize: 18,
//   //                       fontWeight: FontWeight.w600,
//   //                     ),
//   //                     maxLines: 1,
//   //                     overflow: TextOverflow.ellipsis,
//   //                   ),
//   //                 ),
//   //               ),
//   //             );
//   //           },
//   //         );
//   //       } else if (state is MegamenuError) {
//   //         return Center(child: Text('Error: ${state.message}'));
//   //       } else {
//   //         return const Center(child: Text('No categories found.'));
//   //       }
//   //     },
//   //   );
//   // }
// }

//8/12/2025
// class CategoriesViewBody extends StatelessWidget {
//   const CategoriesViewBody({super.key});
//
//   // Helper to extract "black-friday-sale-2025" from the full URL
//   String _extractUrlKey(String fullUrl) {
//     if (fullUrl.isEmpty) return '';
//     try {
//       Uri uri = Uri.parse(fullUrl);
//       String path = uri.path; // Returns "/black-friday-sale-2025.html"
//
//       // Remove leading slash
//       if (path.startsWith('/')) {
//         path = path.substring(1);
//       }
//       // Remove .html extension
//       if (path.endsWith('.html')) {
//         path = path.replaceAll('.html', '');
//       }
//       // Remove trailing slash (for cases like /designer/)
//       if (path.endsWith('/')) {
//         path = path.substring(0, path.length - 1);
//       }
//       return path;
//     } catch (e) {
//       return '';
//     }
//   }
//   void _navigateToMenuScreen(BuildContext context, MegamenuItem item) {
//     final nameLower = item.name.toLowerCase();
//     final String extractedKey = _extractUrlKey(item.url);
//     if (nameLower.contains('designers')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DesignerListScreen()),
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MenuCategoriesScreen(categoryName: item.name,urlKey: extractedKey),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//
//             // ✅ FIX 1: Use 'menuItems' (List<MegamenuItem>) instead of 'menuNames'
//             final categories = state.menuItems;
//
//             return ListView.builder(
//               padding: const EdgeInsets.all(12.0),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//
//                 // ✅ FIX 2: Get the object
//                 final item = categories[index];
//
//                 // ✅ FIX 3: Get the name string from the object
//                 final name = item.name;
//
//                 return GestureDetector(
//                   onTap: () => _navigateToMenuScreen(context, item),
//                   child: Card(
//                     elevation: 2,
//                     margin: const EdgeInsets.only(bottom: 10.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     color: Colors.white,
//                     child: Container(
//                       height: 70,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Text(
//                         name.toUpperCase(), // Display the name
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.red,
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return const Center(child: Text('No categories found.'));
//           }
//         },
//       ),
//     );
//   }
// }

//
// class CategoriesViewBody extends StatelessWidget {
//   const CategoriesViewBody({super.key});
//
//   // ---------------------------------------------------------------------------
//   // 1. IMAGE MAPPING LOGIC
//   // Map the API category name (lowercase) to your local asset path.
//   // ---------------------------------------------------------------------------
//   String _getBackgroundImage(String categoryName) {
//     final name = categoryName.toLowerCase().trim();
//
//     switch (name) {
//       case 'New IN':
//         return 'assets/NEWIN.jpg';
//
//       case 'Designers': // FIXED: Changed from 'designer' to match your log
//         return 'assets/Designers.jpg';
//
//       case 'WOMEN': // FIXED: Changed from 'women-' to match your log
//         return 'assets/WOMEN.jpg';
//
//       case 'Bestsellers':
//         return 'assets/Bestsellers.jpg';
//
//       case 'Jewelry': // Ensure this spelling matches API (e.g. 'jewellery' vs 'jewelry')
//         return 'assets/Jewlery.jpg';
//
//       case 'Accessories':
//         return 'assets/Accessories.jpg';
//
//       case 'MEN':
//         return 'assets/MEN.jpg';
//
//       case 'Wedding':
//         return 'assets/Wedding.jpg';
//
//       case 'Kids':
//         return 'assets/Kids.jpg';
//
//       case 'Offers':
//         return 'assets/Offers.jpg';
//
//       case 'Ready To Ship':
//         return 'assets/Ready To Ship.jpg';
//
//       case 'Journal':
//         return 'assets/Journal.jpg';
//
//       default:
//       // Use an existing image as fallback so you don't get a crash/grey box
//         return 'assets/NEWIN.jpg';
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // 2. NAVIGATION LOGIC (Kept from your original code)
//   // ---------------------------------------------------------------------------
//   void _navigateToMenuScreen(BuildContext context, MegamenuItem item) {
//     final nameLower = item.name.toLowerCase();
//
//     // Handle Designers
//     if (nameLower.contains('designers')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DesignerListScreen()),
//       );
//       return;
//     }
//
//     // Native URL Flow
//     bool useNativeUrlFlow = nameLower.contains('offers') ||
//         nameLower.contains('weddings') ||
//         nameLower.contains('ready to ship') ||
//         nameLower.contains('sale');
//
//     if (useNativeUrlFlow) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => NativeCategoryScreen(url: item.url),
//         ),
//       );
//     } else {
//       // Standard Navigation
//       String extractedKey = _extractUrlKey(item.url);
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MenuCategoriesScreen(categoryName: item.name, urlKey: extractedKey),
//         ),
//       );
//     }
//   }
//
//   String _extractUrlKey(String fullUrl) {
//     if (fullUrl.isEmpty) return '';
//     try {
//       Uri uri = Uri.parse(fullUrl);
//       String path = uri.path;
//       if (path.startsWith('/')) path = path.substring(1);
//       if (path.endsWith('.html')) path = path.replaceAll('.html', '');
//       if (path.endsWith('/')) path = path.substring(0, path.length - 1);
//       return path;
//     } catch (e) {
//       return '';
//     }
//   }
//
//   // ---------------------------------------------------------------------------
//   // 3. UI BUILD
//   // ---------------------------------------------------------------------------
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuItems;
//
//             return ListView.separated(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//               itemCount: categories.length,
//               separatorBuilder: (context, index) => const SizedBox(height: 16),
//               itemBuilder: (context, index) {
//                 final item = categories[index];
//                 final imagePath = _getBackgroundImage(item.name);
//
//                 return _buildAestheticCard(context, item, imagePath);
//               },
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return const Center(child: Text('No categories found.'));
//           }
//         },
//       ),
//     );
//   }
//
//   Widget _buildAestheticCard(BuildContext context, MegamenuItem item, String assetPath) {
//     return GestureDetector(
//       onTap: () => _navigateToMenuScreen(context, item),
//       child: Container(
//         height: 140, // Fixed height for uniformity
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           // Subtle shadow behind the card
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.15),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(1),
//           child: Stack(
//             children: [
//               // LAYER 1: The Static Image
//               Positioned.fill(
//                 child: Image.asset(
//                   assetPath,
//                   fit: BoxFit.cover, // Ensures image fills the area without distortion
//                   errorBuilder: (context, error, stackTrace) {
//                     // Safety check if asset is missing
//                     return Container(color: Colors.grey);
//                   },
//                 ),
//               ),
//
//               // LAYER 2: Gradient Overlay (Scrim)
//               // This makes the text readable regardless of the image brightness
//               // Positioned.fill(
//               //   child: Container(
//               //     decoration: BoxDecoration(
//               //       gradient: LinearGradient(
//               //         begin: Alignment.topCenter,
//               //         end: Alignment.bottomCenter,
//               //         colors: [
//               //           Colors.black.withOpacity(0.1), // Light top
//               //           Colors.black.withOpacity(0.7), // Dark bottom
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // ),
//
//               // LAYER 3: The Text
//               // Center(
//               //   child: Padding(
//               //     padding: const EdgeInsets.all(8.0),
//               //     child: Text(
//               //       item.name.toUpperCase(),
//               //       textAlign: TextAlign.center,
//               //       style: const TextStyle(
//               //         color: Colors.white,
//               //         fontSize: 24, // Large font
//               //         fontWeight: FontWeight.w700, // Bold
//               //         letterSpacing: 2.0, // Wder spacing for "Luxury" feel
//               //         fontFamily: 'Didot', // Optional: Use a serif font if you have one
//               //         shadows: [
//               //           Shadow(
//               //             offset: Offset(0, 2),
//               //             blurRadius: 4.0,
//               //             color: Colors.black, // Drop shadow for text pop
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Import your bloc and other screens here
// import '...';

class CategoriesViewBody extends StatelessWidget {
  const CategoriesViewBody({super.key});

  // ---------------------------------------------------------------------------
  // 1. IMAGE MAPPING LOGIC
  // Maps API names to the EXACT asset paths you provided.
  // ---------------------------------------------------------------------------
  String _getBackgroundImage(String categoryName) {
    // 1. Everything becomes lowercase here
    final name = categoryName.toLowerCase().trim();

    switch (name) {
    // ✅ FIXED: Changed 'NEW IN' to 'new in' (lowercase)
      case 'new in':
        return 'assets/NEWIN.jpg';

    // ✅ FIXED: Changed 'designer' to 'designers' (plural)
      case 'designers':
        return 'assets/Designers.jpg';

      case 'women':
        return 'assets/WOMEN.jpg';

      case 'bestsellers':
        return 'assets/Bestsellers.jpg';

    // ✅ FIXED: Changed 'jewlery' to 'jewelry' (correct spelling for the check)
      case 'jewelry':
      // Note: Keeping the return path as 'Jewlery.jpg' assuming your
      // file is actually named with that typo on disk.
      // If the file is 'Jewlery.jpg', update this string too.
        return 'assets/Jewlery.jpg';

      case 'accessories':
        return 'assets/Accessories.jpg';

      case 'men':
        return 'assets/MEN.jpg';

    // ✅ FIXED: Changed 'wedding' to 'weddings' (plural)
      case 'weddings':
        return 'assets/Wedding.jpg';

      case 'kids':
        return 'assets/Kids.jpg';

      case 'eoss':
        return 'assets/Offers.jpg';

      case 'ready to ship':
        return 'assets/Ready To Ship.jpg';

      case 'journal':
        return 'assets/Journal.jpg';

      default:
      // Generic fallback
        return 'assets/NEWIN.jpg';
    }
  }

  // ---------------------------------------------------------------------------
  // 2. NAVIGATION LOGIC
  // ---------------------------------------------------------------------------
  void _navigateToMenuScreen(BuildContext context, MegamenuItem item) {
    final nameLower = item.name.toLowerCase();

    if (nameLower.contains('designers')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DesignerListScreen()),
      );
      return;
    }

    bool useNativeUrlFlow = nameLower.contains('offers') ||
        nameLower.contains('weddings') ||
        nameLower.contains('ready to ship') ||
        nameLower.contains('sale')||
        nameLower.contains('men')||
        nameLower.contains('eoss')||
        nameLower.contains('new in');

    if (useNativeUrlFlow) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NativeCategoryScreen(url: item.url),
        ),
      );
    } else {
      String extractedKey = _extractUrlKey(item.url);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuCategoriesScreen(categoryName: item.name, urlKey: extractedKey),
        ),
      );
    }
  }

  String _extractUrlKey(String fullUrl) {
    if (fullUrl.isEmpty) return '';
    try {
      Uri uri = Uri.parse(fullUrl);
      String path = uri.path;
      if (path.startsWith('/')) path = path.substring(1);
      if (path.endsWith('.html')) path = path.replaceAll('.html', '');
      if (path.endsWith('/')) path = path.substring(0, path.length - 1);
      return path;
    } catch (e) {
      return '';
    }
  }

  // ---------------------------------------------------------------------------
  // 3. UI BUILD
  // ---------------------------------------------------------------------------
  @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.white,
  //     body: BlocBuilder<MegamenuBloc, MegamenuState>(
  //       builder: (context, state) {
  //         if (state is MegamenuLoading) {
  //           return const Center(child: CircularProgressIndicator());
  //         } else if (state is MegamenuLoaded) {
  //           final categories = state.menuItems;
  //
  //           return ListView.separated(
  //             padding: const EdgeInsets.all(16.0),
  //             itemCount: categories.length,
  //             separatorBuilder: (context, index) => const SizedBox(height: 16),
  //             itemBuilder: (context, index) {
  //               final item = categories[index];
  //               // Get the specific image for this category
  //               final imagePath = _getBackgroundImage(item.name);
  //
  //               return _buildImageCard(context, item, imagePath);
  //             },
  //           );
  //         } else if (state is MegamenuError) {
  //           return Center(child: Text('Error: ${state.message}'));
  //         } else {
  //           return const Center(child: Text('No categories found.'));
  //         }
  //       },
  //     ),
  //   );
  // }

  // Widget _buildImageCard(BuildContext context, MegamenuItem item, String assetPath) {
  //   return GestureDetector(
  //     onTap: () => _navigateToMenuScreen(context, item),
  //     child: Container(
  //       height: 140, // Height of the card
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.black.withOpacity(0.1),
  //             blurRadius: 8,
  //             offset: const Offset(0, 4),
  //           ),
  //         ],
  //       ),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             // 1. BACKGROUND IMAGE
  //             Image.asset(
  //               assetPath,
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) {
  //                 return Container(color: Colors.grey[300]); // Fallback color
  //               },
  //             ),
  //
  //             // 2. DARK OVERLAY (To make white text readable)
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.black.withOpacity(0.35), // Adjust darkness here
  //               ),
  //             ),
  //
  //             // 3. TEXT LABEL
  //             Center(
  //               child: Text(
  //                 item.name.toUpperCase(),
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   letterSpacing: 1.2,
  //                   shadows: [
  //                     Shadow(
  //                       offset: Offset(0, 2),
  //                       blurRadius: 4.0,
  //                       color: Colors.black54,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildImageCard(BuildContext context, MegamenuItem item, String assetPath) {
  //   return GestureDetector(
  //     onTap: () => _navigateToMenuScreen(context, item),
  //     child: Container(
  //       height: 140,
  //       width: double.infinity,
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(12),
  //         // ✅ CHANGED: Removed boxShadow to remove the border/shadow effect
  //       ),
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             // 1. BACKGROUND IMAGE
  //             Image.asset(
  //               assetPath,
  //               fit: BoxFit.cover,
  //               errorBuilder: (context, error, stackTrace) {
  //                 return Container(color: Colors.grey[300]);
  //               },
  //             ),
  //
  //             // 2. DARK OVERLAY
  //             Container(
  //               decoration: BoxDecoration(
  //                 color: Colors.black.withOpacity(0.35),
  //               ),
  //             ),
  //
  //             // 3. TEXT LABEL
  //             Center(
  //               child: Text(
  //                 item.name.toUpperCase(),
  //                 style: const TextStyle(
  //                   color: Colors.white,
  //                   fontSize: 22,
  //                   fontWeight: FontWeight.bold,
  //                   letterSpacing: 1.2,
  //                   shadows: [
  //                     Shadow(
  //                       offset: Offset(0, 2),
  //                       blurRadius: 4.0,
  //                       color: Colors.black54,
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<MegamenuBloc, MegamenuState>(
        builder: (context, state) {
          ///
          if (state is MegamenuError) {
            // Use the helper to check if it's a network issue
            if (isNetworkError(state.message)) {
              return NoInternetWidget(
                onRetry: () {
                  // 🔄 Retry Logic: Trigger the start event again
                  context.read<MegamenuBloc>().add(LoadMegamenu());
                },
              );
            }
            // Optional: Handle non-internet errors here if needed
          }


          ///
          if (state is MegamenuLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MegamenuLoaded) {
            final categories = state.menuItems;

            return ListView.separated(
              // ✅ CHANGED: Padding Left, Right, and Top
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 20),
              itemCount: categories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final item = categories[index];
                final imagePath = _getBackgroundImage(item.name);
                return _buildImageCard(context, item, imagePath);
              },
            );
          } else if (state is MegamenuError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No categories found.'));
          }
        },
      ),
    );
  }

  Widget _buildImageCard(BuildContext context, MegamenuItem item, String assetPath) {
    return GestureDetector(
      onTap: () => _navigateToMenuScreen(context, item),
      // ✅ CHANGED: Use ClipRRect for rounded corners
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(10), // Smooth corners
        child: Image.asset(
          assetPath,
          width: double.infinity,
          // ✅ CHANGED: BoxFit.fitWidth ensures the whole image is seen
          // It automatically adjusts height based on image aspect ratio.
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return Container(height: 100, color: Colors.grey[300]);
          },
        ),
      ),
    );
  }
  bool isNetworkError(String message) {
    return message.contains("SocketException") ||
        message.contains("ClientException") ||
        message.contains("Failed host lookup");
  }

}
//10/12/2025
// class CategoriesViewBody extends StatelessWidget {
//   const CategoriesViewBody({super.key});
//
//   void _navigateToMenuScreen(BuildContext context, MegamenuItem item) {
//     final nameLower = item.name.toLowerCase();
//
//     // 1. Handle Designers (Special Case)
//     if (nameLower.contains('designers')) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => DesignerListScreen()),
//       );
//       return;
//     }
//
//     // 2. Define which categories should use the "URL Resolver" flow.
//     // These are categories where we have a URL but need to fetch the ID from the API first.
//     bool useNativeUrlFlow = nameLower.contains('offers') ||
//         nameLower.contains('weddings') ||
//         nameLower.contains('ready to ship') ||
//         nameLower.contains('sale'); // Add 'sale' if needed
//
//     if (useNativeUrlFlow) {
//       // ✅ DIRECT FLOW: Pass the URL directly to the Native Resolver.
//       // User sees a loader, then the products. No WebView.
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => NativeCategoryScreen(url: item.url),
//         ),
//       );
//     } else {
//       // 3. Standard Navigation (for categories where you might already have logic)
//       // If you want *ALL* categories to work this way, you can remove the 'else'
//       // and send everything to NativeCategoryScreen.
//       String extractedKey = _extractUrlKey(item.url);
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => MenuCategoriesScreen(categoryName: item.name, urlKey: extractedKey),
//         ),
//       );
//     }
//   }
//
//   String _extractUrlKey(String fullUrl) {
//     if (fullUrl.isEmpty) return '';
//     try {
//       Uri uri = Uri.parse(fullUrl);
//       String path = uri.path;
//       if (path.startsWith('/')) path = path.substring(1);
//       if (path.endsWith('.html')) path = path.replaceAll('.html', '');
//       if (path.endsWith('/')) path = path.substring(0, path.length - 1);
//       return path;
//     } catch (e) {
//       return '';
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: BlocBuilder<MegamenuBloc, MegamenuState>(
//         builder: (context, state) {
//           if (state is MegamenuLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is MegamenuLoaded) {
//             final categories = state.menuItems;
//
//             return ListView.builder(
//               padding: const EdgeInsets.all(12.0),
//               itemCount: categories.length,
//               itemBuilder: (context, index) {
//                 final item = categories[index];
//                 final name = item.name;
//
//                 return GestureDetector(
//                   onTap: () => _navigateToMenuScreen(context, item),
//                   child: Card(
//                     elevation: 2,
//                     margin: const EdgeInsets.only(bottom: 10.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     color: Colors.white,
//                     child: Container(
//                       height: 70,
//                       alignment: Alignment.center,
//                       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                       child: Text(
//                         name.toUpperCase(),
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.black, // Changed to black for better UI
//                         ),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           } else if (state is MegamenuError) {
//             return Center(child: Text('Error: ${state.message}'));
//           } else {
//             return const Center(child: Text('No categories found.'));
//           }
//         },
//       ),
//     );
//   }
// }