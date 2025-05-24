import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebViewScreen extends StatefulWidget {
  @override
  _InAppWebViewScreenState createState() => _InAppWebViewScreenState();
}

class _InAppWebViewScreenState extends State<InAppWebViewScreen> {
  late InAppWebViewController webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: InAppWebView(
        initialUrlRequest:
            URLRequest(url: Uri.parse("https://flixprime.in/register")),
        onWebViewCreated: (controller) {
          webViewController = controller;
        },
      ),
    );
  }
}
