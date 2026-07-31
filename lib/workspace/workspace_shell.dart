import 'package:flutter/cupertino.dart';

import 'cupertino_system_surfaces.dart';
import 'legacy_uikit_cupertino.dart';

enum OrthographicView { x, y, z }

enum GestureMode { rotate, pan, transform }

enum SurfaceMultiplier { pointThree, one, three }

enum ItemCatalog { edges, groups, objects }

enum TransformAxis { x, y, z }

enum WorkspacePanelMode {
  import,
  options,
  items,
  material,
  transform,
  wireframe,
}

/// Source-faithful shell for `A3NG_EN/.../Workspace.scm`.
///
/// Every private builder below represents one visual SCM node. Flutter-only
/// constraint wrappers are kept immediately around the node they adapt.
class WorkspaceShell extends StatefulWidget {
  const WorkspaceShell({
    super.key,
    required this.viewport,
    this.isLoading = false,
    this.referenceColors = const ['White'],
  });

  final Widget viewport;
  final bool isLoading;
  final List<String> referenceColors;

  @override
  State<WorkspaceShell> createState() => _WorkspaceShellState();
}

class _WorkspaceShellState extends State<WorkspaceShell> {
  OrthographicView _selectedView = OrthographicView.x;
  GestureMode _gestureMode = GestureMode.rotate;
  SurfaceMultiplier _surfaceMultiplier = SurfaceMultiplier.one;
  ItemCatalog _itemCatalog = ItemCatalog.edges;
  WorkspacePanelMode _panelMode = WorkspacePanelMode.wireframe;
  bool _drawMode = false;
  bool _stickToSurface = false;
  bool _constantPoints = false;
  bool _integerCoordinates = true;
  bool _lockX = false;
  bool _lockY = false;
  bool _negateX = false;
  bool _negateY = false;
  bool _exchangeAxes = false;
  bool _displayReference = false;
  bool _drawingSectionVisible = true;
  bool _surfaceSectionVisible = true;
  bool _couplingSectionVisible = true;
  bool _referenceSectionVisible = true;
  bool _closeStroke = false;
  bool _dragTransform = false;
  bool _rotateTransform = false;
  TransformAxis _transformAxis = TransformAxis.x;
  bool _transformationSectionVisible = true;
  bool _flipAlignSectionVisible = true;
  bool _draggingSectionVisible = true;
  bool _textureGroupSectionVisible = true;
  String? _selectedReferenceColor;
  String? _selectedGroup;
  String? _selectedTexture;

  @override
  Widget build(BuildContext context) => Column(
    key: const ValueKey('workspace-form'),
    children: [
      _buildHiddenInitializationRow(),
      Expanded(child: _buildMainOverlay()),
    ],
  );

