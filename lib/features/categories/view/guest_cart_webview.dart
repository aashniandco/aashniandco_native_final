import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import '../../auth/view/auth_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class GuestProductWebViewScreen extends StatefulWidget {
//   final String productUrl;
//   final String title;
//
//   const GuestProductWebViewScreen({
//     Key? key,
//     required this.productUrl,
//     required this.title,
//   }) : super(key: key);
//
//   @override
//   State<GuestProductWebViewScreen> createState() =>
//       _GuestProductWebViewScreenState();
// }
//
// class _GuestProductWebViewScreenState extends State<GuestProductWebViewScreen> {
//   late InAppWebViewController _controller;
//   bool _isReadyToShow = false;  // Show WebView
//   bool _isNotFound = false;     // Show Product Not Found screen
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<void> _setGuestCookies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cookiesJson = prefs.getString('guest_cart_cookies');
//       if (cookiesJson == null) return;
//
//       final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//       for (var cookie in savedCookies) {
//         if (cookie is Map<String, dynamic>) {
//           await CookieManager.instance().setCookie(
//             url: WebUri("https://stage.aashniandco.com"),
//             name: cookie['name'],
//             value: cookie['value'],
//             domain: cookie['domain'] ?? 'stage.aashniandco.com',
//             path: cookie['path'] ?? '/',
//             isSecure: cookie['secure'] ?? true,
//             isHttpOnly: cookie['httponly'] ?? false,
//             sameSite: HTTPCookieSameSitePolicy.LAX,
//           );
//         }
//       }
//     } catch (e) {
//       print("Error setting cookies: $e");
//     }
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     if (_isNotFound) return; // No need to hide elements for 404 page
//
//     await _controller.evaluateJavascript(source: """
//       // 1️⃣ Inject CSS to hide sticky/footer/header
//       var style = document.createElement('style');
//       style.type = 'text/css';
//       style.innerHTML = \`
//         #aashnisticky,
//         footer, footer div
//         ${isShippingPage ? ", #header" : ""}
//         { display: none !important; }
//       \`;
//       document.head.appendChild(style);
//
//       // 2️⃣ Function to remove elements by XPath
//       function removeByXPath(xpath) {
//         var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//         var el = result.singleNodeValue;
//         if (el && el.parentNode) el.parentNode.removeChild(el);
//       }
//
//       // 3️⃣ Remove all specified elements via XPath
//       const xpaths = [
//         '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[7]/div[4]',
//         '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[8]',
//         '//*[@id="maincontent"]/div[2]/div/div[3]/h2',
//         '//*[@id="maincontent"]/div[2]/div/div[4]/div',
//         '//*[@id="maincontent"]/div[2]/div/div[5]/h2',
//         '//*[@id="maincontent"]/div[2]/div/div[7]/h2',
//         '//*[@id="maincontent"]/div[2]/div/div[9]',
//         '//*[@id="maincontent"]/div[2]/div/div[10]',
//         '//*[@id="maincontent"]/div[2]/div/div[11]',
//         '//*[@id="maincontent"]/div[2]/div/div[12]',
//         '//*[@id="maincontent"]/div[2]/div/div[15]/div[1]',
//         '//*[@id="pdp_slider_recently_viewed"]/div[1]/div',
//         '//*[@id="pdp_slider_new_arrivals"]/div[1]/div',
//         '/html/body/main/div/div[1]/div/div/ol'
//       ];
//
//       xpaths.forEach(function(xpath) {
//         removeByXPath(xpath);
//       });
//
//       // 4️⃣ Observe dynamically added elements and remove immediately
//       var observer = new MutationObserver(function(mutations) {
//         mutations.forEach(function(mutation) {
//           xpaths.forEach(function(xpath) {
//             removeByXPath(xpath);
//           });
//           var sticky = document.getElementById('aashnisticky');
//           if(sticky && sticky.parentNode) sticky.parentNode.removeChild(sticky);
//         });
//       });
//
//       observer.observe(document.body, { childList: true, subtree: true });
//
//       // Stop observer after 15s
//       setTimeout(function() {
//         observer.disconnect();
//       }, 15000);
//     """);
//
//     print("Web elements hidden, including dynamic ones.");
//   }
//
//   void _handleUrlChange(WebUri? webUri) {
//     if (webUri == null) return;
//     final url = webUri.toString();
//     final is404 = url.contains("&404=1");
//     setState(() {
//       _isNotFound = is404;
//       _isReadyToShow = !is404;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Stack(
//         children: [
//           // WebView
//           if (!_isNotFound)
//             Opacity(
//               opacity: _isReadyToShow ? 1 : 0,
//               child: InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//                 onWebViewCreated: (controller) async {
//                   _controller = controller;
//                   await _setGuestCookies();
//                 },
//                 onLoadStart: (controller, url) => _handleUrlChange(url),
//                 onLoadStop: (controller, url) async {
//                   _handleUrlChange(url);
//                   await _hideWebElements(
//                       isShippingPage: url.toString().contains("#shipping"));
//                 },
//                 onUpdateVisitedHistory: (controller, url, androidIsReload) =>
//                     _handleUrlChange(url),
//                 shouldOverrideUrlLoading: (controller, navigationAction) async =>
//                 NavigationActionPolicy.ALLOW,
//                 initialSettings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   useShouldOverrideUrlLoading: true,
//                 ),
//               ),
//             ),
//
//           // Product Not Found UI
//           if (_isNotFound)
//             Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.error_outline,
//                       size: 60, color: Colors.redAccent),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "Product Not Found",
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87),
//                   ),
//                   const SizedBox(height: 8),
//                   ElevatedButton(
//                     onPressed: () => Navigator.pop(context),
//                     child: const Text("Go Back"),
//                   ),
//                 ],
//               ),
//             ),
//
//           // Loading spinner
//           if (!_isReadyToShow && !_isNotFound)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

