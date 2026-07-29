# Workspace: File Operations (Open, Save, Undo, Export)

**Screen**: Workspace  
This document covers all file I/O and project lifecycle operations.

> **Special correction note**: extension and file-detection misunderstandings were corrected during transcription. Please check `20_special_correction_notes.md` before implementing parser/loader logic.

---

## File Format

Projects are stored as **plain-text JSON** with the extension `.SPA` . Example path:
```
/storage/emulated/0/SPACEDESK/MyProject/airplane.SPA
```

The JSON is a list of 5 elements:
```json
[
  titleSegment,       // [1] metadata (string or dict)
  edgeList,           // [2] list of edge objects
  null,               // [3] (reserved / padding index)
  imageList,          // [4] list of texture definitions
  loftCollection      // [5] list of loft surface definitions
]
```

Each **edge** in `edgeList` is a dict with (at minimum):
- `"name"` — display name
- `"points"` — list of 3D point coordinates `[[x,y,z], ...]`
- `"layer"` — layer/group index

Each **loft surface** in `loftCollection` is a dict with:
- `"edges"` — list of edge indices that define the surface boundary
- `"name"` — display name
- `"group"` — group assignment index

Each **image** in `imageList` is a dict with:
- `"base64"` — base64-encoded image data (or a file path reference)
- `"uvCoords"` — UV mapping coordinate list

---

## Loading a Project

### Trigger

Initiated by `扫描触发初始化.Timer` (InitTriggerClock) shortly after `Workspace.Initialize`.

### `赋值()` / assignData()

1. Call `加速()` — applies any pending accelerator setting.
2. Call `FileManager.ReadTextCallback(filePath, callback)` — read the `.SPA` file from disk.
3. In the callback:
   - Parse the JSON text into a list.
   - Populate globals:
     - `titleSegment` = list[1]
     - `edgeList` = list[2]
     - `imageList` = list[4]
     - `loftCollection` = list[5]
     - `objDictionary` = (the full parsed structure)

### `读取文件()` / loadFile()

Called after `赋值()` completes. Performs the full UI initialisation:

1. `赋值()` — load file data into globals.
2. Build top-menu manager buttons.
3. `重置变换参数()` — reset all transform fields.
4. Load preview webview URLs.
5. `界面初始化()` — build all UI controls.
6. Build Items tab-bar.
7. Re-register all value-label watchers.
8. Set viewport scale from persisted setting.
9. Build import thumbnail strip from `截图地址库` TinyDB.

### `扫描触发加载序列.Timer` (LoadSequenceClock)

A timer-based state machine that drives loading in stages:
- Feeds the 3D geometry data to Three.js in chunks.
- Updates the "Loading" progress indicator.
- Dismisses the progress dialog when loading is complete.
- Sets `CMDunlock = true` once Three.js signals readiness.

---

## Saving a Project

### `保存(callback)` / save(callback)

```
if needsSave == true:
    ShowProgressDialog("Saving", "Saving")
    [delayed 300ms]
    serialise [titleSegment, edgeList, null, imageList, loftCollection] as JSON text
    FileManager.SaveTextCallback(jsonText, filePath, doneCallback)
    in doneCallback:
        needsSave = false
        DismissProgressDialog()
        execute callback
else:
    execute callback immediately
```

### When is `needsSave` set to true?

Any operation that modifies geometry sets `needsSave = true` and makes the save button visible:
- Adding/removing an edge.
- Applying a transform.
- Lofting a surface.
- Grouping objects.
- Assigning a texture.

### Save button (`按钮_保存`) visibility

- Hidden by default (shown only when `needsSave = true`).
- Clicking it calls `保存(callback)`.
- After saving, the button is hidden again.

---

## Undo System

### Storage

The undo history is stored in `大容量缓存` (UndoCache, TinyDB). Each snapshot is a JSON list identical to the save format:
```json
[titleSegment, edgeList, null, imageList, loftCollection]
```