  Widget _buildHiddenInitializationRow() => const SizedBox(
    key: ValueKey('hidden-initialization-row'),
    width: double.infinity,
    height: 1,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(key: ValueKey('initialization-image')),
        SizedBox(key: ValueKey('initialization-canvas'), width: 1, height: 1),
        SizedBox(key: ValueKey('origin-layout')),
      ],
    ),
  );

  Widget _buildMainOverlay() => Stack(
    key: const ValueKey('main-overlay'),
    fit: StackFit.expand,
    children: [
      const Offstage(
        key: ValueKey('close-file-animation'),
        offstage: true,
        child: SizedBox.expand(),
      ),
      _buildLargeRegion(),
    ],
  );

  Widget _buildLargeRegion() => Column(
    key: const ValueKey('large-region'),
    children: [
      SizedBox(
        height: AngelCupertinoTokens.toolbarHeight,
        child: _buildTopMenu(),
      ),
      Expanded(child: _buildWorkArea()),
    ],
  );

  Widget _buildTopMenu() => DecoratedBox(
    key: const ValueKey('top-menu'),
    decoration: const BoxDecoration(
      color: AngelCupertinoTokens.toolbarBackground,
      border: Border(
        bottom: BorderSide(
          color: AngelCupertinoTokens.separator,
          width: AngelCupertinoTokens.hairline,
        ),
      ),
    ),
    child: LayoutBuilder(
      builder: (context, constraints) => Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width:
                  constraints.maxWidth <
                      AngelCupertinoTokens.minimumToolbarWidth
                  ? AngelCupertinoTokens.minimumToolbarWidth
                  : constraints.maxWidth,
              child: Row(
                children: [
                  Offstage(
                    key: ValueKey('files-button'),
                    offstage: widget.isLoading,
                    child: const SizedBox(
                      width: AngelCupertinoTokens.toolbarLeadingWidth,
                      height: AngelCupertinoTokens.toolbarHeight,
                      child: Center(
                        child: Text(
                          'Files',
                          style: TextStyle(
                            color: AngelCupertinoTokens.accent,
                            fontSize: AngelCupertinoTokens.bodyFontSize,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Offstage(
                    key: ValueKey('loading-button'),
                    offstage: !widget.isLoading,
                    child: TickerMode(
                      enabled: widget.isLoading,
                      child: Container(
                        width: AngelCupertinoTokens.toolbarLeadingWidth,
                        height: AngelCupertinoTokens.toolbarHeight,
                        alignment: Alignment.center,
                        color: AngelCupertinoTokens.accentTint,
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CupertinoActivityIndicator(radius: 7),
                            SizedBox(width: AngelCupertinoTokens.toolbarGap),
                            Text(
                              'Loading',
                              style: TextStyle(
                                color: AngelCupertinoTokens.accent,
                                fontSize: AngelCupertinoTokens.compactFontSize,
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    key: ValueKey('top-menu-spacer-40'),
                    width: AngelCupertinoTokens.toolbarGap,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      key: const ValueKey('top-function-region'),
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _bareToolbarIcon(
                            CupertinoIcons.arrow_uturn_left,
                            'Undo',
                            width: AngelCupertinoTokens.toolbarItemExtent,
                            height: AngelCupertinoTokens.toolbarItemExtent,
                          ),
                          const SizedBox(width: AngelCupertinoTokens.unit),
                          Offstage(
                            key: ValueKey('save-button'),
                            offstage: true,
                            child: _bareToolbarIcon(
                              CupertinoIcons.archivebox,
                              'Save',
                              width: AngelCupertinoTokens.toolbarCommandWidth,
                              height: AngelCupertinoTokens.toolbarHeight,
                            ),
                          ),
                          const SizedBox(width: AngelCupertinoTokens.unit),
                          LegacyUiKitIconFunctionManager<GestureMode>(
                            key: const ValueKey('gesture-manager'),
                            width: AngelCupertinoTokens.segmentItemExtent * 3,
                            selectedValue: _gestureMode,
                            onSelected: (value) =>
                                setState(() => _gestureMode = value),
                            items: const [
                              LegacyUiKitIconSelectionItem(
                                value: GestureMode.rotate,
                                label: 'Rotate view',
                                icon: CupertinoIcons.rotate_right,
                              ),
                              LegacyUiKitIconSelectionItem(
                                value: GestureMode.pan,
                                label: 'Pan view',
                                icon: CupertinoIcons.move,
                              ),
                              LegacyUiKitIconSelectionItem(
                                value: GestureMode.transform,
                                label: 'Transform object',
                                icon: CupertinoIcons.perspective,
                              ),
                            ],
                          ),
                          const SizedBox(width: AngelCupertinoTokens.unit),
                          SizedBox(
                            key: const ValueKey('orthographic-view-mode'),
                            width: AngelCupertinoTokens.segmentItemExtent * 3,
                            child:
                                LegacyUiKitSingleSelectionBar<OrthographicView>(
                                  items: const {
                                    OrthographicView.x: 'X',
                                    OrthographicView.y: 'Y',
                                    OrthographicView.z: 'Z',
                                  },
                                  selectedValue: _selectedView,
                                  onSelected: (value) {
                                    setState(() => _selectedView = value);
                                  },
                                  height: AngelCupertinoTokens.toolbarHeight,
                                ),
                          ),
                          const SizedBox(width: AngelCupertinoTokens.unit),
                          _classicToolbarIcon(
                            CupertinoIcons.doc_on_doc,
                            'Copy',
                            width: AngelCupertinoTokens.toolbarCommandWidth,
                          ),
                          _classicToolbarIcon(
                            CupertinoIcons.trash,
                            'Delete',
                            width: AngelCupertinoTokens.toolbarCommandWidth,
                          ),
                          _classicToolbarText(
                            'Mid',
                            width: AngelCupertinoTokens.toolbarCommandWidth,
                          ),
                          const SizedBox(
                            key: ValueKey('data-input-clearance'),
                            width: AngelCupertinoTokens.toolbarTextFieldWidth,
                          ),
                          _classicToolbarIcon(
                            CupertinoIcons.forward_end_alt,
                            'Accelerate',
                            width: AngelCupertinoTokens.toolbarCommandWidth,
                          ),
                          const SizedBox(
                            key: ValueKey('focus-steal-field'),
                            width: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _classicToolbarIcon(
                    CupertinoIcons.share,
                    'Export',
                    width: AngelCupertinoTokens.toolbarCommandWidth,
                  ),
                  _classicToolbarIcon(
                    CupertinoIcons.square_grid_3x2,
                    'Dock',
                    width: AngelCupertinoTokens.toolbarCommandWidth,
                  ),
                  LegacyUiKitIconFunctionManager<WorkspacePanelMode>(
                    key: const ValueKey('manager'),
                    width: AngelCupertinoTokens.segmentItemExtent * 3,
                    selectedValue: _panelMode,
                    onSelected: (value) => setState(() => _panelMode = value),
                    items: const [
                      LegacyUiKitIconSelectionItem(
                        value: WorkspacePanelMode.wireframe,
                        label: 'Wireframe',
                        icon: CupertinoIcons.scribble,
                      ),
                      LegacyUiKitIconSelectionItem(
                        value: WorkspacePanelMode.transform,
                        label: 'Transform',
                        icon: CupertinoIcons.move,
                      ),
                      LegacyUiKitIconSelectionItem(
                        value: WorkspacePanelMode.items,
                        label: 'Items',
                        icon: CupertinoIcons.square_stack_3d_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              key: ValueKey('data-input-field'),
              width: AngelCupertinoTokens.toolbarTextFieldWidth,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: AngelCupertinoTokens.hierarchyGap,
                ),
                child: CupertinoTextField(
                  enabled: false,
                  placeholder: 'Input Data',
                  padding: AngelCupertinoTokens.controlPadding,
                  style: AngelCupertinoTokens.bodyTextStyle,
                  placeholderStyle: TextStyle(
                    color: AngelCupertinoTokens.tertiaryLabel,
                    fontSize: AngelCupertinoTokens.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  decoration: BoxDecoration(
                    color: AngelCupertinoTokens.fillForLevel(1),
                    border: AngelCupertinoTokens.controlBorder,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AngelCupertinoTokens.level1Radius),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildWorkArea() => LayoutBuilder(
    builder: (context, constraints) {
      final useCompactLayout =
          constraints.maxWidth < AngelCupertinoTokens.compactWorkAreaBreakpoint;
      if (useCompactLayout) {
        final desiredInspectorHeight =
            constraints.maxHeight *
            AngelCupertinoTokens.compactInspectorHeightFraction;
        final maximumInspectorHeight =
            (constraints.maxHeight -
                    AngelCupertinoTokens.minimumCompactViewportHeight)
                .clamp(0.0, constraints.maxHeight);
        final inspectorHeight =
            maximumInspectorHeight <
                AngelCupertinoTokens.minimumCompactInspectorHeight
            ? maximumInspectorHeight
            : desiredInspectorHeight.clamp(
                AngelCupertinoTokens.minimumCompactInspectorHeight,
                maximumInspectorHeight,
              );

        return Column(
          key: const ValueKey('work-area'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildViewportOuter()),
            _buildFunctionRegion(height: inspectorHeight),
          ],
        );
      }

      return Row(
        key: const ValueKey('work-area'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _buildViewportOuter()),
          _buildFunctionRegion(width: AngelCupertinoTokens.inspectorWidth),
        ],
      );
    },
  );

  Widget _buildViewportOuter() => Align(
    key: const ValueKey('viewport-outer'),
    alignment: Alignment.center,
    child: ClipRect(
      key: const ValueKey('viewport-platform-view-clip'),
      child: SizedBox.expand(child: _buildViewportMother()),
    ),
  );

  Widget _buildViewportMother() => Stack(
    key: const ValueKey('viewport-mother'),
    fit: StackFit.expand,
    children: [
      const Offstage(
        key: ValueKey('smooth-overlay'),
        offstage: true,
        child: SizedBox.expand(),
      ),
      const Offstage(
        key: ValueKey('point-button'),
        offstage: true,
        child: SizedBox(width: 50, height: 50),
      ),
      _buildStackedWindow(),
    ],
  );

  Widget _buildStackedWindow() => Stack(
    key: const ValueKey('stacked-window'),
    fit: StackFit.expand,
    children: [
      const Offstage(
        key: ValueKey('preview-web-viewer'),
        offstage: true,
        child: SizedBox.expand(),
      ),
      KeyedSubtree(
        key: const ValueKey('three-js-web-viewer'),
        child: widget.viewport,
      ),
      const IgnorePointer(
        key: ValueKey('touch-canvas'),
        child: SizedBox.expand(),
      ),
      const IgnorePointer(
        key: ValueKey('reference-image'),
        child: Center(child: SizedBox(width: 4000, height: 4000)),
      ),
    ],
  );

  Widget _buildFunctionRegion({double? width, double? height}) => SizedBox(
    key: const ValueKey('function-region'),
    width: width,
    height: height,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: AngelCupertinoTokens.inspectorBackground,
        border: Border(
          left: width == null
              ? BorderSide.none
              : const BorderSide(
                  color: AngelCupertinoTokens.separator,
                  width: AngelCupertinoTokens.hairline,
                ),
          top: width != null
              ? BorderSide.none
              : const BorderSide(
                  color: AngelCupertinoTokens.separator,
                  width: AngelCupertinoTokens.hairline,
                ),
        ),
      ),
      child: Padding(
        key: const ValueKey('inspector-layout-padding'),
        padding: AngelCupertinoTokens.inspectorPadding,
        child: IndexedStack(
          key: const ValueKey('workspace-panel-visibility-stack'),
          index: WorkspacePanelMode.values.indexOf(_panelMode),
          sizing: StackFit.expand,
          children: [
            _scrollPanel('import-panel', const [
              SizedBox(key: ValueKey('import-flexbox')),
            ]),
            _scrollPanel('options-panel', const []),
            _buildItemsPanel(),
            _scrollPanel('material-panel', const []),
            _buildTransformPanel(),
            _buildWireframePanel(),
          ],
        ),
      ),
    ),
  );

  Widget _scrollPanel(String keyName, List<Widget> children) =>
      SingleChildScrollView(
        key: ValueKey(keyName),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );

  Widget _buildItemsPanel() => LayoutBuilder(
    builder: (context, constraints) {
      final listHeight = constraints.maxHeight * 0.7;
      return SingleChildScrollView(
        key: const ValueKey('items-panel'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              key: const ValueKey('catalog-manager'),
              height: AngelCupertinoTokens.toolbarHeight,
              child: Center(
                child: LegacyUiKitBarSelector<ItemCatalog>(
                  semanticSuffix: 'catalog',
                  items: const {
                    ItemCatalog.edges: 'Edges',
                    ItemCatalog.groups: 'Groups',
                    ItemCatalog.objects: 'Objects',
                  },
                  selectedValue: _itemCatalog,
                  onSelected: (value) => setState(() => _itemCatalog = value),
                ),
              ),
            ),
            Offstage(
              key: const ValueKey('edge-menu'),
              offstage: _itemCatalog != ItemCatalog.edges,
              child: Row(
                children: [
                  Expanded(child: _classicButton('Select')),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(child: _classicButton('Connect')),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(child: _classicButton('Loft')),
                ],
              ),
            ),
            const Offstage(
              key: ValueKey('select-checkbox'),
              offstage: true,
              child: SizedBox(),
            ),
            Offstage(
              key: const ValueKey('loft-menu'),
              offstage: _itemCatalog != ItemCatalog.objects,
              child: Row(
                children: [
                  Expanded(child: _classicButton('Select')),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(child: _classicButton('Edge')),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(child: _classicButton('Group')),
                ],
              ),
            ),
            const Offstage(
              key: ValueKey('multi-select-checkbox'),
              offstage: true,
              child: SizedBox(),
            ),
            Offstage(
              key: const ValueKey('group-menu'),
              offstage: _itemCatalog != ItemCatalog.groups,
              child: Row(
                children: [
                  Expanded(child: _classicButton('Import')),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(child: _classicButton('Unfold')),
                ],
              ),
            ),
            Offstage(
              offstage: _itemCatalog != ItemCatalog.edges,
              child: SizedBox(
                key: const ValueKey('edge-list'),
                height: listHeight,
              ),
            ),
            Offstage(
              key: const ValueKey('group-list'),
              offstage: _itemCatalog != ItemCatalog.groups,
              child: SizedBox(
                height: listHeight,
                child: const Column(key: ValueKey('group-item-layout')),
              ),
            ),
            Offstage(
              key: const ValueKey('loft-list'),
              offstage: _itemCatalog != ItemCatalog.objects,
              child: SizedBox(height: listHeight),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildTransformPanel() => ColoredBox(
    color: AngelCupertinoTokens.inspectorBackground,
    child: _scrollPanel('transform-panel', [
      _inspectorSection(
        header: _sectionHeader(
          keyName: 'gesture-translation-manager',
          icon: CupertinoIcons.move,
          label: 'Dragging',
          value: _draggingSectionVisible,
          update: (value) => _draggingSectionVisible = value,
        ),
        body: _functionGroupBody(
          isExpanded: _draggingSectionVisible,
          child: Column(
            key: const ValueKey('gesture-translation-panel'),
            children: [
              _toggleButton(
                'Drag',
                _dragTransform,
                (value) => _dragTransform = value,
                icon: CupertinoIcons.move,
                showStateSuffix: true,
              ),
              const SizedBox(height: AngelCupertinoTokens.internalSpacing),
              _toggleButton(
                'Rotation',
                _rotateTransform,
                (value) => _rotateTransform = value,
                icon: CupertinoIcons.rotate_right,
                showStateSuffix: true,
              ),
              const SizedBox(height: AngelCupertinoTokens.internalSpacing),
              CupertinoSlidingSegmentedControl<TransformAxis>(
                key: const ValueKey('transform-axis-row'),
                groupValue: _transformAxis,
                onValueChanged: (value) {
                  if (value != null) setState(() => _transformAxis = value);
                },
                children: const {
                  TransformAxis.x: Padding(
                    padding: AngelCupertinoTokens.controlPadding,
                    child: Text('X'),
                  ),
                  TransformAxis.y: Padding(
                    padding: AngelCupertinoTokens.controlPadding,
                    child: Text('Y'),
                  ),
                  TransformAxis.z: Padding(
                    padding: AngelCupertinoTokens.controlPadding,
                    child: Text('Z'),
                  ),
                },
              ),
              const SizedBox(height: AngelCupertinoTokens.internalSpacing),
              Row(
                key: const ValueKey('transform-commit-row'),
                children: [
                  Expanded(
                    child: CupertinoButton(
                      onPressed: null,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.xmark_circle, size: 18),
                            SizedBox(width: AngelCupertinoTokens.toolbarGap),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                  Expanded(
                    child: CupertinoButton.filled(
                      color: AngelCupertinoTokens.accentSurface,
                      borderRadius: BorderRadius.circular(
                        AngelCupertinoTokens.actionRadius,
                      ),
                      onPressed: null,
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(CupertinoIcons.checkmark_circle, size: 18),
                            SizedBox(width: AngelCupertinoTokens.toolbarGap),
                            Text('Apply'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      _inspectorSection(
        header: _sectionHeader(
          keyName: 'transform-data-manager',
          icon: CupertinoIcons.perspective,
          label: 'Transformation',
          value: _transformationSectionVisible,
          update: (value) => _transformationSectionVisible = value,
        ),
        body: _functionGroupBody(
          isExpanded: _transformationSectionVisible,
          child: _buildTransformDataPanel(),
        ),
      ),
      _inspectorSection(
        header: _sectionHeader(
          keyName: 'texture-group-manager',
          icon: CupertinoIcons.layers,
          label: 'Texture & Group',
          value: _textureGroupSectionVisible,
          update: (value) => _textureGroupSectionVisible = value,
        ),
        body: _functionGroupBody(
          isExpanded: _textureGroupSectionVisible,
          child: _buildTextureGroupPanel(),
        ),
      ),
      _inspectorSection(
        header: _sectionHeader(
          keyName: 'button-transform-manager',
          icon: CupertinoIcons.arrow_left_right,
          label: 'Flip & Align',
          value: _flipAlignSectionVisible,
          update: (value) => _flipAlignSectionVisible = value,
        ),
        body: _functionGroupBody(
          isExpanded: _flipAlignSectionVisible,
          child: _buildFlipAlignPanel(),
        ),
      ),
    ]),
  );

  Widget _inspectorSection({
    required Widget header,
    required Widget body,
  }) => CupertinoListSection.insetGrouped(
    margin: const EdgeInsets.only(bottom: AngelCupertinoTokens.moduleSpacing),
    backgroundColor: CupertinoColors.transparent,
    decoration: BoxDecoration(
      color: AngelCupertinoTokens.fillForLevel(1),
      borderRadius: BorderRadius.circular(AngelCupertinoTokens.level1Radius),
    ),
    children: [header, body],
  );

  Widget _buildTransformDataPanel() => Column(
    key: ValueKey('transform-data-panel'),
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _parameterDisplayGroup(
        title: 'Move（X,Y,Z）',
        keyPrefix: 'translate',
        values: const ['0', '0', '0'],
      ),
      _parameterDisplayGroup(
        title: 'Rotation(Tilt,Heading)',
        keyPrefix: 'rotation',
        values: const ['0', '0', '0'],
        visible: const [true, false, true],
      ),
      _parameterDisplayGroup(
        title: 'Scale(X,Y,Z,Whole)',
        keyPrefix: 'scale',
        values: const ['0', '0', '0', '0'],
      ),
    ],
  );

  Widget _parameterDisplayGroup({
    required String title,
    required String keyPrefix,
    required List<String> values,
    List<bool>? visible,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(
        height: AngelCupertinoTokens.sectionCaptionHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: AngelCupertinoTokens.bodyTextStyle),
        ),
      ),
      _LegacyValueRow(
        key: ValueKey('$keyPrefix-parameter-row'),
        values: values,
        valueKeys: [
          for (var index = 0; index < values.length; index++)
            '$keyPrefix-$index-display',
        ],
        visible: visible,
      ),
    ],
  );

  Widget _buildTextureGroupPanel() => Column(
    key: const ValueKey('texture-group-panel'),
    children: [
      _pickerFormRow(
        keyName: 'group-selector-row',
        label: 'Group',
        value: _selectedGroup,
        items: const ['None'],
        onSelected: (value) => setState(() => _selectedGroup = value),
      ),
      _pickerFormRow(
        keyName: 'texture-selector-row',
        label: 'Texture',
        value: _selectedTexture ?? widget.referenceColors.firstOrNull,
        items: widget.referenceColors,
        onSelected: (value) => setState(() => _selectedTexture = value),
      ),
      Padding(
        padding: const EdgeInsets.all(AngelCupertinoTokens.internalSpacing),
        child: CupertinoButton.filled(
          color: AngelCupertinoTokens.accentSurface,
          borderRadius: BorderRadius.circular(
            AngelCupertinoTokens.actionRadius,
          ),
          onPressed: null,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.paintbrush, size: 18),
              SizedBox(width: AngelCupertinoTokens.toolbarGap),
              Text('Edit Livery'),
            ],
          ),
        ),
      ),
    ],
  );

  Widget _buildFlipAlignPanel() => Column(
    key: const ValueKey('flip-align-panel'),
    children: [
      SizedBox(
        height: AngelCupertinoTokens.controlOuterHeight,
        child: Row(
          children: [
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.rotate_right,
                'Rotate X 90°',
              ),
            ),
            const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.arrow_left_right,
                'Mirror Y',
              ),
            ),
            const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.rotate_left,
                'Rotate Z 90°',
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: AngelCupertinoTokens.internalSpacing),
      SizedBox(
        height: AngelCupertinoTokens.controlOuterHeight,
        child: Row(
          children: [
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.arrow_right_to_line,
                'Align X',
              ),
            ),
            const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.arrow_up_to_line,
                'Align Y',
              ),
            ),
            const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
            Expanded(
              child: _classicIconButton(
                CupertinoIcons.arrow_left_to_line,
                'Align Z',
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildWireframePanel() => _scrollPanel('wireframe-panel', [
    _inspectorSection(
      header: _sectionHeader(
        keyName: 'draw-control-bar',
        icon: CupertinoIcons.scribble,
        label: 'Strokes',
        value: _drawingSectionVisible,
        update: (value) => _drawingSectionVisible = value,
      ),
      body: _functionGroupBody(
        isExpanded: _drawingSectionVisible,
        child: Column(
          key: const ValueKey('draw-function-group'),
          children: [
            _classicButton(
              'Drawing State',
              onPressed: () => setState(() => _drawMode = !_drawMode),
            ),
            Offstage(
              key: const ValueKey('lockable-draw-panel'),
              offstage: !_drawMode,
              child: Column(
                children: [
                  Row(
                    key: const ValueKey('draw-type-row'),
                    children: [
                      Expanded(
                        child: _toggleButton(
                          'Close',
                          _closeStroke,
                          (value) => _closeStroke = value,
                        ),
                      ),
                      const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                      Expanded(child: _classicButton('Circle')),
                      const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                      Expanded(child: _classicButton('Line')),
                    ],
                  ),
                  SizedBox(
                    key: const ValueKey('surface-rate-selector'),
                    height: AngelCupertinoTokens.controlOuterHeight,
                    child: Center(
                      child: LegacyUiKitBarSelector<SurfaceMultiplier>(
                        semanticSuffix: 'surface multiplier',
                        items: const {
                          SurfaceMultiplier.pointThree: '0.3x',
                          SurfaceMultiplier.one: '1x',
                          SurfaceMultiplier.three: '3x',
                        },
                        selectedValue: _surfaceMultiplier,
                        onSelected: (value) {
                          setState(() => _surfaceMultiplier = value);
                        },
                      ),
                    ),
                  ),
                  const _CoordinateTable(),
                  _classicButton(
                    'Quit',
                    onPressed: () => setState(() => _drawMode = false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    _inspectorSection(
      header: _sectionHeader(
        keyName: 'surface-manager',
        icon: CupertinoIcons.square_grid_3x2,
        label: 'Surface',
        value: _surfaceSectionVisible,
        update: (value) => _surfaceSectionVisible = value,
      ),
      body: _functionGroupBody(
        isExpanded: _surfaceSectionVisible,
        child: Column(
          key: const ValueKey('surface-panel'),
          children: [
            _toggleButton(
              'Stick To a Surface',
              _stickToSurface,
              (value) => _stickToSurface = value,
              icon: CupertinoIcons.square_grid_3x2,
              showStateSuffix: true,
            ),
            const SizedBox(height: AngelCupertinoTokens.internalSpacing),
            Row(
              key: const ValueKey('snap-mode-row'),
              children: [
                Expanded(
                  child: _toggleButton(
                    'Constant',
                    _constantPoints,
                    (value) => _constantPoints = value,
                    icon: CupertinoIcons.arrow_2_circlepath,
                    showStateSuffix: true,
                  ),
                ),
                const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                Expanded(
                  child: _toggleButton(
                    'Integer',
                    _integerCoordinates,
                    (value) => _integerCoordinates = value,
                  ),
                ),
              ],
            ),
            Row(
              key: const ValueKey('lock-row'),
              children: [
                Expanded(
                  child: _toggleButton(
                    'Xlock',
                    _lockX,
                    (value) => _lockX = value,
                  ),
                ),
                const Offstage(
                  key: ValueKey('swap-switch'),
                  offstage: true,
                  child: SizedBox(),
                ),
                const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                Expanded(
                  child: _toggleButton(
                    'Ylock',
                    _lockY,
                    (value) => _lockY = value,
                  ),
                ),
              ],
            ),
            Row(
              key: const ValueKey('negate-row'),
              children: [
                // Workspace.bky cross-binds these two source buttons.
                Expanded(
                  child: _toggleButton(
                    'Ynega',
                    _negateY,
                    (value) => _negateY = value,
                  ),
                ),
                const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
                Expanded(
                  child: _toggleButton(
                    'Xnega',
                    _negateX,
                    (value) => _negateX = value,
                  ),
                ),
                Expanded(
                  child: _toggleButton(
                    'Exchange',
                    _exchangeAxes,
                    (value) => _exchangeAxes = value,
                  ),
                ),
              ],
            ),
            const _LegacyValueRow(key: ValueKey('uv-row'), values: ['0', '0']),
          ],
        ),
      ),
    ),
    _inspectorSection(
      header: _sectionHeader(
        keyName: 'wireframe-operations-manager',
        icon: CupertinoIcons.link,
        label: 'Connection',
        value: _couplingSectionVisible,
        update: (value) => _couplingSectionVisible = value,
      ),
      body: _functionGroupBody(
        isExpanded: _couplingSectionVisible,
        child: Row(
          key: const ValueKey('wireframe-operations-panel'),
          children: [
            Expanded(child: _classicButton('Symmetry')),
            const SizedBox(width: AngelCupertinoTokens.buttonRowGap),
            Expanded(child: _classicButton('Reverse')),
          ],
        ),
      ),
    ),
    _inspectorSection(
      header: _sectionHeader(
        keyName: 'drawing-reference-manager',
        icon: CupertinoIcons.photo,
        label: 'Reference',
        value: _referenceSectionVisible,
        update: (value) => _referenceSectionVisible = value,
      ),
      body: _functionGroupBody(
        isExpanded: _referenceSectionVisible,
        child: Column(
          key: const ValueKey('drawing-reference-panel'),
          children: [
            _toggleButton(
              'Display 3 Views',
              _displayReference,
              (value) => _displayReference = value,
              icon: CupertinoIcons.photo,
              showStateSuffix: true,
            ),
            SizedBox(
              key: const ValueKey('reference-texture-row'),
              height: AngelCupertinoTokens.controlOuterHeight,
              child: LegacyUiKitPanel(
                height: AngelCupertinoTokens.controlHeight,
                child: AngelCupertinoDropdown<String>(
                  value:
                      widget.referenceColors.contains(_selectedReferenceColor)
                      ? _selectedReferenceColor
                      : widget.referenceColors.firstOrNull,
                  items: {
                    for (final color in widget.referenceColors)
                      color: 'Solid: $color',
                  },
                  onChanged: (value) {
                    setState(() => _selectedReferenceColor = value);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ]);

  Widget _functionGroupBody({
    required bool isExpanded,
    required Widget child,
  }) => LegacyUiKitFunctionGroupBody(isExpanded: isExpanded, child: child);

  Widget _toggleButton(
    String label,
    bool value,
    ValueChanged<bool> update, {
    IconData? icon,
    bool showStateSuffix = false,
  }) {
    final foreground = value
        ? CupertinoColors.white
        : AngelCupertinoTokens.label;
    return LegacyUiKitToggleButton(
      isActive: value,
      onToggle: () => setState(() => update(!value)),
      width: double.infinity,
      height: AngelCupertinoTokens.controlHeight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon ?? _actionIcon(label),
              color: foreground,
              size: AngelCupertinoTokens.iconSize,
            ),
            const SizedBox(width: AngelCupertinoTokens.unit * 2),
            Text(
              showStateSuffix ? '$label:${value ? 'On' : 'Off'}' : label,
              style: TextStyle(
                color: foreground,
                fontSize: AngelCupertinoTokens.bodyFontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String keyName,
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> update,
  }) => LegacyUiKitFunctionGroupHeader(
    key: ValueKey(keyName),
    width: double.infinity,
    icon: icon,
    label: label,
    value: value,
    onChanged: (nextValue) {
      setState(() => update(nextValue));
    },
  );

  Widget _classicButton(
    String label, {
    VoidCallback? onPressed,
    double height = AngelCupertinoTokens.controlHeight,
  }) => LegacyUiKitButton(
    width: double.infinity,
    height: height,
    onPressed: onPressed,
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _actionIcon(label),
            color: AngelCupertinoTokens.label,
            size: AngelCupertinoTokens.iconSize,
          ),
          const SizedBox(width: AngelCupertinoTokens.unit * 2),
          Text(label, maxLines: 1, style: AngelCupertinoTokens.bodyTextStyle),
        ],
      ),
    ),
  );

  Widget _classicIconButton(
    IconData icon,
    String label, {
    VoidCallback? onPressed,
  }) => Semantics(
    button: true,
    enabled: onPressed != null,
    label: label,
    child: LegacyUiKitButton(
      width: double.infinity,
      height: AngelCupertinoTokens.controlHeight,
      onPressed: onPressed,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AngelCupertinoTokens.label,
              size: AngelCupertinoTokens.iconSize,
            ),
            const SizedBox(width: AngelCupertinoTokens.unit * 2),
            Text(label, style: AngelCupertinoTokens.compactTextStyle),
          ],
        ),
      ),
    ),
  );

  IconData _actionIcon(String label) => switch (label) {
    'Select' => CupertinoIcons.cursor_rays,
    'Connect' => CupertinoIcons.link,
    'Loft' => CupertinoIcons.cube_box,
    'Edge' => CupertinoIcons.scribble,
    'Group' => CupertinoIcons.square_stack_3d_up,
    'Import' => CupertinoIcons.tray_arrow_down,
    'Unfold' => CupertinoIcons.doc_text_search,
    'Drawing State' => CupertinoIcons.scribble,
    'Circle' => CupertinoIcons.circle,
    'Line' => CupertinoIcons.minus,
    'Quit' => CupertinoIcons.xmark_circle,
    'Symmetry' => CupertinoIcons.arrow_left_right,
    'Reverse' => CupertinoIcons.arrow_uturn_left,
    'Drag' => CupertinoIcons.move,
    'Rotation' => CupertinoIcons.rotate_right,
    'Close' => CupertinoIcons.lock,
    'Constant' => CupertinoIcons.arrow_2_circlepath,
    'Integer' => CupertinoIcons.number,
    'Xlock' || 'Ylock' => CupertinoIcons.lock,
    'Ynega' || 'Xnega' => CupertinoIcons.minus_circle,
    'Exchange' => CupertinoIcons.arrow_right_arrow_left,
    _ => CupertinoIcons.circle_grid_3x3,
  };

  Widget _bareToolbarIcon(
    IconData icon,
    String label, {
    required double width,
    required double height,
  }) => Semantics(
    button: true,
    enabled: false,
    label: label,
    child: SizedBox(
      width: width,
      height: height,
      child: CupertinoButton(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(AngelCupertinoTokens.controlRadius),
        onPressed: null,
        child: Center(
          child: Icon(
            icon,
            color: AngelCupertinoTokens.label,
            size: AngelCupertinoTokens.iconSize,
          ),
        ),
      ),
    ),
  );

  Widget _classicToolbarIcon(
    IconData icon,
    String label, {
    required double width,
  }) => Semantics(
    button: true,
    enabled: false,
    label: label,
    child: SizedBox(
      width: width,
      height: AngelCupertinoTokens.toolbarHeight,
      child: LegacyUiKitButton(
        width: width,
        height: AngelCupertinoTokens.controlHeight,
        role: AngelButtonRole.toolbar,
        onPressed: null,
        child: Icon(
          icon,
          color: AngelCupertinoTokens.label,
          size: AngelCupertinoTokens.iconSize,
        ),
      ),
    ),
  );

  Widget _classicToolbarText(String label, {required double width}) => SizedBox(
    width: width,
    height: AngelCupertinoTokens.toolbarHeight,
    child: LegacyUiKitButton(
      width: width,
      height: AngelCupertinoTokens.controlHeight,
      role: AngelButtonRole.toolbar,
      onPressed: null,
      child: Text(label, style: AngelCupertinoTokens.bodyTextStyle),
    ),
  );

  Widget _pickerFormRow({
    required String keyName,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String> onSelected,
  }) => SizedBox(
    key: ValueKey(keyName),
    height: AngelCupertinoTokens.controlOuterHeight,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          label == 'Texture' ? CupertinoIcons.photo : CupertinoIcons.layers,
          size: 18,
          color: AngelCupertinoTokens.accent,
        ),
        const SizedBox(width: AngelCupertinoTokens.unit * 2),
        SizedBox(
          width: AngelCupertinoTokens.compactLeadingWidth,
          child: Text(label, style: AngelCupertinoTokens.bodyTextStyle),
        ),
        const SizedBox(width: AngelCupertinoTokens.internalSpacing),
        Expanded(
          child: LegacyUiKitPanel(
            height: AngelCupertinoTokens.controlHeight,
            child: AngelCupertinoDropdown<String>(
              value: value,
              items: {for (final item in items) item: item},
              placeholder: 'None',
              onChanged: onSelected,
            ),
          ),
        ),
      ],
    ),
  );
}

class _LegacyValueRow extends StatelessWidget {
  const _LegacyValueRow({
    super.key,
    required this.values,
    this.valueKeys,
    this.visible,
  }) : assert(valueKeys == null || valueKeys.length == values.length),
       assert(visible == null || visible.length == values.length);

  final List<String> values;
  final List<String>? valueKeys;
  final List<bool>? visible;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: AngelCupertinoTokens.valueRowHeight,
    child: Row(
      children: [
        for (var index = 0; index < values.length; index++)
          Expanded(
            child: Offstage(
              offstage: visible != null && !visible![index],
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AngelCupertinoTokens.unit * 2,
                  ),
                  child: Text(
                    values[index],
                    key: valueKeys == null ? null : ValueKey(valueKeys![index]),
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                      color: AngelCupertinoTokens.label,
                      fontSize: AngelCupertinoTokens.bodyFontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _CoordinateTable extends StatelessWidget {
  const _CoordinateTable();

  @override
  Widget build(BuildContext context) => const LegacyUiKitPanel(
    key: ValueKey('coordinate-display-table'),
    width: AngelCupertinoTokens.wideSelectorWidth,
    height:
        AngelCupertinoTokens.valueRowHeight * 2 +
        AngelCupertinoTokens.hierarchyGap * 2 +
        AngelCupertinoTokens.hairline * 2,
    child: Column(
      children: [
        _LegacyValueRow(values: ['0', '0', '0']),
        _LegacyValueRow(values: ['0', '0', '']),
      ],
    ),
  );
}
