# Workspace: UI Layout

**Screen**: Workspace  
This document describes every visible UI component in the Workspace screen.

> **Migration authority and icon rule:** The recursive `Workspace.scm` tree is
> authoritative for static layout and `Workspace.bky` is authoritative for
> runtime-created controls, labels, UIKIT recipes, and visibility changes.
> Legacy glyph codes and bitmap-icon names are source evidence only. Every
> production icon leaf must use a semantic Flutter `CupertinoIcons` constant;
> do not register bitmap command icons, `ICONFONTforANGELIII.otf`, a
> replacement icon font, raw `IconData(...)`, Material icons, or custom-painted
> substitutes. Preserve the source container around the substituted leaf.
> See `docs/appinventor_layout_fidelity.md` and
> [21_cupertino_ui_migration.md](./21_cupertino_ui_migration.md).

---

## Top-Level Structure

```
Workspace (Form — landscape, no title/status bar)
│
├── 水平布局12 / HiddenInitRow   [HorizontalArrangement — h=1 — invisible row used to hold init-time component refs]
│   ├── 图像框1 / InitImage      [Image — tiny, no picture]
│   ├── 画布1 / InitCanvas       [Canvas — 1×1]
│   └── origin / OriginLayout    [VerticalArrangement — stores origin/reference data]
│
└── 层叠布局1 / MainOverlay  [AbsoluteArrangement — fill 100% width/height — main UI]
    ├── 关闭文件动画 / CloseAnim   [Image — fill screen — ScalePictureToFit — animated when closing file]
    └── 大区 / MainArea          [VerticalArrangement — full screen, z=99]
        ├── 顶端菜单 / TopMenu    [HorizontalArrangement — h=50, semi-transparent white bg]
        └── 工作区 / WorkArea     [HorizontalArrangement — fill remaining height]
```

---

## Top Menu Bar (`顶端菜单` / TopMenu)

Height: 50 px. Semi-transparent white background (`#8BFFFFFF`).

| Component               | Original Name       | Suggested Name        | Details                                              |
|-------------------------|---------------------|-----------------------|------------------------------------------------------|
| Files button (hidden)   | `按钮_Files`        | FilesButton           | "Files" text — hidden normally, shown during load    |
| Loading button          | `按钮_Loading`      | LoadingButton         | "Loading" text — blue bg, white bold — shown during load |
| Spacer                  | `水平布局25`        | TopSpacer             | w=40, pushes toolbar to the right                    |
| Toolbar scroll area     | `顶端功能区`        | ToolbarScroll         | HorizontalScrollArrangement — contains all tools     |
| → Undo button           | `按钮_撤销`         | UndoButton            | 35×35; SCM bitmap establishes command meaning; Flutter leaf is `CupertinoIcons.arrow_uturn_left` |
| → Spacer                | `水平布局22`        | SmallSpacer1          | w=5                                                  |
| → Save button (hidden)  | `按钮_保存`         | SaveButton            | 50×50; SCM bitmap establishes command meaning; Flutter leaf is `CupertinoIcons.archivebox`; initially hidden |
| → Spacer                | `水平布局23`        | SmallSpacer2          | w=5                                                  |
| → Gesture area          | `手势`              | GestureZone           | HorizontalArrangement — w=100 — holds gesture mode buttons |
| → Ortho view mode       | `正交视角模式`      | OrthoModeZone         | HorizontalArrangement — w=150 — orthographic view selector |
| → Copy button           | `按钮_复制`         | CopyButton            | w=50                                                 |
| → Delete button         | `按钮_删除`         | DeleteButton          | w=50                                                 |
| → Mid button            | `按钮_Mid`          | MidButton             | "Mid" text — w=50 — snaps to midpoint                |
| → Data input field      | `文本输入框_1`      | DataInputField        | hint="Input Data" — 20pt — numeric entry             |
| → Accelerate button     | `加速`              | AccelerateButton      | w=50 — multiplier / speed toggle                     |
| → Focus-steal textbox   | `焦点抢占`          | FocusStealField       | w=1 — nearly invisible — used to steal keyboard focus |
| Export button           | `导出`              | ExportButton          | w=50                                                 |
| Dock button             | `程序坞`            | DockButton            | w=50 — save & open in external app                   |
| Manager zone            | `管理器`            | ManagerZone           | HorizontalArrangement — w=150 — top-right mgr buttons |

