import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  Future<void> login(String username, String password) async {
    // Simulate a network call
    await Future.delayed(const Duration(seconds: 2));
    if (username != "user" || password != "password") {
      throw Exception("Invalid credentials");
    }
  }
}
