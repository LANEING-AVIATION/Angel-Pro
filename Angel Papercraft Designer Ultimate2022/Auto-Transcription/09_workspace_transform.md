# Workspace: Transform Operations

**Screen**: Workspace  
This document describes how the user moves, rotates, and scales objects using touch gestures and the transform panel.

---

## Overview

Transform operations are applied to the **currently selected object** (edge, loft surface, or group). They are controlled through:
1. **Gesture input** on the `TouchCanvas` (pinch/drag).
2. **Data entry** in the Transform panel (editable labels).
3. **Axis buttons** (X90, Z90, Mirror Y, Align X/Y/Z).
4. **Operation axis mode** (full-screen transform with visible gizmo).

---

## Important legacy trick: synchronized manipulation overlay

To manipulate a single object without disturbing the full-scene context, the legacy app uses a two-layer preview trick:

1. Keep the main scene in `TJS容器` as global context.
2. Render a focused standalone-object preview in `预览窗口`.
3. During transform operations, sync camera parameters (`相机代码`, derived from `AX/AY/AZ/X/Y/Z`) into both viewers so they share the same viewing direction and perspective.
4. Apply translation/rotation/scale preview updates to the focused layer (`平移预览`, transform JS calls), producing a visual "highlighted manipulated object" effect.

This is why users perceive object-isolation feedback even though AppInventor had no native single-object gizmo workflow.

---

## Gesture Modes

The global `gestureMode` (手势) integer controls how the canvas gestures are interpreted:

| Mode | Integer | Behavior                                               |
|------|---------|--------------------------------------------------------|
| Rotate | 1   | Single-finger drag rotates the camera (orbit)          |
| Pan  | 2       | Single-finger drag pans the camera (translate view)    |
| Transform | 3 | Single-finger drag moves selected object; pinch scales |

Mode is persisted in `Cache` DB under key `"手势"`. The `手势` / GestureZone HorizontalArrangement in the top toolbar contains mode-selector buttons.

---

## Pinch-to-Scale (Two Finger Gesture)

### `触控层.ScaleBegin`
```
gestureScaleStart = globalScale
savedGestureMode = gestureMode
gestureMode = max(gestureMode, ?)   // temporarily override
```

### `触控层.Scale` (ongoing pinch)
```
if gestureMode == 3 (transform mode):
    // Scale selected object
    delta = currentScale / previousScale
    if X axis active: scaleX *= delta
                      → PreviewWindow.EvaluateJavascript("scene.scale.x = " + scaleX)
    if Y axis active: scaleY *= delta
                      → PreviewWindow.EvaluateJavascript("scene.scale.z = " + scaleY)
    if Z axis active: scaleZ *= delta
                      → PreviewWindow.EvaluateJavascript("scene.scale.y = " + scaleZ)
else:
    // Zoom viewport
    globalScale = gestureScaleStart * currentScale
    call globalZoom()
```

### `触控层.ScaleEnd`
```
gestureMode = savedGestureMode   // restore previous mode
prescale = 1                     // reset scale delta
```

---

## Single-Finger Drag (Transform Mode 3)

### `触控层.Dragged` (gestureMode == 3, not drawing mode)

```
compute dx = currentX - prevX   (pixel delta)
compute dy = currentY - prevY

if 复选框_旋转.Checked (rotation mode):
    rotateZ += -dx * sensitivity
    rotateX = 0
    call 平移预览(translateX, -something, translateY)
else (translation mode):
    if Z axis active: translateZ += dx * sensitivity
    if X axis active: translateX += dx * sensitivity
    if Y axis active: translateY += dy * sensitivity
    call 平移预览(translateX, -something, translateY)
```

After each drag step, the preview window is updated via `平移预览()`.

---

## Single-Finger Drag (Camera Control, modes 1 and 2)

### `触控层.Dragged` (gestureMode == 1, orbit mode, not drawing mode)

```
sensitivity = 0.2
dx = currentX - prevX
dy = currentY - prevY
yawAngle  += -dx * sensitivity
pitchAngle += -dy * sensitivity
orthoViewAxisIndex = 4      // switch to free-orbit view
call initTexture()           // hide reference image
call moveCamera()
```

### `触控层.Dragged` (gestureMode == 2, pan mode, not drawing mode)

In 3D mode (not drawing):
```
sensitivity = 1
cameraX += -dx * sensitivity
cameraZ += (computed from dy and plane)
cameraY += (computed)
call moveCamera()
```

---

## Transform Panel — Data Input

The Transform panel (`变换` tab) contains editable label pairs for each transform component. Each label acts as a tap-to-edit numeric field.

### Translation (`平移X`, `平移Y`, `平移Z`)
- Stores the XYZ offset of the selected object relative to its original position.
- Updated live as the user drags in transform mode.
- Sent to Three.js via `平移预览()`.

### Rotation (`旋转X`, `旋转Z`) [旋转Y is hidden]
- Rotation around X (tilt) and Z (heading) axes.
- The `变换()` procedure applies rotation:
  ```
  local R = rotateZ.Text
  local F = rotateX.Text
  local h = tan(something)
  rotateX = -rotateX   // negate
  rotateY = degreesToRadians(something)
  rotateZ = -rotateZ
  [run in background]
  ```

