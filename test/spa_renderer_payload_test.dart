import 'dart:io';

import 'package:angel_papercrafts/renderer/spa_renderer_payload.dart';
import 'package:angel_papercrafts/src/spa/spa_document.dart';
import 'package:angel_papercrafts/src/spa/spa_document_decoder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const converter = SpaRendererPayloadConverter();

  test('maps source XYZ to the legacy Three.js XZY convention', () {
    final payload = converter.convert(
      SpaDocument(
        titleSegment: const SpaTitleSegment.text('axes'),
        edgeList: const <SpaEdgeRecord>[
          SpaEdgeRecord(<Object?>[
            <Object?>[
              <Object?>[1, 2, 3],
            ],
            <String, Object?>{},
          ]),
        ],
        reservedSlot: const SpaReservedSlot(null),
        imageList: const <SpaImageRecord>[],
        loftCollection: const <SpaLoftRecord>[
          SpaLoftRecord(<Object?>[
            <Object?>[
              <Object?>[
                <Object?>[4, 5, 6],
              ],
            ],
            <Object?>[],
            <String, Object?>{},
          ]),
        ],
      ),
    );

    expect(payload.edges.single.points.single.toJson(), <double>[1, 3, 2]);
    expect(
      payload.lofts.single.profiles.single.points.single.toJson(),
      <double>[4, 6, 5],
    );
  });

  test('retains source indices in serialized renderer records', () {
    final document = const SpaDocument(
      titleSegment: SpaTitleSegment.text('indices'),
      edgeList: <SpaEdgeRecord>[
        SpaEdgeRecord(<Object?>[
          <Object?>[
            <Object?>[0, 0, 0],
          ],
        ]),
        SpaEdgeRecord(<Object?>[
          <Object?>[
            <Object?>[1, 1, 1],
          ],
        ]),
      ],
      reservedSlot: SpaReservedSlot(null),
      imageList: <SpaImageRecord>[],
      loftCollection: <SpaLoftRecord>[
        SpaLoftRecord(<Object?>[
          <Object?>[
            <Object?>[
              <Object?>[0, 0, 0],
            ],
            <Object?>[
              <Object?>[1, 1, 1],
            ],
          ],
        ]),
      ],
    );

    final payload = converter.convert(document);

    expect(payload.edges.map((edge) => edge.sourceIndex), <int>[0, 1]);
    expect(payload.lofts.single.sourceIndex, 0);
    expect(
      payload.lofts.single.profiles.map((profile) => profile.sourceIndex),
      <int>[0, 1],
    );
    expect(payload.toJson()['edges'], isA<List<Object?>>());
  });

  test('converts every bundled Boeing edge and loft profile', () {
    final source = File(
      'assets/documents/samples/Boeing_777.SPA',
    ).readAsStringSync();
    final document = const SpaDocumentDecoder().decode(
      source,
      sourcePath: 'assets/documents/samples/Boeing_777.SPA',
    );

    final payload = converter.convert(document);

    expect(payload.edges, hasLength(4));
    expect(payload.lofts, hasLength(15));
    expect(payload.edges.every((edge) => edge.points.length == 64), isTrue);
    expect(
      payload.lofts
          .expand((loft) => loft.profiles)
          .every((profile) => profile.points.length == 64),
      isTrue,
    );
    expect(payload.lofts.first.profiles, hasLength(4));
  });

  test('reports the precise source location of malformed coordinates', () {
    final document = const SpaDocument(
      titleSegment: SpaTitleSegment.text('invalid'),
      edgeList: <SpaEdgeRecord>[
        SpaEdgeRecord(<Object?>[
          <Object?>[
            <Object?>[1, 'bad', 3],
          ],
        ]),
      ],
      reservedSlot: SpaReservedSlot(null),
      imageList: <SpaImageRecord>[],
      loftCollection: <SpaLoftRecord>[],
    );

    expect(
      () => converter.convert(document),
      throwsA(
        isA<SpaRendererPayloadException>().having(
          (error) => error.message,
          'message',
          contains('edge 0 point 0'),
        ),
      ),
    );
  });
}
