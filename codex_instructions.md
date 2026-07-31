# Angel Pro Papercraft Designer

## Status

- **State:** Active
- **Updated:** 2026-07-30
- **Purpose:** Single source of truth for coding agents.

## Current UI Direction (authoritative)

1. Build UI with **native Flutter Cupertino** components.
2. Treat App Inventor sources as **behavior/reference evidence**, not a visual
   style contract.
3. Do **not** rebuild a custom App Inventor-style UI component library unless
   explicitly requested by a human task.

## Deprecated principles removed

The following old principles are no longer active:

- exact/pixel App Inventor visual cloning by default;
- mandatory recreation of legacy UIKIT recipes before using Cupertino-native
  controls;
- screenshot-style matching as a primary acceptance gate;
- date-specific migration freeze rules that were tied to already-completed
  audits.

## What to preserve from legacy sources

Use `Angel Papercraft Designer Ultimate2022/Auto-Transcription/` to preserve:

- feature behavior and command intent;
- workflow and operation order;
- data semantics and file compatibility.

When Cupertino UX and legacy visual style conflict, prioritize Cupertino unless
a human explicitly requests legacy appearance.

## Global engineering rules

- Use Cupertino (not Material) for production UI.
- **Documentation-before-implementation gate:** whenever an agent is asked to
  create or change behavior/architecture (especially when it differs from legacy
  App Inventor structure), the agent must first update the related Markdown
  notes, then implement code.
- Build from live `LayoutBuilder` constraints; do not scale the whole interface.
  Keep the viewport, renderer, paint overlay, and gesture layer in one shared
  content rectangle.
- Preserve a usable viewport at every window size. The inspector may be
  side-by-side only when the minimum viewport and inspector widths both fit;
  otherwise place it below the viewport or make it explicitly dismissible.
  Toolbars and inspectors must scroll on their primary axis when their content
  cannot fit. No production layout may depend on a `Row` or `Column` overflowing.
- Centralize layout values in `AngelCupertinoTokens`. A parent owns the outer
  padding for its child group; children own only their internal padding. Do not
  stack equivalent margins, padding, or spacer widgets at the same boundary.
- Rectangular UI surfaces use a context-aware visual hierarchy. Invisible,
  conditional, scrolling, and layout-only wrappers do not create a level; a
  painted container or distinct interactive group does. The workspace surface
  is level 0, inset panels are level 1, visually separated groups are level 2,
  and their leaf controls are level 3.
- Hierarchy fills are derived from the light base surface by alpha-blending an
  additional 8% black overlay for each deeper level. Text continues to use the
  centralized dark label tokens so every supported level remains readable.
- Distinct nested rectangles use a 2 logical-pixel boundary gap and concentric
  radii: level 1 is 6px, level 2 is 4px, and level 3 is 2px. Fixed-size leaf
  rectangles at the same level are 50x50 logical pixels. Controls whose width
  is owned by responsive layout flow retain their fluid width and use the
  shared 50px component height.
- Right-inspector roots must be transparent and grouped/control surfaces must
  avoid opaque, flat-color fills. Establish hierarchy with translucent native
  surfaces, separators, and state accents, without shadows or solid icon tiles.
  The landscape inspector keeps the original fixed 280 logical-pixel width
  instead of expanding with the window. Every inspector action presents a
  leading named `CupertinoIcons` icon and English text.
- Dropdown menus use the native surface and positioning supplied by
  `CupertinoMenuAnchor`. Their material is the native painted
  `CupertinoPopupSurface`: a translucent adaptive overlay backed by saturation
  and `BackdropFilter` blur, never plain unfiltered transparency or a custom
  opaque fill.
- Every horizontal group of UI components is vertically center-aligned.
- Every dropdown selector is implemented with `CupertinoMenuAnchor` and native
  `CupertinoMenuItem` entries; do not use wheel/scroll pickers or custom overlay
  dropdown implementations.
- The normal type style used by most component text is 12 logical pixels with
  semibold weight. Titles may use a larger purpose-specific token.
- The Strokes, Surface, Connection, Reference, Dragging, Transformation,
  Texture & Group, and Flip & Align panels share one reusable inset-grouped
  inspector-section form. They must not use separate Wireframe and Transform
  panel recipes.
- The App Inventor `Workspace.scm` tree and runtime `Workspace.bky` construction
  are authoritative for the right inspector's functional schema. Preserve its
  categories, component types, parameter labels, ordering, grouping, and
  visibility/state relationships. Native Cupertino painting may wrap or style
  those components, but must not turn a read-only parameter label into an input
  or otherwise change a component category that defines the 3D design process.
- The Input Data field is pinned to the geometric center of the entire top bar,
  independent of toolbar scrolling and sibling widths. At roomy widths the
  command flow reserves its centered footprint. When the left commands cannot
  fit before it, they may continue on its right side, but they must never move
  the field away from center.
- Use RGBA `#54739bff` as the immutable system-wide theme color, represented
  by Flutter as `Color(0xFF54739B)`. All primary actions, active controls,
  selected accents, focus/action text, and reusable UI adapters must consume
  the centralized theme token or its hue-preserving pressed/tint derivatives.
  Do not substitute Cupertino system blue, `#007AFF`, legacy `#0000FF`, or
  recovered UIKIT `#3A6999` as an alternative application accent.
- Keep app text and identifiers English-first (except narrow parser-compat
  tokens required for legacy file decoding).
- Keep Flutter compatibility at `3.44.8`.
- Keep offline runtime support for required WebView/assets.
- Keep direct startup into the main workspace (no legacy splash/file-manager
  flow).
- Keep `.SPA` open/association behavior and fallback sample loading.
- **Rule continuity:** all existing active rules remain in force by default.
  Agents may change or ignore an active rule only when a human explicitly asks
  for that rule modification.

## Agent execution protocol (automation-friendly)

For each task, produce and follow:

1. **Intent:** one-sentence objective.
2. **Inputs Used:** exact docs/files consumed.
3. **Docs Updated First:** list Markdown files updated before implementation and
   what changed.
4. **Behavior Contract:** what must remain true.
5. **Cupertino Mapping:** native components selected.
6. **Validation:** analyzer/tests/manual checks run.
7. **Result:** done/blocked and next action.

## Documentation authority order

1. `codex_instructions.md` (this file, active policy)
2. `docs/appinventor_layout_fidelity.md` (behavior-fidelity contract)
3. `Angel Papercraft Designer Ultimate2022/Auto-Transcription/*.md` (legacy
   reference evidence)
4. archived/history docs (informational, non-authoritative)

Inline imperative wording in a Reference or Archived document describes the
legacy source or historical recommendation; it cannot override an Active
document higher in this order.
