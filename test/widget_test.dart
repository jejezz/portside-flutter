import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:portside/app.dart';
import 'package:portside/settings/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpApp(WidgetTester tester, {ThemeMode mode = ThemeMode.system, String? locale}) async {
  SharedPreferences.setMockInitialValues({
    AppSettings.themeModeKey: mode.name,
    AppSettings.localeKey: ?locale,
  });
  final settings = await AppSettings.load();
  await tester.pumpWidget(PortsideApp(settings: settings));
  await tester.pump();
}

void main() {
  testWidgets('홈 화면이 크래시 없이 뜨는지', (tester) async {
    await _pumpApp(tester);
    expect(find.text('Connect'), findsOneWidget);
    expect(find.byTooltip('Terminal'), findsOneWidget);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('${mode.name} 테마로도 뜨는지', (tester) async {
      await _pumpApp(tester, mode: mode);
      final context = tester.element(find.text('Connect'));
      expect(Theme.of(context).brightness, mode == ThemeMode.light ? Brightness.light : Brightness.dark);
    });
  }

  testWidgets('정보 버튼이 공통 정보 창을 연다', (tester) async {
    PackageInfo.setMockInitialValues(
      appName: 'Portside',
      packageName: 'art.zoomon.portside',
      version: '1.4.2',
      buildNumber: '37',
      buildSignature: '',
    );
    await _pumpApp(tester, locale: 'en');
    await tester.tap(find.byTooltip('About'));
    await tester.pumpAndSettle();
    expect(find.text('Version 1.4.2 (build 37)'), findsOneWidget);
    expect(find.text('Open Source Licenses'), findsOneWidget);
  });

  testWidgets('한국어로 고르면 툴바·상태 바가 한국어', (tester) async {
    await _pumpApp(tester, locale: 'ko');
    expect(find.text('연결'), findsOneWidget);
    expect(find.text('0바이트'), findsOneWidget);
    expect(find.text('새 세션'), findsOneWidget);
  });

  testWidgets('English strings across the main screen and dialogs', (tester) async {
    await _pumpApp(tester, locale: 'en');
    expect(find.text('0 bytes'), findsOneWidget);
    expect(find.text('New Session'), findsOneWidget);

    await tester.tap(find.byTooltip('Help'));
    await tester.pumpAndSettle();
    expect(find.text('Keyboard Shortcuts'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Terminal Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Scrollback Lines'), findsOneWidget);
    expect(find.text('Default (Dark)'), findsOneWidget);
  });
}
