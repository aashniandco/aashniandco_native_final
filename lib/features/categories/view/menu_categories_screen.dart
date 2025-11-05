import 'package:aashniandco/features/auth/view/login_screen.dart';
import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/auth/view/wishlist_screen.dart';
import 'package:aashniandco/features/categories/view/categories_screen.dart';
import 'package:aashniandco/features/categories/view/mens_blazer_screen.dart';
import 'package:flutter/material.dart';

// class MenuScreen extends StatefulWidget {
//   @override
//   _MenuScreenState createState() => _MenuScreenState();
// }

// class _MenuScreenState extends State<MenuScreen> {
//   // Example data for dropdowns
//   String? _selectedDesigner;
//   String? _selectedCategory;
//   String? _selectedOption1;
//   String? _selectedOption2;
//   String? _selectedOption3;

//   final List<String> designers = ["Designer 1", "Designer 2", "Designer 3"];
//   final List<String> categories = ["Category 1", "Category 2", "Category 3"];
//   final List<String> options = ["Option 1", "Option 2", "Option 3"];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Menu Screen"),
//       ),
//       body: ListView(
//         padding: EdgeInsets.all(8),
//         children: [
//           _buildMenuCard("Designers", designers, _selectedDesigner, (newValue) {
//             setState(() {
//               _selectedDesigner = newValue;
//             });
//           }),
//           _buildMenuCard("Categories", categories, _selectedCategory, (newValue) {
//             setState(() {
//               _selectedCategory = newValue;
//             });
//           }),
//           _buildMenuCard("Option 1", options, _selectedOption1, (newValue) {
//             setState(() {
//               _selectedOption1 = newValue;
//             });
//           }),
//           _buildMenuCard("Option 2", options, _selectedOption2, (newValue) {
//             setState(() {
//               _selectedOption2 = newValue;
//             });
//           }),
//           _buildMenuCard("Option 3", options, _selectedOption3, (newValue) {
//             setState(() {
//               _selectedOption3 = newValue;
//             });
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _buildMenuCard(String title, List<String> options, String? selectedOption, ValueChanged<String?> onChanged) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8),
//       elevation: 4,
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 10),
//             DropdownButton<String>(
//               value: selectedOption,
//               hint: Text("Select $title"),
//               onChanged: onChanged,
//               items: options.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




class ShopByCategoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop By Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            buildCategoryCardWithExpansion(
              context: context,
              title: 'Designers',
              children: [
                buildSubCategory(context, 'Aarti Sethia'),
                buildSubCategory(context, 'Abhinav Mishra'),
                buildSubCategory(context, 'Abhishek Sharma'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'Category',
              children: [
                buildSubCategory(context, 'Blazers'),
                buildSubCategory(context, 'Kurtas'),
                buildSubCategory(context, 'Shirts'),
                buildSubCategory(context, 'Sherwanis'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'Occasions',
              children: [
                buildSubCategory(context, 'Wedding'),
                buildSubCategory(context, 'Festive'),
                buildSubCategory(context, 'Party'),
                buildSubCategory(context, 'Puja'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'A + Co Edits',
              children: [
                buildSubCategory(context, 'Celebrity Spotting'),
                buildSubCategory(context, 'Cult Finds'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'Themes',
              children: [
                buildSubCategory(context, 'Contemporary'),
                buildSubCategory(context, 'Ethnic'),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
        ],
        onTap: (index) {
          // Navigate based on the tapped index
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AuthScreen()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WishlistScreen()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => AccountScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget buildCategoryCardWithExpansion({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: ExpansionTile(
        title: Text(
          title,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        children: children,
      ),
    );
  }

  Widget buildSubCategory(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14),
      ),
      onTap: () {
        // Handle navigation based on the title
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (title == 'Blazers') {
                return BlazersCategoryScreen(); // Replace with your specific screen
              }
              // Add other conditions here if needed
              return PlaceholderScreen(title: title);
            },
          ),
        );
      },
    );
  }
}



class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text('This is the $title screen'),
      ),
    );
  }
}