// class GuestProductWebViewScreen extends StatefulWidget {
//   final String productUrl;
//   final String title;
//
//
//   const GuestProductWebViewScreen({
//     Key? key,
//     required this.productUrl,
//     required this.title,
//
//   }) : super(key: key);
//
//   @override
//   State<GuestProductWebViewScreen> createState() =>
//       _GuestProductWebViewScreenState();
// }
//
// class _GuestProductWebViewScreenState extends State<GuestProductWebViewScreen> {
//   late InAppWebViewController _controller;
//   bool _isReadyToShow = false;
//   bool _hideSupportBar = false;
//   bool _shouldExitWebView = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _setGuestCookies();
//   }
//
//   /// Fetch Magento CSRF form_key from session.php
//   Future<String?> _fetchFormKey() async {
//     try {
//       final response =
//       await HttpClient().getUrl(Uri.parse('https://stage.aashniandco.com/session.php'))
//           .then((req) => req.close());
//       final body = await response.transform(utf8.decoder).join();
//       if (response.statusCode == 200) {
//         final data = jsonDecode(body);
//         return data['form_key'];
//       }
//     } catch (e) {
//       print("❌ Error fetching form_key: $e");
//     }
//     return null;
//   }
//
//   /// Open shipping page via POST
//   Future<void> _openShippingViaPost() async {
//     final formKey = await _fetchFormKey();
//     if (formKey == null) return print("❌ Cannot proceed without form_key");
//
//     final postData = {
//       'form_key': formKey,
//       // 'quote_id': widget.guestQuoteId,
//     };
//
//     await _controller.loadUrl(
//       urlRequest: URLRequest(
//         url: WebUri('https://stage.aashniandco.com/checkout/#shipping'),
//         method: 'POST',
//         body: utf8.encode(postData.entries.map((e) => '${e.key}=${e.value}').join('&')),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//       ),
//     );
//   }
//
//   /// Set saved guest cookies in WebView
//   Future<void> _setGuestCookies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cookiesJson = prefs.getString('guest_cart_cookies');
//       if (cookiesJson == null) return;
//
//       final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//       for (var cookie in savedCookies) {
//         if (cookie is Map<String, dynamic>) {
//           await CookieManager.instance().setCookie(
//             url: WebUri("https://stage.aashniandco.com"),
//             name: cookie['name'],
//             value: cookie['value'],
//             domain: cookie['domain'] ?? 'stage.aashniandco.com',
//             path: cookie['path'] ?? '/',
//             isSecure: cookie['secure'] ?? true,
//             isHttpOnly: cookie['httponly'] ?? false,
//             sameSite: HTTPCookieSameSitePolicy.LAX,
//           );
//         }
//       }
//     } catch (e) {
//       print("Error setting cookies: $e");
//     }
//   }
//
//   void _updateSupportBarVisibility(String url) {
//     final lowerUrl = url.toLowerCase();
//     final hide = lowerUrl.contains("/checkout/") ||
//         lowerUrl.contains("paypal") ||
//         lowerUrl.contains("stripe") ||
//         lowerUrl.contains("payu") ||
//         lowerUrl.contains("order-success") ||
//         lowerUrl.contains("#/order-success");
//     if (hide != _hideSupportBar) setState(() => _hideSupportBar = hide);
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     await _controller.evaluateJavascript(source: """
//       (function() {
//         var style = document.createElement('style');
//         style.type = 'text/css';
//         style.innerHTML = '#header, #aashnisticky, footer, footer div ${isShippingPage ? ", #header" : ""} { display: none !important; }';
//         document.head.appendChild(style);
//       })();
//     """);
//   }
//
//   Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
//     return Column(
//       children: [
//         IconButton(icon: Icon(icon, size: 30), onPressed: onPressed),
//         Text(text, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
//
//   void _openWhatsApp(String phone) async {
//     final url =
//     Platform.isAndroid ? "whatsapp://send?phone=$phone" : "https://wa.me/$phone";
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     }
//   }
//
//   void _makePhoneCall(String phone) async {
//     final Uri url = Uri.parse("tel:$phone");
//     if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
//   }
//
//   void _sendEmail(String email) async {
//     final Uri url = Uri.parse("mailto:$email");
//     if (await canLaunchUrl(url)) await launchUrl(url);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_shouldExitWebView) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         if (mounted) Navigator.of(context).pop(); // Or navigate to AuthScreen
//       });
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//               onWebViewCreated: (controller) async {
//                 _controller = controller;
//                 await _setGuestCookies();
//                 await _openShippingViaPost();
//
//                 _controller.addJavaScriptHandler(
//                   handlerName: 'continueShopping',
//                   callback: (args) {
//                     setState(() => _shouldExitWebView = true);
//                     return null;
//                   },
//                 );
//               },
//               onLoadStart: (controller, url) async {
//                 _updateSupportBarVisibility(url.toString());
//                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//               },
//               onLoadStop: (controller, url) async {
//                 _updateSupportBarVisibility(url.toString());
//                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//                 setState(() => _isReadyToShow = true);
//               },
//               shouldOverrideUrlLoading: (controller, navAction) async {
//                 _updateSupportBarVisibility(navAction.request.url.toString());
//                 return NavigationActionPolicy.ALLOW;
//               },
//               initialSettings: InAppWebViewSettings(
//                 javaScriptEnabled: true,
//                 useShouldOverrideUrlLoading: true,
//               ),
//             ),
//           ),
//
//           if (!_isReadyToShow) Container(color: Colors.white),
//
//           if (!_hideSupportBar)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("CUSTOMER SUPPORT",
//                         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
//                         _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
//                         _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

