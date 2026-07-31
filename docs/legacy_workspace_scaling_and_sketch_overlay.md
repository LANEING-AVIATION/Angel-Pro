# Legacy Workspace Scaling and Sketch Overlay Addendum

## Status

- **State:** Reference
- **Updated:** 2026-07-30
- **Usage:** Legacy technical context for renderer/overlay behavior; not a visual-style mandate.

## Status and Sources

This addendum records behavior recovered directly from the exported App Inventor
project after the original author clarified the design intent on 2026-07-30. It
supplements, but does not modify, the immutable files in `Auto-Transcription/`.

Primary evidence:

- `A3NG_EN/.../Workspace.scm`
- `A3NG_EN/.../Workspace.bky`
- `A3NG_EN/assets/objloaderng.HTML`
- `Auto-Transcription/06_workspace_3d_engine.md`
- `Auto-Transcription/08_workspace_drawing_mode.md`

## 1. Why the Entire Interface Was Scaled

The oversized container was intentional, not an accidental layout artifact.
The first interface used controls at their declared App Inventor sizes, but too
little content fit on screen. The later workaround rendered the entire main
interface in a larger logical coordinate space and scaled it down as one unit.

`界面刷新()` / `refreshInterface()` implements the key relationship:

```text
StackedViewport.width  = screen.width
StackedViewport.height = screen.height

MainArea.width  = screen.width  * 1.25
MainArea.height = screen.height * 1.25

MainArea.scaleX = 0.8
MainArea.scaleY = 0.8
MainArea.position = (0, 0)
```

Because `1.25 * 0.8 == 1.0`, the scaled `MainArea` visually occupies the screen
while its children appear at 80% of their authored size. This allowed more
toolbar and inspector content to fit without individually redesigning every
component.

Consequences visible in the source:

- The internal top menu height is 50 logical pixels but appears approximately
  40 physical/CSS pixels after the whole-interface scale.
- The internal side panel width is 250 logical pixels but appears approximately
  200 pixels after scaling.
- Touch coordinates, reference images, the Canvas, and WebViewer geometry need
  explicit compensation because layout size and visible size are no longer the
  same coordinate space.

## 2. Periodic Window-Size Synchronization

`屏幕尺寸改变` / `ScreenSizeChanged` is a `Clock`. It is disabled during initial
screen construction, enabled after the staged document load, and disabled again
when the file closes. No custom interval is stored in `Workspace.scm`, so the
App Inventor default interval applies.

On each timer tick:

1. Set the Edge, Group, and Loft list heights to:

   ```text
   screen.height * 1.25 - 150
   ```

2. Compare `StackedViewport.width` with `screen.width`.
3. If the absolute difference exceeds 6 pixels:
   - call `界面刷新()` to rebuild the oversized/scaled layout geometry;
   - call `TJS大世界自动刷新(true, 5)` to refresh/reload the main scene;
   - clear cached `px` and `py` values.

This was polling-based responsive behavior. It repaired the UI eventually but
could leave a visible delay, repeat expensive work, and reload more of the 3D
scene than a camera/renderer resize actually required.

## 3. Why the Legacy Three.js Camera Was Not Responsive

`objloaderng.HTML` captures:

```javascript
var ww = window.innerWidth;
var wh = window.innerHeight;
```

It then creates the renderer and several orthographic cameras from those initial
values. The file contains no `window.resize` listener and does not subsequently
update:

- renderer width/height;
- orthographic frustum bounds;
- perspective-camera aspect;
- projection matrices.

The App Inventor timer therefore had to detect size drift outside the WebViewer
and trigger a heavier scene refresh.

`全局缩放()` / `globalZoom()` also reconstructs orthographic camera code using
the current WebViewer width, height, and global scale. It applies
`globalScale / 8` to the reference image, refreshes the camera, redraws the
in-progress contour when drawing mode is active, and repositions the reference
image.

### Perspective camera was dormant

The editor HTML declares `cameraPER` and a `renderPER()` helper, but the active
editor render path calls `render()`, which always applies `x/y/z` and
`Ax/Ay/Az` to the orthographic `camera`. The App Inventor `全局缩放()` procedure
also generates a new `THREE.OrthographicCamera(...)` expression. Perspective
projection was therefore retained as experimental/dormant code and was not the
production sketch-aligned editor camera.

The Flutter editor must likewise treat orthographic projection as the canonical
editing camera. A perspective camera may exist later as an optional viewing
mode, but it must not silently replace the camera used by the sketch overlay.

## 4. Sketch Canvas and 3D Viewport Calibration

The main viewport stack contains, in z-order:

1. surface preview WebViewer;
2. main Three.js WebViewer;
3. transparent `触控层` / `TouchCanvas`;
4. optional reference image.

All are children of the same `叠放窗口` / `StackedViewport`. The Canvas fills
that parent and receives the gesture events, so sketching occurs on a transparent
overlay aligned with the 3D scene underneath.

### Scale compensation

The source defines horizontal and vertical centered scale conversions:

```text
scaledX = x * globalScale
        - canvasWidth * globalScale / 2
        + canvasWidth / 2

scaledY = y * globalScale
        - canvasHeight * globalScale / 2
        + canvasHeight / 2
```

Equivalently:

```text
scaledPoint = canvasCenter + (point - canvasCenter) * globalScale
```

These conversions compensate for scaling around the viewport center.

### World/screen conversion

In drawing mode:

- `TouchUp` converts local Canvas pixels into a point on the selected
  orthographic plane.
- `Dragged` either updates that point or pans the camera, depending on gesture
  mode.
- `新轮廓预览()` transforms stored world points by the current camera offset,
  removes the inactive orthographic axis, converts the remaining axes into
  Canvas coordinates, and draws the transient polyline/crosshair.
