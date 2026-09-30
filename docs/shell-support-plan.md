# Shell 세션 지원 확장 계획서

작성일: 2026-09-30 · 대상 버전: v0.2.0 → v0.3.0(안)

## 1. 목표

Portside는 지금 시리얼(USB-to-COM) 전용이다. 여기에 **로컬 Shell 세션**(macOS/Linux: zsh·bash, Windows: PowerShell·pwsh·cmd·Git Bash·WSL)을 같은 탭 UI에 추가한다.
Line Sender, 로깅(Recorder), Hex View, 테마, 다중 탭 등 기존 기능은 세션 종류와 무관하게 재사용한다.

비목표(이번 범위 아님): SSH/Telnet 세션(구조상 나중에 붙일 수 있게만 설계), 모바일/웹 지원, 분할 창, 세션 재생(Replay).

## 2. 현재 구조 분석

| 파일 | 역할 | Shell 확장에서의 문제 |
|---|---|---|
| `services/serial_service.dart` | libserialport 얇은 래퍼 (open/write/close) | 구체 타입으로 직접 참조됨 |
| `state/terminal_session_provider.dart` | 탭 1개의 연결 상태, 수신 버퍼, 로깅, xterm `Terminal` | 시리얼 가정이 곳곳에 박혀 있음 (아래) |
| `state/sessions_provider.dart` | 탭 목록/활성 탭 | `SerialService()`를 직접 생성 |
| `models/connection_settings.dart` | `portName`, `baudRate` | 시리얼 전용 모델 |
| `screens/home_screen.dart` | `PortSelector`, `BaudRateSelector`, 뷰 모드, Line Sender | 툴바가 시리얼 전제 |
| `widgets/line_sender.dart` | 줄 단위 전송 | `session.send()`에만 의존 → 재사용 가능 |
| `services/log_file_service.dart` | raw 바이트 파일 기록 | `suggestedFileName(port)`가 포트명 기반 |

`TerminalSessionProvider` 안의 시리얼 종속 지점:

1. 생성자가 `SerialService`를 구체 타입으로 받음.
2. `connect(ConnectionSettings)` — 포트/보드레이트만 받음.
3. `connect()` 끝에서 `\r\n`을 자동 전송(시리얼 콘솔 깨우기). PTY에서는 불필요하며 프롬프트가 중복될 수 있음.
4. `send()`가 줄바꿈 접미사를 붙이고 Local Echo로 화면에 직접 씀. PTY는 셸이 에코하므로 Local Echo는 꺼져 있어야 함.
5. 오류 모델이 `SerialServiceException`/`SerialErrorKind`(시리얼 전용).
6. `tabTitle`, `_pendingPort`, `_pendingBaudRate` — 포트 중심 상태.
7. 기본 `LineEnding.lf` — Windows PowerShell PTY에서는 Enter가 `\r`이어야 동작이 안정적.
8. `terminal.onResize`를 사용하지 않음 — PTY는 창 크기를 전달해야 함(시리얼에는 없는 새 경로).

## 3. 목표 구조

```
TerminalTransport (추상)
 ├─ SerialTransport   ← 기존 SerialService를 감쌈
 ├─ PtyTransport      ← 신규 (flutter_pty)
 └─ (향후) SshTransport, TelnetTransport
```

```dart
abstract class TerminalTransport {
  /// 연결을 열고 수신 스트림을 반환한다. 실패 시 TransportException.
  Stream<Uint8List> open();
  void write(Uint8List bytes);
  void resize(int columns, int rows); // 시리얼은 no-op
  Future<void> close();

  // 세션 종류별 기본 동작 — provider에 if (serial) 분기를 만들지 않기 위한 속성
  TransportKind get kind;            // serial | shell
  bool get wakeOnConnect;            // serial: true, shell: false
  bool get defaultLocalEcho;         // serial: true, shell: false
  LineEnding get defaultLineEnding;  // serial: lf, shell: cr
  String get displayName;            // 탭 제목 후보
}
```

- 오류는 `SerialServiceException` → `TransportException(kind, detail)`로 일반화한다. `TransportErrorKind`에 `openFailed`, `notOpen`, `io`, `disconnected`(장치 분리/셸 종료)를 두고, 셸 종료(exit code 포함)는 `disconnected`로 취급한다.
- 연결 설정은 sealed class로 나눈다.

```dart
sealed class ConnectionSettings {}
class SerialSettings extends ConnectionSettings { String portName; int baudRate; }
class ShellSettings  extends ConnectionSettings { String executable; List<String> args; String? cwd; }
```

- `TerminalSessionProvider`는 `TerminalTransport`만 알고, 세션 생성은 `SessionsProvider`(또는 팩토리)가 `ConnectionSettings`로부터 transport를 만든다.

