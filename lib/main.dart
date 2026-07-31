import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'renderer/angel_editor_contract.dart';
import 'renderer/angel_editor_gateway.dart';
import 'renderer/angel_javascript_bridge.dart';
import 'renderer/spa_renderer_payload.dart';
import 'src/spa/spa_startup_document_resolver.dart';
import 'workspace/legacy_uikit_cupertino.dart';
import 'workspace/workspace_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await Window.initialize();
    await Window.setEffect(effect: WindowEffect.mica, dark: false);
  }
  runApp(const AngelProApp());
}

class AngelProApp extends StatelessWidget {
  const AngelProApp({super.key});

  @override
  Widget build(BuildContext context) => CupertinoApp(
    debugShowCheckedModeBanner: false,
    title: 'Angel Pro Papercraft Designer',
    theme: AngelCupertinoTokens.appTheme,
    home: const WorkspaceCanvas(),
  );
}

class WorkspaceCanvas extends StatefulWidget {
  const WorkspaceCanvas({super.key});

  @override
  State<WorkspaceCanvas> createState() => _WorkspaceCanvasState();
}

class _WorkspaceCanvasState extends State<WorkspaceCanvas> {
  final AngelJavascriptBridge _bridge = AngelJavascriptBridge();
  late final AngelEditorGateway _editor = AngelEditorGateway(_bridge);
  final SpaStartupDocumentResolver _resolver =
      SpaStartupDocumentResolver.forFlutter();
  bool _isLoading = true;
  List<String> _referenceColors = const ['White'];

  @override
  void initState() {
    super.initState();
    _loadStartupDocument();
  }

  Future<void> _loadStartupDocument() async {
    try {
      final resolved = await _resolver.resolve();
      final payload = const SpaRendererPayloadConverter().convert(
        resolved.document,
      );
      final referenceColors = resolved.document.imageList
          .map((record) => record.displayName)
          .whereType<String>()
          .toList(growable: false);
      if (mounted && referenceColors.isNotEmpty) {
        setState(() => _referenceColors = referenceColors);
      }
      final result = await _editor.loadScene(payload.toJson());
      debugPrint(
        '[Angel WebView] rendered ${resolved.sourcePath}; result=$result',
      );
    } catch (error, stackTrace) {
      debugPrintStack(
        label: '[Angel WebView] startup document failed: $error',
        stackTrace: stackTrace,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
    backgroundColor: CupertinoColors.transparent,
    child: WorkspaceShell(
      isLoading: _isLoading,
      referenceColors: _referenceColors,
      viewport: _buildWebViewport(),
    ),
  );

  Widget _buildWebViewport() => InAppWebView(
    initialFile: 'assets/web/runtime/index.html',
    initialSettings: _viewportSettings,
    onWebViewCreated: (controller) {
      _bridge.bindExecutor(
        (source) => controller.evaluateJavascript(source: source),
      );
      controller.addJavaScriptHandler(
        handlerName: 'angelRuntimeReady',
        callback: (arguments) {
          final payload = arguments.isEmpty ? null : arguments.first;
          _bridge.acceptReadyHandshake(payload);
          debugPrint('[Angel WebView] renderer handshake accepted');
          return <String, Object?>{'accepted': true};
        },
      );
      controller.addJavaScriptHandler(
        handlerName: 'angelEditorEvent',
        callback: (arguments) {
          final event = AngelEditorEvent.fromJson(
            arguments.isEmpty ? null : arguments.first,
          );
          debugPrint(
            '[Angel WebView] editor event ${event.type.name}'
            ' request=${event.requestId}',
          );
          return <String, Object?>{'accepted': true};
        },
      );
    },
    onLoadStart: (controller, url) {
      _bridge.resetReadiness();
    },
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
  );
}
