# Workspace: Global State Variables

**Screen**: Workspace  
There are **63 global variables** that form the state machine of the 3D editor. They are listed below with their original Chinese names, suggested English names, data types, and roles.

---

## 3D Geometry Data (Primary Model State)

These are the core data structures that represent the current project. They are serialised into the `.SPA` file on save.

| Original Name    | Suggested Name        | Type        | Description                                                               |
|------------------|-----------------------|-------------|---------------------------------------------------------------------------|
| `标题段`          | titleSegment          | String/Dict | Metadata header of the project (name, version, etc.)                     |
| `边缘列表`        | edgeList              | List        | All wireframe edges. Each edge is a dict with points, name, layer, etc.   |
| `放样集合`        | loftCollection        | List        | All loft surface definitions. Each entry links edges to a surface mesh.   |
| `图片列表`        | imageList             | List        | All texture/livery image references. Each entry: base64 or file path + UV mapping data. |
| `OBJ大典`         | objDictionary         | Dict        | The full parsed 3D object dictionary loaded from the `.SPA` file.        |

---

## 3D Camera State

| Original Name    | Suggested Name    | Type    | Description                                                    |
|------------------|-------------------|---------|----------------------------------------------------------------|
| `X`              | cameraX           | Number  | Camera position X                                              |
| `Y`              | cameraY           | Number  | Camera position Y                                              |
| `Z`              | cameraZ           | Number  | Camera position Z                                              |
| `AX`             | cameraAngleX      | Number  | Camera pitch angle (radians, computed from `俯仰角`)           |
| `AY`             | cameraAngleY      | Number  | Camera yaw angle (radians, computed from `圆盘角`)             |
| `AZ`             | cameraAngleZ      | Number  | Camera roll angle (always 0 in most modes)                     |
| `圆盘角`          | yawAngle          | Number  | Camera yaw in degrees (user-facing unit)                       |
| `俯仰角`          | pitchAngle        | Number  | Camera pitch in degrees                                        |
| `prescale`        | prevScale         | Number  | Previous pinch scale (used to compute delta scale)             |
| `全局比例`        | globalScale       | Number  | Current viewport zoom/scale factor (applied via ViewAnimator)  |
| `全局比例2`       | globalScale2      | Number  | Secondary scale factor (for specific sub-operations)           |
| `相机代码`        | cameraCode        | String  | Pre-built JS camera command string sent to Three.js            |

---

## Gesture & Input State

| Original Name    | Suggested Name     | Type    | Description                                                        |
|------------------|--------------------|---------|---------------------------------------------------------------------|
| `手势`            | gestureMode        | Integer | Current gesture mode: 1=rotate, 2=pan, 3=transform drag            |
| `真手势`          | savedGestureMode   | Integer | Saved gesture mode before entering transform axis mode             |
| `手势比例`        | gestureScaleStart  | Number  | Scale at the start of a pinch gesture                              |
| `灵敏度64`        | sensitivity64      | Number  | Input sensitivity multiplier                                       |
| `选择豁免`        | selectionExempt    | Boolean | When true, tap does not trigger object selection                   |

---

## Drawing Mode State

| Original Name              | Suggested Name           | Type    | Description                                                          |
|----------------------------|--------------------------|---------|----------------------------------------------------------------------|
| `绘制模式`                  | isDrawingMode            | Boolean | True = wireframe draw mode is active                                 |
| `新轮廓`                    | newOutlinePoints         | List    | List of points being drawn in the current stroke                     |
| `表面点倍率`                | surfacePointMultiplier   | Number  | Scaling multiplier for snapping points to a surface                  |
| `和平面XYZ等价的编号`        | axisPlaneIndex           | Integer | Which orthographic plane is active: 1=YZ, 2=XZ, 3=XY                |
| `主轴序号正交面`             | orthoViewAxisIndex       | Integer | Same as above — primary axis index for the ortho viewport            |

---

## Operation & Undo State

| Original Name          | Suggested Name        | Type    | Description                                                       |
|------------------------|-----------------------|---------|-------------------------------------------------------------------|
| `操作戳序号`            | operationStampIndex   | Integer | Current undo stack pointer (index into undo history)              |
| `允许快撤销`            | allowFastUndo         | Boolean | Whether quick-undo (single operation) is enabled                  |
| `需要保存`              | needsSave             | Boolean | Dirty flag — true if unsaved changes exist                        |
| `需要记录指令`          | shouldRecordCmd       | Boolean | True = current operation should be logged to undo stack           |
| `上一份代码`            | lastCode              | String  | The previously executed JS command (for redo-like replay)         |
| `上上份代码`            | secondLastCode        | String  | The code before last (for double-undo)                            |
| `js队列`               | jsQueue               | List    | Queue of JS commands pending execution in Three.js                |
| `循环队列A`             | loopQueueA            | List    | Part A of a circular command buffer                               |
| `循环队列B`             | loopQueueB            | List    | Part B of a circular command buffer                               |
| `合成队列`              | mergedQueue           | List    | Merged result of loop queues for batch JS execution               |
| `可以进入下一项`         | canAdvanceQueue       | Boolean | Semaphore: true = the JS engine is ready for the next command     |
| `保护时间`              | backPressProtectTime  | Number  | SystemTime timestamp after which a second back-press is allowed   |

