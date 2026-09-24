// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutTooltip => 'About';

  @override
  String aboutVersion(String version, String build) {
    return 'Version $version (build $build)';
  }

  @override
  String get aboutOpenSourceLicenses => 'Open Source Licenses';

  @override
  String get aboutRepository => 'GitHub';

  @override
  String get commonClose => 'Close';

  @override
  String aboutMenuItem(String appName) {
    return 'About $appName';
  }

  @override
  String get themeMenuTooltip => 'Theme';

  @override
  String get themeSystem => 'Follow System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get languageMenuTooltip => 'Language';

  @override
  String get languageSystem => 'System / 시스템 설정 따르기';

  @override
  String get languageSystemShort => 'System';

  @override
  String get aboutTagline =>
      'A free, multi-tab serial terminal for USB-to-Serial (COM) ports';

  @override
  String get aboutDescription =>
      'A lightweight, free serial terminal for Windows, macOS and Linux. Built because CoolTerm no longer runs well on current systems and Termius charges for serial connections.';

  @override
  String get aboutFeature1 =>
      'Automatic serial port detection with hot-plug refresh and any baud rate';

  @override
  String get aboutFeature2 =>
      'Tabbed sessions to talk to several ports at once';

  @override
  String get aboutFeature3 =>
      'ANSI 256-color / true-color terminal with arrow and Ctrl key input';

  @override
  String get aboutFeature4 =>
      'Line Sender — send prepared lines one at a time with Enter';

  @override
  String get aboutFeature5 => 'Hex View toggle and per-tab output logging';

  @override
  String get aboutFeature6 =>
      'Remembers font, color scheme and scrollback settings';
}
