# Angel Pro Papercraft Designer - Master Control Directive

## 1. Project Overview

* **Context:** We are migrating a high-performance 3D papercraft designer application ("Angel") from a legacy App Inventor architecture to a modern, robust Flutter multi-platform codebase.
* **Legacy Source Repository:** `D:\Projects_Directory\Angel_Pro\Angel Papercraft Designer Ultimate2022` contains the unzipped legacy source code.
* **Knowledge Base:** The upstream analysis phase by the human and the documentation agent (GitHub Copilot) is **fully completed**. All extracted architectural logic, variable definitions, and functional specifications are permanently stored as Markdown documentation inside:
  `D:\Projects_Directory\Angel_Pro\Angel Papercraft Designer Ultimate2022\Auto-Transcription\`
* **Current Agent Core Task:** OpenAI Codex operates exclusively as the **Senior Software Architect & Developer** inside the Flutter project (`D:\Projects_Directory\Angel_Pro\lib\main.dart`). Its mission is to fully ingest the `Auto-Transcription/` data and systematically write the Flutter production code.

---

## 2. Instructions by Developer
Here are things you should pay attention to which are not declared in the original project.
If a feature is already declared in knowledge base, it shouldn't appear in the list below. However, if something new is declared by human in chat, you should record here.

* **Design Language:** Strictly enforce **Cupertino style** primitives (iOS/macOS native look-and-feel) across all platforms instead of Material Design.
* **Target Version Compatibility:** All written code, widget structures, and API invocations must maintain strict native compatibility with **Flutter 3.44.8**.
* **Runtime Optimization:** A persistent Flutter debugging session (Windows Desktop target target) is continuously active. Maximize the utilization of Flutter's **stateful hot-reload** capabilities. Do not trigger full cold restarts unless explicitly required by breaking native modifications.
* **Architectural Modifications:** Completely bypass the legacy version's boot behavior (remove the legacy splash screen and bugged file manager). The application must immediately initialize and navigate straight into the primary workspace canvas.
* **Reference Documentation Integrity:** Treat every file inside `Angel Papercraft Designer Ultimate2022/Auto-Transcription/` as immutable reference material; never edit, rename, move, or delete those files.
* **Design Decision Log:** Record every approved change to the application design or to these operating rules explicitly in `codex_instructions.md` before or alongside its implementation.
* **Review Observability:** Temporary console diagnostics or temporary Cupertino UI components may be added when they materially help human verification; remove or clearly isolate them once their review purpose is complete.
* **Human Notification Threshold:** Notify the Human for verification only when the change effect can be checked exclusively through visual display or interaction. If Codex can verify the effect through command-line output, tests, analyzers, builds, logs, deterministic file inspection, or other machine-readable evidence, Codex must perform that verification itself, record the result, close the task, and continue without requesting Human confirmation.
* **Verification Labels and Trace:** Every roadmap task must carry exactly one `[human pass]` or `[auto pass]` label. For `[auto pass]` tasks, Codex must run the relevant checks, preserve a concise trace of their results in console output and the task implementation record, then close and continue automatically; for `[human pass]` tasks, Codex must still run and report all available machine checks before requesting only the remaining visual or interaction verification.

* **Native Window Geometry:** Configure the application desktop deployment target to initialize in an exact 16:10 aspect ratio window. For mobile deployment targets, configure it to run as a native fullscreen activity.
* **Local Asset Integration:** Bundle the sample file `D:\Projects_Directory\Angel_Pro\Sample_Data\Boeing_777.SPA` (a structured structural JSON schema) directly into the native Flutter application bundle assets. Properly register this path within `pubspec.yaml`.
* **Base Interface State:** Ensure the primary initialization layout presents an entirely empty Cupertino UI canvas layout workspace, completely clean of legacy menus.
* **Offline Webview & Graphics Engine Bridge:** Embed an optimized Webview layer into the empty workspace canvas. The Webview must load a localized Three.js graphics rendering engine context. All Webview source assets, dependencies, and script libraries must reside locally within the offline application file package to ensure total application utility without an internet connection.
* **OS File Association Handler:** Register the application within the target desktop operating system registry as the primary default editor handler for files containing the `.SPA` suffix extension. Implement routing logic at application launch:
    * If the application intent payload contains a valid target `.SPA` filepath string, parse and initialize that file structure.
    * If the application is opened raw without command-line parameter arguments or intent vectors, fall back to automatically parsing and rendering `Boeing_777.SPA` out of the bundled application assets.

---

## 3. Agent Coding Workflow
Strict Micro-Task Execution Loop (Dynamic Breakout)
To prevent out-of-order execution, out-of-scope feature creep, or compounding logical errors, Codex **MUST** strictly adhere to the following execution loop:

1. **Step 1 [Initialization & Planning]:** Read the high-level `[new]` requirements under Section 4. Cross-reference them with the complete technical breakdowns in the `Auto-Transcription/` directory. Sub-divide these requirements into a granular, atomic task sequence (10–15 micro-tasks) sorted strictly by compilation and dependency order. Populate these under Section 5 (`## 5. Implementation Roadmap & Milestones`).
2. **Step 2 [Active Coding]:** Codex selects the single highest-priority task marked `[Active: Awaiting Dev]`. Change its status to `[Active: In Progress]` and write the implementation.
3. **Step 3 [Verification Classification]:** Once the micro-task compiles, classify its acceptance evidence as either machine-verifiable (tests, analyzer/build output, deterministic file or console inspection) or human-verifiable (visual display quality or interaction behavior that Codex cannot inspect directly).
4. **Step 4 [Machine-Verifiable Advancement]:** When all required machine-verifiable checks pass and Codex can inspect their output directly, record the evidence, mark the task `[Closed]`, promote the next sequential task, and continue automatically without requesting human review.
5. **Step 5 [Human Review Handoff]:** When acceptance depends on visual display or human interaction, freeze development, mark the task `[Pending Human Review: Verify X Effect]`, and output exactly two concise sentences: what changed, then precisely what the Human should inspect or do.
6. **Step 6 [Visual Gatekeeping]:** Do not proceed beyond a human-verifiable task until the Human approves it or provides explicit validation; machine-verifiable tasks do not require this pause.