//27/09/2025 Webview Guest
class GuestProductWebViewScreen extends StatefulWidget {
  final String productUrl;
  final String title;

  const GuestProductWebViewScreen({
    Key? key,
    required this.productUrl,
    required this.title,
  }) : super(key: key);

  @override
  State<GuestProductWebViewScreen> createState() =>
      _GuestProductWebViewScreenState();
}

class _GuestProductWebViewScreenState extends State<GuestProductWebViewScreen> {
  late InAppWebViewController _controller;
  bool _isReadyToShow = false;
  bool _isProductNotFound = false;
  bool _hideSupportBar = false;
  bool _shouldExitWebView = false; // Flag to navigate after JS call

  @override
  void initState() {
    super.initState();
    _checkIfProductNotFound(widget.productUrl);
  }

  Future<void> _checkIfProductNotFound(String url) async {
    if (url.contains("?404=1") || url.toLowerCase().contains("product-not-found")) {
      setState(() => _isProductNotFound = true);
    } else {
      setState(() => _isProductNotFound = false);
    }
  }

  /// Extract order ID from page title
  String? extractOrderIdFromTitle(String title) {
    final regex = RegExp(r'Order\s+#\s*(\d+)');
    final match = regex.firstMatch(title);
    return match?.group(1);
  }

  /// Extract order ID from URL as fallback
  String? extractOrderIdFromUrl(String url) {
    final regex = RegExp(r'/checkout/onepage/success/(\d+)');
    final match = regex.firstMatch(url);
    return match?.group(1);
  }

  /// Send mobile flag to Magento
  Future<void> _sendMobileFlag(String orderId) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({"orderIncrementId": orderId});

      print("➡️ POST Request:");
      print("Headers: $headers");
      print("Body: $body");

      final response = await http.post(
        Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
        headers: headers,
        body: body,
      );

      print("⬅️ Response:");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");

