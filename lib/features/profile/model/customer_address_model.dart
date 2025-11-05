class CustomerAddress {
  final int id;
  final String firstname;
  final String lastname;
  final String street;
  final String city;
  final String postcode;
  final String country;
  final String telephone;
  final bool isDefaultBilling;
  final bool isDefaultShipping;

  CustomerAddress({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.street,
    required this.city,
    required this.postcode,
    required this.country,
    required this.telephone,
    required this.isDefaultBilling,
    required this.isDefaultShipping,
  });

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      street: (json['street'] as List).join(", "),
      city: json['city'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country_id'] ?? '',
      telephone: json['telephone'] ?? '',
      isDefaultBilling: json['default_billing'] == true,
      isDefaultShipping: json['default_shipping'] == true,
    );
  }


}