- Camera moves and global zooms trigger another contour preview so the overlay
  remains aligned.

The calibration is therefore a two-way mapping:

```text
Canvas local position -> active-plane world point
active-plane world point -> Canvas preview position
```

Both directions depend on the same camera position, active orthographic plane,
viewport dimensions, and global zoom.

## 5. Legacy Native/WebView Data-Flow Architecture

The exported project has a clear ownership split.

### App Inventor/native side owns

- `.SPA` document data and undo state;
- edge, loft, texture, and grouping collections;
- camera state variables (`X/Y/Z`, `AX/AY/AZ`, and global scale);
- gesture-mode interpretation;
- sketch points and active orthographic plane;
- staged scene-loading queues;
- save/export orchestration.

### Editor HTML/WebViewer owns

- the Three.js renderer and scene graph;
- the active orthographic camera;
- OBJ parsing and scene insertion;
- render execution;
- frame capture and scene serialization.

### Native to WebViewer

App Inventor calls `EvaluateJavascript` or `EvaluateJavascriptCallback`.
Commands are assembled by concatenating JavaScript source:

- assign camera variables and call `render()`;
- recreate the orthographic camera after viewport/zoom changes;
- call `classload(...)` or `loadObj(...)` with base64 OBJ data;
- mutate preview transforms such as `scene.scale.x/y/z`;
- request `captured()` or scene serialization;
- sequence large scene loads through callback-gated timer queues.

### WebViewer to native

The HTML calls:

```javascript
window.AppInventor.setWebViewString(value)
```

Two payload families are present:

- `captured()` returns a JPEG data URL from `renderer.domElement.toDataURL()`;
- `TEXT()` returns `JSON.stringify(scene.toJSON())`.

`TJS容器.WebViewStringChange` receives the value. In the primary observed path
it makes `平滑效果` visible and assigns the returned image to
`PictureBase64`, producing a temporary native overlay while the WebViewer is
being refreshed.

### Typed Flutter replacement

The Dart replacement is defined by:

- `lib/renderer/angel_editor_contract.dart`
- `lib/renderer/angel_editor_gateway.dart`
- `lib/renderer/angel_javascript_bridge.dart`

The layers are:

```text
Flutter document / gesture / sketch state
                |
                v
AngelEditorCommand (typed intent + JSON payload)
                |
                v
AngelEditorGateway
                |
                v
AngelJavascriptBridge (readiness gate + ordered request envelopes)
                |
                v
offline Three.js handler registry
                |
                v
AngelEditorEvent (typed WebView-to-Dart response/event)
```

This retains the original separation without exposing application code to raw
JavaScript strings. Commands explicitly include the orthographic camera,
viewport metrics, active sketch plane, and local/world points required for
projection. Events distinguish readiness, viewport synchronization, capture,
serialization, projection, unprojection, and errors instead of overloading one
untyped string callback.

## 6. Flutter/Three.js Modernization Recommendations

### Interface layout

Do not reproduce the 125%-container plus 80%-transform workaround. Use
`LayoutBuilder` constraints as the live source of truth and design compact
Cupertino measurements directly:

- keep toolbar height and inspector width as explicit responsive tokens;
- use horizontal scrolling/overflow for commands;
- use a scrollable inspector;
- reduce padding and control density intentionally at compact breakpoints;
- collapse or overlay the inspector only when the viewport would otherwise
  become unusable.

This preserves the original goal—show more tools—without scaling text, hit
targets, WebViews, and gesture coordinates into different spaces.

### Resize propagation

Replace periodic polling with event-driven updates:

1. Flutter `LayoutBuilder` detects every viewport constraint change.
2. The Web page uses `ResizeObserver` (plus `window.resize` as a fallback).
3. Resize the renderer using CSS-pixel dimensions and the current device-pixel
   ratio.
4. Update the active camera:
   - perspective: set `aspect`;
   - orthographic: recompute left/right/top/bottom from viewport size and zoom.
5. Call `camera.updateProjectionMatrix()` and render once.

Coalesce rapid resize events to one update per animation frame. Do not reload
geometry or recreate the WebView merely because its rectangle changed.

### Overlay architecture

Use one Flutter `Stack` with identical constraints for:

```text
Positioned.fill(WebView)
Positioned.fill(CustomPaint)
Positioned.fill(GestureDetector)
```

The painter and gesture detector must use the exact viewport content rectangle,
excluding toolbar, inspector, margins, and borders. Avoid independent width and
height calculations for the three layers.

### Coordinate model

Create one immutable `ViewportMetrics`/camera snapshot containing:

- viewport logical size;
- device-pixel ratio;
- camera type and projection parameters;
- camera transform/target;
- orthographic zoom;
- active sketch plane;
- optional content inset.

Use one shared projection contract for both directions:

- screen-to-world: convert `localPosition` to normalized device coordinates,
  unproject a ray through the camera, then intersect the active sketch plane;
- world-to-screen: project the world point through the same camera matrices and
  map normalized device coordinates back into Flutter logical pixels.

Three.js may calculate these mappings and return results through the existing
bridge, or Dart may do so using synchronized matrices. Do not maintain separate
hand-tuned scale formulas on each side.

### Verification

Add deterministic tests for:

- center point round-trip: `screen -> world -> screen`;
- corners and points near every viewport edge;
- all XY, XZ, and YZ sketch planes;
- window resize with unchanged camera target;
- orthographic zoom and camera pan;
- non-1.0 device-pixel ratios;
- inspector width changes;
- maximum tolerated round-trip error (for example, <= 0.5 logical pixel).

These tests should make Canvas/scene misalignment detectable without relying
only on visual inspection.
