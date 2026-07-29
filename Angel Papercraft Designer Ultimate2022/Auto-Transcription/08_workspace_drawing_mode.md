# Workspace: Wireframe Drawing Mode

**Screen**: Workspace  
This document describes the wireframe/outline drawing mode where users place 3D points and create edges.

---

## Overview

Drawing mode allows users to place points in an **orthographic projection** (one of three planes: XY, XZ, or YZ) and connect them into wireframe edges. Points are placed by tapping or dragging on the `触控层` (TouchCanvas). The resulting edges are stored in `edgeList` and rendered in the Three.js viewport.

---

## Activating / Deactivating Draw Mode

### Entering Draw Mode: `按钮_绘制状态.Click` / DrawModeButton tap

- Toggles `isDrawingMode` (global `绘制模式`).
- If entering draw mode:
  - Make `绘制功能组可锁定` (DrawPanel) visible.
  - Switch to orthographic view layout.
  - Clear the canvas (`TouchCanvas.Clear()`).
  - Reset `newOutlinePoints = []`.
- If exiting: call `退出绘制()`.

### `退出绘制()` / exitDrawMode()

```
isDrawingMode = false
DrawPanel.Visible = false
call 窗口模式123(1)     // switch back to mode 1 (normal view)
call TouchCanvas.Clear()
newOutlinePoints = []
```

### `按钮_Quit.Click` / QuitDrawButton tap

Calls `退出绘制()`.

---

## Orthographic View Axis (`orthoViewAxisIndex` / `主轴序号正交面`)

Controls which 2D plane is active:

| Value | Plane | Meaning                      |
|-------|-------|------------------------------|
| 1     | YZ    | Looking along X axis         |
| 2     | XZ    | Looking along Y axis         |
| 3     | XY    | Looking along Z axis (top)   |
| 4     | Free  | Free-orbit 3D view (non-ortho)|

In draw mode, only values 1–3 are meaningful. The plane determines which coordinate axes are affected by touch movement:

- **Plane 1 (YZ)**: dragging updates `Y` and `Z` coordinates. `X` is read from `高速缓存["绘制X"]`.
- **Plane 2 (XZ)**: dragging updates `X` and `Z`. `Y` is read from `高速缓存["绘制Y"]`.
- **Plane 3 (XY)**: dragging updates `X` and `Y`. `Z` is read from `高速缓存["绘制Z"]`.

---

## Touch Input in Draw Mode

### `触控层.TouchUp` event (finger lifted)

1. Position `按钮_点` (PointButton) at the touch coordinates (with offset for visual indicator).
2. **Coordinate conversion**: raw canvas pixel → 3D world coordinates using anonymous functions `反向折算横()` / `反向折算竖()` (inverse projection).
3. Store converted X/Y/Z into `高速缓存` (FastCache) under keys `"绘制X"`, `"绘制Y"`, `"绘制Z"` (only the two relevant axes per plane).

### `触控层.Dragged` event (finger moving in draw mode, gesture mode ≠ 2)

1. Convert pixel delta to world coordinate delta.
2. Update `高速缓存["新点X"]`, `["新点Y"]`, `["新点Z"]` by adding the delta.
3. If `StickToSurface` mode is active: update `UVX` and `UVY` labels instead.
4. After updating: call `新轮廓预览()` to redraw the in-progress stroke on the canvas.

### `触控层.Dragged` event (in draw mode, gesture mode = 2 = pan)

- Move the camera (pan the orthographic view) rather than placing points.
- Updates `cameraX`, `cameraZ` (and `cameraY` for non-top-view planes).
- Calls `相机移动()`.

---

## `打点()` / placePoint()

Called when the user confirms a point placement (e.g., taps `按钮_点`):

```
if (number of points in newOutlinePoints) > 4:
    disable PointButton (prevent overflow)
add current [X, Y, Z] to newOutlinePoints
```

> The original shows a check for > 4 points, but the full logic for point lists is implemented via anonymous functions not fully visible in this extraction. The key idea: each confirmed tap adds a 3D coordinate to `newOutlinePoints`.

---

## `新轮廓预览()` / previewNewOutline()

Draws the in-progress outline on the `TouchCanvas` to give the user visual feedback:

1. Clear canvas (`TouchCanvas.LineWidth = 1`).
2. For each consecutive pair of points in `newOutlinePoints`:
   - Project each 3D point back to 2D canvas coordinates.
   - Draw a line between them using `TouchCanvas.DrawLine()`.
3. Show the `按钮_点` at the last known position.

Also calls `previewAutoRefresh()` to update the 3D preview window.

---

## `画十字()` / drawCrosshair()

Draws a crosshair (+) at the current point position on the TouchCanvas. Used as a visual indicator for the active drawing cursor.

---

## Drawing Line Types

