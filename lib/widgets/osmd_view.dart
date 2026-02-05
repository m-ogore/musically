import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:io' show Platform;
import 'package:provider/provider.dart';
import '../providers/player_provider.dart';
import '../providers/hymn_provider.dart';

class OsmdView extends StatefulWidget {
  final String musicXmlPath;
  final NotationViewMode mode;

  const OsmdView({
    super.key,
    required this.musicXmlPath,
    this.mode = NotationViewMode.fullSheet,
  });

  @override
  State<OsmdView> createState() => _OsmdViewState();
}

class _OsmdViewState extends State<OsmdView> {
  static String? _cachedHtmlContent;
  WebViewController? _controller;
  bool _isLoaded = false;
  bool _syncReady = false;
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

      await newController.addJavaScriptChannel(
        'OSMD',
        onMessageReceived: (message) {
          if (message.message == 'rendered') {
            if (mounted) {
              setState(() {
                _syncReady = true;
              });
            }
          }
        },
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
    if (_isLoaded && (oldWidget.musicXmlPath != widget.musicXmlPath || oldWidget.mode != widget.mode)) {
      _renderMusic();
    }
  }

  Future<void> _renderMusic() async {
    if (mounted) {
      setState(() {
        _syncReady = false;
      });
    }
    // Check for theme changes and update JS
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modeStr = widget.mode.toString().split('.').last;
    
    try {
      final xmlContent = await rootBundle.loadString(widget.musicXmlPath);
      final escapedXml = xmlContent.replaceAll('`', '\\`').replaceAll('\$', '\\\$');
      
      // Zoom is now handled dynamically in osmd_bridge.html
      // Pass mode (fullSheet / lineByLine) to JS
      await _controller?.runJavaScript('renderXML(`$escapedXml`, $isDarkMode, "$modeStr")');
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

    // Check for theme changes and update JS
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    _controller!.runJavaScript('setTheme($isDarkMode)');

    // Real-time audio sync
    final player = context.watch<PlayerProvider>();
    if (player.isPlaying && _isLoaded && _syncReady) {
      final positionMs = player.currentPosition.inMilliseconds;
      final durationMs = player.totalDuration.inMilliseconds;
      if (durationMs > 0) {
        _controller!.runJavaScript('syncToTime($positionMs, $durationMs)');
      }
    }

    return WebViewWidget(controller: _controller!);
  }
}
