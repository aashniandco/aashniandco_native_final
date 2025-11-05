import 'package:aashniandco/features/newin/view/category_color_screen.dart';
import 'package:aashniandco/features/newin/view/category_shipin_screen.dart';
import 'package:aashniandco/features/newin/view/new_in_category_designer.dart';
import 'package:flutter/material.dart';

import 'cat_theme_screen.dart';
import 'category_acoedit_screen.dart';
import 'category_filter.dart';
import 'category_filter_screen.dart';
import 'category_gender_screen.dart';
import 'category_occassions_screen.dart';
import 'category_price_screen.dart';
import 'category_size_screen.dart';


import 'package:flutter/material.dart';

// Import all your screen destinations
import 'package:aashniandco/features/newin/view/category_color_screen.dart';
import 'package:aashniandco/features/newin/view/category_shipin_screen.dart';
// import 'package:aashniandco/features/newin/view/new_in_category_designer.dart'; // Uncomment when you have this screen
import 'cat_theme_screen.dart';
import 'category_acoedit_screen.dart';
import 'category_filter_screen.dart';
import 'category_gender_screen.dart';
import 'category_occassions_screen.dart';
import 'category_price_screen.dart';
import 'category_size_screen.dart';

import 'package:flutter/material.dart';

// Import all your screen destinations
import 'package:aashniandco/features/newin/view/category_color_screen.dart';
import 'package:aashniandco/features/newin/view/category_shipin_screen.dart';
// import 'package:aashniandco/features/newin/view/new_in_category_designer.dart'; // Uncomment when you have this screen
import 'cat_theme_screen.dart';
import 'category_acoedit_screen.dart';
import 'category_filter_screen.dart';
import 'category_gender_screen.dart';
import 'category_occassions_screen.dart';
import 'category_price_screen.dart';
import 'category_size_screen.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final List<String> filterOptions = [
    "CATEGORY", "THEME", "GENDER", "DESIGNER", "COLOR",
    "SIZE", "SHIPS IN", "PRICE", "A+CO EDITS", "OCCASIONS"
  ];

  void _navigateToFilterPage(String option) {
    // Using a switch statement is cleaner and more efficient
    switch (option) {
      case "CATEGORY":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryFilterScreen()));
        break;
      case "THEME":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryThemeScreen()));
        break;
      case "GENDER":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryGenderScreen()));
        break;
      case "DESIGNER":
      // TODO: Add navigation for Designer screen
        break;
      case "COLOR":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryColorScreen()));
        break;
      case "SIZE":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategorySizeScreen()));
        break;
      case "SHIPS IN":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryShipinScreen()));
        break;
      case "PRICE":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryPriceScreen()));
        break;
      case "A+CO EDITS":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryAcoeditScreen()));
        break;
      case "OCCASIONS":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoryOccassionsScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // This Container ensures the bottom sheet has a solid white background and rounded corners.
    return Container(
      height: 680,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Takes up only the space it needs
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Apply Filters",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            /// A subtle divider for better visual separation.
            const Divider(),
            const SizedBox(height: 8),

            /// Filter Options List
            Flexible(
              child: ListView.separated(
                itemCount: filterOptions.length,
                shrinkWrap: true,
                separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      option,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
                    onTap: () => _navigateToFilterPage(option),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            /// Action Buttons: Clear & Apply
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Implement logic to clear all selected filters
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Clear All",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement logic to apply the filters
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      "Apply",
                      style: TextStyle(fontSize: 16, letterSpacing: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//18/7/2025

// class FilterBottomSheet extends StatefulWidget {
//   const FilterBottomSheet({super.key});
//
//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }
//
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   final List<String> filterOptions = [
//     "CATEGORY",
//     "THEME",
//     "GENDER",
//     "DESIGNER",
//     "COLOR",
//     "SIZE",
//     "SHIPS IN",
//     "PRICE",
//     "A+CO EDITS",
//     "Occasions"
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 680,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// Title & Close Icon
//           Row(
//             children: [
//               const Expanded(
//                 child: Text(
//                   "Apply Filters",
//                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: const Icon(Icons.close, size: 26, color: Colors.grey),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 20),
//
//           /// Filter Options List
//           Expanded(
//             child: ListView.builder(
//               itemCount: filterOptions.length,
//               itemBuilder: (context, index) {
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 10),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFFD3D4D3),
//                     borderRadius: BorderRadius.circular(12),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         blurRadius: 6,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: ListTile(
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     title: Text(
//                       filterOptions[index],
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black54),
//                     onTap: () {
//                       final selectedOption = filterOptions[index];
//                       if (selectedOption == "CATEGORY") {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             // builder: (_) => const CategoryFilterScreen(),
//                             builder: (_) => const CategoryFilterScreen(),
//                           ),
//                         );
//                       }
//
//                       else if(selectedOption == "THEME"){
//
//                      Navigator.push(context, MaterialPageRoute(builder:
//                      (_)=> const CategoryThemeScreen()
//                      )
//                      );
//
//                       }
//
//                       else if(selectedOption == "GENDER"){
//
//                         Navigator.push(context, MaterialPageRoute(builder:
//                             (_)=> const CategoryGenderScreen()
//                         )
//                         );
//
//                       }
//
//                       else if(selectedOption == "DESIGNER"){
//
//                         // Navigator.push(context, MaterialPageRoute(builder:
//                         //     (_)=> const DesignerListScreen()
//                         // )
//                         // );
//
//                       }
//
//                       else if(selectedOption == "COLOR"){
//
//                         Navigator.push(context, MaterialPageRoute(builder:
//                             (_)=> const CategoryColorScreen()
//                         )
//                         );
//
//                       }
//
//                       else if (selectedOption == "SIZE"){
//                         Navigator.push(context, MaterialPageRoute(builder: (_)=> const
//
//                         CategorySizeScreen()));
//
//                       }
//
//                       else if (selectedOption == "SHIPS IN"){
//
//                         Navigator.push(context, MaterialPageRoute(builder: (_)=> const
//                         CategoryShipinScreen()
//                         ));
//                       }
//
//                       else if (selectedOption == "A+CO EDITS"){
//
//                         Navigator.push(context, MaterialPageRoute(builder: (_)=> const
//                         CategoryAcoeditScreen()
//                         ));
//                       }
//
//                       else if (selectedOption == "Occasions"){
//
//                         Navigator.push(context,MaterialPageRoute(builder: (_)=> const
//                         CategoryOccassionsScreen()
//                         ));
//                       }
//
//                       else if (selectedOption == "PRICE"){
//
//                         Navigator.push(context,MaterialPageRoute(builder: (_)=> const
//                         CategoryPriceScreen()
//                         ));
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//
//           const SizedBox(height: 12),
//
//           /// Apply Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 backgroundColor: Colors.black,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 elevation: 4,
//               ),
//               child: const Text(
//                 "Apply",
//                 style: TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 0.5),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// }

