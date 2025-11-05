import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/view/auth_screen.dart';
import '../features/categories/view/categories_screen.dart';
import '../features/designer/bloc/designers_screen.dart';
import '../features/login/view/login_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/wishlist/view/wishlist_screen.dart';


class CommonBottomNavBar extends StatefulWidget {
  final int currentIndex;
  final TabController? mainTabController;
  // ✅ ADDED: A flag to control the visibility of the nav bar.
  final bool showBottomNavBar;

  const CommonBottomNavBar({
    super.key,
    required this.currentIndex,
    this.mainTabController,
    // ✅ It defaults to `true`, so you only need to set it to `false` when hiding it.
    this.showBottomNavBar = true,
  });

  @override
  State<CommonBottomNavBar> createState() => _CommonBottomNavBarState();
}

class _CommonBottomNavBarState extends State<CommonBottomNavBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CommonBottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  Future<void> _navigateToScreen(Widget screen, {bool removeUntil = false}) async {
    final route = MaterialPageRoute(builder: (_) => screen);
    if (removeUntil) {
      await Navigator.pushAndRemoveUntil(context, route, (route) => false);
    } else {
      await Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ If `showBottomNavBar` is false, return an empty widget.
    if (!widget.showBottomNavBar) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        iconSize: screenWidth < 360 ? 22 : 24,
        selectedFontSize: screenWidth < 360 ? 11 : 12,
        unselectedFontSize: screenWidth < 360 ? 11 : 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.category_outlined), activeIcon: Icon(Icons.category), label: "Categories"),
          BottomNavigationBarItem(icon: Icon(Icons.palette_outlined), activeIcon: Icon(Icons.palette), label: "Designers"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: "Wish List"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: "Login"),
        ],
        onTap: (index) async {
          if (index == _selectedIndex) return;

          setState(() {
            _selectedIndex = index;
          });

          final prefs = await SharedPreferences.getInstance();
          final isLoggedIn = prefs.getString('user_token') != null;

          switch (index) {
            case 0:
              if (widget.mainTabController != null) {
                widget.mainTabController!.animateTo(0);
              } else {
                await _navigateToScreen(AuthScreen(), removeUntil: true);
              }
              break;
            case 1:
              if (widget.mainTabController != null) {
                widget.mainTabController!.animateTo(1);
              } else {
                await _navigateToScreen( CategoriesPage(), removeUntil: true);
              }
              break;
            case 2:
              if (widget.mainTabController != null) {
                widget.mainTabController!.animateTo(3);
              } else {
                await _navigateToScreen(DesignersScreen(), removeUntil: true);
              }
              break;
            case 3:
              await _navigateToScreen(WishlistScreen1());
              break;
            case 4:
              if (isLoggedIn) {
                await _navigateToScreen(const ProfileScreen(), removeUntil: true);
              } else {
                await _navigateToScreen(LoginScreen1(), removeUntil: true);
              }
              break;
          }
        },
      ),
    );
  }
}

// class CommonBottomNavBar extends StatefulWidget {
//   final int currentIndex;
//   final TabController? mainTabController;
//
//   const CommonBottomNavBar({
//     super.key,
//     required this.currentIndex,
//     this.mainTabController,
//   });
//
//   @override
//   State<CommonBottomNavBar> createState() => _CommonBottomNavBarState();
// }
//
// class _CommonBottomNavBarState extends State<CommonBottomNavBar> {
//   late int _selectedIndex;
//
//   @override
//   void initState() {
//     super.initState();
//     _selectedIndex = widget.currentIndex;
//   }
//
//   Future<void> _navigateToScreen(Widget screen, {bool removeUntil = false}) async {
//     if (removeUntil) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => screen),
//             (route) => false,
//       );
//     } else {
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => screen),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.white.withOpacity(0.05),
//             spreadRadius: 1,
//             blurRadius: 10,
//             offset: const Offset(0, -1),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         backgroundColor: Colors.black,
//         selectedItemColor: Colors.white,
//         unselectedItemColor: Colors.grey[600],
//         type: BottomNavigationBarType.fixed,
//         elevation: 0,
//         iconSize: screenWidth < 360 ? 22 : 24,
//         selectedFontSize: screenWidth < 360 ? 11 : 12,
//         unselectedFontSize: screenWidth < 360 ? 11 : 12,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: "Home",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.category_outlined),
//             activeIcon: Icon(Icons.category),
//             label: "Categories",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.palette_outlined),
//             activeIcon: Icon(Icons.palette),
//             label: "Designers",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.favorite_border),
//             activeIcon: Icon(Icons.favorite),
//             label: "Wish List",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: "Login",
//           ),
//         ],
//         onTap: (index) async {
//           setState(() {
//             _selectedIndex = index;
//           });
//
//           final prefs = await SharedPreferences.getInstance();
//           final isLoggedIn = prefs.getString('user_token') != null;
//
//           switch (index) {
//             case 0: // Home
//               if (widget.mainTabController != null) {
//                 widget.mainTabController!.animateTo(0);
//               } else {
//                 await _navigateToScreen(AuthScreen(), removeUntil: true);
//               }
//               break;
//
//             case 1: // Categories
//               if (widget.mainTabController != null) {
//                 widget.mainTabController!.animateTo(1);
//               } else {
//                 await _navigateToScreen(CategoriesPage(), removeUntil: true);
//               }
//               break;
//
//             case 2: // Designers
//               if (widget.mainTabController != null) {
//                 widget.mainTabController!.animateTo(3);
//               } else {
//                 await _navigateToScreen(DesignersScreen(), removeUntil: true);
//               }
//               break;
//
//             case 3: // Wish List
//               await _navigateToScreen(WishlistScreen1());
//               break;
//
//             case 4: // Login/Profile
//               if (isLoggedIn) {
//                 await _navigateToScreen(const ProfileScreen(), removeUntil: true);
//               } else {
//                 await _navigateToScreen(LoginScreen1(), removeUntil: true);
//               }
//               break;
//           }
//         },
//       ),
//     );
//   }
// }
