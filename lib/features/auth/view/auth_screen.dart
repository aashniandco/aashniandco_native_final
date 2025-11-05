// =======================================================================
//  CORRECTED AND CLEANED IMPORTS AT THE TOP OF THE FILE
// =======================================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/profile/view/profile_screen.dart';
import 'package:aashniandco/features/search/presentation/search_screen.dart';
import 'package:aashniandco/features/wishlist/view/wishlist_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Assuming these are your local project files ---
import 'package:aashniandco/bloc/login/login_screen_bloc.dart';
import 'package:aashniandco/features/signup/view/signup_screen.dart';
import 'package:aashniandco/common/dialog.dart';
import 'package:aashniandco/features/accessories/accessories.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart';
import 'package:aashniandco/features/auth/view/tab_bloc.dart';
import 'package:aashniandco/features/categories/view/categories_screen.dart';
import 'package:aashniandco/features/auth/view/wishlist_screen.dart';
import 'package:aashniandco/features/auth/view_models/auth_view_model.dart';
import 'package:aashniandco/features/categories/view/categories_screen1.dart';
import 'package:aashniandco/features/designers.dart';
import 'package:aashniandco/features/newin/bloc/product_te.dart';
import 'package:aashniandco/features/shoppingbag/shopping_bag.dart';
import '../../../common/common_app_bar.dart';
import '../../categories/bloc/megamenu_bloc.dart';
import '../../categories/bloc/megamenu_event.dart';
import '../../categories/repository/megamenu_repository.dart';
import '../../designer/bloc/designers_bloc.dart';
import '../../designer/bloc/designers_screen.dart';
import '../../login/view/login_screen.dart' as login_screen_alias; // Added alias to resolve conflict
import '../../login/view/login_screen.dart';
import '../../new_in_tabbar/presentation/screens/product_list_screen.dart';
import '../../newin/view/new_in_screen.dart';
import '../../newin_catTab/view/new_in_menu_categories_screen.dart';
import '../bloc/currency_bloc.dart';
import '../bloc/currency_event.dart';
import '../bloc/currency_state.dart';
import 'categories_view_body.dart';
import 'currency_app_bar_title.dart';
import 'designers_view_body.dart';
import 'home_screen_banner_listing.dart';
import 'native_product_screen.dart';
import 'offer_pop_up.dart';
// =======================================================================



import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Make sure this is imported if you're using BLoC for currency

// Replace with your actual path

// Assuming TabBloc is for the TabBar, but we'll manage the bottom nav index directly.
// If TabBloc isn't used elsewhere for the main TabBar logic, you can remove it.
// For this solution, I'll remove it to simplify, as the TabController itself manages the index.
// If you still need TabBloc for specific TabController state management outside of AuthScreen,
// you might keep it and adjust its interaction.

// Let's create a minimal TabBloc to avoid compile errors, but it won't be actively used
// for the primary tab switching logic as the TabController handles that.
// If you remove it, also remove `BlocProvider` for `_tabBloc` and `_tabBloc.close()`.
class AuthScreen extends ConsumerStatefulWidget {
  final int initialTabindex;

  const AuthScreen({Key? key, this.initialTabindex = 0}) : super(key: key);

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> with TickerProviderStateMixin {
  // The main controller for the TabBarView with ALL 4 pages
  late TabController _mainTabController;

  // The controller for the VISIBLE TabBar with only 2 tabs
  late TabController _visibleTabController;

  String? _firstName;
  String? _lastName;
  int cartQty = 0;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchCartQuantity();
    _loadUserInfo();

    _mainTabController = TabController(length: 4, vsync: this, initialIndex: widget.initialTabindex);

    // ✅ NEW Simplified Listener:
    // When the user swipes the TabBarView, this updates the bottom nav bar icon.
    _mainTabController.addListener(() {
      // Don't update state while the animation is running
      if (_mainTabController.indexIsChanging) return;

      int newBottomIndex;
      switch (_mainTabController.index) {
        case 0: // Featured
        case 2: // New In (Both are considered "Home")
          newBottomIndex = 0;
          break;
        case 1: // Categories
          newBottomIndex = 1;
          break;
        case 3: // Designers
          newBottomIndex = 2;
          break;
        default:
          return; // Should not happen
      }

      // Only call setState if the index has actually changed
      if (_selectedBottomNavIndex != newBottomIndex) {
        setState(() {
          _selectedBottomNavIndex = newBottomIndex;
        });
      }
    });
  }

  Future<void> _updateCartCurrency(String currencyCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');

      if (customerToken == null || customerToken.isEmpty) {
        print("⚠️ User not logged in, skipping currency update.");
        return;
      }

      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.post(
        Uri.parse('https://aashniandco.com/rest/V1/solr/update-currency'),
        headers: {
          'Authorization': 'Bearer $customerToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"currencyCode": currencyCode}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print("✅ Currency updated: $data");

        final currencyState = context.read<CurrencyBloc>().state;
        if (currencyState is CurrencyLoaded) {
          // Get the symbol directly from the CurrencyLoaded getter
          final String selectedCurrencySymbol = currencyState.selectedSymbol;

          await prefs.setString('selected_currency_code', currencyCode);
          // Save the symbol to SharedPreferences from the getter
          await prefs.setString('selected_currency_symbol', selectedCurrencySymbol);
          print("Currency saved to SharedPreferences: Code=$currencyCode, Symbol=$selectedCurrencySymbol");
        }

        _fetchCartQuantity(); // Optionally refresh cart totals
      } else {
        print("❌ Failed to update currency: ${response.body}");
      }
    } catch (e) {
      print("🔥 Error updating cart currency: $e");
    }
  }

  // Future<void> _updateCartCurrency(String currencyCode) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final customerToken = prefs.getString('user_token');
  //
  //     if (customerToken == null || customerToken.isEmpty) {
  //       print("⚠️ User not logged in, skipping currency update.");
  //       return;
  //     }
  //
  //     HttpClient httpClient = HttpClient();
  //     httpClient.badCertificateCallback = (cert, host, port) => true;
  //     IOClient ioClient = IOClient(httpClient);
  //
  //     final response = await ioClient.post(
  //       Uri.parse('https://stage.aashniandco.com/rest/V1/solr/update-currency'),
  //       headers: {
  //         'Authorization': 'Bearer $customerToken',
  //         'Content-Type': 'application/json',
  //       },
  //       body: jsonEncode({"currencyCode": currencyCode}),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       print("✅ Currency updated: $data");
  //       // Optionally refresh cart totals
  //       _fetchCartQuantity();
  //     } else {
  //       print("❌ Failed to update currency: ${response.body}");
  //     }
  //   } catch (e) {
  //     print("🔥 Error updating cart currency: $e");
  //   }
  // }


  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCartQuantity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customerToken = prefs.getString('user_token');

