# Workspace: Object Management (Edges, Loft Surfaces, Groups, Selection)

**Screen**: Workspace  
This document describes how 3D objects are organised, listed, selected, and manipulated in the Items panel.

---

## Data Model Summary

The project contains three types of geometry objects, all stored in global lists:

| Type         | Global Variable    | Data Structure                                                     |
|--------------|--------------------|--------------------------------------------------------------------|
| Edge         | `edgeList`         | List of dicts: `{name, points: [[x,y,z],...], layer, ...}`        |
| Loft Surface | `loftCollection`   | List of dicts: `{name, edges: [edgeIdx,...], group, uvs, ...}`    |
| Group        | (within each item) | Edges and lofts can be assigned a group index                      |

Selection state is tracked by:
- `selectionMode` (1=edge, 2=loft, 3=group)
- `selectedEdgeIndex`
- `selectedLoftIndex`

---

## Items Panel (`项目` / ItemsTab)

### Tab-Bar (mode selector)

Three buttons at the top of the Items panel switch between sub-views:

| Button           | Original Name    | Shows              |
|------------------|------------------|--------------------|
| `按钮_Select`    | SelectButton     | `边缘列表` (EdgeList) |
| `按钮_Connect`   | ConnectButton    | `放样` (LoftList)  |
| `按钮_Loft`      | LoftButton       | Loft creation mode |

Selecting a button sets the corresponding hidden checkbox (e.g., `复选框_Select.Checked = true`) and shows the appropriate sub-list.

---

## `结构刷新()` / refreshStructure()

Called after any change to `edgeList`, `loftCollection`, or group assignments. Rebuilds all three sub-lists from scratch.

### Rebuilding EdgeList

```
call EdgeList.ClearChildren()
for edge in edgeList:
    local row = EdgeList.CreateComponentInstance()     // VerticalArrangement, h=50
    row.Alignment = 5 (center)
    local iconLabel = row.CreateComponentInstance()    // Label, w=20, h=30
        icon.Text = "•"  (or shape indicator)
        icon.TextColor = white
        if not(SelectCheckbox.Checked):
            icon.SelfDelete()   // hide icon in non-select mode
    local nameLabel = row.CreateComponentInstance()    // Label, w=150
        nameLabel.Text = edge["name"]
        nameLabel.TextAlignment = center
    call registerItem([nameLabel, clickHandler], highlighted=true)
    call 灰色圆角(row)    // apply rounded-corner style
    call row.SetupEventHandler(longClickHandler)   // long-press for context menu
```

### Rebuilding LoftList

```
call LoftList.ClearChildren()
for loft in loftCollection:
    local row = LoftList.CreateComponentInstance()   // VerticalArrangement, h=55
    row.Alignment = left (4)
    call 灰色圆角(row)
    local indexLabel = row.CreateComponentInstance()  // Label, w=45, center
        indexLabel.Text = "▲"  (or index symbol)
        indexLabel.TextColor = white
        if not(MultiSelectCheckbox.Checked):
            indexLabel.SelfDelete()
    local edgeNameLabel = row.CreateComponentInstance()  // Label, h=30, w=50
        (shows name of first edge)
    local nameLabel = row.CreateComponentInstance()      // Label, w=fill
    call registerItem([nameLabel, clickHandler], highlighted=true)
    local previewBox = row.CreateComponentInstance()     // Image, 0×0
        (invisible — used for hit detection)
    call row.SetupEventHandler(touchHandler)
```

### Rebuilding GroupList

```
local groupContainer = GroupList.CreateComponentInstance()
call Flexbox1.Create(groupContainer)   // Flexbox for a grid layout
// iterate group members from loftCollection or edgeList where .group matches
// for each member, create a thumbnail cell in the Flexbox
```

---

## Selection Behaviour

### Edge Selection

Tapping an edge's name label in `EdgeList`:
1. Sets `selectedEdgeIndex` to the tapped edge's index.
2. Sets `selectionMode = 1`.
3. Highlights the selected row (changes background color).
4. Shows `按钮_复制` (CopyButton) and `按钮_删除` (DeleteButton) in the toolbar.
5. Opens the operation axis via `打开操作轴()`.
6. Sends a highlight command to Three.js to visually select the edge.

### Long-press on Edge

- Shows the context/action menu with additional operations (duplicate, merge, etc.).

### Loft Surface Selection

Tapping a loft row:
1. Sets `selectedLoftIndex` to the tapped loft's index.
2. Sets `selectionMode = 2`.
3. Updates texture/group spinners to reflect the selected loft's current material.
4. Opens the operation axis.

---

## `单项注册(item, isHighlighted)` / registerItem(item, highlighted)

A utility that registers a UI item (label + callback pair) into the `valueLabelRegistry`. When the item's associated value changes, its label is updated automatically. If `isHighlighted = true`, the item gets a highlight visual style.

---

## `按钮_复制.Click` / CopyButton tap

