# Build the distributable Windows release.
#
# `flutter build windows --release` already produces a self-contained folder
# (portside.exe, its DLLs — including flutter_libserialport's — and data\),
# so this is a thin wrapper rather than a bare one-liner: it gives
# docs/windows-installer.md a single named step to point at, and gives any
# future post-build step (bundling something extra, signing, etc.) an
# obvious place to land.

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$exeDir = Join-Path $root "build\windows\x64\runner\Release"

Push-Location $root
try {
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { throw "flutter build failed" }
} finally {
    Pop-Location
}

Write-Host ""
Write-Host "완료: $exeDir\portside.exe"
