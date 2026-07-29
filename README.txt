# ==============================================================================
# AI VIBE CODING PROMPT SYSTEM - LEGACY MIGRATION CONFIGURATION
# ==============================================================================
# PROJECT_NAME: Angel Papercraft Design Editor
# TARGET_PLATFORM: Flutter (Cross-Platform)
# ROLE: Expert Flutter Developer & Legacy Migration Specialist
# TASK: Migrate an App Inventor / WxBit project to a modern Flutter application
# ==============================================================================

Flutter_required(VERSION 3.44.0) # Target Flutter SDK 3.44.x Requirement
project(AngelMigration LANGUAGES Dart)
set(CURRENT_WORKING_INTERFACE "Workspace") 
set(CURRENT_TARGET_PLATFORM "Android")
# now skip making Screen1 and RecentFiles screen as they are just the splash screen and file manager.
# currently you are not required to adapt the app to non-Android targets.

# ------------------------------------------------------------------------------
# GLOBAL POLICIES & CONSTRAINTS
# ------------------------------------------------------------------------------
# [POLICY] Strict English Localization: Translate all Chinese text to English upon extraction.
# [POLICY] Pure Cupertino UI Strategy: BANNED: Material Design components. Use Cupertino or Custom Painters only.
# [POLICY] Architecture Paradigm: Declarative Widget Trees, clean state management, responsive separation.
set(GLOBAL_UI_THEME "Cupertino")
set(LOCALIZATION_LANG "EN_US")

# ------------------------------------------------------------------------------
# SOURCE & DESTINATION DIRECTORY CONFIGURATION (ENVIRONMENT)
# ------------------------------------------------------------------------------
set(MIT_REFERENCE_DIR "${SOURCE_DIR}/MIT_reference") # CRITICAL: STRICTLY READ-ONLY
set(FLUTTER_TARGET_LIB_DIR "${BINARY_DIR}/lib")      # TARGET: GENERATED Dart CODE HERE
set(FLUTTER_TARGET_ASSET_DIR "${BINARY_DIR}/assets") # TARGET: VISUAL ASSETS RESIDE HERE

# ------------------------------------------------------------------------------
# APPLICATION SYSTEM MODULES (SCREEN TOPOLOGY)
# ------------------------------------------------------------------------------
# Original App Layout: 3 Screens Total
# - Screen1: Splash Screen
# - RecentFiles: File Manager UI
# - Workspace: Core Papercraft Design Editor (MAIN DEVELOPMENT TARGET)
# Note: Screen1 and RecentFiles exist solely to provide a .SPA file directory context.

set(SCREEN_MODULES Workspace RecentFiles Screen1)

# CRITICAL EXECUTION ORDER: Prioritize Workspace compilation to ensure consistency
list(INSERT SCREEN_MODULES 0 Workspace)
list(REMOVE_DUPLICATES SCREEN_MODULES)

# ------------------------------------------------------------------------------
# DEVELOPMENT / DEBUG BLOCK CONFIGURATION
# ------------------------------------------------------------------------------
# In-dev stage mock file data pipeline
set(DEBUG_SPA_FILE_MOCK "D:/Projects_Directory/Angel_Pro/Flutter_Proj/Sample_Data/Boeing_777.SPA")
# This sample papercraft project has been uploaded to /storage/emulated/0/SPACEDESK/Boeing_777.SPA
# NOTE: The .SPA file utilizes serialized JSON format architecture.
# In development process the app only load this aircraft project sample, while in the delivered version the file directory should be assigned by the user.

# ==============================================================================
# STEP-BY-STEP EXECUTION PIPELINE (INSTRUCTIONS)
# ==============================================================================

# STEP 1: ASSET PIPELINE & RELOCATION REGISTRATION
macro(execute_asset_relocation)
message(STATUS "Scanning ${MIT_REFERENCE_DIR} for internal visual assets (e.g., An225.PNG, Backpic.png)...")
message(STATUS "Copying assets into target asset pool: ${FLUTTER_TARGET_ASSET_DIR}...")
message(STATUS "Appending new asset paths automatically to root 'pubspec.yaml' configuration matrix...")
endmacro()

# STEP 2: PARSING & STRUCTURAL ANATOMY ANALYSIS
macro(analyze_source_hierarchy)
message(STATUS "Parsing App Inventor structural definitions (`.scm` / JSON layout files) in ${MIT_REFERENCE_DIR}...")
message(STATUS "Reconstructing UI Component Tree Hierarchy...")
endmacro()