### Scale (`拉伸X`, `拉伸Y`, `拉伸Z`, `缩放比例`)
- Per-axis scale and a uniform scale (`缩放比例`).
- `缩放比例` (ScaleWhole): applies uniform scale to all axes.

### `重置变换参数()` / resetTransformParams()
Resets all fields to default:
```
translateX = translateY = translateZ = 0
rotateX = rotateY = rotateZ = 0
scaleX = scaleY = scaleZ = 1
scaleWhole = 1
```

---

## `平移预览(tx, ty, tz)` / translationPreview(tx, ty, tz)

Sends the current translation to the preview window:
```javascript
scene.position.x = tx;
scene.position.y = ty;
scene.position.z = tz;
```

---

## `打开操作轴()` / openOperationAxis()

Enters full-screen transform mode (gestureMode = 3):
```
if gestureMode != 3:
    Cache.StoreValue("手势", gestureMode)   // remember previous mode
call resetTransformParams()
call refreshPreviewNoArgs()
call translationPreview(0, 0, 0)
call 窗口模式123(3)     // full-screen viewport mode
gestureMode = 3
GestureZone.Width = 150
```

### `关闭操作轴()` / closeOperationAxis()

Exits transform mode and restores the previous gesture mode:
```
gestureMode = Cache.GetValue("手势")
GestureZone.Width = 100
call 窗口模式123(2)    // or back to previous layout
```

---

## Axis Rotation Buttons (Quick Operations)

Located in the "Flip & Align" section of the Transform tab:

| Button         | Original     | Operation                                        |
|----------------|--------------|--------------------------------------------------|
| `X90`          | RotX90Btn    | Rotate selected object 90° around the X axis    |
| `Z90`          | RotZ90Btn    | Rotate selected object 90° around the Z axis    |
| `按钮_Y镜像`   | MirrorYBtn   | Mirror/flip selected object across the Y axis   |

Each of these sends a JS command to Three.js to apply the transformation and then stamps the undo operation.

---

## Axis Align Buttons

| Button          | Original      | Operation                                                 |
|-----------------|---------------|-----------------------------------------------------------|
| `按钮_X对齐`    | AlignXButton  | Align selected object's X position to 0 (center on X)   |
| `按钮_Y对齐`    | AlignYButton  | Align on Y                                                |
| `按钮_Z对齐`    | AlignZButton  | Align on Z                                                |

---

## `按钮_Apply.Click` / ApplyButton tap

Commits the current transform values to the geometry:
1. Read translate/rotate/scale values from labels.
2. Compute final transform matrix using `矩阵()` function.
3. Send transform to Three.js engine.
4. Call `打下操作戳()` to push undo snapshot.
5. Reset transform params.

---

## `按钮_Cancel.Click` / CancelButton tap

Discards the current transform:
1. Call `重置变换参数()`.
2. Call `平移预览(0, 0, 0)` to restore position in preview.
3. Call `关闭操作轴()`.

---

## `变换翻译()` / transformTranslate() — Return Function

A helper function that translates transform values from the UI representation to the Three.js representation. Returns the corrected value considering axis conventions.

---

## `矩阵()` / matrix() — Return Function

Computes and returns the full 4×4 transformation matrix from the current translate/rotate/scale values. Used before applying transforms to the Three.js scene.

---

## `居中()` / centerObject()

Centers the selected object at the world origin:
- Uses `local_declaration_expression` to compute the bounding box center.
- Applies an offset translation to move the object to (0, 0, 0).

---

## Texture & Group Assignment (in Transform Tab)

The "Texture & Group" section allows assigning a group and texture to the selected object:

### Group Selector (`选择群组` / GroupSpinner)

A `Spinner` dropdown populated with group names from the project. When changed:
```
EVENT: 选择群组.AfterSelecting
    → update selected object's group assignment
    → refresh structure
    → stamp undo operation
```

### Texture Selector (`选择色盒` / TextureSpinner)

A `Spinner` dropdown populated with texture names from `imageList`. When changed:
```
EVENT: 选择色盒.AfterSelecting
    → update selected object's texture index
    → send updated material to Three.js
    → stamp undo operation
```

### Edit Livery Button (`按钮_编辑贴图` / EditLiveryButton)

- Opens the livery editor (navigates to a sub-view or opens a dialog).
- The livery editor allows the user to paint or position texture UV coordinates.

---

## Flutter Implementation Notes

- **Gesture handling**: Use `GestureDetector` with separate handlers for `onScaleStart`, `onScaleUpdate`, `onScaleEnd`, and `onPanUpdate`. The mode switching (`gestureMode`) determines which handler logic to activate.
- **Transform values**: Store all transform values in a `TransformState` data class (translateXYZ, rotateXZ, scaleXYZ, scaleWhole). Use `ValueNotifier` or a `ChangeNotifier` to broadcast changes to both the UI labels and the Three.js engine.
- **Apply vs Cancel**: The Apply/Cancel pattern maps to a "pending transform" concept. While dragging, send preview commands to Three.js. On Apply, commit to the model data. On Cancel, revert to the last committed state.
- **Axis selectors** (X/Y/Z checkboxes in the toolbar): Maintain as a `Set<Axis>` state. The drag handler checks this set to determine which components of the movement delta to apply.
- **Pinch scale**: Flutter's `ScaleUpdateDetails.scale` provides the cumulative scale. Compute the delta by comparing against the scale at `ScaleBegin`. This matches the original `prescale` variable pattern.
