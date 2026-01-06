import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shoppingbag/ shipping_bloc/shipping_bloc.dart';
import '../../shoppingbag/ shipping_bloc/shipping_event.dart';
import '../../shoppingbag/ shipping_bloc/shipping_state.dart';
import '../../shoppingbag/model/countries.dart';
import '../bloc/address_bloc.dart';
import '../bloc/address_event.dart';
import '../bloc/address_state.dart';
import '../model/customer_address_model.dart';

class EditAddressScreen extends StatefulWidget {
  final CustomerAddress? address;

  const EditAddressScreen({super.key, this.address});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _street1Controller = TextEditingController();
  final _street2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _regionController = TextEditingController();

  bool _isDefaultBilling = true;
  bool _isDefaultShipping = true;
  bool _isSaving = false;

  Country? _selectedCountry;
  Region? _selectedRegion;
  List<Country> _countries = [];
  bool _isLoadingCountries = true;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    if (widget.address != null) {
      final addr = widget.address!;
      _firstNameController.text = addr.firstname;
      _lastNameController.text = addr.lastname;
      _phoneController.text = addr.telephone;
      _cityController.text = addr.city;
      _zipController.text = addr.postcode;
      _isDefaultBilling = addr.isDefaultBilling;
      _isDefaultShipping = addr.isDefaultShipping;

      final streetParts = addr.street.split(', ');
      _street1Controller.text = streetParts.isNotEmpty ? streetParts[0] : '';
      if (streetParts.length > 1) {
        _street2Controller.text = streetParts.sublist(1).join(', ');
      }
    }
    // FIX: This is how you call the Bloc event
    context.read<ShippingBloc>().add(FetchCountries());
  }

  void _onSaveAddress() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCountry == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a country.')));
      return;
    }

    final street = _street1Controller.text + (_street2Controller.text.isNotEmpty ? '\n${_street2Controller.text}' : '');

    final updatedAddress = CustomerAddress(
      id: widget.address?.id ?? 0,
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

    // FIX: This is how you add the event
    context.read<AddressBloc>().add(AddAddress(
      updatedAddress,
      region: regionName,
      regionId: regionId,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddressBloc, AddressState>(
      listener: (context, state) {
        // ALWAYS check if the widget is still in the tree (mounted)
        if (!mounted) return;

        if (state is AddressSaving) {
          setState(() => _isSaving = true);
        }

        if (state is AddressError) {
          setState(() => _isSaving = false);
          // Only show SnackBar if still mounted
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        }

        if (state is AddressLoaded) {
          // Success!
          setState(() => _isSaving = false);
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.address == null ? "Add Address" : "Edit Address")),
        body: BlocListener<ShippingBloc, ShippingState>(
          listener: (context, state) {
            if (state is CountriesLoaded) {
              setState(() {
                _countries = state.countries;
                _selectedCountry = _countries.firstWhereOrNull((c) => c.id == (widget.address?.country ?? 'IN'));
                _isLoadingCountries = false;
              });
            }
          },
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildTextField(_firstNameController, 'First Name'),
                  _buildTextField(_lastNameController, 'Last Name'),
                  _buildTextField(_phoneController, 'Phone Number'),
                  _buildTextField(_street1Controller, 'Street Address'),
                  _buildTextField(_street2Controller, 'Street Address 2', required: false),
                  _buildTextField(_cityController, 'City'),

                  if (_isLoadingCountries)
                    const CircularProgressIndicator()
                  else
                    _buildCountryStateDropdowns(),
                  // This method is now defined below
                   SizedBox(height: 20,),
                  _buildTextField(_zipController, 'Zip/Postal Code'),

                  CheckboxListTile(
                    title: const Text("Default Billing"),
                    value: _isDefaultBilling,
                    onChanged: (v) => setState(() => _isDefaultBilling = v!),
                  ),
                  CheckboxListTile(
                    title: const Text("Default Shipping"),
                    value: _isDefaultShipping,
                    onChanged: (v) => setState(() => _isDefaultShipping = v!),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                      onPressed: _isSaving ? null : _onSaveAddress,
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(widget.address == null ? "SAVE ADDRESS" : "UPDATE ADDRESS", style: const TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- MISSING HELPER METHODS ADDED BELOW ---

  Widget _buildTextField(TextEditingController controller, String label, {bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
        validator: (v) => (required && (v == null || v.isEmpty)) ? "Required" : null,
      ),
    );
  }

  Widget _buildCountryStateDropdowns() {
    final regions = _selectedCountry?.regions ?? [];
    return Column(
      children: [
        DropdownButtonFormField<Country>(
          value: _selectedCountry,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Country', border: OutlineInputBorder()),
          items: _countries.map((c) => DropdownMenuItem(value: c, child: Text(c.fullNameEnglish))).toList(),
          onChanged: (country) => setState(() {
            _selectedCountry = country;
            _selectedRegion = null;
          }),
        ),
        const SizedBox(height: 16),
        if (regions.isNotEmpty)
          DropdownButtonFormField<Region>(
            value: _selectedRegion,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'State/Province', border: OutlineInputBorder()),
            items: regions.map((r) => DropdownMenuItem(value: r, child: Text(r.name))).toList(),
            onChanged: (region) => setState(() => _selectedRegion = region),
          )
        else
          _buildTextField(_regionController, 'State/Province'),
      ],
    );
  }
}