import '../src/spa/spa_document.dart';

final class SpaRendererPayload {
  const SpaRendererPayload({required this.edges, required this.lofts});

  final List<RendererEdge> edges;
  final List<RendererLoft> lofts;

  Map<String, Object?> toJson() => <String, Object?>{
    'edges': edges.map((edge) => edge.toJson()).toList(growable: false),
    'lofts': lofts.map((loft) => loft.toJson()).toList(growable: false),
  };
}

final class RendererEdge {
  const RendererEdge({required this.sourceIndex, required this.points});

  final int sourceIndex;
  final List<RendererPoint> points;

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceIndex': sourceIndex,
    'points': points.map((point) => point.toJson()).toList(growable: false),
  };
}

final class RendererLoft {
  const RendererLoft({required this.sourceIndex, required this.profiles});

  final int sourceIndex;
  final List<RendererLoftProfile> profiles;

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceIndex': sourceIndex,
    'profiles': profiles
        .map((profile) => profile.toJson())
        .toList(growable: false),
  };
}

final class RendererLoftProfile {
  const RendererLoftProfile({required this.sourceIndex, required this.points});

  final int sourceIndex;
  final List<RendererPoint> points;

  Map<String, Object?> toJson() => <String, Object?>{
    'sourceIndex': sourceIndex,
    'points': points.map((point) => point.toJson()).toList(growable: false),
  };
}

/// A Three.js point. Angel's source Y and Z axes are intentionally swapped.
final class RendererPoint {
  const RendererPoint(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;

  List<double> toJson() => <double>[x, y, z];
}

final class SpaRendererPayloadException implements FormatException {
  const SpaRendererPayloadException(this.message, [this.source]);

  @override
  final String message;

  @override
  final Object? source;

  @override
  int? get offset => null;
}

final class SpaRendererPayloadConverter {
  const SpaRendererPayloadConverter();

  SpaRendererPayload convert(SpaDocument document) => SpaRendererPayload(
    edges: List<RendererEdge>.unmodifiable(
      document.edgeList.indexed.map(
        (entry) => RendererEdge(
          sourceIndex: entry.$1,
          points: _points(_edgePoints(entry.$2.data), 'edge ${entry.$1}'),
        ),
      ),
    ),
    lofts: List<RendererLoft>.unmodifiable(
      document.loftCollection.indexed.map(
        (entry) => RendererLoft(
          sourceIndex: entry.$1,
          profiles: _loftProfiles(entry.$2.data, entry.$1),
        ),
      ),
    ),
  );

  Object? _edgePoints(Object data) {
    if (data case final List<Object?> values when values.isNotEmpty) {
      return values.first;
    }
    if (data case final Map<String, Object?> fields) {
      return fields['points'];
    }
    return null;
  }

  List<RendererLoftProfile> _loftProfiles(Object data, int loftIndex) {
    final Object? rawProfiles;
    if (data case final List<Object?> values when values.isNotEmpty) {
      rawProfiles = values.first;
    } else if (data case final Map<String, Object?> fields) {
      rawProfiles = fields['profiles'] ?? fields['edges'] ?? fields['points'];
    } else {
      rawProfiles = null;
    }
    if (rawProfiles is! List<Object?>) {
      throw SpaRendererPayloadException(
        'Loft $loftIndex does not contain a profile list.',
        data,
      );
    }

    return List<RendererLoftProfile>.unmodifiable(
      rawProfiles.indexed.map(
        (entry) => RendererLoftProfile(
          sourceIndex: entry.$1,
          points: _points(entry.$2, 'loft $loftIndex profile ${entry.$1}'),
        ),
      ),
    );
  }

  List<RendererPoint> _points(Object? data, String location) {
    if (data is! List<Object?>) {
      throw SpaRendererPayloadException(
        'The $location point collection is not a list.',
        data,
      );
    }
    return List<RendererPoint>.unmodifiable(
      data.indexed.map(
        (entry) => _point(entry.$2, '$location point ${entry.$1}'),
      ),
    );
  }

  RendererPoint _point(Object? data, String location) {
    if (data is! List<Object?> ||
        data.length < 3 ||
        data[0] is! num ||
        data[1] is! num ||
        data[2] is! num) {
      throw SpaRendererPayloadException(
        'The $location value must contain three numeric coordinates.',
        data,
      );
    }
    final sourceX = (data[0] as num).toDouble();
    final sourceY = (data[1] as num).toDouble();
    final sourceZ = (data[2] as num).toDouble();
    return RendererPoint(sourceX, sourceZ, sourceY);
  }
}
