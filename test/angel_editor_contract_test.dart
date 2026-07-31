import 'package:angel_papercrafts/renderer/angel_editor_contract.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('orthographic viewport contract', () {
    test('reproduces the legacy centered global-scale frustum', () {
      final viewport = AngelViewportMetrics(
        logicalWidth: 800,
        logicalHeight: 600,
        devicePixelRatio: 1.5,
      );
      final camera = AngelOrthographicCameraState(
        position: const AngelVector3(0, 0, 150),
        zoom: 2,
      );

      final frustum = camera.frustumFor(viewport);

      expect(frustum.left, -200);
      expect(frustum.right, 200);
      expect(frustum.top, 150);
      expect(frustum.bottom, -150);
    });

    test('synchronization always declares an orthographic projection', () {
      final viewport = AngelViewportMetrics(
        logicalWidth: 1024,
        logicalHeight: 640,
        devicePixelRatio: 2,
      );
      final camera = AngelOrthographicCameraState(
        position: const AngelVector3(12, 24, 48),
        rotation: const AngelEulerAngles(pitch: 0.2, yaw: 0.4),
      );

      final command = AngelEditorCommand.synchronizeViewport(
        viewport: viewport,
        camera: camera,
      );
      final cameraPayload = command.payload['camera']! as Map<String, Object>;

      expect(command.name, 'synchronizeOrthographicViewport');
      expect(cameraPayload['projection'], 'orthographic');
      expect(command.payload['viewport'], <String, double>{
        'logicalWidth': 1024,
        'logicalHeight': 640,
        'devicePixelRatio': 2,
      });
    });

    test('sketch unprojection carries the active plane and local point', () {
      final viewport = AngelViewportMetrics(
        logicalWidth: 900,
        logicalHeight: 500,
        devicePixelRatio: 1,
      );
      final camera = AngelOrthographicCameraState(
        position: const AngelVector3(0, 0, 100),
      );

      final command = AngelEditorCommand.unprojectScreenPoint(
        viewport: viewport,
        camera: camera,
        plane: AngelSketchPlane.xz,
        localX: 125,
        localY: 80,
        planeOffset: 4,
      );

      expect(command.name, 'unprojectScreenPoint');
      expect(command.payload['plane'], 'xz');
      expect(command.payload['localPoint'], <String, double>{
        'x': 125,
        'y': 80,
      });
      expect(command.payload['planeOffset'], 4);
    });
  });

  group('editor events', () {
    test('decodes typed WebView-to-Dart events', () {
      final event = AngelEditorEvent.fromJson(<String, Object?>{
        'type': 'frameCaptured',
        'requestId': 7,
        'payload': <String, Object?>{'dataUrl': 'data:image/jpeg;base64,abc'},
      });

      expect(event.type, AngelEditorEventType.frameCaptured);
      expect(event.requestId, 7);
      expect(event.payload['dataUrl'], startsWith('data:image/jpeg'));
    });

    test('rejects unknown event types', () {
      expect(
        () => AngelEditorEvent.fromJson(<String, Object?>{
          'type': 'legacyString',
          'payload': <String, Object?>{},
        }),
        throwsFormatException,
      );
    });
  });
}