---

## Object Selection & Editing State

| Original Name              | Suggested Name            | Type    | Description                                                   |
|----------------------------|---------------------------|---------|---------------------------------------------------------------|
| `选中边缘1放样2组合3`        | selectionMode             | Integer | What type is currently selected: 1=edge, 2=loft, 3=group     |
| `选中的边缘索引`             | selectedEdgeIndex         | Integer | Index of the currently selected edge in `edgeList`           |
| `选中的放样索引`             | selectedLoftIndex         | Integer | Index of the currently selected loft surface                 |
| `将要删除的边缘列表`          | edgesToDelete             | List    | Edges queued for deletion (before confirmation)              |
| `新组成员`                  | newGroupMembers           | List    | Edges being assembled into a new group                        |
| `新放样第一项`               | loftFirstItem             | List    | First edge selected for a new loft operation                  |
| `追加放样集合`               | loftAppendBuffer          | List    | Loft candidates being appended                                |
| `放样组索引`                 | loftGroupIndex            | Integer | Which loft group is being modified                            |

---

## Reference Image State

| Original Name          | Suggested Name        | Type    | Description                                                       |
|------------------------|-----------------------|---------|-------------------------------------------------------------------|
| `参考图色盒坐标`        | refImageUVCoords      | List    | UV/coordinate mapping for the reference image on the canvas       |

---

## UI & Layout State

| Original Name              | Suggested Name         | Type    | Description                                                          |
|----------------------------|------------------------|---------|----------------------------------------------------------------------|
| `屏幕名称`                  | screenName             | String  | Screen identifier string (passed between screens)                   |
| `图片库`                    | imageLibrary           | List    | In-memory image library (loaded texture references)                  |
| `文件目录`                  | filePath               | String  | Full file path of the currently open `.SPA` project                 |
| `预览数据`                  | previewData            | String  | Current geometry data string to render in the preview window         |
| `改变值的标签注册表`         | valueLabelRegistry     | List    | List of [labelRef, callback] pairs — labels that update live values  |
| `复选框函数映射表`           | checkboxFuncMap        | Dict    | Maps checkbox component refs to their handler functions             |
| `输入回调`                  | inputCallback          | Function| Callback function to call when `DataInputField` text changes        |
| `CMDunlock`               | cmdUnlock              | Boolean | True = Three.js engine is ready to receive the next JS command      |
| `doorknock`               | doorknockCallback      | Function| Queued callback waiting for `CMDunlock` to become true              |

---

## Rendering & Visual State

| Original Name          | Suggested Name       | Type    | Description                                                       |
|------------------------|----------------------|---------|-------------------------------------------------------------------|
| `荧光笔`               | highlighterEnabled   | Boolean | Whether edge highlighting mode is active                          |
| `共享截图`             | sharedScreenshot     | String  | Base64 PNG of the current screenshot for sharing                  |
| `截图外链b`            | screenshotExternalB  | String  | External URL/path for the shared screenshot                       |
| `画圆刷新锁`           | circleRefreshLock    | Boolean | Prevents re-entrant circle-drawing refresh                        |
| `可以PER`              | canPerform           | Boolean | Permission flag for certain operations                            |
| `新轮廓`               | newOutlinePoints     | List    | (same as drawing mode — current stroke in progress)               |

---

## Notes for Flutter Implementation

- **All geometry state** (`edgeList`, `loftCollection`, `imageList`, `titleSegment`) should be held in a `ChangeNotifier`-based provider or a `Bloc`. They are the single source of truth.
- **Save** = serialize these 5 items into a JSON list and write to disk.
- **Undo** = store snapshots of these 5 items into an `UndoCache` after each undoable operation.
- **Camera state** (`cameraX/Y/Z`, `yawAngle`, `pitchAngle`, `globalScale`) drives the Three.js engine via `EvaluateJavascript` calls whenever they change.
- **Gesture mode** (1/2/3) determines how drag events are interpreted:
  - Mode 1 (`gestureMode == 1`): single-finger drag = rotate camera.
  - Mode 2 (`gestureMode == 2`): single-finger drag = pan camera / move drawing cursor.
  - Mode 3 (`gestureMode == 3`): pinch = scale selected object axes; single-finger drag = move selected object.
- The **`cmcUnlock` / `doorknockCallback`** pattern is a simple async-gate: when Three.js is busy, new commands are queued. When it calls back (via `WebViewStringChange`), `cmdUnlock` becomes true and the next queued command is sent.
- The **`valueLabelRegistry`** allows numeric labels in the UI (like `TranslateX`, `RotateZ`) to be linked to callbacks that are automatically called when their value changes. In Flutter, this maps naturally to `TextEditingController` listeners or `ValueNotifier<double>`.
