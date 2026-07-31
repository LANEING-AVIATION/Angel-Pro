# Screen: File Manager (RecentFiles)

**Original name**: `RecentFiles`  
**Suggested Flutter route**: `/files`  
**Orientation**: Landscape  
**Background**: Blurred wallpaper (`Backpicqualitylow.png`). Live blur is sampled from the file-view area on a 30 ms timer.

> **Icon system note**: Toolbar buttons use the custom icon font `ICONFONTforANGELIII.otf` with Latin letter codes (B, L, Y, K, J, V). See [11_icon_system_migration.md](./11_icon_system_migration.md) for the migration plan.

---

## UI Component Tree

```
RecentFiles (Form)
└── 界面动画之母 / AnimationRoot  [AbsoluteArrangement — fills screen]
    │
    ├── 水平布局4 / BrandingRow   [HorizontalArrangement — off-screen at x=-1000, z=-9999999]
    │   └── 标签_兰鹰航空产品 / BrandLabel  [Label — "兰鹰航空产品" — semi-transparent, bold]
    │
    ├── 命名和新建 / NamingDialog  [VerticalArrangement — HIDDEN — center overlay, z=999]
    │   ├── 文件操作对象 / FileOpIcon   [Image — 200×200 — icon of the target file/folder]
    │   ├── 水平布局3 / Spacer          [HorizontalArrangement — h=30 spacer]
    │   └── 水平布局2 / NameInputRow    [HorizontalArrangement — w=250, h=50]
    │       └── 文本输入框1 / NameInput  [TextBox — hint "名称/Name" — white text, 20pt]
    │
    └── 层叠布局1 / MainStack  [AbsoluteArrangement — z=9]
        │
        ├── 顶bar / TopBar  [HorizontalArrangement — h=70, semi-transparent black, z=99]
        │   ├── 水平布局1 / LeftSpacer        [HorizontalArrangement — w=15 — HIDDEN]
        │   ├── 标题 / TitleImage              [Image — Title.png — 180×65]
        │   ├── 标签_请稍候 / LoadingLabel     [Label — "请稍候/Please wait" — HIDDEN]
        │   └── 顶端工具栏 / TopToolbar        [HorizontalArrangement — right-aligned, h=50]
        │       ├── 针对性菜单 / ContextMenu   [HorizontalScrollArrangement — HIDDEN — shows when item selected]
        │       │   ├── 按钮_程序坞 / DockBtn  [Button — 40×40 — DOCK.PNG  — "Send to Dock"]
        │       │   ├── 按钮_共享 / ShareBtn   [Button — 40×40 — OUTW.PNG  — "Share"]
        │       │   ├── 按钮_剪切 / CutBtn     [Button — 40×40 — SCISS.PNG — "Cut"]
        │       │   ├── 按钮_复制 / CopyBtn    [Button — 40×40 — PASTE.PNG — "Copy"]
        │       │   ├── 按钮_删除 / DeleteBtn  [Button — 40×40 — TRASH.PNG — "Delete"]
        │       │   └── 按钮_确认 / ConfirmBtn [Button — 40×40 — TRASH2.PNG — "Confirm Delete" — HIDDEN]
        │       ├── 按钮_粘贴 / PasteBtn       [Button — 40×40 — PASTE.PNG — HIDDEN — shows after cut/copy]
        │       ├── 按钮_新建文件夹 / NewFolderBtn  [Button — 40×40 — NEWFOLDER.PNG]
        │       └── 按钮_新建 / NewFileBtn         [Button — 40×40 — NEW3D.PNG]
        │
        ├── 垂直布局3 / BackgroundLayer  [VerticalArrangement — z=97, full width/height]
        │   └── 你找不到我的 / BlurSample  [Image — fill screen — BlurRate=0.3 — real-time blurred snapshot]
        │       # BlurRate is a normalized rate [0.0 = no blur, 1.0 = maximum blur], NOT a pixel radius.
        │       # See 19_appinventor_property_encoding_quirks.md §6 for the Flutter sigma conversion.
        │
        └── 文件视图内容 / FileViewContainer  [AbsoluteArrangement — fill 100%, z=95]
            ├── 文件视图 / FileList        [VerticalScrollArrangement — z=9 — dynamically populated]
            └── 垂直布局1 / WallpaperLayer [VerticalArrangement — z=0 — behind FileList]
                └── 图像框1 / Wallpaper    [Image — 2048×2048 — Backpic.png — background wallpaper]
```

**Non-visual / service components:**

