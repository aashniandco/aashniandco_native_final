
import 'package:aashniandco/constants/environment.dart';

class ApiConstants{

  static late Environment currentEnv;

  static void setEnvironment(Environment env){

    currentEnv = env;


  }

  static String  get baseUrl{

    switch(currentEnv) {

      case Environment.dev:
        return "https://dev.aashniandco.com/rest";

      case Environment.stage:
        return "https://aashniandco.com/rest";
        // return "http://stage.aashniandco.com/rest";
        // return "https://stage.aashniandco.com";
      case Environment.prod:
        // return "https://aashniandco.com/rest/V1/solr";
        return "https://aashniandco.com/rest";
    }
    }

// static String url = "https://stage.aashniandco.com/rest/V1/solr/search";
  static String url = "https://aashniandco.com/rest/V1/solr/search";


  static String get newIn => "$baseUrl/newin";
  static String get newInAccessories => "$baseUrl/new-in-accessories";
  static String get newInProducts => "$baseUrl/products";
  static String get designers => "$baseUrl/designers";
  static String get lehengas => "$baseUrl/lehengas";
  static String get kurtasets => "$baseUrl/kurtasets";
  static String get tops => "$baseUrl/tops";
  static String get kaftans => "$baseUrl/kaftans";
  static String get gowns => "$baseUrl/gowns";
  static String get pants => "$baseUrl/pants";
  static String get tunicskurtis => "$baseUrl/tunicskurtis";
  static String get capes => "$baseUrl/capes";
  static String get jumpsuits => "$baseUrl/jumpsuits";
  static String get kurtas => "$baseUrl/kurtas";
  static String get skirts => "$baseUrl/skirts";
  static String get palazzosets => "$baseUrl/palazzosets";
  static String get beach => "$baseUrl/beach";
  static String get color => "$baseUrl/color";


  //NewIn-Accessories
  static String get bags => "$baseUrl/bags";
  static String get shoes => "$baseUrl/shoes";
  static String get belts => "$baseUrl/belts";
  static String get masks => "$baseUrl/masks";


  // NewIn- Men
  // static String get kurtasets => "$baseUrl/kurtasets";
  static String get sherwanis => "$baseUrl/sherwanis";
  static String get jackets => "$baseUrl/jackets";
  static String get menaccessories => "$baseUrl/menaccessories";
  // static String get kurtas => "$baseUrl/kurtas";
  static String get shirts => "$baseUrl/shirts";
  static String get bandis => "$baseUrl/bandis";
  static String get trousers=> "$baseUrl/trousers";

  // NewIn- Jewelry
  static String get earrings => "$baseUrl/earrings";
  static String get bangles => "$baseUrl/bangles";
  static String get finejewelry => "$baseUrl/finejewelry";
  static String get handharness => "$baseUrl/handharness";
  static String get rings => "$baseUrl/rings";
  static String get footharness => "$baseUrl/footharness";
  static String get brooches => "$baseUrl/brooches";
  static String get giftboxes => "$baseUrl/giftboxes";

// Newin Kidswear
  static String get kurtasetsforboys => "$baseUrl/kurtasetsforboys";
  static String get shararas => "$baseUrl/shararas";
  static String get dresses => "$baseUrl/dresses";
  static String get kidsaccessories => "$baseUrl/kidsaccessories";
  // static String get shirts => "$baseUrl/shirts";
  // static String get jackets => "$baseUrl/jackets";
  static String get coordset=> "$baseUrl/coordset";
  // static String get gowns => "$baseUrl/gowns";
  static String get jumpsuit => "$baseUrl/jumpsuit";
  // static String get sherwanis => "$baseUrl/sherwanis";
  // static String get pants => "$baseUrl/pants";
  // static String get bags => "$baseUrl/bags";
  // static String get tops=> "$baseUrl/tops";
  // static String get skirts => "$baseUrl/skirts";
  static String get sarees => "$baseUrl/sarees";

  //subcategory

  // Newin Theme
  static String get  contemporary => "$baseUrl/contemporary";
  static String get  ethnic => "$baseUrl/ethnic";

  // Newin Gender
  static String get  men => "$baseUrl/men";
  static String get  women => "$baseUrl/women";
// Newin Color
  static String get  black => "$baseUrl/black";
  static String get  red => "$baseUrl/red";
  static String get  blue => "$baseUrl/blue";
  static String get  green => "$baseUrl/green";
  static String get  yellow => "$baseUrl/yellow";
  static String get  white => "$baseUrl/white";
  static String get  pink => "$baseUrl/pink";
  static String get  grey => "$baseUrl/grey";
  // static String get  brown => "$baseUrl/brown";

// Newin Size

