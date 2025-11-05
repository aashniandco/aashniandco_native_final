import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Map<String, String> product;

  ProductDetailsScreen({required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  String selectedSize = "M"; // State to track selected size
  int _currentIndex = 0; // To track the current image index

  @override
  Widget build(BuildContext context) {
    List<String> images = [
      widget.product['image']!,
      'assets/asuka_blazer.png', // Add other images as needed
      'assets/asuka_blazer.png', // Add other images as needed
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['name']!),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with PageView (swipeable images)
    Stack(
  children: [
    Column(
      children: [
        // PageView for swiping images
        SizedBox(
          height: 300, // Set your desired height
          width: double.infinity,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index; // Update the current index
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        // Page indicator centered below the PageView
  Center(
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(
      images.length,
      (index) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6), // Add sufficient horizontal margin
        height: 8,
        width: _currentIndex == index ? 12 : 8,
        decoration: BoxDecoration(
          color: _currentIndex == index ? Colors.black : Colors.grey,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
  ),
),

      ],
    ),
    // Wishlist Button
    Positioned(
      top: 190,
      right: 10,
      child: GestureDetector(
        onTap: () {
          print("Wishlist button clicked");
          // Add wishlist functionality here
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6), // Semi-transparent background
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.favorite_border,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    ),
    // Share Button
    // Share Button
Positioned(
  bottom: 10,
  right: 10,
  child: GestureDetector(
    onTap: () {
      _shareProductDetails();
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6), // Semi-transparent background
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.share,
        color: Colors.white,
        size: 24,
      ),
    ),
  ),
),

  ],
),

            
            const SizedBox(height: 16),
            // Product Name and Price
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.product['name']!,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                // Positioned to keep the button and text aligned to the right
                SizedBox(width: 80),
                Expanded(
                  child: Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Rounded corners for the dialog
                              ),
                              child: Stack(
                                children: [
                                  // Main Content of the Dialog
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Image.asset(
                                          'assets/size_chart.png', // Replace with your image path
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  ),
                                  // Close Button
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade200,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          // "Size Chart" text
                          Text(
                            'Size Chart',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(width: 8),
                          // Icon Button
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6), // Semi-transparent background
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.show_chart,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.product['price']!,
                style: const TextStyle(fontSize: 14, color: Colors.red),
              ),
            ),
            
            const SizedBox(height: 16),
            // Size Selection
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Select Size:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var size in ["XS", "S", "M", "L", "XL", "XXL", "3XL", "4XL", "5XL", "6XL", "CM"])
                      _buildSizeOption(size),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Delivery Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text(
                "Delivery: 6-7 Weeks",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16),
            // Expandable Sections
            _buildExpandableSection("DETAILS", "Detailed description of the product."),
            _buildExpandableSection("COMPOSITION & CARE", "Care instructions for the product."),
            _buildExpandableSection("DISCLAIMER", "General disclaimer content."),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: "Add to Cart",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_checkout_sharp),
            label: "Buy Now",
          ),
        ],
        onTap: (index) {
          // Handle navigation based on tapped index
          if (index == 0) {
            print("Buy Now tapped");
            // Add Buy Now functionality
          } else if (index == 1) {
            print("Add to Cart tapped");
            // Add Add to Cart functionality
          }
        },
      ),
    );
  }

void _shareProductDetails() {
  String productName = widget.product['name']!;
  String productPrice = widget.product['price']!;
  String productImage = widget.product['image']!; // Local asset path or network URL

  Share.share(
    'Check out this amazing product: $productName\nPrice: $productPrice\nGet it here: https://aashniandco.com/asuka-couture-off-white-pinstripe-suit-and-waistcoat-set-ascsep2405.html/${widget.product['id']}',
    subject: 'Amazing Product: $productName',
  );
}

  // Widget for Size Option
  Widget _buildSizeOption(String size) {
    bool isSelected = size == selectedSize;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedSize = size;
          });
        },
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? Colors.black : Colors.white,
            border: Border.all(color: isSelected ? Colors.black : Colors.grey),
          ),
          child: Center(
            child: Text(
              size,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget for Expandable Section
  Widget _buildExpandableSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
