# Screen: UnfoldULT (A3PDF_EN main PDF export screen)

**Original name**: `UnfoldULT`  
**Suggested Flutter route**: `/export/pdf`  
**Orientation**: Landscape  
**Form title**: `Export PDF`

---

## Purpose

`UnfoldULT` is the core PDF export screen:

1. Loads unfolded geometry into Three.js (`TJS容器`).
2. Lets user pan/scale preview and toggle line visibility.
3. Captures rendered pages and feeds them to `KIO4_Pdf`.
4. Saves/finishes `export.pdf` and invokes sharing.

---

## UI structure

### Top toolbar

- `标签_Export` (title)
- `按钮_恢复线条` (icon: `PEN.PNG`, hidden initially)
- `按钮_去除线条` (icon: `EYESHUT.PNG`, hidden initially)
- `文本输入框_1` (ratio/scale input, default `3.1`)
- `按钮_Save` (final PDF output)
- `按钮_ExpIMG` (switch to image-export path)

### Left panel

- `按钮_加入PDF` (append current rendered page into PDF queue)
- `垂直滚动条布局1` dynamic page thumbnail list

### Main preview area

- `TJS容器` (WebViewer)
- `网页导出的图像` (image receiver/capture layer)
- `手势平移` (`Cover.PNG` watermark frame overlay)

---

## Component rename dictionary

| Original | Suggested English name |
|---|---|
| `按钮_加入PDF` | `addPageToPdfButton` |
| `按钮_Save` | `savePdfButton` |
| `按钮_ExpIMG` | `openImageExportButton` |
| `按钮_去除线条` | `hideLinesButton` |
| `按钮_恢复线条` | `restoreLinesButton` |
| `文本输入框_1` | `scaleInputBox` |
| `TJS容器` | `threeJsUnfoldWebView` |
| `手势平移` | `gestureOverlay` |
| `网页导出的图像` | `webExportedImage` |
| `窗口适应` | `viewportFitClock` |
| `扫描触发加载序列` | `loadSequenceClock` |

---

## Global variable mapping (23 globals)

| Original global | Suggested name |
|---|---|
| `fileID` | `fileId` |
| `页数` | `pageCount` |
| `AX` | `camPitch` |
| `AY` | `camYaw` |
| `AZ` | `camRoll` |
| `俯仰角` | `pitchAngle` |
| `圆盘角` | `yawAngle` |
| `X` | `camX` |
| `Y` | `camY` |
| `Z` | `camZ` |
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
| `代码列表` | `codeList` |

---

## Core event flow

### `UnfoldULT.Initialize`

- Prepares UI positions/elevation (including `按钮_加入PDF`)
- Starts load pipeline clocks

### `TJS容器.PageLoaded`

1. Parse/convert project geometry (`W64SPA转OBJ`).
2. Apply angle conversion (`角度换算赋值`).
3. Save/read unfold payload files (`code.json` and related flow).
4. Push OBJ/image payload into JS (`data:obj;base64`, `data:img;base64`).

### `扫描触发加载序列.Timer`

- Calls `相机刷新`
- Continues staged load process using callback-based JS bridge

### `按钮_加入PDF.Click`

- Executes JS capture path and sends image back through `WebViewStringChange`
- `TJS容器.WebViewStringChange` then:
  - `KIO4_Pdf1.AddPage(...)`
  - Creates thumbnail component in `垂直滚动条布局1`

### `按钮_Save.Click`

- Finalizes PDF (`KIO4_Pdf1.Finish`)
- Shares `export.pdf` (`信息分享器1.ShareFile`)

### `按钮_ExpIMG.Click`

- Saves handoff file: `/storage/emulated/0/SPACEDESK/unfoldcode.txt`
- Opens `UnfoldIMG` with start value

### line visibility toggles

- `按钮_去除线条.Click` -> `TJS容器.GoToUrl("//flatpure.HTML")`
- `按钮_恢复线条.Click` -> `TJS容器.GoToUrl("//flatloader.HTML")`

---

## Key procedures

| Procedure | Role |
|---|---|
| `TJS大世界自动刷新` | Reloads `flatloader.HTML` and reapplies angle state |
| `相机刷新` | Sends X/Y/Z + angle updates to JS |
| `保存` | Serializes unfold state to disk |
| `新轮廓预览` | Clears/updates dynamic line overlays in `手势平移` |
| `画线` | Creates runtime line components for overlay previews |
| `显示TAB` | Builds row/card entry for exported pages |

---

## Flutter rebuild notes

1. Replace `KIO4_Pdf` with Dart `pdf` + `printing` pipeline.
2. Keep the staged JS capture model initially (for parity), then migrate to direct Dart canvas/PDF composition if possible.
3. Keep `Cover.PNG` overlay as a dedicated foreground layer in Flutter Stack.

