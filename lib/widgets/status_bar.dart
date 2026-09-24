import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/file_reveal_service.dart';
import '../state/terminal_session_provider.dart';
import '../theme/tokens.dart';
import '../utils/app_shortcuts.dart';
import 'glass_card.dart';

/// 바이트 카운트, 로깅 상태/제어, 전체 복사를 한 줄로 모아둔 상태 바.
/// (배경/여백은 이 위젯을 감싸는 [GlassCard] 몫 — 여긴 내용만.)
class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TerminalSessionProvider>();
    final connected = session.status == ConnectionStatus.connected;
    final colors = PortsideColors.of(context);
    final l10n = AppLocalizations.of(context);
    final loggingKey = AppShortcut.toggleLogging.label;

    return Row(
      children: [
        Text(
          l10n.statusBytes(session.byteCount),
          style: TextStyle(
            fontSize: 12.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        if (session.isLogging)
          StatusPill(
            label: l10n.statusLogging(session.logFilePath?.split(Platform.pathSeparator).last ?? ''),
            color: AppColors.danger,
            textColor: colors.dangerText,
          ),
        const Spacer(),
        IconBadge(
          icon: session.isLogging
              ? Icons.stop_rounded
              : Icons.fiber_manual_record_rounded,
          color: session.isLogging ? Theme.of(context).colorScheme.primary : AppColors.danger,
          active: session.isLogging,
          tooltip: session.isLogging ? l10n.statusStopLogging(loggingKey) : l10n.statusStartLogging(loggingKey),
          onTap: (connected || session.isLogging)
              ? () => session.toggleLogging(confirmButtonText: l10n.logSaveConfirm)
              : null,
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.folder_open_rounded,
          color: colors.idle,
          tooltip: session.logFilePath == null ? l10n.statusNoLogFile : l10n.statusRevealLogFile,
          onTap: session.logFilePath == null
              ? null
              : () => FileRevealService.reveal(session.logFilePath!),
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.content_copy_rounded,
          color: colors.idle,
          tooltip: l10n.statusCopyAll,
          onTap: () =>
              Clipboard.setData(ClipboardData(text: session.displayText)),
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.clear_all_rounded,
          color: colors.idle,
          tooltip: l10n.statusClear(AppShortcut.clearTerminal.label),
          onTap: () => session.clearTerminal(),
        ),
      ],
    );
  }
}
