# Portside

릴리스·버전·패키징·정보 창·아이콘·라이선스·UI/UX·글꼴·언어·테마는
https://github.com/jejezz/application-release-templates/tree/main/conventions
규약을 따른다. 이 앱에 적용된 규약 버전: conventions-v1

규약과 다르게 정한 것 (이유는 DESIGN.md Phase 14):
- SeoulNamsan 300 굵기를 유지하고 텍스트 테마 전체를 w300으로 둔다.
- 터미널 색상 테마는 앱 테마와 별개로 `terminal_palette` 키에 저장한다.

- 화면 문구는 `lib/l10n/app_ko.arb`(기준)와 `app_en.arb`에 함께 추가하고 `flutter gen-l10n`을 실행한다.
- 색은 `Theme.of(context).colorScheme` 또는 `PortsideColors.of(context)`에서 읽는다. 위젯에 `Color(0x…)`를 직접 쓰지 않는다.
- `lib/about/about_dialog.dart`, `app_menu_bar.dart`, `lib/settings/app_settings.dart`, `settings_menus.dart`, `lib/theme/app_theme.dart`는 템플릿 사본이다. 고치지 말고 앱 쪽 파일(`portside_*.dart`, `tokens.dart`)에서 확장한다.

## Line Sender (편집기처럼 쓰기)

- 구성(위에서 아래로): 입력 칸 · 구분선 · **하단 줄**(높이 44). 하단 줄은 맨 왼쪽에 **이름 칩**(파일 이름·변경 여부, 이름은 최대 20자까지만 보이고
  넘으면 `…`), 이어서 파일 버튼 네 개(새로 만들기, 열기 Ctrl+O/⌘O, 저장 Ctrl+S, 다른 이름으로 저장 Ctrl+Shift+S — 앱의 `IconBadge` 36), 오른쪽 끝에 Echo 스위치 · 줄 끝
  문자 칩(탭하면 메뉴) · 전송 버튼이다. 입력 칸 옆에 열을 두지 않아서 폭·높이와 상관없이 하단 줄이 맨 아래에 같은 크기로 붙어 있다.
- 이름 칩은 `StatusPill`과 같은 알약 모양(옅은 색조 배경 + 윤곽선)이고 본문과 다른 강조색(`primary`)이다. 저장하지 않은 변경이 있으면 경고색이 된다.
- 파일 규칙(`lib/services/sender_file.dart`): UTF-8 텍스트만(BOM은 떼고, UTF-8이 아니면 거부), 2MB 초과 거부. 칸 안에서는 줄바꿈을 LF로 통일하고 저장할 때
  파일이 원래 쓰던 줄바꿈(CRLF 등)으로 돌려놓는다. 마지막 줄을 보내면 붙는 새 줄은 "변경됨"으로 치지 않는다.
- **홈 화면의 높이 배분**: 터미널과 LineSender 영역은 "남는 공간의 비율(flex)"로 나뉜다. LineSender가 잘리지 않으려면 비율의 하한을 창 높이에 맞춰 계산해야 해서
  `_SessionBody._minFraction`이 `LineSender.minHeight`(128) + 카드 여백·보더(26)를 지키는 비율을 구한다. 고정 요소 높이는 **넉넉한 추정치**(230)를 쓴다 —
  실제보다 작게 잡으면 최소 창(860×560)에서 하단이 넘친다(`test/home_sender_height_test.dart`가 확인). 툴바 등 고정 요소를 키우면 이 값을 함께 본다.
- TextField는 칸 전체를 I자 커서로 덮어서 안쪽 스크롤바 위에서도 커서가 안 바뀐다. 스크롤바가 있을 때만 오른쪽 가장자리 28px에 `PassThroughCursorRegion`(화살표 커서,
  마우스 이벤트는 통과)을 겹친다. `MouseRegion`은 이벤트를 막아서 스크롤바를 못 끌게 되므로 쓰지 않는다. 손잡이는 오른쪽 끝에서 13~20px 안쪽(측정).
- 테스트의 파일 선택창은 `FileSelectorPlatform.instance`를 가짜로 바꿔서 쓰고, 시리얼은 `test/helpers/fake_serial.dart`를 쓴다.