---

## 4. Implementation Roadmap & Milestones
*The tasks below are ordered by compilation and runtime dependency. Exactly one task may be developed and reviewed at a time.*

* **[human pass] [Closed] Task 0.1:** Replace the prototype entry widget with a minimal, directly launched `CupertinoApp` workspace shell containing only a full-window empty canvas; confirm that no splash, file-manager, Material widget, toolbar, menu, or legacy route is reachable.
  * **Implementation record:** The active Dart entry point now launches only the light, system-background `WorkspaceCanvas`; the original black surface was rejected during human review because it appeared indistinguishable from a failed render. Prototype WebView/startup-document code, its temporary dependency, and its temporary asset registrations were removed until their dedicated roadmap tasks. Windows debug compilation is stabilized through a project-local Flutter backend wrapper that restores the required system/Git PATH and tolerates localized subprocess output, and the existing shell-association code now includes its required Windows Shell header.
* **[auto pass] [Closed] Task 0.2:** Create the production Flutter asset hierarchy for the bundled sample project and offline web runtime, copy `Boeing_777.SPA` plus the required legacy Three.js library files into it, and register only those local paths in `pubspec.yaml`.
  * **Implementation record:** Added the bundled sample at `assets/documents/samples/Boeing_777.SPA` and consolidated byte-identical legacy production copies of `three.min.js` and `OBJLoader.js` under `assets/web/vendor/`. Registered only those three exact paths in `pubspec.yaml`; SHA-256 source/copy checks match, `flutter analyze` passes, and a debug Flutter asset bundle contains all three files. Archive-derived read-only attributes are cleared from the production asset copies so repeated Windows `flutter_assemble` runs can overwrite generated bundle files.
* **[auto pass] [Closed] Task 0.3:** Introduce strongly typed SPA document models for the five legacy JSON slots (`titleSegment`, `edgeList`, reserved slot, `imageList`, and `loftCollection`) while preserving unknown nested fields for lossless compatibility.
  * **Implementation record:** Added a lossless `SpaDocument` domain model with dedicated title, edge, reserved, image, and loft slot types. The title supports both legacy text and object variants, the reserved slot retains arbitrary real-world payloads, and every record preserves unknown nested JSON fields; Flutter analysis passes and focused five-slot reconstruction tests pass.
* **[auto pass] [Closed] Task 0.4:** Implement and unit-test the SPA decoder/validator against bundled `Boeing_777.SPA`, including malformed JSON, missing-slot, invalid-path, and strict case-insensitive `.SPA` suffix rejection cases.
  * **Implementation record:** Added typed SPA format errors, strict filename-suffix validation with case-insensitive `.SPA` acceptance, five-slot validation, and decoding for both documented object records and real positional-array records. The bundled 18 MB Boeing document decodes successfully as 4 edge groups, 10 image records, and 15 loft records; analyzer and all nine model/decoder tests pass.
* **[auto pass] [Closed] Task 0.5:** Implement a platform-neutral startup document resolver that accepts one validated external `.SPA` launch path and otherwise loads `Boeing_777.SPA` from the Flutter asset bundle.
  * **Implementation record:** Added a UI-independent startup resolver with injected text readers plus a Flutter adapter for external files and asset bundles. It validates an explicitly supplied external path without silently falling back, otherwise loads the bundled Boeing sample; analyzer and all three source-selection tests pass against the real asset.
