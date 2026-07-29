# App Module: A3LIV_EN (Livery Editor) — Overview

**Original App ID**: `A3LIV_EN`  
**Role in legacy architecture**: separate app for aircraft skin/livery authoring  
**Why separate from Workspace**: AppInventor screen/activity complexity limits (component count + block size + runtime memory)

> **Special correction note**: reachability and entry-screen leftover logic were corrected after deeper BKY graph tracing. See `20_special_correction_notes.md`.

---

## Purpose

`A3LIV_EN` is the texture/livery companion app for Angel III.  
It is responsible for:

1. Opening the geometry model from the shared SPACEDESK workspace path.
2. Rendering the model in a WebViewer (Three.js).
3. Assigning images to material slots / texture boxes (`X`, `Y`, `Z` faces).
4. Exporting texture-related data back to shared storage.

This app is not a replacement for the main modeling app (`A3NG_EN`), but an attached workflow step.

---

## Screen Inventory (A3LIV_EN)

| Screen | Suggested Flutter route | Role classification |
|---|---|---|
| `Screen1` | `/livery/entry` | Legacy launcher + test harness |
| `Texture` | `/livery/editor` | **Main production livery editor** |
| `Screen2` | `/livery/test-loader` | OBJ loader test harness |
| `PERSCAM` | `/livery/test-camera` | Camera control test harness |
| `Screen3` | `/livery/audio-test` | HTTP audio test screen |
| `miniimg` | `/livery/mini-preview` | Minimal WebViewer helper |
| `coderANG` | `/livery/uv-proto` | UV manipulation prototype |
| `codeboard` | `/livery/geometry-lab` | Geometry algorithm lab |
| `fitsrr` | `/livery/flexbox-test` | UI extension test screen |

> The core business logic is concentrated in `Texture.scm/.bky`.  
> Other screens are mostly experiments, helpers, or intermediate tooling.

---

## Runtime Entry and Navigation

### Primary navigation observed

- `Screen1.Initialize` loads an initial OBJ viewer and geometry payload.
- `Screen1.按钮4.Click` opens `Texture`.
- `Screen1.计时器1.Timer` also opens `Texture` (auto-forward path).

So the practical production path is:

```text
Screen1  ->  Texture
```

### Reachability audit (important for Flutter scope)

From BKY navigation blocks, only one production transition exists:

- `Screen1` -> `Texture` (via `按钮4.Click` and `计时器1.Timer`)

Screens with **zero incoming navigation** in A3LIV_EN:

- `PERSCAM`
- `Screen2`
- `Screen3`
- `codeboard`
- `coderANG`
- `fitsrr`
- `miniimg`

Interpretation:

1. These are retained prototype/test/developer screens.
2. They are not part of the normal user flow.
3. Any useful logic in them should be selectively migrated as helper functions, not as end-user pages.

Also note: `Screen1.计时器1.Timer` opens `Texture` **without condition** (`controls_if` not present in the event block), so entry-screen controls are mostly legacy leftovers unless the user acts before timer redirect.

### Shared file handoff pattern

Like the main app, A3LIV_EN uses the shared folder:

```text
/storage/emulated/0/SPACEDESK/
```

Important control files:

- `filelink.txt` (which project/path to operate on)
- `lock.txt` (session lock/guard)

---

## Logic Size Snapshot

| BKY file | Globals | Events | Procedures | Functions |
|---|---:|---:|---:|---:|
| `Texture.bky` | 35 | 34 | 19 | 2 |
| `Screen1.bky` | 0 | 14 | 4 | 3 |
| `PERSCAM.bky` | 0 | 3 | 3 | 2 |
| `Screen2.bky` | 0 | 3 | 1 | 0 |
| `codeboard.bky` | 0 | 0 | 4 | 9 |
| `coderANG.bky` | 3 | 1 | 4 | 1 |
| `miniimg.bky` | 1 | 2 | 2 | 0 |
| `Screen3.bky` | 0 | 2 | 0 | 0 |
| `fitsrr.bky` | 0 | 1 | 0 | 0 |

---

## Three.js / WebViewer assets used by A3LIV_EN

Main viewer pages found in logic:

- `//Texloaderng.HTML` (main texture editor page)
- `//objloaderng.HTML`
- `//objloader.html`
- `//objloaderaim.html`
- `//objsurface.html`

OBJ test payloads referenced directly:

- `//banana.obj`
- `//tinker.obj`
- `//CUBE.obj`
- `//PlaneXUP.obj`, `//PlaneXDOWN.obj`, `//PlaneYUP.obj`, `//PlaneYDOWN.obj`, `//PlaneZUP.obj`, `//PlaneZDOWN.obj`

---

## Name mapping strategy (for Flutter rewrite)

Many component and variable names are Chinese or temporary/debug style names.  
For implementation, preserve source names in migration notes but map to clear English identifiers:

- `Texture` -> `LiveryEditorPage`
- `图像盒列表` -> `textureBoxList`
- `图像盒大览` -> `texturePreviewCanvas`
- `TJS容器` -> `threeJsTextureWebView`
- `扫描触发加载序列` -> `loadSequenceClock`

Detailed mappings are in:

- `14_a3liv_texture_editor.md` (main screen)
- `15_a3liv_auxiliary_screens.md` (non-core screens)

---

## Relationship with other modules

- Geometry model format remains `.SPA` (same structure described in `07_workspace_file_operations.md`).
- Icon-font behavior and migration constraints are shared with Workspace (`11_icon_system_migration.md`).
- Asset placement strategy for Flutter is in `12_assets_hierarchy.md`.
