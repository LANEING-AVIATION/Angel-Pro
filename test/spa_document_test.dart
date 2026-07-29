import 'package:angel_papercrafts/src/spa/spa_document.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'reconstructs all five slots without dropping unknown nested fields',
    () {
      final document = SpaDocument(
        titleSegment: const SpaTitleSegment.fields(<String, Object?>{
          'name': 'Boeing 777',
          'unknownMetadata': <String, Object?>{'version': 3},
        }),
        edgeList: const <SpaEdgeRecord>[
          SpaEdgeRecord(<String, Object?>{
            '0': <Object?>[
              <String, Object?>{'customPointData': true},
            ],
          }),
        ],
        reservedSlot: const SpaReservedSlot(<String, Object?>{
          'legacyTexturePath': 'White.png',
        }),
        imageList: const <SpaImageRecord>[
          SpaImageRecord(<String, Object?>{
            'base64': 'data',
            'unknownUvMode': 'legacy',
          }),
        ],
        loftCollection: const <SpaLoftRecord>[
          SpaLoftRecord(<String, Object?>{
            'edges': <Object?>[1, 2],
            'unknownSurfaceData': <Object?>[true, null],
          }),
        ],
      );

      expect(document.toJson(), <Object?>[
        <String, Object?>{
          'name': 'Boeing 777',
          'unknownMetadata': <String, Object?>{'version': 3},
        },
        <Object?>[
          <String, Object?>{
            '0': <Object?>[
              <String, Object?>{'customPointData': true},
            ],
          },
        ],
        <String, Object?>{'legacyTexturePath': 'White.png'},
        <Object?>[
          <String, Object?>{'base64': 'data', 'unknownUvMode': 'legacy'},
        ],
        <Object?>[
          <String, Object?>{
            'edges': <Object?>[1, 2],
            'unknownSurfaceData': <Object?>[true, null],
          },
        ],
      ]);
    },
  );

  test('supports the legacy text title variant', () {
    const document = SpaDocument(
      titleSegment: SpaTitleSegment.text('Untitled'),
      edgeList: <SpaEdgeRecord>[],
      reservedSlot: SpaReservedSlot(null),
      imageList: <SpaImageRecord>[],
      loftCollection: <SpaLoftRecord>[],
    );

    expect(document.toJson(), <Object?>[
      'Untitled',
      <Object?>[],
      null,
      <Object?>[],
      <Object?>[],
    ]);
  });
}
