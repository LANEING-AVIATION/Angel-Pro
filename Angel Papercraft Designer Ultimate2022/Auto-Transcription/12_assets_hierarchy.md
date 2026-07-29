# Flutter Project: Asset Hierarchy Plan

This document maps every asset from the legacy AppInventor projects (A3NG_EN, A3PDF_EN, A3LIV_EN) to a
clean sub-folder structure for the new Flutter project. In App Inventor, **no sub-folders are allowed** inside
the `assets/` directory, so all 20–40 files per project lived at the same level. This plan eliminates that
flat chaos and consolidates the three sub-projects into one Flutter app.

---

## Key Observations Before Restructuring

### Duplicated assets across sub-projects
The following files appear byte-for-byte identical across A3NG_EN, A3LIV_EN and A3PDF_EN — each project
carried its own copy because App Inventor has no shared asset pool. In Flutter there should be **exactly one
copy** of each:

| Asset | Found in |
|---|---|
| `Backpicqualitylow.png` | A3NG_EN · A3LIV_EN · A3PDF_EN |
| `ICONFONTforANGELIII.otf` | A3NG_EN · A3LIV_EN · A3PDF_EN |
| `three.js` | A3NG_EN · A3LIV_EN · A3PDF_EN |
| `three.min.js` | A3NG_EN · A3LIV_EN · A3PDF_EN |
| `OBJLoader.js` | A3NG_EN · A3LIV_EN · A3PDF_EN |
| `OrbitControls.js` | A3NG_EN · A3LIV_EN |
| `SceneUtils.js` | A3NG_EN · A3LIV_EN |
| `stats.min.js` | A3NG_EN · A3LIV_EN |
| `dat.gui.min.js` | A3NG_EN · A3LIV_EN |

### Confirmed unused assets in A3PDF_EN
After searching every `.scm` and `.bky` file across all three projects, these files in A3PDF_EN/assets
are **not referenced anywhere** — they are likely leftovers from earlier development:

| Asset | Status |
|---|---|
| `SCANPIC.PNG` | ❌ Unused — can be archived or deleted |
| `OUTPORT.PNG` | ❌ Unused — can be archived or deleted |
| `FLATLOADNEW.HTML` | ❌ Unused — appears to be a work-in-progress replacement for `flatloader.HTML` that was never wired up |

