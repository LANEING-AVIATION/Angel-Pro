# Workspace: 3D Engine Integration (Three.js + WebViewer)

**Screen**: Workspace  
This document describes how the Flutter/AppInventor app communicates with the Three.js 3D engine running inside a WebViewer.

---

## Architecture

```
Flutter/AppInventor App
         │
         ▼  EvaluateJavascript(jsCode)
 ┌───────────────────┐
 │  TJS容器          │    WebViewer hosting objloaderng.HTML
 │  (ThreeJSContainer)│    Three.js scene: mesh, materials, camera
 └───────────────────┘
         │
         ▼  AppInventor.setWebViewString(base64PNG)
TJS容器.WebViewStringChange fires
         │
         ▼
平滑效果.PictureBase64 = base64PNG   (smooth frame overlay)
```

There are **two WebViewers**:

1. **`TJS容器` / ThreeJSContainer** (`objloaderng.HTML`): Main 3D engine. Renders the full scene. Receives camera and geometry commands. Pushes rendered frames back via `setWebViewString`.

2. **`预览窗口` / PreviewWindow** (`objsurface.html`): Secondary preview for surface/loft geometry. Shows a simplified mesh. Updated independently.

The **`触控层` / TouchCanvas** (AppInventor Canvas widget) is overlaid on top of both WebViewers and captures all touch/gesture events. It never renders permanent content — it is cleared after each gesture and used only for transient visual feedback (crosshairs, new-point indicators).

---

## Sending Commands to Three.js

All communication from app to Three.js goes through:

```
call TJS容器.EvaluateJavascriptCallback(jsCode, callback)
```

The `callback` is an anonymous function that runs when Three.js finishes executing the command.

### Command Gating (`cmdUnlock` Pattern)

Because JavaScript is asynchronous and Three.js rendering can be slow, a semaphore pattern is used:

```
global CMDunlock = false   // Initially, Three.js is not ready
global doorknock = null    // Queued callback

procedure TJS大世界自动刷新():
    if CMDunlock == true:
        CMDunlock = false
        [send the full geometry JSON to Three.js via EvaluateJavascript]
        [on complete callback: set CMDunlock = true again]
    else:
        doorknock = [this procedure as a deferred callback]
        // Will be called when Three.js finishes current operation
```

This ensures commands are never lost: if Three.js is busy, the latest refresh request is stored in `doorknockCallback` and executed as soon as Three.js becomes available.

### Camera Commands

Called from `相机移动()` / `moveCamera()`:

```javascript
// Sent sequentially, each with an async callback
var x = <cameraX>;
var y = <cameraY>;
var z = <cameraZ>;
var Ax = <cameraAngleX>;   // radians
var Ay = <cameraAngleY>;   // radians
var Az = <cameraAngleZ>;   // radians
```

Pre-computation: `角度换算赋值()` converts `yawAngle` (degrees) and `pitchAngle` (degrees) to radians:
```
AX = pitchAngle converted to radians
AY = yawAngle converted to radians
AZ = -sin(pitchAngle) * something  (derived from tan)
```

### Scale Commands (Transform mode)

Sent when the user pinches or types a scale value:
```javascript
scene.scale.x = <scaleX>;
scene.scale.y = <scaleZ>;   // Note: Y and Z axes may be swapped in Three.js convention
scene.scale.z = <scaleY>;
```

### Full Scene Refresh

Called from `TJS大世界自动刷新()`. The full geometry state (edges, lofts, groups) is serialised as a custom format string and passed to Three.js:

```
call TJS容器.EvaluateJavascriptCallback(
    "var x = " + cameraX + ";",   // step 1
    callback → ...
    "var y = " + cameraY + ";",   // step 2
    ...
    [full OBJ/geometry data as JS variable] // final step
)
```

The procedure `输出VT()` / `outputVT()` is a function that returns the geometry data in a format Three.js can consume (likely a custom compressed JSON or OBJ-like format, encoded in base64 via `转64表()`).

---

## Receiving Data from Three.js

### `TJS容器.WebViewStringChange` event

