import 'angel_editor_contract.dart';
import 'angel_javascript_bridge.dart';

/// Typed Dart facade over the serialized JavaScript command gate.
///
/// Flutter code talks only in editor commands. The transport remains free to
/// use `evaluateJavascript`, a JavaScript handler, or another WebView API.
class AngelEditorGateway {
  AngelEditorGateway(this._bridge);

  final AngelJavascriptBridge _bridge;

  Future<Object?> send(AngelEditorCommand command) =>
      _bridge.dispatch(command.name, command.payload);

  Future<Object?> synchronizeViewport({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
  }) => send(
    AngelEditorCommand.synchronizeViewport(viewport: viewport, camera: camera),
  );

  Future<Object?> projectWorldPoints({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
    required List<AngelVector3> points,
  }) => send(
    AngelEditorCommand.projectWorldPoints(
      viewport: viewport,
      camera: camera,
      points: points,
    ),
  );

  Future<Object?> unprojectScreenPoint({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
    required AngelSketchPlane plane,
    required double localX,
    required double localY,
    double planeOffset = 0,
  }) => send(
    AngelEditorCommand.unprojectScreenPoint(
      viewport: viewport,
      camera: camera,
      plane: plane,
      localX: localX,
      localY: localY,
      planeOffset: planeOffset,
    ),
  );

  Future<Object?> captureFrame() => send(AngelEditorCommand.captureFrame());

  Future<Object?> serializeScene() => send(AngelEditorCommand.serializeScene());

  Future<Object?> loadScene(Map<String, Object?> scene) =>
      send(AngelEditorCommand.loadScene(scene));
}
