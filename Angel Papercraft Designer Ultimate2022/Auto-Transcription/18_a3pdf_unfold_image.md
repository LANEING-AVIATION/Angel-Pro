# Screen: UnfoldIMG (A3PDF_EN image export screen)

**Original name**: `UnfoldIMG`  
**Suggested Flutter route**: `/export/image`  
**Orientation**: Landscape  
**Form title**: `Export img`

---

## Purpose

`UnfoldIMG` exports unfolded sheets as image files (JPG), instead of PDF.

It shares most geometry and camera logic with `UnfoldULT`, but the output path is image-based.

---

## UI structure

Top toolbar:

- `按钮_恢复线条` (`PEN.PNG`, hidden initially)
- `按钮_去除线条` (`EYESHUT.PNG`, hidden initially)
- `文本输入框_1` (scale, default `5.2`)
- `按钮_SaveIMG`

Main content:

- `TJS容器` WebViewer
- `网页导出的图像` receiver image
- `手势平移` gesture overlay (no `Cover.PNG` background in this screen)

---

## Component rename dictionary

| Original | Suggested English name |
|---|---|
| `按钮_SaveIMG` | `saveImageButton` |
| `按钮_去除线条` | `hideLinesButton` |
| `按钮_恢复线条` | `restoreLinesButton` |
| `文本输入框_1` | `scaleInputBox` |
| `TJS容器` | `threeJsUnfoldWebView` |
| `网页导出的图像` | `webExportedImage` |
| `手势平移` | `gestureOverlay` |
| `扫描触发加载序列` | `loadSequenceClock` |
| `窗口适应` | `viewportFitClock` |

---

## Global variable mapping (24 globals)

Same as `UnfoldULT`, plus two image-export-specific fields:

| Original global | Suggested name |
|---|---|
| `fileID` | `fileId` |
| `页数` | `pageCount` |
| `小` | `thumbScale` |
| `目录` | `outputDirectory` |
| `AX` `AY` `AZ` | `camPitch` `camYaw` `camRoll` |
| `俯仰角` `圆盘角` | `pitchAngle` `yawAngle` |
| `X` `Y` `Z` | `camX` `camY` `camZ` |
| `js字典` | `jsStateMap` |
| `JS备份` | `jsBackup` |
| `OBJ归档` | `objArchive` |
| `OBJ大典` | `objDictionary` |
| `标题段` | `titleSegment` |
| `边缘列表` | `edgeList` |
| `图片库` | `imageStore` |
| `图片列表` | `imageList` |
| `放样集合` | `loftCollection` |
| `追加放样集合` | `appendedLoftCollection` |
| `新轮廓列表` | `newOutlineList` |
| `可以进入下一项` | `canAdvanceStep` |

---

## Core event flow

### `TJS容器.PageLoaded`

- Loads unfold JSON payload (`/storage/emulated/0/SPACEDESK/导出的图纸/code.json`)
- Injects geometry as base64 OBJ text
- Applies camera state (`角度换算赋值`)

### `扫描触发加载序列.Timer`

- Calls `相机刷新`
- Continues callback-based staged loading from `unfoldcode.txt` and in-memory state

### `按钮_SaveIMG.Click`

- Triggers JS-side render capture via `EvaluateJavascript`
- Result arrives in `TJS容器.WebViewStringChange`

### `TJS容器.WebViewStringChange`

Image output pipeline:

1. Convert `网页导出的图像` to bitmap.
2. Save bitmap as `.jpg` in:
   - `/storage/emulated/0/SPACEDESK/导出的图纸/`
3. Uses `File.BitmapSaveCallback`.

### line visibility buttons

- `按钮_去除线条.Click` -> load `//flatpure.HTML`
- `按钮_恢复线条.Click` -> load `//flatloader.HTML`

### gesture overlay events

- `手势平移.TouchDown / TouchMoving / TouchUp` send camera transform updates to JS
- Includes occasional cache clear call (`TJS容器.ClearCaches`) in move flow

---

## Shared procedures with UnfoldULT

`UnfoldIMG` reuses the same unfold math and camera procedures:

- `TJS大世界自动刷新`
- `角度换算赋值`
- `相机刷新`
- `W64SPA转OBJ`
- `面序号`
- `空间求角度`
- `空间求距离`
- `求平面F`
- `加维度`
- `新轮廓预览` / `画线`

---

## Flutter rebuild notes

1. Keep this route as a sibling to PDF route, sharing one common state model.
2. Implement output mode switch:
   - PDF mode -> build pages.
   - IMG mode -> raster export to gallery/filesystem.
3. Avoid screen-to-screen temp-file handoff (`unfoldcode.txt`) in Flutter; pass typed in-memory state.

