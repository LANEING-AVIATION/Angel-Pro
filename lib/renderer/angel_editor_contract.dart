/// Typed boundary between Flutter's editor state and the offline Three.js
/// viewport.
///
/// The legacy App Inventor application owned gestures, sketch geometry, and
/// document state. Its WebViewer owned the orthographic camera and rendered
/// scene. This contract keeps that separation while replacing ad-hoc
/// JavaScript string concatenation with serializable messages.
library;

enum AngelSketchPlane { xy, xz, yz }

enum AngelEditorEventType {
  ready,
  viewportSynchronized,
  frameCaptured,
  sceneSerialized,
  worldPointsProjected,
  screenPointUnprojected,
  error,
}

class AngelVector3 {
  const AngelVector3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  Map<String, double> toJson() => <String, double>{'x': x, 'y': y, 'z': z};
}

class AngelEulerAngles {
  const AngelEulerAngles({this.pitch = 0, this.yaw = 0, this.roll = 0});

  final double pitch;
  final double yaw;
  final double roll;

  Map<String, double> toJson() => <String, double>{
    'pitch': pitch,
    'yaw': yaw,
    'roll': roll,
  };
}

class AngelViewportMetrics {
  AngelViewportMetrics({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.devicePixelRatio,
  }) {
    if (logicalWidth <= 0 || logicalHeight <= 0) {
      throw ArgumentError('Viewport dimensions must be positive.');
    }
    if (devicePixelRatio <= 0) {
      throw ArgumentError.value(
        devicePixelRatio,
        'devicePixelRatio',
        'must be positive',
      );
    }
  }

  final double logicalWidth;
  final double logicalHeight;
  final double devicePixelRatio;

  Map<String, double> toJson() => <String, double>{
    'logicalWidth': logicalWidth,
    'logicalHeight': logicalHeight,
    'devicePixelRatio': devicePixelRatio,
  };
}

class AngelOrthographicFrustum {
  const AngelOrthographicFrustum({
    required this.left,
    required this.right,
    required this.top,
    required this.bottom,
    required this.near,
    required this.far,
  });

  final double left;
  final double right;
  final double top;
  final double bottom;
  final double near;
  final double far;

  Map<String, double> toJson() => <String, double>{
    'left': left,
    'right': right,
    'top': top,
    'bottom': bottom,
    'near': near,
    'far': far,
  };
}

class AngelOrthographicCameraState {
  AngelOrthographicCameraState({
    required this.position,
    this.rotation = const AngelEulerAngles(),
    this.zoom = 1,
    this.near = -10000,
    this.far = 400000,
  }) {
    if (zoom <= 0) {
      throw ArgumentError.value(zoom, 'zoom', 'must be positive');
    }
    if (near >= far) {
      throw ArgumentError('Camera near plane must be less than far plane.');
    }
  }

  final AngelVector3 position;
  final AngelEulerAngles rotation;

  /// Orthographic magnification.
  ///
  /// This replaces the legacy `globalScale`. The old generated camera used
  /// `PP = globalScale / 0.5`, yielding the same centered frustum calculated
  /// below without scaling the Flutter widget tree.
  final double zoom;
  final double near;
  final double far;

  AngelOrthographicFrustum frustumFor(AngelViewportMetrics viewport) {
    final halfWidth = viewport.logicalWidth / (2 * zoom);
    final halfHeight = viewport.logicalHeight / (2 * zoom);
    return AngelOrthographicFrustum(
      left: -halfWidth,
      right: halfWidth,
      top: halfHeight,
      bottom: -halfHeight,
      near: near,
      far: far,
    );
  }

  Map<String, Object> toJson(AngelViewportMetrics viewport) => <String, Object>{
    'projection': 'orthographic',
    'position': position.toJson(),
    'rotation': rotation.toJson(),
    'zoom': zoom,
    'frustum': frustumFor(viewport).toJson(),
  };
}

class AngelEditorCommand {
  const AngelEditorCommand(this.name, this.payload);

  final String name;
  final Map<String, Object?> payload;

  factory AngelEditorCommand.synchronizeViewport({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
  }) => AngelEditorCommand('synchronizeOrthographicViewport', <String, Object?>{
    'viewport': viewport.toJson(),
    'camera': camera.toJson(viewport),
  });

  factory AngelEditorCommand.captureFrame() =>
      const AngelEditorCommand('captureFrame', <String, Object?>{});

  factory AngelEditorCommand.serializeScene() =>
      const AngelEditorCommand('serializeScene', <String, Object?>{});

  factory AngelEditorCommand.loadScene(Map<String, Object?> scene) =>
      AngelEditorCommand('loadScene', scene);

  factory AngelEditorCommand.projectWorldPoints({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
    required List<AngelVector3> points,
  }) => AngelEditorCommand('projectWorldPoints', <String, Object?>{
    'viewport': viewport.toJson(),
    'camera': camera.toJson(viewport),
    'points': points.map((point) => point.toJson()).toList(growable: false),
  });

  factory AngelEditorCommand.unprojectScreenPoint({
    required AngelViewportMetrics viewport,
    required AngelOrthographicCameraState camera,
    required AngelSketchPlane plane,
    required double localX,
    required double localY,
    double planeOffset = 0,
  }) => AngelEditorCommand('unprojectScreenPoint', <String, Object?>{
    'viewport': viewport.toJson(),
    'camera': camera.toJson(viewport),
    'plane': plane.name,
    'localPoint': <String, double>{'x': localX, 'y': localY},
    'planeOffset': planeOffset,
  });
}

class AngelEditorEvent {
  const AngelEditorEvent({
    required this.type,
    required this.payload,
    this.requestId,
  });

  final AngelEditorEventType type;
  final Map<String, Object?> payload;
  final int? requestId;

  factory AngelEditorEvent.fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const FormatException('Angel editor event must be an object.');
    }
    final rawType = value['type'];
    final type = AngelEditorEventType.values
        .where((candidate) => candidate.name == rawType)
        .firstOrNull;
    if (type == null) {
      throw FormatException('Unknown Angel editor event type: $rawType');
    }
    final rawPayload = value['payload'];
    if (rawPayload is! Map<String, Object?>) {
      throw const FormatException(
        'Angel editor event payload must be an object.',
      );
    }
    final requestId = value['requestId'];
    if (requestId != null && requestId is! int) {
      throw const FormatException('Angel editor requestId must be an integer.');
    }
    final parsedRequestId = requestId is int ? requestId : null;
    return AngelEditorEvent(
      type: type,
      payload: Map<String, Object?>.unmodifiable(rawPayload),
      requestId: parsedRequestId,
    );
  }
}
