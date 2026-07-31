import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  const viewportPath = 'assets/web/runtime/index.html';

  test('offline viewport references only bundled runtime assets', () {
    final html = File(viewportPath).readAsStringSync();

    expect(html, contains('src="../vendor/three.min.js"'));
    expect(html, contains("connect-src 'none'"));
    expect(html, isNot(contains(RegExp(r'https?://', caseSensitive: false))));
    expect(html, isNot(contains('//cdn.')));
    expect(html, isNot(contains('@import')));
  });

  test('offline viewport exposes a deterministic readiness contract', () {
    final html = File(viewportPath).readAsStringSync();

    expect(html, contains('window.__angelRuntime'));
    expect(html, contains("ready: true"));
    expect(
      html,
      contains("document.documentElement.dataset.angelReady = 'true'"),
    );
    expect(html, contains("'angel-three-ready'"));
    expect(html, contains('Offline Three.js r'));
    expect(html, contains('WebGL ready'));
  });

  test('offline viewport exposes the serialized command endpoint', () {
    final html = File(viewportPath).readAsStringSync();

    expect(html, contains('window.__angelBridge'));
    expect(html, contains('async dispatch(command)'));
    expect(html, contains("'angelRuntimeReady'"));
    expect(html, contains('flutterInAppWebViewPlatformReady'));
    expect(html, contains("window.__angelBridge.register('ping'"));
    for (final command in <String>[
      'synchronizeOrthographicViewport',
      'captureFrame',
      'serializeScene',
      'projectWorldPoints',
      'unprojectScreenPoint',
      'loadScene',
    ]) {
      expect(
        html,
        contains("'$command'"),
        reason: 'Missing runtime endpoint for Dart command $command',
      );
    }
  });

  test(
    'offline viewport renders and deterministically frames SPA geometry',
    () {
      final html = File(viewportPath).readAsStringSync();

      expect(html, contains("window.__angelBridge.register('loadScene'"));
      expect(html, contains('new THREE.HemisphereLight'));
      expect(html, contains('new THREE.DirectionalLight'));
      expect(html, contains('new THREE.Line('));
      expect(html, contains('new THREE.Mesh('));
      expect(html, contains('new THREE.Box3().setFromObject(modelRoot)'));
      expect(html, contains('bounds.getBoundingSphere'));
      expect(html, contains("emptyScene.dataset.visible = 'true'"));
      expect(html, contains("window.addEventListener('resize'"));
    },
  );
}
