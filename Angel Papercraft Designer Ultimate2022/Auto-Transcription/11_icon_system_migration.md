# Icon System: Legacy Font Icons → SVG Migration

This document records the custom icon font system used in the original AppInventor project and specifies the migration strategy for the Flutter rebuild.

---

## Background: Why a Custom Icon Font?

MIT App Inventor does not support SVG icons or any standard icon library (like Material Icons). To display vector icons, the original developer created a **custom icon font** using FontCreator:

**Font file**: `ICONFONTforANGELIII.otf`  
**Location in original project**: `assets/ICONFONTforANGELIII.otf`  

Each icon was drawn as a glyph and **mapped to a Latin alphabet letter**. For example, the letter `"D"` might display as a "document" icon, `"V"` as a "view" icon, etc. The font is applied to a Label or Button component at runtime via:

```
call KevinkunEnhance1.setFontTypeface(component, asset("//ICONFONTforANGELIII.otf"))
```

---

## Known Problems with the Icon Font Approach

The developer encountered several limitations:

1. **Letter spacing mismatch**: Glyph widths in `ICONFONTforANGELIII.otf` were designed for alphabet proportions, not square icons. Each icon had its own unexpected horizontal padding. The workaround was to prepend/append different quantities of space characters (`"    "` / `"   "`) to each icon's text string to make it visually centred. This is fragile and not portable.

2. **Latin letters unusable for text**: Since every Latin letter mapped to an icon glyph, it was **impossible to display English text** on any Label or Button that used the icon font. This forced the UI design into two categories:
   - Components using only the icon font (icon-only, no readable text).
   - Components using the system font (text-only, no icons).

3. **Icon + text combos required Chinese**: The only way to show an icon alongside a description was to use the icon font for the letter, followed by **pure Chinese characters** (which rendered normally since they have no glyph mapping in the font). Example: a button with text `"D修改"` would render as `[document-icon] 修改`.

4. **Partial removal in the English version**: The A3NG_EN project (the one being transcribed) is the English-language version. To produce an English UI, many of the icon+Chinese-text buttons had to be **replaced** with either:
   - Icon-only buttons (letter code still used, no text label).
   - Plain English text buttons (no icon font).
   This is why some buttons in the `.scm` files have empty text `""` and some have plain English labels like `"Select"`, `"Loft"`, `"Drag"`.

---

## How the Icon Font Was Used in Code

The `UIKIT建立经典按钮` / `buildClassicButton(button, colorCode)` procedure accepts a **single letter as the icon code**:

```
if colorCode is not empty:
    button.Text = button.Text          // keep existing text (plain English label)
                                       // font NOT applied — button stays system font
else:
    button.Text = HtmlTextDecode(...)  // decode an HTML entity (Unicode char → icon)
    apply ICONFONTforANGELIII.otf to button
```

The `UIKIT建立功能组` / `buildFunctionGroup(layout, toggle, iconCode, label, width)` procedure creates a panel header row with:
- An icon label (font applied, icon code set as text).
- A section title string (plain text, next to the icon).
- A toggle switch.

The `UIKIT建立函数管理器` / `buildFuncManager(layout, itemList, useFont)` procedure creates tab-bar buttons where each item's text is decoded from an HTML entity and the icon font is applied.

---

## Inventory of Icon Letter Codes Used

The following letters are passed as icon codes across the project. The actual glyph each letter maps to is defined in `ICONFONTforANGELIII.otf`. The **suggested SVG icon** is a best-guess replacement based on the button's context.

### Workspace Screen — `界面初始化()` calls

| Letter Code | Context / Assigned To                  | Suggested SVG Icon                |
|-------------|----------------------------------------|-----------------------------------|
| `"D"`       | (×2) — first: unknown btn; second: Texture & Group panel header | document / texture |
| `"V"`       | Unknown button                         | view / eye                        |
| `"F"`       | (×2) — button + Reference panel header | folder / flag / reference         |
| `"T"`       | Unknown button                         | type / text / transform           |
| `"bb"`      | Unknown button (two-char = special?)   | double-arrow / back-back          |
| `"W"`       | (×2) — button + Strokes panel header   | wireframe / pencil / wave         |
| `"O"`       | Button + Connection panel header       | orbit / connect / link            |
| `"P"`       | Button                                 | pin / point / place               |
| `"L"`       | Button                                 | loft / line / layer               |
| `"Y"`       | (×2) — buttons                         | Y-axis / symmetric                |
| `"h"`       | (×2) — button + Flip & Align header    | horizontal / flip                 |
| `"i"`       | (×3) — buttons                         | info / insert                     |
| `"G"`       | Button                                 | group / grid                      |
| `"E"`       | (×3) — checkboxes                      | edge / enter / expand             |
| `"M"`       | Checkbox + Surface panel header        | mesh / material / mirror          |
| `"S"`       | Checkbox                               | select / surface / snap           |
| `"X"`       | Checkbox + Dragging panel header       | x-axis / close / transform        |
| `"N"`       | Checkbox                               | normal / new                      |
| `"I"`       | `UIKIT建立函数管理器` + Transformation panel header | info / inspect |
| `"a"`       | `UIKIT建立函数管理器` item              | add / attach                      |

### Workspace Screen — `UIKIT建立函数管理器` top menu

| Letter Code | Context                                | Suggested SVG Icon                |
|-------------|----------------------------------------|-----------------------------------|
| `"S"`       | First tab                              | files / list                      |
| `"I"`       | Second tab                             | info / settings                   |
| `"X"`       | Third tab                              | close / clear                     |

### RecentFiles Screen — toolbar buttons

