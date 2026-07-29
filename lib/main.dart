import 'package:flutter/cupertino.dart';

void main() => runApp(const AngelProApp());

class AngelProApp extends StatelessWidget {
  const AngelProApp({super.key});

  @override
  Widget build(BuildContext context) => CupertinoApp(
    debugShowCheckedModeBanner: false,
    title: 'Angel Pro Papercraft Designer',
    theme: const CupertinoThemeData(brightness: Brightness.dark),
    home: const WorkspaceCanvas(),
  );
}

class WorkspaceCanvas extends StatelessWidget {
  const WorkspaceCanvas({super.key});

  @override
  Widget build(BuildContext context) => const CupertinoPageScaffold(
    backgroundColor: CupertinoColors.black,
    child: SizedBox.expand(),
  );
}