      if (customerToken == null || customerToken.isEmpty) {
        if (mounted) setState(() => cartQty = 0);
        return;
      }

      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.get(
        Uri.parse('https://aashniandco.com/rest/V1/carts/mine'),
        headers: {
          'Authorization': 'Bearer $customerToken',
          'Content-Type': 'application/json',
        },
      );

      if (mounted) {
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final int itemsCount = data['items_count'] ?? 0;
          setState(() => cartQty = itemsCount);
        } else {
          print('Failed to fetch cart: ${response.body}');
          setState(() => cartQty = 0);
        }
      }
    } catch (e) {
      print('Error fetching cart quantity: $e');
      if (mounted) setState(() => cartQty = 0);
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _firstName = prefs.getString('user_firstname');
        _lastName = prefs.getString('user_lastname');
      });
    }
  }


  Widget _buildResponsiveAppBarTitle() {
    print("met called>>");
    // This BlocBuilder will automatically handle loading, errors, and data states
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        // --- Handle Loading and Error States First ---
        if (state is CurrencyLoading || state is CurrencyInitial) {
          return const Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
            ),
          );
        }
        if (state is CurrencyError) {
          return Tooltip(
            message: state.message,
            child: const Icon(Icons.error_outline, color: Colors.red),
          );
        }


        // --- Handle the Success State ---
        if (state is CurrencyLoaded) {
          // ✅ Wrap the logo and the dropdown in a Row for side-by-side layout.
          return Row(
            children: [
              // 1. Add the logo as the first item in the Row.
              Image.asset('assets/logo.jpeg', height: 30),
              const SizedBox(width: 16),


              // 2. Wrap the Dropdown in an Expanded widget.
              // This tells the dropdown to fill all remaining horizontal space in the AppBar.
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: state.selectedCurrencyCode,
                    isExpanded: true, // Ensures it fills the Expanded widget
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
                    onChanged: (newCode) {
                      if (newCode != null) {
                        context.read<CurrencyBloc>().add(ChangeCurrency(newCode));
                        _updateCartCurrency(newCode);
                      }
                    },
                    // This builder defines how the selected item looks when the dropdown is CLOSED.
                    selectedItemBuilder: (context) {
                      return state.currencyData.availableCurrencyCodes
                          .map((_) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${state.selectedCurrencyCode} | ${state.selectedSymbol}',
                          style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                              fontSize: 14 // Adjusted for better fit
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList();
                    },
                    // This builds the list of items when the dropdown is OPEN.
                    items: state.currencyData.availableCurrencyCodes.map((code) {
                      return DropdownMenuItem<String>(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        }


        // Fallback for any other unhandled state
        return const SizedBox.shrink();
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: CurrencyAppBarTitle(
          // Pass the function that performs the API call as a callback
          onCurrencyChanged: _updateCartCurrency,
        ),
      ),
      // appBar: AppBar(
      //   title: _buildResponsiveAppBarTitle(),
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   foregroundColor: Colors.black,
      //   // ✅ The 'bottom' property is now REMOVED to hide the TabBar
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.search),
      //       onPressed: () {
      //         showDialog(
      //           context: context,
      //           builder: (context) => const SearchScreen1(),
      //         );
      //       },
      //     ),
      //     IconButton(
      //       icon: Stack(
      //         clipBehavior: Clip.none,
      //         children: [
      //           const Icon(Icons.shopping_bag_rounded, color: Colors.black),
      //           if (cartQty > 0)
      //             Positioned(
      //               right: -6,
      //               top: -6,
      //               child: Container(
      //                 padding: const EdgeInsets.all(2),
      //                 decoration: BoxDecoration(
      //                   color: Colors.red,
      //                   borderRadius: BorderRadius.circular(10),
      //                 ),
      //                 constraints:
      //                 const BoxConstraints(minWidth: 18, minHeight: 18),
      //                 child: Text(
      //                   '$cartQty',
      //                   style: const TextStyle(
      //                     color: Colors.white,
      //                     fontSize: 12,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                   textAlign: TextAlign.center,
      //                 ),
      //               ),
      //             ),
      //         ],
      //       ),
      //       onPressed: () {
      //         Navigator.push(
      //           context,
      //           MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      body: authState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
        controller: _mainTabController,
        children: [
          HomeScreen(),
          // CategoriesPage(),
          BlocProvider(
            create: (_) => MegamenuBloc(MegamenuRepository())..add(LoadMegamenu()),
            child:  CategoriesViewBody(),
          ),
          MenuCategoriesScreen1(categoryName: "New In"),

          BlocProvider(
            create: (context) => DesignersBloc()..add(FetchDesigners()),
            child: const DesignersViewBody(),
          ),
          // DesignersScreen(),

        ],
      ),
      bottomNavigationBar: Container(
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
          currentIndex: _selectedBottomNavIndex,
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
            // Update the visual selection immediately
            setState(() {
              _selectedBottomNavIndex = index;
            });

            // Handle navigation logic
            switch (index) {
              case 0: // Home -> "Featured"
                _mainTabController.animateTo(0);
                break;
              case 1: // Categories
                _mainTabController.animateTo(1);
                break;
              case 2: // Designers
                _mainTabController.animateTo(3);
                break;
              case 3: // Wish List
              case 4: // Login/Profile
              // These cases navigate away, so we need the full logic
                final prefs = await SharedPreferences.getInstance();
                final isLoggedIn = prefs.getString('user_token') != null;

                if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WishlistScreen1()),
                  );
                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => WishlistScreen1()), (route) => false);
                } else if (index == 4) {
                  if (isLoggedIn) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const ProfileScreen()), (route) => false);
                  } else {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => LoginScreen1()), (route) => false);
                  }
                }
                break;
            }
          },
        ),
      ),
    );
  }

}
// class AuthScreen extends ConsumerWidget {
//   final int initialTabindex;
//
//   const AuthScreen({Key? key, this.initialTabindex=0}) : super(key: key);
//
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final authState = ref.watch(authViewModelProvider);
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: initialTabindex,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Image.asset('assets/logo.jpeg', height: 30),
//           elevation: 0,
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           bottom: PreferredSize(
//             preferredSize: const Size.fromHeight(kToolbarHeight),
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 double screenWidth = constraints.maxWidth;
//                 double fontSize = screenWidth > 360 ? 12 : 10;
//
//                 return TabBar(
//                   labelColor: Colors.black,
//                   indicatorColor: Colors.black,
//                   unselectedLabelColor: Colors.grey,
//                   tabs: const [
//                     "Exclusives",
//                     "New In",
//                     "Categories",
//                     "Designers"
//                   ].map((tab) {
//                     return Tab(
//                       child: Text(
//                         tab,
//                         style: TextStyle(fontSize: fontSize),
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     );
//                   }).toList(),
//                 );
//               },
//             ),
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.search),
//               onPressed: () {
//                 showDialog(
//                   context: context,
//                   builder: (context) => const SearchScreen(),
//                 );
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.shopping_bag_rounded),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                 );
//               },
//             ),
//           ],
//         ),
//         body: authState.isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : TabBarView(
//           children: [
//             HomeScreen(),
//             Column(
//               children: [
//                 // const Padding(
//                 //   padding: EdgeInsets.all(12),
//                 //   child: Row(
//                 //     children: [
//                 //       Expanded(
//                 //         child: Text(
//                 //           "New In",
//                 //           style: TextStyle(
//                 //             fontSize: 16,
//                 //             fontWeight: FontWeight.bold,
//                 //           ),
//                 //         ),
//                 //       ),
//                 //     ],
//                 //   ),
//                 // ),
//                 Expanded(
//                   child: NewInScreen(selectedCategories: []),
//                 ),
//               ],
//             ),
//             CategoriesPage(),
//             DesignersScreen(),
//           ],
//         ),
//         bottomNavigationBar: BottomNavigationBar(
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//             BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//             BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//           ],
//           onTap: (index) {
//             switch (index) {
//               case 0:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AuthScreen()),
//                       (route) => false,
//                 );
//                 break;
//               case 1:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const WishlistScreen()),
//                       (route) => false,
//                 );
//                 break;
//               case 2:
//                 Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (context) => const AccountScreen()),
//                       (route) => false,
//                 );
//                 break;
//             }
//           },
//         ),
//       ),
//     );
//   }

  //   Widget build(BuildContext context, WidgetRef ref) {
  //     final authState = ref.watch(authViewModelProvider);
  //
  //     return DefaultTabController(
  //       length: 4,
  //       child: Scaffold(
  //         appBar: AppBar(
  //           title: Image.asset(
  //             'assets/logo.jpeg', // Replace with your image path
  //             height: 30, // Adjust height as needed
  //           ),
  //           elevation: 0,
  //           backgroundColor: Colors.white,
  //           foregroundColor: Colors.black,
  //           bottom: TabBar(
  //             labelColor: Colors.black,
  //             indicatorColor: Colors.black,
  //             unselectedLabelColor: Colors.grey,
  //             labelPadding: const EdgeInsets.symmetric(horizontal: 0),
  //             tabs: const [
  //               Tab(
  //                 child: Text(
  //                   "Exclusives",
  //                   style: TextStyle(fontSize: 12),
  //                 ),
  //               ),
  //
  //               Tab(
  //                 child: Text(
  //                   "New In",
  //                   style: TextStyle(fontSize: 12),
  //                 ),
  //               ),
  //               Tab(
  //                 child: Text(
  //                   "Categories",
  //                   style: TextStyle(fontSize: 12),
  //                 ),
  //               ),
  //               // Tab(
  //               //   child: Text(
  //               //     "Accessories",
  //               //     style: TextStyle(fontSize: 14),
  //               //   ),
  //               // ),
  //               Tab(
  //                 child: Text(
  //                   "Designers",
  //                   style: TextStyle(fontSize: 12),
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             IconButton(
  //               icon: const Icon(Icons.search),
  //               onPressed: () {
  //                   showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) => const SearchScreen(),
  //                 );
  //                 print("Search clicked");
  //               },
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.shopping_bag_rounded),
  //               onPressed: () {
  //                 print("Shopping bag clicked");
  //                      Navigator.push(
  //                 context,
  //                 MaterialPageRoute(
  //                   builder: (context) => ShoppingBagScreen(),
  //                 ),
  //               );
  //               },
  //             ),
  //           ],
  //         ),
  //         body: authState.isLoading
  //             ? const Center(child: CircularProgressIndicator())
  //             : TabBarView(
  //                 children: [
  //                   // Home content reused here
  //                   HomeScreen(),
  //                   NewInScreen(selectedCategories: []),
  //                   // NewInScreen(),
  //                   // NewIn(),// Reuse the Home content in the Exclusive tab
  //                   CategoriesPage(),
  // // CategoriesScreen1(),
  //                   // _buildTabContent("Categories Content"),
  //                   // _buildTabContent("Accessories Content"),
  //                   // Accessories(),
  //                   // _buildTabContent("Designers Content"),
  //                   DesignersScreen()
  //                 ],
  //               ),
  //         bottomNavigationBar: BottomNavigationBar(
  //           items: const [
  //             BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
  //             BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
  //             BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
  //           ],
  //           onTap: (index) {
  //             switch (index) {
  //               case 0:
  //                 Navigator.pushAndRemoveUntil(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => const AuthScreen()),
  //                   (Route<dynamic> route) => false,
  //                 );
  //                 break;
  //               case 1:
  //                 Navigator.pushAndRemoveUntil(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => const WishlistScreen()),
  //                   (Route<dynamic> route) => false,
  //                 );
  //                 break;
  //               case 2:
  //                 Navigator.pushAndRemoveUntil(
  //                   context,
  //                   MaterialPageRoute(builder: (context) => const AccountScreen()),
  //                   (Route<dynamic> route) => false,
  //                 );
  //                 break;
  //             }
  //           },
  //         ),
  //       ),
  //     );
  //   }

  Widget _buildTabContent(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }


