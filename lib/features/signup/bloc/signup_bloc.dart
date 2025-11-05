import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/signup_repository.dart';
import 'signup_event.dart';
import 'signup_state.dart';


class SignupBloc extends Bloc<SignupEvent, SignupState> {
  final SignupRepository repository;

  SignupBloc(this.repository) : super(SignupInitial()) {
    on<SubmitSignupForm>(_onSubmitSignupForm);
  }

  Future<void> _onSubmitSignupForm(
      SubmitSignupForm event,
      Emitter<SignupState> emit,
      ) async {
    emit(SignupLoading());
    try {
      await repository.signup(event.request);
      emit(SignupSuccess());
    } catch (e) {
      emit(SignupFailure(e.toString()));
    }
  }
}
