# Special Correction Notes (Previous Misunderstandings)

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

