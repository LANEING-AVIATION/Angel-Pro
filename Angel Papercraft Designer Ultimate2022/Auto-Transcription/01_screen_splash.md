# Screen: Splash / Welcome Screen (Screen1)

**Original name**: `Screen1`  
**Suggested Flutter route**: `/splash`  
**Orientation**: Landscape  
**Background**: Blurred wallpaper (`Backpicqualitylow.png`). If the file `/storage/emulated/0/SPACEDESK/filelink.jpg` exists, use that as wallpaper instead (it is a screenshot captured from the file manager).

---

## UI Component Tree

```
Screen1 (Form)
└── 层叠布局1 / OverlayLayout  [AbsoluteArrangement — fills screen]
    └── 垂直布局2 / MainColumn  [VerticalArrangement — centered]
        └── 水平布局1 / LogoRow  [HorizontalArrangement — centered]
            ├── 图像框2 / AppLogo     [Image — 300×300 — PUREICO.PNG]
            └── 垂直布局3 / AboutPanel  [VerticalArrangement — HIDDEN by default]
                ├── 标签_ANGELII / TitleLabel     [Label — "ANGEL Ⅲ ULTIMATE" — white, bold, 35pt]
                ├── 按钮_资料库 / RecentFilesBtn  [Button — "Recent Files" — black bg, white text]
                └── 垂直滚动条布局1 / CreditsScroll  [VerticalScrollArrangement — h=1050]
                    ├── 标签_基于空间台面 / CreditsBody  [Label — white, multi-line credits text]
                    ├── 标签_公司 / DeveloperLabel    [Label — "Developer:LANEING"]
                    ├── 标签_地点 / LocationLabel     [Label — "Designed by ♥ in Chongqing City,China."]
                    ├── 标签1 / ContactLabel          [Label — "Contact: QQ 961243293"]
                    ├── 标签3 / BilibiliLabel         [Label — Bilibili channel URL]
                    └── 标签2 / MusicLabel            [Label — "Aria by Yanni from Netease Cloud Music" — 10pt]
```

**Non-visual / service components:**

| Original Name        | Type               | Suggested Name         | Purpose                                              |
|----------------------|--------------------|------------------------|------------------------------------------------------|
| `启动页设置1`         | SplashSetting      | SplashConfig           | Sets splash duration to 0 (skips OS splash)          |
| `视图组件动画1`       | ViewAnimator       | ViewAnim1              | General-purpose view animation                       |
| `视图组件动画2`       | ViewAnimator       | ViewAnim2              | Secondary animation slot (unused in known events)    |
| `KevinkunEnhance1`   | KevinkunEnhance    | KevinkunEnhance        | UI styling helper                                    |
| `HTTP客户端1`         | Web                | HttpClient             | Fetches NetEase music stream URL                     |
| `音频播放器1`         | Player             | AudioPlayer            | Background music player                              |
| `文件管理器1`         | File               | FileManager            | Checks/creates SPACEDESK directory, reads manifest   |
| `计时器1`             | Clock              | StartupTimer           | Delays startup logic (triggers once after init)      |
| `微数据库1`           | TinyDB             | AppDB                  | Namespace "Data"; clears "px"/"py" position keys     |

---

## Startup Logic

### On `Screen1.Initialize`

1. Check if `/storage/emulated/0/SPACEDESK/filelink.jpg` exists.
   - If yes → set `OverlayLayout.BackgroundImage` to that file (shows last-session wallpaper).
2. Check if `/storage/emulated/0/SPACEDESK/` directory exists.
   - If not → create it.
3. Clear TinyDB keys `"px"` and `"py"` (reset last-position memory).

### On `StartupTimer.Timer` (fires once, then disables itself)

1. Disable the timer immediately.
2. Check if `/storage/emulated/0/SPACEDESK/manifest.txt` exists:
   - **If yes** → read `manifest.txt` (async callback). On read-complete: open `Workspace` screen, passing the file path from manifest as the start value.
   - **If no**:
     - If screen start value equals `"about"` → show `AboutPanel` (make it visible) + call `HttpClient.MethodGet()` to fetch music URL.
     - Otherwise → `openAnotherScreen("RecentFiles")`.

### On `HttpClient.GotText`

- Parse the response JSON to extract the music stream URL.
- Set `AudioPlayer.Source` to that URL.
- Call `AudioPlayer.Start()`.

### On `按钮_资料库.Click` / RecentFilesBtn tap

- `openAnotherScreen("RecentFiles")`.

### On `Screen1.OtherScreenClosed`

- Re-apply background: if `/storage/emulated/0/SPACEDESK/filelink.jpg` exists, use it; otherwise use the default asset.

---

## Flutter Implementation Notes

- The splash screen should check for the `manifest.txt` file on mount. If found, immediately navigate to `/workspace` with the file path. If not, navigate to `/files` (or show the About overlay if launched with an `about` deep-link).
- The **About panel** (`AboutPanel`) is initially hidden. It contains a scrollable credits section. Show it only when the app is launched with an `"about"` argument.
- **Background music**: Use `just_audio`. Fetch the NetEase URL from `http://music.163.com/api/song/enhance/player/url?id=1324135055&ids=[1324135055]&br=32000`, extract `data[0].url` from the JSON response, and play it.
- The **wallpaper system** (saving a JPEG screenshot of the file manager) should be replicated: after leaving the file manager, save a thumbnail to the app's documents directory, and use it as the blurred background on the splash.
- The `manifest.txt` file at the root of the SPACEDESK directory acts as an **auto-open pointer**: it holds the path of the most recently opened project so the app can reopen it directly on next launch.