### HTML viewers and relative path dependency
All HTML viewer files load Three.js with a **relative path** such as `<script src="three.js">`.
If the Flutter asset structure places HTML files and JS libraries in different sub-folders, every
`<script src="...">` reference inside the HTML files must be updated to match the new relative path.
The recommended structure below keeps all web assets together to avoid this problem — see
[Section: Web Assets](#web-assets-three-js-viewers) for details.

---

## Proposed Flutter Asset Directory Structure

```
assets/
│
├── fonts/
│   └── ICONFONTforANGELIII.otf
│       # Legacy icon font mapping Latin letters to vector icons.
│       # Retained for reference during SVG migration.
│       # Do NOT register this font globally in pubspec.yaml — it must only
│       # be applied to specific icon label widgets via TextStyle.fontFamily.
│       # See 11_icon_system_migration.md for the full SVG replacement plan.
│
├── images/
│   │
│   ├── backgrounds/
│   │   ├── background_wallpaper.png      ← Backpicqualitylow.png
│   │   │   # Low-quality blurred Boeing 777X photo used as the decorative
│   │   │   # background for all screens (Screen1, RecentFiles, Workspace,
│   │   │   # UnfoldULT, UnfoldIMG). Displayed full-screen behind all content.
│   │   │   # In AppInventor: BackgroundImage + BackgroundImageBlurRate property.
│   │   │   # In Flutter: use a full-screen Stack with Image.asset() underneath,
│   │   │   # apply BackdropFilter + ImageFilter.blur() on top if needed.
│   │   │
│   │   └── background_an225.png          ← An225.PNG  (A3NG_EN only)
│   │       # Antonov An-225 Mriya photo.
│   │       # Shown as the wallpaper on the RecentFiles screen ONLY on Feb 27
│   │       # (memorial date easter egg — see 02_screen_filemanager.md).
│   │
│   ├── icons/
│   │   │   # NOTE: All PNG icons listed here are candidates for SVG replacement.
│   │   │   # See 11_icon_system_migration.md for the full migration plan.
│   │   │   # The sub-groups below reflect which module uses each icon.
│   │   │
│   │   ├── editor/
│   │   │   ├── ic_new_3d.png             ← NEW3D.PNG
│   │   │   │   # "New 3D file" button on the RecentFiles toolbar
│   │   │   ├── ic_new_folder.png         ← NEWFOLDER.PNG
│   │   │   │   # "New folder" button on the RecentFiles file browser toolbar
│   │   │   ├── ic_folder.png             ← Folder.PNG
│   │   │   │   # Folder entry icon in the RecentFiles file list
│   │   │   ├── ic_undo.png               ← UNDO.PNG
│   │   │   │   # Undo button icon in the Workspace toolbar
│   │   │   ├── ic_paste.png              ← PASTE.PNG
│   │   │   │   # Paste/duplicate button icon in the Workspace toolbar
│   │   │   ├── ic_scissors.png           ← SCISS.PNG
│   │   │   │   # Cut/scissors icon used in Workspace object operations
│   │   │   ├── ic_storage.png            ← STORAGEW.PNG
│   │   │   │   # Cloud/storage icon used in the Workspace file panel
│   │   │   ├── ic_export_obj.png         ← OUTW.PNG
│   │   │   │   # Export/OBJ-out icon in the Workspace options
│   │   │   ├── ic_trash.png              ← TRASH.PNG
│   │   │   │   # Primary delete/trash icon in Workspace
│   │   │   ├── ic_trash_alt.png          ← TRASH2.PNG
│   │   │   │   # Secondary trash icon variant (used for "delete all" or similar)
│   │   │   └── ic_dock.png               ← DOCK.PNG
│   │   │       # Dock/pin icon in the Workspace side panel
│   │   │
│   │   └── pdf/
│   │       ├── ic_pen.png                ← PEN.PNG
│   │       │   # "Restore hidden lines" button in UnfoldULT and UnfoldIMG toolbars.
│   │       │   # Set as Button BackgroundImage. Visible=False by default, shown
│   │       │   # when the user has previously hidden fold lines.
│   │       ├── ic_eye_hide.png           ← EYESHUT.PNG
│   │       │   # "Hide fold lines" button in UnfoldULT and UnfoldIMG toolbars.
│   │       │   # Set as Button BackgroundImage. Toggles line visibility in the
│   │       │   # Three.js flat-unfolded viewer.
│   │       ├── ic_scan_unused.png        ← SCANPIC.PNG  ⚠️ Currently unused
│   │       │   # Scan/document-capture icon. Not referenced in any logic file.
│   │       │   # Retain in assets for potential future "scan reference image" feature.
│   │       └── ic_export_unused.png      ← OUTPORT.PNG  ⚠️ Currently unused
│   │           # Export/share icon. Not referenced in any logic file.
│   │           # Retain for potential future toolbar expansion.
│   │
│   ├── splash/
│   │   ├── angel_logo_pure.png           ← PUREICO.PNG  (A3NG_EN only)
│   │   │   # The Angel III app logo (transparent background).
│   │   │   # Displayed in the center of the Screen1 splash screen.
│   │   │   # Animates in with ViewAnimator; see 01_screen_splash.md.
│   │   └── title_banner.png              ← Title.png  (A3NG_EN only)
│   │       # "Angel III" title banner graphic used on the splash/about panel.
│   │
│   └── ui/
│       └── pdf_cover_frame.png           ← Cover.PNG
│           # A4-landscape page frame with the "Angel III" watermark in the top-right
│           # corner and Chinese copyright text along the right edge.
│           # Used in UnfoldULT as the BackgroundImage of the gesture-pan overlay
│           # layer (component: 手势平移, ZCoord=99, on top of the Three.js canvas).
│           # In Flutter: render as an overlay Image.asset() with fit: BoxFit.fill
│           # on top of the WebView in the PDF export screen.
│           # Image size: 1485 × 1080 px (matches the UnfoldULT preview frame size).
│
└── web/
    │   # All HTML viewer pages and their JavaScript dependencies.
    │   # IMPORTANT: every HTML file uses relative paths such as <script src="three.js">.
    │   # Keep all JS libraries and all HTML files in the SAME flat directory
    │   # (assets/web/) so those relative references continue to work without
    │   # modifying the HTML source. Sub-folders are introduced only for the
    │   # HTML files themselves; the JS files stay at assets/web/ root level.
    │   #
    │   # In Flutter, load these via flutter_inappwebview:
    │   #   InAppWebView(initialUrlRequest: URLRequest(
    │   #     url: WebUri("asset:///assets/web/flatloader.html")))
    │
    ├── three.js                          ← shared (was in all 3 projects)
    │   # Three.js r128 development build. Used by all HTML viewers as the 3D engine.
    │
    ├── three.min.js                      ← shared (was in A3NG_EN + A3LIV_EN)
    │   # Three.js r128 minified build. Used by A3LIV_EN viewers (objloader, objsurface,
    │   # objloaderaim). Can unify with three.js — keep whichever is more recent.
    │   # Recommendation: keep only three.min.js in production and update all src= refs.
    │
    ├── OBJLoader.js                      ← shared (was in all 3 projects)
    │   # Three.js OBJLoader add-on. Parses Wavefront .obj text format into Three.js meshes.
    │   # Used by every HTML viewer that renders 3D content.
    │
    ├── OrbitControls.js                  ← shared (was in A3NG_EN + A3LIV_EN)
    │   # Three.js OrbitControls. Provides mouse/touch camera orbit, pan, zoom.
    │   # Used only by A3LIV_EN extru.html and extru2.html (the extrusion viewers).
    │   # The main editor (A3NG_EN) uses its own custom touch-gesture camera logic —
    │   # NOT OrbitControls.
    │
    ├── SceneUtils.js                     ← shared (was in A3NG_EN + A3LIV_EN)
    │   # Three.js SceneUtils (mergeGeometries). Used only by extru.html / extru2.html.
    │
    ├── stats.min.js                      ← shared (was in A3NG_EN + A3LIV_EN)
    │   # stats.js performance monitor overlay (FPS counter).
    │   # Used only by extru.html / extru2.html — debug tool, not user-facing.
    │   # ⚠️ Consider removing from production builds.
    │
    ├── dat.gui.min.js                    ← shared (was in A3NG_EN + A3LIV_EN)
    │   # dat.GUI tweakpane — debug UI.
    │   # Used only by extru.html / extru2.html — debug tool, not user-facing.
    │   # ⚠️ Consider removing from production builds.
    │
    ├── editor/
    │   │   # WebView pages for the main 3D editor (A3NG_EN Workspace screen)
    │   │
    │   ├── objloaderng.html              ← A3NG_EN/objloaderng.HTML
    │   │   # OBJ preview viewer. Loaded when the user imports an OBJ file into
    │   │   # the Workspace for reference. Communicates back via setWebViewString.
    │   │
    │   ├── objsurface.html               ← A3NG_EN/objsurface.html
    │   │   # Surface/solid viewer. Shows the 3D model with face fill + wireframe.
    │   │   # Used for the main 3D editing canvas (TJS容器 WebViewer).
    │   │
    │   ├── texloaderng.html              ← A3NG_EN/Texloaderng.HTML
    │   │   # Textured OBJ viewer. Used for the material/texture preview panel
    │   │   # (预览窗口 WebViewer) in the Workspace.
    │   │
    │   ├── flatloader.html               ← A3NG_EN/flatloader.HTML
    │   │   # Flat/unfolded net viewer for the editor's internal preview.
    │   │   # Fixed canvas size: 2970 × 2100 px (A3 paper at the editor's scale).
    │   │   # Uses three.js + OBJLoader. Sends rendered frames back via setWebViewString.
    │   │
    │   └── imageloader.html              ← A3NG_EN/imageloader.html
    │       # Loads a raster image into a Three.js plane for reference-image overlay
    │       # in the Workspace drawing mode (see 08_workspace_drawing_mode.md).
    │
    ├── pdf/
    │   │   # WebView pages for the PDF/image export screen (A3PDF_EN)
    │   │
    │   ├── flatloader.html               ← A3PDF_EN/flatloader.HTML
    │   │   # Flat unfolded-net viewer for PDF page layout.
    │   │   # Fixed canvas: 2970 × 2100 px (A4 landscape at 3.1× scale, matching
    │   │   # the UnfoldULT preview frame dimensions 1485 × 1080 which is exactly half).
    │   │   # Both UnfoldULT.bky and UnfoldIMG.bky load this page into TJS容器.
    │   │
    │   ├── flatpure.html                 ← A3PDF_EN/flatpure.HTML
    │   │   # Pure flat viewer (no texture, wireframe/fold-lines only).
    │   │   # Loaded when the user hides material colours to see only the net structure.
    │   │   # Used by both UnfoldULT.bky and UnfoldIMG.bky.
    │   │
    │   ├── flatloadnew.html              ← A3PDF_EN/FLATLOADNEW.HTML  ⚠️ Currently unused
    │   │   # Appears to be a refactored replacement for flatloader.html with
    │   │   # dynamic window size (uses window.innerWidth/Height instead of hardcoded
    │   │   # 2970 × 2100). Not yet wired up in any BKY logic. Keep for future use.
    │   │
    │   └── texloaderng.html              ← A3PDF_EN/Texloaderng.HTML
    │       # Textured OBJ viewer for the PDF module. Functionally similar to the
    │       # editor version but may have PDF-specific adjustments.
    │       # ⚠️ Compare with assets/web/editor/texloaderng.html — if identical,
    │       # remove this copy and share the one under assets/web/editor/.
    │
    └── livery/
        │   # WebView pages for the livery/paint editor (A3LIV_EN)
        │
        ├── objloaderng.html              ← A3LIV_EN/objloaderng.HTML
        ├── objloaderaim.html             ← A3LIV_EN/objloaderaim.html
        ├── objloader.html                ← A3LIV_EN/objloader.html
        ├── objsurface.html               ← A3LIV_EN/objsurface.html
        ├── texloaderng.html              ← A3LIV_EN/Texloaderng.HTML
        ├── extru2.html                   ← A3LIV_EN/extru2.html
        │   # Extrusion preview viewer v2 (uses SceneUtils, OrbitControls, stats, dat.gui).
        └── extru.html                    ← A3LIV_EN/extru.html
            # Extrusion preview viewer v1 (legacy; extru2 is the active version).
            # ⚠️ Verify whether extru.html is still needed or can be deleted.
```

---

## pubspec.yaml Declaration

```yaml
flutter:
  assets:
    # Images
    - assets/images/backgrounds/
    - assets/images/icons/editor/
    - assets/images/icons/pdf/
    - assets/images/splash/
    - assets/images/ui/

    # Fonts (legacy icon font — see 11_icon_system_migration.md)
    # Register as a named font family so it can be applied selectively
    # Do NOT set it as the app default font

    # Web viewer pages
    - assets/web/
    - assets/web/editor/
    - assets/web/pdf/
    - assets/web/livery/

  fonts:
    - family: AngelIcons
      fonts:
        - asset: assets/fonts/ICONFONTforANGELIII.otf
```

> **Note on JS files**: App Inventor embeds JS files as regular assets loaded by relative URL from
> HTML. In Flutter / `flutter_inappwebview`, local asset HTML files can reference sibling assets using
> relative URLs like `./three.js` as long as the `InAppWebView` is configured with
> `allowFileAccessFromFileURLs: true` and the assets are declared in pubspec.yaml.
> All JS and HTML files should be declared under `assets/web/` (a directory declaration covers all files
> in that directory but NOT sub-directories — each sub-directory must be listed separately).

---

## Important: HTML `<script src="">` Path Updates Required

Every HTML viewer currently uses bare relative paths assuming a flat folder. After moving the HTML files
to sub-directories while keeping JS at `assets/web/`, the `src` attributes need updating:

| Current `src` in HTML | New `src` (relative from `assets/web/editor/` or `pdf/` or `livery/`) |
|---|---|
| `src="three.js"` | `src="../three.js"` |
| `src="OBJLoader.js"` | `src="../OBJLoader.js"` |
| `src="OrbitControls.js"` | `src="../OrbitControls.js"` |
| `src="SceneUtils.js"` | `src="../SceneUtils.js"` |
| `src="stats.min.js"` | `src="../stats.min.js"` |
| `src="dat.gui.min.js"` | `src="../dat.gui.min.js"` |

Alternatively, keep everything in a single flat `assets/web/` directory (no sub-folders) to avoid
all path changes — trade-off is a less organized directory listing.

---

## Asset-by-Asset Migration Reference (A3PDF_EN Focus)

This table covers every file currently in `A3PDF_EN/assets/` (the folder the user highlighted):

| Original file | Description | Used in | New Flutter path | Notes |
|---|---|---|---|---|
| `Backpicqualitylow.png` | Background wallpaper (Boeing 777X) | All screens, all 3 projects | `assets/images/backgrounds/background_wallpaper.png` | Single shared copy; was duplicated in every project |
| `Cover.PNG` | A4 page frame with Angel III watermark | A3PDF_EN / UnfoldULT.scm (overlay layer `手势平移`) | `assets/images/ui/pdf_cover_frame.png` | Positioned absolute at ZCoord=99 over the WebView canvas in PDF export screen |
| `PEN.PNG` | Pen / restore-lines icon | A3PDF_EN / UnfoldULT.scm + UnfoldIMG.scm (button `按钮_恢复线条`) | `assets/images/icons/pdf/ic_pen.png` | Replace with SVG `ic_restore_lines.svg` in Flutter |
| `EYESHUT.PNG` | Eye-shut / hide-lines icon | A3PDF_EN / UnfoldULT.scm + UnfoldIMG.scm (button `按钮_去除线条`) | `assets/images/icons/pdf/ic_eye_hide.png` | Replace with SVG `ic_hide_lines.svg` in Flutter |
| `pdficon.png` | App launcher icon for A3PDF_EN | A3PDF_EN / Screen1.scm (form Icon property) | `assets/images/splash/app_icon_pdf.png` | Used as the Android app icon; in Flutter use `flutter_launcher_icons` package instead |
| `SCANPIC.PNG` | Scan/capture icon | **Not found in any file** | `assets/images/icons/pdf/ic_scan_unused.png` | Unused; retain as archived asset |
| `OUTPORT.PNG` | Export/output icon | **Not found in any file** | `assets/images/icons/pdf/ic_export_unused.png` | Unused; retain as archived asset |
| `flatloader.HTML` | Flat net viewer (fixed 2970×2100) | A3PDF_EN / UnfoldULT.bky + UnfoldIMG.bky | `assets/web/pdf/flatloader.html` | Used for both PDF and image export; update `src="three.js"` → `src="../three.js"` |
| `flatpure.HTML` | Pure flat viewer (no texture) | A3PDF_EN / UnfoldULT.bky + UnfoldIMG.bky | `assets/web/pdf/flatpure.html` | Used when user hides material colours |
| `FLATLOADNEW.HTML` | Newer flat viewer (dynamic size) | **Not referenced in any BKY** | `assets/web/pdf/flatloadnew.html` | Currently unused; candidate for replacing `flatloader.html` once wired up |
| `Texloaderng.HTML` | Textured OBJ viewer | Used by A3LIV_EN/Texture.bky (not A3PDF_EN BKY) | `assets/web/pdf/texloaderng.html` | Compare with editor version; consolidate if identical |
| `three.js` | Three.js dev build | All HTML viewers | `assets/web/three.js` | Single shared copy |
| `three.min.js` | Three.js minified build | A3LIV_EN HTML viewers | `assets/web/three.min.js` | Consider unifying to one version |
| `OBJLoader.js` | Three.js OBJ loader | All HTML viewers | `assets/web/OBJLoader.js` | Single shared copy |
| `OrbitControls.js` | Camera orbit controls | A3LIV_EN extru.html only | `assets/web/OrbitControls.js` | Only needed for livery extrusion viewer |
| `SceneUtils.js` | Scene merge utilities | A3LIV_EN extru.html only | `assets/web/SceneUtils.js` | Only needed for livery extrusion viewer |
| `stats.min.js` | FPS performance overlay | A3LIV_EN extru.html only | `assets/web/stats.min.js` | Debug tool — consider omitting in production |
| `dat.gui.min.js` | Debug GUI tweakpane | A3LIV_EN extru.html only | `assets/web/dat.gui.min.js` | Debug tool — consider omitting in production |
| `ICONFONTforANGELIII.otf` | Custom icon font | A3NG_EN/Workspace.bky + A3LIV_EN/Texture.bky | `assets/fonts/ICONFONTforANGELIII.otf` | Legacy; to be replaced by SVG icons. See `11_icon_system_migration.md` |
| `external_comps/com.KIO4_Pdf/` | KIO4 PDF generator extension | A3PDF_EN Screens (KIO4_Pdf1 component) | N/A | Replace with a Dart PDF library such as `pdf` + `printing` packages |
