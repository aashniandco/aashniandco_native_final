import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/features/newin/model/new_in_model.dart';
import 'package:bloc/bloc.dart';
import 'package:http/io_client.dart';
import 'package:meta/meta.dart';

import 'new_in_theme_state.dart';

part 'new_in_theme_event.dart'; // 👈 connects event


class NewInThemeBloc extends Bloc<NewInThemeEvent, NewInThemeState> {
  NewInThemeBloc() : super(NewInThemeLoading()) {
    on<FetchNewInTheme>(_onFetchNewInTheme);
  }

  Future<void> _onFetchNewInTheme(FetchNewInTheme event,
      Emitter<NewInThemeState> emit,) async {
    emit(NewInThemeLoading());

    final url = Uri.parse(ApiConstants.newIn);

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.get(
          url, headers: {"Connection": "keep-alive"});

      if (response.statusCode == 200) {
        final List<dynamic> responseList = jsonDecode(response.body);
        final Map<String, dynamic> productData = responseList[1];
        final List<dynamic> docs = productData['docs'];

        final List<Product> products =
        docs.map((json) => Product.fromJson(json)).toList();

        emit(NewInThemeLoaded(products: products));
      } else {
        emit(NewInThemeError("Failed to load products"));
      }
    } catch (e) {
      emit(NewInThemeError("Error: $e"));
    }
  }
}
