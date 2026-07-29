# AppInventor/WxBit Property Encoding Quirks (Migration Guardrail)

This note records property-storage rules that are easy to misread when migrating `.scm`/`.bky` to Flutter.

---

## 1) Width/Height magic values

For this project, the following rules are valid:

- `-1` = **Automatic / wrap-content-like**
- `-2` = **Fill parent**
- `< -1000` = **percentage encoding**
  - formula: `percentage = abs(value + 1000)`
  - example: `-1050` => `50%`

Observed examples in current files:

- `Height="-1050"` -> 50% style region
- `Width="-2"` / `Height="-2"` -> fill parent patterns
- fixed positive numbers (e.g. `300`, `1485`, `35`) -> pixel-based constants

---

## 2) Alignment encoding

Two forms appear:

1. Standard horizontal/vertical alignment enums (1/2/3 style).
2. WxBit composite `Alignment` values (e.g., `Alignment="5"`) behaving like a 3x3 anchor grid.

Safe migration strategy:

- Treat these as semantic anchors (`center`, `centerLeft`, etc.) instead of literal integers in Dart.
- Normalize per component type while rebuilding layout.

---

## 3) Color token formats

Two storage formats are used and both are valid:

1. Hex-like AppInventor format: `&HFF54739B` (convert to `0xFF54739B`).
2. Signed 32-bit decimal color values (including negative ints).

Safe decode rule in Dart:

```dart
Color(appInventorValue & 0xFFFFFFFF);
```

---

## 4) Why this matters for this project

If these rules are decoded incorrectly, migration errors usually appear as:

- wrong panel sizing (especially percent-based layouts),
- misplaced overlays/webview stacks,
- incorrect colors/opacity in top bars and side panels.

This is critical for the Workspace viewport stack (`叠放窗口`) and for A3PDF export preview frames.

---

## 5) Scope note

This file records **data-encoding behavior** only.  
It does **not** override feature-scope decisions already documented in:

- `13_a3liv_overview.md` (reachability and test screens),
- `16_a3pdf_overview.md` (entry-screen auto-redirect),
- `12_assets_hierarchy.md` (asset migration layout).

