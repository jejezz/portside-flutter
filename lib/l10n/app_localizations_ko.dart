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
}
