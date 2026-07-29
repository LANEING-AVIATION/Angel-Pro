import 'dart:io';

import 'package:flutter/services.dart';

import 'spa_document.dart';
import 'spa_document_decoder.dart';

typedef SpaTextReader = Future<String> Function(String path);

enum SpaDocumentOrigin { externalFile, bundledSample }

final class ResolvedSpaDocument {
  const ResolvedSpaDocument({
    required this.document,
    required this.sourcePath,
    required this.origin,
  });

  final SpaDocument document;
  final String sourcePath;
  final SpaDocumentOrigin origin;
}

/// Selects and decodes the one startup document independently of UI/platform
/// launch plumbing.
final class SpaStartupDocumentResolver {
  const SpaStartupDocumentResolver({
    required this.readExternalText,
    required this.readAssetText,
    this.decoder = const SpaDocumentDecoder(),
    this.bundledSamplePath = 'assets/documents/samples/Boeing_777.SPA',
  });

  factory SpaStartupDocumentResolver.forFlutter({
    AssetBundle? assetBundle,
    SpaDocumentDecoder decoder = const SpaDocumentDecoder(),
  }) {
    final bundle = assetBundle ?? rootBundle;
    return SpaStartupDocumentResolver(
      readExternalText: (path) => File(path).readAsString(),
      readAssetText: bundle.loadString,
      decoder: decoder,
    );
  }

  final SpaTextReader readExternalText;
  final SpaTextReader readAssetText;
  final SpaDocumentDecoder decoder;
  final String bundledSamplePath;

  Future<ResolvedSpaDocument> resolve({String? externalPath}) async {
    final sourcePath = externalPath ?? bundledSamplePath;
    final origin = externalPath == null
        ? SpaDocumentOrigin.bundledSample
        : SpaDocumentOrigin.externalFile;

    if (origin == SpaDocumentOrigin.externalFile) {
      SpaPathValidator.requireSpaPath(sourcePath);
    }

    final source = origin == SpaDocumentOrigin.externalFile
        ? await readExternalText(sourcePath)
        : await readAssetText(sourcePath);
    final document = decoder.decode(source, sourcePath: sourcePath);

    return ResolvedSpaDocument(
      document: document,
      sourcePath: sourcePath,
      origin: origin,
    );
  }
}