| Original Name           | Type             | Suggested Name          | Purpose                                                |
|-------------------------|------------------|-------------------------|--------------------------------------------------------|
| `视图组件动画1`          | ViewAnimator     | ViewAnim                | Screen-entry/exit animations, blur panel scale         |
| `屏幕尺寸改变`           | Clock (disabled) | ScreenSizeClock         | Fires on orientation change to re-layout               |
| `实时模糊采样`           | Clock (disabled) | BlurSampleClock         | 30 ms interval — captures snapshot for live-blur bg    |
| `文件管理器1`            | File             | FileManager             | List dirs/files, create dirs, save/read text           |
| `缓存`                   | TinyDB           | Cache                   | Namespace "Data" — stores `记忆目录` (last dir), scroll position |
| `KevinkunEnhance1`      | KevinkunEnhance  | KevinkunEnhance         | Rounded-corner styling for buttons                     |
| `HTTP客户端1`            | Web              | HttpClient              | (Background music fetch, same as Screen1)              |
| `音频播放器1`            | Player           | AudioPlayer             | Background music / haptic vibration                    |
| `信息分享器1`            | Sharing          | SharingHelper           | Share files to other apps                              |
| `扫描触发开文件`         | Clock            | FileOpenTrigger         | Polling clock to fire deferred open-file callback      |
| `活动启动器1`            | ActivityStarter  | ActivityStarter         | Launch external apps / file actions                    |
| `信息对话框1`            | Notifier         | Notifier                | Progress dialogs, text input dialogs, alerts           |
| `缓存最近项目`           | TinyDB           | RecentProjectsDB        | Namespace "Datalink" — stores recent project links     |
| `备用`                   | TinyDB           | BackupDB                | Spare TinyDB (no namespace set)                        |

---

## Global Variables

| Original Name   | Suggested Name      | Type       | Description                                             |
|-----------------|---------------------|------------|---------------------------------------------------------|
| `文件目录`       | currentDirectory    | String     | Currently browsed directory path                        |
| `blurswitch`    | blurSwitch          | Boolean    | True = blur needs to be resampled on next clock tick    |
| `模糊计数`       | blurCycleCount      | Integer    | Counts blur cycles; triggers auto-lock screen at 60000 |
| `布局`          | layoutTracker       | String     | Tracks layout state (reset to "" on each refresh)       |
| `托管函数`       | pendingCallback     | Function   | Stores deferred callback for file-open trigger          |
| `读截图`         | readScreenshotCb    | Function   | Callback for reading a thumbnail from disk              |
| `图像组件`       | imageComponentRef   | Component  | Reference to dynamic image component being operated on  |

---

## Procedures

### `文件初始化` / initializeFileView(directory, callback)

Called whenever the directory changes. Rebuilds the `FileList` scroll view.

1. Hide the context menu (`针对性菜单.Visible = false`).
2. Clear all children from `FileList`.
3. Reset `layoutTracker = ""`.
4. Store current directory into `Cache` DB under key `"记忆目录"`.
5. Create a placeholder spacer item at the top of the list (height=70).
6. **Enumerate subdirectories** (`FileManager.ListDirectories()`):
   - For each subdirectory (filtering out hidden folders):
     - Call `生成文件单元` anonymous function to build a folder row UI item.
7. **Enumerate files** (`FileManager.ListFiles()`):
   - For each file whose name ends with `".SPA"` (detected by reversing the filename string and checking if the reversed string starts with `"APS."` — App Inventor lacks a native `endsWith` function, so this reverse trick is used):
     - Build a local thumbnail path: `storageemulated0 + sanitized_path + ".png"`.
     - Store a `读截图` callback that loads that thumbnail into an image widget.
     - Call `生成文件单元` to build a file row UI item.
8. On complete: invoke the passed-in callback.

### `截图` / captureScreenshot(callback)

Saves a JPEG screenshot of the current file-manager view as the wallpaper file:

1. Store current scroll position into `Cache` under key `"滚动条位置"`.
2. Delete existing `/storage/emulated/0/SPACEDESK/filelink.jpg` if it exists.
3. Call `FileManager.BitmapSaveCallback(screen.ToBitmap(), path, callback)`.

### `启动应用` / launchApp()

Creates a lock file at `/storage/emulated/0/SPACEDESK/lock.txt` (empty content). This signals to Workspace that a project is being opened.

### `UIKIT建立简单矩形` / buildSimpleRect(layout)

Applies a styled rectangle look to a given HorizontalArrangement:
- Rounded corners with light-gray border via `KevinkunEnhance.SetBackground`.
- Size: 250×50, alignment: left.
- Margin: 5.

### `UIKIT建立经典按钮` / buildClassicButton(button, colorCode)

Applies icon-button styling:
- Size: 35×35.
- Registers two event handlers: click (opens file / action) and long-click.
- Margin: 5.
- `colorCode` selects the icon/color variant.

### `小动画` / animateSmall(callback)

Scales the ViewAnimator's target view to 90% size and 50% alpha in 100 ms. Used as "press feedback".

### `大动画` / animateLarge(callback)

Restores the view to 100% scale and full alpha in 100 ms. Used as "release feedback".

---

## Event Handlers

### `RecentFiles.Initialize`

