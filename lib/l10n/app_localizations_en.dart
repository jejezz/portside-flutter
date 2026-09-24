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

  @override
  String get toolbarConnect => 'Connect';

  @override
  String get toolbarDisconnect => 'Disconnect';

  @override
  String get toolbarViewTerminal => 'Terminal';

  @override
  String get toolbarViewHex => 'Hex';

  @override
  String get toolbarHelp => 'Help';

  @override
  String get toolbarSettings => 'Terminal Settings';

  @override
  String get portHint => 'Port';

  @override
  String get portRefresh => 'Refresh Ports';

  @override
  String get baudHint => 'Baud';

  @override
  String get baudInvalid => 'Enter a positive whole number';

  @override
  String get baudPresets => 'Common Baud Rates';

  @override
  String get tabNewSession => 'New Session';

  @override
  String tabNew(String shortcut) {
    return 'New Tab ($shortcut)';
  }

  @override
  String get statusConnected => 'CONNECTED';

  @override
  String statusBytes(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString bytes';
  }

  @override
  String statusLogging(String file) {
    return 'Logging · $file';
  }

  @override
  String statusStartLogging(String shortcut) {
    return 'Start Logging ($shortcut)';
  }

  @override
  String statusStopLogging(String shortcut) {
    return 'Stop Logging ($shortcut)';
  }

  @override
  String get statusNoLogFile => 'No log file yet';

  @override
  String get statusRevealLogFile => 'Show Log File';

  @override
  String get statusCopyAll => 'Copy All';

  @override
  String statusClear(String shortcut) {
    return 'Clear Screen ($shortcut)';
  }

  @override
  String get logSaveConfirm => 'Start Logging';

  @override
  String get errorUnknown => 'Unknown error';

  @override
  String errorOpenFailed(String detail) {
    return 'Couldn\'t open the port: $detail';
  }

  @override
  String get errorNotConnected => 'Not connected';

  @override
  String get errorDeviceDisconnected =>
      'The device was disconnected. Check the cable and connect again.';

  @override
  String get senderHint => 'Enter: send the cursor line · Ctrl+Enter: new line';

  @override
  String get senderLineEndingNone => 'None';

  @override
  String get senderEcho => 'Echo';

  @override
  String get senderEchoTooltip => 'Also show sent text in the terminal';

  @override
  String get senderSend => 'Send Current Line';

  @override
  String get settingsTitle => 'Terminal Settings';

  @override
  String get settingsFont => 'Font';

  @override
  String get settingsFontSize => 'Size';

  @override
  String get settingsPalette => 'Color Scheme';

  @override
  String get settingsScrollback => 'Scrollback Lines';

  @override
  String get settingsScrollbackHelper =>
      'Changing this clears the current screen';

  @override
  String settingsScrollbackOption(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString lines';
  }

  @override
  String get paletteDefaultDark => 'Default (Dark)';

  @override
  String get paletteWhiteOnBlack => 'White on Black';

  @override
  String get paletteGreenPhosphor => 'Green Phosphor';

  @override
  String get paletteLight => 'Light';

  @override
  String get helpTitle => 'Help';

  @override
  String get helpConnectTitle => 'Connecting';

  @override
  String get helpConnectBody =>
      'Pick a port, set the baud rate and press Connect. The port list refreshes every 2 seconds, so plugging or unplugging a cable shows up right away. On connect, Portside sends one Enter to wake up the prompt.';

  @override
  String get helpTabsTitle => 'Tabs';

  @override
  String get helpTabsBody =>
      'Open a new session (tab) with + to talk to several ports at once. Background tabs keep receiving and logging data. The last tab can\'t be closed.';

  @override
  String get helpTypingTitle => 'Typing in the Terminal';

  @override
  String get helpTypingBody =>
      'Click the terminal to focus it and type. Arrow keys, Ctrl combinations and Backspace all work. On macOS, Korean input composition breaks because of a library limitation.';

  @override
  String get helpSenderTitle => 'Line Sender';

  @override
  String get helpSenderBody =>
      'Write several lines ahead of time and press Enter to send only the line with the cursor. Ctrl+Enter inserts a new line. After sending, the cursor moves to the end of the next line, so pressing Enter repeatedly sends the lines in order.';

  @override
  String get helpHexTitle => 'Hex View';

  @override
  String get helpHexBody =>
      'Switch with the Terminal/Hex toggle in the toolbar. It shows the bytes actually received as a hex dump.';

  @override
  String get helpLoggingTitle => 'Logging';

  @override
  String helpLoggingBody(String shortcut) {
    return 'Press the ● button (or $shortcut) to choose where to save the log. Several tabs can log at the same time.';
  }

  @override
  String get helpSettingsTitle => 'Font / Color Scheme';

  @override
  String get helpSettingsBody =>
      'Change the font, size, terminal color scheme (Solarized, Dracula, Nord, Gruvbox and more) and scrollback length in Settings (⚙). They are kept across restarts. The app\'s light/dark mode and language are in the buttons at the right of the tab bar.';

  @override
  String get helpShortcutsTitle => 'Keyboard Shortcuts';

  @override
  String get shortcutNewTab => 'New tab';

  @override
  String get shortcutCloseTab => 'Close current tab';

  @override
  String get shortcutToggleLogging => 'Start/stop logging';

  @override
  String get shortcutClear => 'Clear screen';
}
