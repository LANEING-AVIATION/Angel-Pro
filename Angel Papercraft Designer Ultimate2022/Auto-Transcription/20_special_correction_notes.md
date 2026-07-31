# Special Correction Notes (Previous Misunderstandings)

## Status

- **State:** Reference
- **Updated:** 2026-07-30
- **Usage:** Historical migration pitfalls. Not a standalone policy source.

This file records important misunderstandings discovered during transcription so future migration work does not repeat them.

---

## 1) `.SPA` extension detection (critical)

### Earlier misunderstanding

- Treating `"APS."` as the file extension itself.
- Using `contains(".SPA")` style matching in Flutter guidance.

### Correct behavior

- Real extension is `.SPA` (from **SPACEDESK** naming).
- Legacy AppInventor trick: reverse filename string and check `startsWith("APS.")` (because no native `endsWith`).
- Flutter should use strict `path.endsWith('.SPA')`.

---

## 2) Entry-screen logic may be non-production

### Earlier risk

- Assuming all components/events on entry screen are part of real user flow.

### Correct behavior

- Some entry screens auto-redirect immediately without condition.
- Remaining controls/events on those screens can be test leftovers.

Confirmed:

- `A3PDF_EN/Screen1.Initialize` -> unconditional open `UnfoldULT`.
- `A3LIV_EN/Screen1.计时器1.Timer` -> unconditional open `Texture`.

---

## 3) Orphan screens are present by design

### Earlier risk

- Treating all existing screens in project tree as reachable.

### Correct behavior

- Several A3LIV_EN screens have zero incoming navigation and are effectively dev/test stubs.
- They should be treated as optional debug modules unless manually wired.

See reachability notes in:

- `13_a3liv_overview.md`
- `15_a3liv_auxiliary_screens.md`
- `16_a3pdf_overview.md`

---

## 4) Transform overlay trick (single-object manipulation)

### Earlier missing detail

- The docs described transform and preview behavior, but not explicitly the synchronized-overlay intent.

### Correct behavior

- `预览窗口` is used as a focused manipulation overlay.
- Camera settings are synchronized with `TJS容器`.
- This creates a visual highlight/isolation effect for the manipulated object while keeping full-scene context.

See:

- `06_workspace_3d_engine.md`
- `09_workspace_transform.md`

---

## 5) AppInventor/WxBit property encoding quirks

### Earlier risk

- Misreading negative dimensions, alignment indices, and color formats.

Migration enforcement addition: interface work must preserve the recursive
`.scm` component hierarchy and apply relevant `.bky` runtime property overrides,
not merely reproduce an approximate screenshot. Exact dimension/alignment
decoding and the required per-subtree Flutter mapping record are defined in
`19_appinventor_property_encoding_quirks.md` and
`docs/appinventor_layout_fidelity.md`.

### Correct behavior (verified for this project)

- `-1` auto, `-2` fill parent, `< -1000` percentage encoding (`abs(v+1000)`).
- Alignment can use WxBit composite indices (e.g., `Alignment="5"`).
- Colors may be `&H...` or signed 32-bit integers.

See:

- `19_appinventor_property_encoding_quirks.md`

---

## 6) Asset usage assumptions

### Earlier risk

- Assuming every file in `assets/` is active.

### Correct behavior

- Some assets are uploaded but unused in current logic wiring.
- In A3PDF_EN, `SCANPIC.PNG`, `OUTPORT.PNG`, `FLATLOADNEW.HTML` are currently not referenced by BKY runtime paths.

See:

- `12_assets_hierarchy.md`

---

## 7) Interface migration evidence order (critical)

### Earlier misunderstanding

- Treating a screenshot as the specification and describing its appearance
  with broad terms such as “3D,” “beveled,” “flat,” or “glossy.”
- Reading `.scm` without merging initialization and UIKIT calls from `.bky`.
- Applying one generic button treatment to classic buttons, checkbox-bound
  buttons, simple rectangles, function groups, selectors, and managers.
- Replacing an icon's source button/container while replacing the icon leaf.
- Appending each visual correction to the notes without superseding
  contradictory conclusions.
- Writing tests for the latest screenshot reaction instead of decoded source
  properties.

These mistakes produced the metallic toolbar, fabricated command-line block,
pill/gloss gradients, contiguous XYZ tabs, empty Gesture manager, incorrect
runtime group names, missing Transform bodies, and invented blue action-button
hierarchy.

### Correct behavior

Apply interface evidence in strict order:

1. `.scm` recursive component tree, sibling order, raw properties, and initial
   visibility;
2. `.bky` runtime children, UIKIT procedure calls, text/state changes,
   visibility overrides, and animation timings;
3. decoded App Inventor/WxBit component defaults;
4. screenshot validation;
5. Flutter/Cupertino judgment only where the source is silent.

The screenshot may reveal that source evidence was missed, but it may not
silently override explicit source data. Resolve the missing source rule first.
Keep a single merged SCM-plus-BKY manifest and replace obsolete conclusions
instead of accumulating mutually exclusive ones.

### Workspace examples recovered from BKY

- `UIKIT建立经典按钮`: `#7e7e7e21`, radius 5, elevation 1, white
  15-point content, 5-pixel margin, and 100/400 ms press feedback.
- `UIKIT建立复选框`: active `#3a6999`/white with `#8bbeef` shadow;
  inactive white/black with `#999999` shadow.
- `UIKIT建立函数管理器`: inactive items have no tile; the selected item
  uses a white 40 x 40, radius-9, elevation-6 pad that travels in 600 ms.
- Wireframe group labels are `Strokes`, `Surface`, `Connection`, and
  `Reference`.
- Transform group labels are `Dragging`, `Transformation`,
  `Texture & Group`, and `Flip & Align`.

### Icon rule

All migrated production icon leaves must come from Flutter's
`CupertinoIcons` API. Do not register or render bitmap icon assets, the legacy
`ICONFONTforANGELIII.otf`, a replacement/custom icon font, raw
`IconData(...)`, Material icons, or custom-painted icon substitutes.

This rule applies to the icon leaf only. Preserve the `.scm`/`.bky` container,
geometry, ordering, background, shadow, state, and animation. Non-icon source
imagery such as workspace backgrounds and reference images remains allowed.

The canonical procedure and Workspace mapping are maintained in
`docs/appinventor_layout_fidelity.md`.