      print(response.statusCode == 200 && response.body == 'true'
          ? "✅ Order flagged as mobile app"
          : "⚠️ Failed to flag order: ${response.body}");
    } catch (e) {
      print("❌ Error sending mobile flag: $e");
    }
  }

  void _updateSupportBarVisibility(String url) {
    final lowerUrl = url.toLowerCase();
    final hide = lowerUrl.contains("/checkout/") ||
        lowerUrl.contains("paypal") ||
        lowerUrl.contains("stripe") ||
        lowerUrl.contains("payu") ||
        lowerUrl.contains("order-success") ||
        lowerUrl.contains("#/order-success");

    if (hide != _hideSupportBar) setState(() => _hideSupportBar = hide);
  }

  Future<void> _setGuestCookies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cookiesJson = prefs.getString('guest_cart_cookies');
      if (cookiesJson == null) return;

      final List<dynamic> savedCookies = jsonDecode(cookiesJson);
      for (var cookie in savedCookies) {
        if (cookie is Map<String, dynamic>) {
          await CookieManager.instance().setCookie(
            url: WebUri("https://stage.aashniandco.com"),
            name: cookie['name'],
            value: cookie['value'],
            domain: cookie['domain'] ?? 'stage.aashniandco.com',
            path: cookie['path'] ?? '/',
            isSecure: cookie['secure'] ?? true,
            isHttpOnly: cookie['httponly'] ?? false,
            sameSite: HTTPCookieSameSitePolicy.LAX,
          );
        }
      }
    } catch (e) {
      print("Error setting cookies: $e");
    }
  }

  // Future<void> _hideWebElements({required bool isShippingPage}) async {
  //   await _controller.evaluateJavascript(source: """
  //   var style = document.createElement('style');
  //   style.type = 'text/css';
  //   style.innerHTML = \`
  //     #aashnisticky,
  //     footer, footer div
  //     ${isShippingPage ? ", #header" : ""}
  //     { display: none !important; }
  //   \`;
  //   document.head.appendChild(style);
  //
  //   function removeByXPath(xpath) {
  //     var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
  //     var el = result.singleNodeValue;
  //     if (el && el.parentNode) el.parentNode.removeChild(el);
  //   }
  //
  //   const xpaths = [
  //     '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[7]/div[4]',
  //     '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[8]',
  //     '//*[@id="maincontent"]/div[2]/div/div[3]/h2',
  //     '//*[@id="maincontent"]/div[2]/div/div[4]/div',
  //     '//*[@id="maincontent"]/div[2]/div/div[5]/h2',
  //     '//*[@id="maincontent"]/div[2]/div/div[7]/h2',
  //     '//*[@id="maincontent"]/div[2]/div/div[9]',
  //     '//*[@id="maincontent"]/div[2]/div/div[10]',
  //     '//*[@id="maincontent"]/div[2]/div/div[11]',
  //     '//*[@id="maincontent"]/div[2]/div/div[12]',
  //     '//*[@id="maincontent"]/div[2]/div/div[15]/div[1]',
  //     '//*[@id="pdp_slider_recently_viewed"]/div[1]/div',
  //     '//*[@id="pdp_slider_new_arrivals"]/div[1]/div',
  //     '/html/body/main/div/div[1]/div/div/ol'
  //   ];
  //
  //   xpaths.forEach(function(xpath) { removeByXPath(xpath); });
  //
  //   var observer = new MutationObserver(function(mutations) {
  //     mutations.forEach(function(mutation) {
  //       xpaths.forEach(function(xpath) { removeByXPath(xpath); });
  //       var sticky = document.getElementById('aashnisticky');
  //       if(sticky && sticky.parentNode) sticky.parentNode.removeChild(sticky);
  //     });
  //   });
  //
  //   observer.observe(document.body, { childList: true, subtree: true });
  //   setTimeout(function() { observer.disconnect(); }, 15000);
  //   """);
  // }

  Future<void> _hideWebElements({required bool isShippingPage}) async {
    await _controller.evaluateJavascript(source: """
  (function() {
    // Hide header/footer/sticky immediately
    var style = document.createElement('style');
    style.type = 'text/css';
    style.innerHTML = '#header, #aashnisticky, footer, footer div ${isShippingPage ? ", #header" : ""} { display: none !important; }';
    document.head.appendChild(style);

    // Remove elements by XPath
    function removeByXPath(xpath) {
      var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
      var el = result.singleNodeValue;
      if (el && el.parentNode) el.parentNode.removeChild(el);
    }

    const xpaths = [
      '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[7]/div[4]',
      '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[8]',
      '//*[@id="maincontent"]/div[2]/div/div[3]/h2',
      '//*[@id="maincontent"]/div[2]/div/div[4]/div',
      '//*[@id="maincontent"]/div[2]/div/div[5]/h2',
      '//*[@id="maincontent"]/div[2]/div/div[7]/h2',
      '//*[@id="maincontent"]/div[2]/div/div[9]',
      '//*[@id="maincontent"]/div[2]/div/div[10]',
      '//*[@id="maincontent"]/div[2]/div/div[11]',
      '//*[@id="maincontent"]/div[2]/div/div[12]',
      '//*[@id="maincontent"]/div[2]/div/div[15]/div[1]',
      '//*[@id="pdp_slider_recently_viewed"]/div[1]/div',
      '//*[@id="pdp_slider_new_arrivals"]/div[1]/div',
      '/html/body/main/div/div[1]/div/div/ol'
    ];

    xpaths.forEach(function(xpath) { removeByXPath(xpath); });

    // Observe for dynamically loaded elements
    var observer = new MutationObserver(function(mutations) {
      mutations.forEach(function(mutation) {
        xpaths.forEach(function(xpath) { removeByXPath(xpath); });
        var sticky = document.getElementById('aashnisticky');
        if(sticky && sticky.parentNode) sticky.parentNode.removeChild(sticky);
      });
    });

    observer.observe(document.body, { childList: true, subtree: true });
  })();
  """);
  }


  Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, size: 30), onPressed: onPressed),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  void _openWhatsApp(String phone) async {
    String url;
    if (Platform.isAndroid) {
      url = "whatsapp://send?phone=$phone";
    } else {
      url = "https://wa.me/$phone";
    }
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _makePhoneCall(String phone) async {
    final Uri url = Uri.parse("tel:$phone");
    if (await canLaunchUrl(url)) await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void _sendEmail(String email) async {
    final Uri url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) await launchUrl(url);
  }

  @override
  // Widget build(BuildContext context) {
  //   // 1️⃣ Handle exit to AuthScreen
  //   if (_shouldExitWebView) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       if (mounted) {
  //         Navigator.of(context).pushReplacement(
  //           MaterialPageRoute(builder: (_) => const AuthScreen()),
  //         );
  //       }
  //     });
  //   }
  //
  //   // 2️⃣ Show Product Not Found
  //   if (_isProductNotFound) {
  //     return Scaffold(
  //       appBar: AppBar(title: Text(widget.title)),
  //       body: Center(
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.center,
  //           children: const [
  //             Icon(Icons.error_outline, size: 80, color: Colors.red),
  //             SizedBox(height: 16),
  //             Text("Product Not Found", style: TextStyle(fontSize: 20)),
  //             SizedBox(height: 8),
  //             Text("404", style: TextStyle(fontSize: 16, color: Colors.grey)),
  //           ],
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return Scaffold(
  //     appBar: AppBar(title: Text(widget.title)),
  //     body: Stack(
  //       children: [
  //         Positioned.fill(
  //           child: Padding(
  //             padding: EdgeInsets.only(bottom: _hideSupportBar ? 0 : 90),
  //             child: InAppWebView(
  //               initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
  //               onWebViewCreated: (controller) async {
  //                 _controller = controller;
  //                 await _setGuestCookies();
  //
  //                 // ✅ JS handler for Continue Shopping
  //                 _controller.addJavaScriptHandler(
  //                   handlerName: 'continueShopping',
  //                   callback: (args) {
  //                     setState(() => _shouldExitWebView = true);
  //                     return null;
  //                   },
  //                 );
  //               },
  //               onLoadStart: (controller, url) async {
  //                 _updateSupportBarVisibility(url.toString());
  //                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
  //               },
  //               onLoadStop: (controller, url) async {
  //                 _updateSupportBarVisibility(url.toString());
  //                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
  //                 setState(() => _isReadyToShow = true);
  //               },
  //               shouldOverrideUrlLoading: (controller, navAction) async {
  //                 _updateSupportBarVisibility(navAction.request.url.toString());
  //                 return NavigationActionPolicy.ALLOW;
  //               },
  //               initialSettings: InAppWebViewSettings(
  //                 javaScriptEnabled: true,
  //                 useShouldOverrideUrlLoading: true,
  //               ),
  //             ),
  //           ),
  //         ),
  //         if (!_isReadyToShow) const Center(child: CircularProgressIndicator()),
  //         if (!_hideSupportBar)
  //           Positioned(
  //             bottom: 0,
  //             left: 0,
  //             right: 0,
  //             child: Container(
  //               color: Colors.white,
  //               padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
  //                   const SizedBox(height: 10),
  //                   Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                     children: [
  //                       _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
  //                       _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
  //                       _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
  //                     ],
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //       ],
  //     ),
  //   );
  // }

  Widget build(BuildContext context) {
    // Handle exit to AuthScreen
    if (_shouldExitWebView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthScreen()),
          );
        }
      });
    }

    // // Show Product Not Found
    // if (_isProductNotFound) {
    //   return Scaffold(
    //     appBar: AppBar(title: Text(widget.title)),
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: const [
    //           Icon(Icons.error_outline, size: 80, color: Colors.red),
    //           SizedBox(height: 16),
    //           Text("Product Not Found", style: TextStyle(fontSize: 20)),
    //           SizedBox(height: 8),
    //           Text("404", style: TextStyle(fontSize: 16, color: Colors.grey)),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: _hideSupportBar ? 0 : 90),
              child: InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
                onWebViewCreated: (controller) async {
                  _controller = controller;
                  await _setGuestCookies();

                  // JS handler for Continue Shopping
                  _controller.addJavaScriptHandler(
                    handlerName: 'continueShopping',
                    callback: (args) {
                      setState(() => _shouldExitWebView = true);
                      return null;
                    },
                  );
                },
                onLoadStart: (controller, url) async {
                  _updateSupportBarVisibility(url.toString());

                  // Hide header/footer/sticky immediately using JS
                  await controller.evaluateJavascript(source: """
                (function() {
                  document.documentElement.style.visibility = 'hidden';
                  var style = document.createElement('style');
                  style.type = 'text/css';
                  style.innerHTML = '#header, #aashnisticky, footer, footer div { display: none !important; }';
                  document.head.appendChild(style);
                })();
              """);

                  await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
                },
                onLoadStop: (controller, url) async {
                  _updateSupportBarVisibility(url.toString());
                  await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));

                  // Reveal page now that elements are hidden
                  await controller.evaluateJavascript(source: """
                document.documentElement.style.visibility = 'visible';
              """);

                  setState(() => _isReadyToShow = true);

                  // MutationObserver for popups, order success, etc.
                  await controller.evaluateJavascript(source: """
                (function() {
                  var observer = new MutationObserver(function(mutations) {
                    mutations.forEach(function(mutation) {
                      var popupXPath = '/html/body/div[2]/div/div[1]/div/div/div[3]';
                      var result = document.evaluate(popupXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
                      var popup = result.singleNodeValue;
                      if (popup) {
                        window.flutter_inappwebview.callHandler('addToCartDetected');
                        observer.disconnect();
                      }
                    });
                  });
                  observer.observe(document.body, { childList: true, subtree: true });
                })();
              """);

                  // Detect order success and send mobile flag
                  if (url != null &&
                      (url.toString().contains("/checkout/onepage/success") ||
                          url.toString().contains("#/order-success"))) {
                    final title = await controller.getTitle();
                    String? orderId = extractOrderIdFromTitle(title ?? '');
                    orderId ??= extractOrderIdFromUrl(url.toString());
                    if (orderId != null) await _sendMobileFlag(orderId);

                    // Inject Continue Shopping button handler
                    await controller.evaluateJavascript(source: """
                  document.querySelectorAll('a, button').forEach(function(el){
                    if(el.innerText.includes('Continue Shopping')){
                      el.onclick = function(){
                        window.flutter_inappwebview.callHandler('continueShopping');
                        return false;
                      }
                    }
                  });
                """);
                  }
                },
                shouldOverrideUrlLoading: (controller, navAction) async {
                  _updateSupportBarVisibility(navAction.request.url.toString());
                  return NavigationActionPolicy.ALLOW;
                },
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                ),
              ),
            ),
          ),

          // Full-screen overlay while hiding elements
          if (!_isReadyToShow) Container(color: Colors.white),

          // Support bar
          if (!_hideSupportBar)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
                        _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
                        _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

