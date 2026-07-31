# Markdown Status Registry

## Status

- **State:** Active
- **Updated:** 2026-07-30
- **Goal:** Help AI agents select authoritative docs automatically.

## Authority matrix

| Scope | Path pattern | Status | Agent usage |
| --- | --- | --- | --- |
| Active engineering policy | `codex_instructions.md` | Active | Always read first |
| Behavior-fidelity contract | `docs/appinventor_layout_fidelity.md` | Active | Read for migration guardrails |
| Legacy source analysis | `Angel Papercraft Designer Ultimate2022/Auto-Transcription/*.md` | Reference | Use for behavior/data evidence |
| Legacy transcription prompt | `Angel Papercraft Designer Ultimate2022/prompt.md` | Archived | Do not treat as coding policy |
| iOS LaunchImage note | `ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md` | Reference | iOS asset context only |
| Project bootstrap README | `README.md` | Reference | General project info |

## Removed deprecated record

- `codex_instructions_deprated.md` was removed to avoid policy conflicts.

## Conflict resolution

- Status in this registry applies to the entire matching path. A heading such
  as “Active” inside a Reference transcription records legacy source state; it
  does not promote that file to engineering policy.
- Normative words in Reference or Archived files (`must`, `should`, `never`)
  are evidence about the source system unless an Active document adopts them.
- When current Cupertino/layout direction conflicts with legacy visual advice,
  `codex_instructions.md` wins. Behavior and data compatibility remain binding
  through `docs/appinventor_layout_fidelity.md`.

## Change-control requirement for agents

- Before implementing a new behavior/architecture change, agents must update the
  related authoritative Markdown notes first, then take coding action.
- This is mandatory when the new behavior differs from legacy App Inventor
  architecture or prior migration assumptions.
- Previously declared Active rules continue to apply unless a human explicitly
  requests modification.

## Agent document loading order

1. `codex_instructions.md`
2. `docs/appinventor_layout_fidelity.md`
3. relevant `Auto-Transcription/*.md` modules for the current task
4. optional reference docs (`README.md`, iOS asset notes)
