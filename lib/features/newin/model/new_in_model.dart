// class NewInProduct {
//   final String designerName;
//   final double actualPrice;
//   final String productId;
//   final String sku;
//
//   final String shortDesc;
//   final String smallImgUrl;
//   final String thumbImgUrl;
//
//   NewInProduct({
//     required this.designerName,
//     required this.actualPrice,
//     required this.productId,
//     required this.sku,
//
//     required this.shortDesc,
//     required this.smallImgUrl,
//     required this.thumbImgUrl,
//   });
//
//   factory NewInProduct.fromJson(Map<String, dynamic> json) {
//     return NewInProduct(
//       designerName: json['designer_name'] ?? '',
//       actualPrice: (json['actual_price_1'] ?? 0).toDouble(),
//       productId: json['prod_en_id'].toString(),
//       sku: json['prod_sku'] ?? '',
//
//       shortDesc: json['short_desc'] ?? '',
//       smallImgUrl: json['prod_small_img'] ?? '',
//       thumbImgUrl: json['prod_thumb_img'] ?? '',
//     );
//   }
//
//
//   String parseProductName(dynamic raw) {
//     if (raw == null) return '';
//     if (raw is List && raw.isNotEmpty) return raw.first.toString();
//     if (raw is String) return raw;
//     return raw.toString();
//   }
//
//
// }



class SolrProductResponse {
  final int numFound;
  final List<Product> products;

  SolrProductResponse({
    required this.numFound,
    required this.products,
  });

  factory SolrProductResponse.fromJson(Map<String, dynamic> json) {
    final response = json['response'];
    return SolrProductResponse(
      numFound: response['numFound'],
      products: (response['docs'] as List<dynamic>)
          .map((doc) => Product.fromJson(doc))
          .toList(),
    );
  }
}

class Product {
  final String designerName;
  final double actualPrice;
  final String shortDesc;
  final String prod_en_id;
  final String prodSmallImg;
  final List<String> colorNames;
  final List<String> prodNames;
  final List<String> occasionNames;
  final List<String> sizeList;
  final String prod_sku;
  final List<String> prodDesc;
  final List<String> deliveryTime;

  final String? patterns_name;
  final String? gender_name;
  final String? kid_name;

  Product({
    required this.designerName,
    required this.actualPrice,
    required this.shortDesc,
    required this.prod_en_id,
    required this.prodSmallImg,
    required this.colorNames,
    required this.prodNames,
    required this.occasionNames,
    required this.sizeList,
    required this.prod_sku,
    required this.prodDesc,
    required this.deliveryTime,

    this.patterns_name,
    this.gender_name,
    this.kid_name,

  });

  factory Product.fromJson(Map<String, dynamic> json) {
    String? _getFirstString(dynamic value) {
      if (value is String) {
        return value.isNotEmpty ? value : null;
      }
      if (value is List && value.isNotEmpty) {
        // If it's a list, take the first item and ensure it's a string.
        return value.first?.toString();
      }
      // Return null if the value is null, an empty list, or another type.
      return null;
    }
    return Product(
      designerName: json['designer_name'] ?? '',
      actualPrice: (json['actual_price_1'] ?? 0).toDouble(),
      shortDesc: json['short_desc'] ?? '',
      prod_en_id: json['prod_en_id'] ?? '',
      prodSmallImg: json['prod_small_img'] ?? '',
      colorNames: List<String>.from(json['color_name'] ?? []),
      prodNames: List<String>.from(json['prod_name'] ?? []),
      occasionNames: List<String>.from(json['occasion_name'] ?? []),
      sizeList: List<String>.from(json['size_name'] ?? []),
      prod_sku: json['prod_sku'] ?? '',
      prodDesc:  List<String>.from(json['prod_desc'] ?? []),
      deliveryTime:  List<String>.from(json['child_delivery_time'] ?? []),

// ✅ CORRECTED LOGIC HERE
      patterns_name: _getFirstString(json['patterns_name']),
      gender_name: _getFirstString(json['gender_name']),
      kid_name: _getFirstString(json['kid_name']),
    );
  }

  get prodEnId => null;

  Map<String, dynamic> toJson() {
    return {
      'designer_name': designerName,
      'actual_price_1': actualPrice,
      'short_desc': shortDesc,
      'prod_en_id': prod_en_id,
      'prod_small_img': prodSmallImg,
      'color_name': colorNames,
      'prod_name': prodNames,
      'occasion_name': occasionNames,
      'size_name':sizeList,
      'prod_sku': prod_sku,
      'prod_desc':prodDesc,
      'child_delivery_time': deliveryTime,
      'patterns_name': patterns_name,
      'gender_name': gender_name,
      'kid_name': kid_name,


    };
  }

  static List<Product> listFromJson(Map<String, dynamic> json) {
    final docs = json['response']['docs'] as List<dynamic>?;
    if (docs == null) return [];

    return docs.map((doc) => Product.fromJson(doc)).toList();
  }
}


// class Product {
//   final String designerName;
//   final double actualPrice;
//   final String shortDesc;
//   final String prod_en_id;
//
//   final String prodSmallImg;
//   // final List<String> sizeName;
//   final List<String> colorNames;  // Updated field name to reflect color names properly
//   final List<String> prodNames;
//   final List<String> occasionNames;
//
//   Product({
//     required this.designerName,
//     required this.actualPrice,
//     required this.shortDesc,
//     required this.prod_en_id,
//
//     required this.prodSmallImg,
//     required this.colorNames,
//     required this.prodNames,
//     required this.occasionNames,
//
//     // required this.sizeName
//   });
//
//
//
//   factory Product.fromJson(Map<String, dynamic> json) {
//     // final rawSizeName = json['size_name'];
//     //
//     // List<String> parsedSizes;
//     // if (rawSizeName is List) {
//     //   parsedSizes = List<String>.from(rawSizeName.map((e) => e.toString()));
//     // } else if (rawSizeName != null) {
//     //   parsedSizes = [rawSizeName.toString()];
//     // } else {
//     //   parsedSizes = [];
//     // }
//
//     return Product(
//       designerName: json['designer_name'] ?? '',
//       actualPrice: (json['actual_price_1'] ?? 0).toDouble(),
//       shortDesc: json['short_desc'] ?? '',
//       prod_en_id: json['prod_en_id'] ?? '',
//       prodSmallImg: json['prod_small_img'] ?? '',
//       // sizeName: parsedSizes,
//       colorNames: List<String>.from(json['color_name'] ?? []),  // Ensuring this is parsed as a List<String>
//       prodNames: List<String>.from(json['prod_name'] ?? []),
//       occasionNames: List<String>.from(json['occasion_name'] ?? []),
//     );
//   }
//
//
// // // 🆕 Add this static method
//   static List<Product> listFromJson(Map<String, dynamic> json) {
//     final docs = json['response']['docs'] as List<dynamic>?; // 🔥 Magento Solr style
//     if (docs == null) return [];
//
//     return docs.map((doc) => Product.fromJson(doc)).toList();
//   }
// }


