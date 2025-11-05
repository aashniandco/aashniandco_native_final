  import 'dart:async';
  import 'dart:convert';
  import 'dart:io';

  import 'package:aashniandco/constants/api_constants.dart';
  import 'package:aashniandco/features/newin/model/new_in_model.dart';
  import 'package:bloc/bloc.dart';
  import 'package:http/io_client.dart';
  import 'package:meta/meta.dart';

  import 'new_in_color_state.dart';
  import 'new_in_gender_state.dart';
  import 'new_in_size_state.dart';
import 'new_in_theme_state.dart';

  part 'new_in_size_event.dart'; // 👈 connects event


  class NewInSizeBloc extends Bloc<NewInSizeEvent, NewInSizeState> {
    NewInSizeBloc() : super(NewInSizeLoading()) {
      on<FetchProductsBySize>(_onFetchProductsBySize);
    }

    Future<void> _onFetchProductsBySize(
        FetchProductsBySize event,
        Emitter<NewInSizeState> emit,
        ) async {
      emit(NewInSizeLoading());

      final apiUrl = 'https://stage.aashniandco.com/rest/V1/solr/color?colorName=${Uri.encodeComponent(event.size)}';


      try {
        HttpClient httpClient = HttpClient();
        httpClient.badCertificateCallback = (cert, host, port) => true;
        IOClient ioClient = IOClient(httpClient);

        final response = await ioClient.get(Uri.parse(apiUrl), headers: {"Connection": "keep-alive"});

        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final List<dynamic> productsData = jsonData[1]['docs'] ?? [];
          final List<Product> products = productsData.map((json) => Product.fromJson(json)).toList();

          emit(NewInSizeLoaded(products: products));
        } else {
          emit(NewInSizeError('Failed to load products: ${response.statusCode}'));
        }
      } catch (e) {
        emit(NewInSizeError('Error: $e'));
      }
    }
  }
