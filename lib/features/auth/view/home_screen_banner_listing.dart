import 'dart:convert';

import 'package:aashniandco/features/auth/view/wishlist_screen.dart';
import 'package:flutter/material.dart';

import '../../../common/dialog.dart';
import '../../../constants/user_preferences_helper.dart';
import '../../newin/bloc/new_in_bloc.dart';
import '../../newin/bloc/new_in_state.dart';
import '../../newin/model/new_in_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../newin/view/filter_bottom_sheet.dart';
import '../../newin/view/product_details_newin.dart';
import '../../shoppingbag/shopping_bag.dart';
import '../bloc/home_screen_banner_bloc.dart';
import '../bloc/home_screen_banner_event.dart';
import '../bloc/home_screen_banner_state.dart';
import 'auth_screen.dart';
import 'login_screen.dart';

class HomeScreenBannerListing extends StatefulWidget {
  final String bannerName;
  final int bannerId;


  const HomeScreenBannerListing({
    super.key,
    required this.bannerName, required this.bannerId,
  });

  @override
  State<HomeScreenBannerListing> createState() => _HomeScreenBannerListingState();
}

class _HomeScreenBannerListingState extends State<HomeScreenBannerListing> {
  String selectedSort = "Latest";
  List<dynamic> sortedProducts = [];
  String firstName = '';
  String lastName = '';


  @override
  void initState() {
    super.initState();

    print("Banner ID: ${widget.bannerId}");
    _loadUserNames();

    context.read<HomeScreenBannerBloc>().add(FetchHomeScreenBanner(bannerName: widget.bannerName, id: widget.bannerId));
  }


  Future<void> _loadUserNames() async {
    final fName = await UserPreferences.getFirstName();
    final lName = await UserPreferences.getLastName();
    setState(() {
      firstName = fName;
      lastName = lName;
    });
  }

  void sortProducts(List<Product> products) {
    sortedProducts = List<Product>.from(products);
    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => (b.actualPrice ?? 0).compareTo(a.actualPrice ?? 0));
    } else if (selectedSort == "Low to High") {
      sortedProducts.sort((a, b) => (a.actualPrice ?? 0).compareTo(b.actualPrice ?? 0));
    } else if (selectedSort == "Latest") {
      sortedProducts.sort((a, b) {
        final idA = int.tryParse(a.prod_en_id ?? '0') ?? 0;
        final idB = int.tryParse(b.prod_en_id ?? '0') ?? 0;
        return idB.compareTo(idA);
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   appBar: AppBar(title: Text('Banner: ${widget.bannerName}')),
    //   body: Center(
    //     child: Text('Showing details for ${widget.bannerName}'),
    //   ),
    // );

    return Scaffold(
      // appBar: AppBar(title: Text('${widget.bannerName}')),
      appBar: AppBar(
        title:
        Column(
          children: [
            // Image.asset('assets/logo.jpeg', height: 30),
            // const SizedBox(width: 10), // space between image and text
            Center(child: Text("${widget.bannerName}", style: const TextStyle(fontSize: 24, color: Colors.black,fontWeight: FontWeight.bold))),
          ],
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: LayoutBuilder(
              builder: (context, constraints) {
                double screenWidth = constraints.maxWidth;
                double fontSize = screenWidth > 360 ? 13 : 10;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    "",
                    style: TextStyle(fontSize: fontSize, color: Colors.black, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),

        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const SearchScreen(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_bag_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<HomeScreenBannerBloc, HomeScreenBannerState>(
        builder: (context, state) {
          if (state is HomeScreenBannerLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HomeScreenBannerError) {
            return Center(child: Text(state.message));
          } else if (state is HomeScreenBannerLoaded) {
            sortProducts(state.products);

            if (sortedProducts.isEmpty) {
              return const Center(child: Text("No products found"));
            }

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(''),
                      Container(
                        height: 35,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: DropdownButton<String>(
                          value: selectedSort,
                          icon: const Icon(Icons.sort, color: Colors.black),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          dropdownColor: Colors.white,
                          underline: Container(),
                          onChanged: (value) {
                            setState(() {
                              selectedSort = value!;
                              sortProducts(state.products);
                            });
                          },
                          items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
                            return DropdownMenuItem<String>(
                              value: sortOption,
                              child: Text(sortOption, style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Product Grid
                  Expanded(
                    child: GridView.builder(
                      itemCount: sortedProducts.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.5,
                      ),
                      itemBuilder: (context, index) {
                        final item = sortedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            print("Designer Data: ${jsonEncode(item.toJson())}");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailNewInDetailScreen(product: item.toJson()),
                              ),
                            );
                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Product Image
                                Flexible(
                                  child: Image.network(
                                    item.prodSmallImg ?? item.prodThumbImg ?? '',
                                    width: double.infinity,
                                    height: 550,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: double.infinity,
                                        height: 550,
                                        color: Colors.grey[300],
                                        alignment: Alignment.center,
                                        child: const Icon(Icons.image_not_supported, size: 50),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Designer Name
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      item.designerName ?? "Unknown",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                // Short Description
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Center(
                                    child: Text(
                                      item.shortDesc ?? "No description",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),

                                // Price
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(
                                    child: Text(
                                      "₹${item.actualPrice?.toStringAsFixed(0) ?? 'N/A'}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),

      // Floating Filter Button
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
              );
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const WishlistScreen()),
                    (route) => false,
              );
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const AccountScreen()),
                    (route) => false,
              );
              break;
          }
        },
      ),
    );

  }
}