---

## Work Area (`工作区` / WorkArea)

The work area is split horizontally into a **viewport column** (left/center) and a **side panel** (right).

### Viewport Column (`叠放窗口母母` → `叠放窗口之母` → `叠放窗口`)

```
叠放窗口母母 / ViewportOuter   [VerticalArrangement — centered, fills height]
└── 叠放窗口之母 / ViewportMid  [AbsoluteArrangement]
    ├── 平滑效果 / SmoothOverlay [Image — HIDDEN — full screen — receives rendered frames from Three.js as base64]
    ├── 按钮_点 / PointButton    [Button — 40×40 — HIDDEN — draggable; represents the active drawing point]
    └── 叠放窗口 / ViewportStack [AbsoluteArrangement — the stacked viewport area]
        ├── 预览窗口 / PreviewWindow   [WebViewer — objsurface.html — loft/surface preview]
        ├── TJS容器 / ThreeJSContainer [WebViewer — objloaderng.HTML — main 3D engine]
        ├── 触控层 / TouchCanvas       [Canvas — overlaid on top — captures all gestures]
        └── 参考图片 / ReferenceImage  [Image — shows 3-view orthographic reference image]
```

### Side Panel (`功能区` / SidePanel)

The side panel is a `HorizontalArrangement` containing several tabs, each a `VerticalScrollArrangement`. Only one tab is visible at a time.

The six SCM siblings remain in this exact order: Import, Options, Items,
Material, Transform, Wireframe. Wireframe is the design-time visible branch.
`Workspace.bky` initializes the three-choice top manager (Wireframe, Transform,
Items) that changes which retained sibling is visible.

---

## Side Panel Tabs

### Tab 1: Import (`导入` / ImportTab) — HIDDEN initially

- `导入flexbox` — a `VerticalArrangement` wrapping a `Flexbox1` grid.
- Shows thumbnails of previously imported texture/reference images.
- Thumbnails are 125×80 Image widgets, loaded from base64 stored in `截图地址库` TinyDB.

---

### Tab 2: Options (`选项` / OptionsTab) — HIDDEN initially

*(Content created dynamically; not mapped in the SCM — placeholder for settings.)*

---

### Tab 3: Items (`项目` / ItemsTab) — HIDDEN initially

```
项目 / ItemsTab  [VerticalScrollArrangement]
├── 目录管理器 / DirectoryManager  [HorizontalArrangement — tab header/breadcrumb]
├── 边缘菜单 / EdgeModeMenu        [HorizontalArrangement — item-type selector]
│   ├── 按钮_Select / SelectBtn   [Button — "Select"]
│   ├── 按钮_Connect / ConnectBtn [Button — "Connect"]
│   └── 按钮_Loft / LoftBtn       [Button — "Loft"]
├── 复选框_Select / SelectCheckbox [CheckBox — "Select" — HIDDEN — internal state tracker]
├── 放样菜单 / LoftMenu            [HorizontalArrangement — HIDDEN — loft submenu]
│   ├── 按钮_多选成组 / MultiSelectBtn [Button — "Select"]
│   ├── 按钮_Edge / EdgeBtn        [Button — "Edge"]
│   └── 按钮_Group / GroupBtn      [Button — "Group"]
├── 复选框_多选成组 / MultiSelectCB [CheckBox — HIDDEN]
├── 组合菜单 / GroupMenu           [HorizontalArrangement — HIDDEN — group submenu]
│   ├── 按钮_Import / ImportObjBtn [Button — "Import"]
│   └── 按钮_Unfold / UnfoldBtn   [Button — "Unfold"]
├── 边缘列表 / EdgeList            [VerticalScrollArrangement — dynamically populated with edge items]
├── 成组 / GroupList               [VerticalScrollArrangement — HIDDEN]
│   └── 成组垂直布局 / GroupItemLayout [VerticalArrangement — Flexbox container for group members]
└── 放样 / LoftList                [VerticalScrollArrangement — HIDDEN — loft surface items]
```

---

### Tab 4: Materials (`材质` / MaterialsTab) — HIDDEN initially

*(Populated dynamically at runtime.)*

---

### Tab 5: Transform (`变换` / TransformTab) — HIDDEN initially

