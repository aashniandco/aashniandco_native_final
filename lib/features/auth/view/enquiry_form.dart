import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EnquiryFormWebView extends StatefulWidget {
  final String productName; // e.g. "IQBAL HUSSAIN"

  const EnquiryFormWebView({Key? key, required this.productName}) : super(key: key);

  @override
  State<EnquiryFormWebView> createState() => _EnquiryFormWebViewState();
}

class _EnquiryFormWebViewState extends State<EnquiryFormWebView> {
  late final WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://stage.aashniandco.com/womens-clothing.html'))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            setState(() => isLoading = false);

            // 🔥 Try to auto-trigger the enquiry modal using JavaScript
            await _controller.runJavaScript('''
              const buttons = [...document.querySelectorAll('button, a')];
              const enquireButton = buttons.find(b => 
                b.innerText.toLowerCase().includes('enquire now') &&
                b.parentElement?.innerText?.includes('${widget.productName}')
              );
              if (enquireButton) enquireButton.click();
            ''');
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enquire: ${widget.productName}'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
