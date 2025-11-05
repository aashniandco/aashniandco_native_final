
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // <--- New Import
// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final String userEmail;
//   final String userPassword;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     this.userEmail = 'ram11@gmail.com', // default email
//     this.userPassword = 'mah@12345678',    // default password
//   }) : super(key: key);
//
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   InAppWebViewController? _webViewController;
//   double _progress = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () async {
//             if (_webViewController != null) {
//               bool? canGoBack = await _webViewController!.canGoBack();
//               if (canGoBack == true) {
//                 _webViewController!.goBack();
//               } else {
//                 Navigator.of(context).pop();
//               }
//             } else {
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 javaScriptEnabled: true,
//                 useOnDownloadStart: true,
//                 allowFileAccessFromFileURLs: true,
//                 allowUniversalAccessFromFileURLs: true,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 useHybridComposition: true,
//                 thirdPartyCookiesEnabled: true,
//                 safeBrowsingEnabled: true,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 limitsNavigationsToAppBoundDomains: false,
//               ),
//             ),
//               onWebViewCreated: (controller) {
//     _webViewController = controller;
//     controller.addJavaScriptHandler(
//     handlerName: 'consoleLog',
//     callback: (args) {
//     print("WEBVIEW JS: ${args.join(', ')}");
//     },
//     );
//     },
//             onProgressChanged: (controller, progress) {
//               if (mounted) {
//                 setState(() {
//                   _progress = progress / 100;
//                 });
//               }
//             },
//     onLoadStop: (controller, url) async {
//     if (mounted) {
//     setState(() {
//     _progress = 1.0; // Mark as fully loaded for progress indicator
//     });
//     }
//
//     final currentUrl = url.toString();
//     print("WebView onLoadStop: $currentUrl");
//
//     // Determine the exact URL where the login form appears during checkout
//     // It might be 'checkout/#login', 'checkout/onepage/', or directly on '#shipping' if it's dynamic
//     // You MUST inspect this in a browser to be sure.
//     final bool isLoginPageOrCheckoutWithLogin =
//     currentUrl.contains('customer/account/login') ||
//     currentUrl.contains('checkout/#shipping') || // Keep this if form appears here
//     currentUrl.contains('checkout/#login') ||    // Add if there's a specific login step
//     currentUrl.contains('checkout/onepage/index/'); // Common for one-page checkout login
//
//     if (isLoginPageOrCheckoutWithLogin) {
//     print("Attempting auto-login for URL: $currentUrl");
//
//     await Future.delayed(const Duration(milliseconds: 1000)); // Give page time to render fully
//
//     String jsCode = '';
//     bool credentialsProvided = false;
//
//     if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
//     credentialsProvided = true;
//     const emailFieldId = 'email'; // Verify this ID on the actual login form
//     jsCode += """
//         (function() {
//           var emailInput = document.getElementById('$emailFieldId');
//           if (emailInput) {
//             emailInput.value = '${widget.userEmail}';
//             emailInput.dispatchEvent(new Event('change', {bubbles: true}));
//             emailInput.dispatchEvent(new Event('input', {bubbles: true}));
//             console.log('JS: Email field ($emailFieldId) pre-filled and events dispatched.');
//           } else {
//             console.log('JS: Email input field (ID: $emailFieldId) not found on $currentUrl.');
//           }
//         })();
//       """;
//     }
//
//     if (widget.userPassword != null && widget.userPassword!.isNotEmpty) {
//     credentialsProvided = true;
//     const passwordFieldId = 'pass'; // Verify this ID on the actual login form
//     jsCode += """
//         (function() {
//           var passwordInput = document.getElementById('$passwordFieldId');
//           if (passwordInput) {
//             passwordInput.value = '${widget.userPassword}';
//             passwordInput.dispatchEvent(new Event('change', {bubbles: true}));
//             passwordInput.dispatchEvent(new Event('input', {bubbles: true}));
//             console.log('JS: Password field ($passwordFieldId) pre-filled and events dispatched.');
//           } else {
//             console.log('JS: Password input field (ID: $passwordFieldId) not found on $currentUrl.');
//           }
//         })();
//       """;
//     }
//
//     if (credentialsProvided) {
//     jsCode += """
//         (function() {
//           console.log('JS: Attempting to click login button or submit form...');
//           // VERIFY THESE SELECTORS ON THE ACTUAL LOGIN FORM
//           var loginButton = document.getElementById('send2');
//           if (loginButton) {
//               loginButton.click();
//               console.log('JS: Clicked button by ID "send2".');
//           } else {
//               var actionLoginButton = document.querySelector('.action.login');
//               if (actionLoginButton) {
//                   actionLoginButton.click();
//                   console.log('JS: Clicked button by class ".action.login".');
//               } else {
//                   var loginForm = document.querySelector('#login-form');
//                   if (loginForm) {
//                       loginForm.submit();
//                       console.log('JS: Submitted form by ID "#login-form".');
//                   } else {
//                       var customerLoginForm = document.querySelector('.customer-account-login form');
//                       if (customerLoginForm) {
//                           customerLoginForm.submit();
//                           console.log('JS: Submitted form by class ".customer-account-login form".');
//                       } else {
//                           console.log('JS: No login button or form found to submit on $currentUrl.');
//                       }
//                   }
//               }
//           }
//         })();
//       """;
//     } else {
//     print("No user email or password provided for auto-login.");
//     }
//
//     if (jsCode.isNotEmpty) {
//     try {
//     await controller.evaluateJavascript(source: jsCode);
//     print("JS auto-login code executed.");
//     } catch (e) {
//     print("Error executing auto-login JavaScript: $e");
//     }
//     }
//     } else {
//     print("Current URL ($currentUrl) does not match auto-login criteria. Skipping JS injection.");
//     }
//     },
//             onLoadError: (controller, url, code, message) {
//               print('Error loading $url: $message (Code: $code)');
//               // Handle error
//             },
//           ),
//           if (_progress < 1.0 && _progress > 0.0)
//             LinearProgressIndicator(value: _progress, color: Theme.of(context).primaryColor),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final String userEmail;
//   final String userPassword;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     this.userEmail = 'ram11@gmail.com', // default email
//     this.userPassword = 'mah@12345678', // default password
//   }) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   InAppWebViewController? _webViewController;
//   double _progress = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Checkout'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () async {
//             if (_webViewController != null) {
//               bool? canGoBack = await _webViewController!.canGoBack();
//               if (canGoBack == true) {
//                 _webViewController!.goBack();
//               } else {
//                 Navigator.of(context).pop();
//               }
//             } else {
//               Navigator.of(context).pop();
//             }
//           },
//         ),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useOnDownloadStart: true,
//                 allowFileAccessFromFileURLs: true,
//                 allowUniversalAccessFromFileURLs: true,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 useHybridComposition: true,
//                 thirdPartyCookiesEnabled: true,
//                 safeBrowsingEnabled: true,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 limitsNavigationsToAppBoundDomains: false,
//               ),
//             ),
//             onWebViewCreated: (controller) {
//               _webViewController = controller;
//               controller.addJavaScriptHandler(
//                 handlerName: 'consoleLog',
//                 callback: (args) {
//                   print("WEBVIEW JS: ${args.join(', ')}");
//                 },
//               );
//             },
//             onProgressChanged: (controller, progress) {
//               if (mounted) {
//                 setState(() {
//                   _progress = progress / 100;
//                 });
//               }
//             },
//             onLoadStop: (controller, url) async {
//               if (mounted) {
//                 setState(() {
//                   _progress = 1.0;
//                 });
//               }
//
//               final currentUrl = url.toString();
//               print("WebView onLoadStop: $currentUrl");
//
//               // Auto-login criteria
//               final bool isLoginPageOrCheckoutWithLogin =
//                   currentUrl.contains('customer/account/login') ||
//                       currentUrl.contains('checkout/#shipping') ||
//                       currentUrl.contains('checkout/#login') ||
//                       currentUrl.contains('checkout/onepage/index/');
//
//               if (isLoginPageOrCheckoutWithLogin) {
//                 print("Attempting auto-login for URL: $currentUrl");
//
//                 await Future.delayed(const Duration(milliseconds: 1000));
//
//                 // Robust JS for Magento login
//                 String jsCode = """
// (function() {
//   var emailInput = document.getElementById('email') || document.querySelector('input[name="login[username]"]');
//   if(emailInput) {
//     emailInput.focus();
//     emailInput.value = '${widget.userEmail}';
//     emailInput.dispatchEvent(new Event('input', {bubbles:true}));
//     emailInput.dispatchEvent(new Event('change', {bubbles:true}));
//     console.log('JS: Email field filled');
//   } else {
//     console.log('JS: Email field not found');
//   }
//
//   var passwordInput = document.getElementById('pass');
//   if(passwordInput) {
//     passwordInput.focus();
//     passwordInput.value = '${widget.userPassword}';
//     passwordInput.dispatchEvent(new Event('input', {bubbles:true}));
//     passwordInput.dispatchEvent(new Event('change', {bubbles:true}));
//     console.log('JS: Password field filled');
//   } else {
//     console.log('JS: Password field not found');
//   }
//
//   var loginButton = document.getElementById('send2') || document.querySelector('.action.login') || document.querySelector('#login-form') || document.querySelector('.customer-account-login form');
//   if(loginButton) {
//     if(loginButton.tagName.toLowerCase() === 'form') {
//       loginButton.submit();
//       console.log('JS: Form submitted');
//     } else {
//       loginButton.click();
//       console.log('JS: Button clicked');
//     }
//   } else {
//     console.log('JS: No login button found');
//   }
// })();
// """;
//
//                 try {
//                   await controller.evaluateJavascript(source: jsCode);
//                   print("JS auto-login code executed.");
//                 } catch (e) {
//                   print("Error executing auto-login JavaScript: $e");
//                 }
//               } else {
//                 print(
//                     "Current URL ($currentUrl) does not match auto-login criteria. Skipping JS injection.");
//               }
//             },
//             onLoadError: (controller, url, code, message) {
//               print('Error loading $url: $message (Code: $code)');
//             },
//           ),
//           if (_progress < 1.0 && _progress > 0.0)
//             LinearProgressIndicator(
//                 value: _progress, color: Theme.of(context).primaryColor),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inapp;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inapp;

