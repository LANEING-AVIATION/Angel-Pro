# Icon System: Legacy Evidence to CupertinoIcons

This document records how to interpret the original icon system and the only
permitted Flutter migration strategy.

## Legacy source system

The App Inventor projects use `ICONFONTforANGELIII.otf`. Glyphs are mapped to
Latin letters or private-use characters and assigned at runtime by UIKIT
procedures. Some SCM buttons also use bitmap command images such as
`UNDO.PNG`, `STORAGEW.PNG`, `OUTW.PNG`, `DOCK.PNG`, and `TRASH.PNG`.

These artifacts are authoritative evidence for:

- whether the source node is an icon-bearing leaf;
- the command or mode associated with the leaf;
- whether the surrounding button text is retained;
- the source node's size, order, state, and UIKIT procedure.

They are not permitted Flutter rendering assets.

## Why literal font/bitmap migration is rejected

The legacy font has inconsistent glyph bearings, requires per-glyph space
hacks, prevents reliable English icon-and-text labels, and has undocumented
private-use mappings. Bitmap command icons do not scale consistently and would
mix visual systems. Custom painters and replacement SVG packs would introduce
another icon system not requested by the product rule.

## Required Flutter rule

Every production icon leaf must use a named constant from Flutter's
`CupertinoIcons` API.

Forbidden:

- registering or rendering `ICONFONTforANGELIII.otf`;
- registering any replacement/custom icon font;
- raw `IconData(...)` construction;
- bitmap assets used as command icons;
- SVG command-icon assets;
- Material `Icons`;
- `CustomPainter` or hand-drawn icon substitutes.

Non-icon source imagery remains allowed: workspace backgrounds, reference
images, textures/liveries, photographs, and content thumbnails.

## Leaf-only substitution discipline

Icon migration changes only the leaf:

1. Find the source component in `.scm`.
2. Find every `.bky` call affecting it.
3. Determine the command from the component name, click handler, state binding,
   and UIKIT call. Never infer meaning from the letter code alone.
4. Select the closest semantic `CupertinoIcons` constant.
5. Preserve the source parent, sibling order, width/height, margin,
   background, shadow, radius, selected state, and animation.
6. Add an English semantics label based on the recovered command.

A different-looking Cupertino symbol is acceptable when the legacy glyph is
forbidden; a different container or interaction is not.

## Recovered UIKIT icon behavior

### Classic button

`UIKIT建立经典按钮` keeps an existing English text label. Only an empty
icon-bearing source leaf receives a Cupertino icon. The surrounding source
recipe remains `#7E7E7E21`, radius 5, elevation 1, white content, margin 5,
and 100/400 ms press feedback.

### Checkbox-bound toggle

`UIKIT建立复选框` may combine an icon and state text. The icon becomes a
Cupertino icon beside ordinary English text. Active state is blue/white;
inactive state is white/black.

### Function group

`UIKIT建立功能组` creates an icon label beside the runtime section name and
switch. Use a 20-point Cupertino icon without changing the 250 x 50 header or
moving its controlled body.

### Function manager

`UIKIT建立函数管理器` uses icon/text items over a moving selection pad. The
replacement icon stays dark. Inactive items have no tile; the selected item has
the source white 40 x 40, radius-9, elevation-6 pad moving over 600 ms.

## Workspace semantic mapping

This table is based on component behavior recovered from `Workspace.scm` and
`Workspace.bky`, not on isolated glyph-letter guesses.

| Source meaning | Cupertino icon |
| --- | --- |
| Undo | `CupertinoIcons.arrow_uturn_left` |
| Save | `CupertinoIcons.archivebox` |
| Rotate view | `CupertinoIcons.rotate_right` |
| Pan view | `CupertinoIcons.move` |
| Transform object | `CupertinoIcons.perspective` |
| Copy | `CupertinoIcons.doc_on_doc` |
| Delete | `CupertinoIcons.trash` |
| Accelerate/advance | `CupertinoIcons.forward_end_alt` |
| Export/share | `CupertinoIcons.share` |
| Dock/grid | `CupertinoIcons.square_grid_3x2` |
| Wireframe/strokes | `CupertinoIcons.scribble` |
| Transform manager | `CupertinoIcons.move` |
| Items/layers | `CupertinoIcons.square_stack_3d_up` |
| Surface | `CupertinoIcons.square_grid_3x2` |
| Connection | `CupertinoIcons.link` |
| Reference image | `CupertinoIcons.photo` |
| Transformation data | `CupertinoIcons.perspective` |
| Flip and align | `CupertinoIcons.arrow_left_right` |
| Texture and group | `CupertinoIcons.layers` |

X, Y, and Z are source text identifiers, not icons.
Source buttons with retained English text such as `Circle` and `Line` likewise
remain text buttons even when their initialization call carries a legacy
glyph-code argument.

## Legacy letter-code inventory

Workspace blocks contain codes including `D`, `V`, `F`, `T`, `bb`, `W`, `O`,
`P`, `L`, `Y`, `h`, `i`, `G`, `E`, `M`, `S`, `X`, `N`, `I`, and `a`.
The same code can appear in different contexts and does not establish one
global meaning. Preserve this inventory for source tracing only.

RecentFiles and other screens must be audited through their own component
names and event handlers before selecting Cupertino constants. Do not copy a
Workspace mapping solely because the raw letter matches.

## Spacing and sizing

Do not reproduce font-bearing space hacks. Center the Cupertino `Icon` within
the exact decoded source control. Use the source UIKIT font size as the initial
icon size (commonly 20) and adjust only through a documented platform adapter,
not per-glyph arbitrary spaces.

## Mechanical acceptance

For each migrated screen, verify:

- all icon-bearing source nodes have an English semantics label;
- every production icon value originates from `CupertinoIcons`;
- no command bitmap is registered in `pubspec.yaml`;
- no custom font family is registered;
- no raw `IconData(...)`, Material icon, SVG command asset, or custom icon
  painter exists;
- background/reference/content imagery is not incorrectly rejected as an icon;
- surrounding UIKIT containers and selection behavior still match SCM/BKY.

The canonical layout/evidence discipline is
`docs/appinventor_layout_fidelity.md`.
