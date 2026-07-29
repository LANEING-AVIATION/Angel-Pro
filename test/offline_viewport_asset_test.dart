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
}