# STEP 3: DART TRANSCOMPILATION & COMPONENT GENERATION
macro(generate_flutter_source)
foreach(MODULE IN LISTS SCREEN_MODULES)
message(STATUS "Generating clean production-ready modular codebase for module: ${MODULE} inside ${FLUTTER_TARGET_LIB_DIR}...")
endforeach()
endmacro()

# ==============================================================================
# MAPPING COMPILER RULES: APP INVENTOR INTERNALS -> FLUTTER CODEBASE
# ==============================================================================

# RULE 1: DIMENSIONAL TRANSFORMATION RULES (Negative Magic Layout Mapping)
# Formulaic implementation mapping values for Width & Height properties
function(map_dimensional_property IN_VALUE OUT_FLUTTER_CODE)
if(IN_VALUE EQUAL -1)
# Magic -1: Auto Responsive Mode
set(${OUT_FLUTTER_CODE} "/* Unconstrained size / Intrinsic Layout determined by child component */" PARENT_SCOPE)
elseif(IN_VALUE EQUAL -2)
# Magic -2: Fill Parent Mode
set(${OUT_FLUTTER_CODE} "double.infinity /* or wrap inside Expanded() / Flexible() if nested in flex axis */" PARENT_SCOPE)
elseif(IN_VALUE LESS -1000)
# Magic < -1000: Percentage Layout Logic. Formula: Percentage = abs(Value + 1000)
# E.g., "-1050" -> |-1050 + 1000| = 50% -> FractionallySizedBox(widthFactor: 0.5) / MediaQuery dynamic sizing
set(${OUT_FLUTTER_CODE} "FractionallySizedBox(factor: abs(${IN_VALUE} + 1000) / 100.0) /* Or dynamic calculation via MediaQuery.of(context).size */" PARENT_SCOPE)
else()
# Positive value: Standard Absolute Pixel Dimensions
set(${OUT_FLUTTER_CODE} "width/height: ${IN_VALUE}.0" PARENT_SCOPE)
endif()
endfunction()

# RULE 2: SPATIAL ALIGNMENT ALGEBRA MATRIX
# Horizontal Axis Grid Mapping Rules: 1 = Left, 2 = Right, 3 = Center
# Vertical Axis Grid Mapping Rules:   1 = Top, 2 = Center/Middle, 3 = Bottom
# Composite Layout index grid matching (3x3 grid centered around 5):
# E.g., "Alignment" Index = 5 -> Alignment.center
# E.g., "Alignment" Index = 4 -> Alignment.centerLeft
macro(map_alignment_matrix INDEX OUT_ALIGNMENT)
# Math abstraction notation for AI parser:
# 5 -> Alignment.center
# Other indexes mapped according to standard 3x3 layout alignment coordinate block.
endmacro()

# RULE 3: CHROMATIC DECODING SUBSYSTEM (ARGB Color Conversions)
# 1. Hex Engine Tokens: Formats prefixed with `&H` map directly to standard hex notations by substituting with `0x`.
#    Example: `&HFF54739B` -> `Color(0xFF54739B)`
# 2. Decimal Complement Engine: Signed 32-bit Negative Integers evaluated through bitwise masking array.
#    Formula notation: Color(value & 0xFFFFFFFF)
#    Example: `-11242597` -> Evaluates directly to `Color(0xFF54739B)`
# 3. Fallback Engine: Null entries / "Default 0" -> Maps directly to `Colors.transparent` or fallbacks to implicit Cupertino themes.
macro(decode_color_token TOKEN OUT_FLUTTER_COLOR)
# Bitwise masking and hex matching rules are applied here during translation phase.
endmacro()

# RULE 4: TYPOGRAPHIC TRANSCRIPTION ENGINE
# - Bold/Italic Tokens: `fontBold: "True"` / `fontItalic: "True"` -> `FontWeight.bold` / `FontStyle.italic`.
# - Rich Text HTML Framework: If `htmlFormat: true`, standard Text blocks are BANNED.
#   Must transpile to `RichText` / `TextSpan` or third-party safe parsers to compile tokens like `<b>`, `<i>`.
macro(transcribe_typography TRADITIONAL_PROPERTIES OUT_TEXT_WIDGET)
# Enforces custom text styling architecture over basic text widgets.
endmacro()

# ==============================================================================
# PIPELINE INVOCATION TRACE
# ==============================================================================
message(STATUS "Initializing Vibe Coding Compiler Pipelines...")
execute_asset_relocation()
analyze_source_hierarchy()
generate_flutter_source()
message(STATUS "Compilation target pipeline fully configured. Awaiting workspace generation.")