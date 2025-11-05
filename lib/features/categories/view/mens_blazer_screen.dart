import 'package:aashniandco/features/categories/view/product_details.dart';
import 'package:flutter/material.dart';

class BlazersCategoryScreen extends StatefulWidget {
  @override
  State<BlazersCategoryScreen> createState() => _BlazersCategoryScreenState();
}

class _BlazersCategoryScreenState extends State<BlazersCategoryScreen> {
  final List<Map<String, String>> blazers = [
    {
      "name": "Asuka Couture",
      "description": "Charcoal grey wool suit set",
      "price": "₹25,500",
      "image": "assets/asuka_blazer.png"
    },
    {
      "name": "Paarsh Atelier",
      "description": "Dusty beige artsy giraffe appliqued blazer",
      "price": "₹17,900",
      "image": "assets/Banner-3.jpeg"
    },
    {
      "name": "Jatin Malik",
      "description": "Charcoal grey floral embroidery blazer set",
      "price": "₹78,500",
      "image": "assets/Banner-3.jpeg"
    },
    {
      "name": "Achkann",
      "description": "Black clock embroidered tuxedo set",
      "price": "₹30,999",
      "image": "assets/Banner-3.jpeg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Blazers'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: blazers.length, // Use the list's length
          itemBuilder: (context, index) {
            // Get the current blazer's data
            final blazer = blazers[index];
       return GestureDetector(
      onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsScreen(
                      product: blazer,
                    ),
                  ),
                );
              },
  child: SizedBox(
    height: 900, // Increase card height
    child: Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2, // Controls image height relative to the card
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                    image: DecorationImage(
                      image: AssetImage(blazer['image']!), // Dynamic image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8.0,
                  right: 8.0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        // Add to wishlist functionality
                      },
                      iconSize: 18,
                    ),
                  ),
                ),
                Positioned(
                  top: 58.0,
                  right: 4.0,
                  child: Container(
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.shopping_cart,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        // Add to cart functionality
                      },
                      iconSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  blazer['name']!, // Dynamic name
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  blazer['price']!, // Dynamic price
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);

          },
        ),
      ),
    );
  }
}