* **[human pass] [Closed] Task 0.6:** Add a local offline HTML viewport document and verify that it boots the bundled Three.js runtime with no HTTP, CDN, remote font, or other network dependency.
  * **Implementation record:** Added `assets/web/runtime/index.html` with a local-only CSP, bundled Three.js reference, hardware-preferred WebGL renderer, resize handling, and deterministic `window.__angelRuntime`/`angel-three-ready` readiness contracts. Static offline/readiness tests pass, the Flutter bundle includes the page, and direct JavaScript execution confirms bundled Three.js revision 130; because no controllable browser was available, a temporary review-only status badge reports green WebGL readiness or a red renderer error for human verification.
* **[human pass] [Closed] Task 0.7:** Embed one hardware-accelerated `flutter_inappwebview` viewport as the sole child of the Cupertino workspace canvas, with context menus, native zoom chrome, overscroll, and safe-area gaps disabled.
  * **Implementation record:** Added `flutter_inappwebview` 6.1.5 and its Windows WebView2 implementation, then replaced the empty workspace child with one expanded local-asset `InAppWebView`. Hardware acceleration and JavaScript are enabled while network loads, context menus, native zoom controls/gestures, overscroll, scrollbars, link previews, and automatic content insets are disabled. Analyzer passes, all 14 tests pass, the Windows debug binary builds, and the relaunched console reports `ready: true`, `renderer: webgl`, and `threeRevision: 130` from the packaged `flutter_assets` page. Human screenshot review confirms edge-to-edge client-area fill, the green offline WebGL-ready badge, and no visible native browser chrome, scrollbar, safe-area gap, or error surface.
* **[auto pass] [Active: Awaiting Dev] Task 0.8:** Implement the Dart-to-JavaScript bridge readiness handshake and serialized command gate so SPA scene commands cannot run before the offline Three.js page reports ready.
* **[auto pass] [Queued] Task 0.9:** Convert decoded SPA edge and loft data into the renderer payload expected by the legacy Three.js coordinate conventions, retaining the documented Y/Z axis mapping and source indices.
* **[human pass] [Queued] Task 0.10:** Render the resolved startup document in the offline viewport and add deterministic fit-to-model camera framing, resize handling, lighting, and an empty-scene fallback for valid projects without geometry.
* **[human pass] [Queued] Task 0.11:** Configure Windows desktop startup geometry to an exact 16:10 client-area size and validate resize/aspect behavior; this native runner change requires a controlled debugger restart rather than hot reload.
* **[human pass] [Queued] Task 0.12:** Configure Android and iOS as native fullscreen activities while preserving WebView hardware acceleration and platform lifecycle behavior; validate each platform configuration independently.
* **[human pass] [Queued] Task 0.13:** Register `.SPA` open-with metadata for Windows and mobile platform manifests, route the delivered file intent/command-line path into the startup resolver, and verify both external-file launch and bundled-sample fallback end to end; native association testing requires a controlled reinstall/restart.

***

## 6. Human Quick-Reply Cheat Sheet
*Human User: Copy-paste these exact strings into the IntelliJ chat window to interface smoothly with Codex.*

### Command: Initiate Planning Mode
> **Human:** "Your role: [Codex Senior Architect & Developer]. Read my instructions file `codex_instructions.md` and deep-dive into the technical specifications inside `Angel Papercraft Designer Ultimate2022/Auto-Transcription/`. Execute Step 1 of the Micro-Task Execution Loop: Break down the high-level goals into a granular list of 10-15 sequential micro-tasks under Section 5. Mark the first one as `[Active: Awaiting Dev]` and the rest as `[Queued]`. Do not write code yet. Present the roadmap for review."

### Command: Task Approval & Execution Greenlight
> **Human:** "The implementation plan looks solid. Proceed with the current active micro-task. Keep a tight focus on the scope of this individual item, leverage hot-reload, and halt immediately once it is complete for my review."

### Command: Review Passed (Advance Pipeline)
> **Human:** "Review passed. The current task is officially verified and marked `[Closed]`. Promote the next sequential task in the roadmap queue to `[Active: Awaiting Dev]` and begin development immediately."

### Command: Review Failed (Iterate and Fix)
> **Human:** "The implementation has a defect. Look at the running instance: [INSERT TEXT DESCRIBING BUG OR VISUAL MISMATCH HERE]. Keep the current task status as `[Active: In Progress]`, debug the issue within this current module scope, hot-reload, and notify me for verification once resolved."