Duplicates the selected edge or loft surface:
1. Deep-copy the selected item from `edgeList` or `loftCollection`.
2. Append to the respective list.
3. Call `结构刷新()`.
4. Call `打下操作戳()` to push undo snapshot.
5. Call `TJS大世界自动刷新()` to refresh 3D view.

---

## `按钮_删除.Click` / DeleteButton tap

Deletes the selected edge/loft/group:
1. Populate `edgesToDelete` with the selected indices.
2. Show confirmation dialog: "Delete?" (via `信息对话框1`).
3. On confirm: remove from `edgeList` / `loftCollection`.
4. Call `结构刷新()`.
5. Call `打下操作戳()`.
6. Refresh Three.js.

---

## Loft Operations

### `按钮_Loft.Click` / LoftButton tap

Enters loft-creation mode. The user selects two edges to loft between:
1. Switch to LoftList view.
2. Prompt the user to select the first edge (`loftFirstItem = []`).
3. On first edge selection: store it in `loftFirstItem`.
4. Prompt for second edge selection.
5. On second selection: create a new loft surface dict linking both edges.
6. Append to `loftCollection`.
7. Call `结构刷新()`, `打下操作戳()`, refresh Three.js.

### `按钮_Edge.Click` / EdgeButton tap

Adds the currently selected edge as an edge boundary for the loft being created. Part of the multi-step loft workflow.

### `按钮_Group.Click` / GroupButton tap

Creates a new group from the `newGroupMembers` selection:
1. Assign the same group index to all selected edges/lofts in `newGroupMembers`.
2. Update `loftCollection` group assignments.
3. Call `结构刷新()`, `打下操作戳()`.

---

## Loft Append / Multi-select

### `追加放样集合` (loftAppendBuffer)

Used when building a complex loft from multiple edges:
- Each edge selection in multi-select mode is appended to `loftAppendBuffer`.
- When the user confirms, the buffer is committed as a new loft surface.

### `新放样第一项` (loftFirstItem)

Stores the first selected edge when beginning a new loft. Once a second edge is selected, the loft is created between these two.

---

## `按钮_Mid.Click` / MidButton tap

Snaps the currently selected point or edge midpoint to the midpoint between two selected edges. A snap/averaging operation that inserts a new edge at the geometric midpoint.

---

## Group Management (`成组` / GroupList)

Groups are visual containers in the Items panel. They use a `Flexbox` layout to show member thumbnails as a grid.

- Creating a group: select multiple edges/lofts → `按钮_Group.Click`.
- The group list is rebuilt by `结构刷新()` by iterating edges/lofts and bucketing them by their `group` property.
- Each group member shows as a small tile in the `Flexbox1` grid.

---

## `按钮_Import.Click` / ImportObjButton tap

Imports an external 3D model (OBJ/other format):
1. Opens `FilePicker` with the SPACEDESK directory as default.
2. On file selection: reads the file and parses it via `W64SPA转高速OBJ()` (a return function that converts from a 64-encoded spatial format to the internal OBJ dict format).
3. Merges the imported geometry into `edgeList`.
4. Refreshes structure and Three.js.

---

## `按钮_Unfold.Click` / UnfoldButton tap

Unfolds a group (flattens it, removing group membership and returning edges/lofts to the top level):
1. Iterate all edges/lofts in the selected group.
2. Set their group index to null/default.
3. Call `结构刷新()`.

---

## `目录管理器` / DirectoryManager

The horizontal breadcrumb/navigation bar at the top of the Items tab. Displays the current selection path (e.g., `Groups → MyGroup → Edge 3`). Tapping a breadcrumb navigates to that level.

---

## `边缘菜单` / EdgeModeMenu

The horizontal tab-bar inside the Items panel that controls which sub-list is shown. Switches between `EdgeList`, `LoftList`, and group view via the hidden checkboxes.

---

## Flutter Implementation Notes

- The Items panel is a dynamically built list. Use `ListView.builder` with a `key` per item to efficiently update when items are added/removed/reordered.
- Selection state should be held in a `SelectionManager` class exposed via `Provider`. Multiple parts of the UI (Items panel, toolbar, 3D viewport via JS) all react to selection changes.
- The **long-press context menu** for edges/lofts should use a `showMenu()` positioned at the touch point.
- The **Flexbox group grid** maps to Flutter's `Wrap` widget with a fixed item width.
- Edge rows use `灰色圆角` (grey rounded corners) — implement as a `Container` with `BoxDecoration(borderRadius: BorderRadius.circular(5), color: Colors.grey.shade700)`.
- The loft preview box (0×0, invisible) from the original is a hit-testing component — in Flutter this is handled transparently by the gesture system.
- **`registerItem`** should be replaced by a reactive pattern: the label widget observes the `ValueNotifier<String>` for its linked data field and rebuilds automatically.
- The copy/delete/undo cycle should always be: modify list → call `结构刷新()` equivalent → push to undo stack → send to Three.js.
