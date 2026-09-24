import 'package:flutter_test/flutter_test.dart';
import 'package:portside/models/app_terminal_theme.dart';
import 'package:portside/state/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('0.1.9까지의 설정 키를 terminal_*로 옮긴다', () async {
    SharedPreferences.setMockInitialValues({
      'font_size': 18.0,
      'font_family': 'Monaco',
      'theme': AppTerminalTheme.dracula.name,
      'scrollback_lines': 50000,
    });
    final settings = SettingsProvider();
    await Future<void>.delayed(Duration.zero);
    await pumpEventQueue();

    expect(settings.fontSize, 18);
    expect(settings.fontFamily, 'Monaco');
    expect(settings.appTheme, AppTerminalTheme.dracula);
    expect(settings.scrollbackLines, 50000);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('terminal_palette'), AppTerminalTheme.dracula.name);
    expect(prefs.getDouble('terminal_font_size'), 18);
    expect(prefs.containsKey('theme'), isFalse);
    expect(prefs.containsKey('font_size'), isFalse);
  });
}
