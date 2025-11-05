import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:flutter/material.dart';

class Accessories extends StatefulWidget {
  @override
  _AccessoriesState createState() => _AccessoriesState();
}

class _AccessoriesState extends State<Accessories> {
  Map<String, Set<String>> selectedSubCategories = {}; // Map to track selected items for each category
  String? expandedCategoryKey; // Track the key of the currently expanded category

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Accessories'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            buildCategoryCardWithExpansion(
              context: context,
              title: 'SHOP BY',
              gradientColors: [const Color.fromARGB(255, 99, 109, 117), const Color.fromARGB(255, 88, 97, 113)],
              subCategoryKey: 'SHOP_BY',
              children: [
                buildSubCategory(context, 'Ethnic', 'SHOP_BY'),
                buildSubCategory(context, 'Contemporary', 'SHOP_BY'),
                buildSubCategory(context, 'All Accessories', 'SHOP_BY'),
                buildSubCategory(context, 'Bags', 'SHOP_BY'),
                buildSubCategory(context, 'Belts', 'SHOP_BY'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'ESSENTIAL EDITS',
              gradientColors: [const Color.fromARGB(255, 101, 116, 102), const Color.fromARGB(255, 81, 104, 101)],
              subCategoryKey: 'ESSENTIAL_EDITS',
              children: [
                buildSubCategory(context, 'Just In', 'ESSENTIAL_EDITS'),
                buildSubCategory(context, 'Festive Potlis', 'ESSENTIAL_EDITS'),
                buildSubCategory(context, 'Ready To Ship', 'ESSENTIAL_EDITS'),
                buildSubCategory(context, 'Cult Finds', 'ESSENTIAL_EDITS'),
              ],
            ),
            buildCategoryCardWithExpansion(
              context: context,
              title: 'A+CO LOVES',
              gradientColors: [const Color.fromARGB(255, 149, 136, 151), const Color.fromARGB(255, 111, 104, 107)],
              subCategoryKey: 'A_CO_LOVES',
              children: [
                buildSubCategory(context, '5 Elements by Radhika Gupta', 'A_CO_LOVES'),
                buildSubCategory(context, 'Amyra', 'A_CO_LOVES'),
                buildSubCategory(context, 'Be Chic', 'A_CO_LOVES'),
                buildSubCategory(context, 'House Of Vian', 'A_CO_LOVES'),
                buildSubCategory(context, 'Sabyasachi', 'A_CO_LOVES'),
                buildSubCategory(context, 'Soho Boho Studio', 'A_CO_LOVES'),
              ],
            ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const [
      //     BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      //     BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
      //     BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
      //   ],
      //   onTap: (index) {
      //     switch (index) {
      //       case 0:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => AuthScreen()),
      //         );
      //         break;
      //       case 1:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => WishlistScreen()),
      //         );
      //         break;
      //       case 2:
      //         Navigator.pushReplacement(
      //           context,
      //           MaterialPageRoute(builder: (context) => AccountScreen()),
      //         );
      //         break;
      //     }
      //   },
      // ),
    );
  }

  Widget buildCategoryCardWithExpansion({
    required BuildContext context,
    required String title,
    required String subCategoryKey,
    required List<Widget> children,
    required List<Color> gradientColors,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ExpansionTile(
          key: PageStorageKey<String>(title),
          initiallyExpanded: expandedCategoryKey == title,
          onExpansionChanged: (isExpanded) {
            setState(() {
              expandedCategoryKey = isExpanded ? title : null;
            });
          },
          title: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          trailing: SizedBox.shrink(),
          children: children,
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget buildSubCategory(BuildContext context, String title, String subCategoryKey) {
    selectedSubCategories.putIfAbsent(subCategoryKey, () => {}); // Ensure key exists
    return ListTile(
      title: Text(
        title,
        style: TextStyle(fontSize: 14,
        color: Colors.white,),
        
      ),
      trailing: Radio<String>(
        value: title,
        groupValue: selectedSubCategories[subCategoryKey]!.contains(title) ? title : null,
        onChanged: (value) {
          setState(() {
            if (selectedSubCategories[subCategoryKey]!.contains(value)) {
              selectedSubCategories[subCategoryKey]!.remove(value);
            } else {
              selectedSubCategories[subCategoryKey]!.add(value!);
            }
          });
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
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


// class WishlistScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return PlaceholderScreen(title: "Wishlist Screen");
//   }
// }

// class AccountScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return PlaceholderScreen(title: "Account Screen");
//   }
// }