| Letter Code | Context / Button Position              | Suggested SVG Icon                |
|-------------|----------------------------------------|-----------------------------------|
| `"B"`       | First toolbar button                   | back / browse / bookmark          |
| `"L"`       | (×2) Second and third buttons          | list / location                   |
| `"Y"`       | Fourth button                          | confirm / yes                     |
| `"K"`       | Fifth button                           | key / link                        |
| `"J"`       | Sixth button                           | jump / join                       |
| `"V"`       | Seventh button                         | view / verify                     |
| `""`        | Eighth button — empty code means HTML-entity icon decoded at runtime | (see note below) |

> **Note on empty string `""`**: When the icon code is an empty string, the button text is set from `HTTP客户端1.HtmlTextDecode(entity)` at runtime — meaning the glyph character is stored as an HTML entity (e.g., `&#xE001;`) somewhere in the block code, not as a plain letter. These are **private-use Unicode codepoints** mapped in the font. The exact glyph is unknown without running the app, but they are the icons where the developer had no available Latin letter that fit the meaning.

---

## Spacing Hack

Because icon glyphs had mismatched advance widths, text values were padded with spaces. Examples seen in the code:

```
?.Text = join("    ", HTTP客户端1.HtmlTextDecode(), "   ")
//              ^^^^                                  ^^^
//         4 leading spaces                      3 trailing spaces
```

This was done per-icon to compensate for different left/right bearing values in the font. **This technique must not be replicated in Flutter.**

---

## Migration Strategy: SVG Icons in Flutter

For the Flutter rebuild, replace all icon font usage with **SVG icons**.

### Recommended Approach

Use the [`flutter_svg`](https://pub.dev/packages/flutter_svg) package:

```yaml
dependencies:
  flutter_svg: ^2.x.x
```

Render an icon:
```dart
SvgPicture.asset(
  'assets/icons/undo.svg',
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
)
```

### Icon + Text Buttons

The original icon+text pattern (icon letter followed by Chinese text) should be reimplemented as a `Row` containing an `SvgPicture` and a `Text`:

```dart
Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    SvgPicture.asset('assets/icons/folder.svg', width: 20, height: 20),
    const SizedBox(width: 6),
    const Text('Open'),
  ],
)
```

### Standalone Icon Buttons

For icon-only buttons (the most common case in toolbar rows), use `IconButton` with an `SvgPicture` as the icon:

```dart
IconButton(
  icon: SvgPicture.asset('assets/icons/undo.svg', width: 24),
  onPressed: onUndo,
  tooltip: 'Undo',
)
```

### No More Spacing Hacks

SVG icons have precise bounding boxes. Set `width` and `height` explicitly — no padding or spacing tricks needed.

### No Font Restriction on Text

Since SVG icons are separate widgets from text, English labels can be placed freely next to any icon without any conflict.

---

## Asset Organisation

Create a dedicated icons directory:

```
assets/
└── icons/
    ├── undo.svg
    ├── save.svg
    ├── folder.svg
    ├── new_file.svg
    ├── delete.svg
    ├── copy.svg
    ├── cut.svg
    ├── paste.svg
    ├── share.svg
    ├── dock.svg
    ├── new_folder.svg
    ├── wireframe.svg
    ├── transform.svg
    ├── texture.svg
    ├── edge.svg
    ├── loft.svg
    ├── group.svg
    ├── surface.svg
    ├── reference.svg
    ├── connection.svg
    ├── flip.svg
    ├── drag.svg
    ├── select.svg
    └── ...
```

A good free source for SVG icons matching this app's style (technical/engineering): [Material Symbols](https://fonts.google.com/icons) or [Tabler Icons](https://tabler.io/icons).

---

## Summary Table: Letter Code → Recommended SVG

This is a working reference. The developer (LANEING) should verify each mapping visually before finalising.

| Screen        | Letter | Context label       | Recommended icon name (Material / Tabler) |
|---------------|--------|---------------------|-------------------------------------------|
| Workspace     | D      | Texture & Group     | `texture` / `color_lens`                  |
| Workspace     | V      | —                   | `visibility`                              |
| Workspace     | F      | Reference           | `flag` / `photo`                          |
| Workspace     | T      | —                   | `text_fields` / `title`                   |
| Workspace     | bb     | —                   | `keyboard_double_arrow_left`              |
| Workspace     | W      | Strokes             | `gesture` / `draw`                        |
| Workspace     | O      | Connection          | `hub` / `link`                            |
| Workspace     | P      | —                   | `place` / `push_pin`                      |
| Workspace     | L      | —                   | `layers` / `line_axis`                    |
| Workspace     | Y      | —                   | `swap_vert` / `sync_alt`                  |
| Workspace     | h      | Flip & Align        | `flip` / `align_horizontal_center`        |
| Workspace     | i      | —                   | `info_outline`                            |
| Workspace     | G      | —                   | `group_work` / `grid_view`                |
| Workspace     | E      | Edge                | `timeline` / `polyline`                   |
| Workspace     | M      | Surface             | `grid_3x3` / `blur_on`                    |
| Workspace     | S      | Select              | `select_all` / `highlight_alt`            |
| Workspace     | X      | Dragging            | `open_with` / `drag_indicator`            |
| Workspace     | N      | —                   | `add` / `fiber_new`                       |
| Workspace     | I      | Transformation      | `transform` / `tune`                      |
| RecentFiles   | B      | —                   | `folder_open` / `source`                  |
| RecentFiles   | L      | —                   | `list` / `format_list_bulleted`           |
| RecentFiles   | Y      | —                   | `check` / `done`                          |
| RecentFiles   | K      | —                   | `key` / `vpn_key`                         |
| RecentFiles   | J      | —                   | `open_in_new` / `launch`                  |
| RecentFiles   | V      | —                   | `preview` / `visibility`                  |
