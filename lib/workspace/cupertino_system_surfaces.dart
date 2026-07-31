import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'legacy_uikit_cupertino.dart';

Future<bool> showAngelConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String cancelLabel = 'Cancel',
  String confirmLabel = 'Confirm',
  bool destructive = false,
}) async =>
    await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDefaultAction: !destructive,
            isDestructiveAction: destructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    ) ??
    false;

class AngelContextAction {
  const AngelContextAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
    this.defaultAction = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
  final bool defaultAction;

  CupertinoContextMenuAction build() => CupertinoContextMenuAction(
    isDestructiveAction: destructive,
    isDefaultAction: defaultAction,
    onPressed: onPressed,
    child: Text(label),
  );
}

/// Shared dropdown built on Flutter's native Cupertino menu anchor.
class AngelCupertinoDropdown<T> extends StatelessWidget {
  const AngelCupertinoDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = 'Select',
  });

  final T? value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) => CupertinoMenuAnchor(
    constraints: const BoxConstraints(
      maxWidth: AngelCupertinoTokens.menuMaximumWidth,
      maxHeight: AngelCupertinoTokens.menuMaximumHeight,
    ),
    constrainCrossAxis: true,
    useRootOverlay: true,
    menuChildren: [
      for (final entry in items.entries)
        CupertinoMenuItem(
          key: ValueKey('cupertino-menu-item-${entry.key}'),
          trailing: entry.key == value
              ? const Icon(
                  CupertinoIcons.check_mark,
                  size: 16,
                  color: AngelCupertinoTokens.accent,
                )
              : null,
          onPressed: () => onChanged(entry.key),
          child: Text(
            entry.value,
            overflow: TextOverflow.ellipsis,
            style: AngelCupertinoTokens.bodyTextStyle,
          ),
        ),
    ],
    builder: (context, controller, child) => DecoratedBox(
      decoration: BoxDecoration(
        color: AngelCupertinoTokens.fillForLevel(3),
        borderRadius: BorderRadius.circular(AngelCupertinoTokens.level3Radius),
      ),
      child: CupertinoButton(
        minimumSize: Size.zero,
        padding: AngelCupertinoTokens.controlPadding,
        borderRadius: BorderRadius.circular(AngelCupertinoTokens.level3Radius),
        onPressed: items.isEmpty
            ? null
            : () => controller.isOpen ? controller.close() : controller.open(),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.list_bullet,
              size: 16,
              color: AngelCupertinoTokens.accent,
            ),
            const SizedBox(width: AngelCupertinoTokens.unit * 2),
            Expanded(
              child: Text(
                value == null ? placeholder : items[value] ?? placeholder,
                overflow: TextOverflow.ellipsis,
                style: AngelCupertinoTokens.compactTextStyle,
              ),
            ),
            const Icon(
              CupertinoIcons.chevron_down,
              size: 13,
              color: AngelCupertinoTokens.accent,
            ),
          ],
        ),
      ),
    ),
  );
}

class AngelCupertinoNotice {
  AngelCupertinoNotice._();

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(context);
    late final OverlayEntry entry;
    Timer? timer;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: 24,
        right: 24,
        bottom: 28,
        child: SafeArea(
          child: Center(
            child: CupertinoPopupSurface(
              isSurfacePainted: false,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AngelCupertinoTokens.noticeBackground,
                  borderRadius: BorderRadius.circular(
                    AngelCupertinoTokens.largeRadius,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AngelCupertinoTokens.unit * 4,
                    vertical: AngelCupertinoTokens.unit * 3,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: AngelCupertinoTokens.compactFontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    timer = Timer(duration, () {
      if (entry.mounted) entry.remove();
      timer?.cancel();
    });
  }
}
