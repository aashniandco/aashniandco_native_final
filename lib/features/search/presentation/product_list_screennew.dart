import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/features/search/data/repositories/search_repository.dart';
import 'package:aashniandco/features/search/presentation/search_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/io_client.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common/common_app_bar.dart';
import '../../../common/common_bottom_nav_bar.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import '../../categories/bloc/filtered_products_bloc.dart';
import '../../categories/bloc/filtered_products_state.dart';
import '../../categories/repository/api_service.dart';
import '../../newin/model/new_in_model.dart';
import '../../newin/view/plpfilterscreens/filter_bottom_sheet_categories.dart';
import '../../newin/view/product_details_newin.dart';
import '../../shoppingbag/model/countries.dart';
import '../data/models/product_model.dart';
import 'package:flutter/rendering.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart'as http;
import 'package:intl/intl.dart';
// Import your other necessary files
// import 'package:your_app/services/api_service.dart';
// import 'package:your_app/models/product_model.dart';

class ProductListingScreen extends StatelessWidget {
  final String categoryId;
  final String categoryName;

  const ProductListingScreen({
    Key? key,
    required this.categoryId,
    required this.categoryName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // We provide the FilteredProductsBloc here. Its lifecycle is tied to this screen.
    return BlocProvider(
      create: (context) => FilteredProductsBloc()
      // ✅ This is the crucial part. As soon as the screen is built,
      // we dispatch the event to fetch products for the given categoryId.
        ..add(FetchFilteredProducts(
          selectedFilters: [
            {'type': 'categories', 'id': categoryId}
          ],
          sortOrder: 'Latest', // Your desired default sort
          page: 0,
        )),
      child: CategoryProductView(
        categoryName: categoryName,
        // We can pass the categoryId down if needed for other features like filtering
        categoryId: categoryId,
      ),
    );
  }
}

// This is the view part, adapted from your MenuCategoriesView
class CategoryProductView extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryProductView({
    Key? key,
    required this.categoryName,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<CategoryProductView> createState() => _CategoryProductViewState();
}

class _CategoryProductViewState extends State<CategoryProductView> {
  final _scrollController = ScrollController();
  String _selectedSort = "Latest";

  bool _isNavBarVisible = true;
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _categoryMetadata;
  List<Country> _apiCountries = [];
  bool _isLoadingCountries = true; // New state variable for country loading

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _categoryMetadata = _apiService.fetchCategoryMetadataByName(widget.categoryName);
    _fetchCountries(); // Start fetching countries
  }

  Future<void> _fetchCountries() async {
    print("Countries Method Clicked>>");
    setState(() {
      _isLoadingCountries = true; // Set loading to true when fetching starts
    });
    try {
      final url = Uri.parse('https://stage.aashniandco.com/rest/V1/directory/countries');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _apiCountries = data.map((e) => Country.fromJson(e)).toList();
          print("_apiCountries>>$_apiCountries");
        });
      } else {
        print('Failed to fetch countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching countries: $e');
    } finally {
      setState(() {
        _isLoadingCountries = false; // Set loading to false when fetching is done (success or error)
      });
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<FilteredProductsBloc>().state;
      if (currentState is FilteredProductsLoaded && !currentState.hasReachedEnd) {
        context.read<FilteredProductsBloc>().add(FetchFilteredProducts(
          selectedFilters: [{'type': 'categories', 'id': widget.categoryId}],
          sortOrder: _selectedSort,
          page: currentState.products.length ~/ 10,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double navBarHeight =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CommonAppBar(
        automaticallyImplyLeading: true,
        titleWidget: Text(widget.categoryName),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFilterButton(),
                _buildSortDropdown(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildProductGrid()),
        ],
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        height: _isNavBarVisible ? navBarHeight : 0,
        child: Wrap(
          children: const [
            CommonBottomNavBar(currentIndex: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildSortDropdown() {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6),
      ),
      child: DropdownButton<String>(
        value: _selectedSort,
        icon: const Icon(Icons.sort, color: Colors.black),
        underline: Container(),
        onChanged: (value) {
          if (value != null && value != _selectedSort) {
            setState(() => _selectedSort = value);
            context.read<FilteredProductsBloc>().add(
              FetchFilteredProducts(
                selectedFilters: [
                  {'type': 'categories', 'id': widget.categoryId}
                ],
                sortOrder: _selectedSort,
                page: 0,
              ),
            );
          }
        },
        items: ["Latest", "High to Low", "Low to High"].map((sortOption) {
          return DropdownMenuItem<String>(
            value: sortOption,
            child: Text(sortOption,
                style: const TextStyle(color: Colors.black, fontSize: 14)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilterButton() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _categoryMetadata,
      builder: (context, snapshot) {
        final bool canFilter =
            snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError;

        return TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          onPressed: canFilter
              ? () {
            final categoryData = snapshot.data!;
            final String parentCategoryId =
                categoryData['pare_cat_id']?.toString() ?? '';
            if (parentCategoryId.isNotEmpty) {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider.value(
                  value: BlocProvider.of<FilteredProductsBloc>(context),
                  child: FilterBottomSheetCategories(
                    categoryId: parentCategoryId,
                    isFromFilteredScreen: false,
                  ),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content:
                    Text("Filter not available for this category.")),
              );
            }
          }
              : null,
          icon: const Icon(Icons.filter_list),
          label: Text(
            'Filter',
            style: TextStyle(
              fontSize: 16,
              color: canFilter ? Colors.black : Colors.grey,
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductGrid() {
    return BlocBuilder<FilteredProductsBloc, FilteredProductsState>(
      builder: (context, state) {
        if (state is FilteredProductsLoading) {
          return const ProductGridShimmer();
        }
        if (state is FilteredProductsError) {
          return Center(child: Text('Failed to fetch products: ${state.message}'));
        }
        if (state is FilteredProductsLoaded) {
          if (state.products.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          // Check if countries are still loading
          if (_isLoadingCountries) {
            return const Center(child: CircularProgressIndicator());
          }

          // If countries are loaded, build the GridView
          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: state.hasReachedEnd
                ? state.products.length
                : state.products.length + 1,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.5,
            ),
            itemBuilder: (context, index) {
              if (index >= state.products.length) {
                return const Center(child: CircularProgressIndicator());
              }
              return ProductGridTile(
                product: state.products[index],
                apiCountries: _apiCountries, // Pass the fetched countries here
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        itemCount: 10, // Display 10 shimmer placeholders
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.5,
        ),
        itemBuilder: (context, index) {
          return Card(
            color: Colors.white,
            elevation: 1,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 16,
                    width: 100,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 14,
                    width: 150,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    height: 16,
                    width: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Keep _inputDecoration outside the class, but ensure it uses the provided context
InputDecoration _inputDecoration(BuildContext context, String labelText) {
  return InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(color: Colors.grey[700]),
    filled: true,
    fillColor: Colors.grey[100],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

// Update _buildTextField to accept and pass the context
Widget _buildTextField({
  required BuildContext context, // Add context here
  required TextEditingController controller,
  required String label,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    decoration: _inputDecoration(context, label), // Pass context here
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Please enter $label';
      }
      if (keyboardType == TextInputType.emailAddress && !value.contains('@')) {
        return 'Please enter a valid email';
      }
      return null;
    },
  );
}

class ProductGridTile extends StatelessWidget {
  const ProductGridTile({
    Key? key,
    required this.product,
    required this.apiCountries, // Add this to constructor
  }) : super(key: key);

  final Product product;
  final List<Country> apiCountries; // Store the list of countries

  void _showEnquiryDialog(BuildContext context, Product product, List<Country> countries) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final countryController = TextEditingController();
    final phoneController = TextEditingController();
    final queryController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool isLoading = false;
    String? selectedCountry = countryController.text.isEmpty ? null : countryController.text;

    final sortedCountries = List<Country>.from(countries) // Use the passed countries list
      ..sort((a, b) => (a.fullNameEnglish ?? '').compareTo(b.fullNameEnglish ?? ''));


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (dialogContext, setState) { // Use dialogContext to avoid conflicts
            Future<void> submitForm() async {
              if (!_formKey.currentState!.validate()) return;

              setState(() => isLoading = true);

              final url = Uri.parse(
                  'https://aashniandco.com/rest/V1/solr/submitEnquiry');
              final body = jsonEncode({
                "name": nameController.text,
                "email": emailController.text,
                "country": countryController.text,
                "phone": phoneController.text,
                "query": queryController.text,
                "product_name": product.designerName, // Use product.designerName directly
              });

              try {
                final response = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: body,
                );

                if (response.statusCode == 200) {
                  final result = jsonDecode(response.body);
                  if (result is List && result[0] == true) {
                    Navigator.pop(dialogContext); // Use dialogContext to pop
                    ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                      const SnackBar(
                        content: Text('Enquiry submitted successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception(result);
                  }
                } else {
                  throw Exception('Server Error: ${response.statusCode}');
                }
              } catch (e) {
                ScaffoldMessenger.of(dialogContext).showSnackBar( // Use dialogContext
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              } finally {
                setState(() => isLoading = false);
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: Colors.white,
              titlePadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Enquire Now",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.designerName, // Use product.designerName directly
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildTextField(
                        context: dialogContext, // Pass dialogContext here
                        controller: nameController,
                        label: "Full Name",
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        context: dialogContext, // Pass dialogContext here
                        controller: emailController,
                        label: "Email",
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        decoration: _inputDecoration(dialogContext, 'Country'), // Pass dialogContext
                        value: selectedCountry,
                        hint: const Text("Select Country"),
                        isExpanded: true,
                        items: sortedCountries
                            .where((country) => country.fullNameEnglish != null)
                            .map((Country country) {
                          return DropdownMenuItem<String>(
                            value: country.fullNameEnglish,
                            child: Text(country.fullNameEnglish ?? ''),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCountry = value;
                            countryController.text = value ?? '';
                          });
                        },
                        validator: (value) =>
                        (value == null || value.isEmpty) ? 'Please select your country' : null,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        context: dialogContext, // Pass dialogContext here
                        controller: phoneController,
                        label: "Phone Number",
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      _buildTextField(
                        context: dialogContext, // Pass dialogContext here
                        controller: queryController,
                        label: "Your Query",
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext), // Use dialogContext
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyState = context.watch<CurrencyBloc>().state;

    String displaySymbol = '₹';
    double displayPrice = product.actualPrice;

    if (currencyState is CurrencyLoaded) {
      displaySymbol = currencyState.selectedSymbol;
      final rate = currencyState.selectedRate.rate;
      displayPrice = product.actualPrice * (rate > 0 ? rate : 1.0);
    }

    final NumberFormat priceFormatter = NumberFormat.currency(
      symbol: displaySymbol,
      decimalDigits: 0,
      locale: displaySymbol == '₹'
          ? 'en_IN'
          : displaySymbol == '£'
          ? 'en_GB'
          : 'en_US',
    );

    final bool showEnquireButton =
        product.enquire1 != null && product.enquire1!.contains(1);

    return GestureDetector(
      onTap: () {
        final productData = {
          'prod_sku': product.prod_sku,
          'designer_name': product.designerName,
          'short_desc': product.shortDesc,
          'prod_small_img': product.prodSmallImg,
          'actual_price_1': product.actualPrice,
          'prod_desc': product.prodDesc.isNotEmpty ? product.prodDesc.first : null,
          'child_delivery_time': product.deliveryTime.isNotEmpty ? product.deliveryTime.first : null,
          'size_name': product.sizeList,
          'patterns_name': product.patterns_name,
          'gender_name': product.gender_name,
          'kid_name': product.kid_name,
          'enquire_1': product.enquire1,
          'prod_en_id': product.prod_en_id,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailNewInDetailScreen(product: productData),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: CachedNetworkImage(
                imageUrl: product.prodSmallImg,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.0,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade300),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  product.designerName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  product.shortDesc,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: showEnquireButton
                    ? ElevatedButton(
                  onPressed: () {
                    _showEnquiryDialog(context, product, apiCountries);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Text('Enquire Now'),
                )
                    :

                Text(
                    priceFormatter.format(displayPrice),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
                // Text(
                //   '$displaySymbol${displayPrice.toStringAsFixed(0)}',
                //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                //   textAlign: TextAlign.center,
                // ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//11/8/2025
// its the whole screen same as productlist screen
// class ProductGridTile extends StatelessWidget {
//   const ProductGridTile({
//     Key? key,
//     required this.product,
//   }) : super(key: key);
//
//   final Product product;
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         final productData = {
//           'prod_sku': product.prod_sku,
//           'designer_name': product.designerName,
//           'short_desc': product.shortDesc,
//           'prod_small_img': product.prodSmallImg,
//           'actual_price_1': product.actualPrice,
//           'prod_desc': product.prodDesc,
//           'child_delivery_time': product.deliveryTime,
//           'size_name': product.sizeList,
//         };
//
//         // ✅ PRINT THE ENTIRE MAP
//         print("Navigating with product data: $productData");
//
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => ProductDetailNewInDetailScreen(
//               product: productData,
//             ),
//           ),
//         );
//       },
//       // onTap: () {
//       //   // ✅ NEW: Navigation logic
//       //   print('Tapped on product: ${product.designerName}');
//       //
//       //   // IMPORTANT: The `autosuggest` API often returns incomplete product data.
//       //   // You will likely need to make another API call on the detail screen
//       //   // using the product's SKU or URL to get the full details (like all sizes).
//       //   // For now, we pass the data we have.
//       //
//       //   Navigator.push(
//       //     context,
//       //     MaterialPageRoute(
//       //       // Navigate to your existing Product Detail Screen
//       //       builder: (_) => ProductDetailNewInDetailScreen(
//       //         // You need to convert your simplified `Product` model
//       //         // back into the Map<String, dynamic> format that the
//       //         // detail screen expects.
//       //         product: {
//       //           'prod_sku': product.prod_sku,
//       //           'designer_name': product.designerName,
//       //           'short_desc': product.shortDesc,
//       //           'prod_small_img': product.prodSmallImg,
//       //           'actual_price_1': product.actualPrice,
//       //           // Add any other fields the detail screen requires, even if they are empty
//       //           'prod_desc': product.prodDesc,
//       //           'child_delivery_time': product.deliveryTime,
//       //           'size_name': product.sizeList, // Start with an empty list of sizes
//       //         },
//       //       ),
//       //     ),
//       //   );
//       // },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             child: Card(
//               margin: EdgeInsets.zero,
//               clipBehavior: Clip.antiAlias,
//               elevation: 0,
//               child: CachedNetworkImage(
//                 imageUrl: product.prodSmallImg,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 placeholder: (context, url) => Container(color: Colors.grey[200]),
//                 errorWidget: (context, url, error) => Container(
//                   color: Colors.grey[200],
//                   child: const Icon(Icons.error_outline, color: Colors.grey),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(4, 8, 4, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   product.designerName,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14,
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   product.shortDesc,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[700],
//                   ),
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   // Price is already a formatted String
//                   '₹${product.actualPrice.toStringAsFixed(0)}',
//                   style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// class ProductListingScreen extends StatefulWidget {
//   final String? searchQuery;
//   final String? categoryUrl;
//
//   const ProductListingScreen({
//     Key? key,
//     this.searchQuery,
//     this.categoryUrl,
//   }) : super(key: key);
//
//   @override
//   // This line connects the StatefulWidget to its State class
//   _ProductListingScreenState createState() => _ProductListingScreenState();
// }
//
// class _ProductListingScreenState extends State<ProductListingScreen> {
//   late Future<SearchResults> _productFuture;
//   // ✅ Use your actual repository
//   final SearchRepository _searchRepository = SearchRepository();
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _loadProducts();
//     });
//   }
//
// // inside class _ProductListingScreenState
//
// // inside class _ProductListingScreenState
//
//   Future<String> _getCategoryIdFromUrl(String url) async {
//     try {
//       final uri = Uri.parse(url);
//       final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//       if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//
//       print('Fetching category ID for url_key: $urlKey');
//       final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//
//       HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//       IOClient ioClient = IOClient(httpClient);
//       final response = await ioClient.get(endpoint);
//
//       if (response.statusCode == 200) {
//         // ✅ --- START OF THE DOUBLE-DECODE FIX ---
//
//         // 1. First decode: This turns the outer JSON `[...]` into a Dart List.
//         final dynamic decodedResponse = json.decode(response.body);
//
//         // 2. Safety Check: Ensure we have a non-empty list and its first item is a String.
//         if (decodedResponse is List && decodedResponse.isNotEmpty && decodedResponse[0] is String) {
//
//           // 3. Extract the string that contains the inner JSON.
//           final String innerJsonString = decodedResponse[0];
//
//           // 4. Second decode: This parses the inner JSON string into the Map we need.
//           final Map<String, dynamic> categoryData = json.decode(innerJsonString);
//
//           final dynamic categoryId = categoryData['cat_id'];
//
//           if (categoryId != null) {
//             print('Successfully fetched category ID: $categoryId');
//             return categoryId.toString();
//           } else {
//             throw Exception('Inner JSON object did not contain a "cat_id".');
//           }
//         } else {
//           throw Exception('API did not return the expected data structure (a list containing a JSON string).');
//         }
//         // ✅ --- END OF THE DOUBLE-DECODE FIX ---
//
//       } else if (response.statusCode == 404) {
//         final errorData = json.decode(response.body);
//         throw Exception('Category not found: ${errorData['message']}');
//       }
//       else {
//         throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//       }
//     } catch (e) {
//       print("Error in _getCategoryIdFromUrl: $e");
//       rethrow;
//     }
//   }
//   // Future<String> _getCategoryIdFromUrl(String url) async {
//   //   try {
//   //     final uri = Uri.parse(url);
//   //     final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//   //     if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//   //
//   //     print('Fetching category ID for url_key: $urlKey');
//   //     final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//   //
//   //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //     final response = await ioClient.get(endpoint);
//   //
//   //     if (response.statusCode == 200) {
//   //       // Decode the response body
//   //       final decodedResponse = json.decode(response.body);
//   //
//   //       // ✅ --- START OF FIX ---
//   //       // Check if the decoded response is a List and is not empty
//   //       if (decodedResponse is List && decodedResponse.isNotEmpty) {
//   //
//   //         // Access the first element of the list, which should be the map we want
//   //         final Map<String, dynamic> categoryData = decodedResponse[0];
//   //         final categoryId = categoryData['cat_id'];
//   //
//   //         if (categoryId != null) {
//   //           print('Successfully fetched category ID: $categoryId');
//   //           return categoryId.toString();
//   //         } else {
//   //           throw Exception('API response list did not contain an object with "cat_id".');
//   //         }
//   //       } else {
//   //         // Handle the case where the list is empty or not a list
//   //         throw Exception('API did not return a valid category data list.');
//   //       }
//   //       // ✅ --- END OF FIX ---
//   //
//   //     } else {
//   //       throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print("Error in _getCategoryIdFromUrl: $e");
//   //     rethrow;
//   //   }
//   // }
//   // Future<String> _getCategoryIdFromUrl(String url) async {
//   //   try {
//   //     final uri = Uri.parse(url);
//   //     final urlKey = uri.pathSegments.last.replaceAll('.html', '');
//   //     if (urlKey.isEmpty) throw Exception("Could not extract URL key.");
//   //
//   //     print('Fetching category ID for url_key: $urlKey');
//   //     final endpoint = Uri.parse('https://stage.aashniandco.com/rest/V1/solr/category-by-url-key/$urlKey');
//   //
//   //     HttpClient httpClient = HttpClient()..badCertificateCallback = (cert, host, port) => true;
//   //     IOClient ioClient = IOClient(httpClient);
//   //     final response = await ioClient.get(endpoint);
//   //
//   //     if (response.statusCode == 200) {
//   //       final categoryData = json.decode(response.body);
//   //       final categoryId = categoryData['cat_id'];
//   //       if (categoryId != null) {
//   //         print('Successfully fetched category ID: $categoryId');
//   //         return categoryId.toString();
//   //       } else {
//   //         throw Exception('API response did not contain a "cat_id".');
//   //       }
//   //     } else {
//   //       throw Exception('Failed to fetch category ID. Status: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print("Error in _getCategoryIdFromUrl: $e");
//   //     rethrow;
//   //   }
//   // }
//
//   void _loadProducts() {
//     setState(() {
//       if (widget.categoryUrl != null && widget.categoryUrl!.isNotEmpty) {
//         // Case 1: Navigated from a category click
//         // Get the ID first, then call the repository method with the categoryId
//         _productFuture = _getCategoryIdFromUrl(widget.categoryUrl!)
//             .then((categoryId) => _searchRepository.fetchProductsByCategory(categoryId: categoryId));
//       } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
//         // Case 2: Navigated from "View all results"
//         // Call the repository method directly with the searchQuery
//         _productFuture = _searchRepository.fetchProductsByCategory(searchQuery: widget.searchQuery!);
//       } else {
//         // Fallback case
//         _productFuture = Future.error("No search query or category was provided.");
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final String appBarTitle = widget.searchQuery != null && widget.searchQuery!.isNotEmpty
//         ? 'Results for "${widget.searchQuery}"'
//         : 'Products';
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(appBarTitle),
//       ),
//       body: FutureBuilder<SearchResults>(
//         future: _productFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snapshot.hasError) {
//             return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text('Error: ${snapshot.error}')));
//           }
//           if (!snapshot.hasData || snapshot.data!.products.isEmpty) {
//             return const Center(child: Text('No products found.'));
//           }
//           final products = snapshot.data!.products;
//           return GridView.builder(
//             padding: const EdgeInsets.all(8.0),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               childAspectRatio: 0.65,
//               crossAxisSpacing: 8.0,
//               mainAxisSpacing: 8.0,
//             ),
//             itemCount: products.length,
//             itemBuilder: (context, index) {
//               return ProductGridTile(product: products[index]);
//             },
//           );
//         },
//       ),
//     );
//   }
// }