Three line types can be selected in the DrawPanel:

| Button           | Original Name        | Mode      | Description                                         |
|------------------|----------------------|-----------|-----------------------------------------------------|
| `按钮_Line`      | LineButton           | Line      | Straight line segment between two points            |
| `按钮_Circle`    | CircleButton         | Circle    | Arc/circle segment (uses multiple intermediate pts) |
| `按钮_Close`     | ClosePathButton      | Close     | Closes the current path (connects last to first pt) |

The active type is tracked by a hidden checkbox (`复选框_Close`) and the `画圆刷新锁` flag for circle mode.

---

## Surface Snapping (`StickToSurface` Mode)

When `按钮_锁定到表面` is active (`复选框_锁定到表面.Checked = true`):

- Points are snapped to the surface of an existing mesh rather than placed freely.
- Touch dragging updates `UVX` and `UVY` (surface UV coordinates) instead of raw XYZ.
- `uvxy更改后(value)` / `onUVXYChanged()` is called to recompute the 3D position from UV.
- The `表面点倍率` (surfacePointMultiplier) scales the UV movement.

---

## Axis Locking

Available while drawing to restrict movement to a specific axis:

| Button            | Original Name   | Effect                                          |
|-------------------|-----------------|-------------------------------------------------|
| `按钮_Xlock`      | XLockButton     | Lock X: drag only changes Y coordinate          |
| `按钮_Ylock`      | YLockButton     | Lock Y: drag only changes X coordinate          |
| `按钮_Xnega`      | XNegButton      | Negate X: flip the X component of movement     |
| `按钮_Ynega`      | YNegButton      | Negate Y: flip the Y component                 |
| `按钮_互换`        | SwapButton      | Exchange X/Y: swap X and Y movement components |
| `按钮_连续打点`    | ConstantButton  | Continuous mode: auto-place point on every drag |
| `按钮_Integer`    | IntegerButton   | Integer snap: round coordinates to whole numbers|

Each button toggles its corresponding hidden `CheckBox` component. The checkbox state is read during drag handling.

---

## Coordinate Display Panel

Located in the DrawPanel, a `TableArrangement` shows real-time feedback:

| Label Original  | Suggested Name  | Content                          |
|-----------------|-----------------|----------------------------------|
| `新点X`          | NewPointX       | X coordinate of the next point  |
| `新点Y`          | NewPointY       | Y coordinate                    |
| `新点Z`          | NewPointZ       | Z coordinate                    |
| `新线条长度`      | NewLineLength   | Distance from last to new point |
| `新线条角度`      | NewLineAngle    | Angle of the new line segment   |

These are updated by `长度角度()` / `computeLengthAngle()` after each point movement.

---

## Reference Image (`参考图片`)

The `参考图片` / ReferenceImage widget is an `Image` placed inside the viewport:

- Shown when `复选框_打开参考图片.Checked = true`.
- Displays the 3-view orthographic blueprint image.
- The image source is selected from `imageList` using `选择参考色盒` (RefTextureSpinner).
- `色盒初始化()` / `initTexture()`: Sets `参考图片.PictureBase64` from `imageList[selectedIndex]`. Only shown when `orthoViewAxisIndex <= 3` (ortho mode).
- `参考图移动()` / `moveReferenceImage()`: Repositions the reference image on the canvas to align with the current camera offset and scale. Called after any camera move or scale change.

---

## Symmetry & Reverse Operations

Located in the WireframeOps section:

| Button               | Original Name      | Operation                                                      |
|----------------------|--------------------|----------------------------------------------------------------|
| `按钮_对称衔接`       | SymmetryButton     | Mirror/symmetrically connect two edges across an axis          |
| `按钮_Reverse`        | ReverseButton      | Reverse the point order of a selected edge (flips normal)     |

---

## Flutter Implementation Notes

- The `TouchCanvas` is a transparent overlay on the WebViewer. In Flutter, use a `GestureDetector` + `CustomPainter` for the canvas overlay.
- The coordinate conversion (`反向折算横/竖`) converts pixel positions on the canvas to 3D world positions based on the current camera position, zoom level, and active plane. Implement this as a pure Dart function given the camera state and canvas dimensions.
- `newOutlinePoints` accumulates points until the user commits them (taps a confirm button or closes the path). The in-progress stroke is drawn on the `CustomPainter` layer.
- When `isDrawingMode` is active, drag events should NOT move the camera (unless `gestureMode == 2`). The mode switch needs to be detected at the gesture level.
- The **crosshair** (`画十字`) and **point button** (`按钮_点`) together provide the drawing cursor. In Flutter, render these as `CustomPainter` elements on the canvas overlay.
- UV surface snapping requires the Flutter app to query the Three.js engine for the surface hit point at a given UV coordinate.
