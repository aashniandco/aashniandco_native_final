import 'package:flutter/material.dart';
class AuthScreenWeb extends StatelessWidget {
  final String? token;
  const AuthScreenWeb({Key? key, this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Auth Screen Web")),
      body: Center(
        child: Text("User token: $token"),
      ),
    );
  }
}
