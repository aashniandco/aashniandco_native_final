  import 'dart:async';
  import 'dart:convert';
  import 'dart:io';

  import 'package:aashniandco/constants/api_constants.dart';
  import 'package:aashniandco/features/newin/model/new_in_model.dart';
  import 'package:bloc/bloc.dart';
  import 'package:http/io_client.dart';

  import 'new_in_wc_lehengas_event.dart';
  import 'new_in_wc_lehengas_state.dart';

  // class NewInWcLehengasBloc extends Bloc<NewInWcLehengasEvent, NewInWcLehengasState> {
  //   NewInWcLehengasBloc() : super(NewInWcLehengasLoading()) {
  //     on<FetchNewInWcLehengas>(_onFetchNewInWcLehengas);
  //   }
  //
  //   Future<void> _onFetchNewInWcLehengas(
  //       FetchNewInWcLehengas event,
  //       Emitter<NewInWcLehengasState> emit,
  //       ) async {
  //     emit(NewInWcLehengasLoading());
  //
  //     final url = Uri.parse(ApiConstants.getApiUrlForSubcategory("lehengas"));
  //
  //     try {
  //       HttpClient httpClient = HttpClient();
  //       httpClient.badCertificateCallback = (cert, host, port) => true;
  //       IOClient ioClient = IOClient(httpClient);
  //
  //       print("Fetching Lehengas from URL: $url");
  //
  //       final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});
  // print ("re>>$response");
  //       print("Response Body: ${response.body}");
  //       if (response.statusCode == 200) {
  //         final List<dynamic> responseList = jsonDecode(response.body);
  //         final Map<String, dynamic> productData = responseList[1];
  //         final List<dynamic> docs = productData['docs'];
  //
  //         final List<Product> products = docs.map((json) => Product.fromJson(json)).toList();
  //
  //         emit(NewInWcLehengasLoaded(products: products));
  //       } else {
  //         emit(NewInWcLehengasError("Failed to load lehengas"));
  //       }
  //     } catch (e) {
  //       emit(NewInWcLehengasError("Error: $e"));
  //     }
  //   }
  // }
