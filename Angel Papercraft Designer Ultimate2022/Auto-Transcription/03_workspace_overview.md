# Screen: Workspace — Overview

**Original name**: `Workspace`  
**Suggested Flutter route**: `/workspace`  
**Orientation**: Landscape  
**Background**: Blurred wallpaper (`Backpicqualitylow.png`), with `BackgroundImageinBase64` loaded from `link` TinyDB on init. The `平滑效果` (SmoothEffect) image overlays a snapshot received from the Three.js WebViewer whenever it sends a render frame.

---

## Purpose

The Workspace is the **core 3D editing screen**. It hosts a real-time Three.js 3D viewport inside a `WebViewer` (`TJS容器`), a secondary preview `WebViewer` (`预览窗口`), and a full side-panel UI for object management, transformation, wireframe drawing, material assignment, and import/export.

---

## How the Screen Is Opened

The file path of the `.SPA` project to open is passed as the **screen start value** (`getStartValue`). On `Workspace.Initialize`:

1. If `manifest.txt` exists → the manifest lock is active (another session is open) → show redirect / close.
2. Otherwise:
   - Set background image from `link` TinyDB (persisted from last save).
   - Set `FilePicker.DefaultDirectory` to the SPACEDESK root.
   - Show progress dialog "Loading".
   - Store the file path into `currentDirectory` global.
   - After a brief delay: call `读取文件()` / `loadFile()`.

---

## Two WebViewer Viewports

| Component           | Original Name | HTML File          | Role                                        |
|---------------------|---------------|--------------------|---------------------------------------------|
| `TJS容器`           | TJS container | `objloaderng.HTML` | Main Three.js 3D viewport (camera, objects) |
| `预览窗口`          | PreviewWindow | `objsurface.html`  | Secondary surface/loft preview              |
| `触控层`            | TouchCanvas   | —                  | AppInventor Canvas overlaid on the viewports — receives all touch/gesture input |

The two WebViewers are stacked inside `叠放窗口` (`StackedWindow`) using `AbsoluteArrangement`. The touch-transparent Canvas intercepts all finger events and translates them to camera/geometry commands sent to the JS engine via `EvaluateJavascript`.

### Communication: App → Three.js

AppInventor calls `TJS容器.EvaluateJavascriptCallback(jsCode, callback)` to send commands. Examples:
```javascript
var x = 12.5;       // camera position X
var y = 0;          // camera position Y
var z = 30;         // camera position Z
var Ax = 0.3;       // camera pitch angle
var Ay = 1.2;       // camera yaw angle
var Az = 0;         // camera roll angle
scene.scale.x = 1.5;   // scale selected object X axis
```

### Communication: Three.js → App

The Three.js page calls `AppInventor.setWebViewString(base64ImageData)` to push rendered frames back. The `TJS容器.WebViewStringChange` event fires, and the received base64 PNG is assigned to `平滑效果.PictureBase64` — this creates a smooth visual transition while the WebView continues rendering.

---

## Startup Sequence (detailed)

1. **`Workspace.Initialize`**: set globals, start file load.
2. **`扫描触发初始化.Timer`** (init trigger clock, fires once): after delay, calls `读取文件()`.
3. **`读取文件()` / loadFile()**:
   a. Call `赋值()` → reads the `.SPA` file from disk into memory and populates global variables.
   b. Call `UIKIT建立函数管理器(管理器, [...], true)` — builds the top-menu manager buttons.
   c. Call `重置变换参数()` — reset all transform fields to 0/1.
   d. Load `预览窗口` HTML (`objsurface.html`).
   e. Load `TJS容器` HTML (`objloaderng.HTML`).
   f. Call `界面初始化()` — build all side-panel buttons, checkboxes, sliders.
   g. Build Items panel tab-bar.
   h. Re-register all previously registered value-label watchers.
   i. Set gesture/hand area width.
   j. Set initial viewport scale from persisted scale factor.
   k. Create import thumbnail strip.
4. **`扫描触发加载序列.Timer`** (load sequence clock): manages multi-step asynchronous loading (feeds data to Three.js in chunks, updates progress).

---

## Application Modes / View Modes

The workspace operates in several named modes controlled by the `窗口模式123(n)` procedure and various checkbox state variables:

| Mode ID | Name                    | Description                                                  |
|---------|-------------------------|--------------------------------------------------------------|
| 1       | Items mode              | Side panel shows Edges/Groups/Objects list                   |
| 2       | Transform + 3D view     | Side panel shows transform controls; 3D viewport active      |
| 3       | Transform + full screen | Viewport fills most of the screen; operation axis shown      |
| Draw    | `绘制模式=true`         | Wireframe drawing mode; Canvas captures taps as 3D points    |

---

## Undo System

The undo stack is stored in `大容量缓存` (TinyDB, "large cache"). Each undoable operation is tagged with `操作戳序号` (operation-stamp index). On undo (`按钮_撤销.Click`):

1. Load the JSON list from `大容量缓存`.
2. Decrement `操作戳序号` by 1.
3. Restore: `放样集合` from index [5], `图片列表` from [4], `边缘列表` from [2], `标题段` from [1].
4. Refresh the structure and Three.js view.

---

## Save / Exit Flow

```
程序坞.Click / 导出.Click / 按钮_Files.Click / 关闭文件()
    └── 保存(callback):
            if 需要保存:
                ShowProgressDialog("Saving")
                [delayed] serialize globals to JSON
                FileManager.SaveText(json, filePath)
                [on complete]: execute callback
            else:
                execute callback immediately

关闭文件() calls 保存(callback where callback = go back to RecentFiles)
导出.Click  calls 保存(callback where callback = share the file)
程序坞.Click calls 保存(callback where callback = open the file in another app via ActivityStarter)
```

---

## Error Handling

`Workspace.ErrorOccurred` event:
- Dismiss any open progress dialog.

`Workspace.BackPressed` event:
- Acts as a **safety guard**: if the current time is within 2 seconds of the last back-press (i.e., user tapped back twice quickly), dismiss all dialogs and show a warning: "Make sure all background processes have finished before proceeding".
- Update `保护时间 = SystemTime + 2000` on each back-press.
