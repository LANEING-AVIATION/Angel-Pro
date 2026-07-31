import 'package:flutter/cupertino.dart';

/// System-wide iPadOS 15 design decisions for the migrated workspace.
///
/// Every legacy UIKIT adapter and every surrounding workspace surface consumes
/// this single token set. The four-point grid keeps unrelated controls aligned
/// while the native system font and Cupertino controls provide the platform
/// appearance without a bundled font or bitmap command icon.
abstract final class AngelCupertinoTokens {
  static const double unit = 4;
  static const double hairline = 0.5;
  static const double toolbarHeight = componentExtent + hierarchyGap * 2;
  static const double toolbarLeadingWidth = 96;
  static const double toolbarGap = 8;
  static const double toolbarCommandWidth = 44;
  static const double toolbarTextFieldWidth = 160;
  static const double minimumToolbarWidth = 520;
  static const double inspectorWidth = 280;
  static const double minimumViewportWidth = 320;
  static const double compactWorkAreaBreakpoint =
      minimumViewportWidth + inspectorWidth;
  static const double compactInspectorHeightFraction = 0.44;
  static const double minimumCompactViewportHeight = 180;
  static const double minimumCompactInspectorHeight = 160;
  static const double inspectorPaddingValue = 16;
  static const double buttonRowGap = 4;
  static const double hierarchyGap = 2;
  static const double internalSpacing = hierarchyGap;
  static const double moduleSpacing = 16;
  static const double componentExtent = 50;
  static const double controlHeight = componentExtent;
  static const double controlOuterHeight = componentExtent + hierarchyGap * 2;
  static const double valueRowHeight = componentExtent;
  static const double sectionCaptionHeight = 24;
  static const double toolbarItemExtent = componentExtent;
  static const double segmentItemExtent = componentExtent;
  static const double wideSelectorWidth = 240;
  static const double segmentedControlHeight = componentExtent;
  static const double sectionHeaderHeight = componentExtent;
  static const double iconSize = 18;
  static const double bodyFontSize = 12;
  static const double compactFontSize = 12;
  static const double titleFontSize = 17;
  static const double level1Radius = 6;
  static const double level2Radius = 4;
  static const double level3Radius = 2;
  static const double controlRadius = level2Radius;
  static const double panelRadius = level2Radius;
  static const double largeRadius = 12;
  static const double menuMaximumWidth = 320;
  static const double menuMaximumHeight = 360;
  static const double compactLeadingWidth = 58;
  static const double actionRadius = 11;

  static const Color accent = Color(0xFF54739B);
  static const Color accentPressed = Color(0xFF425C7C);
  static const Color accentTint = Color(0x1A54739B);
  static const Color accentSurface = Color(0xB354739B);
  static const Color accentPressedSurface = Color(0xCC425C7C);
  static const Color groupedBackground = CupertinoColors.transparent;
  static const Color inspectorBackground = CupertinoColors.transparent;
  static const Color secondaryGroupedBackground = Color(0xBFFFFFFF);
  static const Color toolbarBackground = CupertinoColors.transparent;
  static const Color controlFill = Color(0x73FFFFFF);
  static const Color controlFillPressed = Color(0xA6FFFFFF);
  static const Color segmentedBackground = Color(0x33787880);
  static const Color label = Color(0xFF1C1C1E);
  static const Color secondaryLabel = Color(0xFF636366);
  static const Color tertiaryLabel = Color(0xFF8E8E93);
  static const Color separator = Color(0x4A3C3C43);
  static const Color switchTrack = Color(0xFFAEAEB2);
  static const Color noticeBackground = Color(0xE61C1C1E);
  static const Color hierarchyBase = Color(0xE6FFFFFF);
  static const double hierarchyOverlayOpacity = 0.08;

  static double radiusForLevel(int level) => switch (level) {
    1 => level1Radius,
    2 => level2Radius,
    3 => level3Radius,
    _ => 0,
  };

  static Color fillForLevel(int level) {
    var result = hierarchyBase;
    for (var depth = 0; depth < level; depth++) {
      result = Color.alphaBlend(
        CupertinoColors.black.withValues(alpha: hierarchyOverlayOpacity),
        result,
      );
    }
    return result;
  }

  static const EdgeInsets controlPadding = EdgeInsets.symmetric(
    horizontal: unit * 3,
  );
  static const EdgeInsets sectionPadding = EdgeInsets.symmetric(
    horizontal: unit * 3,
  );
  static const EdgeInsets inspectorPadding = EdgeInsets.all(
    inspectorPaddingValue,
  );

