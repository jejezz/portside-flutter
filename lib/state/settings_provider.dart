import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xterm2/xterm.dart';

import '../models/app_terminal_theme.dart';

/// 흔히 쓰는 스크롤백 줄 수 프리셋.
const kScrollbackLinesOptions = <int>[1000, 5000, 10000, 20000, 50000, 100000];

/// 터미널 폰트/테마/스크롤백 설정. `shared_preferences`로 영속화해서
/// 재실행 후에도 유지된다.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _load();
  }

  // 앱 고유 설정은 <기능>_<이름> (localization.md §5). 터미널 색 구성표는
  // 앱 테마(theme_mode)와 별개라서 terminal_palette로 둔다 (theming.md §1).
  static const _kFontSizeKey = 'terminal_font_size';
  static const _kFontFamilyKey = 'terminal_font_family';
  static const _kThemeKey = 'terminal_palette';
  static const _kScrollbackLinesKey = 'terminal_scrollback_lines';

  /// 0.1.9까지 쓰던 키 → 새 키. 키만 바꾸면 사용자 설정이 사라지므로 처음
  /// 실행할 때 한 번 옮긴다.
  static const legacyKeys = {
    'font_size': _kFontSizeKey,
    'font_family': _kFontFamilyKey,
    'theme': _kThemeKey,
    'scrollback_lines': _kScrollbackLinesKey,
  };

  double _fontSize = 14;
  String _fontFamily = kFontFamilies.first;
  AppTerminalTheme _appTheme = AppTerminalTheme.defaultDark;
  int _scrollbackLines = 10000;

  double get fontSize => _fontSize;
  String get fontFamily => _fontFamily;
  AppTerminalTheme get appTheme => _appTheme;
  int get scrollbackLines => _scrollbackLines;
  TerminalStyle get terminalStyle => TerminalStyle(fontSize: _fontSize, fontFamily: _fontFamily);
  TerminalTheme get terminalTheme => _appTheme.theme;

  static Future<void> _migrateLegacyKeys(SharedPreferences prefs) async {
    for (final MapEntry(key: old, value: current) in legacyKeys.entries) {
      final value = prefs.get(old);
      if (value == null) continue;
      if (!prefs.containsKey(current)) {
        switch (value) {
          case double v:
            await prefs.setDouble(current, v);
          case int v:
            await prefs.setInt(current, v);
          case String v:
            await prefs.setString(current, v);
        }
      }
      await prefs.remove(old);
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    await _migrateLegacyKeys(prefs);
    _fontSize = prefs.getDouble(_kFontSizeKey) ?? _fontSize;
    _fontFamily = prefs.getString(_kFontFamilyKey) ?? _fontFamily;
    _scrollbackLines = prefs.getInt(_kScrollbackLinesKey) ?? _scrollbackLines;
    final themeName = prefs.getString(_kThemeKey);
    if (themeName != null) {
      _appTheme = AppTerminalTheme.values.firstWhere(
        (t) => t.name == themeName,
        orElse: () => AppTerminalTheme.defaultDark,
      );
    }
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSizeKey, value);
  }

  Future<void> setFontFamily(String value) async {
    _fontFamily = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFontFamilyKey, value);
  }

  Future<void> setAppTheme(AppTerminalTheme value) async {
    _appTheme = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeKey, value.name);
  }

  Future<void> setScrollbackLines(int value) async {
    _scrollbackLines = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kScrollbackLinesKey, value);
  }
}
