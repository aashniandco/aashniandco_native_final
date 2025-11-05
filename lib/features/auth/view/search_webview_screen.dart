import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dummy_product_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class SearchWebViewScreen extends StatelessWidget {
  final String query;

  SearchWebViewScreen({required this.query});

  @override
  Widget build(BuildContext context) {
    String searchUrl = "https://www.aashniandco.com/catalogsearch/result/?q=$query";

    return Scaffold(
      appBar: AppBar(title: Text("Search: $query")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(searchUrl)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            javaScriptEnabled: true,
          ),
        ),
      ),
    );
  }
}

