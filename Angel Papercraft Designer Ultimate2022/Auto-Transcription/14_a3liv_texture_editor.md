# Screen: Texture (A3LIV_EN main livery editor)

**Original name**: `Texture`  
**Suggested Flutter route**: `/livery/editor`  
**Orientation**: Landscape  
**Form title**: `Set Liveries and References`

---

## Purpose

`Texture` is the production screen for assigning liveries/material images to the 3D model.

It combines:

1. A Three.js WebViewer (`TJS容器`) for model preview.
2. A texture-box UI (`X/Y/Z` image faces).
3. Dynamic component generation (UIKIT procedures).
4. Shared-file persistence back to SPACEDESK project data.

---

## High-level UI structure

### Top bar

- `标签_Done` (Done action)
- `按钮_NewBox`
- `按钮_Remove` (hidden by default)
- Optional hidden debug actions (`按钮_Export`, `按钮_刷新`, `开关_刷新`)
- Color picker spinner (`选择贴图盒颜色`)

### Middle controls

- Sliders: `水平滑动条1/2/3` (positioning/offset controls)
- Name editor textbox: `名称` (rename selected item)
- List panel: `图像盒列表` (texture box list)

### Preview area

- `TJS容器` inside `三维大览` for live 3D display.
- `图像盒大览` / nested `色盒` stack with face pickers:
  - `图像选择框_X`
  - `图像选择框_Y`
  - `图像选择框_Z`

---

## Component renaming dictionary (important UI elements)

| Original component | Suggested English name | Notes |
|---|---|---|
| `图像盒列表` | `textureBoxList` | Main list of texture entries |
| `图像盒大览` | `textureBoxPreviewRoot` | 2D texture face preview area |
| `色盒` | `textureCubePanel` | Nested panel holding X/Y/Z faces |
| `XPIC` / `YPIC` / `ZPIC` | `xFaceImage` / `yFaceImage` / `zFaceImage` | Current images per face |
| `图像选择框_X/Y/Z` | `xFacePicker` / `yFacePicker` / `zFacePicker` | Picks face image from storage |
| `三维大览` | `threeDPreviewPanel` | Container for WebViewer preview |
| `TJS容器` | `threeJsTextureWebView` | Main Three.js WebViewer |
| `TJS触控` | `threeJsTouchCanvas` | Gesture layer for drag/scale events |
| `标签_Done` | `doneActionLabel` | Commit and return flow |
| `扫描触发加载序列` | `loadSequenceClock` | Asynchronous load coordinator |
| `计时器1` | `bootstrapClock` | Reads file link + lock at startup |

---

## Global variable mapping (35 globals)

| Original global | Suggested name |
|---|---|
| `light` | `lightConfig` |
| `body` | `bodyMesh` |
| `tire_rr` | `rearRightTireMesh` |
| `tire_rf` | `frontRightTireMesh` |
| `tire_lr` | `rearLeftTireMesh` |
| `tire_lf` | `frontLeftTireMesh` |
| `选中项索引` | `selectedItemIndex` |
| `OBJ归档` | `objArchive` |
| `归位函数` | `resetPoseFn` |
| `AX` | `camPitch` |
| `AY` | `camYaw` |
| `AZ` | `camRoll` |
| `俯仰角` | `pitchAngle` |
| `圆盘角` | `diskAngle` |
| `正交面序号` | `orthoPlaneIndex` |
| `js字典` | `jsStateMap` |
| `JS备份` | `jsBackup` |
| `颜色列表` | `colorList` |
| `可以进入下一项` | `canAdvanceStep` |
| `时间` | `timeTick` |
| `max` | `maxValue` |
| `附件库` | `attachmentStore` |
| `边缘列表` | `edgeList` |
| `放样集合` | `loftCollection` |
| `标题段` | `titleSegment` |
| `JSON备份` | `jsonBackup` |
| `图片列表` | `imageList` |
| `X` | `panelOffsetX` |
| `Y` | `panelOffsetY` |
| `Z` | `panelOffsetZ` |
| `全局比例` | `globalScale` |
| `手势比例` | `gestureScale` |
| `选中的放样索引` | `selectedLoftIndex` |
| `手势` | `gestureMode` |
| `OBJ大典` | `objDictionary` |

---

## Core event logic

### `Texture.Initialize`

Primary setup pipeline:

1. Build runtime UI blocks (`UIKIT建立条形函数选择器`, `UIKIT建立函数管理器`, `UIKIT建立经典按钮`).
2. Apply panel styling (`KevinkunEnhance1.SetBackground`, animation calls).
3. Load initial layout data (`载入平面排版`).
4. Trigger initial 3D refresh (`TJS大世界自动刷新` -> `TJS容器.GoToUrl("//Texloaderng.HTML")`).
5. Initialize X/Y/Z/P layout helpers.

### `计时器1.Timer`

Bootstraps shared project context from SPACEDESK:

- Reads `/storage/emulated/0/SPACEDESK/filelink.txt`
- Checks `/storage/emulated/0/SPACEDESK/lock.txt`
- Calls `载入平面排版`, `结构刷新`, `图片列表和附件库的初始化`

### `图像盒列表.AfterPicking`

Main selection event:

- Calls `打开色盒`
- Repositions visible preview panels (`平面排版的位移和置顶`)
- Applies face panel transitions (`X`, `Y`, `Z`, `P`)

### Face image pickers (`图像选择框_X/Y/Z.AfterPicking`)

- Convert selected image/canvas data to base64
- Update corresponding face (`XPIC`/`YPIC`/`ZPIC`)
- show user feedback via `信息对话框1.ShowAlert`

### `标签_Done.Click`

Commit/return behavior:

- Shows progress dialog
- Reads/updates project link state
- Saves text payload back to disk (`SaveTextCallback`)
- Deletes lock file when needed
- self-deletes Done label (temporary UI teardown) before leaving flow

---

## Key procedures and roles

| Procedure | Practical role |
|---|---|
| `TJS大世界自动刷新` | Reload Three.js texture page (`//Texloaderng.HTML`) |
| `结构刷新` | Rebuilds dynamic list/layout controls, event handlers, flexbox rows |
| `载入平面排版` | Hydrates texture panel UI from current JSON/image state |
| `图片列表和附件库的初始化` | Initializes image repositories, outputs PNGs to SPACEDESK |
| `相机移动` | Sends camera variables to JS (`EvaluateJavascriptCallback`) |
| `角度换算赋值` | Converts local angles to JS camera values |
| `UIKIT建立经典按钮*` | Creates runtime icon/text action controls |
| `W64SPA转OBJ` + `面序号` | Converts `.SPA` geometry data into OBJ-ready text/index ordering |

---

## WebViewer bridge behavior

- App -> JS: `TJS容器.EvaluateJavascript(...)` / `EvaluateJavascriptCallback(...)`
- JS -> App: `WebViewStringChange` payloads (`data:obj;base64,` and `data:img;base64,`)

`TJS容器.PageLoaded` is the major sync point:

1. Inject model/material payload to JS.
2. Apply camera values (`角度换算赋值` + `相机移动`).
3. Dismiss progress once ready.

---

## Flutter reconstruction notes

1. Treat this screen as the **single source of truth** for livery editing.
2. Move all dynamic UIKIT behaviors to strongly-typed Flutter widgets/state.
3. Preserve the shared-file contract (`filelink.txt`, lock behavior) initially for compatibility, then replace with direct in-app route state.
4. Replace icon font controls using the migration rules in `11_icon_system_migration.md`.

