import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() => runApp(const AngelProApp());

class AngelProApp extends StatelessWidget {
  const AngelProApp({super.key});

  @override
  Widget build(BuildContext context) => CupertinoApp(
    debugShowCheckedModeBanner: false,
    title: 'Angel Pro Papercraft Designer',
    theme: const CupertinoThemeData(brightness: Brightness.light),
    home: const WorkspaceCanvas(),
  );
}

class WorkspaceCanvas extends StatelessWidget {
  const WorkspaceCanvas({super.key});

  static final InAppWebViewSettings _viewportSettings = InAppWebViewSettings(
    javaScriptEnabled: true,
    hardwareAcceleration: true,
    cacheEnabled: false,
    blockNetworkLoads: true,
    disableContextMenu: true,
    disableLongPressContextMenuOnLinks: true,
    supportZoom: false,
    builtInZoomControls: false,
    displayZoomControls: false,
    disallowOverScroll: true,
    overScrollMode: OverScrollMode.NEVER,
    verticalScrollBarEnabled: false,
    horizontalScrollBarEnabled: false,
    allowsLinkPreview: false,
    contentInsetAdjustmentBehavior:
        ScrollViewContentInsetAdjustmentBehavior.NEVER,
    transparentBackground: false,
  );

  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    backgroundColor: CupertinoColors.systemBackground,
    child: SizedBox.expand(
      child: InAppWebView(
        initialFile: 'assets/web/runtime/index.html',
        initialSettings: _viewportSettings,
        onConsoleMessage: (controller, message) {
          debugPrint('[Angel WebView] ${message.message}');
        },
        onLoadStop: (controller, url) async {
          final runtime = await controller.evaluateJavascript(
            source: 'window.__angelRuntime ?? null',
          );
          debugPrint('[Angel WebView] loaded $url; runtime=$runtime');
        },
        onReceivedError: (controller, request, error) {
          debugPrint(
            '[Angel WebView] load error ${error.type}: ${error.description}',
          );
        },
      ),
    ),
  );
}
