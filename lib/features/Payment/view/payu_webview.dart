import 'package:flutter/material.dart';

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

  class PayUWebViewScreen extends StatefulWidget {
    // This screen needs the payment data (key, hash, txnid, etc.) to function.
    final Map<String, dynamic> paymentData;

    const PayUWebViewScreen({
      super.key,
      required this.paymentData,
    });

    @override
    State<PayUWebViewScreen> createState() => _PayUWebViewScreenState();
  }

  class _PayUWebViewScreenState extends State<PayUWebViewScreen> {
    // A GlobalKey is useful for programmatically controlling the WebView if needed.
    final GlobalKey webViewKey = GlobalKey();
    InAppWebViewController? webViewController;

    @override
    Widget build(BuildContext context) {
      // Use the PayU test URL. For production, change to 'https://secure.payu.in/_payment'
      // const payuUrl = 'https://test.payu.in/_payment';
      const payuUrl = 'https://secure.payu.in/_payment';


      return Scaffold(
        appBar: AppBar(
          title: const Text('Complete Your Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Pop the screen and return a 'Cancelled' status
              Navigator.pop(context, 'Cancelled');
            },
          ),
        ),
        body: InAppWebView(
          key: webViewKey,
          // The initial request is a POST request to the PayU URL.
          initialUrlRequest: URLRequest(
            url: WebUri(payuUrl),
            method: 'POST',
            body: _buildPostData(), // The payment data is sent as the body
            headers: {
              'Content-Type': 'application/x-www-form-urlencoded',
            },
          ),
          // This callback is triggered when the WebView starts to load a new URL.
          // It's the perfect place to check for our success/failure redirects.
          onLoadStart: (controller, url) {
            if (url != null) {
              String urlString = url.toString();

              // Check if PayU is redirecting to your success URL
              if (urlString.startsWith(widget.paymentData['surl'])) {
                // Stop the navigation
                controller.stopLoading();
                // Pop this screen and return 'Success' to the previous screen (PaymentScreen).
                Navigator.pop(context, 'Success');
              }
              // Check if PayU is redirecting to your failure URL
              else if (urlString.startsWith(widget.paymentData['furl'])) {
                // Stop the navigation
                controller.stopLoading();
                // Pop this screen and return 'Failure'.
                Navigator.pop(context, 'Failure');
              }
            }
          },
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      );
    }

    /// Helper function to convert the payment data map into a URL-encoded string.
    /// This is required for the POST request body.
    Uint8List _buildPostData() {
      // Ensure all values in the map are strings
      final Map<String, String> stringData = widget.paymentData.map(
            (key, value) => MapEntry(key, value.toString()),
      );

      // This creates a URL-encoded string like "key=value&txnid=123..."
      // and converts it to a Uint8List, which the `body` parameter expects.
      return Uint8List.fromList(Uri(queryParameters: stringData).query.codeUnits);
    }
  }