## 4. 작업 단계

각 단계는 독립 PR(또는 커밋)로 나누고, 단계마다 `flutter analyze`와 `flutter test`가 통과해야 한다.

### 1단계 — 리팩터링 (동작 변화 없음)
- `TerminalTransport`, `TransportException` 정의.
- `SerialService` → `SerialTransport`로 이관(파일명·클래스명 변경, 로직 유지).
- `ConnectionSettings`를 sealed class로 변경, `SerialSettings` 추가.
- `TerminalSessionProvider`가 transport 주입을 받도록 변경. `wakeOnConnect`, `defaultLocalEcho`, `defaultLineEnding`을 transport 속성에서 읽음.
- `_errorText`(home_screen)와 l10n 오류 문구를 `TransportErrorKind` 기준으로 정리.
- **검증**: 시리얼 동작이 이전과 동일해야 한다. Fake transport로 provider 단위 테스트 추가(연결/수신/전송/오류/로깅).

### 2단계 — PtyTransport 추가
- 의존성 추가: `flutter_pty`. (macOS/Linux `forkpty`, Windows ConPTY)
- `PtyTransport`: 실행 파일/인자/cwd/환경 변수로 `Pty.start`. `TERM=xterm-256color`, `COLORTERM=truecolor` 설정.
- 수신은 `pty.output`을 그대로 `Stream<Uint8List>`로 전달. UTF-8 멀티바이트가 청크 경계에서 잘리는 문제를 막기 위해 provider의 `utf8.decode(chunk, allowMalformed: true)`를 **스트리밍 디코더(`Utf8Decoder` 청크 변환)**로 교체한다. (시리얼에도 이득)
- `pty.exitCode`를 구독해 셸 종료 시 `disconnected` 상태로 전환.
- `terminal.onResize` → `transport.resize`.
- 셸 종료 후 같은 탭에서 "다시 시작"할 수 있게 한다.

### 3단계 — 셸 탐색 및 세션 생성 UI
- `ShellDiscovery` 서비스: 실제로 존재하는 셸만 목록에 노출.
  - macOS/Linux: `/etc/shells` 파싱 + `$SHELL`을 기본값으로.
  - Windows: `powershell.exe`(System32), `pwsh.exe`(PATH/Program Files), `cmd.exe`, Git Bash(`Program Files\Git\bin\bash.exe`), `wsl.exe`(설치 시).
  - 크로스 플랫폼: PATH에 `pwsh`가 있으면 추가.
- 새 탭 연결 영역: 종류 선택(Serial / Shell). Shell이면 `ShellSelector`(셸 드롭다운 + 선택적 작업 폴더)를 보이고, Serial이면 기존 `PortSelector`/`BaudRateSelector`를 보인다.
- Shell 세션에서는 Hex View 토글, 보드레이트, Local Echo 스위치를 숨기거나 비활성화(Local Echo는 켜면 입력이 두 번 보이므로 Shell에서는 숨기는 것을 권장).
- 탭 제목: Shell은 셸 이름(`zsh`, `bash`, `PowerShell`), Serial은 기존대로 포트명. 탭에 종류 아이콘 표시.
- Shell은 "연결" 버튼 없이 선택 즉시 시작하는 방안과, 시리얼과 동일하게 연결 버튼을 두는 방안이 있다. → **연결 버튼 통일(기존 UX 유지)을 기본안으로 하고, 새 탭 생성 시 기본 셸로 자동 시작하는 옵션은 설정으로 둔다.**

### 4단계 — Recorder/Line Sender 보강
- 로그 파일명: 세션 종류에 맞는 이름(`zsh_20260930_120000.log`).
- 로그 형식 옵션 추가:
  - Raw (현재 방식, ANSI 포함)
  - Plain text (ANSI 제거) — raw 스트림 가공이 아니라 `terminal.buffer`의 확정된 줄을 기록하는 방식을 우선 검토(백스페이스/프롬프트 편집 때문에 단순 ANSI 제거는 결과가 지저분함).
  - 타임스탬프 접두 옵션(줄 단위).
- Line Sender: 세션 종류별 기본 줄바꿈 적용(Shell = CR). 줄 간 지연(ms) 옵션과 "프롬프트 대기 후 전송" 모드는 후속 과제로 분리.

