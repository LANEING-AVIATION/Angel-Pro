# Cupertino UI Migration Guide (Native-Equivalent Mode)

## Status

- **State:** Reference
- **Updated:** 2026-07-30
- **Role:** Historical migration mapping. `codex_instructions.md` is normative.

## Primary rule

Use App Inventor artifacts to recover **what the UI does**, then implement that
intent with **native Cupertino components**.

## Implementation principles

1. Preserve behavior, command meaning, and user flow.
2. Prefer Cupertino-native controls over custom visual cloning.
3. Do not import Material widgets for production UI unless explicitly approved.
4. Keep icons on `CupertinoIcons` by default.
5. Keep legacy styling only when it conveys critical behavior/state that
   Cupertino cannot represent clearly.

## Suggested native mappings

| Legacy intent | Preferred Cupertino surface |
| --- | --- |
| confirmation/alert | `CupertinoAlertDialog` |
| contextual actions | `CupertinoContextMenu` / `CupertinoContextMenuAction` |
| mutually exclusive mode | `CupertinoSlidingSegmentedControl<T>` |
| value picker | `CupertinoPicker` |
| anchored menu/dropdown | `CupertinoMenuAnchor` + `CupertinoMenuItem` |
| text form row | `CupertinoFormRow` + `CupertinoTextField` |
| grouped inspector section | `CupertinoListSection.insetGrouped` |

## Deprecated migration assumptions

- “Rebuild every App Inventor UIKIT primitive exactly” is deprecated.
- “Visual parity first, behavior second” is deprecated.
- “Use screenshot look as spec” is deprecated.

## Agent output

Use the single execution protocol in `codex_instructions.md`.

When a task introduces a new behavior (especially one that diverges from legacy
App Inventor architecture), update the relevant Markdown notes first, then
implement code. Existing active rules remain binding unless a human explicitly
modifies them.

## Inspector mapping

The current inspector appearance, spacing ownership, and adaptive behavior are
defined once in `codex_instructions.md`. This file supplies component mappings
only.
