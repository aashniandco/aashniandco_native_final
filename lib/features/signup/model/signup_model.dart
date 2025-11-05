// model/login_model.dart
class MagentoSignupRequest {
  final String email;
  final String firstname;
  final String lastname;
  final String password;

  MagentoSignupRequest({
    required this.email,
    required this.firstname,
    required this.lastname,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "customer": {
        "email": email,
        "firstname": firstname,
        "lastname": lastname,
      },
      "password": password,
    };
  }
}
