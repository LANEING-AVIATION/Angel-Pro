import 'package:angel_papercrafts/src/spa/spa_document_decoder.dart';
import 'package:angel_papercrafts/src/spa/spa_startup_document_resolver.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const minimalSpa = '["title", [], null, [], []]';

  test('uses one valid external path when supplied', () async {
    final reads = <String>[];
    final resolver = SpaStartupDocumentResolver(
      readExternalText: (path) async {
        reads.add('external:$path');
        return minimalSpa;
      },
      readAssetText: (path) async {
        reads.add('asset:$path');
        return minimalSpa;
      },
    );

    final result = await resolver.resolve(externalPath: 'C:/models/test.SPA');

    expect(result.origin, SpaDocumentOrigin.externalFile);
    expect(result.sourcePath, 'C:/models/test.SPA');
    expect(reads, <String>['external:C:/models/test.SPA']);
  });

  test(
    'rejects an invalid external path without reading or falling back',
    () async {
      var readCount = 0;
      final resolver = SpaStartupDocumentResolver(
        readExternalText: (_) async {
          readCount++;
          return minimalSpa;
        },
        readAssetText: (_) async {
          readCount++;
          return minimalSpa;
        },
      );

      await expectLater(
        resolver.resolve(externalPath: 'test.json'),
        throwsA(
          isA<SpaFormatException>().having(
            (exception) => exception.error,
            'error',
            SpaDecodeError.invalidPath,
          ),
        ),
      );
      expect(readCount, 0);
    },
  );

  test('falls back to the bundled Boeing document', () async {
    final resolver = SpaStartupDocumentResolver(
      readExternalText: (_) => throw StateError('External read not expected'),
      readAssetText: rootBundle.loadString,
    );

    final result = await resolver.resolve();

    expect(result.origin, SpaDocumentOrigin.bundledSample);
    expect(result.sourcePath, 'assets/documents/samples/Boeing_777.SPA');
    expect(result.document.edgeList, hasLength(4));
    expect(result.document.imageList, hasLength(10));
    expect(result.document.loftCollection, hasLength(15));
  });
}
