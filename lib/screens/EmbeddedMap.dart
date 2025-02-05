import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class EmbeddedMap extends StatelessWidget {
  final String location; // Location as "latitude,longitude"

  const EmbeddedMap({Key? key, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Construct Google Maps URL
    String mapsUrl =
        "https://www.google.com/maps/search/?api=1&query=${Uri.encodeFull(location)}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: WebView(
        initialUrl: mapsUrl,
        javascriptMode: JavascriptMode.unrestricted, // Enable JavaScript
        onPageStarted: (url) {
          debugPrint("Loading: $url");
        },
        onPageFinished: (url) {
          debugPrint("Finished loading: $url");
        },
        onWebResourceError: (error) {
          debugPrint("Error loading page: ${error.description}");
        },
      ),
    );
  }
}
