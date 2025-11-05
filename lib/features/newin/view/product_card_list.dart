import 'package:aashniandco/features/newin/view/product_card_list.dart';
import 'package:flutter/material.dart';
import '../../../constants/text_styles.dart';
import '../../auth/view/auth_screen.dart';
import '../../auth/view/login_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../model/new_in_model.dart';
// Replace with actual import



class ProductCardListView extends StatefulWidget {
  final List<Product> products;
  final String initialTab;

  const ProductCardListView({
    super.key,
    required this.products,
    this.initialTab = "New In",
  });

  @override
  State<ProductCardListView> createState() => _ProductCardListViewState();
}

class _ProductCardListViewState extends State<ProductCardListView> {
  String selectedSort = 'High to Low';
  late List<Product> sortedProducts;

  final tabTitles = ["Exclusives", "New In", "Categories", "Designers"];

  @override
  void initState() {
    super.initState();
    sortedProducts = List<Product>.from(widget.products);
    sortProducts();
  }

  void sortProducts() {
    if (selectedSort == "High to Low") {
      sortedProducts.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
    } else {
      sortedProducts.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialIndex = tabTitles.indexOf(widget.initialTab);

    return DefaultTabController(
      length: 4,
      initialIndex: initialIndex >= 0 ? initialIndex : 1,
      child: Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/logo.jpeg', height: 30),
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: TabBar(
              labelColor: Colors.black,
              indicatorColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: tabTitles.map((tab) {
                return Tab(
                  child: Text(
                    tab,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            const Center(child: Text("Exclusives")),
            buildProductListTab(),
            const Center(child: Text("Categories")),
            const Center(child: Text("Designers")),
          ],
        ),
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
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                      (route) => false,
                );
                break;
              case 1:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WishlistScreen()),
                      (route) => false,
                );
                break;
              case 2:
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AccountScreen()),
                      (route) => false,
                );
                break;
            }
          },
        ),
      ),
    );
  }

  Widget buildProductListTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, right: 12),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              height: 35,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedSort,
                icon: const Icon(Icons.sort, color: Colors.black),
                style: const TextStyle(color: Colors.black, fontSize: 14),
                dropdownColor: Colors.white,
                underline: Container(),
                onChanged: (value) {
                  setState(() {
                    selectedSort = value!;
                    sortProducts();
                  });
                },
                items: ["High to Low", "Low to High"].map((sortOption) {
                  return DropdownMenuItem<String>(
                    value: sortOption,
                    child: Text(sortOption),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: sortedProducts.length,
            itemBuilder: (context, index) {
              final product = sortedProducts[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      product.prodSmallImg,
                      width: double.infinity,
                      height: 550,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 550,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_not_supported, size: 50),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          product.designerName,
                          style: AppTextStyle.designerName,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        child: Text(
                          product.shortDesc,
                          style: AppTextStyle.shortDescription,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          "₹${product.actualPrice.toStringAsFixed(0)}",
                          style: AppTextStyle.actualPrice,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