//
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: _hideSupportBar ? 0 : 90),
//               child: InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//                 onWebViewCreated: (controller) async {
//                   _controller = controller;
//                   await _setGuestCookies();
//
//                   // _controller.addJavaScriptHandler(
//                   //   handlerName: 'addToCartDetected',
//                   //   callback: (args) {
//                   //     // Navigate to cart page in Flutter
//                   //     _controller.loadUrl(urlRequest: URLRequest(url: WebUri('https://stage.aashniandco.com/checkout/cart/')));
//                   //     return null;
//                   //   },
//                   // );
//
//
//                   // JS handler for Continue Shopping
//                   _controller.addJavaScriptHandler(
//                     handlerName: 'continueShopping',
//                     callback: (args) {
//                       setState(() => _shouldExitWebView = true);
//                       return null;
//                     },
//                   );
//                 },
//                 onLoadStart: (controller, url) async {
//                   _updateSupportBarVisibility(url.toString());
//
//                   await controller.evaluateJavascript(source: """
//     (function() {
//       var style = document.createElement('style');
//       style.type = 'text/css';
//       style.innerHTML = '#aashnisticky, footer, footer div { display: none !important; }';
//       document.head.appendChild(style);
//     })();
//   """);
//
//                   await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//                 },
//                 onLoadStop: (controller, url) async {
//                   _updateSupportBarVisibility(url.toString());
//                   await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//                   setState(() => _isReadyToShow = true);
//
//                   await controller.evaluateJavascript(source: """
// (function() {
//   var observer = new MutationObserver(function(mutations) {
//     mutations.forEach(function(mutation) {
//       var popupXPath = '/html/body/div[2]/div/div[1]/div/div/div[3]';
//       var result = document.evaluate(popupXPath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//       var popup = result.singleNodeValue;
//       if (popup) {
//         // Notify Flutter to navigate
//         window.flutter_inappwebview.callHandler('addToCartDetected');
//         observer.disconnect();
//       }
//     });
//   });
//   observer.observe(document.body, { childList: true, subtree: true });
// })();
// """);
//
//
//                   // ✅ Detect order success and flag mobile order
//                   if (url != null &&
//                       (url.toString().contains("/checkout/onepage/success") ||
//                           url.toString().contains("#/order-success"))) {
//                     print("Order success page detected.");
//
//                     // Try to extract order ID from title
//                     final title = await controller.getTitle();
//                     String? orderId = extractOrderIdFromTitle(title ?? '');
//
//                     // Fallback to URL
//                     orderId ??= extractOrderIdFromUrl(url.toString());
//
//                     if (orderId != null) {
//                       print("Extracted Order ID: $orderId");
//                       await _sendMobileFlag(orderId);
//                     } else {
//                       print("❌ Failed to extract order ID. Title: $title, URL: $url");
//                     }
//
//                     // Inject continue shopping button handler
//                     await controller.evaluateJavascript(source: """
//                     document.querySelectorAll('a, button').forEach(function(el){
//                       if(el.innerText.includes('Continue Shopping')){
//                         el.onclick = function(){
//                           window.flutter_inappwebview.callHandler('continueShopping');
//                           return false;
//                         }
//                       }
//                     });
//                   """);
//                     print("Continue Shopping button handler injected.");
//                   }
//                 },
//                 shouldOverrideUrlLoading: (controller, navAction) async {
//                   _updateSupportBarVisibility(navAction.request.url.toString());
//                   return NavigationActionPolicy.ALLOW;
//                 },
//                 initialSettings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   useShouldOverrideUrlLoading: true,
//                 ),
//               ),
//             ),
//           ),
//           if (!_isReadyToShow) const Center(child: CircularProgressIndicator()),
//           if (!_hideSupportBar)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
//                         _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
//                         _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
  }
}

