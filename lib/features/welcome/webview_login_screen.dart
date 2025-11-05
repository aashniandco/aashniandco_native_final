import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/view/auth_screen.dart';

import 'auth_webview.dart';

class WebViewLoginScreen extends StatefulWidget {
  const WebViewLoginScreen({Key? key}) : super(key: key);

  @override
  State<WebViewLoginScreen> createState() => _WebViewLoginScreenState();
}

class _WebViewLoginScreenState extends State<WebViewLoginScreen> {
  InAppWebViewController? _webViewController;

  /// 👇 Add this line
  bool _navigated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("https://stage.aashniandco.com/customer/account/login/"),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED,
          );
        },
        onLoadStop: (controller, url) async {
          if (_navigated) return;

          final currentUrl = url.toString();
          debugPrint("✅ WebView URL: $currentUrl");

          if (currentUrl.contains("/customer/account") ||
              currentUrl.contains("/account/dashboard") ||
              currentUrl == "https://stage.aashniandco.com/") {

            Future.delayed(const Duration(seconds: 1), () async {
              final cookies = await CookieManager().getCookies(
                url: WebUri("https://stage.aashniandco.com"),
              );

              String? frontendCookie;
              for (var cookie in cookies) {
                if (cookie.name == "frontend") {
                  frontendCookie = cookie.value;
                }
              }

              if (frontendCookie != null && !_navigated) {
                _navigated = true;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString("user_token", frontendCookie);

                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AuthScreenWeb(token: frontendCookie),
                    ),
                  );
                }
              }
            });
          }
        },
      ),
    );
  }
}

