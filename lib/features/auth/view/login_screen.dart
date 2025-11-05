import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/signup/view/signup_screen.dart';
import 'package:aashniandco/features/auth/view/wishlist_screen.dart';
import 'package:flutter/material.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      
    appBar: AppBar(
        leading: IconButton(
    icon: Icon(Icons.arrow_back, color: Colors.black), // Back button icon
    onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (context)=> AuthScreen())) ;// Navigates to the previous screen
    },
  ),
  title: const Text(
    'Login', // Title text
    style: TextStyle(
      color: Colors.black, // Text color
      fontWeight: FontWeight.bold, // Bold font
    ),
  ),
  elevation: 0, // No shadow
  backgroundColor: Colors.white, // White background
  foregroundColor: Colors.black, 
     
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  print("Sign in with Google clicked");
                },
                icon: Image.asset(
                  'assets/google_logo.png', // Replace with your Google logo asset
                  height: 24,
                  width: 24,
                ),
                label: const Text("Sign In with Google",style: TextStyle(fontSize: 12),),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.grey),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("or", style: TextStyle(color: Colors.grey)),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Email *",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
          Container(
  height: 70, // Set the desired height
  child: TextField(
    decoration: InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      hintText: "Enter Email",
         hintStyle: TextStyle(
        fontSize: 14, // Set the desired font size
        color: Colors.grey, // Optional: Set a hint text color
      ),
    ),
  ),
),

              const SizedBox(height: 20),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Password *",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                 height: 70, 
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: "Enter Password",
                    suffixIcon: const Icon(Icons.visibility_off),
                       hintStyle: TextStyle(
        fontSize: 14, // Set the desired font size
        color: Colors.grey, // Optional: Set a hint text color
      ),
                    
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print("Forgot Password clicked");
                  },
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(color: Colors.redAccent,fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        print("Sign In clicked");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("SIGN IN",style: TextStyle(
                        color: Colors.white
                      ),)
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Expanded(
                  //   child: ElevatedButton(
                  //     onPressed: () {
                  //       print("Login with OTP clicked");
                  //     },
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white,
                  //       foregroundColor: Colors.black,
                  //       side: const BorderSide(color: Colors.orange),
                  //       minimumSize: const Size(0, 50),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //     ),
                  //     child: const Text("Login With OTP"),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account yet? ",style: TextStyle(fontSize: 12),),
                  GestureDetector(
                    onTap: () {
                      print("Sign Up clicked");

                      Navigator.push(context, MaterialPageRoute(builder: (context) => SignupScreen ()));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Colors.redAccent,fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
 
    );
  }
}