1. If `manifest.txt` exists at SPACEDESK root → `openAnotherScreen("Workspace")` (redirect — shouldn't happen normally since Screen1 handles this, but is a safety net).
2. Otherwise:
   - Set wallpaper image size to max(screenWidth, screenHeight).
   - Apply special wallpaper if today's date is "02.27" (In memory of the aircraft — shows AN-225 image).
   - Create fold.txt at SPACEDESK/SPACE/ (initialises subfolder).
   - Restore last visited directory from `Cache` DB.
   - Apply elevation shadow to top bar.
   - Build 8 toolbar buttons with `buildClassicButton`.
   - Call `initializeFileView(currentDirectory, callback)`.
   - Start `ScreenSizeClock` and `BlurSampleClock`.

### `按钮_新建.Click` / NewFileBtn tap

- Show progress dialog "正在载入 / Loading".
- Serialize a minimal new project JSON list and save it as a new `.SPA` file in the current directory.
- On save complete: open the Workspace screen with the new file path as start value.

### `按钮_新建文件夹.Click` / NewFolderBtn tap

- Show a text-input dialog: "文件夹名称 / Folder Name" with default text "新建文件夹 / New Folder".

### `信息对话框1.AfterTextInput` / Notifier text input callback

- If input is not empty:
  - Show progress dialog.
  - Create the directory at `currentDirectory + "/" + inputText`.
  - If success: refresh `initializeFileView` and dismiss the progress dialog.

### `屏幕尺寸改变.Timer` / ScreenSizeClock tick

- Compute `max(screen.Width, screen.Height)`.
- If the current animation width differs from screen size by more than 6 px:
  - Animate the overlay to fill the new screen size.
  - Refresh `initializeFileView`.
- If `manifest.txt` exists → open Workspace (handles mid-session orientation change).

### `实时模糊采样.Timer` / BlurSampleClock tick (30 ms)

- If `blurSwitch` is true:
  - Capture a bitmap snapshot of `FileViewContainer`.
  - Store it into `BlurSample.PictureBitmap`.
  - Reset `blurSwitch = false`.
  - Increment `blurCycleCount += 30`.
  - If `blurCycleCount >= 60000` → open Workspace (locks screen after long idle).

### `文件视图.ScrollChanged`

- Set `blurSwitch = false` (disable live blur sampling while scrolling).

### `RecentFiles.BackPressed`

Handles the Android back button with a three-level dismissal:
1. If `NamingDialog` is visible → hide it and dismiss keyboard.
2. Else if `ContextMenu` is visible → hide it.
3. Else if history stack has >3 entries → pop the current directory (go up one level).
4. Run the back-navigation animation (scale + fade out, then navigate back to Screen1).

### `标题.Click` / TitleImage tap

- Capture a screenshot (async).

### `标题.LongClick` / TitleImage long-press

- Clear all `Cache` DB entries.
- Vibrate for 1000 ms.

### `RecentFiles.OtherScreenClosed`

- When returning from Workspace: go back to Screen1 (full app restart).

### `扫描触发开文件.Timer` / FileOpenTrigger tick

- If `pendingCallback` is not "done" → execute the deferred callback (opens the selected file).

---

## Flutter Implementation Notes

- The `FileList` is a **dynamically built scrollable list**: each item is created programmatically. In Flutter, use a `ListView.builder` that reads the directory listing and produces `ListTile`-style widgets.
- **Thumbnail loading**: Each `.SPA` file has a companion `.png` screenshot. Load thumbnails asynchronously with `Image.file(File(thumbnailPath))`.
- The **context menu** (`针对性菜单`) appears as a horizontal strip of icon buttons above the top bar when a file/folder is selected (long-press). It contains: Dock, Share, Cut, Copy, Delete, Confirm-Delete. Implement as an `AnimatedContainer` that slides in from the right.
- **Live blur background**: On each scroll or interaction, capture the `FileList` widget as a `ui.Image` snapshot, apply a Gaussian blur, and display it behind the list. Rate-limit this to match the 30 ms original clock interval.
- The **NamingDialog** (`命名和新建`) is a center-of-screen overlay with a file-icon image and a single text field. In Flutter, use a `showDialog` with a `TextField`.
- **New file creation**: A new project is a JSON list `["title", [], [], [], []]` saved to disk as `<folderName>/<name>.SPA`. The `.SPA` extension comes from the app's original name **SPACEDESK** (first 3 letters: SPA).
- **File detection in Flutter**: Use `path.endsWith('.SPA')` (case-sensitive, matching original behaviour). The original AppInventor code detects `.SPA` files by **reversing the filename string** and checking if the reversed string starts with `"APS."` — since App Inventor has no `endsWith` function. Do not use `contains` as that would match false positives.
- **Directory navigation**: Current directory is stored in `Cache` TinyDB (`记忆目录` key). Restore it on screen open.
