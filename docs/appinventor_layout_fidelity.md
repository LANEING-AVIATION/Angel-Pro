# App Inventor to Flutter Fidelity Contract (Behavior-First)

## Status

- **State:** Active
- **Updated:** 2026-07-30
- **Scope:** How to use legacy App Inventor evidence during Flutter migration.

## Decision shift

This project no longer treats App Inventor UI as a pixel-perfect visual target.
The target UI system is native Flutter Cupertino.

## Preserve vs modernize

### Preserve (required)

- feature behavior and command semantics;
- screen flow/navigation intent;
- data contracts and file compatibility;
- visibility/state logic and mode switching behavior.

### Modernize (allowed by default)

- legacy visual recipes (colors/shadows/corners) into native Cupertino
  components;
- rigid legacy layout hacks when cleaner Cupertino layout keeps behavior;
- old non-native interaction surfaces where Cupertino has a direct equivalent.

### Workspace inspector presentation

- In landscape, retain the original 280 logical-pixel right-inspector width.
- The original `Workspace.scm` and runtime-created `Workspace.bky` right-panel
  tree are authoritative for the inspector's functional schema. Preserve every
  category, visible component type, parameter label, grouping, order, and
  visibility/state relationship. In particular, read-only App Inventor
  `Label` parameter displays must remain read-only display components and must
  not be recast as text inputs, buttons, dropdowns, or other control categories.
- Cupertino adapters may modernize how a preserved component category is
  painted, but may not change what 3D-design parameter the component represents
  or whether the user can edit it.
- Rectangular visual hierarchy is semantic rather than widget-tree-based:
  invisible visibility/animation/layout wrappers do not add nesting depth.
  Painted or interactively distinct surfaces progress from workspace level 0,
  through panel level 1 and group level 2, to leaf-control level 3.
- Each deeper surface blends an additional 8% black over the light base
  surface. Nested boundaries use a fixed 2px gap with radii 6px, 4px, and 2px
  for levels 1, 2, and 3 respectively. Fixed leaf controls at a common level
  are 50x50; responsive controls keep layout-owned widths and use 50px height.
- Inspector components may use translucent Cupertino hierarchy surfaces, but
  must not use opaque flat-color panel or icon-tile fills.
- Dropdown popups use the native surface and placement behavior of
  `CupertinoMenuAnchor`. The anchor-owned `CupertinoPopupSurface` must remain
  painted and use its native saturation plus backdrop-filter blur. Do not
  replace it with plain transparency or an opaque custom popup.
- Horizontally arranged control groups center their children vertically.
- Dropdowns use the shared `CupertinoMenuAnchor` adapter with
  `CupertinoMenuItem` rows, never a wheel picker or custom overlay.
- Standard component copy uses the shared 12-pixel semibold text style.
- All eight Wireframe/Transform function groups use the same shared
  inset-grouped inspector form, header, body, spacing, and surface treatment.
- The Input Data field behaves as a centered top-bar exclusion region: it
  remains centered at every width while surrounding commands yield when they
  fit and flow beyond its right edge when the left side is saturated.

## Evidence priority for implementation

1. Legacy behavior from `.bky` and recovered transcription docs.
2. Data/schema semantics from legacy files and parser docs.
3. Current active product direction in `codex_instructions.md`.
4. Native Cupertino conventions when behavior is unaffected.

## Documentation-first execution gate

Before writing implementation code for any new or changed behavior (especially
when diverging from legacy App Inventor architecture), update the related
Markdown records first:

- update `codex_instructions.md` if policy or workflow changes;
- update relevant `Auto-Transcription/*.md` or `docs/*.md` notes for behavior
  interpretation changes;
- then start implementation.

If no documentation update is needed, the task record must explicitly state why.

## Rule persistence

All active documented rules remain binding across tasks until a human explicitly
requests a modification. Silent drift from existing rules is not allowed.

## Deprecated principles (removed)

- exact-tree visual reproduction as a universal rule;
- mandatory hand-cloning of each legacy UIKIT primitive;
- screenshot-first UI decisions.

## Execution record

Use the execution record defined once in `codex_instructions.md`. Include any
intentional behavior change in its **Result** field.

## Validation baseline

- `flutter analyze` passes;
- targeted tests for changed behavior pass;
- production UI follows the component and adaptive-layout rules in
  `codex_instructions.md`.