import '../ shipping_bloc/shipping_bloc.dart';
import '../../auth/bloc/currency_bloc.dart';
import '../../auth/bloc/currency_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../auth/view/auth_screen.dart';
import '../../search/presentation/search_screen.dart';
import '../cart_bloc/cart_event.dart';

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false; // <-- One-time refresh flag
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
//         title: const Text('Checkout'),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             // onWebViewCreated: (controller) {
//             //   _controller = controller;
//             // },
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // ✅ Set currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//
//               print("🍪 Currency cookie set: $selectedCurrency");
//             },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_COMPATIBILITY_MODE,
//               ),
//             ),
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/#shipping")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//
//               // One-time refresh after page load
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Refreshing WebView for full page load");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error refreshing WebView: $e");
//                   }
//                 });
//               }
//             },
//           ),
//           if (isLoading)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

//
// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   bool isLoggedIn = false;
//   bool hasGuestCart = false;
//   String? _userEmail;
//   String? _userPassword;
//   String? _userToken;
//
//  // One-time refresh flag
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//   Future<void> _initializeScreen() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//
//     _userEmail = prefs.getString('user_email');
//     _userPassword = prefs.getString('user_password');
//     _userToken = prefs.getString('user_token');
//
//
//     print("geustQuoteID>>$hasGuestCart");
//     print("User Email: $_userEmail");
//     print("User Password $_userPassword" );
//     print("User Token: $_userToken");
//     if (!isLoggedIn && !hasGuestCart) {
//       if (mounted) setState(() => isLoading = false);
//       return;
//     }
//     //
//     // _shippingBloc = context.read<ShippingBloc>();
//     // context.read<CartBloc>().add(FetchCartItems());
//     // _shippingBloc.add(FetchCountries());
//     // await _loadShippingPreferences();
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   String extractOrderIdFromUrl(String url) {
//     final uri = Uri.parse(url);
//     final segments = uri.pathSegments; // ['checkout', 'onepage', 'success', 'order_id', '0000123']
//     final index = segments.indexOf('order_id');
//     if (index != -1 && index + 1 < segments.length) {
//       return segments[index + 1]; // returns '0000123'
//     }
//     return ''; // fallback if not found
//   }
//
//   Future<void> _sendMobileFlag(String currentUrl) async {
//     try {
//       // Extract order ID from URL or page (depends on your setup)
//       final orderId = extractOrderIdFromUrl(currentUrl);
//
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_userToken', // if needed
//         },
//         body: jsonEncode({
//           'order_increment_id': orderId,
//           'source': 'mobile_app',
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("✅ Order flagged as mobile app");
//       } else {
//         print("⚠️ Failed to flag order: ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
//         title: const Text('Checkout'),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//
//             // WebView created
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // ✅ Set currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//               print("🍪 Currency cookie set: $selectedCurrency");
//
//               // Optional: set user agent for payment gateways
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             // WebView options
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//
//             // Allow all checkout URLs to fix payment iframe
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//
//             // Loading indicators
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//             // onLoadStop: (controller, url) async {
//             //   setState(() => isLoading = false);
//             //
//             //   // One-time reload to ensure full page load
//             //   if (!hasRefreshed) {
//             //     hasRefreshed = true;
//             //     Future.delayed(const Duration(seconds: 1), () async {
//             //       try {
//             //         print("🔄 Refreshing WebView for full page load");
//             //         await _controller.reload();
//             //       } catch (e) {
//             //         print("Error refreshing WebView: $e");
//             //       }
//             //     });
//             //   }
//             // },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//
//               final currentUrl = url.toString();
//
//               // 1️⃣ One-time reload after initial page load
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Refreshing WebView for full page load");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error refreshing WebView: $e");
//                   }
//                 });
//               }
//
//               // 2️⃣ Detect order success page
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 print("✅ Order completed, sending mobile flag");
//                 await _sendMobileFlag(currentUrl); // Call your Flutter API here
//               }
//             },
//
//           ),
//
//           // Loading spinner
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }




import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// Your CurrencyBloc import
//11/9/2025
// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   bool isLoggedIn = false;
//   bool hasGuestCart = false;
//   String? _userEmail;
//   String? _userPassword;
//   String? _userToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//     _userEmail = prefs.getString('user_email');
//     _userPassword = prefs.getString('user_password');
//     _userToken = prefs.getString('user_token');
//
//     print("Guest Quote ID: $hasGuestCart");
//     print("User Email: $_userEmail");
//     print("User Password: $_userPassword");
//     print("User Token: $_userToken");
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   String extractOrderIdFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final segments = uri.pathSegments;
//       final index = segments.indexOf('order_id');
//       if (index != -1 && index + 1 < segments.length) {
//         return segments[index + 1];
//       }
//     } catch (e) {
//       print("Error extracting order ID: $e");
//     }
//     return '';
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//
//   // Future<void> _sendMobileFlag(String currentUrl) async {
//   //   final orderId = extractOrderIdFromUrl(currentUrl);
//   //   if (orderId.isEmpty) {
//   //     print("⚠️ Order ID not found, skipping mobile flag.");
//   //     return;
//   //   }
//   //
//   //   try {
//   //     final response = await http.post(
//   //       Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization': 'Bearer $_userToken', // if needed
//   //       },
//   //       body: jsonEncode({
//   //         'order_increment_id': orderId,
//   //         'source': 'mobile_app',
//   //       }),
//   //     );
//   //
//   //     if (response.statusCode == 200) {
//   //       print("✅ Order flagged as mobile app");
//   //     } else {
//   //       print("⚠️ Failed to flag order: ${response.body}");
//   //     }
//   //   } catch (e) {
//   //     print("Error sending mobile flag: $e");
//   //   }
//   // }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//           // remove Authorization if your API route is anonymous
//           // 'Authorization': 'Bearer $_userToken',
//         },
//         body: jsonEncode({
//           "orderIncrementId": orderId, // 👈 match PHP method argument
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("✅ Order flagged as mobile app");
//       } else {
//         print("⚠️ Failed to flag order: ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
//         title: const Text('Checkout'),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             onTitleChanged: (controller, title) {
//               if (title != null && title.contains("Order #")) {
//                 final orderId = extractOrderIdFromTitle(title);
//                 if (orderId != null) {
//                   print("📦 Extracted Order ID: $orderId");
//                   _sendMobileFlag(orderId);
//                 }
//               }
//             },
//
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // Set currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//               print("🍪 Currency cookie set: $selectedCurrency");
//
//               // Optional: set user agent for payment gateways
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//
//
//
//
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//               final currentUrl = url.toString();
//
//               // One-time reload after initial page load
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Refreshing WebView for full page load");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error refreshing WebView: $e");
//                   }
//                 });
//               }
//
//               // Detect order success page
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 print("✅ Order completed, sending mobile flag");
//                 await _sendMobileFlag(currentUrl);
//               }
//             },
//           ),
//
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }






import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;


// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   bool isLoggedIn = false;
//   bool hasGuestCart = false;
//   String? _userEmail;
//   String? _userPassword;
//   String? _userToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//     _userEmail = prefs.getString('user_email');
//     _userPassword = prefs.getString('user_password');
//     _userToken = prefs.getString('user_token');
//
//     print("Guest Quote ID: $hasGuestCart");
//     print("User Email: $_userEmail");
//     print("User Password: $_userPassword");
//     print("User Token: $_userToken");
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   String extractOrderIdFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final segments = uri.pathSegments;
//       final index = segments.indexOf('order_id');
//       if (index != -1 && index + 1 < segments.length) {
//         return segments[index + 1];
//       }
//     } catch (e) {
//       print("Error extracting order ID: $e");
//     }
//     return '';
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "orderIncrementId": orderId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("✅ Order flagged as mobile app");
//       } else {
//         print("⚠️ Failed to flag order: ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
//         title: const Text('Checkout'),
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // JS handler for Continue Shopping
//               _controller.addJavaScriptHandler(
//                 handlerName: 'continueShopping',
//                 callback: (args) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => AuthScreen()),
//                   );
//                 },
//               );
//
//               // Set currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//               print("🍪 Currency cookie set: $selectedCurrency");
//
//               // Optional: set user agent for payment gateways
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             onTitleChanged: (controller, title) {
//               if (title != null && title.contains("Order #")) {
//                 final orderId = extractOrderIdFromTitle(title);
//                 if (orderId != null) {
//                   print("📦 Extracted Order ID: $orderId");
//                   _sendMobileFlag(orderId);
//                 }
//               }
//             },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//               final currentUrl = url.toString();
//
//               // One-time reload after initial page load
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Refreshing WebView for full page load");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error refreshing WebView: $e");
//                   }
//                 });
//               }
//
//
//               // Inject JavaScript to hide elements
//               await controller.evaluateJavascript(source: """
//     // Hide the top styling queries div
//     document.querySelector('.stylingqueries')?.style.display = 'none';
//
//     // Hide the welcome message
//     document.querySelector('.greet.welcome')?.style.display = 'none';
//
//     // Hide the middle header content (currency selector, logo, login/cart)
//     document.querySelector('.middle-header-content')?.style.display = 'none';
//
//     // Hide the bottom header content (menu, mobile wishlist, search, minicart)
//     document.querySelector('.bottom-header-content')?.style.display = 'none';
//
//     // Hide the "Home" link
//     document.querySelector('a[title="Home"][href="https://stage.aashniandco.com/"]')?.style.display = 'none';
//
//     // Hide the header element if present (based on your previous code)
//     document.querySelector('header')?.style.display = 'none';
//
//     // Hide the footer element if present (based on your previous code)
//     document.querySelector('footer')?.style.display = 'none';
//   """);
//
//               // Detect order success page
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 print("✅ Order completed, sending mobile flag");
//                 await _sendMobileFlag(currentUrl);
//
//                 // Hide WebView header/footer
//                 await controller.evaluateJavascript(source: """
//                   document.querySelector('header')?.style.display = 'none';
//                   document.querySelector('footer')?.style.display = 'none';
//                 """);
//
//                 // Detect Continue Shopping click
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//           ),
//
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shopping_bag.dart';
 // Assuming this path is correct

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   bool isLoggedIn = false;
//   bool hasGuestCart = false;
//   String? _userEmail;
//   String? _userPassword;
//   String? _userToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//     _userEmail = prefs.getString('user_email');
//     _userPassword = prefs.getString('user_password');
//     _userToken = prefs.getString('user_token');
//
//     print("Guest Quote ID: $hasGuestCart");
//     print("User Email: $_userEmail");
//     print("User Password: $_userPassword");
//     print("User Token: $_userToken");
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   String extractOrderIdFromUrl(String url) {
//     try {
//       final uri = Uri.parse(url);
//       final segments = uri.pathSegments;
//       final index = segments.indexOf('order_id');
//       if (index != -1 && index + 1 < segments.length) {
//         return segments[index + 1];
//       }
//     } catch (e) {
//       print("Error extracting order ID: $e");
//     }
//     return '';
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "orderIncrementId": orderId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("✅ Order flagged as mobile app");
//       } else {
//         print("⚠️ Failed to flag order: ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//   // Future<void> _hideWebElements() async {
//   //   await _controller.evaluateJavascript(source: """
//   //   // Remove the element with ID 'aashnisticky'
//   //   var stickyEl = document.getElementById('aashnisticky');
//   //   if(stickyEl && stickyEl.parentNode) {
//   //     stickyEl.parentNode.removeChild(stickyEl);
//   //     console.log('Removed #aashnisticky');
//   //   }
//   // """);
//   // }
//
//   Future<void> _hideWebElements() async {
//     await _controller.evaluateJavascript(source: """
//     // Remove the element with ID 'aashnisticky'
//     var stickyEl = document.getElementById('aashnisticky');
//     if (stickyEl && stickyEl.parentNode) {
//       stickyEl.parentNode.removeChild(stickyEl);
//       console.log('Removed #aashnisticky');
//     }
//
//     // Helper function to remove element by XPath
//     function removeByXPath(xpath) {
//       var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//       var el = result.singleNodeValue;
//       if (el && el.parentNode) {
//         el.parentNode.removeChild(el);
//         console.log('Removed element by XPath: ' + xpath);
//       }
//     }
//
//     // Remove footer elements by XPath
//     removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//     removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//     removeByXPath('/html/body/main/div/footer/div/div[3]');
//   """);
//   }
//
//
//   Widget _buildResponsiveAppBarTitle() {
//     print("met called>>");
//     // This BlocBuilder will automatically handle loading, errors, and data states
//     return BlocBuilder<CurrencyBloc, CurrencyState>(
//       builder: (context, state) {
//         // --- Handle Loading and Error States First ---
//         if (state is CurrencyLoading || state is CurrencyInitial) {
//           return const Center(
//             child: SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
//             ),
//           );
//         }
//         if (state is CurrencyError) {
//           return Tooltip(
//             message: state.message,
//             child: const Icon(Icons.error_outline, color: Colors.red),
//           );
//         }
//
//
//         // --- Handle the Success State ---
//         if (state is CurrencyLoaded) {
//           // ✅ Wrap the logo and the dropdown in a Row for side-by-side layout.
//           return Row(
//             children: [
//               // 1. Add the logo as the first item in the Row.
//               Image.asset('assets/logo.jpeg', height: 30),
//               const SizedBox(width: 16),
//
//
//               // 2. Wrap the Dropdown in an Expanded widget.
//               // This tells the dropdown to fill all remaining horizontal space in the AppBar.
//               // Expanded(
//               //   child: DropdownButtonHideUnderline(
//               //     child: DropdownButton<String>(
//               //       value: state.selectedCurrencyCode,
//               //       isExpanded: true, // Ensures it fills the Expanded widget
//               //       icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black87),
//               //       onChanged: (newCode) {
//               //         if (newCode != null) {
//               //           context.read<CurrencyBloc>().add(ChangeCurrency(newCode));
//               //           _updateCartCurrency(newCode);
//               //         }
//               //       },
//               //       // This builder defines how the selected item looks when the dropdown is CLOSED.
//               //       selectedItemBuilder: (context) {
//               //         return state.currencyData.availableCurrencyCodes
//               //             .map((_) => Align(
//               //           alignment: Alignment.centerLeft,
//               //           child: Text(
//               //             '${state.selectedCurrencyCode} | ${state.selectedSymbol}',
//               //             style: const TextStyle(
//               //                 color: Colors.black,
//               //                 fontWeight: FontWeight.w500,
//               //                 fontSize: 14 // Adjusted for better fit
//               //             ),
//               //             overflow: TextOverflow.ellipsis,
//               //           ),
//               //         ))
//               //             .toList();
//               //       },
//               //       // This builds the list of items when the dropdown is OPEN.
//               //       items: state.currencyData.availableCurrencyCodes.map((code) {
//               //         return DropdownMenuItem<String>(
//               //           value: code,
//               //           child: Text(code),
//               //         );
//               //       }).toList(),
//               //     ),
//               //   ),
//               // ),
//             ],
//           );
//         }
//
//
//         // Fallback for any other unhandled state
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
//       //   title: const Text('Checkout'),
//       // ),
//
//       appBar: AppBar(
//         title: _buildResponsiveAppBarTitle(),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         // ✅ The 'bottom' property is now REMOVED to hide the TabBar
//         actions: [
//           // IconButton(
//           //   icon: const Icon(Icons.search),
//           //   onPressed: () {
//           //     showDialog(
//           //       context: context,
//           //       builder: (context) => const SearchScreen1(),
//           //     );
//           //   },
//           // ),
//           // IconButton(
//           //   icon: Stack(
//           //     clipBehavior: Clip.none,
//           //     children: [
//           //       const Icon(Icons.shopping_bag_rounded, color: Colors.black),
//           //       if (cartQty > 0)
//           //         Positioned(
//           //           right: -6, top: -6,
//           //           child: Container(
//           //             padding: const EdgeInsets.all(2),
//           //             decoration: BoxDecoration(
//           //               color: Colors.red,
//           //               borderRadius: BorderRadius.circular(10),
//           //             ),
//           //             constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
//           //             child: Text(
//           //               '$cartQty',
//           //               style: const TextStyle(
//           //                 color: Colors.white,
//           //                 fontSize: 12,
//           //                 fontWeight: FontWeight.bold,
//           //               ),
//           //               textAlign: TextAlign.center,
//           //             ),
//           //           ),
//           //         ),
//           //     ],
//           //   ),
//           //   onPressed: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(builder: (context) => ShoppingBagScreen()),
//           //     );
//           //   },
//           // ),
//         ],
//       ),
//
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // Inject the hiding script immediately upon creation
//               await _hideWebElements();
//
//               // JS handler for Continue Shopping
//               _controller.addJavaScriptHandler(
//                 handlerName: 'continueShopping',
//                 callback: (args) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => AuthScreen()),
//                   );
//                 },
//               );
//
//               // Set currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//               print("🍪 Currency cookie set: $selectedCurrency");
//
//               // Optional: set user agent for payment gateways
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             onTitleChanged: (controller, title) {
//               if (title != null && title.contains("Order #")) {
//                 final orderId = extractOrderIdFromTitle(title);
//                 if (orderId != null) {
//                   print("📦 Extracted Order ID: $orderId");
//                   _sendMobileFlag(orderId);
//                 }
//               }
//             },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               // Allow navigation for checkout related URLs
//               if (requestedUrl.contains("/checkout/") || requestedUrl.contains("paypal") || requestedUrl.contains("stripe")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//               final currentUrl = url.toString();
//
//               // Inject the hiding script again after the page fully loads
//               await _hideWebElements();
//
//               // One-time reload after initial page load (only if needed, might cause flicker)
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Reloading WebView for full page load and script application.");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error reloading WebView: $e");
//                   }
//                 });
//               }
//
//
//               // Detect order success page
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 print("✅ Order completed, sending mobile flag");
//                 await _sendMobileFlag(currentUrl);
//
//                 // Detect Continue Shopping click
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//           ),
//
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

//16/9/2025

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   bool isLoggedIn = false;
//   bool hasGuestCart = false;
//   String? _userEmail;
//   String? _userPassword;
//   String? _userToken;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeScreen();
//   }
//
//   Future<void> _initializeScreen() async {
//     if (!mounted) return;
//     setState(() => isLoading = true);
//
//     final prefs = await SharedPreferences.getInstance();
//     isLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
//     hasGuestCart = (prefs.getString('guest_quote_id') ?? '').isNotEmpty;
//     _userEmail = prefs.getString('user_email');
//     _userPassword = prefs.getString('user_password');
//     _userToken = prefs.getString('user_token');
//
//     print("Guest Quote ID: $hasGuestCart");
//     print("User Email: $_userEmail");
//     print("User Password: $_userPassword");
//     print("User Token: $_userToken");
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   Future<void> _goBack() async {
//     if (await _controller.canGoBack()) {
//       _controller.goBack();
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode({
//           "orderIncrementId": orderId,
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         print("✅ Order flagged as mobile app");
//       } else {
//         print("⚠️ Failed to flag order: ${response.body}");
//       }
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//   /// Hides sticky + footer always, header only if shipping page
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     await _controller.evaluateJavascript(source: """
//       // Remove the element with ID 'aashnisticky'
//       var stickyEl = document.getElementById('aashnisticky');
//       if (stickyEl && stickyEl.parentNode) {
//         stickyEl.parentNode.removeChild(stickyEl);
//         console.log('Removed #aashnisticky');
//       }
//
//       // Helper function to remove element by XPath
//       function removeByXPath(xpath) {
//         var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//         var el = result.singleNodeValue;
//         if (el && el.parentNode) {
//           el.parentNode.removeChild(el);
//           console.log('Removed element by XPath: ' + xpath);
//         }
//       }
//
//       // Always remove footer parts
//       removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//       removeByXPath('/html/body/main/div/footer/div/div[3]');
//       removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//       // Remove header ONLY on shipping page
//       ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//     """);
//   }
//
//   Widget _buildResponsiveAppBarTitle() {
//     return BlocBuilder<CurrencyBloc, CurrencyState>(
//       builder: (context, state) {
//         if (state is CurrencyLoading || state is CurrencyInitial) {
//           return const Center(
//             child: SizedBox(
//               height: 20,
//               width: 20,
//               child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black54),
//             ),
//           );
//         }
//         if (state is CurrencyError) {
//           return Tooltip(
//             message: state.message,
//             child: const Icon(Icons.error_outline, color: Colors.red),
//           );
//         }
//         if (state is CurrencyLoaded) {
//           return Row(
//             children: [
//               Image.asset('assets/logo.jpeg', height: 30),
//               const SizedBox(width: 16),
//             ],
//           );
//         }
//         return const SizedBox.shrink();
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: _buildResponsiveAppBarTitle(),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // First injection (no URL yet, so assume false)
//               await _hideWebElements(isShippingPage: false);
//
//               // JS handler for Continue Shopping
//               _controller.addJavaScriptHandler(
//                 handlerName: 'continueShopping',
//                 callback: (args) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                   );
//                 },
//               );
//
//               // Currency cookie
//               final currencyState = context.read<CurrencyBloc>().state;
//               final selectedCurrency = currencyState is CurrencyLoaded
//                   ? currencyState.selectedCurrencyCode
//                   : 'INR';
//
//               final cookieManager = CookieManager.instance();
//               await cookieManager.setCookie(
//                 url: WebUri('https://stage.aashniandco.com'),
//                 name: 'currency',
//                 value: selectedCurrency,
//                 domain: 'stage.aashniandco.com',
//                 path: '/',
//                 isSecure: true,
//                 isHttpOnly: false,
//                 sameSite: HTTPCookieSameSitePolicy.LAX,
//               );
//               print("🍪 Currency cookie set: $selectedCurrency");
//
//               // User agent
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             onTitleChanged: (controller, title) {
//               if (title != null && title.contains("Order #")) {
//                 final orderId = extractOrderIdFromTitle(title);
//                 if (orderId != null) {
//                   print("📦 Extracted Order ID: $orderId");
//                   _sendMobileFlag(orderId);
//                 }
//               }
//             },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/") ||
//                   requestedUrl.contains("paypal") ||
//                   requestedUrl.contains("stripe")) {
//                 return NavigationActionPolicy.ALLOW;
//               } else {
//                 print("⛔ Blocked navigation to: $requestedUrl");
//                 return NavigationActionPolicy.CANCEL;
//               }
//             },
//
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//               final currentUrl = url.toString();
//
//               // Inject with shipping flag
//               await _hideWebElements(isShippingPage: currentUrl.contains("/checkout/#shipping"));
//
//               // One-time reload
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     print("🔄 Reloading WebView for full script application");
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error reloading WebView: $e");
//                   }
//                 });
//               }
//
//               // Detect success page
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 print("✅ Order completed, sending mobile flag");
//                 await _sendMobileFlag(currentUrl);
//
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//           ),
//
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }




// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   const WebViewScreen({Key? key, required this.initialUrl}) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     await _controller.evaluateJavascript(source: """
//       var stickyEl = document.getElementById('aashnisticky');
//       if (stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);
//
//       function removeByXPath(xpath) {
//         var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//         var el = result.singleNodeValue;
//         if (el && el.parentNode) el.parentNode.removeChild(el);
//       }
//
//       removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//       removeByXPath('/html/body/main/div/footer/div/div[3]');
//       removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//       ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//     """);
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({"orderIncrementId": orderId}),
//       );
//
//       print(response.statusCode == 200
//           ? "✅ Order flagged as mobile app"
//           : "⚠️ Failed to flag order: ${response.body}");
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.jpeg', height: 30),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               await _hideWebElements(isShippingPage: false);
//
//               _controller.addJavaScriptHandler(
//                 handlerName: 'continueShopping',
//                 callback: (args) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                   );
//                 },
//               );
//
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//
//             onTitleChanged: (controller, title) {
//               if (title != null && title.contains("Order #")) {
//                 final orderId = extractOrderIdFromTitle(title);
//                 if (orderId != null) _sendMobileFlag(orderId);
//               }
//             },
//
//             onLoadStart: (controller, url) {
//               setState(() => isLoading = true);
//             },
//
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//               final currentUrl = url.toString();
//
//               await _hideWebElements(isShippingPage: currentUrl.contains("/checkout/#shipping"));
//
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error reloading WebView: $e");
//                   }
//                 });
//               }
//
//               if (currentUrl.contains("/checkout/onepage/success") ||
//                   currentUrl.contains("#/order-success")) {
//                 await _sendMobileFlag(currentUrl);
//
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//
//               // Block any /checkout/cart/ navigation
//               if (requestedUrl.contains("/checkout/cart/")) {
//                 print("⛔ Prevented redirect to cart: $requestedUrl");
//
//                 // Force redirect to shipping page
//                 await controller.loadUrl(
//                   urlRequest: URLRequest(
//                     url: WebUri("https://stage.aashniandco.com/checkout/#shipping"),
//                   ),
//                 );
//
//                 return NavigationActionPolicy.CANCEL;
//               }
//
//               // Allow normal checkout pages or payment URLs
//               if (requestedUrl.contains("/checkout/") || requestedUrl.contains("paypal") || requestedUrl.contains("stripe")) {
//                 return NavigationActionPolicy.ALLOW;
//               }
//
//               // Block everything else
//               print("⛔ Blocked navigation to: $requestedUrl");
//               return NavigationActionPolicy.CANCEL;
//             },
//
//             // shouldOverrideUrlLoading: (controller, navAction) async {
//             //   final requestedUrl = navAction.request.url.toString();
//             //   if (requestedUrl.contains("/checkout/") ||
//             //       requestedUrl.contains("paypal") ||
//             //       requestedUrl.contains("stripe")) {
//             //     return NavigationActionPolicy.ALLOW;
//             //   } else {
//             //     return NavigationActionPolicy.CANCEL;
//             //   }
//             // },
//
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//           ),
//
//           if (isLoading)
//             const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }





// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final List<Map<String, dynamic>> cookies;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     required this.cookies,
//   }) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   /// Inject cookies before loading page
//   Future<void> _setCookies(List<Map<String, dynamic>> cookies) async {
//     final cookieManager = CookieManager.instance();
//     for (final cookie in cookies) {
//       await cookieManager.setCookie(
//         url: WebUri("https://stage.aashniandco.com"),
//         name: cookie['name'],
//         value: cookie['value'],
//         domain: 'stage.aashniandco.com', // force exact domain
//         path: cookie['path'] ?? '/',
//         isSecure: cookie['secure'] ?? true,
//         isHttpOnly: cookie['httponly'] ?? false,
//         sameSite: HTTPCookieSameSitePolicy.LAX,
//       );
//     }
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     await _controller.evaluateJavascript(source: """
//       var stickyEl = document.getElementById('aashnisticky');
//       if (stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);
//
//       function removeByXPath(xpath) {
//         var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//         var el = result.singleNodeValue;
//         if (el && el.parentNode) el.parentNode.removeChild(el);
//       }
//
//       removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//       removeByXPath('/html/body/main/div/footer/div/div[3]');
//       removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//       ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//     """);
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       // Get cookies from WebView
//       final cookies = await CookieManager.instance()
//           .getCookies(url: WebUri("https://stage.aashniandco.com"));
//
//       // Build cookie header
//       final cookieHeader = cookies.map((c) => '${c.name}=${c.value}').join('; ');
//
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Cookie': cookieHeader, // <-- send session cookies
//         },
//         body: jsonEncode({"orderIncrementId": orderId}),
//       );
//
//       print("statusCode>>${response.statusCode}");
//       print("body>>${response.body}");
//       print(response.statusCode == 200 && response.body == 'true'
//           ? "✅ Order flagged as mobile app"
//           : "⚠️ Failed to flag order in Magento: ${response.body}");
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.jpeg', height: 30),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//
//               // ✅ Set cookies first
//               await _setCookies(widget.cookies);
//               await Future.delayed(const Duration(milliseconds: 200));
//
//               // Load checkout page
//               await _controller.loadUrl(
//                 urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//               );
//
//               await _hideWebElements(isShippingPage: widget.initialUrl.contains("#shipping"));
//
//               _controller.addJavaScriptHandler(
//                 handlerName: 'continueShopping',
//                 callback: (args) {
//                   Navigator.pushReplacement(
//                     context,
//                     MaterialPageRoute(builder: (_) => const AuthScreen()),
//                   );
//                 },
//               );
//
//               await _controller.setSettings(
//                 settings: InAppWebViewSettings(
//                   javaScriptEnabled: true,
//                   userAgent:
//                   'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                 ),
//               );
//             },
//             onLoadStop: (controller, url) async {
//               setState(() => isLoading = false);
//
//               // ✅ Debug WebView cookies
//               final webViewCookies = await CookieManager.instance().getCookies(url: WebUri(url.toString()));
//               print("🌐 WebView Cookies at $url:");
//               for (var cookie in webViewCookies) {
//                 print("${cookie.name} = ${cookie.value}, domain=${cookie.domain}");
//               }
//
//               await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//
//               if (!hasRefreshed) {
//                 hasRefreshed = true;
//                 Future.delayed(const Duration(seconds: 1), () async {
//                   try {
//                     await _controller.reload();
//                   } catch (e) {
//                     print("Error reloading WebView: $e");
//                   }
//                 });
//               }
//
//               if (url.toString().contains("/checkout/onepage/success") ||
//                   url.toString().contains("#/order-success")) {
//                 await _sendMobileFlag(url.toString());
//
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//
//               // Prevent /checkout/cart/ navigation
//               if (requestedUrl.contains("/checkout/cart/")) {
//                 await controller.loadUrl(
//                   urlRequest: URLRequest(url: WebUri("https://stage.aashniandco.com/checkout/#shipping")),
//                 );
//                 return NavigationActionPolicy.CANCEL;
//               }
//
//               // Allow normal checkout pages or payment URLs
//               if (requestedUrl.contains("/checkout/") ||
//                   requestedUrl.contains("paypal") ||
//                   requestedUrl.contains("stripe")) {
//                 return NavigationActionPolicy.ALLOW;
//               }
//
//               print("⛔ Blocked navigation to: $requestedUrl");
//               return NavigationActionPolicy.CANCEL;
//             },
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//                 allowsAirPlayForMediaPlayback: true,
//                 isFraudulentWebsiteWarningEnabled: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//           ),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

//25/9/2025
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
 // Adjust this import path as needed

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final List<Map<String, dynamic>> cookies;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     required this.cookies,
//   }) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//   bool _hideSupportBar = false;
//
//   @override
//   void initState() {
//     super.initState();
//     debugMagentoCookies();
//     print("WebViewScreen initialized with URL: ${widget.initialUrl}");
//     print("Initial cookies passed to WebViewScreen: ${json.encode(widget.cookies)}");
//   }
//
//
//
//   Future<void> debugMagentoCookies() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cookiesJson = prefs.getString('guest_cart_cookies') ??
//         prefs.getString('user_cart_cookies');
//
//     if (cookiesJson == null) {
//       print("❌ No cookies found in SharedPreferences.");
//       return;
//     }
//
//     final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//
//     print("🔎 Saved Magento cookies:");
//     for (var cookie in savedCookies) {
//       if (cookie is Map<String, dynamic>) {
//         final name = cookie['name'];
//         if (name == "frontend" || name == "PHPSESSID" || name == "X-Magento-Vary") {
//           print("👉 $name = ${cookie['value']}");
//         }
//       }
//     }
//   }
//
//   Future<void> compareMagentoCookies(InAppWebViewController controller) async {
//     final prefs = await SharedPreferences.getInstance();
//     final cookiesJson = prefs.getString('guest_cart_cookies') ??
//         prefs.getString('user_cart_cookies');
//
//     if (cookiesJson == null) {
//       print("❌ No cookies found in SharedPreferences.");
//       return;
//     }
//
//     final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//
//     // Extract relevant cookies from SharedPreferences
//     final Map<String, String> saved = {};
//     for (var cookie in savedCookies) {
//       if (cookie is Map<String, dynamic>) {
//         final name = cookie['name'];
//         if (name == "frontend" || name == "PHPSESSID" || name == "X-Magento-Vary") {
//           saved[name] = cookie['value'];
//         }
//       }
//     }
//
//     // Extract cookies from WebView
//     final current = <String, String>{};
//     final webCookies = await CookieManager.instance()
//         .getCookies(url: WebUri("https://stage.aashniandco.com"));
//     for (var cookie in webCookies) {
//       if (cookie.name == "frontend" ||
//           cookie.name == "PHPSESSID" ||
//           cookie.name == "X-Magento-Vary") {
//         current[cookie.name] = cookie.value ?? "";
//       }
//     }
//
//     // Print side-by-side comparison
//     print("🔎 Magento Cookies Comparison:");
//     for (final key in ["frontend", "PHPSESSID", "X-Magento-Vary"]) {
//       print("👉 $key | Saved: ${saved[key] ?? '❌ Missing'} "
//           "| WebView: ${current[key] ?? '❌ Missing'}");
//     }
//   }
//   /// Inject cookies before loading page
//   Future<void> _setCookies(List<Map<String, dynamic>> cookies) async {
//     final cookieManager = CookieManager.instance();
//     print("Attempting to set ${cookies.length} cookies for WebView...");
//     for (final cookie in cookies) {
//       String effectiveDomain = cookie['domain'] ?? 'stage.aashniandco.com';
//       String effectivePath = cookie['path'] ?? '/';
//
//       // Special handling for PHPSESSID and isLogin to ensure domain matches
//       if (cookie['name'] == 'PHPSESSID' || cookie['name'] == 'isLogin') {
//         effectiveDomain = 'stage.aashniandco.com'; // Be explicit for the primary domain
//         effectivePath = '/'; // Often session cookies are for the root path
//       }
//
//       await cookieManager.setCookie(
//         url: WebUri("https://stage.aashniandco.com"),
//         name: cookie['name'],
//         value: cookie['value'],
//         domain: effectiveDomain,
//         path: effectivePath,
//         isSecure: cookie['secure'] ?? true,
//         isHttpOnly: cookie['httponly'] ?? false,
//         sameSite: HTTPCookieSameSitePolicy.LAX,
//       );
//       print("  Set WebView Cookie: ${cookie['name']} = ${cookie['value']}, domain=$effectiveDomain, path=$effectivePath, secure=${cookie['secure']}, httponly=${cookie['httponly']}");
//     }
//     print("All cookies processing attempted by _setCookies.");
//   }
//
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     try {
//       await _controller.evaluateJavascript(source: """
//         var stickyEl = document.getElementById('aashnisticky');
//         if (stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);
//
//         function removeByXPath(xpath) {
//           var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//           var el = result.singleNodeValue;
//           if (el && el.parentNode) el.parentNode.removeChild(el);
//         }
//
//         removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//         removeByXPath('/html/body/main/div/footer/div/div[3]');
//         removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//         ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//       """);
//       print("Web elements hidden.");
//     } catch (e) {
//       print("Error hiding web elements: $e");
//     }
//   }
//
//   String? extractOrderIdFromTitle(String title) {
//     final regex = RegExp(r'Order\s+#\s*(\d+)');
//     final match = regex.firstMatch(title);
//     return match != null ? match.group(1) : null;
//   }
//
//   Future<void> _sendMobileFlag(String orderId) async {
//     try {
//       final headers = {'Content-Type': 'application/json'};
//       final body = jsonEncode({"orderIncrementId": orderId});
//
//       // Print request details
//       print("➡️ POST Request:");
//       print("Headers: $headers");
//       print("Body: $body");
//
//       final response = await http.post(
//         Uri.parse('https://stage.aashniandco.com/rest/V1/mobile/order-flag'),
//         headers: headers,
//         body: body,
//       );
//
//       print("⬅️ Response:");
//       print("Status Code: ${response.statusCode}");
//       print("Body: ${response.body}");
//
//       print(response.statusCode == 200
//           ? "✅ Order flagged as mobile app"
//           : "⚠️ Failed to flag order: ${response.body}");
//     } catch (e) {
//       print("Error sending mobile flag: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.jpeg', height: 30), // Ensure 'assets/logo.jpeg' exists
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           Opacity(
//             opacity: isLoading ? 0 : 1,
//             child: InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//               onWebViewCreated: (controller) async {
//                 _controller = controller;
//                 print("WebView created, preparing to set cookies.");
//
//                 // ✅ Set cookies first
//                 await _setCookies(widget.cookies);
//                 // Significantly increase delay to ensure cookies are set BEFORE navigation begins
//                 await Future.delayed(const Duration(milliseconds: 1000)); // Try 1 second
//                 print("Delay after setting cookies completed.");
//
//                 // DEBUG: Verify cookies right after setting them and delay
//                 final preLoadCookies = await CookieManager.instance().getCookies(url: WebUri("https://stage.aashniandco.com"));
//                 print("🔵 Cookies just before loading URL (after delay):");
//                 for (var cookie in preLoadCookies) {
//                   print("${cookie.name} = ${cookie.value}, domain=${cookie.domain}, path=${cookie.path}, httponly=${cookie.isHttpOnly}");
//                 }
//                 print("About to load initial URL: ${widget.initialUrl}");
//                 // END DEBUG
//
//                 // Load checkout page
//                 await _controller.loadUrl(
//                   urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//                 );
//
//                 await _hideWebElements(isShippingPage: widget.initialUrl.contains("#shipping"));
//
//                 _controller.addJavaScriptHandler(
//                   handlerName: 'continueShopping',
//                   callback: (args) {
//                     print("JavaScript handler 'continueShopping' called.");
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const AuthScreen()),
//                     );
//                   },
//                 );
//
//                 await _controller.setSettings(
//                   settings: InAppWebViewSettings(
//                     javaScriptEnabled: true,
//                     userAgent: 'Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366',
//                     // Ensure these are enabled for complex web apps like Magento checkout
//                     javaScriptCanOpenWindowsAutomatically: true,
//                     useShouldOverrideUrlLoading: true,
//                     mediaPlaybackRequiresUserGesture: false,
//                     cacheEnabled: true,
//                     supportZoom: false,
//                   ),
//                 );
//                 print("WebView settings applied.");
//               },
//               onLoadStop: (controller, url) async {
//                 print("✅ WebView finished loading: $url");
//                 await compareMagentoCookies(controller);
//                 if (url == null) return; // Ensure URL is not null
//                 setState(() => isLoading = false);
//                 print("onLoadStop: Page finished loading: $url");
//
//                 // ✅ Debug WebView cookies
//                 final webViewCookies = await CookieManager.instance().getCookies(url: WebUri(url.toString()));
//                 print("🌐 WebView Cookies at $url:");
//                 for (var cookie in webViewCookies) {
//                   print("${cookie.name} = ${cookie.value}, domain=${cookie.domain}, path=${cookie.path}, httponly=${cookie.isHttpOnly}");
//                 }
//
//                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//
//                 // Keep the reload if necessary, but understand its impact
//                 // Only reload if not already refreshed AND not on the cart page (which would indicate an issue)
//                 // if (!hasRefreshed && !url.toString().contains("/checkout/cart/")) {
//                 //   hasRefreshed = true;
//                 //   Future.delayed(const Duration(seconds: 1), () async {
//                 //     try {
//                 //       print("Attempting to reload WebView after initial load (if not on cart page).");
//                 //       await _controller.reload();
//                 //     } catch (e) {
//                 //       print("Error reloading WebView: $e");
//                 //     }
//                 //   });
//                 // }
//                 // else if (url.toString().contains("/checkout/cart/") && !hasRefreshed) {
//                 //   // Log if it landed on cart page and wasn't manually refreshed yet
//                 //   print("⚠️ WebView landed on /checkout/cart/ on first load. This indicates a cookie/session issue.");
//                 //   // You might want to force a reload here too, but it often leads to loops if the underlying issue isn't fixed
//                 //   // If you want to try reloading here as well:
//                 //   // hasRefreshed = true;
//                 //   // Future.delayed(const Duration(seconds: 1), () async {
//                 //   //   try {
//                 //   //     print("Attempting to reload WebView after landing on cart page.");
//                 //   //     await _controller.reload();
//                 //   //   } catch (e) {
//                 //   //     print("Error reloading WebView from cart page: $e");
//                 //   //   }
//                 //   // });
//                 // }
//
//
//                 if (url.toString().contains("/checkout/onepage/success") ||
//                     url.toString().contains("#/order-success")) {
//                   print("Order success page detected.");
//                   await _sendMobileFlag(url.toString());
//
//                   await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//                   print("Continue Shopping button handler injected.");
//                 }
//               },
//               shouldOverrideUrlLoading: (controller, navigationAction) async {
//                 final requestedUrl = navigationAction.request.url.toString();
//                 print("Attempting to navigate to: $requestedUrl (from shouldOverrideUrlLoading)");
//
//                 // Prevent /checkout/cart/ navigation
//                 // This is commented out based on our debugging strategy.
//                 // Re-enable if you want to force redirect from cart page.
//                 // if (requestedUrl.contains("/checkout/cart/")) {
//                 //   print("Redirect detected to /checkout/cart/, attempting to force to #shipping.");
//                 //   await controller.loadUrl(
//                 //     urlRequest: URLRequest(url: WebUri("https://stage.aashniandco.com/checkout/#shipping")),
//                 //   );
//                 //   return NavigationActionPolicy.CANCEL;
//                 // }
//
//                 // Allow normal checkout pages or payment URLs
//                 if (requestedUrl.contains("/checkout/") ||
//                     requestedUrl.contains("paypal") ||
//                     requestedUrl.contains("stripe")) {
//                   print("Allowed navigation to: $requestedUrl");
//                   return NavigationActionPolicy.ALLOW;
//                 }
//
//                 print("⛔ Blocked navigation to: $requestedUrl (non-checkout/payment URL)");
//                 return NavigationActionPolicy.CANCEL;
//               },
//               initialOptions: InAppWebViewGroupOptions(
//                 crossPlatform: InAppWebViewOptions(
//                   javaScriptEnabled: true,
//                   javaScriptCanOpenWindowsAutomatically: true,
//                   useShouldOverrideUrlLoading: true,
//                   mediaPlaybackRequiresUserGesture: false,
//                   cacheEnabled: true,
//                   supportZoom: false,
//                 ),
//                 ios: IOSInAppWebViewOptions(
//                   allowsInlineMediaPlayback: true,
//                   allowsBackForwardNavigationGestures: true,
//                   allowsLinkPreview: false,
//                   allowsAirPlayForMediaPlayback: true,
//                   isFraudulentWebsiteWarningEnabled: false,
//                 ),
//                 android: AndroidInAppWebViewOptions(
//                   domStorageEnabled: true,
//                   mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//                 ),
//               ),
//             ),
//           ),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final List<Map<String, dynamic>> cookies;
//   final String selectedCurrency;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     required this.cookies,
//     required this.selectedCurrency,
//   }) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool _alreadyForcedShippingPage = false;
//
//   @override
//   void initState() {
//     super.initState();
//     print("WebViewScreen initialized with URL: ${widget.initialUrl}");
//   }
//
//   /// Apply cookies before loading URL
//   Future<void> _setCookies(List<Map<String, dynamic>> cookies) async {
//     final cookieManager = CookieManager.instance();
//
//     for (final cookie in cookies) {
//       await cookieManager.setCookie(
//         url: WebUri('https://stage.aashniandco.com'),
//         name: cookie['name'],
//         value: cookie['value'],
//         domain: 'stage.aashniandco.com',
//         path: cookie['path'] ?? '/',
//         isSecure: cookie['secure'] ?? true,
//         isHttpOnly: cookie['httponly'] ?? false,
//         sameSite: HTTPCookieSameSitePolicy.LAX,
//       );
//       print("Set WebView Cookie: ${cookie['name']} = ${cookie['value']}");
//     }
//
//     // Set currency cookie
//     await cookieManager.setCookie(
//       url: WebUri('https://stage.aashniandco.com'),
//       name: 'currency',
//       value: widget.selectedCurrency,
//       domain: 'stage.aashniandco.com',
//       path: '/',
//       isSecure: true,
//       isHttpOnly: false,
//       sameSite: HTTPCookieSameSitePolicy.LAX,
//     );
//     print("Currency cookie set: ${widget.selectedCurrency}");
//   }
//
//   /// Remove unwanted sticky elements
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     try {
//       await _controller.evaluateJavascript(source: """
//         var stickyEl = document.getElementById('aashnisticky');
//         if (stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);
//
//         function removeByXPath(xpath) {
//           var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//           var el = result.singleNodeValue;
//           if (el && el.parentNode) el.parentNode.removeChild(el);
//         }
//
//         removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//         removeByXPath('/html/body/main/div/footer/div/div[3]');
//         removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//         ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//       """);
//     } catch (e) {
//       print("Error hiding web elements: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.jpeg', height: 30),
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Stack(
//         children: [
//           Opacity(
//             opacity: isLoading ? 0 : 1,
//             child: InAppWebView(
//               initialUrlRequest: URLRequest(url: WebUri('about:blank')), // load blank first
//               onWebViewCreated: (controller) async {
//                 _controller = controller;
//
//                 // Apply cookies before loading actual URL
//                 await _setCookies(widget.cookies);
//
//                 // Wait briefly for iOS to register cookies
//                 await Future.delayed(const Duration(milliseconds: 300));
//
//                 // Load the actual URL
//                 await _controller.loadUrl(
//                   urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//                 );
//               },
//               onLoadStop: (controller, url) async {
//                 if (url == null) return;
//                 setState(() => isLoading = false);
//
//                 await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//               },
//               shouldOverrideUrlLoading: (controller, navigationAction) async {
//                 final requestedUrl = navigationAction.request.url.toString();
//                 print("Navigation attempt: $requestedUrl");
//
//                 // Handle Magento redirect from /checkout/cart → /checkout/#shipping
//                 if (requestedUrl.contains("/checkout/cart") && !_alreadyForcedShippingPage) {
//                   final cookies = await CookieManager.instance().getCookies(
//                     url: WebUri('https://stage.aashniandco.com'),
//                   );
//                   final hasSession = cookies.any((c) => c.name == 'PHPSESSID' && c.value.isNotEmpty);
//
//                   if (hasSession) {
//                     _alreadyForcedShippingPage = true;
//                     print("PHPSESSID exists, forcing shipping page once...");
//                     await controller.loadUrl(
//                       urlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//                     );
//                     return NavigationActionPolicy.CANCEL;
//                   }
//                 }
//
//                 // Prevent fragment-only loops on iOS
//                 if (requestedUrl.contains("#shipping")) {
//                   final currentUrl = (await _controller.getUrl())?.toString() ?? "";
//                   if (currentUrl.endsWith("#shipping")) {
//                     return NavigationActionPolicy.CANCEL;
//                   }
//                 }
//
//                 return NavigationActionPolicy.ALLOW;
//               },
//               initialOptions: InAppWebViewGroupOptions(
//                 crossPlatform: InAppWebViewOptions(
//                   javaScriptEnabled: true,
//                   javaScriptCanOpenWindowsAutomatically: true,
//                   useShouldOverrideUrlLoading: true,
//                   mediaPlaybackRequiresUserGesture: false,
//                   cacheEnabled: true,
//                   supportZoom: false,
//                 ),
//                 ios: IOSInAppWebViewOptions(
//                   allowsInlineMediaPlayback: true,
//                   allowsBackForwardNavigationGestures: true,
//                   allowsLinkPreview: false,
//                   allowsAirPlayForMediaPlayback: true,
//                   isFraudulentWebsiteWarningEnabled: false,
//                 ),
//                 android: AndroidInAppWebViewOptions(
//                   domStorageEnabled: true,
//                   mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//                 ),
//               ),
//             ),
//           ),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }



//19
class WebViewScreen extends StatefulWidget {
  final String initialUrl;
  final List<Map<String, dynamic>> cookies;

  const WebViewScreen({
    Key? key,
    required this.initialUrl,
    required this.cookies,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController _controller;
  bool isLoading = true;
  bool hasRefreshed = false;

  @override
  void initState() {
    super.initState();
    print("WebViewScreen initialized with URL: ${widget.initialUrl}");
    print("Initial cookies passed to WebViewScreen: ${json.encode(widget.cookies)}");
  }

  /// Helper: Set cookies for WebView
  Future<void> _setCookies(List<Map<String, dynamic>> cookies) async {
    final cookieManager = CookieManager.instance();
    print("Attempting to set ${cookies.length} cookies for WebView...");
    for (final cookie in cookies) {
      String domain = cookie['domain'] ?? 'stage.aashniandco.com';
      String path = cookie['path'] ?? '/';
      await cookieManager.setCookie(
        url: WebUri("https://stage.aashniandco.com"),
        name: cookie['name'],
        value: cookie['value'],
        domain: domain,
        path: path,
        isSecure: cookie['secure'] ?? true,
        isHttpOnly: cookie['httponly'] ?? false,
        sameSite: HTTPCookieSameSitePolicy.LAX,
      );
      print("Set WebView Cookie: ${cookie['name']} = ${cookie['value']}");
    }
    print("All cookies processed by _setCookies.");
  }

  /// Helper: Hide certain web elements
  Future<void> _hideWebElements({required bool isShippingPage}) async {
    try {
      await _controller.evaluateJavascript(source: """
        var stickyEl = document.getElementById('aashnisticky');
        if (stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);

        function removeByXPath(xpath) {
          var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
          var el = result.singleNodeValue;
          if (el && el.parentNode) el.parentNode.removeChild(el);
        }

        removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
        removeByXPath('/html/body/main/div/footer/div/div[3]');
        removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');

        ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
      """);
      print("Web elements hidden.");
    } catch (e) {
      print("Error hiding web elements: $e");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/logo.jpeg', height: 30),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: isLoading ? 0 : 1,
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
              onWebViewCreated: (controller) async {
                _controller = controller;
                print("WebView created, setting cookies...");
                await _setCookies(widget.cookies);
                await Future.delayed(const Duration(milliseconds: 1000));
              },
              onLoadStop: (controller, url) async {
                if (url == null) return;
                setState(() => isLoading = false);

                await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));

                if (url.toString().contains("/checkout/onepage/success") ||
                    url.toString().contains("#/order-success")) {
                  print("Order success page detected.");

                  // Try to extract order ID from title first
                  final title = await controller.getTitle();
                  String? orderId = extractOrderIdFromTitle(title ?? '');

                  // Fallback to URL
                  if (orderId == null) {
                    orderId = extractOrderIdFromUrl(url.toString());
                  }

                  if (orderId != null) {
                    print("Extracted Order ID: $orderId");
                    await _sendMobileFlag(orderId);
                  } else {
                    print("❌ Failed to extract order ID. Title: $title, URL: $url");
                  }

                  // Inject continue shopping button handler
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
                  print("Continue Shopping button handler injected.");
                }
              },
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                final requestedUrl = navigationAction.request.url.toString();
                print("Navigation attempt: $requestedUrl");

                if (requestedUrl.contains("/checkout/") ||
                    requestedUrl.contains("paypal") ||
                    requestedUrl.contains("stripe")) {
                  return NavigationActionPolicy.ALLOW;
                }

                print("Blocked navigation to: $requestedUrl");
                return NavigationActionPolicy.CANCEL;
              },
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                  useShouldOverrideUrlLoading: true,
                  mediaPlaybackRequiresUserGesture: false,
                  cacheEnabled: true,
                  supportZoom: false,
                ),
                ios: IOSInAppWebViewOptions(
                  allowsInlineMediaPlayback: true,
                  allowsBackForwardNavigationGestures: true,
                  allowsLinkPreview: false,
                  allowsAirPlayForMediaPlayback: true,
                  isFraudulentWebsiteWarningEnabled: false,
                ),
                android: AndroidInAppWebViewOptions(
                  domStorageEnabled: true,
                  mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
              ),
            ),
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}



// class WebViewScreen extends StatefulWidget {
//   final String initialUrl;
//   final List<Map<String, dynamic>> cookies;
//
//   const WebViewScreen({
//     Key? key,
//     required this.initialUrl,
//     required this.cookies,
//   }) : super(key: key);
//
//   @override
//   State<WebViewScreen> createState() => _WebViewScreenState();
// }
//
// class _WebViewScreenState extends State<WebViewScreen> {
//   late InAppWebViewController _controller;
//   bool isLoading = true;
//   bool hasRefreshed = false;
//
//   @override
//   void initState() {
//     super.initState();
//     debugMagentoCookies();
//     print("WebViewScreen initialized with URL: ${widget.initialUrl}");
//     print("Initial cookies passed: ${json.encode(widget.cookies)}");
//   }
//
//   /// Debug cookies from SharedPreferences
//   Future<void> debugMagentoCookies() async {
//     final prefs = await SharedPreferences.getInstance();
//     final cookiesJson = prefs.getString('guest_cart_cookies') ??
//         prefs.getString('user_cart_cookies');
//
//     if (cookiesJson == null) {
//       print("❌ No cookies found in SharedPreferences.");
//       return;
//     }
//
//     final List<dynamic> savedCookies = jsonDecode(cookiesJson);
//     print("🔎 Saved Magento cookies:");
//     for (var cookie in savedCookies) {
//       if (cookie is Map<String, dynamic>) {
//         final name = cookie['name'];
//         if (name == "frontend" || name == "PHPSESSID" || name == "X-Magento-Vary") {
//           print("👉 $name = ${cookie['value']}");
//         }
//       }
//     }
//   }
//
//   /// Set cookies for WebView
//   Future<void> _setCookies(List<Map<String, dynamic>> cookies) async {
//     final cookieManager = CookieManager.instance();
//     print("Setting ${cookies.length} cookies for WebView...");
//     for (final cookie in cookies) {
//       await cookieManager.setCookie(
//         url: WebUri("https://stage.aashniandco.com"),
//         name: cookie['name'],
//         value: cookie['value'],
//         domain: cookie['domain'] ?? 'stage.aashniandco.com',
//         path: cookie['path'] ?? '/',
//         isSecure: cookie['secure'] ?? true,
//         isHttpOnly: cookie['httponly'] ?? false,
//         sameSite: HTTPCookieSameSitePolicy.LAX,
//       );
//       print("  Set cookie: ${cookie['name']} = ${cookie['value']}");
//     }
//     await cookieManager.deleteAllCookies();
//     print("✅ All cookies flushed to WebView.");
//   }
//
//   /// Hide unwanted web elements
//   Future<void> _hideWebElements({required bool isShippingPage}) async {
//     try {
//       await _controller.evaluateJavascript(source: """
//         var stickyEl = document.getElementById('aashnisticky');
//         if(stickyEl && stickyEl.parentNode) stickyEl.parentNode.removeChild(stickyEl);
//
//         function removeByXPath(xpath){
//           var result = document.evaluate(xpath, document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
//           var el = result.singleNodeValue;
//           if(el && el.parentNode) el.parentNode.removeChild(el);
//         }
//
//         removeByXPath('/html/body/main/div/footer/div/div[2]/div/div');
//         removeByXPath('/html/body/main/div/footer/div/div[3]');
//         removeByXPath('/html/body/main/div/footer/div/div[1]/div/div');
//
//         ${isShippingPage ? "removeByXPath('/html/body/div[4]/header');" : ""}
//       """);
//       print("Web elements hidden.");
//     } catch (e) {
//       print("Error hiding web elements: $e");
//     }
//   }
//
//   /// Compare SharedPreferences cookies with WebView cookies
//   Future<void> compareMagentoCookies() async {
//     final webCookies = await CookieManager.instance().getCookies(
//       url: WebUri("https://stage.aashniandco.com"),
//     );
//     print("🌐 Current WebView cookies:");
//     for (var c in webCookies) {
//       print("${c.name}=${c.value}, domain=${c.domain}, path=${c.path}, httponly=${c.isHttpOnly}");
//     }
//   }
//
//   /// Force reload to #shipping if WebView lands on /checkout/cart/
//   Future<void> ensureShippingPage(String url) async {
//     if (url.contains("/checkout/cart/") && !hasRefreshed) {
//       hasRefreshed = true;
//       print("⚠️ Redirected to cart. Reloading to #shipping.");
//       await _controller.loadUrl(
//         urlRequest: URLRequest(url: WebUri("https://stage.aashniandco.com/checkout/#shipping")),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset('assets/logo.jpeg', height: 30),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Stack(
//         children: [
//           InAppWebView(
//             initialUrlRequest: URLRequest(url: WebUri(widget.initialUrl)),
//             onWebViewCreated: (controller) async {
//               _controller = controller;
//               print("WebView created, setting cookies...");
//
//               await _setCookies(widget.cookies);
//               await Future.delayed(const Duration(milliseconds: 500)); // small safety delay
//
//               print("Loading initial URL: ${widget.initialUrl}");
//               await _controller.loadUrl(urlRequest: URLRequest(url: WebUri(widget.initialUrl)));
//             },
//             onLoadStop: (controller, url) async {
//               if (url == null) return;
//               print("✅ Page loaded: $url");
//               setState(() => isLoading = false);
//
//               await compareMagentoCookies();
//               await _hideWebElements(isShippingPage: url.toString().contains("#shipping"));
//               await ensureShippingPage(url.toString());
//
//               // Inject continue shopping button handler if on success page
//               if (url.toString().contains("/checkout/onepage/success") ||
//                   url.toString().contains("#/order-success")) {
//                 await controller.evaluateJavascript(source: """
//                   document.querySelectorAll('a, button').forEach(function(el){
//                     if(el.innerText.includes('Continue Shopping')){
//                       el.onclick = function(){
//                         window.flutter_inappwebview.callHandler('continueShopping');
//                         return false;
//                       }
//                     }
//                   });
//                 """);
//               }
//             },
//             shouldOverrideUrlLoading: (controller, navigationAction) async {
//               final requestedUrl = navigationAction.request.url.toString();
//               if (requestedUrl.contains("/checkout/") ||
//                   requestedUrl.contains("paypal") ||
//                   requestedUrl.contains("stripe")) {
//                 return NavigationActionPolicy.ALLOW;
//               }
//               print("⛔ Blocked navigation to: $requestedUrl");
//               return NavigationActionPolicy.CANCEL;
//             },
//             initialOptions: InAppWebViewGroupOptions(
//               crossPlatform: InAppWebViewOptions(
//                 javaScriptEnabled: true,
//                 javaScriptCanOpenWindowsAutomatically: true,
//                 useShouldOverrideUrlLoading: true,
//                 mediaPlaybackRequiresUserGesture: false,
//                 cacheEnabled: true,
//                 supportZoom: false,
//               ),
//               ios: IOSInAppWebViewOptions(
//                 allowsInlineMediaPlayback: true,
//                 allowsBackForwardNavigationGestures: true,
//                 allowsLinkPreview: false,
//               ),
//               android: AndroidInAppWebViewOptions(
//                 domStorageEnabled: true,
//                 mixedContentMode: AndroidMixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
//               ),
//             ),
//           ),
//           if (isLoading) const Center(child: CircularProgressIndicator()),
//         ],
//       ),
//     );
//   }
// }
