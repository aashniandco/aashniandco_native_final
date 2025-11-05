

abstract class NewInProductsEvent {}

class FetchProductsEvent extends NewInProductsEvent {

}

// Events

class FetchProductsByPostEvent extends NewInProductsEvent {}



class FetchProducts extends NewInProductsEvent {}
// class FetchProductsEvent extends NewInProductsEvent {
//   final List<String>? themes;  // List of themes
//   final String? categoryId;    // Category ID
//
//   FetchProductsEvent({this.themes, this.categoryId});
// }


enum SortOrder { lowToHigh, highToLow,latest }

class SortProductsEvent extends NewInProductsEvent {
  final SortOrder sortOrder;
  SortProductsEvent(this.sortOrder);
}

// class FetchProductsByGenderEvent extends NewInProductsEvent {
//   final String genderName;
//
//   FetchProductsByGenderEvent(this.genderName);
// }

class FetchProductsByGendersEvent extends NewInProductsEvent {
  final List<String> genders;
  FetchProductsByGendersEvent(this.genders);
}

class FetchProductsByThemesEvent extends NewInProductsEvent {
  final List<String> themes;
  FetchProductsByThemesEvent(this.themes);
}

class FetchProductsByColorsEvent extends NewInProductsEvent {
  final List<String> colors;
  FetchProductsByColorsEvent(this.colors);
}

class FetchProductsBySizesEvent extends NewInProductsEvent {
  final List<String> sizes;
  FetchProductsBySizesEvent(this.sizes);
}

class FetchProductsByShipsinEvent extends NewInProductsEvent {
  final List<String> shipsin;
  FetchProductsByShipsinEvent(this.shipsin);
}

class FetchProductsByAcoEditEvent extends NewInProductsEvent {
  final List<String> acoedit;
  FetchProductsByAcoEditEvent(this.acoedit);
}

class FetchProductsByOccassionsEvent extends NewInProductsEvent {
  final List<String> occassions;
  FetchProductsByOccassionsEvent(this.occassions);
}

class FetchProductsByPricesEvent extends NewInProductsEvent {
  final List<String> price;
  FetchProductsByPricesEvent(this.price);
}

class FetchProductsByCategoryFilterEvent extends NewInProductsEvent {
  final List<String> cat_filter;
  FetchProductsByCategoryFilterEvent(this.cat_filter);
}

class FetchProductsBySubcategoryFilterEvent extends NewInProductsEvent {
  final List<String> subcategories;

  // FetchProductsBySubcategoryFilterEvent(this.subcategories);
  FetchProductsBySubcategoryFilterEvent(dynamic subcategory)
      : subcategories = subcategory is List<String> ? subcategory : [subcategory];
}

