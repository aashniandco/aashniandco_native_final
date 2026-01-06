  import 'package:aashniandco/features/profile/repository/order_history_repository.dart';
import 'package:collection/collection.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  import '../../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../../shoppingbag/model/countries.dart';
import '../bloc/address_bloc.dart';
  import '../bloc/address_event.dart';
  import '../bloc/address_state.dart';
  import '../model/customer_address_model.dart';

  import 'package:flutter/material.dart';

  import 'package:aashniandco/features/profile/repository/order_history_repository.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_bloc/flutter_bloc.dart';

  import '../bloc/address_bloc.dart';
  import '../bloc/address_event.dart';
  import '../bloc/address_state.dart';
  import '../model/customer_address_model.dart';
import 'edit_screen.dart';

  class AddressScreen extends StatelessWidget {
    const AddressScreen({super.key});

    @override
    Widget build(BuildContext context) {
      return BlocProvider(
        create: (_) => AddressBloc(OrderHistoryRepository())..add(LoadAddresses()),
        child: Scaffold(
          appBar: AppBar(title: const Text("My Addresses")),
          body: BlocBuilder<AddressBloc, AddressState>(
            builder: (context, state) {
              if (state is AddressLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AddressLoaded) {

                // --- INTEGRATED FILTERING LOGIC START ---

                // 1. Find the actual objects (can be null)
                final billingAddr = state.addresses.firstWhereOrNull((a) => a.isDefaultBilling);
                final shippingAddr = state.addresses.firstWhereOrNull((a) => a.isDefaultShipping);

                // 2. Filter Additional: Show only if the ID is NOT the billing ID and NOT the shipping ID
                final additional = state.addresses.where((a) {
                  return a.id != billingAddr?.id && a.id != shippingAddr?.id;
                }).toList();

                // 3. Create placeholders for the UI if defaults aren't found (to maintain your id == 0 logic)
                final emptyAddr = CustomerAddress(
                    id: 0, firstname: "", lastname: "", street: "", city: "",
                    postcode: "", country: "", telephone: "",
                    isDefaultBilling: false, isDefaultShipping: false
                );

                final billing = billingAddr ?? emptyAddr;
                final shipping = shippingAddr ?? emptyAddr;

                // --- INTEGRATED FILTERING LOGIC END ---

                // CASE: No addresses at all
                if (state.addresses.isEmpty) {
                  return _noAddressesView(context);
                }

                // CASE: A billing address exists, but no default shipping address is set.
                if (billing.id != 0 && shipping.id == 0) {
                  return _noShippingView(context, billing);
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text("Default Billing Address",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _addressCard(context, billing),
                    const SizedBox(height: 20),

                    const Text("Default Shipping Address",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    _addressCard(context, shipping),
                    const SizedBox(height: 20),

                    const Text("Additional Address Entries",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    additional.isEmpty
                        ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("You have no other address entries."),
                    )
                        : Column(
                      children: additional.map((a) => _addressCard(context, a)).toList(),
                    ),

                    const SizedBox(height: 24),

                    // ADD NEW ADDRESS BUTTON
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider.value(
                              value: context.read<AddressBloc>(),
                              child: const EditAddressScreen(), // No address passed = Add Mode
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("ADD NEW ADDRESS"),
                    ),
                    const SizedBox(height: 40),
                  ],
                );
              } else if (state is AddressError) {
                return Center(child: Text("Error: ${state.message}"));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    }

    Widget _addressCard(BuildContext context, CustomerAddress address) {
      if (address.id == 0) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("No address found."),
          ),
        );
      }

      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${address.firstname} ${address.lastname}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(address.street),
              Text("${address.city}, ${address.postcode}"),
              Text(address.country),
              const SizedBox(height: 4),
              Text("T: ${address.telephone}"),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ✅ HIDE DELETE BUTTON FOR DEFAULT BILLING
                  if (!address.isDefaultBilling)
                    TextButton.icon(
                      onPressed: () => _confirmDelete(context, address.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.black),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),

                  const SizedBox(width: 8),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<AddressBloc>(),
                            child: EditAddressScreen(address: address),
                          ),
                        ),
                      );
                    },
                    child: const Text("Edit"),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    // Widget _addressCard(BuildContext context, CustomerAddress address) {
    //   if (address.id == 0) {
    //     return const Card(
    //       child: Padding(
    //         padding: EdgeInsets.all(12.0),
    //         child: Text("No address found."),
    //       ),
    //     );
    //   }
    //   return Card(
    //     margin: const EdgeInsets.symmetric(vertical: 8),
    //     child: Padding(
    //       padding: const EdgeInsets.all(12),
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           Text("${address.firstname} ${address.lastname}",
    //               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    //           const SizedBox(height: 4),
    //           Text(address.street),
    //           Text("${address.city}, ${address.postcode}"),
    //           Text(address.country),
    //           const SizedBox(height: 4),
    //           Text("T: ${address.telephone}"),
    //           const SizedBox(height: 8),
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.end,
    //             children: [
    //               TextButton.icon(
    //                 onPressed: () => _confirmDelete(context, address.id),
    //                 icon: const Icon(Icons.delete_outline, color: Colors.red),
    //                 label: const Text("Delete", style: TextStyle(color: Colors.red)),
    //               ),
    //               const SizedBox(width: 8),
    //               ElevatedButton(
    //                 onPressed: () {
    //                   Navigator.push(
    //                     context,
    //                     MaterialPageRoute(
    //                       builder: (_) => BlocProvider.value(
    //                         value: context.read<AddressBloc>(),
    //                         child: EditAddressScreen(address: address),
    //                       ),
    //                     ),
    //                   );
    //                 },
    //                 child: const Text("Edit"),
    //               ),
    //             ],
    //           )
    //         ],
    //       ),
    //     ),
    //   );
    // }

    void _confirmDelete(BuildContext context, int addressId) {
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text("Delete Address"),
          content: const Text("Are you sure you want to delete this address?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                context.read<AddressBloc>().add(DeleteAddress(addressId));
                Navigator.pop(dialogContext);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    Widget _noAddressesView(BuildContext context) {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<AddressBloc>(),
                  child: const EditAddressScreen(),
                ),
              ),
            );
          },
          child: const Text("Add Your First Address"),
        ),
      );
    }

    Widget _noShippingView(BuildContext context, CustomerAddress billing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                "No Default Shipping Address Found",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // This button now correctly navigates to the form
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: context.read<AddressBloc>(),
                        child: const EditAddressScreen(), // Add New Address mode
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Shipping Address"),
              ),

              const SizedBox(height: 12),

              // Shortcut button: Makes current billing address also the shipping default
              TextButton(
                onPressed: () {
                  context.read<AddressBloc>().add(AddAddress(
                    billing.copyWith(isDefaultShipping: true),
                    region: billing.region,
                    regionId: billing.regionId,
                  ));
                },
                child: const Text("Use Billing Address as Default Shipping"),
              ),
            ],
          ),
        ),
      );
    }
  // Widget _noShippingView(CustomerAddress billing) {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Icon(Icons.location_off, size: 64, color: Colors.grey),
  //         const SizedBox(height: 16),
  //         const Text("No Default Shipping Address Found", style: TextStyle(fontWeight: FontWeight.bold)),
  //         const SizedBox(height: 24),
  //         ElevatedButton(onPressed: () {}, child: const Text("Add Shipping Address"))
  //       ],
  //     ),
  //   );
  // }
  }

  //6/1/2026
  // class AddressScreen extends StatelessWidget {
  //   const AddressScreen({super.key});
  //
  //   @override
  //   Widget build(BuildContext context) {
  //     return BlocProvider(
  //       create: (_) => AddressBloc(OrderHistoryRepository())..add(LoadAddresses()),
  //       child: Scaffold(
  //         appBar: AppBar(title: const Text("My Addresses")),
  //         body: BlocBuilder<AddressBloc, AddressState>(
  //           // Inside AddressScreen -> BlocBuilder
  //           builder: (context, state) {
  //             if (state is AddressLoading) {
  //               return const Center(child: CircularProgressIndicator());
  //             } else if (state is AddressLoaded) {
  //               // 1. If no addresses exist at all, show the Add form
  //               if (state.addresses.isEmpty) {
  //                 return const _AddAddressForm();
  //               }
  //
  //               // 2. Separate addresses for categorization
  //               final billing = state.addresses.where((a) => a.isDefaultBilling).toList();
  //               final shipping = state.addresses.where((a) => a.isDefaultShipping).toList();
  //
  //               // Additional: Addresses that are neither default billing nor default shipping
  //               final additional = state.addresses
  //                   .where((a) => !a.isDefaultBilling && !a.isDefaultShipping)
  //                   .toList();
  //
  //               return ListView(
  //                 padding: const EdgeInsets.all(16),
  //                 children: [
  //                   // Only show Billing section if it exists
  //                   if (billing.isNotEmpty) ...[
  //                     const Text("Default Billing Address",
  //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                     ...billing.map((a) => _addressCard(context, a)),
  //                     const SizedBox(height: 20),
  //                   ],
  //
  //                   // Only show Shipping section if it exists
  //                   if (shipping.isNotEmpty) ...[
  //                     const Text("Default Shipping Address",
  //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                     ...shipping.map((a) => _addressCard(context, a)),
  //                     const SizedBox(height: 20),
  //                   ],
  //
  //                   // Show general header if there are non-default addresses
  //                   if (additional.isNotEmpty) ...[
  //                     const Text("Additional Address Entries",
  //                         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //                     ...additional.map((a) => _addressCard(context, a)),
  //                   ],
  //
  //                   // Floating-style Add Button at the bottom
  //                   const SizedBox(height: 20),
  //                   ElevatedButton.icon(
  //                     onPressed: () {
  //                       Navigator.push(
  //                         context,
  //                         MaterialPageRoute(
  //                           builder: (_) => BlocProvider.value(
  //                             value: context.read<AddressBloc>(),
  //                             child: const _AddAddressForm(),
  //                           ),
  //                         ),
  //                       );
  //                     },
  //                     icon: const Icon(Icons.add),
  //                     label: const Text("Add New Address"),
  //                     style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white),
  //                   ),
  //                 ],
  //               );
  //             } else if (state is AddressError) {
  //               return Center(child: Text("Error: ${state.message}"));
  //             }
  //             return const SizedBox.shrink();
  //           },
  //           // builder: (context, state) {
  //           //   if (state is AddressLoading) {
  //           //     return const Center(child: CircularProgressIndicator());
  //           //   } else if (state is AddressLoaded) {
  //           //     // Find the default billing address, or create an empty one if not found.
  //           //     final billing = state.addresses.firstWhere(
  //           //           (a) => a.isDefaultBilling,
  //           //       orElse: () => CustomerAddress(id: 0, firstname: "", lastname: "", street: "", city: "", postcode: "", country: "", telephone: "", isDefaultBilling: false, isDefaultShipping: false),
  //           //     );
  //           //
  //           //     // Find the default shipping address, or create an empty one if not found.
  //           //     final shipping = state.addresses.firstWhere(
  //           //           (a) => a.isDefaultShipping,
  //           //       orElse: () => CustomerAddress(id: 0, firstname: "", lastname: "", street: "", city: "", postcode: "", country: "", telephone: "", isDefaultBilling: false, isDefaultShipping: false),
  //           //     );
  //           //
  //           //     // Get all other addresses.
  //           //     final additional = state.addresses
  //           //         .where((a) => !a.isDefaultBilling && !a.isDefaultShipping)
  //           //         .toList();
  //           //
  //           //     // CASE: No default addresses exist at all. Show the add address form.
  //           //     if (billing.id == 0 && shipping.id == 0) {
  //           //       return _AddAddressForm();
  //           //     }
  //           //
  //           //     // CASE: A billing address exists, but no default shipping address is set.
  //           //     if (billing.id != 0 && shipping.id == 0) {
  //           //       return _noShippingView(billing);
  //           //     }
  //           //
  //           //     // NORMAL FLOW: Display all found addresses in their respective sections.
  //           //     return ListView(
  //           //       padding: const EdgeInsets.all(16),
  //           //       children: [
  //           //         const Text("Default Billing Address",
  //           //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //           //         _addressCard(context, billing),   // ✅ pass context
  //           //         const SizedBox(height: 20),
  //           //
  //           //         const Text("Default Shipping Address",
  //           //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //           //         _addressCard(context, shipping),  // ✅ pass context
  //           //         const SizedBox(height: 20),
  //           //
  //           //         const Text("Additional Address Entries",
  //           //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
  //           //         additional.isEmpty
  //           //             ? const Padding(
  //           //           padding: EdgeInsets.symmetric(vertical: 8.0),
  //           //           child: Text("You have no other address entries."),
  //           //         )
  //           //             : Column(
  //           //           children:
  //           //           additional.map((a) => _addressCard(context, a)).toList(), // ✅ pass context
  //           //         ),
  //           //       ],
  //           //     );
  //           //     ;
  //           //   } else if (state is AddressError) {
  //           //     return Center(child: Text("Error: ${state.message}"));
  //           //   }
  //           //   // Initial or unknown state
  //           //   return const SizedBox.shrink();
  //           // },
  //         ),
  //       ),
  //     );
  //   }
  //
  //   /// A card widget to display a single address.
  //   /// A card widget to display a single address.
  //   /// A card widget to display a single address.
  //   ///
  //   Widget _addressCard(BuildContext context, CustomerAddress address) {
  //     return Card(
  //       margin: const EdgeInsets.symmetric(vertical: 8),
  //       elevation: 2,
  //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  //       child: Padding(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Text("${address.firstname} ${address.lastname}",
  //                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
  //                 if (address.isDefaultBilling || address.isDefaultShipping)
  //                   Container(
  //                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
  //                     decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
  //                     child: const Text("DEFAULT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
  //                   )
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Text(address.street),
  //             Text("${address.city}, ${address.postcode}"),
  //             Text(address.country),
  //             Text("T: ${address.telephone}"),
  //             const Divider(height: 24),
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.end,
  //               children: [
  //                 // EDIT BUTTON
  //                 TextButton.icon(
  //                   onPressed: () {
  //                     Navigator.push(
  //                       context,
  //                       MaterialPageRoute(
  //                         builder: (_) => BlocProvider.value(
  //                           value: context.read<AddressBloc>(),
  //                           child: _AddAddressForm(existingAddress: address),
  //                         ),
  //                       ),
  //                     );
  //                   },
  //                   icon: const Icon(Icons.edit, size: 18),
  //                   label: const Text("Edit"),
  //                 ),
  //                 const SizedBox(width: 8),
  //                 // DELETE BUTTON
  //                 // TextButton.icon(
  //                 //   onPressed: () => _confirmDelete(context, address),
  //                 //   icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
  //                 //   label: const Text("Delete", style: TextStyle(color: Colors.red)),
  //                 // ),
  //               ],
  //             )
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   void _confirmDelete(BuildContext context, CustomerAddress address) {
  //     showDialog(
  //       context: context,
  //       builder: (dialogContext) => AlertDialog(
  //         title: const Text("Delete Address"),
  //         content: const Text("Are you sure you want to delete this address?"),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(dialogContext),
  //             child: const Text("Cancel"),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               // Dispatch Delete event to your AddressBloc
  //               // Make sure your AddressBloc has a DeleteAddress event implemented
  //               context.read<AddressBloc>().add(DeleteAddress(address.id));
  //               Navigator.pop(dialogContext);
  //             },
  //             child: const Text("Delete", style: TextStyle(color: Colors.red)),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //   // Widget _addressCard(BuildContext context, CustomerAddress address) {
  //   //   // If the address ID is 0, it means no address was found.
  //   //   if (address.id == 0) {
  //   //     return const Card(
  //   //       child: Padding(
  //   //         padding: EdgeInsets.all(12.0),
  //   //         child: Text("No address found."),
  //   //       ),
  //   //     );
  //   //   }
  //   //   return Card(
  //   //     margin: const EdgeInsets.symmetric(vertical: 8),
  //   //     child: Padding(
  //   //       padding: const EdgeInsets.all(12),
  //   //       child: Column(
  //   //         crossAxisAlignment: CrossAxisAlignment.start,
  //   //         children: [
  //   //           Text("${address.firstname} ${address.lastname}",
  //   //               style: const TextStyle(
  //   //                   fontWeight: FontWeight.bold, fontSize: 16)),
  //   //           const SizedBox(height: 4),
  //   //           Text(address.street),
  //   //           Text("${address.city}, ${address.postcode}"),
  //   //           Text(address.country),
  //   //           const SizedBox(height: 4),
  //   //           Text("T: ${address.telephone}"),
  //   //           const SizedBox(height: 8),
  //   //           Align(
  //   //             alignment: Alignment.centerRight,
  //   //             child: ElevatedButton(
  //   //               onPressed: () {
  //   //                 Navigator.push(
  //   //                   context,
  //   //                   MaterialPageRoute(
  //   //                     builder: (_) => BlocProvider.value(
  //   //                       value: context.read<AddressBloc>(), // reuse same bloc
  //   //                       child: _AddAddressForm(existingAddress: address), // ✅ pass address
  //   //                     ),
  //   //                   ),
  //   //                 );
  //   //               },
  //   //               child: const Text("Edit"),
  //   //             ),
  //   //           )
  //   //         ],
  //   //       ),
  //   //     ),
  //   //   );
  //   // }
  //
  //
  //
  //   /// A custom view shown when a default shipping address is missing.
  //   Widget _noShippingView(CustomerAddress billing) {
  //     return Center(
  //       child: Padding(
  //         padding: const EdgeInsets.all(24.0),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           crossAxisAlignment: CrossAxisAlignment.center,
  //           children: [
  //             const Icon(Icons.location_off, size: 80, color: Colors.grey),
  //             const SizedBox(height: 16),
  //             const Text(
  //               "No Default Shipping Address Found",
  //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //             ),
  //             const SizedBox(height: 8),
  //             const Text(
  //               "You have a billing address saved, but no shipping address.\nPlease add one to continue.",
  //               textAlign: TextAlign.center,
  //             ),
  //             const SizedBox(height: 24),
  //             ElevatedButton.icon(
  //               onPressed: () {
  //                 // TODO: Navigate to Add Shipping Address screen
  //               },
  //               icon: const Icon(Icons.add),
  //               label: const Text("Add Shipping Address"),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  // }


  /// A widget for the "Add Address" form, displayed when no addresses are found.


  /// A widget for the "Add Address" form, displayed when no addresses are found.
    class _AddAddressForm extends StatefulWidget {
      final CustomerAddress? existingAddress; // ✅ optional

      const _AddAddressForm({Key? key, this.existingAddress}) : super(key: key);

      @override
      __AddAddressFormState createState() => __AddAddressFormState();
    }

    class __AddAddressFormState extends State<_AddAddressForm> {
      final _formKey = GlobalKey<FormState>();

      final _firstNameController = TextEditingController();
      final _lastNameController = TextEditingController();
      final _companyController = TextEditingController();
      final _phoneController = TextEditingController();
      final _faxController = TextEditingController();
      final _street1Controller = TextEditingController();
      final _street2Controller = TextEditingController();
      final _cityController = TextEditingController();
      final _zipController = TextEditingController();
      // MODIFICATION: Add a controller for the manual region text field
      final _regionController = TextEditingController();

      bool _isDefaultBilling = true;
      bool _isDefaultShipping = true;
      bool _isSaving = false;

      late ShippingBloc _shippingBloc;
      List<Country> _countries = [];
      Country? _selectedCountry;
      Region? _selectedRegion;
      bool _isLoadingCountries = true;

      @override
      // void initState() {
      //   super.initState();
      //   _loadUserData();
      //
      //   _shippingBloc = context.read<ShippingBloc>();
      //   _shippingBloc.add(FetchCountries());
      // }

      @override
      @override
      void initState() {
        super.initState();
        _loadUserData();

        _shippingBloc = context.read<ShippingBloc>();
        _shippingBloc.add(FetchCountries());

        if (widget.existingAddress != null) {
          final addr = widget.existingAddress!;
          _firstNameController.text = addr.firstname;
          _lastNameController.text = addr.lastname;
          _phoneController.text = addr.telephone;

          // Split street. If it contains a newline, assume first line is street1.
          // Otherwise, assume the whole street is street1.
          final streetParts = addr.street.split('\n');
          _street1Controller.text = streetParts.first;
          if (streetParts.length > 1) {
            _street2Controller.text = streetParts.sublist(1).join(', '); // Join remaining parts for street2
          }

          _cityController.text = addr.city;
          _zipController.text = addr.postcode;
          _isDefaultBilling = addr.isDefaultBilling;
          _isDefaultShipping = addr.isDefaultShipping;
        }
      }


      Future<void> _loadUserData() async {
        final prefs = await SharedPreferences.getInstance();
        final firstName = prefs.getString('first_name') ?? '';
        final lastName = prefs.getString('last_name') ?? '';

        if (mounted) {
          _firstNameController.text = firstName;
          _lastNameController.text = lastName;
        }
      }

      void _onSaveAddress() {
        if (!_formKey.currentState!.validate()) return;

        if (_selectedCountry == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a country.')),
          );
          return;
        }

        final street = _street1Controller.text +
            (_street2Controller.text.isNotEmpty ? '\n${_street2Controller.text}' : '');

        final newAddress = CustomerAddress(
          id: widget.existingAddress?.id ?? 0, // ✅ reuse id if editing
          firstname: _firstNameController.text,
          lastname: _lastNameController.text,
          street: street,
          city: _cityController.text,
          postcode: _zipController.text,
          country: _selectedCountry!.id,
          telephone: _phoneController.text,
          isDefaultBilling: _isDefaultBilling,
          isDefaultShipping: _isDefaultShipping,
        );

        final String? regionId = _selectedRegion?.id;
        final String? regionName = _selectedCountry?.regions.isNotEmpty ?? false
            ? _selectedRegion?.name
            : (_regionController.text.isNotEmpty ? _regionController.text : null);

        context.read<AddressBloc>().add(AddAddress(
          newAddress,
          region: regionName,
          regionId: regionId,
        ));
      }

      // void _onSaveAddress() {
      //   // Validate the form first
      //   if (!_formKey.currentState!.validate()) {
      //     return;
      //   }
      //
      //   // A country must be selected
      //   if (_selectedCountry == null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       const SnackBar(content: Text('Please select a country.')),
      //     );
      //     return;
      //   }
      //
      //   // Combine street addresses
      //   final street = _street1Controller.text +
      //       (_street2Controller.text.isNotEmpty ? '\n${_street2Controller.text}' : '');
      //
      //   // Create the address object from the form data
      //   final newAddress = CustomerAddress(
      //     id: 0, // ID is 0 because this is a new address
      //     firstname: _firstNameController.text,
      //     lastname: _lastNameController.text,
      //     street: street,
      //     city: _cityController.text,
      //     postcode: _zipController.text,
      //     country: _selectedCountry!.id, // Use the country ID for the API
      //     telephone: _phoneController.text,
      //     isDefaultBilling: _isDefaultBilling,
      //     isDefaultShipping: _isDefaultShipping,
      //   );
      //
      //   // This logic is correct!
      //   final String? regionId = _selectedRegion?.id;
      //   final String? regionName = _selectedCountry?.regions.isNotEmpty ?? false
      //       ? _selectedRegion?.name
      //       : (_regionController.text.isNotEmpty ? _regionController.text : null);
      //
      //   // --- THIS IS THE CORRECTED LINE ---
      //   // Dispatch the event WITH the region data.
      //   context.read<AddressBloc>().add(AddAddress(
      //     newAddress,
      //     region: regionName,
      //     regionId: regionId,
      //   ));
      // }

      @override
      void dispose() {
        _firstNameController.dispose();
        _lastNameController.dispose();
        _companyController.dispose();
        _phoneController.dispose();
        _faxController.dispose();
        _street1Controller.dispose();
        _street2Controller.dispose();
        _cityController.dispose();
        _zipController.dispose();
        // MODIFICATION: Dispose the new controller
        _regionController.dispose();
        super.dispose();
      }

      // Widget _buildLabel(String text, {bool isRequired = false}) {
      //   return Padding(
      //     padding: const EdgeInsets.only(bottom: 8.0),
      //     child: RichText(
      //       text: TextSpan(
      //         text: text,
      //         style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16,
      //           color: Colors.black,),
      //         children: [
      //           if (isRequired)
      //             const TextSpan(
      //               text: ' *',
      //               style: TextStyle(color: Colors.black),
      //             ),
      //         ],
      //       ),
      //     ),
      //   );
      // }

      Widget _buildLabel(String text, {bool isRequired = false}) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(
              text: text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
                decoration: TextDecoration.none, // ✅ IMPORTANT
              ),
              children: [
                if (isRequired)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none, // ✅ IMPORTANT
                    ),
                  ),
              ],
            ),
          ),
        );
      }

      Widget _buildTextField({
        required TextEditingController controller,
        required String label,
        bool isRequired = false,
        String? hintText,
        bool enabled = true,
      }) {
        const blackBorder = OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel(label, isRequired: isRequired),

            TextFormField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                hintText: hintText,
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

                // ✅ FORCE BLACK BORDER EVERYWHERE
                border: blackBorder,
                enabledBorder: blackBorder,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),
                errorBorder: blackBorder,
                focusedErrorBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1.5),
                ),

                // ✅ ERROR TEXT ALSO BLACK
                errorStyle: const TextStyle(color: Colors.black),

                // Disabled field styling
                filled: !enabled,
                fillColor: !enabled ? Colors.grey.shade200 : null,
              ),
              validator: (value) {
                if (enabled && isRequired && (value == null || value.isEmpty)) {
                  return 'This field is required.';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),
          ],
        );
      }

      // MODIFICATION: Added an 'enabled' parameter to the helper for better reusability.
      // Widget _buildTextField({
      //   required TextEditingController controller,
      //   required String label,
      //   bool isRequired = false,
      //   String? hintText,
      //   bool enabled = true,
      // }) {
      //   return Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       _buildLabel(label, isRequired: isRequired),
      //       TextFormField(
      //         controller: controller,
      //         enabled: enabled,
      //         decoration: InputDecoration(
      //           border: const OutlineInputBorder(),
      //           contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //           hintText: hintText,
      //           // Add a visual cue for disabled fields
      //           filled: !enabled,
      //           fillColor: !enabled ? Colors.grey.shade200 : null,
      //         ),
      //         validator: (value) {
      //           // Only validate if the field is enabled and required
      //           if (enabled && isRequired && (value == null || value.isEmpty)) {
      //             return 'This field is required.';
      //           }
      //           return null;
      //         },
      //       ),
      //       const SizedBox(height: 20),
      //     ],
      //   );
      // }



      @override
      @override
      Widget build(BuildContext context) {
        return BlocConsumer<AddressBloc, AddressState>(
          listener: (context, state) {
            if (state is AddressSaving) {
              setState(() => _isSaving = true);
            }
            if (state is AddressError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
              setState(() => _isSaving = false);
            }
            if (state is AddressLoaded) {
              // If the address was successfully added/updated, pop the screen
              // and let the parent AddressScreen rebuild to show the updated list.
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            return BlocListener<ShippingBloc, ShippingState>(
              listener: (context, state) {
                if (state is CountriesLoaded) {
                  if (mounted) {
                    setState(() {
                      _countries = state.countries;

                      // Always try to find the existing address's country first using firstWhereOrNull
                      if (widget.existingAddress != null && widget.existingAddress!.country.isNotEmpty) {
                        _selectedCountry = _countries.firstWhereOrNull((c) => c.id == widget.existingAddress!.country);
                      }

                      // If no existing country found or if existing country was not in the list,
                      // then try to default to India.
                      if (_selectedCountry == null) {
                        _selectedCountry = _countries.firstWhereOrNull((c) => c.fullNameEnglish.toLowerCase() == 'india');
                      }

                      // If still no country (e.g., India not in list, or list is empty), _selectedCountry remains null.
                      // This is fine as _selectedCountry is already nullable.

                      // Try to find the existing address's region if available
                      if (_selectedCountry != null && widget.existingAddress != null && widget.existingAddress!.street.contains(', ')) {
                        final streetParts = widget.existingAddress!.street.split(', ').map((s) => s.trim()).toList();
                        String? regionNameToMatch;

                        // Improved heuristic for finding region name in street address
                        if (streetParts.length > 1) {
                          // Iterate backwards from the second to last part,
                          // avoiding the last part if it looks like a postcode.
                          for (int i = streetParts.length - 1; i >= 0; i--) {
                            final part = streetParts[i];
                            // Check if the part is not a simple number (like a zip code)
                            // and has more than 1 character to avoid single-letter abbreviations
                            if (part.length > 1 && int.tryParse(part) == null) {
                              regionNameToMatch = part;
                              break; // Found a likely region, stop
                            }
                          }
                        }

                        if (regionNameToMatch != null && _selectedCountry!.regions.isNotEmpty) {
                          _selectedRegion = _selectedCountry!.regions.firstWhereOrNull(
                                (r) => r.name.toLowerCase() == regionNameToMatch!.toLowerCase(),
                          );

                          if (_selectedRegion == null) {
                            // If region not found in dropdown, put the extracted name in the text controller
                            _regionController.text = regionNameToMatch;
                          }
                        } else if (regionNameToMatch != null) {
                          // If country has no regions, but we extracted a region name, put it in the text field
                          _regionController.text = regionNameToMatch;
                        }
                      } else if (widget.existingAddress != null && widget.existingAddress!.street.isNotEmpty && _selectedCountry != null && _selectedCountry!.regions.isEmpty) {
                        // Special case: country has no regions and street might contain the region directly
                        // This might need more specific logic depending on your `street` format
                        final streetLines = widget.existingAddress!.street.split('\n');
                        if (streetLines.length > 1) {
                          _regionController.text = streetLines.last.trim();
                        } else {
                          // If it's a single line, maybe the whole thing is the region?
                          // Or part of it. This is highly dependent on your data.
                          _regionController.text = widget.existingAddress!.street.trim();
                        }
                      }


                      _isLoadingCountries = false;
                    });
                  }
                } else if (state is ShippingError) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not load countries: ${state.message}')),);
                    setState(() => _isLoadingCountries = false);
                  }
                }
              },
              child: Material( // <<< WRAP WITH MATERIAL WIDGET HERE
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(controller: _firstNameController, label: 'First Name', isRequired: true),
                        _buildTextField(controller: _lastNameController, label: 'Last Name', isRequired: true),
                        _buildTextField(controller: _companyController, label: 'Company'),
                        _buildTextField(controller: _phoneController, label: 'Phone Number', isRequired: true),
                        _buildTextField(controller: _faxController, label: 'Fax'),
                        const SizedBox(height: 20),
                        Center(child: Text('Address', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
                        const SizedBox(height: 20),
                        _buildTextField(controller: _street1Controller, label: 'Street Address', isRequired: true),
                        TextFormField(
                          controller: _street2Controller,
                          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), hintText: 'Street Address 2'),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(controller: _cityController, label: 'City', isRequired: true),
                        if (_isLoadingCountries) const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 32.0), child: CircularProgressIndicator(),))
                        else _buildCountryStateDropdowns(),
                        _buildTextField(controller: _zipController, label: 'Zip/Postal Code', isRequired: true),
                        const SizedBox(height: 10),

                        Column(
                          children: [
                            Card(
                              child: CheckboxListTile(
                                value: _isDefaultBilling,
                                title: const Text("Set as Default Billing Address"),
                                onChanged: (val) {
                                  setState(() => _isDefaultBilling = val!);
                                },
                              ),
                            ),
                            Card(
                              child: CheckboxListTile(
                                value: _isDefaultShipping,
                                title: const Text("Set as Default Shipping Address"),
                                onChanged: (val) {
                                  setState(() => _isDefaultShipping = val!);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _onSaveAddress,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: _isSaving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,)) : const Text('Save Address'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.black,
                                  side: const BorderSide(color: Colors.black),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Go back'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ), // <<< END OF MATERIAL WIDGET
            );;
          },
        );
      }


      // MODIFICATION: This entire widget is updated to handle the logic.
      Widget _buildCountryStateDropdowns() {
        final regions = _selectedCountry?.regions ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('Country', isRequired: true),
            DropdownButtonFormField<Country>(
              value: _selectedCountry,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              hint: const Text('Please select a country.'),
              items: _countries
                  .map((country) => DropdownMenuItem(
                value: country,
                child: Text(country.fullNameEnglish),
              ))
                  .toList(),
              onChanged: (country) {
                if (country != _selectedCountry) {
                  setState(() {
                    _selectedCountry = country;
                    _selectedRegion = null;
                    // Clear the text field when the country changes
                    _regionController.clear();
                  });
                }
              },
              validator: (value) => value == null ? 'Please select a country.' : null,
            ),
            const SizedBox(height: 20),

            // Conditionally show dropdown or text field
            if (regions.isNotEmpty)
            // If regions are available, show the dropdown
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('State/Province', isRequired: true),
                  DropdownButtonFormField<Region>(
                    value: _selectedRegion,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    hint: const Text('Please select a region, state or province.'),
                    onChanged: (region) {
                      setState(() => _selectedRegion = region);
                    },
                    items: regions
                        .map((region) => DropdownMenuItem(
                      value: region,
                      child: Text(region.name),
                    ))
                        .toList(),
                    validator: (value) {
                      if (regions.isNotEmpty && value == null) {
                        return 'Please select a state.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              )
            else
            // If no regions are available, show a text field
              _buildTextField(
                controller: _regionController,
                label: 'State/Province',
                // Field is required and enabled only if a country has been selected
                isRequired: _selectedCountry != null,
                enabled: _selectedCountry != null,
                hintText: _selectedCountry == null ? 'Select a country first' : null,
              ),
          ],
        );
      }
    }