Multiple snapshots are stored together as a list of snapshots, keyed by `操作戳序号` (operationStampIndex).

### `打下操作戳()` / stampOperation()

Called after every undoable action. Saves the current state as a snapshot:
1. Increment `operationStampIndex`.
2. Store current state snapshot at index `operationStampIndex`.
3. Store `operationStampIndex` in `Cache` DB.
4. Set `needsSave = true`.
5. Show save button.

### `按钮_撤销.Click` / UndoButton tap

```
load undo history from UndoCache
if history is not empty:
    needsSave = false
    operationStampIndex -= 1
    restore state from history[operationStampIndex]
    call 结构刷新()   // refresh items panel
    call TJS大世界自动刷新()  // refresh 3D view
    hide UndoButton   // undo button hides after use (only one level of undo shown)
```

> **Note**: The undo system appears to support multiple levels (stack pointer system), but the UndoButton is hidden after one undo in the observed logic. Flutter implementation should track this behaviour and re-show the button for each available undo level.

---

## Export

### `导出.Click` / ExportButton tap

```
call 保存(callback):
    // On save complete:
    share the saved .SPA file via the native share dialog
    (using 信息分享器1 / SharingHelper)
```

### `程序坞.Click` / DockButton tap

```
call 保存(callback):
    // On save complete:
    open the saved .SPA file in an external app
    (using 活动启动器1 / ActivityStarter with ACTION_VIEW)
```

---

## Closing a Project

### `关闭文件()` / closeFile()

```
call 保存(callback):
    // On save complete:
    navigate back to RecentFiles screen
```

### `按钮_Files.Click` / FilesButton tap

Same as `关闭文件()`.

### `Workspace.BackPressed`

Does **not** immediately close the file. Instead:
- Checks time since last back-press (protects against accidental back).
- If pressed twice within 2 seconds: shows a warning dialog ("Make sure all background processes have finished").
- The user must dismiss loading dialogs manually before navigating away.

---

## Manifest File (`manifest.txt`)

Located at `/storage/emulated/0/SPACEDESK/manifest.txt`.

- Written by the **RecentFiles** screen when a project is opened (via `启动应用()` which creates `lock.txt`).
- Read by **Screen1** on startup; if present, the Workspace screen is opened immediately with the path as start value.
- Also checked by **RecentFiles.Initialize**: if present, it redirects to Workspace (prevents re-entering file manager mid-session).
- Deleted / cleared by the Workspace screen when the project is closed.

> **Flutter equivalent**: Use a `SharedPreferences` key `"last_opened_project"` to store the most recently opened file path. On app launch, check this key and navigate accordingly.

---

## Flutter Implementation Notes

- Use `dart:io` `File.readAsString()` and `File.writeAsString()` for all file I/O.
- **`.SPA` file detection**: The extension name comes from the app's original name **SPACEDESK** (first 3 letters). In the original AppInventor code, `.SPA` files are detected by **reversing the filename string** and checking if the reversed result starts with `"APS."` (since AppInventor has no native `endsWith`). In Flutter, use `path.endsWith('.SPA')` — do **not** use `contains`, as that would match false positives inside directory names.
- The undo system can be implemented with a simple `List<ProjectSnapshot>` and a `currentIndex` pointer. Each undoable action pushes a snapshot. `undo()` decrements the index and restores the snapshot.
- On save, also store the current viewport scale and background image to a sidecar preferences entry so they are restored on next open.
- **Loading sequence**: The original app uses a Clock-timer state machine to feed data to Three.js in steps. In Flutter with `flutter_inappwebview`, use `Future.delayed` between `evaluateJavascript` calls, or wait for each call's Future to complete before sending the next chunk.
- The **progress dialog** ("Saving" / "Loading") should block user interaction. Use `showDialog` with `barrierDismissible: false` and a `CircularProgressIndicator`.