// // HomeTab Widget reused in Exclusive and Home tab
// class HomeTab extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Reuse the content from the HomeScreen's `_buildHomeTab()` function
//     return Column(
//       children: [
//         // Add banners, categories, ready-to-ship sections here
//         Center(
//           child: Text(
//             "Home Tab Content",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ),
//       ],
//     );
//   }
// }


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// ======================= THE FIX IS IN THIS CLASS =========================
// ======================= THE FIX IS IN THIS CLASS =========================

// ======================= THE FIX IS IN THIS CLASS =========================
// ======================= THE FIX IS IN THIS CLASS =========================


// ======================= THE FIX IS IN THIS CLASS =========================

// ======================= THE FIX IS IN THIS CLASS =========================
class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  InAppWebViewController? _webViewController;
  PullToRefreshController? _pullToRefreshController;

  bool _isLoading = true;
  bool _isWebViewReady = false;
  bool _isInitialLoad = true;

  final String _initialUrl = "https://aashniandco.com/";

  // --- THE UPDATED JAVASCRIPT ---
  // We've added a new command to hide the slider dots.
  final String _scriptToInject = """
    // First, hide the top text bar
    var elements = document.querySelectorAll('div, p, span, a');
    for (var i = 0; i < elements.length; i++) {
      var element = elements[i];
      if (element.innerText && element.innerText.includes('For styling assistance & customizations')) {
        element.style.display = 'none';
        break;
      }
    }
    
    // ================== NEW FIX HERE ==================
    // Now, find and hide the pagination dots for the sliders.
    // The website uses the class 'owl-dots' for the container of the dots.
    var sliderDots = document.querySelectorAll('.owl-dots');
    for (var i = 0; i < sliderDots.length; i++) {
        sliderDots[i].style.display = 'none';
    }
    // =================================================
  """;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _pullToRefreshController = PullToRefreshController(
      onRefresh: () async {
        if (_webViewController != null) {
          setState(() {
            _isInitialLoad = true;
          });
          _webViewController!.reload();
        }
      },
    );
  }

  void _navigateToNativeScreen(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NativeCategoryScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        if (_webViewController != null) {
          if (await _webViewController!.canGoBack()) {
            await _webViewController!.goBack();
            return false;
          }
        }
        return true;
      },
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Opacity(
              opacity: _isWebViewReady ? 1.0 : 0.0,
              child: NotificationListener<OverscrollNotification>(
                onNotification: (overscroll) {
                  return true; // Consume the notification to prevent the glow
                },
                child: InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(_initialUrl)),
                  pullToRefreshController: _pullToRefreshController,
                  gestureRecognizers: {
                    Factory<VerticalDragGestureRecognizer>(() => VerticalDragGestureRecognizer())
                  },
                  onWebViewCreated: (controller) {
                    _webViewController = controller;
                  },
                  onLoadStop: (controller, url) async {
                    _pullToRefreshController?.endRefreshing();
                    if (!_isWebViewReady) {
                      // Inject our updated script
                      await _webViewController?.evaluateJavascript(source: _scriptToInject);
                      await Future.delayed(const Duration(milliseconds: 30));
                      if (mounted) {
                        setState(() {
                          _isLoading = false;
                          _isWebViewReady = true;
                        });
                      }
                    }
                    if(mounted) setState(() => _isInitialLoad = false);
                  },
                  onLoadError: (controller, url, code, message) {
                    _pullToRefreshController?.endRefreshing();
                    print("--- WebView Error: $message ---");
                  },
                  onReceivedServerTrustAuthRequest: (controller, challenge) async {
                    return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
                  },
                  shouldOverrideUrlLoading: (controller, navigationAction) async {
                    var uri = navigationAction.request.url;
                    if (uri == null) return NavigationActionPolicy.CANCEL;

                    var urlString = uri.toString();
                    if (_isInitialLoad) {
                      return NavigationActionPolicy.ALLOW;
                    }

                    print("Intercepted user click to: $urlString");
                    _navigateToNativeScreen(urlString);
                    return NavigationActionPolicy.CANCEL;
                  },
                ),
              ),
            ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
