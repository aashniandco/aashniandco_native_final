class MagentoLoginRequest {
  final String username;
  final String password;

  MagentoLoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      "username": username,
      "password": password,
    };
  }
}
