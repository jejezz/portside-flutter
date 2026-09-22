import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';

/// 앱 이름/버전/목적/기능 등을 보여주는 정보 다이얼로그.
class PortsideAboutDialog extends StatelessWidget {
  const PortsideAboutDialog({super.key});

  static const version = '0.1.9';
  static final _repoUrl = Uri.parse('https://github.com/jejezz/portside-flutter');

  static const _features = [
    '시리얼 포트 자동 감지·핫플러그 새로고침, 보드레이트 지정',
    '탭 기반 멀티 세션으로 여러 포트에 동시 접속',
    'ANSI 256색/트루컬러 터미널, 화살표·Ctrl 조합 입력',
    'Line Sender — 미리 써둔 여러 줄을 Enter로 한 줄씩 전송',
    'Hex View 토글, 탭별 Output 로깅',
    '폰트·색상 테마·스크롤백 설정 저장',
  ];

  static const _body = TextStyle(fontSize: 13, height: 1.5, color: AppColors.textMid);
  static const _strong = TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w700, color: AppColors.textHi);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.card)),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cable_rounded, size: 24, color: AppColors.accent),
          SizedBox(width: 10),
          Text('Portside 정보'),
        ],
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('USB-to-Serial(COM) 포트용 무료 멀티탭 시리얼 터미널', style: _body),
              const SizedBox(height: 4),
              const Text('버전 $version', style: _strong),
              const SizedBox(height: 12),
              const Text(
                'Windows·macOS·Linux 어디서나 쓸 수 있는 가볍고 무료인 시리얼 터미널을 목표로 만들었습니다. '
                'CoolTerm은 오래되어 최신 OS에서 잘 돌지 않고, Termius는 시리얼 통신이 유료라서 직접 제작했습니다.',
                style: _body,
              ),
              const SizedBox(height: 16),
              const Text(
                '주요 기능',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textHi),
              ),
              const SizedBox(height: 6),
              for (final feature in _features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  ', style: _body),
                      Expanded(child: Text(feature, style: _body)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              const Text('Flutter(Dart)로 제작', style: _strong),
              const Text('라이선스: MIT', style: _strong),
              const Text('Copyright © 2026 Jong-yun Ahn', style: _body),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => launchUrl(_repoUrl),
          child: const Text('GitHub 저장소 열기'),
        ),
        FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('닫기')),
      ],
    );
  }
}
