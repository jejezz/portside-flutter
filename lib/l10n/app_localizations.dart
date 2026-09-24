import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @aboutTooltip.
  ///
  /// In ko, this message translates to:
  /// **'정보'**
  String get aboutTooltip;

  /// No description provided for @aboutVersion.
  ///
  /// In ko, this message translates to:
  /// **'버전 {version} (빌드 {build})'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutOpenSourceLicenses.
  ///
  /// In ko, this message translates to:
  /// **'오픈소스 라이선스'**
  String get aboutOpenSourceLicenses;

  /// No description provided for @aboutRepository.
  ///
  /// In ko, this message translates to:
  /// **'GitHub'**
  String get aboutRepository;

  /// No description provided for @commonClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// No description provided for @aboutMenuItem.
  ///
  /// In ko, this message translates to:
  /// **'{appName} 정보'**
  String aboutMenuItem(String appName);

  /// No description provided for @themeMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'테마'**
  String get themeMenuTooltip;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @languageMenuTooltip.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get languageMenuTooltip;

  /// No description provided for @languageSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템 설정 따르기 / System'**
  String get languageSystem;

  /// No description provided for @languageSystemShort.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get languageSystemShort;

  /// No description provided for @aboutTagline.
  ///
  /// In ko, this message translates to:
  /// **'USB-to-Serial(COM) 포트용 무료 멀티탭 시리얼 터미널'**
  String get aboutTagline;

  /// No description provided for @aboutDescription.
  ///
  /// In ko, this message translates to:
  /// **'Windows·macOS·Linux 어디서나 쓸 수 있는 가볍고 무료인 시리얼 터미널을 목표로 만들었어요. CoolTerm은 오래되어 최신 OS에서 잘 돌지 않고, Termius는 시리얼 통신이 유료라서 직접 만들었어요.'**
  String get aboutDescription;

  /// No description provided for @aboutFeature1.
  ///
  /// In ko, this message translates to:
  /// **'시리얼 포트 자동 감지·핫플러그 새로고침, 보드레이트 지정'**
  String get aboutFeature1;

  /// No description provided for @aboutFeature2.
  ///
  /// In ko, this message translates to:
  /// **'탭 기반 멀티 세션으로 여러 포트에 동시 접속'**
  String get aboutFeature2;

  /// No description provided for @aboutFeature3.
  ///
  /// In ko, this message translates to:
  /// **'ANSI 256색/트루컬러 터미널, 화살표·Ctrl 조합 입력'**
  String get aboutFeature3;

  /// No description provided for @aboutFeature4.
  ///
  /// In ko, this message translates to:
  /// **'Line Sender — 미리 써둔 여러 줄을 Enter로 한 줄씩 전송'**
  String get aboutFeature4;

  /// No description provided for @aboutFeature5.
  ///
  /// In ko, this message translates to:
  /// **'Hex View 토글, 탭별 Output 로깅'**
  String get aboutFeature5;

  /// No description provided for @aboutFeature6.
  ///
  /// In ko, this message translates to:
  /// **'폰트·색상 테마·스크롤백 설정 저장'**
  String get aboutFeature6;

  /// No description provided for @toolbarConnect.
  ///
  /// In ko, this message translates to:
  /// **'연결'**
  String get toolbarConnect;

  /// No description provided for @toolbarDisconnect.
  ///
  /// In ko, this message translates to:
  /// **'연결 끊기'**
  String get toolbarDisconnect;

  /// No description provided for @toolbarViewTerminal.
  ///
  /// In ko, this message translates to:
  /// **'터미널'**
  String get toolbarViewTerminal;

  /// No description provided for @toolbarViewHex.
  ///
  /// In ko, this message translates to:
  /// **'Hex'**
  String get toolbarViewHex;

  /// No description provided for @toolbarHelp.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get toolbarHelp;

  /// No description provided for @toolbarSettings.
  ///
  /// In ko, this message translates to:
  /// **'터미널 설정'**
  String get toolbarSettings;

  /// No description provided for @portHint.
  ///
  /// In ko, this message translates to:
  /// **'포트'**
  String get portHint;

  /// No description provided for @portRefresh.
  ///
  /// In ko, this message translates to:
  /// **'포트 새로고침'**
  String get portRefresh;

  /// No description provided for @baudHint.
  ///
  /// In ko, this message translates to:
  /// **'보드레이트'**
  String get baudHint;

  /// No description provided for @baudInvalid.
  ///
  /// In ko, this message translates to:
  /// **'양의 정수를 입력하세요'**
  String get baudInvalid;

  /// No description provided for @baudPresets.
  ///
  /// In ko, this message translates to:
  /// **'흔한 보드레이트'**
  String get baudPresets;

  /// No description provided for @tabNewSession.
  ///
  /// In ko, this message translates to:
  /// **'새 세션'**
  String get tabNewSession;

  /// No description provided for @tabNew.
  ///
  /// In ko, this message translates to:
  /// **'새 탭 ({shortcut})'**
  String tabNew(String shortcut);

  /// No description provided for @statusConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결됨'**
  String get statusConnected;

  /// No description provided for @statusBytes.
  ///
  /// In ko, this message translates to:
  /// **'{count}바이트'**
  String statusBytes(int count);

  /// No description provided for @statusLogging.
  ///
  /// In ko, this message translates to:
  /// **'기록 중 · {file}'**
  String statusLogging(String file);

  /// No description provided for @statusStartLogging.
  ///
  /// In ko, this message translates to:
  /// **'기록 시작 ({shortcut})'**
  String statusStartLogging(String shortcut);

  /// No description provided for @statusStopLogging.
  ///
  /// In ko, this message translates to:
  /// **'기록 정지 ({shortcut})'**
  String statusStopLogging(String shortcut);

  /// No description provided for @statusNoLogFile.
  ///
  /// In ko, this message translates to:
  /// **'기록된 로그 파일 없음'**
  String get statusNoLogFile;

  /// No description provided for @statusRevealLogFile.
  ///
  /// In ko, this message translates to:
  /// **'기록 파일 위치 열기'**
  String get statusRevealLogFile;

  /// No description provided for @statusCopyAll.
  ///
  /// In ko, this message translates to:
  /// **'전체 복사'**
  String get statusCopyAll;

  /// No description provided for @statusClear.
  ///
  /// In ko, this message translates to:
  /// **'화면 지우기 ({shortcut})'**
  String statusClear(String shortcut);

  /// No description provided for @logSaveConfirm.
  ///
  /// In ko, this message translates to:
  /// **'기록 시작'**
  String get logSaveConfirm;

  /// No description provided for @errorUnknown.
  ///
  /// In ko, this message translates to:
  /// **'알 수 없는 오류'**
  String get errorUnknown;

  /// No description provided for @errorOpenFailed.
  ///
  /// In ko, this message translates to:
  /// **'포트를 열 수 없어요: {detail}'**
  String errorOpenFailed(String detail);

  /// No description provided for @errorNotConnected.
  ///
  /// In ko, this message translates to:
  /// **'연결되어 있지 않아요'**
  String get errorNotConnected;

  /// No description provided for @errorDeviceDisconnected.
  ///
  /// In ko, this message translates to:
  /// **'기기와의 연결이 끊어졌어요. 케이블을 확인하고 다시 연결하세요.'**
  String get errorDeviceDisconnected;

  /// No description provided for @senderHint.
  ///
  /// In ko, this message translates to:
  /// **'Enter: 커서 줄 전송 · Ctrl+Enter: 줄바꿈'**
  String get senderHint;

  /// No description provided for @senderLineEndingNone.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get senderLineEndingNone;

  /// No description provided for @senderEcho.
  ///
  /// In ko, this message translates to:
  /// **'Echo'**
  String get senderEcho;

  /// No description provided for @senderEchoTooltip.
  ///
  /// In ko, this message translates to:
  /// **'보낸 내용을 터미널 화면에도 표시'**
  String get senderEchoTooltip;

  /// No description provided for @senderSend.
  ///
  /// In ko, this message translates to:
  /// **'현재 줄 전송'**
  String get senderSend;

  /// No description provided for @settingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'터미널 설정'**
  String get settingsTitle;

  /// No description provided for @settingsFont.
  ///
  /// In ko, this message translates to:
  /// **'폰트'**
  String get settingsFont;

  /// No description provided for @settingsFontSize.
  ///
  /// In ko, this message translates to:
  /// **'크기'**
  String get settingsFontSize;

  /// No description provided for @settingsPalette.
  ///
  /// In ko, this message translates to:
  /// **'색상 테마'**
  String get settingsPalette;

  /// No description provided for @settingsScrollback.
  ///
  /// In ko, this message translates to:
  /// **'스크롤백 줄 수'**
  String get settingsScrollback;

  /// No description provided for @settingsScrollbackHelper.
  ///
  /// In ko, this message translates to:
  /// **'바꾸면 현재 화면 내용은 지워져요'**
  String get settingsScrollbackHelper;

  /// No description provided for @settingsScrollbackOption.
  ///
  /// In ko, this message translates to:
  /// **'{count}줄'**
  String settingsScrollbackOption(int count);

  /// No description provided for @paletteDefaultDark.
  ///
  /// In ko, this message translates to:
  /// **'기본 (다크)'**
  String get paletteDefaultDark;

  /// No description provided for @paletteWhiteOnBlack.
  ///
  /// In ko, this message translates to:
  /// **'화이트 온 블랙'**
  String get paletteWhiteOnBlack;

  /// No description provided for @paletteGreenPhosphor.
  ///
  /// In ko, this message translates to:
  /// **'그린 포스포'**
  String get paletteGreenPhosphor;

  /// No description provided for @paletteLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get paletteLight;

  /// No description provided for @helpTitle.
  ///
  /// In ko, this message translates to:
  /// **'도움말'**
  String get helpTitle;

  /// No description provided for @helpConnectTitle.
  ///
  /// In ko, this message translates to:
  /// **'연결하기'**
  String get helpConnectTitle;

  /// No description provided for @helpConnectBody.
  ///
  /// In ko, this message translates to:
  /// **'포트를 고르고 보드레이트를 정한 뒤 연결을 누르세요. 포트 목록은 2초마다 새로고침돼서 케이블을 꽂거나 뽑으면 바로 반영돼요. 연결되면 프롬프트를 깨우려고 Enter를 한 번 자동으로 보내요.'**
  String get helpConnectBody;

  /// No description provided for @helpTabsTitle.
  ///
  /// In ko, this message translates to:
  /// **'탭'**
  String get helpTabsTitle;

  /// No description provided for @helpTabsBody.
  ///
  /// In ko, this message translates to:
  /// **'+ 버튼으로 새 세션(탭)을 열어 여러 포트에 동시에 접속할 수 있어요. 뒤에 있는 탭도 계속 데이터를 받고 기록해요. 마지막 탭은 닫을 수 없어요.'**
  String get helpTabsBody;

  /// No description provided for @helpTypingTitle.
  ///
  /// In ko, this message translates to:
  /// **'터미널에 직접 입력'**
  String get helpTypingTitle;

  /// No description provided for @helpTypingBody.
  ///
  /// In ko, this message translates to:
  /// **'터미널 화면을 클릭해 포커스를 준 뒤 바로 입력하세요. 화살표, Ctrl 조합, 백스페이스를 모두 쓸 수 있어요. 단, macOS에서는 라이브러리 한계로 한글 조합이 깨져요.'**
  String get helpTypingBody;

  /// No description provided for @helpSenderTitle.
  ///
  /// In ko, this message translates to:
  /// **'Line Sender'**
  String get helpSenderTitle;

  /// No description provided for @helpSenderBody.
  ///
  /// In ko, this message translates to:
  /// **'여러 줄을 미리 써 두고 Enter로 커서가 있는 줄만 보내요. Ctrl+Enter는 줄바꿈이에요. 보낸 뒤 커서가 다음 줄 끝으로 가서, Enter를 계속 누르면 위에서부터 차례로 보내져요.'**
  String get helpSenderBody;

  /// No description provided for @helpHexTitle.
  ///
  /// In ko, this message translates to:
  /// **'Hex View'**
  String get helpHexTitle;

  /// No description provided for @helpHexBody.
  ///
  /// In ko, this message translates to:
  /// **'툴바의 터미널/Hex 전환 버튼으로 바꿔요. 실제로 받은 바이트를 그대로 hex dump로 보여줘요.'**
  String get helpHexBody;

  /// No description provided for @helpLoggingTitle.
  ///
  /// In ko, this message translates to:
  /// **'기록'**
  String get helpLoggingTitle;

  /// No description provided for @helpLoggingBody.
  ///
  /// In ko, this message translates to:
  /// **'● 버튼(또는 {shortcut})을 누르면 저장 위치와 파일 이름을 고르는 창이 떠요. 여러 탭이 동시에 각자 기록할 수 있어요.'**
  String helpLoggingBody(String shortcut);

  /// No description provided for @helpSettingsTitle.
  ///
  /// In ko, this message translates to:
  /// **'폰트 / 색상 테마'**
  String get helpSettingsTitle;

  /// No description provided for @helpSettingsBody.
  ///
  /// In ko, this message translates to:
  /// **'설정(⚙)에서 폰트, 크기, 터미널 색상 테마(Solarized, Dracula, Nord, Gruvbox 등), 스크롤백 줄 수를 바꿀 수 있어요. 다시 실행해도 유지돼요. 앱 전체의 라이트/다크와 언어는 탭 바 오른쪽 버튼에서 골라요.'**
  String get helpSettingsBody;

  /// No description provided for @helpShortcutsTitle.
  ///
  /// In ko, this message translates to:
  /// **'단축키'**
  String get helpShortcutsTitle;

  /// No description provided for @shortcutNewTab.
  ///
  /// In ko, this message translates to:
  /// **'새 탭'**
  String get shortcutNewTab;

  /// No description provided for @shortcutCloseTab.
  ///
  /// In ko, this message translates to:
  /// **'현재 탭 닫기'**
  String get shortcutCloseTab;

  /// No description provided for @shortcutToggleLogging.
  ///
  /// In ko, this message translates to:
  /// **'기록 시작/정지'**
  String get shortcutToggleLogging;

  /// No description provided for @shortcutClear.
  ///
  /// In ko, this message translates to:
  /// **'화면 지우기'**
  String get shortcutClear;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
