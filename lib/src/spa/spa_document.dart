/// A decoded JSON object used by the legacy SPA format.
typedef SpaJsonObject = Map<String, Object?>;

/// The lossless, five-slot representation of an Angel SPA document.
///
/// Parsing and validation intentionally live outside this model. Each slot has
/// its own domain type while retaining its complete legacy JSON payload.
final class SpaDocument {
  const SpaDocument({
    required this.titleSegment,
    required this.edgeList,
    required this.reservedSlot,
    required this.imageList,
    required this.loftCollection,
  });

  final SpaTitleSegment titleSegment;
  final List<SpaEdgeRecord> edgeList;
  final SpaReservedSlot reservedSlot;
  final List<SpaImageRecord> imageList;
  final List<SpaLoftRecord> loftCollection;

  /// Reconstructs the exact five-slot shape required by legacy SPA writers.
  List<Object?> toJson() => <Object?>[
    titleSegment.toJson(),
    edgeList.map((record) => record.toJson()).toList(growable: false),
    reservedSlot.toJson(),
    imageList.map((record) => record.toJson()).toList(growable: false),
    loftCollection.map((record) => record.toJson()).toList(growable: false),
  ];
}

/// Metadata in slot 0, which legacy files store as either text or an object.
sealed class SpaTitleSegment {
  const SpaTitleSegment();

  const factory SpaTitleSegment.text(String value) = SpaTextTitleSegment;
  const factory SpaTitleSegment.fields(SpaJsonObject fields) =
      SpaObjectTitleSegment;

  Object toJson();
}

final class SpaTextTitleSegment extends SpaTitleSegment {
  const SpaTextTitleSegment(this.value);

  final String value;

  @override
  String toJson() => value;
}

final class SpaObjectTitleSegment extends SpaTitleSegment {
  const SpaObjectTitleSegment(this.fields);

  final SpaJsonObject fields;

  @override
  SpaJsonObject toJson() => fields;
}

/// One top-level record from the legacy edge-list slot.
///
/// Legacy files use both named objects and positional arrays.
final class SpaEdgeRecord {
  const SpaEdgeRecord(this.data);

  final Object data;

  Object toJson() => data;
}

/// Slot 2 is reserved, but real files may contain arbitrary legacy data.
final class SpaReservedSlot {
  const SpaReservedSlot(this.value);

  final Object? value;

  Object? toJson() => value;
}

/// One top-level record from the legacy image-list slot.
///
/// Legacy files use both named objects and positional arrays.
final class SpaImageRecord {
  const SpaImageRecord(this.data);

  final Object data;

  /// English display name recovered from either a positional or named record.
  String? get displayName {
    final metadata = switch (data) {
      final List<Object?> values when values.isNotEmpty => values.first,
      final Map<String, Object?> fields => fields,
      _ => null,
    };
    if (metadata is! Map) return null;
    return metadata.values.whereType<String>().firstOrNull;
  }

  Object toJson() => data;
}

/// One top-level record from the legacy loft-collection slot.
///
/// Legacy files use both named objects and positional arrays.
final class SpaLoftRecord {
  const SpaLoftRecord(this.data);

  final Object data;

  Object toJson() => data;
}
