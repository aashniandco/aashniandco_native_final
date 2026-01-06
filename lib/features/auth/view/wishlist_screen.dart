import 'package:aashniandco/bloc/login/login_screen_bloc.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart';
import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:flutter/material.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  Widget build(BuildContext context) {
    // primary color
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/logo.jpeg', // Replace with your image path
          height: 30, // Adjust height as needed
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          // Search Icon
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Add functionality for search button
              print("Search clicked");
            },
          ),
          // Shopping Bag Icon
          IconButton(
            icon: Icon(Icons.shopping_bag),
            onPressed: () {
              // Add functionality for shopping bag button
              print("Shopping bag clicked");
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 80,),
          Center(
            child: Text(
              "Your Wishlist is Empty", // Placeholder text
              style: TextStyle(fontSize: 24),
            ),
            
          
           
          ),

          ElevatedButton(onPressed: (){
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> AccountScreen()));

          }, child: Text('Sign in to sync Wishlist'))
        ],
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Account"),
        ],
        onTap: (index) {
          // Navigate based on the tapped index
          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WishlistScreen()),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
              break;
            case 2:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
                (Route<dynamic> route) => false, // Removes all previous routes
              );
              break;
          }
        },
      ),
    );
  }
}
