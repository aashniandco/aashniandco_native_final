import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';

final authViewModelProvider = StateNotifierProvider<AuthViewModel, AuthState>(
  (ref) => AuthViewModel(ref.read(authRepositoryProvider)),
);

class AuthState {
  final bool isLoading;

  const AuthState({this.isLoading = false});
}

class AuthViewModel extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository) : super(const AuthState());

  Future<void> login(String username, String password) async {
    state = const AuthState(isLoading: true);
    try {
      await _authRepository.login(username, password);
      // Handle success
    } catch (e) {
      // Handle error
    } finally {
      state = const AuthState(isLoading: false);
    }
  }
}
