import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
      LoginSubmitted event, Emitter<LoginState> emit) async {
    emit(LoginLoading());

    try {
      final response = await http.post(
        Uri.parse('https://reqres.in/api/login'),
        body: {
          'email': event.email,
          'password': event.password,
        },
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        emit(LoginSuccess(token));
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        emit(LoginFailure(error));
      }
    } catch (e) {
      emit(LoginFailure('Failed to connect to server'));
    }
  }
}
