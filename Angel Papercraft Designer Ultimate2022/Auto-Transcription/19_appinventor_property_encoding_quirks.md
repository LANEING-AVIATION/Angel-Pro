# AppInventor/WxBit Property Encoding Quirks (Migration Guardrail)

This note records property-storage rules that are easy to misread when migrating `.scm`/`.bky` to Flutter.

Official behavior references:

- MIT App Inventor [Layout component reference](https://ai2.appinventor.mit.edu/reference/components/layout.html)
- MIT App Inventor [User Interface component reference](https://ai2.appinventor.mit.edu/reference/components/userinterface.html)

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

The stored integer must be decoded by **property name and owning component
type**. It is not a single enum shared by Flutter:

- WxBit arrangement/absolute-layout `Alignment` is a 3x3 anchor grid:
  `1` top-left, `2` top-center, `3` top-right, `4` center-left, `5` center,
  `6` center-right, `7` bottom-left, `8` bottom-center, `9` bottom-right.
- Standard MIT App Inventor `AlignHorizontal`: `1` left, `2` right,
  `3` horizontally centered.
- `AlignVertical`: `1` top, `2` center, `3` bottom.
- `TextAlignment` controls text flow, not placement of the component in its
  parent, and must be mapped separately.
- In absolute layouts, `XCoord`, `YCoord`, `ZCoord`, and `OriginAtCenter`
  remain independent positioning inputs and must be preserved.

Safe migration strategy:

- Treat these as semantic anchors (`center`, `centerLeft`, etc.) instead of literal integers in Dart.
- Resolve omitted values using that App Inventor component type's default;
  omitted never means “center by default in Flutter.”
- Normalize per component type while rebuilding layout.

Main-axis sizing must also preserve arrangement behavior:

- In a fixed/fill `HorizontalArrangement`, fill-parent-width children equally
  divide the width remaining after fixed/automatic siblings.
- In an automatic-width `HorizontalArrangement`, a fill-parent-width child
  behaves as automatic.
- The equivalent rules apply to heights in a `VerticalArrangement`.
- In a `TableArrangement`, fill-parent is evaluated as automatic while
  calculating row/column size, after which the component fills its cell.

These rules are confirmed by the official MIT App Inventor layout reference and
must be represented with `Expanded`/`Flexible`, loose constraints, or table cell
constraints according to the actual parent; `double.infinity` alone is not an
equivalent in every context.

---

## 3) Component-tree and runtime-override rule

The `.scm` `$Components` recursion is the authoritative design-time component
tree. Preserve its parent/child nesting, sibling order, arrangement and scroll
boundaries, hidden branches, and absolute overlay/Z order in Flutter. Do not
flatten or regroup nodes merely because a different Flutter composition is
more convenient.

The corresponding `.bky` must also be searched for runtime changes to size,
alignment, visibility, coordinates, and component creation. A design-time
property copied from `.scm` is incomplete when blocks later replace it.

Flutter technical wrappers such as `Expanded`, `Align`, `Positioned`, `Stack`,
or `FractionallySizedBox` are permitted only as documented one-purpose adapters
for the corresponding legacy node. See the required mapping and acceptance
record in `docs/appinventor_layout_fidelity.md`.

### Visibility-driven view switching is structural

The legacy application predates Flutter-style responsive composition. When
`.bky` mode logic hides the former side-panel arrangement and shows the new
one, this means **one retained sibling branch is visible at a time**; it does
not authorize merging all branch contents into one responsive scrolling page.

In Flutter, preserve every `.scm` sibling and its state with an `IndexedStack`
or explicit `Offstage`/visibility wrappers controlled by one English enum.
Changing the selection changes the visible branch only. Do not reconstruct or
reset hidden branches unless the original blocks do so.

---

## 4) Color token formats

Two storage formats are used and both are valid:

1. Hex-like AppInventor format: `&HFF54739B` (convert to `0xFF54739B`).
2. Signed 32-bit decimal color values (including negative ints).

Safe decode rule in Dart:

```dart
Color(appInventorValue & 0xFFFFFFFF);
```

---

## 5) Why this matters for this project

If these rules are decoded incorrectly, migration errors usually appear as:

- wrong panel sizing (especially percent-based layouts),
- misplaced overlays/webview stacks,
- incorrect colors/opacity in top bars and side panels.

This is critical for the Workspace viewport stack (`叠放窗口`) and for A3PDF export preview frames.

---

## 6) Blur rate property semantics

Two blur-related properties appear in WxBit/AppInventor `.scm` files:

| Property name              | Component type        | Example values seen |
|----------------------------|-----------------------|---------------------|
| `BackgroundImageBlurRate`  | Screen, Image, Layout | `"0.2"`, `"1.0"`   |
| `BlurRate`                 | Image (live-capture)  | `"0.01"`, `"0.3"`  |

**Encoding rule:** both are a **normalized rate in the range `[0.0, 1.0]`**, NOT
a pixel radius or sigma value.

- `1` (or `1.0`) → **maximum blur** — apply the strongest available blur effect.
- `0` (or `0.0`) → **no blur** — the image is rendered unfiltered.

This is the inverse of what Flutter's `ImageFilter.blur(sigmaX, sigmaY)` expects.
When migrating, the rate must be converted to an appropriate sigma:

```dart
// Suggested mapping — tune maxSigma to taste (12–20 is typical for heavy glass blur).
const double maxSigma = 15.0;
double toSigma(double blurRate) => blurRate * maxSigma;

ImageFilter.blur(sigmaX: toSigma(rate), sigmaY: toSigma(rate), tileMode: TileMode.clamp)
```

Do **not** pass the raw `BlurRate` value as a sigma — `ImageFilter.blur(sigmaX: 1)` is
a radius-1-pixel blur (barely visible), which is the exact opposite of the intended
"maximum blur" behavior.

---

## 7) Scope note

This file records **data-encoding behavior** only.  
It does **not** override feature-scope decisions already documented in:

- `13_a3liv_overview.md` (reachability and test screens),
- `16_a3pdf_overview.md` (entry-screen auto-redirect),
- `12_assets_hierarchy.md` (asset migration layout).

