# Angel Ⅲ Papercraft Designer Ultimate — Project Overview

## What Is This App?

**Angel Ⅲ Papercraft Designer Ultimate** (internal codename: A3NG_EN) is an Android 3D papercraft design tool. It enables users to:

- Browse and manage `.SPA` (This app was formly named SPACEDESK) project files stored on the device.
- Open a project and edit a 3D mesh inside a real-time Three.js viewport.
- Draw wireframe outlines (new edges/points) in orthographic views.
- Apply transform operations (move, rotate, scale) to geometry.
- Loft surfaces between edges, group objects, and apply livery textures.
- Export models and share them.

The app was built with **MIT App Inventor** (WxBit flavour) and uses several custom Android extensions. It is landscape-only.

---

## Screen Structure

There are three AppInventor screens, each mapping to a distinct Flutter route/page:

| Screen Name     | Flutter Route Suggestion | Role                                                          |
|-----------------|--------------------------|---------------------------------------------------------------|
| `Screen1`       | `/splash`                | Splash / Welcome screen; navigates to RecentFiles or Workspace |
| `RecentFiles`   | `/files`                 | File manager: browse, create, delete, rename `.SPA` projects  |
| `Workspace`     | `/workspace`             | Main 3D editor                                               |

---

## Additional Companion Apps (split by AppInventor limits)

The original Angel III ecosystem also contains two additional AppInventor projects that were kept separate because a single activity/screen could not hold all modeling + livery + unfold logic within AppInventor complexity limits:

| App | Role | Notes |
|---|---|---|
| `A3LIV_EN` | Livery editor | Defines aircraft texture/livery data on top of 3D geometry |
| `A3PDF_EN` | Unfold/PDF exporter | Converts 3D papercraft geometry into unfolded A4 PDF/image outputs |

See the dedicated transcription files:

- `13_a3liv_overview.md`
- `14_a3liv_texture_editor.md`
- `15_a3liv_auxiliary_screens.md`
- `16_a3pdf_overview.md`
- `17_a3pdf_unfold_pdf.md`
- `18_a3pdf_unfold_image.md`
- `19_appinventor_property_encoding_quirks.md`
- `20_special_correction_notes.md`

---

## Technology Stack (Original)

| Component              | Original                                      | Flutter Equivalent                          |
|------------------------|-----------------------------------------------|---------------------------------------------|
| UI framework           | MIT App Inventor (WxBit)                      | Flutter widgets                             |
| 3D rendering           | Three.js loaded inside a WebViewer            | `flutter_inappwebview` + Three.js HTML page |
| File I/O               | `File` component (Android filesystem)         | `path_provider` + `dart:io`                 |
| Local persistence      | `TinyDB` (multiple namespaces)                | `shared_preferences` / `hive`               |
| Layout animations      | `ViewAnimator` (KevinKun extension)           | Flutter `AnimatedContainer` / `Hero`        |
| UI theming             | `KevinkunEnhance` (rounded corners, shadows)  | Flutter `BoxDecoration`, `Theme`            |
| Networking             | `Web` (HTTP client)                           | `http` package                              |
| Audio                  | `Player` component                            | `just_audio` package                        |
| Share / export         | `Sharing` + `ActivityStarter`                 | `share_plus` package                        |
| Dialogs / alerts       | `Notifier`                                    | `showDialog` / `AlertDialog`                |
| Flex layout            | `Flexbox` extension                           | Flutter `Wrap` / `Flex`                     |

---

## File Format

Project files are stored as plain-text JSON in the device filesystem under:

```
/storage/emulated/0/SPACEDESK/
```

Each project is a directory (subfolder) named by the user. Inside is:
- A file ending in `.SPA` (extension stands for **SPACEDESK** — the app's original name) containing the serialised 3D model data (JSON list structure).
- A thumbnail screenshot ending in `.png` (keyed by a sanitised path like `storageemulated0...`).

The data structure stored per file is a JSON list with at least 5 indexed elements:
1. `[1]` — Title/metadata segment (`标题段`)
2. `[2]` — Edge list (`边缘列表`)
3. `[3]` — (reserved / unused slot observed in undo stack)
4. `[4]` — Image/texture list (`图片列表`)
5. `[5]` — Loft collection (`放样集合`)

---

## Navigation Flow

```
App Launch
    └── Screen1 (Splash)
            ├── [SPACEDESK/manifest.txt exists?]
            │       YES → read manifest → open Workspace with file path as start value
            │       NO  → start value == "about"? → show About panel + play music
            │                                  else → open RecentFiles
            └── [按钮_资料库 / "Recent Files" button]
                        └── open RecentFiles

RecentFiles
    └── tap file item → open Workspace (pass file path as screen start value)
    └── 按钮_新建 (New) → create new .SPA file → open Workspace

Workspace
    └── 按钮_Files / 关闭文件 → save → go back to RecentFiles
    └── 程序坞 (Dock) / 导出 (Export) → save → share
```

---

## Key Third-Party / Custom Extensions Used

| Extension                  | Purpose                                                               |
|----------------------------|-----------------------------------------------------------------------|
| `KevinkunEnhance`          | SetBackground (rounded corners, shadows), SetMargin, SetElevation     |
| `ViewAnimator`             | Animate View (scale, alpha, position, duration) — used for all UI transitions |
| `SplashSetting`            | Configure splash screen duration                                      |
| `Flexbox`                  | Flexible grid layout for import/texture thumbnail strip               |
| `FilePicker`               | Native file chooser, default dir `/storage/emulated/0/SPACEDESK/`    |
| `AbsoluteArrangement`      | Free-position layout used for the main viewport and overlay panels    |

---

## App Identity

- **App Name**: Angel Ⅲ  
- **Developer**: LANEING (LANEING Aviation / 兰鹰航空)  
- **Location**: Chongqing City, China  
- **Package**: `wxbit.AngelFile.test`  
- **Accent / Primary color**: `#54739B` (steel blue)  
- **Orientation**: Landscape only  
- **Status bar**: Hidden  
- **Title bar**: Hidden  
