import 'dart:async';
import 'dart:convert';

typedef JavascriptExecutor = Future<Object?> Function(String source);

/// Serializes scene mutations and holds them until the local renderer confirms
/// that Three.js and WebGL are ready.
class AngelJavascriptBridge {
  JavascriptExecutor? _executor;
  Completer<void> _ready = Completer<void>();
  Future<void> _commandTail = Future<void>.value();
  int _nextCommandId = 0;

  bool get isReady => _ready.isCompleted;

  void bindExecutor(JavascriptExecutor executor) {
    _executor = executor;
  }

  void resetReadiness() {
    _ready = Completer<void>();
  }

  void acceptReadyHandshake(Object? payload) {
    if (payload is! Map<String, Object?> ||
        payload['ready'] != true ||
        payload['renderer'] != 'webgl') {
      throw const FormatException('Invalid Angel renderer readiness payload.');
    }
    if (!_ready.isCompleted) {
      _ready.complete();
    }
  }

  Future<Object?> dispatch(
    String type, [
    Map<String, Object?> payload = const <String, Object?>{},
  ]) {
    if (type.trim().isEmpty) {
      return Future<Object?>.error(
        ArgumentError.value(type, 'type', 'must not be empty'),
      );
    }

    final result = Completer<Object?>();
    final envelope = jsonEncode(<String, Object?>{
      'id': ++_nextCommandId,
      'type': type,
      'payload': payload,
    });

    _commandTail = _commandTail.then((_) async {
      try {
        await _ready.future;
        final executor = _executor;
        if (executor == null) {
          throw StateError('No JavaScript executor is bound.');
        }
        final value = await executor(
          'window.__angelBridge.dispatch($envelope)',
        );
        result.complete(value);
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });

    return result.future;
  }
}