//imp
// class GuestProductWebViewScreen extends StatefulWidget {
//   final String productUrl;
//   final String title;
//
//   const GuestProductWebViewScreen({
//     Key? key,
//     required this.productUrl,
//     required this.title,
//   }) : super(key: key);
//
//   @override
//   State<GuestProductWebViewScreen> createState() =>
//       _GuestProductWebViewScreenState();
// }
//
// class _GuestProductWebViewScreenState extends State<GuestProductWebViewScreen> {
//   late InAppWebViewController _controller;
//   bool _isReadyToShow = false;
//   bool _isProductNotFound = false;// Only true after hiding elements
//   bool _hideSupportBar = false;
//   @override
//   void initState() {
//     super.initState();
//     _checkIfProductNotFound(widget.productUrl);
//   }
//
//   void _updateSupportBarVisibility(String url) {
//     final lowerUrl = url.toLowerCase();
//     final hide = lowerUrl.contains("/checkout/") ||
//         lowerUrl.contains("paypal") ||
//         lowerUrl.contains("stripe") ||
//         lowerUrl.contains("payu") ||
//         lowerUrl.contains("order-success") ||
//         lowerUrl.contains("#/order-success");
//
//     if (hide != _hideSupportBar) {
//       setState(() => _hideSupportBar = hide);
//     }
//   }
//
//   Future<void> _checkIfProductNotFound(String url) async {
//     // Magento 404 or generic product-not-found URLs
//     if (url.contains("?404=1") || url.toLowerCase().contains("product-not-found")) {
//       setState(() => _isProductNotFound = true);
//     } else {
//       setState(() => _isProductNotFound = false);
//     }
//   }
//   Future<void> _setGuestCookies() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final cookiesJson = prefs.getString('guest_cart_cookies');
//       if (cookiesJson == null) return;
//
//       final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//       for (var cookie in savedCookies) {
//         if (cookie is Map<String, dynamic>) {
//           await CookieManager.instance().setCookie(
//             url: WebUri("https://stage.aashniandco.com"),
//             name: cookie['name'],
//             value: cookie['value'],
//             domain: cookie['domain'] ?? 'stage.aashniandco.com',
//             path: cookie['path'] ?? '/',
//             isSecure: cookie['secure'] ?? true,
//             isHttpOnly: cookie['httponly'] ?? false,
//             sameSite: HTTPCookieSameSitePolicy.LAX,
//           );
//         }
//       }
//     } catch (e) {
//       print("Error setting cookies: $e");
//     }
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     await _controller.evaluateJavascript(source: """
//     // 1️⃣ Inject CSS to hide sticky/footer/header instantly
//     var style = document.createElement('style');
//     style.type = 'text/css';
//     style.innerHTML = \`
//       #aashnisticky,
//       footer, footer div
//       ${isShippingPage ? ", #header" : ""}
//       { display: none !important; }
//     \`;
//     document.head.appendChild(style);
//
//     // 2️⃣ Function to remove elements by XPath
//     function removeByXPath(xpath) {
//       var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//       var el = result.singleNodeValue;
//       if (el && el.parentNode) el.parentNode.removeChild(el);
//     }
//
//     // 3️⃣ Remove all specified elements via XPath
//     const xpaths = [
//       '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[7]/div[4]',
//       '//*[@id="maincontent"]/div[2]/div/div[1]/div[2]/div/div[8]',
//       '//*[@id="maincontent"]/div[2]/div/div[3]/h2',
//       '//*[@id="maincontent"]/div[2]/div/div[4]/div',
//       '//*[@id="maincontent"]/div[2]/div/div[5]/h2',
//       '//*[@id="maincontent"]/div[2]/div/div[7]/h2',
//       '//*[@id="maincontent"]/div[2]/div/div[9]',
//       '//*[@id="maincontent"]/div[2]/div/div[10]',
//       '//*[@id="maincontent"]/div[2]/div/div[11]',
//       '//*[@id="maincontent"]/div[2]/div/div[12]',
//       '//*[@id="maincontent"]/div[2]/div/div[15]/div[1]',
//       '//*[@id="pdp_slider_recently_viewed"]/div[1]/div',
//       '//*[@id="pdp_slider_new_arrivals"]/div[1]/div',
//       '/html/body/main/div/div[1]/div/div/ol'   // ✅ Newly added
//     ];
//
//     xpaths.forEach(function(xpath) {
//       removeByXPath(xpath);
//     });
//
//     // 4️⃣ Observe dynamically added elements and remove them immediately
//     var observer = new MutationObserver(function(mutations) {
//       mutations.forEach(function(mutation) {
//         xpaths.forEach(function(xpath) {
//           removeByXPath(xpath);
//         });
//         var sticky = document.getElementById('aashnisticky');
//         if(sticky && sticky.parentNode) sticky.parentNode.removeChild(sticky);
//       });
//     });
//
//     observer.observe(document.body, { childList: true, subtree: true });
//
//     // Stop observer after 15s to reduce overhead
//     setTimeout(function() {
//       observer.disconnect();
//     }, 15000);
//   """);
//
//     print("All specified web elements hidden, including dynamically added ones.");
//   }
//
//
//
//   Widget _supportButton(IconData icon, String text, VoidCallback onPressed) {
//     return Column(
//       children: [
//         IconButton(
//           icon: Icon(icon, size: 30),
//           onPressed: onPressed,
//         ),
//         Text(text, style: const TextStyle(fontSize: 12)),
//       ],
//     );
//   }
//
//   void _openWhatsApp(String phone) async {
//     String url;
//
//
//     if (Platform.isAndroid) {
//       url = "whatsapp://send?phone=$phone";
//     } else if (Platform.isIOS) {
//       print("whatsapp IOS clicked>>");
//       url = "https://wa.me/$phone";
//     } else {
//       url = "https://wa.me/$phone";
//     }
//
//
//     // Ensure launchUrl is called
//     if (await canLaunchUrl(Uri.parse(url))) {
//       await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
//     } else {
//       print("Could not launch $url");
//     }
//   }
//
//
//
//
//   void _makePhoneCall(String phone) async {
//     final Uri url = Uri.parse("tel:$phone");
//
//
//     if (await canLaunchUrl(url)) {
//       print("Launching dialer...");
//       await launchUrl(url, mode: LaunchMode.externalApplication);
//     } else {
//       print("Error: Cannot launch dialer for $phone");
//     }
//   }
//
//
//
//
//   void _sendEmail(String email) async {
//     final Uri url = Uri.parse("mailto:$email"); // ✅ Correct scheme
//
//
//     if (await canLaunchUrl(url)) {
//       await launchUrl(url);
//     } else {
//       print("Could not launch email for $email");
//     }
//   }
//
//   @override
//   @override
//   @override
//   Widget build(BuildContext context) {
//     if (_isProductNotFound) {
//       return Scaffold(
//         appBar: AppBar(title: Text(widget.title)),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: const [
//               Icon(Icons.error_outline, size: 80, color: Colors.red),
//               SizedBox(height: 16),
//               Text("Product Not Found", style: TextStyle(fontSize: 20)),
//               SizedBox(height: 8),
//               Text("404", style: TextStyle(fontSize: 16, color: Colors.grey)),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       appBar: AppBar(title: Text(widget.title)),
//       body: Stack(
//         children: [
//           // WebView with bottom padding to avoid overlapping support bar
//           Positioned.fill(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: _hideSupportBar ? 0 : 90),
//               child: InAppWebView(
//                 initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//                 onWebViewCreated: (controller) async {
//                   _controller = controller;
//                   await _setGuestCookies();
//
//                   // Add JavaScript handler for continueShopping
//                   _controller.addJavaScriptHandler(
//                     handlerName: 'continueShopping',
//                     callback: (args) {
//                       print("JavaScript handler 'continueShopping' called.");
//                       Navigator.pushReplacement(
//                         context,
//                         MaterialPageRoute(builder: (_) => const AuthScreen()),
//                       );
//                     },
//                   );
//                 },
//                 onLoadStart: (controller, url) async {
//                   _updateSupportBarVisibility(url.toString());
//                   await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//                 },
//                 onLoadStop: (controller, url) async {
//                   _updateSupportBarVisibility(url.toString());
//                   await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//                   setState(() => _isReadyToShow = true);
//                 },
//                 shouldOverrideUrlLoading: (controller, navigationAction) async {
//                   final requestedUrl = navigationAction.request.url.toString();
//                   _updateSupportBarVisibility(requestedUrl);
//                   return NavigationActionPolicy.ALLOW;
//                 },
//                 initialSettings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   useShouldOverrideUrlLoading: true,
//                 ),
//               ),
//             ),
//           ),
//
//           // Loading indicator
//           if (!_isReadyToShow) const Center(child: CircularProgressIndicator()),
//
//           // Bottom Customer Support Bar (conditionally hidden)
//           if (!_hideSupportBar)
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: Container(
//                 color: Colors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Text(
//                       "CUSTOMER SUPPORT",
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 10),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
//                         _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
//                         _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//
// // Widget build(BuildContext context) {
//   //   if (_isProductNotFound) {
//   //     return Scaffold(
//   //       appBar: AppBar(title: Text(widget.title)),
//   //       body: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: const [
//   //             Icon(Icons.error_outline, size: 80, color: Colors.red),
//   //             SizedBox(height: 16),
//   //             Text("Product Not Found", style: TextStyle(fontSize: 20)),
//   //             SizedBox(height: 8),
//   //             Text("404", style: TextStyle(fontSize: 16, color: Colors.grey)),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //
//   //   return Scaffold(
//   //     appBar: AppBar(title: Text(widget.title)),
//   //     body: Stack(
//   //       children: [
//   //         // WebView in background
//   //         Positioned.fill(
//   //           child: Opacity(
//   //             opacity: _isReadyToShow ? 1 : 0,
//   //             child: InAppWebView(
//   //               initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//   //               onWebViewCreated: (controller) async {
//   //                 _controller = controller;
//   //                 await _setGuestCookies();
//   //               },
//   //               onLoadStart: (controller, url) async {
//   //                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//   //               },
//   //               onLoadStop: (controller, url) async {
//   //                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//   //                 setState(() => _isReadyToShow = true);
//   //               },
//   //               shouldOverrideUrlLoading: (controller, navigationAction) async {
//   //                 return NavigationActionPolicy.ALLOW;
//   //               },
//   //               initialSettings: InAppWebViewSettings(
//   //                 javaScriptEnabled: true,
//   //                 useShouldOverrideUrlLoading: true,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //
//   //         // Loading indicator
//   //         if (!_isReadyToShow)
//   //           const Center(child: CircularProgressIndicator()),
//   //
//   //         // Customer Support Bar at bottom
//   //         Positioned(
//   //           bottom: 0,
//   //           left: 0,
//   //           right: 0,
//   //           child: Container(
//   //             color: Colors.white,
//   //             padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
//   //             child: Column(
//   //               mainAxisSize: MainAxisSize.min, // Important: avoid taking full height
//   //               children: [
//   //                 const Text(
//   //                   "CUSTOMER SUPPORT",
//   //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//   //                 ),
//   //                 const SizedBox(height: 10),
//   //                 Row(
//   //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //                   children: [
//   //                     _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
//   //                     _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
//   //                     _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
//   //                   ],
//   //                 ),
//   //               ],
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//
// // Widget build(BuildContext context) {
//   //   if (_isProductNotFound) {
//   //     return Scaffold(
//   //       appBar: AppBar(title: Text(widget.title)),
//   //       body: Center(
//   //         child: Column(
//   //           mainAxisAlignment: MainAxisAlignment.center,
//   //           children: const [
//   //             Icon(Icons.error_outline, size: 80, color: Colors.red),
//   //             SizedBox(height: 16),
//   //             Text("Product Not Found", style: TextStyle(fontSize: 20)),
//   //             SizedBox(height: 8),
//   //             Text("404", style: TextStyle(fontSize: 16, color: Colors.grey)),
//   //           ],
//   //         ),
//   //       ),
//   //     );
//   //   }
//   //   return Scaffold(
//   //     appBar: AppBar(title: Text(widget.title)),
//   //     body: Stack(
//   //       children: [
//   //         // WebView is invisible until _isReadyToShow = true
//   //         Opacity(
//   //           opacity: _isReadyToShow ? 1 : 0,
//   //           child: InAppWebView(
//   //             initialUrlRequest: URLRequest(url: WebUri(widget.productUrl)),
//   //             onWebViewCreated: (controller) async {
//   //               _controller = controller;
//   //
//   //               // Set cookies first
//   //               await _setGuestCookies();
//   //             },
//   //             onLoadStart: (controller, url) async {
//   //               // Page started loading → hide elements ASAP
//   //               await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//   //             },
//   //             onLoadStop: (controller, url) async {
//   //               // Page finished → mark WebView ready to show
//   //               await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//   //               setState(() => _isReadyToShow = true);
//   //             },
//   //             shouldOverrideUrlLoading: (controller, navigationAction) async {
//   //               return NavigationActionPolicy.ALLOW;
//   //             },
//   //             initialSettings: InAppWebViewSettings(
//   //               javaScriptEnabled: true,
//   //               useShouldOverrideUrlLoading: true,
//   //             ),
//   //           ),
//   //         ),
//   //         // Loading spinner while WebView is hidden
//   //         if (!_isReadyToShow) const Center(child: CircularProgressIndicator()),
//   //
//   //         Container(
//   //           padding: const EdgeInsets.symmetric(vertical: 10),
//   //           color: Colors.white,
//   //           child: Column(
//   //             children: [
//   //               const Text("CUSTOMER SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//   //               const SizedBox(height: 10),
//   //               Row(
//   //                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//   //                 children: [
//   //                   _supportButton(Icons.chat, "Chat With Us", () => _openWhatsApp("+918375036648")),
//   //                   _supportButton(Icons.phone, "+91 8375036648", () => _makePhoneCall("+918375036648")),
//   //                   _supportButton(Icons.email, "Mail us", () => _sendEmail("customercare@aashniandco.com")),
//   //                 ],
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
// }
