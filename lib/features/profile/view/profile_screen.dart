import 'package:flutter/material.dart';

import '../../auth/view/auth_screen.dart';
import '../../auth/view/tab_bloc.dart';
import '../../login/view/login_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../../wishlist/view/wishlist_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 1; // Default to Account tab
  int cartQty = 0;
  String? _firstName;
  String? _lastName;

  final List<Widget> _screens = [
    AuthScreen(),        // Home
    const AccountPage(), // Account
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // 👇 Hide AppBar on Home (0)
      appBar: (_currentIndex == 0)
          ? null
          : AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/logo.jpeg', height: 30),
            if (_firstName != null && _lastName != null)
              Padding(
                padding: const EdgeInsets.only(top: 10, right: 100),
                child: Text(
                  'Welcome, $_firstName $_lastName !!!',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SearchScreen1(),
              );
            },
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_rounded,
                    color: Colors.black),
                if (cartQty > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      child: Text(
                        '$cartQty',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShoppingBagScreen()),
              );
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // 👇 Hide BottomNavigationBar when index == 0
      bottomNavigationBar: _currentIndex == 0
          ? null
          : Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          backgroundColor: const Color(0xFFF8F8F8),
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          iconSize: screenWidth < 360 ? 22 : 24,
          selectedFontSize: screenWidth < 360 ? 11 : 12,
          unselectedFontSize: screenWidth < 360 ? 11 : 12,

          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: "Account",
            ),
          ],
        ),
      ),
    );
  }
}
// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});
//
//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }
//
// class _ProfileScreenState extends State<ProfileScreen> {
//   int _currentIndex = 2; // Default to Account tab
//   int cartQty = 0;
//   String? _firstName;
//   String? _lastName;
//
//   final List<Widget> _screens = [
//     AuthScreen(),       // Home (has its own navigation)
//     WishlistScreen1(),  // Wish List
//     const AccountPage(), // Account
//   ];
//
//   @override
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Scaffold(
//       // 👇 Hide AppBar on Home (0) and Wishlist (1)
//       appBar: (_currentIndex == 0 || _currentIndex == 1)
//           ? null
//           : AppBar(
//         title: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Image.asset('assets/logo.jpeg', height: 30),
//             if (_firstName != null && _lastName != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 10, right: 100),
//                 child: Text(
//                   'Welcome, $_firstName $_lastName !!!',
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.black,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//           ],
//         ),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => const SearchScreen1(),
//               );
//             },
//           ),
//           IconButton(
//             icon: Stack(
//               clipBehavior: Clip.none,
//               children: [
//                 const Icon(Icons.shopping_bag_rounded,
//                     color: Colors.black),
//                 if (cartQty > 0)
//                   Positioned(
//                     right: -6,
//                     top: -6,
//                     child: Container(
//                       padding: const EdgeInsets.all(2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                       constraints: const BoxConstraints(
//                         minWidth: 18,
//                         minHeight: 18,
//                       ),
//                       child: Text(
//                         '$cartQty',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (_) => ShoppingBagScreen()),
//               );
//             },
//           ),
//         ],
//       ),
//
//       body: IndexedStack(
//         index: _currentIndex,
//         children: _screens,
//       ),
//
//       // 👇 Hide BottomNavigationBar when index == 0
//       bottomNavigationBar: _currentIndex == 0
//           ? null
//           : Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               spreadRadius: 1,
//               blurRadius: 10,
//               offset: const Offset(0, -1),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           currentIndex: _currentIndex,
//           backgroundColor: const Color(0xFFF8F8F8),
//           selectedItemColor: Colors.black,
//           unselectedItemColor: Colors.grey[600],
//           type: BottomNavigationBarType.fixed,
//           elevation: 0,
//           iconSize: screenWidth < 360 ? 22 : 24,
//           selectedFontSize: screenWidth < 360 ? 11 : 12,
//           unselectedFontSize: screenWidth < 360 ? 11 : 12,
//
//           onTap: (index) {
//             setState(() {
//               _currentIndex = index;
//             });
//           },
//
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined),
//               activeIcon: Icon(Icons.home),
//               label: "Home",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.favorite_border),
//               activeIcon: Icon(Icons.favorite),
//               label: "Wish List",
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.person_outline),
//               activeIcon: Icon(Icons.person),
//               label: "Account",
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
// }