### 5단계 — 다듬기와 배포
- l10n: `app_ko.arb`(기준)와 `app_en.arb`에 문구 추가 후 `flutter gen-l10n`. (CLAUDE.md 규약)
- 색상은 `PortsideColors`/`colorScheme`만 사용, 템플릿 사본 파일(`about_dialog`, `app_menu_bar`, `app_settings`, `settings_menus`, `app_theme`)은 수정하지 않고 `portside_*.dart`/`tokens.dart`에서 확장.
- README(ko/en) 소개 문구·스크린샷 갱신: "serial terminal" → "serial + shell terminal". 앱 이름/포지셔닝(CoolTerm 대안)을 유지할지 결정 필요.
- 플랫폼별 빌드 검증: Windows 설치 프로그램(`installer/`), macOS 서명/노타라이즈(아래 위험 참고), Linux.
- 버전 v0.3.0, 릴리스 규약(conventions-v1)에 따라 릴리스 노트 작성.

## 5. 테스트 계획

| 대상 | 방법 |
|---|---|
| provider 로직 | `FakeTransport`로 단위 테스트: 연결·수신·전송·오류·종료·로깅 |
| UTF-8 청크 경계 | 멀티바이트 문자를 임의 위치에서 쪼갠 입력으로 디코딩 검증 |
| 셸 탐색 | 파일시스템/환경을 주입 가능하게 만들어 플랫폼별 결과 검증 |
| 위젯 | 세션 종류 전환 시 툴바 요소 표시/숨김 |
| 수동 검증 (OS별) | zsh/bash/PowerShell 실행, `vim`·`htop`·`top`, 색상(`ls --color`), 창 크기 변경, 한글 입력(IME) 조합, 붙여넣기, `Ctrl+C`, `exit` 후 재시작, 대용량 출력(`yes \| head -n 1000000`) |
| 회귀 | 시리얼 세션(로깅, Hex View, Line Sender) 기존 동작 |

## 6. 위험과 대응

| 위험 | 영향 | 대응 |
|---|---|---|
| **macOS App Sandbox** | 샌드박스가 켜져 있으면 임의 셸 실행 불가 | `macos/Runner/*.entitlements`의 `com.apple.security.app-sandbox` 확인. Shell 지원 빌드는 샌드박스를 끄고 Developer ID + 노타라이즈로 직접 배포. App Store 배포는 포기하거나 Shell 기능을 분리 |
| 한글 IME / wide char | 입력·커서 위치 어긋남 | 2단계 직후 조기 검증. 이미 시리얼에서 xterm2로 IME를 다뤄 왔으므로 위험은 낮음 |
| Windows ConPTY 버전 | Windows 10 1809 미만 미지원 | 최소 지원 버전을 문서화 |
| `flutter_pty` 유지보수 | 업스트림 정체 시 버그 수정 지연 | 착수 전 pub.dev 최신 버전/이슈 확인. 문제가 있으면 포크 또는 `PtyTransport` 뒤에서 대체 구현(추상화 덕분에 교체 범위가 한 파일) |
| Shell 환경 변수/로그인 셸 | macOS 앱 실행 시 GUI 환경이라 PATH가 터미널과 다름 | macOS/Linux는 로그인 셸(`-l`)로 실행 옵션 제공 |
| 보안 인식 | 앱이 임의 프로세스를 실행함 | 실행 파일은 탐색된 목록 또는 사용자가 명시적으로 지정한 경로만 허용. 원격 입력으로 실행하지 않음 |
| 제품 범위 | "시리얼 터미널" 포지셔닝 희석 | 시리얼을 1급 기능으로 유지하고 Shell은 같은 워크플로(Line Sender, 로깅)를 로컬 셸에도 제공하는 것으로 설명 |

## 7. 결정이 필요한 항목

1. **앱 이름/포지셔닝**: Portside(항구 옆)를 유지할지, README의 "serial terminal" 설명을 어떻게 바꿀지.
2. **macOS 배포 방식**: 직접 배포(샌드박스 해제)로 확정 가능한지, App Store가 필요한지.
3. **Windows 셸 기본값**: PowerShell(내장 5.1)을 기본으로 할지, `pwsh`가 있으면 우선할지.
4. **Shell 세션 자동 시작**: 새 탭 생성 시 자동 시작 여부(기본값).
5. **Plain text 로그**: 4단계에 포함할지, 후속 릴리스로 미룰지.

## 8. 일정 추정 (1인 기준, 대략)

| 단계 | 규모 |
|---|---|
| 1단계 추상화 + 테스트 | 1~2일 |
| 2단계 PtyTransport | 1~2일 |
| 3단계 셸 탐색 + UI | 2~3일 |
| 4단계 Recorder/Line Sender | 1~2일 |
| 5단계 다듬기·OS별 검증·배포 | 2~3일 |

OS별 수동 검증(특히 macOS 노타라이즈, Windows 설치 프로그램)에서 일정이 늘어날 가능성이 가장 크다.