  // static String get  xxsmall => "$baseUrl/xxsmall";
  // static String get  xsmall => "$baseUrl/xsmall";
  // static String get  small => "$baseUrl/small";
  //
  // static String get  medium => "$baseUrl/medium";
  // static String get  large => "$baseUrl/large";
  // static String get  xlarge => "$baseUrl/xlarge";
  // static String get  xxlarge => "$baseUrl/xxlarge";
  // static String get  3xlarge => "$baseUrl/3xlarge";
  // static String get  small => "$baseUrl/small";
  // static String get  small => "$baseUrl/small";
  // static String get  small => "$baseUrl/small";
  // static String get  small => "$baseUrl/small";
  // static String get  small => "$baseUrl/small";

  // static Map<String, String> get sizes => {
  //
  // };


  static String getApiUrlForProducts(List<String> selectedThemes, String categoryId) {
    // Joining themes to form a comma-separated list
    final themes = selectedThemes.join(',');

    // Constructing the full URL with query parameters
    return '$baseUrl/products?themes=$themes&categoryId=$categoryId';
  }

  /// ✅ All subcategory endpoints in one place
  // Inside ApiConstants
  static final Map<String, String> subcategoryApiMap = {
    'designers': '$baseUrl/designers',
    'products': '$baseUrl/products',
    'lehengas': "$baseUrl/lehengas",
    'kurtasets':"$baseUrl/kurtasets",
    'tops':"$baseUrl/tops",
    'sarees': "$baseUrl/sarees",
    'kaftans': "$baseUrl/kaftans",
    'gowns': "$baseUrl/gowns",
    'pants': "$baseUrl/pants",
    'capes': "$baseUrl/capes",
    'jumpsuits': "$baseUrl/jumpsuits",
    'kurtas': "$baseUrl/kurtas",
    'skirts': "$baseUrl/skirts",
    'palazzosets': "$baseUrl/palazzosets",
    'beach': "$baseUrl/beach",

    'bags': "$baseUrl/bags",
    'shoes': "$baseUrl/shoes",
    'belts': "$baseUrl/belts",
    'masks': "$baseUrl/masks",

    'sherwanis': "$baseUrl/sherwanis",
    'jackets': "$baseUrl/jackets",
    'menaccessories': "$baseUrl/menaccessories",

    'shirts': "$baseUrl/shirts",
    'bandis': "$baseUrl/bandis",
    'trousers': "$baseUrl/trousers",



   'earrings': "$baseUrl/earrings",
   'bangles': "$baseUrl/bangles",
   'finejewelry': "$baseUrl/finejewelry",
   'handharness': "$baseUrl/handharness",
   'rings': "$baseUrl/rings",
   'footharness': "$baseUrl/footharness",
   'brooches': "$baseUrl/brooches",
   'giftboxes': "$baseUrl/giftboxes",


    'kurtasetsforboys': "$baseUrl/kurtasetsforboys",
    'shararas': "$baseUrl/shararas",
    'dresses': "$baseUrl/dresses",
    'kidsaccessories ': "$baseUrl/kidsaccessories ",
    'coordset': "$baseUrl/coordset",
    'jumpsuit': "$baseUrl/jumpsuit",
    'sarees': "$baseUrl/sarees",


    'contemporary': "$baseUrl/contemporary",
    'ethnic': "$baseUrl/ethnic",

    'men': "$baseUrl/men",
    'women': "$baseUrl/women",
    'color': "$baseUrl/color",

    'black': "$baseUrl/black",
    'red': "$baseUrl/red",
    'blue': "$baseUrl/blue",
    'green': "$baseUrl/green",
    'yellow': "$baseUrl/yellow",
    'white': "$baseUrl/white",
    'pink': "$baseUrl/pink",
    'grey': "$baseUrl/grey",
    'brown': "$baseUrl/brown",


    'xlarge': '$baseUrl/xlarge',
    'xxlarge': '$baseUrl/xxlarge',
    '3xlarge': '$baseUrl/3xlarge',
    '4xlarge': '$baseUrl/4xlarge',
    '5xlarge': '$baseUrl/5xlarge',
    '6xlarge': '$baseUrl/6xlarge',
    'custommade': '$baseUrl/custommade',
    'freesize': '$baseUrl/freesize',
    'eurosize32': '$baseUrl/eurosize32',
    'eurosize33': '$baseUrl/eurosize33',
    'eurosize34': '$baseUrl/eurosize34',
    'eurosize35': '$baseUrl/eurosize35',
    'eurosize36': '$baseUrl/eurosize36',
    'eurosize37': '$baseUrl/eurosize37',
    'eurosize38': '$baseUrl/eurosize38',
    'eurosize39': '$baseUrl/eurosize39',
    'eurosize40': '$baseUrl/eurosize40',
    'eurosize41': '$baseUrl/eurosize41',
    'eurosize42': '$baseUrl/eurosize42',
    'eurosize43': '$baseUrl/eurosize43',
    'eurosize44': '$baseUrl/eurosize44',
    'eurosize45': '$baseUrl/eurosize45',
    'eurosize46': '$baseUrl/eurosize46',
    'eurosize47': '$baseUrl/eurosize47',
    'eurosize48': '$baseUrl/eurosize48',
    'eurosize49': '$baseUrl/eurosize49',
    'banglesize22': '$baseUrl/banglesize22',
    'banglesize24': '$baseUrl/banglesize24',
    'banglesize26': '$baseUrl/banglesize26',
    'banglesize28': '$baseUrl/banglesize28',
    '6_12months': '$baseUrl/6_12months',
    '1_2years': '$baseUrl/1_2years',
    '2_3years': '$baseUrl/2_3years',
    '3_4years': '$baseUrl/3_4years',
    '4_5years': '$baseUrl/4_5years',
    '5_6years': '$baseUrl/5_6years',
    '6_7years': '$baseUrl/6_7years',
    '7_8years': '$baseUrl/7_8years',
    '8_9years': '$baseUrl/8_9years',
    '9_10years': '$baseUrl/9_10years',
    '10_11years': '$baseUrl/10_11years',
    '11_12years': '$baseUrl/11_12years',
    '12_13years': '$baseUrl/12_13years',
    '13_14years': '$baseUrl/13_14years',
    '14_15years': '$baseUrl/14_15years',
    '15_16years': '$baseUrl/15_16years',

    'immediate': '$baseUrl/immediate',
    '1_2weeks': '$baseUrl/1_2weeks',
    '2_4weeks': '$baseUrl/2_4weeks',
    '4_6weeks': '$baseUrl/4_6weeks',
    '6_8weeks': '$baseUrl/6_8weeks',
    '8weeks': '$baseUrl/8weeks',
    'contemporary': '$baseUrl/contemporary',
    'new in accessories': "$baseUrl/new-in-accessories",
    'search': "$baseUrl/search",

    // add more here
  };