  static const Duration fastMotion = Duration(milliseconds: 100);
  static const Duration regularMotion = Duration(milliseconds: 250);
  static const Duration springMotion = Duration(milliseconds: 350);

  static const Border controlBorder = Border.fromBorderSide(
    BorderSide(color: separator, width: hairline),
  );
  static const TextStyle bodyTextStyle = TextStyle(
    color: label,
    fontSize: bodyFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );
  static const TextStyle compactTextStyle = TextStyle(
    color: secondaryLabel,
    fontSize: compactFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
  );
  static const TextStyle sectionTitleTextStyle = TextStyle(
    color: label,
    fontSize: bodyFontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
  );

  static const CupertinoThemeData appTheme = CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: accent,
    primaryContrastingColor: CupertinoColors.white,
    barBackgroundColor: toolbarBackground,
    scaffoldBackgroundColor: groupedBackground,
    textTheme: CupertinoTextThemeData(
      primaryColor: accent,
      textStyle: bodyTextStyle,
      actionTextStyle: TextStyle(
        color: accent,
        fontSize: bodyFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      navTitleTextStyle: TextStyle(
        color: label,
        fontSize: titleFontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
      ),
    ),
  );
}

enum AngelButtonRole { inspector, selected, toolbar }

/// Cupertino-rendered alternative to the legacy UIKIT classic button.
///
/// Geometry belongs to the parent grid. The role controls whether this leaf is
/// an opaque inspector action, an active selection, or an unboxed toolbar item.
class LegacyUiKitButton extends StatefulWidget {
  const LegacyUiKitButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.width = AngelCupertinoTokens.componentExtent,
    this.height = AngelCupertinoTokens.controlHeight,
    this.role = AngelButtonRole.inspector,
    this.borderRadius = AngelCupertinoTokens.controlRadius,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final double width;
  final double height;
  final AngelButtonRole role;
  final double borderRadius;

  @override
  State<LegacyUiKitButton> createState() => _LegacyUiKitButtonState();
}

