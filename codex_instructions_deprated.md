# Angel Pro Papercraft Designer
# This file is an instruction of the app.
# I am migrating a papercraft designer app from appinventor to flutter.
# "D:\Projects_Directory\Angel_Pro\Angel Papercraft Designer Ultimate2022" refers to the directory containing the unzipped appinventor project file
# an agent is working on this directory (github-copilot) to read the raw files. It extracts all valuable information to Markdown files in "Angel Papercraft Designer Ultimate2022/Auto-Transcription"
# the second agent is working on flutter code generation (OpenAI Codex) based on regulations provided below and in Markdown files provided by the former agent.
# this Markdown is written by human. Agents shouldn't edit it without approval, but they can read and provide suggestions.
# Automated workflow example:"your role:[codex code generator] read this instruction and decide what to do next." [this Markdown attached]

# The following rules are applied system-wide.
    use Cupertino style instead of material-design.
    when I am developing, a flutter debugging session (Windows) is launched. launching new session may not be required as you can implement the hot-reload feature of flutter.
    All API you implemented should be compitable with flutter 3.44.8
    Additional features in the legacy appinventor project are described in markdown files written in /Angel Papercraft Designer Ultimate2022/Auto-Transcription
    Some features should be modified in your current job. The major update is that the legacy version starts with a splash screen and file manager bug now you should navigate to main workspace directly.

# The following rules are applied in papercraft designer main app window.

# Following are missions to construct the app. Once a mission is marked [closed], you should pass it. If not, you should ensure the requirements are met.
# you should especially pay attention to lines marked [new] as they are new added prompts.
# I am building up the app step by step, so I may set up some goals halfway, this does not indicate that the feature will persist in the final release.
# You shouldn't introduce too much feature in the overall plan if they are not declared in texts below because working without human surveillance may lead to failure.
# refer to the Markdown doc first, decide the next feature to sync in flutter project, ask human for approval, add mission in the list below(done by human or approved by human), and start writing code.
[new] when the app starts, a 16:10 window should be open on a desktop deployment target, or a fullscreen activity on mobile platform.
[new] make D:\Projects_Directory\Angel_Pro\Sample_Data\Boeing_777.SPA a part of app assets. It is a JSON file.
[new] the interface should be empty
[new] insert a webview to the interface. it should load a three.js scene. all assets and dependencies should be stored inside the application so the app keeps functional even without Internet connection.
[new] the app should be registered as the editor of .SPA file. When the app is open without a valid file input, it should load Boeing_777.SPA