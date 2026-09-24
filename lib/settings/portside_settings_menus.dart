import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../widgets/glass_card.dart';
import 'app_settings.dart';

// 공통 settings_menus.dart의 ThemeMenuButton / LanguageMenuButton과 동작이
// 같다 (체크 표시 팝업 메뉴, theming.md §3, localization.md §4). 탭 바의 다른
// 버튼(+, 정보)과 같은 IconBadge 모양으로 그리려고 Portside에 따로 둔다 —
// 공통 파일은 템플릿과 같게 유지한다.

/// 언어 이름은 그 언어로 쓴다 — 잘못 골라도 읽고 되돌아올 수 있게.
const _languages = [(Locale('ko'), '한국어'), (Locale('en'), 'English')];

class ThemeMenuBadge extends StatelessWidget {
  const ThemeMenuBadge({super.key});

  static IconData _icon(ThemeMode mode) => switch (mode) {
        ThemeMode.system => Icons.brightness_auto_rounded,
        ThemeMode.light => Icons.light_mode_rounded,
        ThemeMode.dark => Icons.dark_mode_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<ThemeMode>(
      tooltip: l10n.themeMenuTooltip,
      initialValue: settings.themeMode,
      onSelected: settings.setThemeMode,
      itemBuilder: (_) => [
        for (final (mode, label) in [
          (ThemeMode.system, l10n.themeSystem),
          (ThemeMode.light, l10n.themeLight),
          (ThemeMode.dark, l10n.themeDark),
        ])
          CheckedPopupMenuItem(value: mode, checked: mode == settings.themeMode, child: Text(label)),
      ],
      child: IconBadge(icon: _icon(settings.themeMode), color: PortsideColors.of(context).idle),
    );
  }
}

class LanguageMenuBadge extends StatelessWidget {
  const LanguageMenuBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final l10n = AppLocalizations.of(context);
    // PopupMenuButton은 null을 값으로 못 쓰므로 ''가 "시스템"을 뜻한다.
    final current = settings.locale?.languageCode ?? '';
    return PopupMenuButton<String>(
      tooltip: l10n.languageMenuTooltip,
      initialValue: current,
      onSelected: (code) => settings.setLocale(code.isEmpty ? null : Locale(code)),
      itemBuilder: (_) => [
        CheckedPopupMenuItem(value: '', checked: current.isEmpty, child: Text(l10n.languageSystem)),
        const PopupMenuDivider(),
        for (final (locale, name) in _languages)
          CheckedPopupMenuItem(
            value: locale.languageCode,
            checked: current == locale.languageCode,
            child: Text(name),
          ),
      ],
      child: IconBadge(icon: Icons.translate_rounded, color: PortsideColors.of(context).idle),
    );
  }
}
