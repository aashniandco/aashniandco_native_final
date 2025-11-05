// new_in_accessories_bloc.dart

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:aashniandco/constants/api_constants.dart';
import 'package:aashniandco/features/newin/model/new_in_model.dart';
import 'package:bloc/bloc.dart';
import 'package:http/io_client.dart';

import 'new_in_accessories_event.dart'; // ✅ Add this import
import 'new_in_accessories_state.dart';

class NewInAccessoriesBloc
    extends Bloc<NewInAccessoriesEvent, NewInAccessoriesState> {
  NewInAccessoriesBloc() : super(NewInAccessoriesLoading()) {
    on<FetchNewInAccessories>(_onFetchNewInAccessories);
  }

  Future<void> _onFetchNewInAccessories(
      FetchNewInAccessories event,
      Emitter<NewInAccessoriesState> emit,
      ) async {
    emit(NewInAccessoriesLoading());

    final url = Uri.parse(ApiConstants.newInAccessories);

    try {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => true;
      IOClient ioClient = IOClient(httpClient);

      final response = await ioClient.get(url, headers: {"Connection": "keep-alive"});

      if (response.statusCode == 200) {
        final List<dynamic> responseList = jsonDecode(response.body);
        final Map<String, dynamic> productData = responseList[1];
        final List<dynamic> docs = productData['docs'];

        final List<Product> products = docs.map((json) => Product.fromJson(json)).toList();

        emit(NewInAccessoriesLoaded(products: products));
      } else {
        emit(NewInAccessoriesError("Failed to load products"));
      }
    } catch (e) {
      emit(NewInAccessoriesError("Error: $e"));
    }
  }
}
