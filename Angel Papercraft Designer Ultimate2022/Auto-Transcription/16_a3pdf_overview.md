# App Module: A3PDF_EN (Unfold to A4 PDF/Image) — Overview

**Original App ID**: `A3PDF_EN`  
**Role in legacy architecture**: separate unfold/export app  
**Why separate from Workspace**: AppInventor complexity limits; unfold/PDF pipeline isolated into another activity/app

> **Special correction note**: entry-screen auto-redirect and effective feature scope were corrected after event-graph verification. See `20_special_correction_notes.md`.

---

## Purpose

`A3PDF_EN` converts Angel III 3D papercraft model data into:

1. Flat unfolded layout previews (WebViewer + Three.js),
2. Multi-page PDF exports (via `KIO4_Pdf` extension),
3. Standalone image exports (`.jpg`) of unfolded sheets.

It is the downstream export stage after modeling in `A3NG_EN`.

---

## Screen map

| Screen | Suggested Flutter route | Role |
|---|---|---|
| `Screen1` | `/export/entry` | immediate redirect to PDF screen |
| `UnfoldULT` | `/export/pdf` | **main PDF export page** |
| `UnfoldIMG` | `/export/image` | image export page |

---

## Navigation flow

```text
Screen1.Initialize
  -> open UnfoldULT

UnfoldULT
  -> Exp IMG button writes unfold state
  -> open UnfoldIMG with start value
```

Observed BKY target blocks:

- `Screen1` uses `controls_openAnotherScreen` -> `UnfoldULT`
- `UnfoldULT` uses `controls_openAnotherScreenWithStartValue` -> `UnfoldIMG`

### Reachability / leftover-code notes

1. `Screen1` is an entry stub that redirects on `Initialize` with no `controls_if` guard.
2. Any additional logic/components left on `Screen1` are effectively legacy/test leftovers unless they run before redirect.
3. `UnfoldIMG` is reachable only through `UnfoldULT.按钮_ExpIMG.Click` (not directly from entry).
4. No other screens exist in A3PDF_EN, so there are no hidden orphan screens in this module.

---

## Shared file contract and storage paths

Main runtime folder:

```text
/storage/emulated/0/SPACEDESK/
```

Observed files used by Unfold screens:

- `filelink.txt` (project/file pointer from upstream app)
- `unfoldcode.txt` (handoff payload to UnfoldIMG)
- `导出的图纸/code.json` (generated unfold geometry payload)
- exported image directory: `导出的图纸/`
- exported PDF filename: `export.pdf`

---

## Shared logic footprint (UnfoldULT + UnfoldIMG)

Both screens include:

- 14 component events
- 9 procedures
- 6 functions
- shared geometry conversion and camera math pipeline:
  - `W64SPA转OBJ`
  - `面序号`
  - `空间求角度`
  - `空间求距离`
  - `求平面F`
  - `加维度`

Shared procedures:

- `TJS大世界自动刷新`
- `角度换算赋值`
- `相机刷新`
- `保存`
- `新轮廓预览`
- `画线`
- `UIKIT建立经典按钮`

---

## Web assets used

- `//flatloader.HTML` (normal unfolded view with lines)
- `//flatpure.HTML` (line-hidden / simplified view)

Button behavior:

- `按钮_去除线条.Click` -> load `flatpure.HTML`
- `按钮_恢复线条.Click` -> load `flatloader.HTML`

---

## Name mapping (key)

| Original | Suggested |
|---|---|
| `TJS容器` | `threeJsUnfoldWebView` |
| `网页导出的图像` | `renderOutputImage` |
| `手势平移` | `gestureOverlay` |
| `扫描触发加载序列` | `loadSequenceClock` |
| `窗口适应` | `viewportFitClock` |
| `文本输入框_1` | `scaleInputBox` |

Detailed screen-level dictionaries are in:

- `17_a3pdf_unfold_pdf.md`
- `18_a3pdf_unfold_image.md`
