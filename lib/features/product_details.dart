import 'dart:io';

import 'package:flutter/material.dart';
import 'package:aashniandco/features/shoppingbag/shopping_bag.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

// designer
class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;


  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int selectedSizeIndex = 0; // Default selected size
  // List<String> sizes = ["S", "M", "L"]; // Dummy size options
  List<String> sizes = [];
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    // ✅ Extract sizes from API response and convert to short forms
    if (widget.product['size_name'] != null && widget.product['size_name'] is List) {
      sizes = List<String>.from(widget.product['size_name']).map((size) {
        switch (size.toLowerCase()) {
          case "xxsmall": return "XXS";
          case "xsmall": return "XS";
          case "small": return "S";
          case "medium": return "M";
          case "large": return "L";
          case "xlarge": return "XL";
          case "xxlarge": return "XXL";
          case "3xlarge": return "3XL";
          case "4xlarge": return "4XL";
          case "5xlarge": return "5XL";
          case "6xlarge": return "6XL";
          case "custom made": return "CM";
          default: return size; // Fallback for unknown sizes
        }
      }).toList();
    } else {
      sizes = ["S", "M", "L"]; // Fallback sizes if no data is available
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  void _showSizeChartDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Ensures full-screen modal
      backgroundColor: Colors.transparent, // Make it full screen
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height, // Full height
          width: MediaQuery.of(context).size.width,   // Full width
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset(
                    "assets/women_size_chart.png",
                    fit: BoxFit.contain, // Ensures the image fits well
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    // Extract small and thumbnail images
    final List<String> images = [
      if (widget.product['prod_small_img'] != null) widget.product['prod_small_img'],
      if (widget.product['prod_thumb_img'] != null) widget.product['prod_thumb_img'],
    ];


    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
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
      body: Column(
        children: [
          // ✅ Scrollable Content (Product Details)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Carousel
                  SizedBox(
                    height: 400,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          images[index],
                          width: double.infinity,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported, size: 50),
                          ),
                        );
                      },
                    ),
                  ),

                  // Product Details
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.product['designer_name'] ?? "Unknown Designer",
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(widget.product['short_desc'] ?? "No description available",
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 10),
                        Text("₹${widget.product['actual_price_1'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 20, color: Colors.black)),
                        const SizedBox(height: 5),
                        Text("SKU: ${widget.product['prod_sku'] ?? 'N/A'}",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  // Size Selector
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🔹 Size Selection Grid
                      SizedBox(
                        height: (sizes.length / 4).ceil() * 80,
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                          itemCount: sizes.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedSizeIndex = index;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.black),
                                  color: selectedSizeIndex == index ? Colors.black : Colors.white,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  sizes[index],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: selectedSizeIndex == index ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 10),

                      // 🔹 Size Chart Button (Separate from Grid)
                      GestureDetector(
                        onTap: () => _showSizeChartDialog(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const Text(
                              "Size Chart",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.insert_chart, size: 24, color: Colors.black),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),


                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: const Text("Ships In: 3-4 Weeks", style: TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                  const SizedBox(height: 15),

                  // Buy Now & Add to Cart Buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(60, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text("BUY NOW", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: const Size(60, 60),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                            ),
                            child: const Text("ADD TO CART", style: TextStyle(color: Colors.white)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: const Icon(Icons.favorite_border),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Expandable Sections
                  ExpansionTile(
                    title: const Text("DETAILS", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          (widget.product['prod_desc'] is List)
                              ? widget.product['prod_desc'].join(", ")
                              : widget.product['prod_desc'] ?? "No description available",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text("DISCLAIMER", style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Disclaimer:\n"
                              "This product is made to order.\n"
                              "Product color may slightly vary due to photographic lighting sources or your monitor setting.\n"
                              "For any sizing queries please connect with us on +91 83750 36648\n\n"
                              "${widget.product['disclaimer'] ?? 'No disclaimer available.'}",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ✅ Fixed Bottom Section (Customer Support)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: Column(
              children: [
                const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _supportButton(Icons.chat, "Chat With Us", () {
                      _openWhatsApp("+918375036648");
                    }),
                    _supportButton(Icons.phone, "+91 8375036648", () {
                      _makePhoneCall("+918375036648");
                    }),
                    _supportButton(Icons.email, "Mail us", () {
                      _sendEmail("support@example.com");
                    }),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  }

  Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, size: 30),
          onPressed: onPressed,
        ),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }


  void _openWhatsApp(String phone) async {
    String url;

    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phone";
    } else if (Platform.isIOS) {
      print("whatsapp IOS clicked>>");
      url = "https://wa.me/$phone";
    } else {
      url = "https://wa.me/$phone";
    }

    // Ensure launchUrl is called
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }


  void _makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");

    if (await canLaunchUrl(url)) {
      print("Launching dialer...");
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("Error: Cannot launch dialer for $phone");
    }
  }


  void _sendEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email"); // ✅ Correct scheme

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      print("Could not launch email for $email");
    }
  }




}
