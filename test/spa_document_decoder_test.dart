import 'dart:io';

import 'package:angel_papercrafts/src/spa/spa_document.dart';
import 'package:angel_papercrafts/src/spa/spa_document_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const decoder = SpaDocumentDecoder();

  group('SpaDocumentDecoder', () {
    test('decodes the bundled Boeing 777 document', () {
      final source = File(
        'assets/documents/samples/Boeing_777.SPA',
      ).readAsStringSync();

      final document = decoder.decode(
        source,
        sourcePath: 'assets/documents/samples/Boeing_777.SPA',
      );

      expect(document.titleSegment, isA<SpaObjectTitleSegment>());
      expect(document.edgeList, hasLength(4));
      expect(document.reservedSlot.value, isA<Map<String, Object?>>());
      expect(document.imageList, hasLength(10));
      expect(document.loftCollection, hasLength(15));
    });

    test('reports malformed JSON', () {
      expect(
        () => decoder.decode('[', sourcePath: 'broken.SPA'),
        throwsSpaError(SpaDecodeError.malformedJson),
      );
    });

    test('reports a missing fifth slot', () {
      expect(
        () => decoder.decode('[{}, [], null, []]', sourcePath: 'missing.SPA'),
        throwsSpaError(SpaDecodeError.invalidSlotCount),
      );
    });

    test('reports an invalid source path before parsing', () {
      expect(
        () => decoder.decode('not json', sourcePath: 'model.json'),
        throwsSpaError(SpaDecodeError.invalidPath),
      );
    });

    test('accepts only the strict legacy .SPA suffix', () {
      expect(SpaPathValidator.isSpaPath('model.SPA'), isTrue);
      expect(SpaPathValidator.isSpaPath('model.spa'), isFalse);
      expect(SpaPathValidator.isSpaPath(r'C:\models\aircraft.SpA'), isFalse);
    });

    test('rejects embedded, incomplete, and trailing suffix lookalikes', () {
      for (final path in <String>[
        '',
        '.SPA',
        'model.SPA.json',
        'folder.SPA/model',
        'model.SPA/',
        'model.SPA ',
      ]) {
        expect(SpaPathValidator.isSpaPath(path), isFalse, reason: path);
      }
    });

    test('reports a non-object record with its slot error', () {
      expect(
        () => decoder.decode(
          '["title", [1], null, [], []]',
          sourcePath: 'invalid.SPA',
        ),
        throwsSpaError(SpaDecodeError.invalidEdgeList),
      );
    });
  });
}

Matcher throwsSpaError(SpaDecodeError error) => throwsA(
  isA<SpaFormatException>().having(
    (exception) => exception.error,
    'error',
    error,
  ),
);
