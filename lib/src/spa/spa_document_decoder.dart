import 'dart:convert';

import 'spa_document.dart';

enum SpaDecodeError {
  invalidPath,
  malformedJson,
  invalidRoot,
  invalidSlotCount,
  invalidTitleSegment,
  invalidEdgeList,
  invalidImageList,
  invalidLoftCollection,
}

final class SpaFormatException implements FormatException {
  const SpaFormatException(
    this.error,
    this.message, [
    this.source,
    this.offset,
  ]);

  final SpaDecodeError error;

  @override
  final String message;

  @override
  final Object? source;

  @override
  final int? offset;

  @override
  String toString() => 'SpaFormatException($error): $message';
}

abstract final class SpaPathValidator {
  static bool isSpaPath(String path) {
    final separatorIndex = _lastSeparatorIndex(path);
    final fileName = path.substring(separatorIndex + 1);
    return fileName.length > '.SPA'.length && fileName.endsWith('.SPA');
  }

  static void requireSpaPath(String path) {
    if (!isSpaPath(path)) {
      throw SpaFormatException(
        SpaDecodeError.invalidPath,
        'Expected a file path ending in .SPA.',
        path,
      );
    }
  }

  static int _lastSeparatorIndex(String path) {
    final slashIndex = path.lastIndexOf('/');
    final backslashIndex = path.lastIndexOf(r'\');
    return slashIndex > backslashIndex ? slashIndex : backslashIndex;
  }
}

final class SpaDocumentDecoder {
  const SpaDocumentDecoder();

  SpaDocument decode(String source, {required String sourcePath}) {
    SpaPathValidator.requireSpaPath(sourcePath);

    final Object? decoded;
    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw SpaFormatException(
        SpaDecodeError.malformedJson,
        error.message,
        sourcePath,
        error.offset,
      );
    }

    if (decoded is! List<Object?>) {
      throw SpaFormatException(
        SpaDecodeError.invalidRoot,
        'The SPA root must be a JSON array.',
        sourcePath,
      );
    }
    if (decoded.length != 5) {
      throw SpaFormatException(
        SpaDecodeError.invalidSlotCount,
        'The SPA root must contain exactly five slots.',
        sourcePath,
      );
    }

    return SpaDocument(
      titleSegment: _decodeTitle(decoded[0], sourcePath),
      edgeList: _decodeRecords(
        decoded[1],
        sourcePath,
        SpaDecodeError.invalidEdgeList,
        SpaEdgeRecord.new,
      ),
      reservedSlot: SpaReservedSlot(decoded[2]),
      imageList: _decodeRecords(
        decoded[3],
        sourcePath,
        SpaDecodeError.invalidImageList,
        SpaImageRecord.new,
      ),
      loftCollection: _decodeRecords(
        decoded[4],
        sourcePath,
        SpaDecodeError.invalidLoftCollection,
        SpaLoftRecord.new,
      ),
    );
  }

  SpaTitleSegment _decodeTitle(Object? value, String sourcePath) {
    if (value is String) {
      return SpaTitleSegment.text(value);
    }
    final fields = _jsonObjectOrNull(value);
    if (fields != null) {
      return SpaTitleSegment.fields(fields);
    }
    throw SpaFormatException(
      SpaDecodeError.invalidTitleSegment,
      'SPA slot 0 must be a string or JSON object.',
      sourcePath,
    );
  }

  List<T> _decodeRecords<T>(
    Object? value,
    String sourcePath,
    SpaDecodeError error,
    T Function(Object data) create,
  ) {
    if (value is! List<Object?>) {
      throw SpaFormatException(
        error,
        'The SPA record slot must be a JSON array.',
        sourcePath,
      );
    }

    final records = <T>[];
    for (var index = 0; index < value.length; index++) {
      final data = _structuredRecordOrNull(value[index]);
      if (data == null) {
        throw SpaFormatException(
          error,
          'SPA record at index $index must be a JSON object or array.',
          sourcePath,
        );
      }
      records.add(create(data));
    }
    return List<T>.unmodifiable(records);
  }

  SpaJsonObject? _jsonObjectOrNull(Object? value) {
    if (value is! Map<dynamic, dynamic> ||
        value.keys.any((key) => key is! String)) {
      return null;
    }
    return Map<String, Object?>.unmodifiable(
      value.map((key, value) => MapEntry(key as String, value)),
    );
  }

  Object? _structuredRecordOrNull(Object? value) {
    final object = _jsonObjectOrNull(value);
    if (object != null) {
      return object;
    }
    if (value is List<Object?>) {
      return List<Object?>.unmodifiable(value);
    }
    return null;
  }
}
