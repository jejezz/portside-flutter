import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

    return Row(
      children: [
        Text(
          '${session.byteCount} bytes',
          style: TextStyle(
            fontSize: 12.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 10),
        if (session.isLogging)
          StatusPill(
            label: '기록 중 · ${session.logFilePath?.split('/').last ?? ''}',
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
          tooltip: session.isLogging ? '기록 정지 (${AppShortcut.toggleLogging.label})' : '기록 시작 (${AppShortcut.toggleLogging.label})',
          onTap: (connected || session.isLogging)
              ? () => session.toggleLogging()
              : null,
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.folder_open_rounded,
          color: colors.idle,
          tooltip: session.logFilePath == null ? '기록된 로그 파일 없음' : '기록 파일 위치 열기',
          onTap: session.logFilePath == null
              ? null
              : () => FileRevealService.reveal(session.logFilePath!),
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.content_copy_rounded,
          color: colors.idle,
          tooltip: '전체 복사',
          onTap: () =>
              Clipboard.setData(ClipboardData(text: session.displayText)),
        ),
        const SizedBox(width: 6),
        IconBadge(
          icon: Icons.clear_all_rounded,
          color: colors.idle,
          tooltip: '화면 지우기 (${AppShortcut.clearTerminal.label})',
          onTap: () => session.clearTerminal(),
        ),
      ],
    );
  }
}
