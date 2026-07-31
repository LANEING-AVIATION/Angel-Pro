import 'dart:async';

import 'package:angel_papercrafts/renderer/angel_javascript_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('holds commands until a valid WebGL readiness handshake', () async {
    final calls = <String>[];
    final bridge = AngelJavascriptBridge()
      ..bindExecutor((source) async {
        calls.add(source);
        return 'done';
      });

    final pending = bridge.dispatch('ping');
    await Future<void>.delayed(Duration.zero);
    expect(calls, isEmpty);

    bridge.acceptReadyHandshake(<String, Object?>{
      'ready': true,
      'renderer': 'webgl',
      'threeRevision': '130',
    });

    expect(await pending, 'done');
    expect(calls.single, contains('"type":"ping"'));
  });

  test('serializes commands and preserves submission order', () async {
    final firstRelease = Completer<void>();
    final calls = <String>[];
    final bridge = AngelJavascriptBridge()
      ..bindExecutor((source) async {
        calls.add(source);
        if (calls.length == 1) {
          await firstRelease.future;
        }
        return calls.length;
      })
      ..acceptReadyHandshake(<String, Object?>{
        'ready': true,
        'renderer': 'webgl',
      });

    final first = bridge.dispatch('first');
    final second = bridge.dispatch('second');
    await Future<void>.delayed(Duration.zero);
    expect(calls, hasLength(1));

    firstRelease.complete();
    await Future.wait<Object?>(<Future<Object?>>[first, second]);
    expect(calls, hasLength(2));
    expect(calls[0], contains('"id":1'));
    expect(calls[1], contains('"id":2'));
  });

  test('a failed command does not stall the queue', () async {
    var callCount = 0;
    final bridge = AngelJavascriptBridge()
      ..bindExecutor((_) async {
        callCount++;
        if (callCount == 1) {
          throw StateError('command failed');
        }
        return 'recovered';
      })
      ..acceptReadyHandshake(<String, Object?>{
        'ready': true,
        'renderer': 'webgl',
      });

    await expectLater(bridge.dispatch('fails'), throwsStateError);
    expect(await bridge.dispatch('next'), 'recovered');
  });

  test('rejects malformed readiness payloads', () {
    final bridge = AngelJavascriptBridge();

    expect(
      () => bridge.acceptReadyHandshake(<String, Object?>{
        'ready': true,
        'renderer': 'unavailable',
      }),
      throwsFormatException,
    );
    expect(bridge.isReady, isFalse);
  });
}