When Three.js has finished rendering a frame (or wants to send data back), it calls:
```javascript
AppInventor.setWebViewString(base64ImageData);
```

The AppInventor event fires:
```
EVENT: TJS容器.WebViewStringChange
    平滑效果.Visible = true
    平滑效果.PictureBase64 = value   // value is the base64 PNG
```

The `平滑效果` (`SmoothOverlay`) Image widget is positioned on top of the WebViewer. It shows the last rendered frame while the WebViewer refreshes, preventing flicker. When the WebViewer finishes loading the next frame, the overlay becomes transparent again.

---

## Preview Window (`预览窗口` / PreviewWindow)

The preview window renders a simplified version of the surface geometry (loft/surface preview). It is updated via:

```
call 预览窗口.EvaluateJavascriptCallback(jsCode, callback)
call 预览窗口.EvaluateJavascript(jsCode)
```

It is controlled independently from the main Three.js container.

### Manipulation-overlay sync behavior

Although `预览窗口` is a separate WebViewer, transform mode uses it as a synchronized manipulation overlay:

- The app pushes the shared camera script (`相机代码`) to both `预览窗口` and `TJS容器`.
- Then it triggers render updates (`render();`) in both viewers.
- This keeps direction/perspective aligned while showing a focused object-level transform preview, which visually highlights the currently manipulated item.

`预览无参数刷新()` / `refreshPreviewNoArgs()`: Takes the current `previewData` global and sends it to the preview window.

`预览自动刷新(script)` / `autoRefreshPreview(script)`: Stores `script` to `previewData`, then calls `refreshPreviewNoArgs()`.

---

## WebViewer Viewport Layout

The viewport is controlled via `ViewAnimator` (`视图组件动画1`). The entire viewport stack (`叠放窗口之母`) is animated using `SetScaleX`/`SetScaleY`/`SetX`/`SetY`. This is how the app implements:

- **Zoom**: `SetScaleX = globalScale/8`, `SetScaleY = globalScale/8`.
- **Full screen mode**: Scale = 1.0, no offset.
- **Sub-window mode**: Scale < 1.0, positioned to share screen with the side panel.

`界面刷新()` / `refreshLayout()` sets viewport and main-area dimensions and positions them:
```
叠放窗口.Width  = screenWidth * factor
叠放窗口.Height = screenHeight * factor
大区.Width  = screenWidth * factor
大区.Height = screenHeight * factor
call 叠放窗口.SetPosition(0, 0)
call 大区.SetPosition(0, 0)
ViewAnim.SetScaleX = 0.8   // initial entrance animation
ViewAnim.SetScaleY = 0.8
```

---

## `全局缩放()` / globalZoom() Procedure

Applies the current `globalScale` to the viewport via animation and then refreshes the camera:

```
local scale = globalScale
相机代码 = [replace current scale in camera JS string]
ViewAnim.SetDuration = 1
ViewAnim.SetScaleX = scale / 8
ViewAnim.SetScaleY = scale / 8
call ViewAnim.StartViewAnimations(viewportComponent)
call refreshCamera()
if isDrawingMode:
    call previewNewOutline()
call moveReferenceImage()
```

---

## Flutter Implementation Notes

- Use `flutter_inappwebview` to host both HTML files.
- Place them in `assets/html/objloaderng.html` and `assets/html/objsurface.html`.
- Use `InAppWebViewController.evaluateJavascript()` for app→JS commands.
- For JS→app communication, add a JavaScript channel named `AppInventor`. In Flutter, intercept `onWebViewCreated` and add a `JavaScriptChannel` that routes `setWebViewString` calls to a `StreamController<String>`.
- The `SmoothOverlay` pattern: maintain a `Widget` layer above the `WebView` that shows the last received `base64PNG`. Fade it out after each new frame arrives to prevent flicker.
- The `CMDunlock` gating pattern should be replicated using a `Completer<void>` or a `BehaviorSubject<bool>`.
- The `globalScale / 8` transform suggests the internal Three.js unit scale is 8× the viewport display scale. Keep this constant in mind when setting up the WebViewer transform.