`Workspace.bky` gives its four manager/body pairs the runtime labels
`Dragging`, `Transformation`, `Texture & Group`, and `Flip & Align`, in the
same order as the SCM nodes below.

```
变换 / TransformTab  [VerticalScrollArrangement]
├── 复选框_Drag / DragCheckbox         [CheckBox — "Drag" — HIDDEN — internal state]
├── 手势平移管理器 / GesturePanManager [HorizontalArrangement — section header]
├── 手势平移 / GesturePanPanel         [VerticalArrangement]
│   ├── 按钮_Drag / DragBtn            [Button — "Drag" — pan mode]
│   ├── 按钮_旋转 / RotationBtn        [Button — "Rotation" — rotation mode]
│   └── 水平布局5 / AxisRow            [HorizontalArrangement]
│       ├── 按钮_X / XAxisBtn          [Button — "X"]
│       ├── 按钮_Y / YAxisBtn          [Button — "Y"]
│       └── 按钮_Z / ZAxisBtn          [Button — "Z"]
│   └── 水平布局6 / ApplyCancelRow     [HorizontalArrangement]
│       ├── 按钮_Cancel / CancelBtn    [Button — "Cancel"]
│       └── 按钮_Apply / ApplyBtn      [Button — "Apply"]
├── 数据组变换管理器 / DataTransformMgr [HorizontalArrangement — section header]
├── 数据组变换 / DataTransformPanel     [VerticalArrangement]
│   ├── 标签1 / MoveLabel              [Label — "Move（X,Y,Z）"]
│   ├── 水平布局2 / TranslateRow       [HorizontalArrangement]
│   │   ├── 平移X / TranslateX         [Label — "0" — editable display]
│   │   ├── 平移Y / TranslateY         [Label — "0"]
│   │   └── 平移Z / TranslateZ         [Label — "0"]
│   ├── 标签2 / RotLabel               [Label — "Rotation(Tilt,Heading)"]
│   ├── 水平布局3 / RotateRow          [HorizontalArrangement]
│   │   ├── 旋转X / RotateX            [Label — "0"]
│   │   ├── 旋转Y / RotateY            [Label — "0" — HIDDEN]
│   │   └── 旋转Z / RotateZ            [Label — "0"]
│   ├── 标签3 / ScaleLabel             [Label — "Scale(X,Y,Z,Whole)"]
│   └── 水平布局4 / ScaleRow           [HorizontalArrangement]
│       ├── 拉伸X / ScaleX             [Label — "0"]
│       ├── 拉伸Y / ScaleY             [Label — "0"]
│       ├── 拉伸Z / ScaleZ             [Label — "0"]
│       └── 缩放比例 / ScaleWhole      [Label — "0"]
├── 色盒群组管理器 / TextureGroupMgr   [HorizontalArrangement — section header]
├── 色盒群组 / TextureGroupPanel       [VerticalArrangement]
│   ├── 水平布局10 / GroupRow          [HorizontalArrangement]
│   │   ├── 标签_Group / GroupLabel    [Label — "Group"]
│   │   └── 选择群组 / GroupSpinner    [Spinner — group selector dropdown]
│   ├── 水平布局11 / TextureRow        [HorizontalArrangement]
│   │   ├── 标签_Texture / TexLabel    [Label — "Texture"]
│   │   └── 选择色盒 / TextureSpinner  [Spinner — texture/livery selector]
│   └── 按钮_编辑贴图 / EditLiveryBtn  [Button — "Edit Livery"]
├── 按钮变换管理器 / ButtonTransformMgr [HorizontalArrangement — section header]
├── 垂直布局1 / FlipAlignPanel         [VerticalArrangement]
│   ├── 水平布局13 / RotateRow         [HorizontalArrangement]
│   │   ├── X90 / RotX90Btn            [Button — rotate 90° around X]
│   │   ├── 按钮_Y镜像 / MirrorYBtn    [Button — mirror on Y axis]
│   │   └── Z90 / RotZ90Btn            [Button — rotate 90° around Z]
│   └── 水平布局15 / AlignRow          [HorizontalArrangement]
│       ├── 按钮_X对齐 / AlignXBtn     [Button — align to X axis]
│       ├── 按钮_Y对齐 / AlignYBtn     [Button — align to Y axis]
│       └── 按钮_Z对齐 / AlignZBtn     [Button — align to Z axis]
└── [Hidden checkboxes: 复选框_旋转, 复选框_X/Y/Z, 选择模式 spinner]
```

