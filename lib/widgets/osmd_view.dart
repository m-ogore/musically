import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show Platform;

class OsmdView extends StatefulWidget {
  final String musicXmlPath;

  const OsmdView({
    super.key,
    required this.musicXmlPath,
  });

  @override
  State<OsmdView> createState() => _OsmdViewState();
}

class _OsmdViewState extends State<OsmdView> {
  static String? _cachedHtmlContent;
  WebViewController? _controller;
  bool _isLoaded = false;
  bool _isUnsupportedPlatform = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
      setState(() {
        _isUnsupportedPlatform = true;
      });
      return;
    }

    try {
      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }

      final newController = WebViewController.fromPlatformCreationParams(params);
      
      try {
        if (!kIsWeb && newController.platform is AndroidWebViewController) {
          AndroidWebViewController.enableDebugging(true);
          (newController.platform as AndroidWebViewController)
              .setMediaPlaybackRequiresUserGesture(false);
        }
      } catch (_) {}

      if (!kIsWeb) {
        try {
          await newController.setJavaScriptMode(JavaScriptMode.unrestricted);
        } catch (_) {}
        
        try {
          await newController.setBackgroundColor(Colors.transparent);
        } catch (_) {}
      }

      await newController.setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoaded = true;
              });
              _renderMusic();
            }
          },
        ),
      );

      if (_cachedHtmlContent == null) {
        String htmlContent = await rootBundle.loadString('assets/notation/osmd_bridge.html');
        String jsContent = await rootBundle.loadString('assets/js/opensheetmusicdisplay.min.js');
        
        // Inline the JS to avoid relative path issues
        _cachedHtmlContent = htmlContent.replaceFirst(
          '<script src="../js/opensheetmusicdisplay.min.js"></script>',
          '<script>$jsContent</script>'
        );
      }
      
      await newController.loadHtmlString(_cachedHtmlContent!);
      
      if (mounted) {
        setState(() {
          _controller = newController;
        });
      }
    } catch (e) {
      debugPrint('OSMD WebView initialization error: $e');
    }
  }

  @override
  void didUpdateWidget(OsmdView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLoaded && oldWidget.musicXmlPath != widget.musicXmlPath) {
      _renderMusic();
    }
  }

  Future<void> _renderMusic() async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    try {
      final xmlContent = await rootBundle.loadString(widget.musicXmlPath);
      final escapedXml = xmlContent.replaceAll('`', '\\`').replaceAll('\$', '\\\$');
      // Reduced zoom to ensure notation fits within screen width
      double zoom = width < 400 ? 0.5 : 0.6;
      
      await _controller?.runJavaScript('renderXML(`$escapedXml`, $isDarkMode, $zoom)');
    } catch (e) {
      debugPrint('OSMD Render error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnsupportedPlatform) {
      return const Center(child: Text('OSMD not supported on this platform.'));
    }
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WebViewWidget(controller: _controller!);
  }
}
