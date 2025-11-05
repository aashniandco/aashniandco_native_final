import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/login_repository.dart';
import 'login_event.dart';
import 'login_state.dart';


class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginRepository repository;

  LoginBloc(this.repository) : super(LoginInitial()) {
    on<SubmitLoginForm>(_onSubmitLoginForm);
  }

  Future<void> _onSubmitLoginForm(
      SubmitLoginForm event,
      Emitter<LoginState> emit,
      ) async {
    emit(LoginLoading());
    try {
      await repository.login(event.request);
      emit(LoginSuccess());
    } catch (e) {
      emit(LoginFailure(e.toString()));
    }
  }
}