class _LegacyUiKitButtonState extends State<LegacyUiKitButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (widget.onPressed == null) return;
    _setPressed(true);
  }

  void _handlePointerUp(PointerUpEvent event) {
    _setPressed(false);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    _setPressed(false);
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.role == AngelButtonRole.selected;
    final isToolbar = widget.role == AngelButtonRole.toolbar;
    final foregroundColor = isSelected
        ? CupertinoColors.white
        : AngelCupertinoTokens.label;
    final backgroundColor = isToolbar
        ? CupertinoColors.transparent
        : isSelected
        ? (_pressed
              ? AngelCupertinoTokens.accentPressedSurface
              : AngelCupertinoTokens.accentSurface)
        : (_pressed
              ? Color.alphaBlend(
                  AngelCupertinoTokens.controlFillPressed,
                  AngelCupertinoTokens.fillForLevel(2),
                )
              : AngelCupertinoTokens.fillForLevel(2));

    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _handlePointerDown,
        onPointerUp: _handlePointerUp,
        onPointerCancel: _handlePointerCancel,
        child: CupertinoButton(
          minimumSize: Size.zero,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          pressedOpacity: 1,
          onPressed: widget.onPressed,
          child: AnimatedScale(
            scale: _pressed ? 0.97 : 1,
            duration: AngelCupertinoTokens.fastMotion,
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: AngelCupertinoTokens.fastMotion,
              width: widget.width,
              height: widget.height,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: isToolbar
                    ? BorderRadius.zero
                    : BorderRadius.circular(widget.borderRadius),
              ),
              child: IconTheme(
                data: IconThemeData(color: foregroundColor),
                child: DefaultTextStyle(
                  style: TextStyle(
                    color: foregroundColor,
                    fontSize: AngelCupertinoTokens.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cupertino-rendered alternative to the UIKIT simple rectangle.
class LegacyUiKitPanel extends StatelessWidget {
  const LegacyUiKitPanel({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    margin: margin,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: AngelCupertinoTokens.fillForLevel(2),
      borderRadius: BorderRadius.circular(AngelCupertinoTokens.panelRadius),
      border: AngelCupertinoTokens.controlBorder,
    ),
    padding: const EdgeInsets.all(AngelCupertinoTokens.hierarchyGap),
    child: child,
  );
}

/// Cupertino-rendered alternative to the UIKIT checkbox-bound toggle button.
class LegacyUiKitToggleButton extends StatelessWidget {
  const LegacyUiKitToggleButton({
    super.key,
    required this.isActive,
    required this.onToggle,
    required this.child,
    this.width = AngelCupertinoTokens.toolbarItemExtent,
    this.height = AngelCupertinoTokens.controlHeight,
  });

  final bool isActive;
  final VoidCallback onToggle;
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => Semantics(
    toggled: isActive,
    child: LegacyUiKitButton(
      onPressed: onToggle,
      width: width,
      height: height,
      role: isActive ? AngelButtonRole.selected : AngelButtonRole.inspector,
      child: child,
    ),
  );
}

/// Cupertino switch header for the legacy switch-controlled function group.
class LegacyUiKitFunctionGroupHeader extends StatelessWidget {
  const LegacyUiKitFunctionGroupHeader({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.width = AngelCupertinoTokens.inspectorWidth,
    this.height = AngelCupertinoTokens.sectionHeaderHeight,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AngelCupertinoTokens.fillForLevel(2),
        border: const Border(
          bottom: BorderSide(
            color: AngelCupertinoTokens.separator,
            width: AngelCupertinoTokens.hairline,
          ),
        ),
      ),
      child: CupertinoListTile(
        padding: AngelCupertinoTokens.sectionPadding,
        leadingSize: 28,
        leadingToTitle: AngelCupertinoTokens.unit * 2,
        leading: SizedBox.square(
          dimension: 28,
          child: Icon(icon, color: AngelCupertinoTokens.accent, size: 18),
        ),
        title: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AngelCupertinoTokens.sectionTitleTextStyle,
        ),
        trailing: CupertinoSwitch(
          value: value,
          activeTrackColor: AngelCupertinoTokens.accent,
          inactiveTrackColor: AngelCupertinoTokens.switchTrack,
          thumbColor: CupertinoColors.white,
          inactiveThumbColor: CupertinoColors.white,
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

/// State-preserving body for the legacy switch-controlled function group.
class LegacyUiKitFunctionGroupBody extends StatelessWidget {
  const LegacyUiKitFunctionGroupBody({
    super.key,
    required this.isExpanded,
    required this.child,
  });

  final bool isExpanded;
  final Widget child;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    excluding: !isExpanded,
    child: IgnorePointer(
      ignoring: !isExpanded,
      child: AnimatedSize(
        duration: AngelCupertinoTokens.regularMotion,
        curve: Curves.easeInOutCubic,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: isExpanded ? 1 : 0,
            child: ColoredBox(
              color: AngelCupertinoTokens.groupedBackground,
              child: AnimatedOpacity(
                opacity: isExpanded ? 1 : 0,
                duration: AngelCupertinoTokens.regularMotion,
                curve: Curves.easeInOut,
                child: child,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// Cupertino alternative to the UIKIT bar selector.
///
/// Selection is mutually exclusive and rendered by the native iPadOS sliding
/// segmented control used by SwiftUI's segmented picker style.
class LegacyUiKitSingleSelectionBar<T extends Object> extends StatelessWidget {
  const LegacyUiKitSingleSelectionBar({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.width = AngelCupertinoTokens.segmentItemExtent * 3,
    this.height = AngelCupertinoTokens.toolbarHeight,
    this.semanticLabels,
    this.semanticSuffix = 'view',
  }) : assert(items.length > 0);

  final Map<T, String> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double width;
  final double height;
  final Map<T, String>? semanticLabels;
  final String semanticSuffix;

  @override
  Widget build(BuildContext context) {
    final values = items.keys.toList(growable: false);
    assert(values.contains(selectedValue));

    return SizedBox(
      key: const ValueKey('legacy-uikit-single-selection-bar'),
      width: width,
      height: height,
      child: Center(
        child: SizedBox(
          width: width,
          height: AngelCupertinoTokens.segmentedControlHeight,
          child: CupertinoSlidingSegmentedControl<T>(
            key: const ValueKey('legacy-uikit-native-segmented-control'),
            groupValue: selectedValue,
            backgroundColor: AngelCupertinoTokens.segmentedBackground,
            thumbColor: AngelCupertinoTokens.secondaryGroupedBackground,
            padding: const EdgeInsets.all(AngelCupertinoTokens.unit / 2),
            onValueChanged: (value) {
              if (value != null) onSelected(value);
            },
            children: {
              for (final value in values)
                value: Semantics(
                  button: true,
                  selected: value == selectedValue,
                  label:
                      '${semanticLabels?[value] ?? items[value]}'
                      ' $semanticSuffix',
                  child: Center(
                    child: Text(
                      items[value]!,
                      style: TextStyle(
                        color: value == selectedValue
                            ? AngelCupertinoTokens.accent
                            : AngelCupertinoTokens.label,
                        fontSize: AngelCupertinoTokens.bodyFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }
}

/// Cupertino-rendered alternative to the legacy 240 x 40 bar selector.
///
/// The wide legacy selector maps to a full-width native segmented picker.
class LegacyUiKitBarSelector<T extends Object> extends StatelessWidget {
  const LegacyUiKitBarSelector({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    this.semanticSuffix = 'option',
  }) : assert(items.length == 3);

  final Map<T, String> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final String semanticSuffix;

  @override
  Widget build(BuildContext context) {
    final values = items.keys.toList(growable: false);
    assert(values.contains(selectedValue));

    return SizedBox(
      key: const ValueKey('legacy-uikit-bar-selector'),
      width: AngelCupertinoTokens.wideSelectorWidth,
      height: AngelCupertinoTokens.controlOuterHeight,
      child: Center(
        child: SizedBox(
          width: AngelCupertinoTokens.wideSelectorWidth,
          height: AngelCupertinoTokens.segmentedControlHeight,
          child: CupertinoSlidingSegmentedControl<T>(
            key: const ValueKey('legacy-uikit-wide-segmented-control'),
            groupValue: selectedValue,
            backgroundColor: AngelCupertinoTokens.segmentedBackground,
            thumbColor: AngelCupertinoTokens.secondaryGroupedBackground,
            padding: const EdgeInsets.all(AngelCupertinoTokens.unit / 2),
            onValueChanged: (value) {
              if (value != null) onSelected(value);
            },
            children: {
              for (final value in values)
                value: Semantics(
                  button: true,
                  selected: value == selectedValue,
                  label: '${items[value]} $semanticSuffix',
                  child: Center(
                    child: Text(
                      items[value]!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: value == selectedValue
                            ? AngelCupertinoTokens.accent
                            : AngelCupertinoTokens.label,
                        fontSize: AngelCupertinoTokens.compactFontSize,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }
}

class LegacyUiKitIconSelectionItem<T extends Object> {
  const LegacyUiKitIconSelectionItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  final T value;
  final String label;
  final IconData icon;
}

/// Cupertino-icon implementation of the legacy function manager.
///
/// Each manager is explicitly cast to a native sliding segmented control so
/// text and icon managers share one iPadOS selection language.
class LegacyUiKitIconFunctionManager<T extends Object> extends StatelessWidget {
  const LegacyUiKitIconFunctionManager({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onSelected,
    required this.width,
    this.height = AngelCupertinoTokens.toolbarHeight,
    this.iconSize = AngelCupertinoTokens.iconSize,
  }) : assert(items.length > 0);

  final List<LegacyUiKitIconSelectionItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final double width;
  final double height;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    assert(items.any((item) => item.value == selectedValue));
    final minimumWidth = items.length * AngelCupertinoTokens.segmentItemExtent;
    final effectiveWidth = width < minimumWidth ? minimumWidth : width;

    return SizedBox(
      width: effectiveWidth,
      height: height,
      child: Center(
        child: SizedBox(
          width: effectiveWidth,
          height: AngelCupertinoTokens.segmentedControlHeight,
          child: CupertinoSlidingSegmentedControl<T>(
            key: const ValueKey('legacy-uikit-native-icon-segmented-control'),
            groupValue: selectedValue,
            backgroundColor: AngelCupertinoTokens.segmentedBackground,
            thumbColor: AngelCupertinoTokens.secondaryGroupedBackground,
            padding: const EdgeInsets.all(AngelCupertinoTokens.unit / 2),
            onValueChanged: (value) {
              if (value != null) onSelected(value);
            },
            children: {
              for (final item in items)
                item.value: Semantics(
                  button: true,
                  selected: item.value == selectedValue,
                  label: item.label,
                  child: Center(
                    child: Icon(
                      item.icon,
                      size: iconSize,
                      color: item.value == selectedValue
                          ? AngelCupertinoTokens.accent
                          : AngelCupertinoTokens.label,
                    ),
                  ),
                ),
            },
          ),
        ),
      ),
    );
  }
}