  // static String? getApiKeyForSubcategory(String subcategoryName) {
  //   return subcategoryApiMap.entries.firstWhere(
  //         (entry) => entry.key.toLowerCase().trim() == subcategoryName.toLowerCase().trim(),
  //     orElse: () => const MapEntry('', ''),
  //   ).key;
  // }

  static String? getApiKeyForSubcategory(String subcategory) {
    return subcategoryApiMap[subcategory.toLowerCase()];
  }


  ///  Get URL for a given subcategory name
  // static String getApiUrlForSubcategory(String subcategoryName) {
  //   return subcategoryApiMap[subcategoryName.toLowerCase()] ??
  //       "$baseUrl/newin "; // fallback
  // }

  // important message

  // static dynamic getApiUrlForSubcategory(String subcategoryName) {
  //   // Split the input into multiple subcategories
  //   List<String> subcategoryNames = subcategoryName
  //       .toLowerCase()
  //       .split(',')
  //       .map((s) => s.trim())
  //       .where((s) => s.isNotEmpty)
  //       .toList();
  //
  //   // If only one subcategory is selected, return a single URL
  //   if (subcategoryNames.length == 1) {
  //     return subcategoryApiMap[subcategoryNames.first] ?? "$baseUrl/newin"; // Fallback URL
  //   }
  //
  //   // Otherwise, return a list of URLs for multiple subcategories
  //   return subcategoryNames
  //       .map((subcategory) => subcategoryApiMap[subcategory] ?? "$baseUrl/newin") // Fallback URL
  //       .toList();
  // }

  static dynamic getApiUrlForSubcategory(String subcategoryName) {
    // If the input is a full URL, extract the subcategory name
    Uri uri = Uri.parse(subcategoryName);
    String path = uri.pathSegments.last.toLowerCase();  // Extract the last path segment as subcategory

    // Debug: Check the extracted subcategory
    print("Extracted Subcategory: $path");

    // Now check if the subcategory name exists in subcategoryApiMap
    if (subcategoryApiMap.containsKey(path)) {
      print("API URL found for $path: ${subcategoryApiMap[path]}");
      return subcategoryApiMap[path];
    } else {
      print("No API URL found in map for $path, returning fallback URL.");
      return "$baseUrl/newin"; // Fallback URL
    }
  }





  ///  Add this method at the end
  static bool isSubcategory(String subcategory, String keyToCheck) {
    return subcategory.trim().toLowerCase() == keyToCheck.trim().toLowerCase();
  }

  static String getColorFilterUrl(String colorName) {
    final encodedColor = Uri.encodeComponent(colorName.trim());
    return "$baseUrl/color?colorName=$encodedColor";
  }

  // static String getNewInByColor(String color) {
  //   final cleanColor = color.trim().toLowerCase().replaceAll(' ', '%20');
  //   return "$baseUrl/newin?fq=attributes_color:$cleanColor";
  // }

}