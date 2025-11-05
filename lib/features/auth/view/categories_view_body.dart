
import 'package:flutter/material.dart';

import '../../categories/bloc/megamenu_bloc.dart';
import '../../categories/bloc/megamenu_state.dart';
import '../../categories/view/menu_categories_screen1.dart';
import '../../newin/view/new_in_category_designer.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
/// This widget contains ONLY the UI for the list of categories.
/// It does NOT have a Scaffold, AppBar, or BottomNavigationBar.
class CategoriesViewBody extends StatelessWidget {
  const CategoriesViewBody({super.key});

  void _navigateToMenuScreen(BuildContext context, String categoryName) {
    final nameLower = categoryName.toLowerCase();

    if (nameLower.contains('designers')) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DesignerListScreen()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MenuCategoriesScreen(categoryName: categoryName),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 🔥 Makes full screen white
      body: BlocBuilder<MegamenuBloc, MegamenuState>(
        builder: (context, state) {
          if (state is MegamenuLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MegamenuLoaded) {
            final categories = state.menuNames;
            return ListView.builder(
              padding: const EdgeInsets.all(12.0),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final name = categories[index];
                return GestureDetector(
                  onTap: () => _navigateToMenuScreen(context, name),
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white, // ✅ Card color also white (optional)
                    child: Container(
                      height: 70,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black, // ensure text visible
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
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

// Widget build(BuildContext context) {
  //
  //   // This BlocBuilder and ListView is the core content.
  //   return BlocBuilder<MegamenuBloc, MegamenuState>(
  //     builder: (context, state) {
  //       if (state is MegamenuLoading) {
  //         return const Center(child: CircularProgressIndicator());
  //       } else if (state is MegamenuLoaded) {
  //         final categories = state.menuNames;
  //         return ListView.builder(
  //
  //           padding: const EdgeInsets.all(12.0),
  //           itemCount: categories.length,
  //           itemBuilder: (context, index) {
  //             final name = categories[index];
  //             return GestureDetector(
  //               onTap: () => _navigateToMenuScreen(context, name),
  //               child: Card(
  //                 elevation: 2,
  //                 margin: const EdgeInsets.only(bottom: 10.0),
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //                 color: Colors.white,
  //                 child: Container(
  //                   height: 70,
  //                   alignment: Alignment.center,
  //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                   child: Text(
  //                     name,
  //                     style: const TextStyle(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.w600,
  //                     ),
  //                     maxLines: 1,
  //                     overflow: TextOverflow.ellipsis,
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //         );
  //       } else if (state is MegamenuError) {
  //         return Center(child: Text('Error: ${state.message}'));
  //       } else {
  //         return const Center(child: Text('No categories found.'));
  //       }
  //     },
  //   );
  // }
}
