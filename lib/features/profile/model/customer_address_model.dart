// class CustomerAddress {
//   final int id;
//   final String firstname;
//   final String lastname;
//   final String street;
//   final String city;
//   final String postcode;
//   final String country;
//   final String telephone;
//   final String? region;   // The name of the state/province
//   final int? regionId;
//   final bool isDefaultBilling;
//   final bool isDefaultShipping;
//
//   CustomerAddress({
//     required this.id,
//     required this.firstname,
//     required this.lastname,
//     required this.street,
//     required this.city,
//     required this.postcode,
//     required this.country,
//     required this.telephone,
//     this.region,
//     this.regionId,
//     required this.isDefaultBilling,
//     required this.isDefaultShipping,
//   });
//
//   factory CustomerAddress.fromJson(Map<String, dynamic> json) {
//     return CustomerAddress(
//       id: json['id'],
//       firstname: json['firstname'] ?? '',
//       lastname: json['lastname'] ?? '',
//       street: (json['street'] as List).join(", "),
//       city: json['city'] ?? '',
//       postcode: json['postcode'] ?? '',
//       country: json['country_id'] ?? '',
//       telephone: json['telephone'] ?? '',
//       isDefaultBilling: json['default_billing'] == true,
//       isDefaultShipping: json['default_shipping'] == true,
//     );
//   }
//
//
// }


// class CustomerAddress {
//   final int id;
//   final String firstname;
//   final String lastname;
//   final String street;
//   final String city;
//   final String postcode;
//   final String country;
//   final String telephone;
//   final String? region; // The name of the state/province
//   final int? regionId;
//   final bool isDefaultBilling;
//   final bool isDefaultShipping;
//
//   CustomerAddress({
//     required this.id,
//     required this.firstname,
//     required this.lastname,
//     required this.street,
//     required this.city,
//     required this.postcode,
//     required this.country,
//     required this.telephone,
//     this.region,
//     this.regionId,
//     required this.isDefaultBilling,
//     required this.isDefaultShipping,
//   });
//
//   factory CustomerAddress.fromJson(Map<String, dynamic> json) {
//     // 1. Safe parsing for Street (Magento returns a List)
//     String streetString = "";
//     if (json['street'] is List) {
//       streetString = (json['street'] as List).join(", ");
//     } else {
//       streetString = json['street']?.toString() ?? "";
//     }
//
//     // 2. Safe parsing for Region (Handling nested Map or flat ID)
//     String? regionName;
//     int? rId;
//
//     if (json['region'] is Map) {
//       // Structure: "region": {"region": "Maharashtra", "region_id": 541}
//       regionName = json['region']['region']?.toString();
//       rId = json['region']['region_id'] is int
//           ? json['region']['region_id']
//           : int.tryParse(json['region']['region_id']?.toString() ?? '');
//     } else {
//       // Structure: "region": "Maharashtra", "region_id": 541
//       regionName = json['region']?.toString();
//       rId = json['region_id'] is int
//           ? json['region_id']
//           : int.tryParse(json['region_id']?.toString() ?? '');
//     }
//
//     return CustomerAddress(
//       id: json['id'] ?? 0,
//       firstname: json['firstname'] ?? '',
//       lastname: json['lastname'] ?? '',
//       street: streetString,
//       city: json['city'] ?? '',
//       postcode: json['postcode'] ?? '',
//       country: json['country_id'] ?? '',
//       telephone: json['telephone'] ?? '',
//       region: regionName,
//       regionId: rId,
//       isDefaultBilling: json['default_billing'] == true,
//       isDefaultShipping: json['default_shipping'] == true,
//     );
//   }
// }


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
  final String? region;   // Added this
  final String? regionId; // Added this

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
    this.region,   // Added this
    this.regionId, // Added this
  });

  // This fixes the "copyWith" error
  CustomerAddress copyWith({
    int? id,
    String? firstname,
    String? lastname,
    String? street,
    String? city,
    String? postcode,
    String? country,
    String? telephone,
    bool? isDefaultBilling,
    bool? isDefaultShipping,
    String? region,
    String? regionId,
  }) {
    return CustomerAddress(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      lastname: lastname ?? this.lastname,
      street: street ?? this.street,
      city: city ?? this.city,
      postcode: postcode ?? this.postcode,
      country: country ?? this.country,
      telephone: telephone ?? this.telephone,
      isDefaultBilling: isDefaultBilling ?? this.isDefaultBilling,
      isDefaultShipping: isDefaultShipping ?? this.isDefaultShipping,
      region: region ?? this.region,
      regionId: regionId ?? this.regionId,
    );
  }

  factory CustomerAddress.fromJson(Map<String, dynamic> json) {
    return CustomerAddress(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      street: (json['street'] is List) ? (json['street'] as List).join(", ") : (json['street'] ?? ""),
      city: json['city'] ?? '',
      postcode: json['postcode'] ?? '',
      country: json['country_id'] ?? '',
      telephone: json['telephone'] ?? '',
      isDefaultBilling: json['default_billing'] == true,
      isDefaultShipping: json['default_shipping'] == true,
      // Pull region data from Magento JSON if available
      region: json['region'] is Map ? json['region']['region'] : json['region'],
      regionId: json['region_id']?.toString(),
    );
  }
}