---

### Tab 6: Wireframe (`线框` / WireframeTab) — VISIBLE initially

`Workspace.bky` gives its four manager/body pairs the runtime labels
`Strokes`, `Surface`, `Connection`, and `Reference`. These labels supersede
descriptive screenshot aliases such as “Drawing,” “Surface-based,” “Coupling,”
and “Reference Map.”

```
线框 / WireframeTab  [VerticalScrollArrangement]
│
├── 绘制控制条 / DrawControlBar         [HorizontalArrangement — section header]
├── 绘制功能组 / DrawFuncGroup          [VerticalArrangement]
│   ├── 按钮_绘制状态 / DrawModeBtn     [Button — SCM literal "CMD_Line"; English presentation alias "Drawing State"; toggles draw mode]
│   └── 绘制功能组可锁定 / DrawPanel    [VerticalArrangement — HIDDEN until draw mode active]
│       ├── 水平布局1 / DrawTypeRow     [HorizontalArrangement]
│       │   ├── 按钮_Close / ClosePathBtn  [Button — "Close" — close path]
│       │   ├── 按钮_Circle / CircleBtn    [Button — "Circle" — draw circle arc]
│       │   └── 按钮_Line / LineBtn        [Button — "Line" — draw straight line]
│       ├── 表面点倍率选择器 / SurfaceRateSelector [HorizontalArrangement — multiplier for surface point snapping]
│       ├── 表格布局1 / CoordDisplay     [TableArrangement — shows real-time XYZ and angle data]
│       │   ├── 新点X / NewPointX        [Label — "0" — X coordinate of next point]
│       │   ├── 新点Y / NewPointY        [Label — "0" — Y coordinate]
│       │   ├── 新线条长度 / LineLength  [Label — "0" — line length]
│       │   ├── 新线条角度 / LineAngle   [Label — "0" — line angle]
│       │   └── 新点Z / NewPointZ        [Label — "0" — Z coordinate]
│       └── 按钮_Quit / QuitDrawBtn      [Button — "Quit" — exit draw mode]
│
├── 表面管理器 / SurfaceManager          [HorizontalArrangement — section header]
├── 表面线 / SurfacePanel               [VerticalArrangement]
│   ├── 按钮_锁定到表面 / StickToSurfBtn [Button — "Stick To a Surface"]
│   ├── [Hidden checkboxes for: StickToSurface, IntegerSnap]
│   ├── 水平布局26 / SnapModeRow        [HorizontalArrangement]
│   │   ├── 按钮_连续打点 / ConstantBtn  [Button — "Constant" — continuous point mode]
│   │   └── 按钮_Integer / IntegerBtn    [Button — "Integer" — snap to integer coords]
│   ├── [Hidden checkboxes: Constant, Xlock, Ylock]
│   ├── 水平布局18 / LockRow            [HorizontalArrangement]
│   │   ├── 按钮_Xlock / XLockBtn       [Button — "Xlock" — lock X axis movement]
│   │   ├── 互换开关 / SwapSwitch        [Switch — HIDDEN]
│   │   └── 按钮_Ylock / YLockBtn       [Button — "Ylock" — lock Y axis movement]
│   ├── 水平布局19 / NegateRow          [HorizontalArrangement]
│   │   ├── 按钮_Xnega / XNegBtn        [Button — "Xnega" — negate X axis]
│   │   ├── 按钮_Ynega / YNegBtn        [Button — "Ynega" — negate Y axis]
│   │   └── 按钮_互换 / SwapBtn         [Button — "Exchange" — swap X/Y axes]
│   ├── [Hidden checkboxes: Xnega, Ynega, Exchange]
│   └── 水平布局16 / UVRow              [HorizontalArrangement]
│       ├── UVX / UVX                   [Label — "0" — current surface U coordinate]
│       └── UVY / UVY                   [Label — "0" — current surface V coordinate]
│
├── 线框操作管理器 / WireframeOpsMgr    [HorizontalArrangement — section header]
├── 线框操作 / WireframeOpsPanel        [VerticalArrangement]
│   └── 水平布局24 / WireOpsRow         [HorizontalArrangement]
│       ├── 按钮_对称衔接 / SymmetryBtn  [Button — "Symmetry" — symmetric edge connect]
│       └── 按钮_Reverse / ReverseBtn   [Button — "Reverse" — reverse edge direction]
│
├── 绘制参考管理器 / DrawRefMgr         [HorizontalArrangement — section header]
└── 绘制参考 / DrawRefPanel             [VerticalArrangement]
    ├── 按钮_显示参考图片 / ShowRefBtn   [Button — "Display 3 Views" — show orthographic reference overlay]
    ├── [Hidden checkbox: DisplayRef]
    └── 水平布局17 / RefTextureRow      [HorizontalArrangement]
        └── 选择参考色盒 / RefTextureSpinner [Spinner — select which texture set to use as 3-view reference]
```

