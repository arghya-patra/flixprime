import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VideoPlayerWebViewScreen extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWebViewScreen({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.red,
      ),
      body: WebViewWidget(
        controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(videoUrl)),
      ),
    );
  }
}