// Dummy class for NativeProductScreen if it's not in the same file

// Home Page 24 june 2025
// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0; // Keeps track of the selected tab
//   int _currentBannerIndex = 0;
//   int _currentBannerIndexSpe=0;
//   int _currentNewinSliderIndex=0;// Keeps track of the current banner index
//   final PageController _pageControllerBanner = PageController();
//   final PageController _pageControllerBannerSpe = PageController();
//   final PageController _pageControllerShop = PageController();
//   late PageController _pageControllerACOEdit = PageController();
//    int _currentShopByOccassionIndex =0;
//   int _currentACOEditIndex =0;
//   int _previousBannerIndex = 0;
//   double _opacity = 1.0;
//   bool _showPreviousImage = true;
//
//   final ScrollController _scrollController = ScrollController();
//   late Timer _timer;
//   int _currentIndex = 0;
//
//   Timer? _bannerTimer;
//   Timer? _bannerTimerSpe;// Declare a Timer variable
//   Timer? _shopOccasionTimer;  // Another Timer for Shop By Occasion
//
//    final List<String> shopByOccassionImages= [
//
//      'assets/Shop-by-occassion-1.jpg', // Replace with actual banner image paths
//      'assets/Shop-by-occassion-2.jpg',
//      'assets/Shop-by-occassion-3.jpg',
//      'assets/Shop-by-occassion-4.jpg',
//      'assets/Shop-by-occassion-5.jpg',
//      'assets/Shop-by-occassion-6.jpg',
//    ];
//
//   final List<String> ACoEditImages= [
//
//
//
//
//     'assets/ACO-EDITS-1.jpg',
//  'assets/ACO-EDITS-2.jpg',
//   'assets/ACO-EDITS-3.jpg',
//   'assets/ACO-EDITS-4.jpg',
//   'assets/ACO-EDITS-5.jpg',
//      'assets/ACO-EDITS-6.jpg',
// 'assets/ACO-EDITS-1.jpg',
//  'assets/ACO-EDITS-7.jpg',
//     'assets/ACO-EDITS-8.jpg',
//   ];
//
//   final acoEdits = [
//
//   ];
//
//
//   final mensWearEdit = [
//     'assets/Menswear-Edit-1.jpg',
//     'assets/Menswear-Edit-2.jpg',
//     'assets/Menswear-Edit-3.jpg',
//     'assets/Menswear-Edit-4.jpg',
//
//   ];
//
//
//
//   // final List<String> bannerImages = [
//   //   'assets/Banner-1.jpg', // Replace with actual banner image paths
//   //   'assets/Banner-2.jpg',
//   //   'assets/Banner-3.jpg',
//   //   'assets/Banner-4.jpg',
//   //   // 'assets/Banner-5.jpg',
//   //   // 'assets/Banner-6.jpg',
//   //   // 'assets/Banner-7.jpg'
//   // ];
//
//   final List<Map<String, dynamic>> bannerImages = [
//     {'id': 1545,'image': 'assets/Banner-1.jpg', 'name': 'Ritika Mirchandani',},
//     {'id': 5223,'image': 'assets/Banner-2.jpg', 'name': 'Aditi Gupta',},
//     {'id': 1786,'image': 'assets/Banner-3.jpg', 'name': 'Sue Mue',},
//     {'id': 1512,'image': 'assets/Banner-4.jpg', 'name': 'Elan',},
//     {'id': 1468,'image': 'assets/Banner-5.jpg', 'name': 'Ridhi Mehra',},
//   ];
//
// //Contemporary Styles
//
//
//
//   final List<Map<String, dynamic>> bannerSpeImages = [
//
//     // {'id': 5994,'image': 'assets/Banner-new-1-.jpg', 'name': 'Wedding Collections',},
//     // {'id': 5994,'image': 'assets/Banner-SS25-New.jpg', 'name': 'uuu',},
//
//     {'id': 5994,'image': 'assets/wedding-curation.jpg', 'name': 'Wedding Collections',},
//
//
//   ];
//
//
//
//   // Function to handle tab selection
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index; // Update the selected index
//     });
//   }
//
//
//   void _startAutoSlideACOEdit() {
//     _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_pageControllerACOEdit.hasClients) {
//         setState(() {
//           _currentACOEditIndex =
//               (_currentACOEditIndex + 1) % ACoEditImages.length;
//         });
//         _pageControllerACOEdit.animateToPage(
//           _currentACOEditIndex,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//   void _startAutoScroll() {
//     _bannerTimer= Timer.periodic(Duration(seconds: 3), (timer) {
//       if (_scrollController.hasClients) {
//         double maxScroll = _scrollController.position.maxScrollExtent;
//         double nextOffset = _scrollController.offset + 220; // Adjust step size based on image width + padding
//
//         if (nextOffset >= maxScroll) {
//           _scrollController.animateTo(
//             0.0,
//             duration: Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//           _currentIndex = 0;
//         } else {
//           _scrollController.animateTo(
//             nextOffset,
//             duration: Duration(milliseconds: 500),
//             curve: Curves.easeInOut,
//           );
//           _currentIndex++;
//         }
//       }
//     });
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//     _startAutoScroll();
//     _startAutoSlide();
//     _startAutoSlideShopByOccassion();
//     _startAutoSlideACOEdit();
//     _startAutoSlideBannerSpe();
//     Future.delayed(Duration(seconds: 4), () {
//       showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (context) => OfferPopup(onClose: () {
//           Navigator.pop(context);
//         }),
//       );
//     });
//
//   }
//
//
//
//   void _startAutoSlideShopByOccassion() {
//     Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_pageControllerShop.hasClients) {
//         setState(() {
//           _currentShopByOccassionIndex =
//               (_currentShopByOccassionIndex + 1) % shopByOccassionImages.length;
//         });
//         _pageControllerShop.animateToPage(
//           _currentShopByOccassionIndex,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }
//
//
//
//
//   // void _startAutoSlide() {
//   //   _bannerTimer = Timer.periodic(Duration(seconds: 12), (Timer timer) {
//   //     if (_currentBannerIndex < bannerImages.length - 1) {
//   //       _currentBannerIndex++;
//   //     } else {
//   //       _currentBannerIndex = 0; // Reset to first image
//   //     }
//   //     _pageControllerBanner.animateToPage(
//   //       _currentBannerIndex,
//   //       duration: Duration(milliseconds: 1200),
//   //       curve: Curves.easeInOut,
//   //     );
//   //   });
//   // }
//
//   void _startAutoSlide() {
//     _bannerTimer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
//       setState(() {
//         _opacity = 0.0; // Start fade-out
//         _showPreviousImage = true; // Show previous image temporarily
//       });
//
//       Future.delayed(Duration(milliseconds: 600), () {
//         setState(() {
//           _previousBannerIndex = _currentBannerIndex; // Update previous image
//           _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length; // Update image index
//         });
//
//         Future.delayed(Duration(milliseconds: 200), () {
//           setState(() {
//             _opacity = 1.0; // Fade-in new image
//             _showPreviousImage = false; // Hide previous image after transition
//           });
//         });
//       });
//     });
//   }
//
//
//   void _startAutoSlideBannerSpe() {
//     _bannerTimerSpe = Timer.periodic(Duration(seconds: 4), (Timer timer) {
//       setState(() {
//         _opacity = 0.0; // Start fade-out
//         _showPreviousImage = true; // Show previous image temporarily
//       });
//
//       Future.delayed(Duration(milliseconds: 600), () {
//         setState(() {
//           _previousBannerIndex = _currentBannerIndexSpe; // Update previous image
//           _currentBannerIndexSpe = (_currentBannerIndexSpe + 1) % bannerSpeImages.length; // Update image index
//         });
//
//         Future.delayed(Duration(milliseconds: 200), () {
//           setState(() {
//             _opacity = 1.0; // Fade-in new image
//             _showPreviousImage = false; // Hide previous image after transition
//           });
//         });
//       });
//     });
//     // _bannerTimerSpe = Timer.periodic(Duration(seconds: 12), (Timer timer) {
//     //   if (_currentBannerIndexSpe < bannerSpeImages.length - 1) {
//     //     _currentBannerIndexSpe++;
//     //   } else {
//     //     _currentBannerIndexSpe = 0; // Reset to first image
//     //   }
//     //   _pageControllerBannerSpe.animateToPage(
//     //     _currentBannerIndexSpe,
//     //     duration: Duration(milliseconds: 1200),
//     //     curve: Curves.easeInOut,
//     //   );
//     // });
//   }
//
//   @override
//   void dispose() {
//     _bannerTimer?.cancel();
//     _pageControllerBanner.dispose();
//     _pageControllerShop.dispose();
//     _timer.cancel();
//     _scrollController.dispose();
//     _timer.cancel();
//     _pageControllerACOEdit.dispose();
//     _pageControllerBannerSpe.dispose();
//     super.dispose();
//   }
//
//
//
// Widget _buildHomeTab() {
//   double sectionHeight = 350;
//   final categories = [
//     "New In",
//     "Designers",
//     "Women",
//     "Bestsellers",
//     "Jewellery",
//     "Accessories",
//     "Men",
//     "Weddings",
//     "Kids",
//     "Sales",
//     "Ready To Ship",
//     "Journal"
//   ];
//
//
//
//   final accessoryEdit = [
//     {'image': 'assets/Festive-Favourites.jpg', 'name': 'DIYARAJVIR'},
//     {'image': 'assets/Modern-Jewels.jpg', 'name': 'DIYARAJVIR'},
//     {'image': 'assets/Everyday-Classics.jpg', 'name': 'SAFAA'},
//     {'image': 'assets/Hand-Jewelry.jpg', 'name': 'PEACHOO'},
//
//   ];
//   final List<Map<String, dynamic>> designerData = [
//     {'id': 6220,'image': 'assets/New-In-1.jpg', 'name': 'Iqbal Hussain'},
//     {'id': 3989,'image': 'assets/New-In-3.jpg', 'name': 'Niti Bothra'},
//     {'id': 1545,'image': 'assets/New-In-4.jpg', 'name': 'Asaga'},
//     {'id': 1512,'image': 'assets/New-In-5.jpg', 'name': 'Elan'},
//     {'id': 1545,'image': 'assets/New-In-6.jpg', 'name': 'The Aarya'},
//     {'id': 5974,'image': 'assets/New-In-7.jpg', 'name': 'Capisvirleo'},
//     {'id': 1700,'image': 'assets/New-In-8.jpg', 'name': 'Masumi Mewawalla'},
//     {'id': 3697,'image': 'assets/New-In-9.jpg', 'name': 'Saundh'},
//     {'id': 2053,'image': 'assets/New-In-11.jpg', 'name': 'Seema Thukral'},
//     {'id': 5990,'image': 'assets/New-In-11.jpg', 'name': 'Miku Kumar'},
//     // {'image': 'assets/New-In-12.jpg', 'name': 'PEACHOO'},
//     // {'image': 'assets/New-In-13.jpg', 'name': 'PEACHOO'},
//   ];
//
//     final readytoShip = [
//     {'id': 6018,'image': 'assets/RTS.jpg', 'name': 'Ready To Ship'},
//     {'id': 1475,'image': 'assets/Sabya.jpg', 'name': 'Sabyasachi'},
//     {'id': 5492,'image': 'assets/Occasion-wear-lehengas.jpg', 'name': 'Ocassion Wear Lehengas'},
//   ];
//
//       final acoEdits = [
//     {'image': 'assets/ACO-EDITS-1.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/ACO-EDITS-2.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/ACO-EDITS-3.jpg', 'name': 'OCASSION Wear Lehengas'},
//     {'image': 'assets/ACO-EDITS-4.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/ACO-EDITS-5.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/ACO-EDITS-6.jpg', 'name': 'OCASSION Wear Lehengas'},    {'image': 'assets/ACO-EDITS-1.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/ACO-EDITS-7.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/ACO-EDITS-8.jpg', 'name': 'OCASSION Wear Lehengas'},
//   ];
//
//   final shopbyStyle1 = [
//     {'image': 'assets/Shop-by-style-1.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/Shop-by-style-2.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/Shop-by-style-3.jpg', 'name': 'OCASSION Wear Lehengas'},
//     {'image': 'assets/Shop-by-style-4.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/Shop-by-style-5.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/Shop-by-style-6.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/Shop-by-style-7.jpg', 'name': 'OCASSION Wear Lehengas'},
//     {'image': 'assets/Shop-by-style-8.jpg', 'name': 'Ready To Ship'},
//   ];
//
//
//   final shopbyStyle2 = [
//     {'image': 'assets/Shop-by-style-5.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/Shop-by-style-6.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/Shop-by-style-7.jpg', 'name': 'OCASSION Wear Lehengas'},
//     {'image': 'assets/Shop-by-style-8.jpg', 'name': 'Ready To Ship'},
//
//   ];
//
//   final acoBridalEdit = [
//     {'image': 'assets/Bridesmaid-Glam-New.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/Gold-&-Ivory-Lehengas.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/Trousseau-Essentials.jpg', 'name': 'OCASSION Wear Lehengas'},
//
//
//   ];
//
//
//   final bottomImages = [
//     {'image': 'assets/Accessories-for-him.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/LAST-MINUTE-EID-PICKS.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/ACO-KIDS.jpg', 'name': 'OCASSION Wear Lehengas'},
//
//
//   ];
//
//   final bottomImage2 = [
//
//     {'image': 'assets/A Tribute to Rohit Bal The Eternal Maestro of Indian Fashion.jpg', 'name': 'SABYASACHI'},
//     {'image': 'assets/Elevating Traditional Fashion with the Latest Anarkali Trends.jpg', 'name': 'OCASSION Wear Lehengas'},
//     {'image': 'assets/Benarasi Lehengas A Nod to Heritage.jpg', 'name': 'Ready To Ship'},
//     {'image': 'assets/The Comeback of the Mermaid Lehenga.jpg', 'name': 'Ready To Ship'},
//   ];
//
//
//   return Column(
//     children: [
//
//
//       Expanded(
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               SizedBox(
//                 height: 180,
//                 width: double.infinity,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: GestureDetector(
//                     onTap: () async {
//                       final selectedBanner = bannerImages[_currentBannerIndex];
//
//
//
//                       // 2. Navigate to new screen
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => HomeScreenBannerListing(
//                             bannerName: selectedBanner['name']!,
//                             bannerId: selectedBanner['id'],
//                           ),
//                         ),
//                       );
//                     },
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 1000),
//                       transitionBuilder: (Widget child, Animation<double> animation) {
//                         return FadeTransition(opacity: animation, child: child);
//                       },
//                       child: Image.asset(
//                         bannerImages[_currentBannerIndex]['image']!,
//                         key: ValueKey<int>(_currentBannerIndex),
//                         fit: BoxFit.cover,
//                         width: double.infinity,
//                         height: 180,
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//               ,
//
//
//               SizedBox(
//                 height: 180,
//                 width: double.infinity,
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       final selectedBanner = bannerSpeImages[_currentBannerIndexSpe];
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => HomeScreenBannerListing(
//                             bannerName: selectedBanner['name']!,
//                             bannerId: selectedBanner['id'],
//                           ),
//                         ),
//                       );
//                     },
//                     child: AnimatedSwitcher(
//                       duration: const Duration(milliseconds: 1000),
//                       transitionBuilder: (Widget child, Animation<double> animation) {
//                         return FadeTransition(opacity: animation, child: child);
//                       },
//                       child: Builder(
//                         builder: (context) {
//                           print("Current banner index: $_currentBannerIndexSpe"); // Debug print
//                           return Image.asset(
//                             bannerSpeImages[_currentBannerIndexSpe]['image']!,
//                             key: ValueKey<int>(_currentBannerIndexSpe),
//                             fit: BoxFit.cover,
//                             width: double.infinity,
//                             height: 180,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               )
//               ,
//
//
//
//               SizedBox(height: 8),
//
//
//
//               // Add spacing between sections
//
//               Column(
//                 mainAxisSize: MainAxisSize.min, // Prevent extra spacing
//                 children: [
//
//   Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//   Expanded(
//   flex: 2, // Text part
//   child: Container( // This is the TextBlockContainer
//   height: sectionHeight, // <--- FIX 1: Explicitly set height
//   padding: const EdgeInsets.only(left: 16.0, right: 8.0, top: 8.0, bottom: 8.0 /* Optional bottom padding */),
//   alignment: Alignment.topLeft,
//   child: SingleChildScrollView( // <--- FIX 2: Make content scrollable if it overflows
//   child: Column(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   // mainAxisAlignment: MainAxisAlignment.start, // Default for Column
//   children: [
//   Text(
//   'New In',
//   style: TextStyle(
//   fontFamily: 'Serif',
//   fontSize: 30,
//   color: Colors.black87,
//   ),
//   ),
//   SizedBox(height: 12),
//   Text(
//   'New arrivals, now dropping five days a week - discover the latest launches onsite from Monday to\nFriday', // Ensure this text isn't unexpectedly long
//   style: TextStyle(
//   fontSize: 14,
//   color: Colors.black87,
//   height: 1.4,
//   ),
//   ),
//   SizedBox(height: 16),
//   InkWell(
//   onTap: () {
//   print("Explore Now tapped!");
//   // Add navigation or other action here
//   },
//   child: Text(
//   'EXPLORE NOW',
//   style: TextStyle(
//   fontSize: 14,
//   color: Colors.black87,
//   fontWeight: FontWeight.w500,
//   decoration: TextDecoration.underline,
//   decorationThickness: 1.0,
//   decorationColor: Colors.black87,
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//   ),
//   ),
//           Expanded(
//             flex: 2,
//             child: Container(
//               height: sectionHeight,
//               child: ListView.builder(
//                 controller: _scrollController,
//                 scrollDirection: Axis.horizontal,
//                 itemCount: designerData.length,
//                 padding: EdgeInsets.symmetric(horizontal: 9.0),
//                 itemBuilder: (context, index) {
//                   final designer = designerData[index];
//                   final String? imagePath = designer['image'];
//                   final String bannerName = designer['name'] ?? 'No Title';
//                   final int bannerId = designer['id'];
//                   double itemWidth = 200;
//                   double imageHeight = 280;
//
//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => HomeScreenBannerListing(
//                             bannerName: bannerName,
//                             bannerId: bannerId,
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       width: itemWidth,
//                       margin: const EdgeInsets.symmetric(horizontal: 9.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           (imagePath != null && imagePath.isNotEmpty)
//                               ? ClipRRect(
//                             child: Image.asset(
//                               imagePath,
//                               width: itemWidth,
//                               height: imageHeight,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) {
//                                 return Container(
//                                   width: itemWidth,
//                                   height: imageHeight,
//                                   color: Colors.grey[300],
//                                   child: Center(
//                                     child: Icon(Icons.broken_image,
//                                         color: Colors.grey[600]),
//                                   ),
//                                 );
//                               },
//                             ),
//                           )
//                               : Container(
//                             width: itemWidth,
//                             height: imageHeight,
//                             color: Colors.grey[200],
//                             child: Center(
//                               child: Icon(Icons.image_not_supported,
//                                   color: Colors.grey[500]),
//                             ),
//                           ),
//
//                           // 👇 Removed the Text widget displaying designer name
//                           // You can re-enable this later if needed
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//   ],
//   ),
//
//                   // Removing any unnecessary space
//
//                 ],
//               ),
//
//
//
//
//
//
//
//
//   Container(
//   padding: EdgeInsets.zero,
//   margin: EdgeInsets.zero,
//   child: Column(
//   mainAxisSize: MainAxisSize.min,
//   children: readytoShip.map((item) {
//   final String imagePath = item['image'] as String;
//   final int bannerId = item['id'] as int;
//   final String bannerName = item['name'] as String;
//
//   return GestureDetector(
//   onTap: () {
//   Navigator.push(
//   context,
//   MaterialPageRoute(
//   builder: (_) => HomeScreenBannerListing(
//   bannerName: bannerName,
//   bannerId: bannerId,
//   ),
//   ),
//   );
//   },
//   child: ClipRRect(
//   child: Image.asset(
//   imagePath,
//   width: 350,
//   height: 380,
//   fit: BoxFit.cover,
//   ),
//   ),
//   );
//   }).toList(),
//   ),
//   )
//   ,
//
//
//              SizedBox(height: 10,),
//
//
//               // A+Co Edits
//
//   Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: Container(
//       padding: const EdgeInsets.symmetric(vertical: 16),
//       color: const Color(0xFFC9C8C7),
//       child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//       Padding(
//       padding: const EdgeInsets.only(left: 16.0, top: 16.0),
//       child: Center(
//         child: Text(
//         'A+CO EDITS',
//         style: TextStyle(fontSize: 22),
//         ),
//       ),
//       ),
//       const SizedBox(height: 8), // Space between text and slider
//       SizedBox(
//       height: 450, // Height for the slider
//       child: PageView.builder(
//       controller: _pageControllerACOEdit,
//       itemCount: ACoEditImages.length,
//       itemBuilder: (context, index) {
//       return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//       child: ClipRRect(
//
//       child: Image.asset(
//       ACoEditImages[index],
//       width: 160,
//       height: 320,
//       fit: BoxFit.cover,
//       ),
//       ),
//       );
//       },
//       ),
//       ),
//       ],
//       ),
//     ),
//   ),
//
//             SizedBox(height: 10,),
//
//               //Shop by Style-1
//               // SHOP BY STYLE - TITLE
//               Container(
//                 padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
//                 alignment: Alignment.centerLeft,
//                 child: Center(
//                   child: Text(
//                     'SHOP BY STYLE',
//                     style: TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//
// // GRID VIEW
//               Container(
//                 padding: const EdgeInsets.all(8.0), // Padding around the grid
//                 child: GridView.builder(
//                   physics: const NeverScrollableScrollPhysics(), // Prevents internal scrolling
//                   shrinkWrap: true, // Allows the grid to adjust its height dynamically
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2, // 2 columns
//                     crossAxisSpacing: 8, // Space between columns
//                     mainAxisSpacing: 8, // Space between rows
//                     childAspectRatio: 0.75, // Makes images proportionate
//                   ),
//                   itemCount: shopbyStyle1.length,
//                   itemBuilder: (context, index) {
//                     final aco = shopbyStyle1[index];
//                     return Column(
//                       children: [
//                         AspectRatio(
//                           aspectRatio: 3 / 4, // Ensures images are always proportional
//                           child: ClipRRect(
//                             // borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
//                             child: Image.asset(
//                               aco['image']!,
//                               width: double.infinity, // Takes full width of grid cell
//                               fit: BoxFit.cover, // Ensures proper scaling
//                             ),
//                           ),
//                         ),
//                         // const SizedBox(height: 8), // Space between image and text (if needed)
//                       ],
//                     );
//                   },
//                 ),
//               )
//
//               ,
//
//
//
//
//
//               //SHOP BY OCCASSION
//
//
//   Container(
//   color: Colors.black,
//   padding: const EdgeInsets.symmetric(vertical: 35), // Slightly increased padding
//   child: Column(
//   mainAxisAlignment: MainAxisAlignment.center,
//   children: [
//   Text(
//   "SHOP BY OCCASIONS",
//   style: TextStyle(
//   color: Colors.white,
//   fontSize: 22, // Increased font size slightly
//   fontWeight: FontWeight.bold, // Enhanced visibility
//   ),
//   ),
//   const SizedBox(height: 14), // Slightly increased spacing
//
//   SizedBox(
//   height: MediaQuery.of(context).size.height * 0.52, // Increased height
//   child: PageView.builder(
//   controller: _pageControllerShop,
//   onPageChanged: (index) => setState(() => _currentShopByOccassionIndex = index),
//   itemCount: shopByOccassionImages.length,
//   itemBuilder: (context, index) {
//   return Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optimized padding
//   child: ClipRRect(
//   // More natural rounding
//   child: AspectRatio(
//   aspectRatio: 3 / 4, // Maintains consistent image proportions
//   child: Image.asset(
//   shopByOccassionImages[index],
//   fit: BoxFit.cover,
//   width: double.infinity,
//   ),
//   ),
//   ),
//   );
//   },
//   ),
//   ),
//   ],
//   ),
//   ),
//
//
//   //Designer of the Week
//
//               SizedBox(height:10),
//   Padding(
//   padding: const EdgeInsets.symmetric(horizontal: 8), // Padding on both sides
//   child: Column(
//   children: [
//   Container(
//   height: 580, // Set uniform height
//   width: double.infinity, // Full width
//   decoration: BoxDecoration(
//   image: DecorationImage(
//   image: AssetImage('assets/Designer-of-the-week.jpg'),
//   fit: BoxFit.cover, // Ensures full coverage without distortion
//   ),
//   ),
//   ),
//   SizedBox(height: 8), // Space between images
//   Container(
//   height: 350, // Same height as above image
//   width: double.infinity, // Full width
//   decoration: BoxDecoration(
//   image: DecorationImage(
//   image: AssetImage('assets/Celeb-Spotting.jpg'),
//   fit: BoxFit.cover, // Ensures full coverage without distortion
//   ),
//   ),
//   ),
//   ],
//   ),
//   ),
//
//
//
//
//
//
//
//               //A+Co Bridal Edit
//               SizedBox(height:15),
//
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Column( // No fixed height
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Center(
//                       child: Text(
//                         "A+CO BRIDAL EDITS",
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
//                     ClipRRect(
//                       child: Image.asset(
//                         'assets/Here-comes-the-bride.jpg',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//
//                     // Remove fixed height
//                     Column(
//                       children: [
//                         SizedBox(
//                           height: acoBridalEdit.length * 590, // Adjust height dynamically
//                           child: ListView.builder(
//                             shrinkWrap: true,
//                             physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
//                             itemCount: acoBridalEdit.length,
//                             itemBuilder: (context, index) {
//                               final aco = acoBridalEdit[index];
//                               return Padding(
//                                 padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjust spacing
//                                 child: ClipRRect(
//                                   // borderRadius: BorderRadius.circular(8), // Optional rounded corners
//                                   child: Image.asset(
//                                     aco['image']!,
//                                     width: double.infinity, // Full width
//                                     height: 580, // Keep the original height
//                                     fit: BoxFit.cover,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     )
//                     ,
// SizedBox(height: 10,),
//                     ClipRRect(
//                       child: Image.asset(
//                         'assets/Code-Red.jpg',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 10,),
//               //Accessory Edit
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 8),
//                 child: Column( // No fixed height
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Center(
//                       child: Text(
//                         "ACCESSORY EDIT",
//                         style: TextStyle(color: Colors.black, fontSize: 20),
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: ClipRRect(
//                             child: Image.asset(
//                               'assets/Bride-Bling.jpg',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 8), // Optional spacing between images
//                         Expanded(
//                           child: ClipRRect(
//                             child: Image.asset(
//                               'assets/Finishing-Touches.jpg',
//                               fit: BoxFit.cover,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//
// SizedBox(height: 10,),
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         double screenWidth = constraints.maxWidth;
//                         int crossAxisCount = screenWidth > 600 ? 3 : 2; // 2 columns on small screens, 3 on larger screens
//                         double childAspectRatio = screenWidth > 600 ? 0.7 : 0.6; // Adjust aspect ratio based on screen size
//
//                         return GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: crossAxisCount, // Responsive columns
//                             crossAxisSpacing: 10.0,
//                             mainAxisSpacing: 10.0,
//                             childAspectRatio: childAspectRatio, // Adjust image height
//                           ),
//                           itemCount: accessoryEdit.length,
//                           itemBuilder: (context, index) {
//                             final aco = accessoryEdit[index];
//                             return ClipRRect(
//
//                               child: Image.asset(
//                                 aco['image']!,
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     )
//
//                     ,
//
//
//
//
//                   ],
//                 ),
//               ),
//
//               SizedBox(height: 10,),
//               //Mens Wear Edit
//
//               Container(
//                 color: Colors.black,
//                 padding: EdgeInsets.symmetric(vertical: 50),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "MENS WEAR EDIT",
//                       style: TextStyle(color: Colors.white, fontSize: 24),
//                     ),
//                     SizedBox(height: 20),
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         double screenWidth = constraints.maxWidth;
//
//                         // Adjust column count based on screen width
//                         int crossAxisCount = 2; // Default for phones
//                         if (screenWidth > 600) crossAxisCount = 3; // Tablets
//                         if (screenWidth > 900) crossAxisCount = 4; // Large screens
//
//                         // Adjust image height proportionally
//                         double childAspectRatio = screenWidth > 600 ? 0.8 : 0.7;
//
//                         return GridView.builder(
//                           shrinkWrap: true,
//                           physics: NeverScrollableScrollPhysics(), // Prevents internal scrolling
//                           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: crossAxisCount, // Responsive columns
//                             crossAxisSpacing: 10.0,
//                             mainAxisSpacing: 10.0,
//                             childAspectRatio: childAspectRatio, // Adjust image height
//                           ),
//                           itemCount: mensWearEdit.length,
//                           itemBuilder: (context, index) {
//                             return ClipRRect(
//                             // Optional rounded corners
//                               child: Image.asset(
//                                 mensWearEdit[index],
//                                 fit: BoxFit.cover,
//                               ),
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               )
//
//               ,
//
//               // 3 images
//
//               SizedBox(height: 10,),
//
//               Column(
//                 children: bottomImages.map((aco) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
//                     child: SizedBox(
//                       width: 390,
//                       height: 480,
//                       child: ClipRRect(
//                         child: Image.asset(
//                           aco['image']!,
//                           fit: BoxFit.cover, // Ensures consistent display
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//
// SizedBox(height: 10,),
//
//   Padding(
//     padding: const EdgeInsets.all(8.0),
//     child: ClipRRect(
//     child: Image.asset(
//     'assets/Bridal Trends in 2025.jpg',
//     fit: BoxFit.cover,
//     ),
//     ),
//   ),
// SizedBox(height: 10,),
//               Column(
//                 children: bottomImage2.map((aco) {
//                   return Padding(
//                     padding: const EdgeInsets.symmetric( horizontal: 8),
//                     child: SizedBox(
//                       width: 390,
//                       height: 400,
//                       child: ClipRRect(
//                         child: Image.asset(
//                           aco['image']!,
//                           fit: BoxFit.fitWidth, // Ensures consistent display
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               )
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//             ],
//           ),
//         ),
//       ),
//     ],
//   );
// }
//
//
//
//
//   Widget _buildSearchTab() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.search, size: 50, color: Colors.green),
//           SizedBox(height: 10),
//           Text(
//             "Search for items here!",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//
// Widget build(BuildContext context) {
//   final List<Widget> _tabs = [
//     _buildHomeTab(),
//     _buildSearchTab(),
// // Use the separate ProfileWidget class
//   ];
//
//   return Scaffold(
//     backgroundColor: Colors.white,
//     // appBar: AppBar(
//     //   title: Image.asset(
//     //     'assets/logo.jpeg', // Replace with the path to your image
//     //     height: 40, // Adjust height as needed
//     //   ),
//     //   centerTitle: true, // Centers the image in the AppBar
//     //   backgroundColor: Colors.white, // Customize background color
//     // ),
//     body: _tabs[_selectedIndex], // Show content of the selected tab
//
//   );
// }
//
//
//
// }
