# A3LIV_EN: Auxiliary / Prototype Screens

This file covers all A3LIV_EN screens except `Texture` (the production livery editor).

---

## Reachability status summary

In the current exported project, these screens have no incoming `openAnotherScreen` references and are therefore not launched by the normal user path:

- `Screen2`
- `PERSCAM`
- `Screen3`
- `miniimg`
- `coderANG`
- `codeboard`
- `fitsrr`

`Screen1` itself is the entry screen, but it contains a timer-based auto-redirect to `Texture`, so many controls on `Screen1` are effectively test leftovers.

---

## 1) `Screen1` (legacy launcher + prototype viewer)

**Suggested route**: `/livery/entry`

### UI highlights

- One WebViewer (`网页浏览框1`)
- Many debug sliders (`x`, `y`, `z`, `上下`, `左右`, `旋转`, `俯仰角`, `圆盘角`)
- Hidden/debug buttons (`按钮_先加载材质`, `按钮2`, `按钮3`)
- `按钮4` (navigates into `Texture`)

### Main logic

- `Screen1.Initialize`:
  - Loads multiple demo OBJ assets (plane axis objects + `banana.obj`)
  - Loads `//objloaderng.HTML`
  - Calls local conversion pipeline (`W64SPA转OBJ`, `加载OBJ文件`, `加载OBJ文本`)
- `按钮4.Click` and `计时器1.Timer` open screen `Texture`.
- Camera sliders drive JS variables via `EvaluateJavascript`.

> Reachability note: `计时器1.Timer` uses an unconditional `controls_openAnotherScreen(Texture)` (no `controls_if` guard), so this screen behaves mostly as a short-lived bootstrap shell.

### Name mapping

| Original | Suggested |
|---|---|
| `网页浏览框1` | `threeJsEntryWebView` |
| `按钮_运行html` | `runHtmlButton` |
| `按钮_capture` | `captureButton` |
| `按钮4` | `openTextureEditorButton` |
| `俯仰角` | `pitchSlider` |
| `圆盘角` | `yawSlider` |

---

## 2) `Screen2` (OBJ loader test)

**Suggested route**: `/livery/test-loader`

### Behavior

- `按钮_加载obj.Click` loads `//objloaderaim.html`
- `按钮1.Click` loads `//tinker.obj` through `加载OBJ文件`
- Minimal camera sliders send direct JS updates

> Reachability note: no screen opens `Screen2` in current BKY navigation graph.

### Name mapping

| Original | Suggested |
|---|---|
| `网页浏览框1` | `threeJsObjTestWebView` |
| `按钮_加载obj` | `loadObjViewerButton` |
| `按钮1` | `loadTinkerObjButton` |

---

## 3) `PERSCAM` (camera calibration playground)

**Suggested route**: `/livery/test-camera`

### Behavior

- `PERSCAM.Initialize` loads:
  - `//objsurface.html`
  - `//objloaderng.html` (in secondary WebViewer `模拟`)
- `按钮1.Click` loads `//CUBE.obj`
- Multiple sliders update both WebViewers simultaneously via JS

> Reachability note: no screen opens `PERSCAM` in current BKY navigation graph.

### Name mapping

| Original | Suggested |
|---|---|
| `网页浏览框1` | `primaryCameraWebView` |
| `模拟` | `secondaryCameraWebView` |
| `按钮1` | `loadCubeButton` |

---

## 4) `miniimg` (mini preview helper)

**Suggested route**: `/livery/mini-preview`

- Contains `网页浏览框1`, `文件管理器1`, `缓存`
- `miniimg.Initialize` calls `网页浏览框1.GoToUrl(...)`
- Likely used as a lightweight utility for preview/caching operations

> Reachability note: no screen opens `miniimg` in current BKY navigation graph.

---

## 5) `coderANG` (UV / control prototype)

**Suggested route**: `/livery/uv-proto`

### Characteristics

- Contains `表面点操控器` + draggable `摇杆`
- Globals: `放样集合`, `灵敏度64`, `选中的放样索引`
- Procedures: `uvxy更改后`, `新轮廓预览`, `单项注册`
- Suggests an early UV or control-point editor prototype

> Reachability note: no screen opens `coderANG` in current BKY navigation graph.

### Name mapping

| Original | Suggested |
|---|---|
| `表面点操控器` | `surfacePointController` |
| `摇杆` | `virtualJoystick` |
| `灵敏度64` | `sensitivity64` |

---

## 6) `codeboard` (geometry algorithm lab)

**Suggested route**: `/livery/geometry-lab`

No events; pure procedure/function container.

Important computational routines include:

- `布尔运算` (boolean ops)
- `显示外切立方体`
- `居中`
- Vector/plane/intersection helpers (`求法向量`, `求相交向量`, `点是否属于三角形`, etc.)

This acts as a reusable math workbench rather than a user-facing page.

> Reachability note: no screen opens `codeboard` in current BKY navigation graph.

---

## 7) `fitsrr` (Flexbox extension test)

**Suggested route**: `/livery/flexbox-test`

- Very small screen used to test dynamic component creation with `Flexbox1`
- `fitsrr.Initialize` calls `Flexbox1.FlewGrow` and runtime component creation

> Reachability note: no screen opens `fitsrr` in current BKY navigation graph.

---

## 8) `Screen3` (audio/network test)

**Suggested route**: `/livery/audio-test`

- `Screen3.Initialize` -> `HTTP客户端1.MethodGet`
- `HTTP客户端1.GotText` -> `音频播放器1.Start`

Appears to be a simple endpoint/audio connectivity test.

> Reachability note: no screen opens `Screen3` in current BKY navigation graph.

---

## Engineering recommendation for Flutter

For production rewrite, keep:

1. `Texture` as the main livery editor page.
2. A minimal launcher route (optional).

Treat all other screens as:

- legacy experiments,
- debugging tools,
- or optional developer-only pages behind a debug flag.
