import 'dart:io';

import 'package:angel_papercrafts/workspace/cupertino_system_surfaces.dart';
import 'package:angel_papercrafts/workspace/legacy_uikit_cupertino.dart';
import 'package:angel_papercrafts/workspace/workspace_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget application() => const CupertinoApp(
    theme: AngelCupertinoTokens.appTheme,
    home: SizedBox(
      width: 1280,
      height: 800,
      child: WorkspaceShell(viewport: ColoredBox(color: Color(0xFF101010))),
    ),
  );

  testWidgets('preserves the Workspace SCM region dimensions and ancestry', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    expect(find.byKey(const ValueKey('workspace-form')), findsOneWidget);
    final formWidth = tester
        .getSize(find.byKey(const ValueKey('workspace-form')))
        .width;
    expect(
      tester.getSize(find.byKey(const ValueKey('hidden-initialization-row'))),
      Size(formWidth, 1),
    );
    expect(find.byKey(const ValueKey('main-overlay')), findsOneWidget);
    expect(find.byKey(const ValueKey('large-region')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('top-menu'))).height,
      AngelCupertinoTokens.toolbarHeight,
    );
    expect(find.byKey(const ValueKey('work-area')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('function-region'))).width,
      AngelCupertinoTokens.inspectorWidth,
    );
    expect(find.byKey(const ValueKey('initialization-image')), findsOneWidget);
    expect(find.byKey(const ValueKey('initialization-canvas')), findsOneWidget);
    expect(find.byKey(const ValueKey('origin-layout')), findsOneWidget);
  });

  testWidgets('retains the legacy viewport overlay siblings in source order', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    expect(find.byKey(const ValueKey('viewport-outer')), findsOneWidget);
    expect(find.byKey(const ValueKey('viewport-mother')), findsOneWidget);
    expect(find.byKey(const ValueKey('stacked-window')), findsOneWidget);
    expect(find.byKey(const ValueKey('three-js-web-viewer')), findsOneWidget);
    expect(find.byKey(const ValueKey('touch-canvas')), findsOneWidget);
    expect(find.byKey(const ValueKey('reference-image')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('viewport-platform-view-clip')),
      findsOneWidget,
    );
    expect(find.text('ORTHOGRAPHIC VIEW'), findsNothing);
  });

  testWidgets('starts with only the source-visible Wireframe branch', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    expect(
      find.byKey(const ValueKey('workspace-panel-visibility-stack')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('wireframe-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('items-panel')), findsNothing);
    expect(find.byKey(const ValueKey('transform-panel')), findsNothing);
    expect(find.text('Drawing State'), findsOneWidget);
    expect(find.textContaining('CMD |'), findsNothing);
  });

  testWidgets('manager exposes and switches only the three BKY modes', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final manager = find.byType(
      LegacyUiKitIconFunctionManager<WorkspacePanelMode>,
    );
    expect(manager, findsOneWidget);
    expect(find.bySemanticsLabel('Wireframe'), findsOneWidget);
    expect(find.bySemanticsLabel('Transform'), findsOneWidget);
    expect(find.bySemanticsLabel('Items'), findsOneWidget);
    expect(find.bySemanticsLabel('Import'), findsNothing);
    expect(find.bySemanticsLabel('Options'), findsNothing);
    expect(find.bySemanticsLabel('Material'), findsNothing);

    await tester.tap(find.bySemanticsLabel('Transform'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('transform-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('wireframe-panel')), findsNothing);
  });

  testWidgets('XYZ is cast to the native iPadOS segmented picker', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final picker = find.byType(LegacyUiKitSingleSelectionBar<OrthographicView>);
    expect(picker, findsOneWidget);
    expect(
      tester.getSize(picker),
      const Size(
        AngelCupertinoTokens.segmentItemExtent * 3,
        AngelCupertinoTokens.toolbarHeight,
      ),
    );

    Finder semanticsFinder(String label) => find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == '$label view',
    );
    Semantics semanticsFor(String label) =>
        tester.widget<Semantics>(semanticsFinder(label));
    expect(semanticsFor('X').properties.selected, isTrue);
    expect(semanticsFor('Y').properties.selected, isFalse);
    expect(semanticsFor('Z').properties.selected, isFalse);

    var segmented = tester
        .widget<CupertinoSlidingSegmentedControl<OrthographicView>>(
          find.byKey(const ValueKey('legacy-uikit-native-segmented-control')),
        );
    expect(segmented.groupValue, OrthographicView.x);
    expect(segmented.backgroundColor, AngelCupertinoTokens.segmentedBackground);
    expect(
      segmented.thumbColor,
      AngelCupertinoTokens.secondaryGroupedBackground,
    );

    await tester.tap(find.text('Z'));
    await tester.pumpAndSettle();
    expect(semanticsFor('X').properties.selected, isFalse);
    expect(semanticsFor('Z').properties.selected, isTrue);
    segmented = tester
        .widget<CupertinoSlidingSegmentedControl<OrthographicView>>(
          find.byKey(const ValueKey('legacy-uikit-native-segmented-control')),
        );
    expect(segmented.groupValue, OrthographicView.z);
  });

  testWidgets('wide selector uses the shared native Cupertino picker', (
    tester,
  ) async {
    await tester.pumpWidget(application());
    await tester.tap(find.text('Drawing State'));
    await tester.pumpAndSettle();

    final selector = find.byType(LegacyUiKitBarSelector<SurfaceMultiplier>);
    expect(selector, findsOneWidget);
    expect(
      tester.getSize(selector),
      const Size(
        AngelCupertinoTokens.wideSelectorWidth,
        AngelCupertinoTokens.controlOuterHeight,
      ),
    );
    final segmented = tester
        .widget<CupertinoSlidingSegmentedControl<SurfaceMultiplier>>(
          find.byKey(const ValueKey('legacy-uikit-wide-segmented-control')),
        );
    expect(segmented.groupValue, SurfaceMultiplier.one);
    expect(segmented.backgroundColor, AngelCupertinoTokens.segmentedBackground);
    for (final label in [
      '0.3x surface multiplier',
      '1x surface multiplier',
      '3x surface multiplier',
    ]) {
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Semantics && widget.properties.label == label,
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('gesture manager fits all Cupertino icon segments', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final manager = find.byKey(const ValueKey('gesture-manager'));
    expect(manager, findsOneWidget);
    expect(
      tester.getSize(manager),
      const Size(
        AngelCupertinoTokens.segmentItemExtent * 3,
        AngelCupertinoTokens.toolbarHeight,
      ),
    );
    expect(find.bySemanticsLabel('Rotate view'), findsOneWidget);
    expect(find.bySemanticsLabel('Pan view'), findsOneWidget);
    expect(find.bySemanticsLabel('Transform object'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.rotate_right), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.move), findsNWidgets(2));
    expect(find.byIcon(CupertinoIcons.perspective), findsOneWidget);
    expect(
      find.byType(CupertinoSlidingSegmentedControl<GestureMode>),
      findsOneWidget,
    );
  });

  testWidgets('uses the four exact BKY Wireframe group labels', (tester) async {
    await tester.pumpWidget(application());

    for (final entry in <String, String>{
      'draw-control-bar': 'Strokes',
      'surface-manager': 'Surface',
      'wireframe-operations-manager': 'Connection',
      'drawing-reference-manager': 'Reference',
    }.entries) {
      final header = find.byKey(ValueKey(entry.key));
      expect(header, findsOneWidget);
      expect(
        tester.getSize(header).height,
        AngelCupertinoTokens.sectionHeaderHeight,
      );
      expect(
        find.descendant(of: header, matching: find.text(entry.value)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header, matching: find.byType(CupertinoSwitch)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header, matching: find.byType(Icon)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: header, matching: find.byType(CupertinoListTile)),
        findsOneWidget,
      );
    }
  });

  testWidgets('UIKIT buttons share the regulated iPadOS control recipe', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    LegacyUiKitButton buttonFor(String label) =>
        tester.widget<LegacyUiKitButton>(
          find
              .ancestor(
                of: find.textContaining(label).first,
                matching: find.byType(LegacyUiKitButton),
              )
              .first,
        );

    final integer = buttonFor('Integer');
    expect(integer.role, AngelButtonRole.selected);
    expect(integer.borderRadius, AngelCupertinoTokens.controlRadius);

    final displayReference = buttonFor('Display 3 Views');
    expect(displayReference.role, AngelButtonRole.inspector);
    expect(find.text('Display 3 Views:Off'), findsOneWidget);
    expect(find.text('Stick To a Surface:Off'), findsOneWidget);
    expect(find.text('Constant:Off'), findsOneWidget);

    for (final label in ['Drawing State', 'Symmetry', 'Reverse']) {
      final classic = buttonFor(label);
      expect(classic.role, AngelButtonRole.inspector, reason: label);
      expect(
        classic.borderRadius,
        AngelCupertinoTokens.controlRadius,
        reason: label,
      );
    }
    expect(AngelCupertinoTokens.controlFill.a, lessThan(1));

    expect(find.byType(AngelCupertinoDropdown<String>), findsOneWidget);
    expect(find.text('Solid: White'), findsOneWidget);

    final negateRow = find.byKey(const ValueKey('negate-row'));
    final yNegate = find.descendant(
      of: negateRow,
      matching: find.text('Ynega'),
    );
    final xNegate = find.descendant(
      of: negateRow,
      matching: find.text('Xnega'),
    );
    expect(
      tester.getCenter(yNegate).dx,
      lessThan(tester.getCenter(xNegate).dx),
    );
  });

  testWidgets('dropdown uses CupertinoMenuAnchor and native menu items', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final dropdown = find.byType(AngelCupertinoDropdown<String>);
    expect(find.byType(CupertinoMenuAnchor), findsOneWidget);
    await tester.ensureVisible(dropdown);
    await tester.pumpAndSettle();
    await tester.tap(dropdown);
    await tester.pumpAndSettle();

    expect(find.byType(CupertinoPicker), findsNothing);
    expect(find.byType(CupertinoMenuItem), findsOneWidget);
    expect(find.byType(CupertinoPopupSurface), findsOneWidget);
    expect(find.byType(BackdropFilter), findsOneWidget);
    final selectedItem = tester.widget<CupertinoMenuItem>(
      find.byType(CupertinoMenuItem),
    );
    expect(selectedItem.trailing, isA<Icon>());
  });

  testWidgets('Cupertino menu opens below its control', (tester) async {
    await tester.pumpWidget(
      CupertinoApp(
        home: Center(
          child: SizedBox(
            width: 200,
            child: AngelCupertinoDropdown<String>(
              value: 'White',
              items: const {'White': 'White', 'Red': 'Red'},
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final dropdown = find.byType(AngelCupertinoDropdown<String>);
    final dropdownBottom = tester.getBottomLeft(dropdown).dy;
    await tester.tap(dropdown);
    await tester.pumpAndSettle();
    final firstItem = find.byKey(const ValueKey('cupertino-menu-item-White'));
    expect(
      tester.getTopLeft(firstItem).dy,
      greaterThanOrEqualTo(dropdownBottom),
    );
  });

  testWidgets('top menu follows the shared iPadOS toolbar system', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    expect(
      tester.getSize(find.byKey(const ValueKey('files-button'))).width,
      AngelCupertinoTokens.toolbarLeadingWidth,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('data-input-field'))).width,
      AngelCupertinoTokens.toolbarTextFieldWidth,
    );
    expect(
      find.descendant(
        of: find.bySemanticsLabel('Undo'),
        matching: find.byIcon(CupertinoIcons.arrow_uturn_left),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(CupertinoIcons.doc_on_doc), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.trash), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.share), findsOneWidget);
    expect(
      find.byIcon(CupertinoIcons.square_grid_3x2),
      findsAtLeastNWidgets(2),
    );
    expect(find.byIcon(CupertinoIcons.scribble), findsAtLeastNWidgets(2));
    expect(find.byIcon(CupertinoIcons.square_stack_3d_up), findsOneWidget);

    final topMenu = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('top-menu')),
    );
    final decoration = topMenu.decoration as BoxDecoration;
    expect(decoration.color, AngelCupertinoTokens.toolbarBackground);
    expect(decoration.gradient, isNull);
    expect(
      decoration.border,
      const Border(
        bottom: BorderSide(
          color: AngelCupertinoTokens.separator,
          width: AngelCupertinoTokens.hairline,
        ),
      ),
    );
  });

  testWidgets('top actions use unboxed Cupertino toolbar roles', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    for (final label in ['Copy', 'Delete', 'Accelerate', 'Export', 'Dock']) {
      final button = tester.widget<LegacyUiKitButton>(
        find
            .descendant(
              of: find.bySemanticsLabel(label),
              matching: find.byType(LegacyUiKitButton),
            )
            .first,
      );
      expect(button.role, AngelButtonRole.toolbar, reason: label);
      final surface = tester.widget<AnimatedContainer>(
        find
            .descendant(
              of: find.bySemanticsLabel(label),
              matching: find.byType(AnimatedContainer),
            )
            .first,
      );
      final decoration = surface.decoration as BoxDecoration;
      expect(decoration.color, CupertinoColors.transparent, reason: label);
      expect(decoration.border, isNull, reason: label);
      expect(decoration.boxShadow, isNull, reason: label);
    }
  });

  testWidgets('restores all four source Transform groups and their bodies', (
    tester,
  ) async {
    await tester.pumpWidget(application());
    await tester.tap(find.bySemanticsLabel('Transform'));
    await tester.pumpAndSettle();

    for (final entry in <String, String>{
      'gesture-translation-manager': 'Dragging',
      'transform-data-manager': 'Transformation',
      'texture-group-manager': 'Texture & Group',
      'button-transform-manager': 'Flip & Align',
    }.entries) {
      expect(find.byKey(ValueKey(entry.key)), findsOneWidget);
      expect(find.text(entry.value), findsOneWidget);
    }
    expect(
      find.byKey(const ValueKey('gesture-translation-panel')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('transform-data-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('texture-group-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('flip-align-panel')), findsOneWidget);
    expect(find.byType(LegacyUiKitFunctionGroupBody), findsNWidgets(4));
    expect(find.byType(CupertinoListSection), findsNWidgets(4));
    expect(find.byType(CupertinoTextField), findsOneWidget);
    expect(find.text('Move（X,Y,Z）'), findsOneWidget);
    expect(find.text('Rotation(Tilt,Heading)'), findsOneWidget);
    expect(find.text('Scale(X,Y,Z,Whole)'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('translate-parameter-row')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('rotation-parameter-row')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('scale-parameter-row')), findsOneWidget);
    expect(
      tester
          .widgetList<Offstage>(
            find.descendant(
              of: find.byKey(const ValueKey('rotation-parameter-row')),
              matching: find.byType(Offstage, skipOffstage: false),
            ),
          )
          .where((widget) => widget.offstage),
      hasLength(1),
    );
    expect(
      find.byType(CupertinoSlidingSegmentedControl<TransformAxis>),
      findsOneWidget,
    );
    for (final axis in ['X', 'Y', 'Z']) {
      expect(find.text(axis), findsWidgets);
    }

    final cancel = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.text('Cancel'),
        matching: find.byType(CupertinoButton),
      ),
    );
    final apply = tester.widget<CupertinoButton>(
      find.ancestor(
        of: find.text('Apply'),
        matching: find.byType(CupertinoButton),
      ),
    );
    expect(cancel.color, isNull);
    expect(apply.color, AngelCupertinoTokens.accentSurface);
    expect(apply.borderRadius, BorderRadius.circular(11));

    await tester.ensureVisible(
      find.byKey(const ValueKey('texture-selector-row')),
    );
    await tester.tap(find.byKey(const ValueKey('texture-selector-row')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoPicker), findsNothing);
    expect(find.byType(CupertinoMenuAnchor), findsWidgets);
    expect(find.byType(CupertinoMenuItem), findsWidgets);
  });

  testWidgets('workspace regions and toolbar groups do not overlap', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final form = tester.getRect(find.byKey(const ValueKey('workspace-form')));
    final viewport = tester.getRect(
      find.byKey(const ValueKey('viewport-platform-view-clip')),
    );
    final inspector = tester.getRect(
      find.byKey(const ValueKey('function-region')),
    );
    final gesture = tester.getRect(
      find.byKey(const ValueKey('gesture-manager')),
    );
    final orthographic = tester.getRect(
      find.byKey(const ValueKey('orthographic-view-mode')),
    );

    expect(inspector.right, lessThanOrEqualTo(form.right));
    expect(viewport.right, lessThanOrEqualTo(inspector.left));
    expect(gesture.right, lessThanOrEqualTo(orthographic.left));
  });

  testWidgets('Items catalog switches the retained SCM menu/list siblings', (
    tester,
  ) async {
    await tester.pumpWidget(application());
    await tester.tap(find.bySemanticsLabel('Items'));
    await tester.pumpAndSettle();

    bool isOffstage(String key) =>
        tester.widget<Offstage>(find.byKey(ValueKey(key))).offstage;

    expect(find.byKey(const ValueKey('edge-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('edge-list')), findsOneWidget);
    expect(isOffstage('edge-menu'), isFalse);
    expect(isOffstage('group-menu'), isTrue);
    expect(isOffstage('group-list'), isTrue);
    final panelHeight = tester
        .getSize(find.byKey(const ValueKey('function-region')))
        .height;
    expect(
      tester.getSize(find.byKey(const ValueKey('edge-list'))).height,
      closeTo(
        (panelHeight - AngelCupertinoTokens.inspectorPaddingValue * 2) * 0.7,
        0.01,
      ),
    );

    await tester.tap(find.text('Groups'));
    await tester.pumpAndSettle();
    expect(isOffstage('edge-menu'), isTrue);
    expect(find.byKey(const ValueKey('edge-list')), findsNothing);
    expect(isOffstage('group-menu'), isFalse);
    expect(isOffstage('group-list'), isFalse);
    expect(find.text('Import'), findsOneWidget);
    expect(find.text('Unfold'), findsOneWidget);
  });

  test('Workspace icons are exclusively supplied through CupertinoIcons', () {
    final manifest = File('pubspec.yaml').readAsStringSync();
    final mainSource = File('lib/main.dart').readAsStringSync();
    final shell = File('lib/workspace/workspace_shell.dart').readAsStringSync();
    final adapters = File(
      'lib/workspace/legacy_uikit_cupertino.dart',
    ).readAsStringSync();
    final surfaces = File(
      'lib/workspace/cupertino_system_surfaces.dart',
    ).readAsStringSync();
    final productionUi = '$mainSource$shell$adapters$surfaces';

    expect(manifest, isNot(contains('Backpicqualitylow.png')));
    expect(shell, isNot(contains('DecorationImage(')));
    expect(shell, isNot(contains('AssetImage(')));
    for (final iconAsset in [
      'UNDO.PNG',
      'STORAGEW.PNG',
      'OUTW.PNG',
      'DOCK.PNG',
      'TRASH.PNG',
    ]) {
      expect(manifest, isNot(contains(iconAsset)), reason: iconAsset);
      expect(shell, isNot(contains(iconAsset)), reason: iconAsset);
    }
    expect(shell, isNot(contains('Image.asset(')));
    expect(productionUi, isNot(contains('CustomPaint')));
    expect(productionUi, isNot(contains('CustomPainter')));
    expect(productionUi, isNot(contains('IconData(')));
    expect(productionUi, isNot(contains('fontFamily:')));
    expect(productionUi, isNot(contains('package:flutter/material.dart')));
    expect(
      productionUi.replaceAll('CupertinoIcons.', ''),
      isNot(contains('Icons.')),
    );
    expect(
      manifest,
      isNot(contains(RegExp(r'^\s+fonts\s*:', multiLine: true))),
    );
    expect(shell, contains('CupertinoIcons.arrow_uturn_left'));
    expect(shell, contains('CupertinoIcons.scribble'));
    expect(shell, contains('CupertinoIcons.move'));
  });

  test('all UIKIT adapters consume the one iPadOS token system', () {
    final mainSource = File('lib/main.dart').readAsStringSync();
    final shell = File('lib/workspace/workspace_shell.dart').readAsStringSync();
    final surfaces = File(
      'lib/workspace/cupertino_system_surfaces.dart',
    ).readAsStringSync();
    final adapters = File(
      'lib/workspace/legacy_uikit_cupertino.dart',
    ).readAsStringSync();

    expect(adapters, contains('abstract final class AngelCupertinoTokens'));
    expect(mainSource, contains('theme: AngelCupertinoTokens.appTheme'));
    expect(
      mainSource,
      contains("package:flutter_acrylic/flutter_acrylic.dart"),
    );
    expect(mainSource, contains('await Window.initialize()'));
    expect(
      mainSource,
      contains('Window.setEffect(effect: WindowEffect.mica, dark: false)'),
    );
    expect(AngelCupertinoTokens.accent, const Color(0xFF54739B));
    expect(AngelCupertinoTokens.appTheme.primaryColor, const Color(0xFF54739B));
    expect(
      AngelCupertinoTokens.appTheme.textTheme.actionTextStyle.color,
      const Color(0xFF54739B),
    );
    expect(AngelCupertinoTokens.toolbarBackground, CupertinoColors.transparent);
    expect(
      AngelCupertinoTokens.inspectorBackground,
      CupertinoColors.transparent,
    );
    for (final forbiddenBlue in [
      'CupertinoColors.activeBlue',
      'CupertinoColors.systemBlue',
      'Color(0xFF007AFF)',
      'Color(0xFF0000FF)',
      'Color(0xFF3A6999)',
    ]) {
      expect(shell, isNot(contains(forbiddenBlue)), reason: forbiddenBlue);
      expect(adapters, isNot(contains(forbiddenBlue)), reason: forbiddenBlue);
      expect(surfaces, isNot(contains(forbiddenBlue)), reason: forbiddenBlue);
    }
    expect(shell, isNot(contains('Color(0x')));
    expect(surfaces, isNot(contains('Color(0x')));
    expect(adapters, contains('class LegacyUiKitButton'));
    expect(adapters, contains('class LegacyUiKitToggleButton'));
    expect(adapters, contains('class LegacyUiKitPanel'));
    expect(adapters, contains('class LegacyUiKitFunctionGroupHeader'));
    expect(adapters, contains('class LegacyUiKitFunctionGroupBody'));
    expect(adapters, contains('class LegacyUiKitSingleSelectionBar'));
    expect(adapters, contains('class LegacyUiKitBarSelector'));
    expect(adapters, contains('class LegacyUiKitIconFunctionManager'));
    expect(adapters, contains('CupertinoButton('));
    expect(adapters, contains('CupertinoListTile('));
    expect(adapters, contains('CupertinoSwitch('));
    expect(adapters, contains('CupertinoSlidingSegmentedControl<T>'));
    expect(
      AngelCupertinoTokens.controlHeight,
      AngelCupertinoTokens.componentExtent,
    );
    expect(AngelCupertinoTokens.hierarchyGap, 2);
    expect(
      AngelCupertinoTokens.toolbarItemExtent,
      AngelCupertinoTokens.componentExtent,
    );
    expect(
      AngelCupertinoTokens.sectionHeaderHeight,
      AngelCupertinoTokens.componentExtent,
    );
  });

  test('rect hierarchy darkens by level with concentric geometry', () {
    double luminance(Color color) => color.computeLuminance();

    final level1 = AngelCupertinoTokens.fillForLevel(1);
    final level2 = AngelCupertinoTokens.fillForLevel(2);
    final level3 = AngelCupertinoTokens.fillForLevel(3);

    expect(luminance(level2), lessThan(luminance(level1)));
    expect(luminance(level3), lessThan(luminance(level2)));
    expect(AngelCupertinoTokens.hierarchyOverlayOpacity, 0.08);
    expect(AngelCupertinoTokens.level1Radius, 6);
    expect(
      AngelCupertinoTokens.level1Radius,
      AngelCupertinoTokens.level2Radius + AngelCupertinoTokens.hierarchyGap,
    );
    expect(
      AngelCupertinoTokens.level2Radius,
      AngelCupertinoTokens.level3Radius + AngelCupertinoTokens.hierarchyGap,
    );
    expect(AngelCupertinoTokens.componentExtent, 50);
  });

  testWidgets('inspector uses the shared compact grid and button geometry', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    final inspectorPadding = tester.widget<Padding>(
      find.byKey(const ValueKey('inspector-layout-padding')),
    );
    expect(
      inspectorPadding.padding,
      const EdgeInsets.all(AngelCupertinoTokens.inspectorPaddingValue),
    );

    final functionRegion = find.byKey(const ValueKey('function-region'));
    final decoratedRegion = find
        .descendant(of: functionRegion, matching: find.byType(DecoratedBox))
        .first;
    final decoration =
        tester.widget<DecoratedBox>(decoratedRegion).decoration
            as BoxDecoration;
    expect(decoration.color, AngelCupertinoTokens.inspectorBackground);

    final symmetry = tester.widget<LegacyUiKitButton>(
      find
          .ancestor(
            of: find.text('Symmetry'),
            matching: find.byType(LegacyUiKitButton),
          )
          .first,
    );
    expect(symmetry.width, double.infinity);
    expect(symmetry.height, AngelCupertinoTokens.controlHeight);
    expect(symmetry.borderRadius, AngelCupertinoTokens.level2Radius);
    expect(symmetry.role, AngelButtonRole.inspector);

    final connectionRow = find.byKey(
      const ValueKey('wireframe-operations-panel'),
    );
    expect(tester.getSize(connectionRow).width, 248);
    final row = tester.widget<Row>(connectionRow);
    expect(
      row.children.whereType<SizedBox>().single.width,
      AngelCupertinoTokens.buttonRowGap,
    );
  });

  testWidgets('horizontal inspector component groups are vertically centered', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    for (final keyName in [
      'wireframe-operations-panel',
      'snap-mode-row',
      'lock-row',
      'negate-row',
    ]) {
      final row = tester.widget<Row>(find.byKey(ValueKey(keyName)));
      expect(
        row.crossAxisAlignment,
        CrossAxisAlignment.center,
        reason: keyName,
      );
    }
    final valueRow = tester.widget<Row>(
      find.descendant(
        of: find.byKey(const ValueKey('uv-row')),
        matching: find.byType(Row),
      ),
    );
    expect(valueRow.crossAxisAlignment, CrossAxisAlignment.center);
  });

  testWidgets('all eight inspector groups share one inset form recipe', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    void expectSharedSections(List<String> keyNames) {
      for (final keyName in keyNames) {
        final sections = find.ancestor(
          of: find.byKey(ValueKey(keyName)),
          matching: find.byType(CupertinoListSection),
        );
        expect(sections, findsOneWidget, reason: keyName);
        final section = tester.widget<CupertinoListSection>(sections);
        expect(
          section.backgroundColor,
          CupertinoColors.transparent,
          reason: keyName,
        );
        expect(section.children!.length, 2, reason: keyName);
      }
    }

    expectSharedSections([
      'draw-control-bar',
      'surface-manager',
      'wireframe-operations-manager',
      'drawing-reference-manager',
    ]);

    await tester.tap(find.bySemanticsLabel('Transform'));
    await tester.pumpAndSettle();

    expectSharedSections([
      'gesture-translation-manager',
      'transform-data-manager',
      'texture-group-manager',
      'button-transform-manager',
    ]);
  });

  testWidgets('inspector hierarchy is translucent, shadowless, and icon-led', (
    tester,
  ) async {
    await tester.pumpWidget(application());

    expect(AngelCupertinoTokens.secondaryGroupedBackground.a, lessThan(1));
    expect(AngelCupertinoTokens.controlFill.a, lessThan(1));
    expect(AngelCupertinoTokens.accentSurface.a, lessThan(1));

    final symmetryButton = find.ancestor(
      of: find.text('Symmetry'),
      matching: find.byType(LegacyUiKitButton),
    );
    final contentRow = tester.widget<Row>(
      find.descendant(of: symmetryButton, matching: find.byType(Row)).first,
    );
    expect(contentRow.children.first, isA<Icon>());
    expect(contentRow.children.last, isA<Text>());

    final strokesTile = tester.widget<CupertinoListTile>(
      find.descendant(
        of: find.byKey(const ValueKey('draw-control-bar')),
        matching: find.byType(CupertinoListTile),
      ),
    );
    expect(strokesTile.leading, isA<SizedBox>());

    final adapters = File(
      'lib/workspace/legacy_uikit_cupertino.dart',
    ).readAsStringSync();
    final shell = File('lib/workspace/workspace_shell.dart').readAsStringSync();
    final surfaces = File(
      'lib/workspace/cupertino_system_surfaces.dart',
    ).readAsStringSync();
    expect('$adapters$shell$surfaces', isNot(contains('BoxShadow')));
    expect('$adapters$shell$surfaces', isNot(contains('boxShadow:')));
  });

  testWidgets(
    'inspector keeps the original width in a large landscape workspace',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1400, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(application());
      final inspectorWidth = tester
          .getSize(find.byKey(const ValueKey('function-region')))
          .width;
      expect(inspectorWidth, AngelCupertinoTokens.inspectorWidth);
    },
  );

  testWidgets('compact workspace stacks inspector without covering viewport', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(500, 700);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(application());

    final form = tester.getRect(find.byKey(const ValueKey('workspace-form')));
    final viewport = tester.getRect(
      find.byKey(const ValueKey('viewport-platform-view-clip')),
    );
    final inspector = tester.getRect(
      find.byKey(const ValueKey('function-region')),
    );

    expect(viewport.width, form.width);
    expect(inspector.width, form.width);
    expect(viewport.bottom, lessThanOrEqualTo(inspector.top));
    expect(inspector.bottom, lessThanOrEqualTo(form.bottom));
    expect(
      viewport.height,
      greaterThanOrEqualTo(AngelCupertinoTokens.minimumCompactViewportHeight),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Input Data stays centered in the whole top bar', (tester) async {
    for (final size in [const Size(1280, 900), const Size(700, 700)]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      await tester.pumpWidget(application());

      final toolbar = tester.getRect(find.byKey(const ValueKey('top-menu')));
      final input = tester.getRect(
        find.byKey(const ValueKey('data-input-field')),
      );
      expect(
        input.center.dx,
        closeTo(toolbar.center.dx, 0.01),
        reason: '$size',
      );
      expect(input.width, AngelCupertinoTokens.toolbarTextFieldWidth);
    }
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final inputField = tester.widget<CupertinoTextField>(
      find.descendant(
        of: find.byKey(const ValueKey('data-input-field')),
        matching: find.byType(CupertinoTextField),
      ),
    );
    expect(inputField.padding, AngelCupertinoTokens.controlPadding);
  });

  testWidgets('UIKIT button press uses the shared Cupertino motion token', (
    tester,
  ) async {
    await tester.pumpWidget(
      CupertinoApp(
        theme: AngelCupertinoTokens.appTheme,
        home: Center(
          child: LegacyUiKitButton(
            onPressed: () {},
            child: const Text('Action'),
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Action')),
    );
    await tester.pump();

    final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    final surface = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = surface.decoration as BoxDecoration;
    expect(scale.scale, 0.97);
    expect(scale.duration, AngelCupertinoTokens.fastMotion);
    expect(
      decoration.color,
      Color.alphaBlend(
        AngelCupertinoTokens.controlFillPressed,
        AngelCupertinoTokens.fillForLevel(2),
      ),
    );
    expect(decoration.border, isNull);
    expect(decoration.boxShadow, isNull);

    await gesture.up();
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });
}
