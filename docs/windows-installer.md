# Windows 인스톨러 만들기

`scripts/build-app-windows.ps1`은 `build\windows\x64\runner\Release\`에 실행 파일 폴더를 만들 뿐, 더블클릭 한 번으로 설치되는 인스톨러(`setup.exe`)는 만들지 않는다. 그 폴더를 실제 배포용 인스톨러로 패키징하는 절차를 정리한 것이 이 문서다.

`v`로 시작하는 태그를 푸시하면 `.github/workflows/release.yml`의 `build-windows` 잡이 이 절차(빌드 → Inno Setup 컴파일)를 그대로 CI에서 실행하고, macOS/Linux 빌드까지 모두 성공하면 마지막 `release` 잡이 한 번에 모아서 같은 태그의 GitHub 릴리즈에 올린다 — 새 버전을 낼 때 로컬에서 아래 단계를 직접 따라갈 필요는 없다. 이 문서는 인스톨러를 로컬에서 빌드해 배포 전에 미리 테스트하고 싶을 때, 또는 CI 없이 수동으로 릴리즈해야 할 때를 위한 절차다.

**빌드 스크립트와 인스톨러 스크립트는 이미 저장소에 있다.** 새로 만들 필요 없이, 아래 파일을 그대로 쓴다.

| 파일 | 용도 |
|---|---|
| [`scripts/build-app-windows.ps1`](../scripts/build-app-windows.ps1) | `flutter build windows --release` 실행 |
| [`installer/windows/portside.iss`](../installer/windows/portside.iss) | Inno Setup 스크립트 — `PortsideSetup-<version>.exe` 생성 |

서명 인증서 없이(ad-hoc) 만들므로, macOS의 Gatekeeper처럼 Windows SmartScreen이 처음 실행 시 "Windows에서 PC를 보호했습니다" 경고를 띄운다. "추가 정보 → 실행"으로 넘어갈 수 있다 — macOS 릴리즈가 공증 없이 배포되는 것과 같은 사정이다.

**검증 상태**: 아래 0~4단계(빌드 → Inno Setup 컴파일 → `/VERYSILENT` 설치 → 실행 → 언인스톨러로 제거)를 이 저장소의 릴리즈 빌드로 실제로 확인함 (2026-09-19).

## 0. 먼저 릴리즈 빌드를 만든다

```powershell
.\scripts\build-app-windows.ps1
```

`build\windows\x64\runner\Release\`에 `portside.exe`, `flutter_windows.dll`, `serialport.dll`, 플러그인 DLL들, `data\`가 갖춰진 상태가 되어야 한다. 인스톨러는 이 폴더 전체를 그대로 담는다.

## 1. Inno Setup 준비

[Inno Setup](https://jrsoftware.org/isdl.php)을 설치한다 (무료).

```powershell
winget install JRSoftware.InnoSetup
```

## 2. 버전 맞추기

CI(`.github/workflows/release.yml`)는 태그 이름(예: `v0.1.4` → `0.1.4`)을 `ISCC /DMyAppVersion=...`로 넘겨서 버전을 자동으로 맞춘다. 로컬에서 수동으로 컴파일할 때만 [`installer/windows/portside.iss`](../installer/windows/portside.iss) 맨 위의 기본값 `MyAppVersion`을 `pubspec.yaml`의 `version:`(빌드 번호 `+N`은 뺀 `major.minor.patch`만)과 맞춰서 바꾼다. 예: `version: 0.1.4+14` → `MyAppVersion "0.1.4"`.

`AppId`(고유 GUID)는 그 안에 이미 고정되어 있다 — 앱을 갈아엎는 게 아니라면 절대 바꾸지 않는다. 바꾸면 Windows가 이전 버전과 다른 앱으로 인식해서, 제어판 "프로그램 추가/제거"에서 업그레이드/제거가 깨진다.

## 3. 컴파일

```powershell
& "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe" installer\windows\portside.iss
```

`dist\PortsideSetup-<version>.exe`가 만들어진다. (특정 버전을 강제하려면 CI처럼 `/DMyAppVersion=0.1.4`를 덧붙인다.)

## 4. 설치 테스트

더블클릭해서 마법사가 정상적으로 뜨는지 확인한다. 사람 손 안 대고 빠르게 확인하려면:

```powershell
.\dist\PortsideSetup-0.1.4.exe /VERYSILENT /DIR="$env:TEMP\portside-test-install"
& "$env:TEMP\portside-test-install\portside.exe"
```

앱이 뜨고 포트 목록이 정상적으로 뜨는지 확인한 뒤, 테스트 설치 폴더는 지운다.

## GitHub 릴리즈에 올리기

태그를 푸시하면 CI가 알아서 올려주므로, 보통은 이 섹션을 직접 따라갈 필요가 없다. CI 없이 수동으로 올려야 할 때만 아래 절차를 쓴다.

**GitHub CLI로 (권장 — 설치돼 있지 않으면 `winget install GitHub.cli`)**

이미 그 태그의 릴리즈가 있다면(예: CI의 `release` 잡이 macOS/Linux까지는 만들어 놓은 상태):

```powershell
gh release upload v0.1.4 dist\PortsideSetup-0.1.4.exe
```

아직 릴리즈 자체가 없다면 (Windows만 먼저 낼 때):

```powershell
gh release create v0.1.4 dist\PortsideSetup-0.1.4.exe --title v0.1.4 --draft
```

`--draft`를 빼면 바로 공개된다. 초안으로 만들었다면 GitHub 웹에서 내용을 확인한 뒤 "Publish release"를 누른다.

체크섬도 같이 올려두면 좋다:

```powershell
Get-FileHash dist\PortsideSetup-0.1.4.exe -Algorithm SHA256 |
    ForEach-Object { "$($_.Hash.ToLower())  $(Split-Path $_.Path -Leaf)" } |
    Out-File -Append dist\SHA256SUMS -Encoding ascii
gh release upload v0.1.4 dist\SHA256SUMS --clobber
```

**GitHub 웹 UI로 (gh 설치 없이)**

1. https://github.com/jejezz/portside-flutter/releases 에서 해당 태그의 릴리즈를 연다 (없으면 "Draft a new release").
2. "Attach binaries" 영역에 `dist\PortsideSetup-0.1.4.exe`를 드래그 앤 드롭.
3. 초안이면 "Publish release".

## 배포 노트에 적어둘 것

Windows 릴리즈 노트(또는 GitHub Actions가 `--generate-notes`로 만든 노트에 `gh release edit <tag> --notes-file ...`로 덧붙이는 식)에 SmartScreen 경고가 뜬다는 것과 "추가 정보 → 실행"으로 넘어가면 된다는 것을 적어두면 좋다 — 처음 쓰는 사람이 "고장났다"고 오해하기 쉬운 지점이다.

## 참고: 진짜 `.msi`가 필요하다면

Group Policy/Intune 같은 기업 배포 도구가 `.msi`를 요구하는 특별한 사정이 아니라면 위 Inno Setup으로 충분하다. `.msi`가 꼭 필요해지면 [WiX Toolset](https://wixtoolset.org/)을 쓸 수 있는데, v6부터 생긴 "Open Source Maintenance Fee" EULA에 동의해야 빌드가 되니(`wix eula accept wix7` 또는 `wix build ... -acceptEula wix7`) 먼저 [wixtoolset.org/osmf](https://wixtoolset.org/osmf/)에서 라이선스/비용 조건을 직접 확인하고 동의 여부를 판단한다 — 이 저장소에는 아직 검증된 `.wxs`가 없다.
