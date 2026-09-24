import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/tokens.dart';
import '../utils/app_shortcuts.dart';

/// 기능 사용법 요약 도움말.
class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  // 단축키 표기가 플랫폼(⌘ / Ctrl+Shift)마다 달라서 const가 아니라 함수다.
  static List<(String, String)> _sections(AppLocalizations l10n) => [
    (l10n.helpConnectTitle, l10n.helpConnectBody),
    (l10n.helpTabsTitle, l10n.helpTabsBody),
    (l10n.helpTypingTitle, l10n.helpTypingBody),
    (l10n.helpSenderTitle, l10n.helpSenderBody),
    (l10n.helpHexTitle, l10n.helpHexBody),
    (l10n.helpLoggingTitle, l10n.helpLoggingBody(AppShortcut.toggleLogging.label)),
    (l10n.helpSettingsTitle, l10n.helpSettingsBody),
  ];

  static List<(String, String)> _shortcuts(AppLocalizations l10n) => [
    (AppShortcut.newTab.label, l10n.shortcutNewTab),
    (AppShortcut.closeTab.label, l10n.shortcutCloseTab),
    (AppShortcut.toggleLogging.label, l10n.shortcutToggleLogging),
    (AppShortcut.clearTerminal.label, l10n.shortcutClear),
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final heading = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: scheme.onSurface);
    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline_rounded, size: 22, color: scheme.primary),
          const SizedBox(width: 10),
          Text(l10n.helpTitle),
        ],
      ),
      content: SizedBox(
        width: 420,
        height: 420,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (title, body) in _sections(l10n)) ...[
                Text(title, style: heading),
                const SizedBox(height: 4),
                Text(body, style: TextStyle(fontSize: 12.5, height: 1.5, color: scheme.onSurfaceVariant)),
                const SizedBox(height: 16),
              ],
              Text(l10n.helpShortcutsTitle, style: heading),
              const SizedBox(height: 8),
              for (final (key, desc) in _shortcuts(l10n))
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: PortsideColors.of(context).inset,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(key, style: TextStyle(fontSize: 12, color: scheme.onSurface)),
                      ),
                      const SizedBox(width: 10),
                      Text(desc, style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonClose)),
      ],
    );
  }
}
