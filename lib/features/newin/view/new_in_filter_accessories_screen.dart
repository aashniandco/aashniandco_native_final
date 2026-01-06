
import 'dart:async';

import 'package:aashniandco/common/dialog.dart';
import 'package:aashniandco/features/auth/view/auth_screen.dart';
import 'package:aashniandco/features/auth/view/login_screen.dart';
import 'package:aashniandco/features/newin/view/new_in_filter_accessories_screen.dart';
import 'package:aashniandco/features/designer/bloc/designers_screen.dart';
import 'package:aashniandco/features/newin/view/product_card.dart';
import 'package:aashniandco/features/shoppingbag/shopping_bag.dart';
import 'package:flutter/material.dart';

import '../../../constants/text_styles.dart';
import '../../auth/view/home_screen.dart';
import '../../auth/view/wishlist_screen.dart';
import '../../categories/view/categories_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/new_in_accessories_bloc.dart';
import '../bloc/new_in_accessories_event.dart';
import '../bloc/new_in_accessories_state.dart';
import '../model/new_in_model.dart';
import 'filtered_product_tab_screen.dart';

class NewInFilterAccessoriesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> selectedCategories;

  const NewInFilterAccessoriesScreen({super.key, required this.selectedCategories});

  @override
  @override
  Widget build(BuildContext context) {
    return FilteredProductTabScreen(
      selectedCategories: selectedCategories,
      initialTab: "New In",
      productListBuilder: (selectedCategory, selectedSort) {
        return BlocProvider(
          create: (_) => NewInAccessoriesBloc()..add(FetchNewInAccessories()),
          child: BlocBuilder<NewInAccessoriesBloc, NewInAccessoriesState>(
            builder: (context, state) {
              if (state is NewInAccessoriesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is NewInAccessoriesLoaded) {
                /// Sort products here based on selectedSort
                List<Product> products = List.from(state.products);

                if (selectedSort == 'High to Low') {
                  products.sort((a, b) => b.actualPrice.compareTo(a.actualPrice));
                } else if (selectedSort == 'Low to High') {
                  products.sort((a, b) => a.actualPrice.compareTo(b.actualPrice));
                }

                if (products.isEmpty) {
                  return const Center(child: Text("No products found"));
                }

                return GridView.builder(
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.55,
                  ),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(product: product);
                  },
                );
              } else if (state is NewInAccessoriesError) {
                return Center(child: Text(state.message));
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

}


// class NewInFilterAccessoriesScreen extends StatelessWidget {
//   final List<Map<String, dynamic>> selectedCategories;
//
//   const NewInFilterAccessoriesScreen({super.key, required this.selectedCategories});
//
//   @override
//   Widget build(BuildContext context) {
//     final selectedText = selectedCategories.isNotEmpty
//         ? selectedCategories[0]["category"]
//         : "No Category Selected";
//
//     return DefaultTabController(
//       length: 4,
//       initialIndex: 1,
//       child: BlocProvider(
//         create: (_) => NewInAccessoriesBloc()..add(FetchNewInAccessories()),
//         child: Scaffold(
//           appBar: AppBar(
//             title: Image.asset(
//               'assets/logo.jpeg',
//               height: 30,
//             ),
//             elevation: 0,
//             backgroundColor: Colors.white,
//             foregroundColor: Colors.black,
//             bottom: const TabBar(
//               labelColor: Colors.black,
//               indicatorColor: Colors.black,
//               unselectedLabelColor: Colors.grey,
//               labelPadding: EdgeInsets.symmetric(horizontal: 0),
//               tabs: [
//                 Tab(child: Text("Exclusives", style: TextStyle(fontSize: 14))),
//                 Tab(child: Text("New In", style: TextStyle(fontSize: 14))),
//                 Tab(child: Text("Categories", style: TextStyle(fontSize: 14))),
//                 Tab(child: Text("Designers", style: TextStyle(fontSize: 14))),
//               ],
//             ),
//             actions: [
//               IconButton(
//                 icon: const Icon(Icons.search),
//                 onPressed: () {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => const SearchScreen(),
//                   );
//                 },
//               ),
//               IconButton(
//                 icon: const Icon(Icons.shopping_bag_rounded),
//                 onPressed: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//                   );
//                 },
//               ),
//             ],
//           ),
//           body: TabBarView(
//             children: [
//               // 1. Exclusives
//               HomeScreen(),
//
//               // 2. New In Accessories with filter applied
//               Column(
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "Filtered by: $selectedText",
//                             style: const TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushReplacement(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (_) => const NewInFilterAccessoriesScreen(
//                                   selectedCategories: [],
//                                 ),
//                               ),
//                             );
//                           },
//                           child: const Text("Clear Filter"),
//                         )
//                       ],
//                     ),
//                   ),
//                   Expanded(
//                     child: BlocBuilder<NewInAccessoriesBloc, NewInAccessoriesState>(
//                       builder: (context, state) {
//                         if (state is NewInAccessoriesLoading) {
//                           return const Center(child: CircularProgressIndicator());
//                         } else if (state is NewInAccessoriesLoaded) {
//                           final products = state.products;
//                           if (products.isEmpty) {
//                             return const Center(child: Text('No products found.'));
//                           }
//                           return
//
//
//
//
//                             GridView.builder(
//                             itemCount: products.length,
//                               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 crossAxisSpacing: 10,
//                                 mainAxisSpacing: 10,
//                                 childAspectRatio: 0.55,
//                               ),
//
//                               itemBuilder: (context, index) {
//                               final product = products[index];
//                               // return Card(
//                               //   margin: const EdgeInsets.all(8),
//                               //   child: ListTile(
//                               //     leading: Image.network(
//                               //       product.prodSmallImg,
//                               //       width: 50,
//                               //       height: 50,
//                               //       fit: BoxFit.cover,
//                               //       errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported),
//                               //     ),
//                               //     title: Text(product.designerName),
//                               //     subtitle: Text(product.shortDesc),
//                               //     trailing: Text("£${product.actualPrice.toStringAsFixed(2)}"),
//                               //   ),
//                               // );
//
//                               return Card(
//                                 color: Colors.white,
//                                 elevation: 1,
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Flexible(
//                                       child: Image.network(
//                                         product.prodSmallImg,
//                                         width: double.infinity,
//                                         height: 550,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error, stackTrace) {
//                                           return Container(
//                                             height: 550,
//                                             color: Colors.grey[300],
//                                             alignment: Alignment.center,
//                                             child: const Icon(Icons.image_not_supported, size: 50),
//                                           );
//                                         },
//                                       ),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Center(
//                                         child: Text(
//                                           product.designerName,
//                                           style: AppTextStyle.designerName,
//                                           textAlign: TextAlign.center,
//                                           maxLines: 1,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                                       child: Center(
//                                         child: Text(
//                                           product.shortDesc,
//                                           textAlign: TextAlign.center,
//                                           style: AppTextStyle.shortDescription,
//
//
//                                           maxLines: 2,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 8.0),
//                                       child: Center(
//                                         child: Text(
//                                           "₹${product.actualPrice.toStringAsFixed(0)}",
//                                           style: AppTextStyle.actualPrice,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               );
//
//
//                               },
//                           );
//                         } else if (state is NewInAccessoriesError) {
//                           return Center(child: Text(state.message));
//                         } else {
//                           return const SizedBox.shrink();
//                         }
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//
//               // 3. Categories
//               CategoriesPage(),
//
//               // 4. Designers
//               DesignersScreen(),
//             ],
//           ),
//           bottomNavigationBar: BottomNavigationBar(
//             items: const [
//               BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
//               BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Wish List"),
//               BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Accounts"),
//             ],
//             onTap: (index) {
//               switch (index) {
//                 case 0:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const AuthScreen()),
//                         (Route<dynamic> route) => false,
//                   );
//                   break;
//                 case 1:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const WishlistScreen()),
//                         (Route<dynamic> route) => false,
//                   );
//                   break;
//                 case 2:
//                   Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => const AccountScreen()),
//                         (Route<dynamic> route) => false,
//                   );
//                   break;
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }





class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Keeps track of the selected tab
  int _currentBannerIndex = 0;
  int _currentBannerIndexSpe=0;// Keeps track of the current banner index
  final PageController _pageControllerBanner = PageController();
  final PageController _pageControllerBannerSpe = PageController();
  final PageController _pageControllerShop = PageController();
  late PageController _pageControllerACOEdit = PageController();
  int _currentShopByOccassionIndex =0;
  int _currentACOEditIndex =0;
  int _previousBannerIndex = 0;
  double _opacity = 1.0;
  bool _showPreviousImage = true;

  final ScrollController _scrollController = ScrollController();
  late Timer _timer;
  int _currentIndex = 0;

  Timer? _bannerTimer;
  Timer? _bannerTimerSpe;// Declare a Timer variable
  Timer? _shopOccasionTimer;  // Another Timer for Shop By Occasion

  final List<String> shopByOccassionImages= [

    'assets/Shop-by-occassion-1.jpg', // Replace with actual banner image paths
    'assets/Shop-by-occassion-2.jpg',
    'assets/Shop-by-occassion-3.jpg',
    'assets/Shop-by-occassion-4.jpg',
    'assets/Shop-by-occassion-5.jpg',
    'assets/Shop-by-occassion-6.jpg',
  ];

  final List<String> ACoEditImages= [




    'assets/ACO-EDITS-1.jpg',
    'assets/ACO-EDITS-2.jpg',
    'assets/ACO-EDITS-3.jpg',
    'assets/ACO-EDITS-4.jpg',
    'assets/ACO-EDITS-5.jpg',
    'assets/ACO-EDITS-6.jpg',
    'assets/ACO-EDITS-1.jpg',
    'assets/ACO-EDITS-7.jpg',
    'assets/ACO-EDITS-8.jpg',
  ];

  final acoEdits = [

  ];


  final mensWearEdit = [
    'assets/Menswear-Edit-1.jpg',
    'assets/Menswear-Edit-2.jpg',
    'assets/Menswear-Edit-3.jpg',
    'assets/Menswear-Edit-4.jpg',

  ];



  final List<String> bannerImages = [
    'assets/Banner-1.jpg', // Replace with actual banner image paths
    'assets/Banner-2.jpg',
    'assets/Banner-3.jpg',
    'assets/Banner-4.jpg',
    // 'assets/Banner-5.jpg',
    // 'assets/Banner-6.jpg',
    // 'assets/Banner-7.jpg'
  ];

  final List<String> bannerSpeImages = [
    'assets/Banner-new-1-.jpg',
    'assets/Banner-SS25-New.jpg',
  ];


  // Function to handle tab selection
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }


  void _startAutoSlideACOEdit() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageControllerACOEdit.hasClients) {
        setState(() {
          _currentACOEditIndex =
              (_currentACOEditIndex + 1) % ACoEditImages.length;
        });
        _pageControllerACOEdit.animateToPage(
          _currentACOEditIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  void _startAutoScroll() {
    _bannerTimer= Timer.periodic(Duration(seconds: 3), (timer) {
      if (_scrollController.hasClients) {
        double maxScroll = _scrollController.position.maxScrollExtent;
        double nextOffset = _scrollController.offset + 220; // Adjust step size based on image width + padding

        if (nextOffset >= maxScroll) {
          _scrollController.animateTo(
            0.0,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _currentIndex = 0;
        } else {
          _scrollController.animateTo(
            nextOffset,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          _currentIndex++;
        }
      }
    });
  }


  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _startAutoSlide();
    _startAutoSlideShopByOccassion();
    _startAutoSlideACOEdit();
    _startAutoSlideBannerSpe();


  }



  void _startAutoSlideShopByOccassion() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageControllerShop.hasClients) {
        setState(() {
          _currentShopByOccassionIndex =
              (_currentShopByOccassionIndex + 1) % shopByOccassionImages.length;
        });
        _pageControllerShop.animateToPage(
          _currentShopByOccassionIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }




  // void _startAutoSlide() {
  //   _bannerTimer = Timer.periodic(Duration(seconds: 12), (Timer timer) {
  //     if (_currentBannerIndex < bannerImages.length - 1) {
  //       _currentBannerIndex++;
  //     } else {
  //       _currentBannerIndex = 0; // Reset to first image
  //     }
  //     _pageControllerBanner.animateToPage(
  //       _currentBannerIndex,
  //       duration: Duration(milliseconds: 1200),
  //       curve: Curves.easeInOut,
  //     );
  //   });
  // }

  void _startAutoSlide() {
    _bannerTimer = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      setState(() {
        _opacity = 0.0; // Start fade-out
        _showPreviousImage = true; // Show previous image temporarily
      });

      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          _previousBannerIndex = _currentBannerIndex; // Update previous image
          _currentBannerIndex = (_currentBannerIndex + 1) % bannerImages.length; // Update image index
        });

        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            _opacity = 1.0; // Fade-in new image
            _showPreviousImage = false; // Hide previous image after transition
          });
        });
      });
    });
  }


  void _startAutoSlideBannerSpe() {
    _bannerTimerSpe = Timer.periodic(Duration(seconds: 4), (Timer timer) {
      setState(() {
        _opacity = 0.0; // Start fade-out
        _showPreviousImage = true; // Show previous image temporarily
      });

      Future.delayed(Duration(milliseconds: 600), () {
        setState(() {
          _previousBannerIndex = _currentBannerIndexSpe; // Update previous image
          _currentBannerIndexSpe = (_currentBannerIndexSpe + 1) % bannerSpeImages.length; // Update image index
        });

        Future.delayed(Duration(milliseconds: 200), () {
          setState(() {
            _opacity = 1.0; // Fade-in new image
            _showPreviousImage = false; // Hide previous image after transition
          });
        });
      });
    });
    // _bannerTimerSpe = Timer.periodic(Duration(seconds: 12), (Timer timer) {
    //   if (_currentBannerIndexSpe < bannerSpeImages.length - 1) {
    //     _currentBannerIndexSpe++;
    //   } else {
    //     _currentBannerIndexSpe = 0; // Reset to first image
    //   }
    //   _pageControllerBannerSpe.animateToPage(
    //     _currentBannerIndexSpe,
    //     duration: Duration(milliseconds: 1200),
    //     curve: Curves.easeInOut,
    //   );
    // });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _pageControllerBanner.dispose();
    _pageControllerShop.dispose();
    _timer.cancel();
    _scrollController.dispose();
    _timer.cancel();
    _pageControllerACOEdit.dispose();
    _pageControllerBannerSpe.dispose();
    super.dispose();
  }



  Widget _buildHomeTab() {
    final categories = [
      "New In",
      "Designers",
      "Women",
      "Bestsellers",
      "Jewellery",
      "Accessories",
      "Men",
      "Weddings",
      "Kids",
      "Sales",
      "Ready To Ship",
      "Journal"
    ];



    final accessoryEdit = [
      {'image': 'assets/Festive-Favourites.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/Modern-Jewels.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/Everyday-Classics.jpg', 'name': 'SAFAA'},
      {'image': 'assets/Hand-Jewlery.jpg', 'name': 'PEACHOO'},

    ];
    final List<Map<String, String>> designerData = [
      {'image': 'assets/New-In-1.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/New-In-2.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/New-In-3.jpg', 'name': 'SAFAA'},
      {'image': 'assets/New-In-4.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-5.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/New-In-6.jpg', 'name': 'DIYARAJVIR'},
      {'image': 'assets/New-In-7.jpg', 'name': 'SAFAA'},
      {'image': 'assets/New-In-8.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-9.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-10.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-11.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-12.jpg', 'name': 'PEACHOO'},
      {'image': 'assets/New-In-13.jpg', 'name': 'PEACHOO'},
    ];

    final readytoShip = [
      {'image': 'assets/RTS.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Sabya.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Occasion-wear-lehengas.jpeg', 'name': 'OCASSION Wear Lehengas'},
    ];

    final acoEdits = [
      {'image': 'assets/ACO-EDITS-1.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/ACO-EDITS-2.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/ACO-EDITS-3.jpg', 'name': 'OCASSION Wear Lehengas'},
      {'image': 'assets/ACO-EDITS-4.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/ACO-EDITS-5.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/ACO-EDITS-6.jpg', 'name': 'OCASSION Wear Lehengas'},    {'image': 'assets/ACO-EDITS-1.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/ACO-EDITS-7.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/ACO-EDITS-8.jpg', 'name': 'OCASSION Wear Lehengas'},
    ];

    final shopbyStyle1 = [
      {'image': 'assets/Shop-by-style-1.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Shop-by-style-2.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Shop-by-style-3.jpg', 'name': 'OCASSION Wear Lehengas'},
      {'image': 'assets/Shop-by-style-4.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Shop-by-style-5.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Shop-by-style-6.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Shop-by-style-7.jpg', 'name': 'OCASSION Wear Lehengas'},
      {'image': 'assets/Shop-by-style-8.jpg', 'name': 'Ready To Ship'},
    ];


    final shopbyStyle2 = [
      {'image': 'assets/Shop-by-style-5.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Shop-by-style-6.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Shop-by-style-7.jpg', 'name': 'OCASSION Wear Lehengas'},
      {'image': 'assets/Shop-by-style-8.jpg', 'name': 'Ready To Ship'},

    ];

    final acoBridalEdit = [
      {'image': 'assets/Bridesmaid-Glam-New.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/Gold-&-Ivory-Lehengas.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Trousseau-Essentials.jpg', 'name': 'OCASSION Wear Lehengas'},


    ];


    final bottomImages = [
      {'image': 'assets/Accessories-for-him.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/LAST-MINUTE-EID-PICKS.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/ACO-KIDS.jpg', 'name': 'OCASSION Wear Lehengas'},


    ];

    final bottomImage2 = [

      {'image': 'assets/A Tribute to Rohit Bal The Eternal Maestro of Indian Fashion.jpg', 'name': 'SABYASACHI'},
      {'image': 'assets/Elevating Traditional Fashion with the Latest Anarkali Trends.jpg', 'name': 'OCASSION Wear Lehengas'},
      {'image': 'assets/Benarasi Lehengas A Nod to Heritage.jpg', 'name': 'Ready To Ship'},
      {'image': 'assets/The Comeback of the Mermaid Lehenga.jpg', 'name': 'Ready To Ship'},
    ];


    return Column(
      children: [


        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child:Padding(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Image.asset(
                        bannerImages[_currentBannerIndex],
                        key: ValueKey<int>(_currentBannerIndex),
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 180,
                      ),
                    ),
                  ),

                ),


                SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(8.0), // Adjust padding as needed
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 1000),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: Builder(
                        builder: (context) {
                          print("Current banner index: $_currentBannerIndexSpe"); // Debug print
                          return Image.asset(
                            bannerSpeImages[_currentBannerIndexSpe],
                            key: ValueKey<int>(_currentBannerIndexSpe),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          );
                        },
                      ),
                    ),
                  ),
                ),



                SizedBox(height: 8),



                // Add spacing between sections
                SizedBox(height: 10,),
                Column(
                  mainAxisSize: MainAxisSize.min, // Prevent extra spacing
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.only(left: 8.0),
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'New In',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8), // Reduce this if needed
                                Text(
                                  'New arrivals, now',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'dropping five days a',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'week - discover the',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'latest launches onsite',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'from Monday to',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'friday',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 10), // Reduce this if needed
                                Text(
                                  'EXPLORE NOW',
                                  style: TextStyle(
                                    fontSize: 16,
                                    decoration: TextDecoration.underline,
                                    decorationThickness: 1.5,
                                    decorationColor: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded( // Ensure the parent has a fixed size
                          child: FractionallySizedBox(
                            widthFactor: 20/ (4.5+2), // Convert flex-like ratio to fraction
                            child: Container(
                              height: 320, // Ensure height is defined
                              child: ListView.builder(
                                controller: _scrollController,
                                scrollDirection: Axis.horizontal,
                                itemCount: designerData.length,
                                itemBuilder: (context, index) {
                                  final designer = designerData[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          child: Image.asset(
                                            designer['image']!,
                                            width: 200,
                                            height: 300,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),

                    // Removing any unnecessary space

                  ],
                ),








                Container(
                  padding: EdgeInsets.zero, // Ensure no extra padding
                  margin: EdgeInsets.zero, // Ensure no extra margin
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Prevent extra vertical space
                    children: [
                      ClipRRect(
                        child: Image.asset(
                          'assets/RTS.jpg',
                          width: 350,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ClipRRect(
                        child: Image.asset(
                          'assets/Sabya.jpg',
                          width: 350,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),
                      ClipRRect(
                        child: Image.asset(
                          'assets/Occasion-wear-lehengas.jpg',
                          width: 350,
                          height: 380,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),


                SizedBox(height: 10,),


                // A+Co Edits

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    color: const Color(0xFFC9C8C7),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
                          child: Center(
                            child: Text(
                              'A+CO EDITS',
                              style: TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8), // Space between text and slider
                        SizedBox(
                          height: 450, // Height for the slider
                          child: PageView.builder(
                            controller: _pageControllerACOEdit,
                            itemCount: ACoEditImages.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: ClipRRect(

                                  child: Image.asset(
                                    ACoEditImages[index],
                                    width: 160,
                                    height: 320,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 10,),

                //Shop by Style-1
                // SHOP BY STYLE - TITLE
                Container(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                  alignment: Alignment.centerLeft,
                  child: Center(
                    child: Text(
                      'SHOP BY STYLE',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

// GRID VIEW
                Container(
                  padding: const EdgeInsets.all(8.0), // Padding around the grid
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Prevents internal scrolling
                    shrinkWrap: true, // Allows the grid to adjust its height dynamically
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 columns
                      crossAxisSpacing: 8, // Space between columns
                      mainAxisSpacing: 8, // Space between rows
                      childAspectRatio: 0.75, // Makes images proportionate
                    ),
                    itemCount: shopbyStyle1.length,
                    itemBuilder: (context, index) {
                      final aco = shopbyStyle1[index];
                      return Column(
                        children: [
                          AspectRatio(
                            aspectRatio: 3 / 4, // Ensures images are always proportional
                            child: ClipRRect(
                              // borderRadius: BorderRadius.circular(8.0), // Optional rounded corners
                              child: Image.asset(
                                aco['image']!,
                                width: double.infinity, // Takes full width of grid cell
                                fit: BoxFit.cover, // Ensures proper scaling
                              ),
                            ),
                          ),
                          // const SizedBox(height: 8), // Space between image and text (if needed)
                        ],
                      );
                    },
                  ),
                )

                ,





                //SHOP BY OCCASSION


                Container(
                  color: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 35), // Slightly increased padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "SHOP BY OCCASIONS",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22, // Increased font size slightly
                          fontWeight: FontWeight.bold, // Enhanced visibility
                        ),
                      ),
                      const SizedBox(height: 14), // Slightly increased spacing

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.52, // Increased height
                        child: PageView.builder(
                          controller: _pageControllerShop,
                          onPageChanged: (index) => setState(() => _currentShopByOccassionIndex = index),
                          itemCount: shopByOccassionImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0), // Optimized padding
                              child: ClipRRect(
                                // More natural rounding
                                child: AspectRatio(
                                  aspectRatio: 3 / 4, // Maintains consistent image proportions
                                  child: Image.asset(
                                    shopByOccassionImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),


                //Designer of the Week

                SizedBox(height:10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8), // Padding on both sides
                  child: Column(
                    children: [
                      Container(
                        height: 580, // Set uniform height
                        width: double.infinity, // Full width
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Designer-of-the-week.jpg'),
                            fit: BoxFit.cover, // Ensures full coverage without distortion
                          ),
                        ),
                      ),
                      SizedBox(height: 8), // Space between images
                      Container(
                        height: 350, // Same height as above image
                        width: double.infinity, // Full width
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/Celeb-Spotting.jpg'),
                            fit: BoxFit.cover, // Ensures full coverage without distortion
                          ),
                        ),
                      ),
                    ],
                  ),
                ),







                //A+Co Bridal Edit
                SizedBox(height:15),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column( // No fixed height
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "A+CO BRIDAL EDITS",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      ClipRRect(
                        child: Image.asset(
                          'assets/Here-comes-the-bride.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 10),

                      // Remove fixed height
                      Column(
                        children: [
                          SizedBox(
                            height: acoBridalEdit.length * 590, // Adjust height dynamically
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
                              itemCount: acoBridalEdit.length,
                              itemBuilder: (context, index) {
                                final aco = acoBridalEdit[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0), // Adjust spacing
                                  child: ClipRRect(
                                    // borderRadius: BorderRadius.circular(8), // Optional rounded corners
                                    child: Image.asset(
                                      aco['image']!,
                                      width: double.infinity, // Full width
                                      height: 580, // Keep the original height
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      )
                      ,
                      SizedBox(height: 10,),
                      ClipRRect(
                        child: Image.asset(
                          'assets/Code-Red.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 10,),
                //Accessory Edit
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Column( // No fixed height
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "ACCESSORY EDIT",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/Bride-Bling.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 8), // Optional spacing between images
                          Expanded(
                            child: ClipRRect(
                              child: Image.asset(
                                'assets/Finishing-Touches.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 10,),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;
                          int crossAxisCount = screenWidth > 600 ? 3 : 2; // 2 columns on small screens, 3 on larger screens
                          double childAspectRatio = screenWidth > 600 ? 0.7 : 0.6; // Adjust aspect ratio based on screen size

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Prevent internal scrolling
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount, // Responsive columns
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: childAspectRatio, // Adjust image height
                            ),
                            itemCount: accessoryEdit.length,
                            itemBuilder: (context, index) {
                              final aco = accessoryEdit[index];
                              return ClipRRect(

                                child: Image.asset(
                                  aco['image']!,
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        },
                      )

                      ,




                    ],
                  ),
                ),

                SizedBox(height: 10,),
                //Mens Wear Edit

                Container(
                  color: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "MENS WEAR EDIT",
                        style: TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      SizedBox(height: 20),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          double screenWidth = constraints.maxWidth;

                          // Adjust column count based on screen width
                          int crossAxisCount = 2; // Default for phones
                          if (screenWidth > 600) crossAxisCount = 3; // Tablets
                          if (screenWidth > 900) crossAxisCount = 4; // Large screens

                          // Adjust image height proportionally
                          double childAspectRatio = screenWidth > 600 ? 0.8 : 0.7;

                          return GridView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(), // Prevents internal scrolling
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount, // Responsive columns
                              crossAxisSpacing: 10.0,
                              mainAxisSpacing: 10.0,
                              childAspectRatio: childAspectRatio, // Adjust image height
                            ),
                            itemCount: mensWearEdit.length,
                            itemBuilder: (context, index) {
                              return ClipRRect(
                                // Optional rounded corners
                                child: Image.asset(
                                  mensWearEdit[index],
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                )

                ,

                // 3 images

                SizedBox(height: 10,),

                Column(
                  children: bottomImages.map((aco) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
                      child: SizedBox(
                        width: 390,
                        height: 480,
                        child: ClipRRect(
                          child: Image.asset(
                            aco['image']!,
                            fit: BoxFit.cover, // Ensures consistent display
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10,),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    child: Image.asset(
                      'assets/Bridal Trends in 2025.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10,),
                Column(
                  children: bottomImage2.map((aco) {
                    return Padding(
                      padding: const EdgeInsets.symmetric( horizontal: 8),
                      child: SizedBox(
                        width: 390,
                        height: 400,
                        child: ClipRRect(
                          child: Image.asset(
                            aco['image']!,
                            fit: BoxFit.fitWidth, // Ensures consistent display
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
















              ],
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildSearchTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 50, color: Colors.green),
          SizedBox(height: 10),
          Text(
            "Search for items here!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override

  Widget build(BuildContext context) {
    final List<Widget> _tabs = [
      _buildHomeTab(),
      _buildSearchTab(),
// Use the separate ProfileWidget class
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   title: Image.asset(
      //     'assets/logo.jpeg', // Replace with the path to your image
      //     height: 40, // Adjust height as needed
      //   ),
      //   centerTitle: true, // Centers the image in the AppBar
      //   backgroundColor: Colors.white, // Customize background color
      // ),
      body: _tabs[_selectedIndex], // Show content of the selected tab

    );
  }



}