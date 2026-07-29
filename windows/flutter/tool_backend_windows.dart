import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final targetPlatform = arguments[0];
  final buildMode = arguments[1].toLowerCase();
  final environment = Platform.environment;
  final flutterRoot = environment['FLUTTER_ROOT'];
  final projectDirectory = environment['PROJECT_DIR'];

  if (flutterRoot == null || projectDirectory == null) {
    stderr.writeln('FLUTTER_ROOT and PROJECT_DIR must be set.');
    exitCode = 1;
    return;
  }

  Directory.current = projectDirectory;
  final flutterTarget = environment['FLUTTER_TARGET'] ?? r'lib\main.dart';
  final dartObfuscation = environment['DART_OBFUSCATION'] == 'true';
  final trackWidgetCreation = environment['TRACK_WIDGET_CREATION'] == 'true';
  final treeShakeIcons = environment['TREE_SHAKE_ICONS'] == 'true';
  final dartDefines = environment['DART_DEFINES'];
  final flutterExecutable = [flutterRoot, 'bin', 'flutter.bat'].join(r'\');
  final childEnvironment = Map<String, String>.of(environment);
  final pathKey = environment.keys.firstWhere(
    (key) => key.toLowerCase() == 'path',
    orElse: () => 'Path',
  );
  childEnvironment[pathKey] =
      '${r'C:\Program Files\Git\cmd'};${environment[pathKey] ?? ''}';

  final process = await Process.start(flutterExecutable, [
    'assemble',
    '--no-version-check',
    '--output=build',
    '-dTargetPlatform=$targetPlatform',
    '-dTrackWidgetCreation=$trackWidgetCreation',
    '-dBuildMode=$buildMode',
    '-dTargetFile=$flutterTarget',
    '-dTreeShakeIcons="$treeShakeIcons"',
    '-dDartObfuscation=$dartObfuscation',
    if (dartDefines != null) '--DartDefines=$dartDefines',
    '${buildMode}_bundle_${targetPlatform}_assets',
  ], environment: childEnvironment);

  const decoder = Utf8Decoder(allowMalformed: true);
  process.stdout
      .transform(decoder)
      .transform(const LineSplitter())
      .listen(stdout.writeln);
  process.stderr
      .transform(decoder)
      .transform(const LineSplitter())
      .listen(stderr.writeln);

  final result = await process.exitCode;
  if (result != 0) {
    exitCode = result;
  }
}
