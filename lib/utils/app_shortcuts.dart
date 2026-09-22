import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// 앱 전역 단축키 하나. macOS는 ⌘ 조합, Windows/Linux는 Ctrl+Shift 조합을
/// 쓴다 — 그냥 Ctrl+W/K/T는 시리얼 장치 쪽 셸에서 쓰는 제어 문자(단어
/// 지우기, 줄 끝까지 지우기 등)라서 가로채면 안 되기 때문이다.
class AppShortcut {
  const AppShortcut._(this._key, this._macShift);

  final LogicalKeyboardKey _key;
  final bool _macShift;

  static bool get _isMac => defaultTargetPlatform == TargetPlatform.macOS;

  static const newTab = AppShortcut._(LogicalKeyboardKey.keyT, false);
  static const closeTab = AppShortcut._(LogicalKeyboardKey.keyW, false);
  static const toggleLogging = AppShortcut._(LogicalKeyboardKey.keyR, true);
  static const clearTerminal = AppShortcut._(LogicalKeyboardKey.keyK, false);

  static const all = [newTab, closeTab, toggleLogging, clearTerminal];

  SingleActivator get activator => _isMac
      ? SingleActivator(_key, meta: true, shift: _macShift)
      : SingleActivator(_key, control: true, shift: true);

  /// 도움말/툴팁에 보여줄 표기. 예: `⌘⇧R`, `Ctrl+Shift+R`.
  String get label => _isMac
      ? '⌘${_macShift ? '⇧' : ''}${_key.keyLabel}'
      : 'Ctrl+Shift+${_key.keyLabel}';
}
