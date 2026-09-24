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
