# Portside

Windows·macOS·Linux에서 쓰는 무료 USB-to-Serial(COM) 멀티탭 터미널. Flutter로 만들었다.

## 왜

OS를 가리지 않고 쓸 수 있는 가볍고 무료인 시리얼 터미널이 마땅치 않다. CoolTerm은 오래돼서 최신 macOS에서 더 이상 실행되지 않고, Termius는 시리얼 통신을 지원하지만 유료다. 그래서 직접 만들었다.

## 기능

- 시리얼 포트 자동 감지/새로고침, 보드레이트 지정
- **탭 기반 멀티 세션** — 여러 포트에 동시 접속
- 터미널 화면(`xterm2` 기반 — 한글 조합 제외한 IME, 256색/트루컬러 ANSI, 화살표·Ctrl 조합 지원)
- **Line Sender** — 여러 줄을 미리 써두고 Enter로 한 줄씩 순서대로 전송, Ctrl+Enter로 줄바꿈
- Hex View 토글
- Output 로깅 — 시작 시 저장 위치/파일명을 직접 지정, 단축키로 시작/정지
- 폰트/색상 테마(Solarized, Dracula, Nord, Gruvbox 등)·스크롤백 줄 수 설정, 재실행 후에도 유지
- 단축키

  | 동작 | macOS | Windows / Linux |
  |---|---|---|
  | 새 탭 | ⌘T | Ctrl+Shift+T |
  | 탭 닫기 | ⌘W | Ctrl+Shift+W |
  | 로깅 시작/정지 | ⌘⇧R | Ctrl+Shift+R |
  | 화면 지우기 | ⌘K | Ctrl+Shift+K |

  Windows/Linux에서 Shift를 함께 쓰는 건, 그냥 Ctrl+W/K/T가 시리얼 장치 쪽 셸의 제어 문자라서 그대로 장치에 보내야 하기 때문이다.

## 요구 사항

- Flutter (stable 채널)
- **macOS**: Xcode 전체 설치(Command Line Tools만으로는 안 됨), Homebrew `autoconf`/`automake`/`libtool`/`pkg-config` — `flutter_libserialport`가 CocoaPods로 `libserialport` C 라이브러리를 소스 빌드하는 데 필요
- **Windows**: Visual Studio("C++를 사용한 데스크톱 개발" 워크로드)
- **Linux**: `clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev` (Ubuntu 기준 `apt-get`으로 설치)

## 실행

```bash
flutter pub get
flutter run -d macos    # 또는 windows / linux
```

## 릴리스 만들기

`v` 로 시작하는 태그를 푸시하면 GitHub Actions(`.github/workflows/release.yml`)가 macOS DMG, Windows 인스톨러(`.exe`), Linux tarball(`.tar.gz`)을 각각 빌드해서 같은 GitHub Release에 올려준다.

```bash
git tag v0.1.0
git push origin v0.1.0
```

macOS DMG는 Developer ID로 서명하고 공증(notarize)까지 마친 뒤 올라가므로 Gatekeeper 경고 없이 바로 실행된다(필요한 인증서/자격 증명은 저장소 secrets에 등록되어 있다). Windows는 서명 인증서 없이 만들어서 SmartScreen이 "Windows에서 PC를 보호했습니다" 경고를 띄운다 — "추가 정보 → 실행"으로 넘어가면 된다. Linux tarball은 `portside/` 폴더를 그대로 담고 있으며, 압축을 풀고 `portside/portside`를 실행하면 된다(설치 없이 실행 가능한 형태라 배포판 패키지 관리자에는 등록되어 있지 않다).

Windows 인스톨러를 로컬에서 직접 빌드/테스트하고 싶을 때는 [docs/windows-installer.md](docs/windows-installer.md)를 참고한다.

## 알려진 한계

- 터미널 화면에 직접 타이핑할 때 한글 조합이 깨진다 — `xterm2`(정확히는 원조 `xterm.dart`)의 macOS 텍스트 입력 처리 버그. Line Sender 입력창은 일반 `TextField`라 영향 없음.

## 설계 문서

전체 설계 배경, 아키텍처, 각 기능을 만들며 겪은 문제와 해결 과정은 [DESIGN.md](DESIGN.md)에 있다.

## 라이선스

[MIT](LICENSE). 실제 시리얼 포트 접근은 `flutter_libserialport`가 동적으로 링크하는 [libserialport](https://sigrok.org/wiki/Libserialport)(LGPL v3)에 의존한다.
