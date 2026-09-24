; Inno Setup script template for a Flutter Windows desktop app
; (jejezz/application-release-templates desktop/ @ conventions-v1).
;
; Run by .github/workflows/release.yml's `build-windows` job on every
; `vX.Y.Z` tag push, which passes MyAppName / MyFileName / MyAppVersion /
; MyAppNumericVersion / MyAppExeName via `ISCC /D...` (read from the tag,
; AppInfo.xcconfig and windows/CMakeLists.txt). The fallbacks below are only
; for a local, manual compile — MyAppVersion 0.0.0 marks such a build.
;
; Edit by hand, once per app:
;   1. AppId — a fresh GUID (PowerShell: `[guid]::NewGuid()`). Never reuse
;      another app's GUID, and never change it after the first release, or
;      Windows treats the next version as a different application (breaking
;      upgrade/uninstall). conventions/identity.md §5.
;   2. MyAppURL — this app's GitHub repository (conventions/identity.md §1).

#ifndef MyAppName
  #define MyAppName "Portside"
#endif
#ifndef MyFileName
  #define MyFileName "Portside"
#endif
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#ifndef MyAppNumericVersion
  #define MyAppNumericVersion "0.0.0"
#endif
#ifndef MyAppExeName
  #define MyAppExeName "portside.exe"
#endif
#define MyAppPublisher "Jongyun Ahn"
#define MyAppURL "https://github.com/jejezz/portside-flutter"
; The app's first release year — edit it for apps started after 2026.
#define MyFirstReleaseYear "2026"
#define SourceDir "..\..\build\windows\x64\runner\Release"

[Setup]
; Portside의 기존 GUID — 이미 릴리스했으므로 절대 바꾸지 않는다.
AppId={{A6109CAF-C188-40AA-A565-A3B330AE33F8}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
AppCopyright=Copyright (C) {#MyFirstReleaseYear} {#MyAppPublisher}
VersionInfoVersion={#MyAppNumericVersion}
VersionInfoProductName={#MyAppName}
VersionInfoCompany={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\..\dist
OutputBaseFilename={#MyFileName}-{#MyAppVersion}-windows-x64-setup
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
UninstallDisplayName={#MyAppName}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
; No license page: MIT apps have nothing to agree to (conventions/licensing.md §4).

[Languages]
; Installer text comes from Inno Setup's own translations — don't hardcode
; Korean (or English) strings below (conventions/packaging.md §3).
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[InstallDelete]
; 0.1.9 이하 설치 프로그램은 시작 메뉴에 "Portside" 폴더를 만들고 그 안에
; 바로가기를 뒀다. 새 바로가기는 {autoprograms} 바로 아래에 생기므로 옛
; 바로가기와 빈 폴더를 지운다 (conventions/packaging.md §3).
Type: files; Name: "{autoprograms}\{#MyAppName}\{#MyAppName}.lnk"
Type: dirifempty; Name: "{autoprograms}\{#MyAppName}"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
