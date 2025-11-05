


import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import '../../../constants/api_constants.dart';
import '../../newin/model/new_in_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'home_screen_banner_event.dart';
import 'home_screen_banner_state.dart';

const List<String> validDesignerNames = [
  "Ritika Mirchandani",
  "Aditi Gupta",
  "Sue Mue",
  "Elan",
  "Ridhi Mehra",
  "Niti Bothra",
  "Asaga",
  "Elan",
  "The Aarya",
  "Capisvirleo",
  "Masumi Mewawalla",
  "Saundh",
  "Seema Thukral",
  "Miku Kumar",
  "Sabyasachi",










  // Add more designer names here
];


const List<String> validCatNames = [

  "Wedding Collections",
  "Ready To Ship",
  "OCASSION Wear Lehengas",


  // Add more designer names here
];


const List<int> validCatId = [
  5994,
  5492,
  6018,
  1475,


];


class HomeScreenBannerBloc extends Bloc<HomeScreenBannerEvent, HomeScreenBannerState> {
  HomeScreenBannerBloc() : super(HomeScreenBannerLoading()) {
    on<FetchHomeScreenBanner>(_onFetchHomeScreenBanner);
  }

  Future<void> _onFetchHomeScreenBanner(
      FetchHomeScreenBanner event, Emitter<HomeScreenBannerState> emit) async {
    emit(HomeScreenBannerLoading());

    final bannerName = event.bannerName;
    final bannerId = event.id;
    final uri = Uri.parse(ApiConstants.url);


    print("uriHomeScreenBannerBloc>>>$uri");

    print("Banner Bloc ID: $bannerId");

    String queryField;
    dynamic queryValue;

    // ✅ Decide field and value based on valid designer or category
    if (validDesignerNames.contains(bannerName)) {
      queryField = "designer_name";
      queryValue = '"$bannerName"'; // send as quoted string
    } else if (validCatId.contains(bannerId)) {
      queryField = "categories-store-1_id";
      queryValue = bannerId; // send as raw number
    }
    else if (validCatNames.contains(bannerId)) {
      queryField = "categories-store-1_id";
      queryValue = bannerId;
      print("elseif called>>");// send as raw number
    }
    else {
      print("Invalid banner name or id: $bannerName / $bannerId. API call skipped.");
      emit(HomeScreenBannerError("Invalid banner name or id"));
      return;
    }

    print("Valid field: $queryField with value: $queryValue");

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final Map<String, dynamic> body = {
        "queryParams": {
          "query": '$queryField:($queryValue)',
          "params": {
            "fl": "designer_name,actual_price_1,prod_name,prod_en_id,prod_sku,prod_small_img,prod_thumb_img,short_desc,categories-store-1_name,size_name,prod_desc,child_delivery_time",
            "rows": "40000",
            "sort": "prod_en_id desc"
          }
        }
      };

      print("Request body: $body");

      final response = await ioClient.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final secondItem = decoded[1];
        final docs = secondItem['docs'];

        print("doc>>$docs");
        if (docs is List) {
          final products = docs.map((doc) => Product.fromJson(doc)).toList();
          emit(HomeScreenBannerLoaded(products: products));
        } else {
          emit(HomeScreenBannerError("Invalid docs format"));
        }
      } else {
        emit(HomeScreenBannerError("Failed with status: ${response.statusCode}"));
      }
    } on SocketException {
      emit(HomeScreenBannerError("No internet connection"));
    } catch (e) {
      emit(HomeScreenBannerError("Error: $e"));
    }
  }

}
