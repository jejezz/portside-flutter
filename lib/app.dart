import 'dart:io';
import 'dart:ui' show AppExitResponse;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'about/app_menu_bar.dart';
import 'about/portside_about.dart';
import 'app_identity.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';
import 'settings/app_settings.dart';
import 'state/sessions_provider.dart';
import 'state/settings_provider.dart';
import 'theme/tokens.dart';
import 'utils/app_shortcuts.dart';

/// 메뉴/버튼/라벨을 SeoulNamsan Light(300)로 그린다 — Material 기본 굵기는
/// 이 앱의 인상과 맞지 않아서 텍스트 테마 전체를 가볍게 둔다. 크기는 공통
/// 테마의 데스크톱 밀도(본문 13)를 그대로 쓴다.
TextTheme _lightWeight(TextTheme base) {
  TextStyle? light(TextStyle? style) => style?.copyWith(fontWeight: FontWeight.w300);
  return base.copyWith(
    displayLarge: light(base.displayLarge),
    displayMedium: light(base.displayMedium),
    displaySmall: light(base.displaySmall),
    headlineLarge: light(base.headlineLarge),
    headlineMedium: light(base.headlineMedium),
    headlineSmall: light(base.headlineSmall),
    titleLarge: light(base.titleLarge),
    titleMedium: light(base.titleMedium),
    titleSmall: light(base.titleSmall),
    bodyLarge: light(base.bodyLarge),
    bodyMedium: light(base.bodyMedium),
    bodySmall: light(base.bodySmall),
    labelLarge: light(base.labelLarge),
    labelMedium: light(base.labelMedium),
    labelSmall: light(base.labelSmall),
  );
}

/// 공통 Saturn 테마(theme/app_theme.dart)에 Portside 고유 색과 글꼴 굵기를 얹는다.
ThemeData _buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final base = dark ? AppTheme.dark() : AppTheme.light();
  return base.copyWith(
    textTheme: _lightWeight(base.textTheme),
    extensions: [dark ? PortsideColors.dark : PortsideColors.light],
  );
}

class PortsideApp extends StatefulWidget {
  const PortsideApp({super.key, required this.settings});

  /// 테마 모드·언어 (theme_mode / app_locale).
  final AppSettings settings;

  @override
  State<PortsideApp> createState() => _PortsideAppState();
}

class _PortsideAppState extends State<PortsideApp> with WidgetsBindingObserver {
  late final _sessions = SessionsProvider();
  late final _settings = SettingsProvider();
  final _navigatorKey = GlobalKey<NavigatorState>();

  static final bool _isDesktop = Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.settings.addListener(_syncWindowBrightness);
    _syncWindowBrightness();
    // 스크롤백 줄 수는 SettingsProvider(전역 설정)가 값을 들고 있고 실제
    // 적용은 각 TerminalSessionProvider의 Terminal 재생성으로 이뤄지는데,
    // provider들이 서로를 몰라도 되게 이 앱 레벨에서 이어준다. 설정이
    // 바뀌거나(_settings) 탭이 새로 생기거나(_sessions) 둘 중 하나만
    // 일어나도 전체 탭에 다시 맞춰준다 — setScrollbackLines가 값이 같으면
    // no-op이라 중복 호출해도 안전하다.
    _settings.addListener(_syncScrollback);
    _sessions.addListener(_syncScrollback);
  }

  void _syncScrollback() {
    for (final session in _sessions.sessions) {
      session.setScrollbackLines(_settings.scrollbackLines);
    }
  }

  // 앱에서 다크를 골라도 OS가 라이트면 제목 표시줄은 밝게 남는다 (theming.md §4).
  @override
  void didChangePlatformBrightness() => _syncWindowBrightness();

  void _syncWindowBrightness() {
    if (!_isDesktop || Platform.isLinux) return;
    final brightness = switch (widget.settings.themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    windowManager.setBrightness(brightness);
  }

  void _showAbout() {
    final context = _navigatorKey.currentContext;
    if (context != null) showPortsideAbout(context);
  }

  @override
  void dispose() {
    widget.settings.removeListener(_syncWindowBrightness);
    WidgetsBinding.instance.removeObserver(this);
    _settings.removeListener(_syncScrollback);
    _sessions.removeListener(_syncScrollback);
    _sessions.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Future<AppExitResponse> didRequestAppExit() async {
    // ⌘Q 등으로 앱이 종료될 때는 위젯 dispose가 보장되지 않으므로, 종료
    // 직전에 모든 탭의 로그 파일을 확실히 flush/close한다.
    await _sessions.prepareAllForExit();
    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _sessions),
        ChangeNotifierProvider.value(value: _settings),
      ],
      child: Builder(
        builder: (context) {
          // 포커스가 터미널/Line Sender 어디에 있든 동작하는 앱 전역
          // 단축키. 로깅 토글/새 탭/탭 닫기는 전부 "활성 탭" 기준이다.
          return CallbackShortcuts(
            bindings: {
              AppShortcut.toggleLogging.activator: () =>
                  context.read<SessionsProvider>().active.toggleLogging(),
              AppShortcut.newTab.activator: () =>
                  context.read<SessionsProvider>().addSession(),
              AppShortcut.closeTab.activator: () {
                final sessions = context.read<SessionsProvider>();
                sessions.closeSession(sessions.activeIndex);
              },
              AppShortcut.clearTerminal.activator: () =>
                  context.read<SessionsProvider>().active.clearTerminal(),
            },
            child: AppSettingsScope(
              settings: widget.settings,
              child: ListenableBuilder(
                listenable: widget.settings,
                builder: (context, _) => MaterialApp(
                  navigatorKey: _navigatorKey,
                  title: AppIdentity.displayName,
                  debugShowCheckedModeBanner: false,
                  theme: _buildTheme(Brightness.light),
                  darkTheme: _buildTheme(Brightness.dark),
                  themeMode: widget.settings.themeMode,
                  locale: widget.settings.locale,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localeResolutionCallback: AppSettings.resolveLocale,
                  builder: (context, child) => AppMenuBar(onAbout: _showAbout, child: child!),
                  home: const HomeScreen(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
