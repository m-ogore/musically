import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show Platform;

class VexFlowRenderer extends StatefulWidget {
  final Map<String, dynamic> data;
  final bool singleSystem;
  final int? systemIndex;

  const VexFlowRenderer({
    super.key,
    required this.data,
    this.singleSystem = false,
    this.systemIndex,
  });

  @override
  State<VexFlowRenderer> createState() => _VexFlowRendererState();
}

class _VexFlowRendererState extends State<VexFlowRenderer> {
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

      
      // Initialize controller
      final newController = WebViewController.fromPlatformCreationParams(params);
      
      // Web/Linux/Windows might not support these specific platform casts
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
              _updateNotation();
            }
          },
        ),
      );

      // On Web, loadFlutterAsset is often unimplemented. 
      // We use loadHtmlString with inlined JS as a robust fallback.
      if (kIsWeb) {
        if (_cachedHtmlContent == null) {
          String htmlContent = await rootBundle.loadString('assets/notation/bridge.html');
          String jsContent = await rootBundle.loadString('assets/js/vexflow.js');
          
          // Inline the JS to avoid relative path issues in loadHtmlString
          _cachedHtmlContent = htmlContent.replaceFirst(
            '<script src="../js/vexflow.js"></script>',
            '<script>$jsContent</script>'
          );
        }
        
        await newController.loadHtmlString(_cachedHtmlContent!);
      } else {
        await newController.loadFlutterAsset('assets/notation/bridge.html');
      }
      
      if (mounted) {
        setState(() {
          _controller = newController;
        });
      }
    } catch (e) {
      debugPrint('WebView initialization error: $e');
      // If loadFlutterAsset fails, we might be on a platform that doesn't support it
      // like Linux Desktop or certain Web configurations.
    }
  }

  @override
  void didUpdateWidget(VexFlowRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isLoaded && (oldWidget.data != widget.data || oldWidget.systemIndex != widget.systemIndex)) {
      _updateNotation();
    }
  }

  void _updateNotation() {
    Map<String, dynamic> renderData = Map.from(widget.data);
    if (widget.singleSystem && widget.systemIndex != null) {
      final systems = renderData['systems'] as List;
      if (widget.systemIndex! < systems.length) {
        renderData['systems'] = [systems[widget.systemIndex!]];
        renderData['showAllSignatures'] = true;
      }
    }

    final jsonString = jsonEncode(renderData);
    _controller?.runJavaScript('renderHymn($jsonString)');
  }

  @override
  Widget build(BuildContext context) {
    if (_isUnsupportedPlatform) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 48, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Music notation is not supported on this platform (Desktop).',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Please use an Android emulator, iOS simulator, or Chrome for the full experience.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
    if (_controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WebViewWidget(controller: _controller!);
  }
}
