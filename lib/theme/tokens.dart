import 'package:flutter/material.dart';

import 'app_theme.dart';

export 'app_theme.dart';

/// Portside 고유 색. 공통 팔레트(app_theme.dart)에 없는 것만 라이트·다크 한
/// 쌍으로 둔다 (conventions/theming.md §2). 위젯에서는
/// `PortsideColors.of(context)`로 읽는다.
@immutable
class PortsideColors extends ThemeExtension<PortsideColors> {
  const PortsideColors({
    required this.bg,
    required this.bgAlt,
    required this.idle,
    required this.inset,
    required this.textLow,
    required this.successText,
    required this.dangerText,
  });

  /// 배경 워시([AuroraBackground])의 양 끝과 가운데 색.
  final Color bg;
  final Color bgAlt;

  /// 보조 아이콘 배지(도움말, 설정, 새로고침 등)의 색.
  final Color idle;

  /// 카드 안에 파인 입력칸·키 표시의 채움.
  final Color inset;

  final Color textLow;

  /// 의미 색을 글자에 쓸 때 — 흰 배경에서는 진한 변형이 필요하다.
  final Color successText;
  final Color dangerText;

  static const dark = PortsideColors(
    bg: AppColors.bg,
    bgAlt: Color(0xFF0E141C),
    idle: Color(0xFF64748B),
    inset: Color(0x47000000),
    textLow: AppColors.textLow,
    successText: AppColors.success,
    dangerText: AppColors.danger,
  );

  static const light = PortsideColors(
    bg: AppColors.bgLight,
    bgAlt: Color(0xFFE9EEF6),
    idle: Color(0xFF64748B),
    inset: Color(0x0F000000),
    textLow: AppColors.textLowLight,
    successText: AppColors.successTextLight,
    dangerText: AppColors.dangerTextLight,
  );

  static PortsideColors of(BuildContext context) => Theme.of(context).extension<PortsideColors>()!;

  @override
  PortsideColors copyWith({
    Color? bg,
    Color? bgAlt,
    Color? idle,
    Color? inset,
    Color? textLow,
    Color? successText,
    Color? dangerText,
  }) =>
      PortsideColors(
        bg: bg ?? this.bg,
        bgAlt: bgAlt ?? this.bgAlt,
        idle: idle ?? this.idle,
        inset: inset ?? this.inset,
        textLow: textLow ?? this.textLow,
        successText: successText ?? this.successText,
        dangerText: dangerText ?? this.dangerText,
      );

  @override
  PortsideColors lerp(PortsideColors? other, double t) {
    if (other == null) return this;
    return PortsideColors(
      bg: Color.lerp(bg, other.bg, t)!,
      bgAlt: Color.lerp(bgAlt, other.bgAlt, t)!,
      idle: Color.lerp(idle, other.idle, t)!,
      inset: Color.lerp(inset, other.inset, t)!,
      textLow: Color.lerp(textLow, other.textLow, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
    );
  }
}

/// Saturn과 같은 배경 워시 — 스캐폴드 뒤에 까는 은은한 아우라 그라디언트.
class AuroraBackground extends StatelessWidget {
  const AuroraBackground({super.key, required this.child, this.tint});

  final Widget child;
  final Color? tint;

  @override
  Widget build(BuildContext context) {
    final colors = PortsideColors.of(context);
    final accent = tint ?? Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.bg,
            Color.alphaBlend(accent.withValues(alpha: 0.10), colors.bgAlt),
            colors.bg,
          ],
          stops: const [0, 0.45, 1],
        ),
      ),
      child: child,
    );
  }
}