**Flutter Spinner mapping correction (2026-07-30):** `RefTextureSpinner` and
the other Workspace Spinner leaves retain their source parent, sibling order,
size relationship, runtime element order, and selection behavior. Their leaf
widget is the reusable `AngelCupertinoDropdown<T>`, implemented with
`CupertinoMenuAnchor` and ordered `CupertinoMenuItem` children. This is an
anchored dropdown mapping; do not substitute a `CupertinoPicker`, centered
modal, or `CupertinoContextMenuAction` list.

**UIKIT rendering correction:** Classic buttons use the recovered translucent
`#7E7E7E21` background, radius 5, elevation 1, white content, and 100/400 ms
press feedback. Checkbox-bound controls use blue/white only while active and
white/black while inactive. Function managers use a white 40×40, radius-9,
elevation-6 moving pad with no inactive tiles. Do not add metallic/glossy
gradients, pill shading, generic borders, or an invented blue-action
hierarchy.

---

## Service Components

| Original Name             | Type             | Suggested Name          | Purpose                                                         |
|---------------------------|------------------|-------------------------|-----------------------------------------------------------------|
| `KevinkunEnhance1`        | KevinkunEnhance  | KevinkunEnhance         | Rounded corners, shadows, margins on dynamic buttons            |
| `视图组件动画1`            | ViewAnimator     | ViewAnim                | Viewport scale transitions, UI fade animations                  |
| `HTTP客户端1`             | Web              | HttpClient              | (Background music, same as other screens)                       |
| `高速缓存`                | TinyDB           | FastCache               | Stores drawing point coordinates (绘制X/Y/Z keys)              |
| `文件管理器1`             | File             | FileManager             | Read/write `.SPA` files, check existence                       |
| `link`                    | TinyDB           | LinkDB                  | Stores the background image base64 for the workspace            |
| `信息分享器1`             | Sharing          | SharingHelper           | Share exported file                                             |
| `缓存`                    | TinyDB           | Cache                   | Stores: gesture mode, operation stamp index, misc UI state      |
| `大容量缓存`              | TinyDB           | UndoCache               | Full undo history stack (JSON list of snapshots)                |
| `扫描触发加载序列`        | Clock            | LoadSequenceClock       | Drives the multi-step async file loading sequence               |
| `屏幕尺寸改变`            | Clock            | ScreenSizeClock         | Fires when screen dimensions change (orientation switch)        |
| `扫描触发初始化`          | Clock            | InitTriggerClock        | Fires once on startup to begin the load sequence after a delay  |
| `信息对话框1`             | Notifier         | Notifier                | Progress dialogs, confirm dialogs, message dialogs              |
| `活动启动器1`             | ActivityStarter  | ActivityStarter         | Open file in external app (dock feature)                        |
| `文件选择框1`             | FilePicker       | FilePicker              | Native file chooser for import                                  |
| `监督手势`                | Clock            | GestureWatchClock       | Monitors multi-finger gesture state                             |
| `Flexbox1`                | Flexbox          | FlexboxMain             | Flexible layout for group member thumbnails                     |
| `截图地址库`              | TinyDB           | ScreenshotDB            | Stores thumbnail base64 keyed by project path                   |
| `导入项目FB`              | Flexbox          | ImportFlexbox           | Flexbox for import thumbnail strip (top of import panel)        |
| `UPDATE`                  | Clock            | UpdateClock             | General-purpose periodic update clock                           |
