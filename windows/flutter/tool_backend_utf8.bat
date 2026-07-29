@ECHO off
set "PATH=%SystemRoot%\System32;%SystemRoot%;%SystemRoot%\System32\WindowsPowerShell\v1.0;C:\Program Files\Git\cmd;%PATH%"
"%FLUTTER_ROOT%\bin\cache\dart-sdk\bin\dart.exe" "%~dp0tool_backend_windows.dart" %*
