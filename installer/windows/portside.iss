; Inno Setup script for Portside.
;
; Run automatically by .github/workflows/release.yml's `windows` job on every
; `v*.*.*` tag push. For local, manual compiles see docs/windows-installer.md
; (build the release folder first, then compile this file with ISCC.exe).

#define MyAppName "Portside"
; CI passes the real version via `ISCC /DMyAppVersion=x.y.z` (see
; .github/workflows/release.yml); this default is only used for local,
; manual compiles per docs/windows-installer.md.
#ifndef MyAppVersion
  #define MyAppVersion "0.1.4"
#endif
#define MyAppExeName "portside.exe"
#define SourceDir "..\..\build\windows\x64\runner\Release"

[Setup]
; Fixed once and never changed — this is how Windows recognises upgrades of
; the same app across versions. Generate a new one only for a genuinely
; different application, e.g. via PowerShell: [guid]::NewGuid()
AppId={{A6109CAF-C188-40AA-A565-A3B330AE33F8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher=jyahn
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputDir=..\..\dist
OutputBaseFilename=PortsideSetup-{#MyAppVersion}
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
Compression=lzma2
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64compatible
DisableProgramGroupPage=yes
UninstallDisplayIcon={app}\{#MyAppExeName}

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "바탕화면에 바로가기 만들기"; GroupDescription: "추가 아이콘:"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "설치 후 바로 실행"; Flags: nowait postinstall skipifsilent
