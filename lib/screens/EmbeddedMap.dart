import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EmbeddedMap extends StatefulWidget {
  final String location; // Location in "latitude,longitude" format

  const EmbeddedMap({Key? key, required this.location}) : super(key: key);

  @override
  _EmbeddedMapState createState() => _EmbeddedMapState();
}

class _EmbeddedMapState extends State<EmbeddedMap> {
  late InAppWebViewController _webViewController;
  bool _isValid = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    String location = widget.location.trim();

    if (location.isEmpty) {
      _errorMessage = 'No location data available';
      return;
    }

    List<String> locationParts = location.split(',');
    if (locationParts.length != 2) {
      _errorMessage = 'Invalid location format';
      return;
    }

    String latitude = locationParts[0].trim();
    String longitude = locationParts[1].trim();
    String mapsUrl = "https://www.google.com/maps?q=$latitude,$longitude";

    // Load the URL with the location
    _isValid = true;

    // Call setState to refresh the widget and show the map
    setState(() {
      _errorMessage = null; // Reset error message when valid location is ready
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isValid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Food Truck Location')),
        body: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(
                "https://www.google.com/maps?q=${widget.location}"), // Pass the location URL here
          ),
          onWebViewCreated: (InAppWebViewController controller) {
            _webViewController = controller;
          },
          onReceivedError: (controller, request, error) {
            setState(() {
              _errorMessage = 'Error loading map: ${error.description}';
            });
          },
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(_errorMessage ?? 'Unknown error')),
      );
    }
  }
}
