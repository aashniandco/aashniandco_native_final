import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/search/presentation/search_screen.dart';
import '../features/shoppingbag/shopping_bag.dart';

// Import your screen pages
// import 'path/to/search_screen.dart';
// import 'path/to/shopping_bag_screen.dart';

/// A reusable, application-wide AppBar.
///
/// It implements [PreferredSizeWidget] to be used in a Scaffold's appBar property.
/// This AppBar contains the standard actions (search, cart) and styling.
/// The title can be customized by passing a `titleWidget`.
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your screen pages
// import 'path/to/search_screen.dart';
// import 'path/to/shopping_bag_screen.dart';

/// A reusable, application-wide AppBar.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? titleWidget;
  final bool automaticallyImplyLeading;

  const CommonAppBar({
    super.key,
    this.titleWidget,
    this.automaticallyImplyLeading = false,
  });

  // Helper widget to manage the state of the cart icon
  Widget _buildCartIcon() {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        int cartQty = 0;

        Future<void> fetchCartQuantity() async {
          final prefs = await SharedPreferences.getInstance();
          final customerToken = prefs.getString('user_token');
          if (customerToken == null || customerToken.isEmpty) {
            if (context.mounted) setState(() => cartQty = 0);
            return;
          }
          try {
            HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
            IOClient ioClient = IOClient(httpClient);
            final response = await ioClient.get(
              Uri.parse('https://aashniandco.com/rest/V1/carts/mine'),
              headers: {'Authorization': 'Bearer $customerToken'},
            );
            if (context.mounted && response.statusCode == 200) {
              final data = json.decode(response.body);
              setState(() => cartQty = data['items_count'] ?? 0);
            }
          } catch (e) {
            print('Error fetching cart in AppBar: $e');
            if (context.mounted) setState(() => cartQty = 0);
          }
        }

        fetchCartQuantity();

        return IconButton(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.shopping_bag_rounded, color: Colors.black),
              if (cartQty > 0)
                Positioned(
                  right: -6,
                  top: -6,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$cartQty',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          onPressed: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingBagScreen()));
            fetchCartQuantity(); // Refresh after returning
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget,
      automaticallyImplyLeading: automaticallyImplyLeading,
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      centerTitle: true,
      toolbarHeight: 30, // 👈 custom height here
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showDialog(context: context, builder: (context) => const SearchScreen1());
          },
        ),
        _buildCartIcon(),
      ],
    );
  }
  // Widget build(BuildContext context) {
  //   return AppBar(
  //     title: titleWidget,
  //     automaticallyImplyLeading: automaticallyImplyLeading,
  //     elevation: 0,
  //     backgroundColor: Colors.white,
  //     foregroundColor: Colors.black,
  //     centerTitle: true,
  //
  //     actions: [
  //       IconButton(
  //         icon: const Icon(Icons.search),
  //         onPressed: () {
  //           showDialog(context: context, builder: (context) => const SearchScreen1());
  //         },
  //       ),
  //       _buildCartIcon(),
  //     ],
  //   );
  // }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}