// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get aboutTooltip => '정보';

  @override
  String aboutVersion(String version, String build) {
    return '버전 $version (빌드 $build)';
  }

  @override
  String get aboutOpenSourceLicenses => '오픈소스 라이선스';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => '닫기';

  @override
  String aboutMenuItem(String appName) {
    return '$appName 정보';
  }

  @override
  String get themeMenuTooltip => '테마';

  @override
  String get themeSystem => '시스템 설정 따르기';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get languageMenuTooltip => '언어';

  @override
  String get languageSystem => '시스템 설정 따르기 / System';

  @override
  String get languageSystemShort => '시스템';

  @override
  String get aboutTagline => 'USB-to-Serial(COM) 포트용 무료 멀티탭 시리얼 터미널';

  @override
  String get aboutDescription =>
      'Windows·macOS·Linux 어디서나 쓸 수 있는 가볍고 무료인 시리얼 터미널을 목표로 만들었어요. CoolTerm은 오래되어 최신 OS에서 잘 돌지 않고, Termius는 시리얼 통신이 유료라서 직접 만들었어요.';

  @override
  String get aboutFeature1 => '시리얼 포트 자동 감지·핫플러그 새로고침, 보드레이트 지정';

  @override
  String get aboutFeature2 => '탭 기반 멀티 세션으로 여러 포트에 동시 접속';

  @override
  String get aboutFeature3 => 'ANSI 256색/트루컬러 터미널, 화살표·Ctrl 조합 입력';

  @override
  String get aboutFeature4 => 'Line Sender — 미리 써둔 여러 줄을 Enter로 한 줄씩 전송';

  @override
  String get aboutFeature5 => 'Hex View 토글, 탭별 Output 로깅';

  @override
  String get aboutFeature6 => '폰트·색상 테마·스크롤백 설정 저장';

  @override
  String get toolbarConnect => '연결';

  @override
  String get toolbarDisconnect => '연결 끊기';

  @override
  String get toolbarViewTerminal => '터미널';

  @override
  String get toolbarViewHex => 'Hex';

  @override
  String get toolbarHelp => '도움말';

  @override
  String get toolbarSettings => '터미널 설정';

  @override
  String get portHint => '포트';

  @override
  String get portRefresh => '포트 새로고침';

  @override
  String get baudHint => '보드레이트';

  @override
  String get baudInvalid => '양의 정수를 입력하세요';

  @override
  String get baudPresets => '흔한 보드레이트';

  @override
  String get tabNewSession => '새 세션';

  @override
  String tabNew(String shortcut) {
    return '새 탭 ($shortcut)';
  }

  @override
  String get statusConnected => '연결됨';

  @override
  String statusBytes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString바이트';
  }

  @override
  String statusLogging(String file) {
    return '기록 중 · $file';
  }

  @override
  String statusStartLogging(String shortcut) {
    return '기록 시작 ($shortcut)';
  }

  @override
  String statusStopLogging(String shortcut) {
    return '기록 정지 ($shortcut)';
  }

  @override
  String get statusNoLogFile => '기록된 로그 파일 없음';

  @override
  String get statusRevealLogFile => '기록 파일 위치 열기';

  @override
  String get statusCopyAll => '전체 복사';

  @override
  String statusClear(String shortcut) {
    return '화면 지우기 ($shortcut)';
  }

  @override
  String get logSaveConfirm => '기록 시작';

  @override
  String get errorUnknown => '알 수 없는 오류';

  @override
  String errorOpenFailed(String detail) {
    return '포트를 열 수 없어요: $detail';
  }

  @override
  String get errorNotConnected => '연결되어 있지 않아요';

  @override
  String get errorDeviceDisconnected => '기기와의 연결이 끊어졌어요. 케이블을 확인하고 다시 연결하세요.';

  @override
  String get senderHint => 'Enter: 커서 줄 전송 · Ctrl+Enter: 줄바꿈';

  @override
  String get senderLineEndingNone => '없음';

  @override
  String get senderEcho => 'Echo';

  @override
  String get senderEchoTooltip => '보낸 내용을 터미널 화면에도 표시';

  @override
  String get senderSend => '현재 줄 전송';

  @override
  String get settingsTitle => '터미널 설정';

  @override
  String get settingsFont => '폰트';

  @override
  String get settingsFontSize => '크기';

  @override
  String get settingsPalette => '색상 테마';

  @override
  String get settingsScrollback => '스크롤백 줄 수';

  @override
  String get settingsScrollbackHelper => '바꾸면 현재 화면 내용은 지워져요';

  @override
  String settingsScrollbackOption(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString줄';
  }

  @override
  String get paletteDefaultDark => '기본 (다크)';

  @override
  String get paletteWhiteOnBlack => '화이트 온 블랙';

  @override
  String get paletteGreenPhosphor => '그린 포스포';

  @override
  String get paletteLight => '라이트';

  @override
  String get helpTitle => '도움말';

  @override
  String get helpConnectTitle => '연결하기';

  @override
  String get helpConnectBody =>
      '포트를 고르고 보드레이트를 정한 뒤 연결을 누르세요. 포트 목록은 2초마다 새로고침돼서 케이블을 꽂거나 뽑으면 바로 반영돼요. 연결되면 프롬프트를 깨우려고 Enter를 한 번 자동으로 보내요.';

  @override
  String get helpTabsTitle => '탭';

  @override
  String get helpTabsBody =>
      '+ 버튼으로 새 세션(탭)을 열어 여러 포트에 동시에 접속할 수 있어요. 뒤에 있는 탭도 계속 데이터를 받고 기록해요. 마지막 탭은 닫을 수 없어요.';

  @override
  String get helpTypingTitle => '터미널에 직접 입력';

  @override
  String get helpTypingBody =>
      '터미널 화면을 클릭해 포커스를 준 뒤 바로 입력하세요. 화살표, Ctrl 조합, 백스페이스를 모두 쓸 수 있어요. 단, macOS에서는 라이브러리 한계로 한글 조합이 깨져요.';

  @override
  String get helpSenderTitle => 'Line Sender';

  @override
  String get helpSenderBody =>
      '여러 줄을 미리 써 두고 Enter로 커서가 있는 줄만 보내요. Ctrl+Enter는 줄바꿈이에요. 보낸 뒤 커서가 다음 줄 끝으로 가서, Enter를 계속 누르면 위에서부터 차례로 보내져요.';

  @override
  String get helpHexTitle => 'Hex View';

  @override
  String get helpHexBody =>
      '툴바의 터미널/Hex 전환 버튼으로 바꿔요. 실제로 받은 바이트를 그대로 hex dump로 보여줘요.';

  @override
  String get helpLoggingTitle => '기록';

  @override
  String helpLoggingBody(String shortcut) {
    return '● 버튼(또는 $shortcut)을 누르면 저장 위치와 파일 이름을 고르는 창이 떠요. 여러 탭이 동시에 각자 기록할 수 있어요.';
  }

  @override
  String get helpSettingsTitle => '폰트 / 색상 테마';

  @override
  String get helpSettingsBody =>
      '설정(⚙)에서 폰트, 크기, 터미널 색상 테마(Solarized, Dracula, Nord, Gruvbox 등), 스크롤백 줄 수를 바꿀 수 있어요. 다시 실행해도 유지돼요. 앱 전체의 라이트/다크와 언어는 탭 바 오른쪽 버튼에서 골라요.';

  @override
  String get helpShortcutsTitle => '단축키';

  @override
  String get shortcutNewTab => '새 탭';

  @override
  String get shortcutCloseTab => '현재 탭 닫기';

  @override
  String get shortcutToggleLogging => '기록 시작/정지';

  @override
  String get shortcutClear => '화면 지우기';
}
