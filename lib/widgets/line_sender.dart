import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/line_ending.dart';
import '../services/sender_file.dart';
import '../state/terminal_session_provider.dart';
import '../theme/tokens.dart';
import 'glass_card.dart';
import 'pass_through_cursor.dart';

/// 여러 줄을 미리 써두고 한 줄씩 순서대로 전송하는 스크립트 러너.
/// 그냥 Enter는 커서가 있는 줄을 전송하고, Ctrl+Enter는 평범한 줄바꿈이다.
/// 전송 후 커서는 다음 줄의 끝으로 이동해서, Enter를 반복해서 누르면
/// 위에서부터 한 줄씩 순서대로 흘러 내려가며 전송된다.
///
/// 편집기처럼 스크립트를 파일에서 불러오고(Ctrl+O) 저장할 수 있다(Ctrl+S, 다른 이름으로: Ctrl+Shift+S).
/// macOS에서는 Ctrl 대신 ⌘. 편집 중인 파일 이름과 변경 여부는 입력 칸 안 맨 위의 칩에 보이고, 저장하지 않은 변경이
/// 있으면 열기·새로 만들기 전에 묻는다.
///
/// 구성(위에서 아래로): 이름 칩(입력 칸 안 맨 위, 고정) · 입력 칸 · 구분선 · 하단 줄. 하단 줄은 왼쪽에 파일 버튼 네 개,
/// 오른쪽 끝에 Echo 스위치 · 줄 끝 문자 선택 · 전송 버튼이다. 입력 칸 옆에 열을 두지 않아서 폭과 높이가 어떻게 바뀌어도
/// 버튼은 항상 같은 자리에 같은 크기로 있다. 바깥 [GlassCard]가 여백을 주므로 이 위젯은 자기 여백이 없다.
class LineSender extends StatefulWidget {
  const LineSender({super.key});

  /// 이 위젯이 보이려면 필요한 최소 높이: 글 영역이 한 줄은 보일 높이 + 간격 + 하단 줄.
  /// 호출하는 쪽(홈 화면)이 [GlassCard]의 여백까지 더해서 영역의 최소 높이를 정한다.
  static const minHeight = 44.0 + 4.0 + 44.0;

  @override
  State<LineSender> createState() => _LineSenderState();
}

class _LineSenderState extends State<LineSender> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _scroll = ScrollController();

  /// 편집 중인 파일. 아직 저장한 적 없는 새 스크립트면 null.
  String? _path;

  /// 파일에 저장된(또는 방금 불러온) 내용과 그 파일의 줄바꿈.
  String _savedText = '';
  String _eol = '\n';
  bool _modified = false;

  /// 내용이 칸보다 길어서 스크롤바가 생겼는가.
  bool _scrollable = false;
  bool _scrollCheckQueued = false;

  /// 입력 칸 안쪽 여백. 스크롤바는 이 여백 안쪽에 그려지므로(손잡이가 상자 오른쪽 끝에서 13~20px 안쪽) 스크롤바
  /// 영역을 잡을 때 여백을 더해야 한다.
  static const _contentPadding = 10.0;

  /// 스크롤바 위에서 화살표 커서를 보여 줄 오른쪽 가장자리의 폭: 여백 + 스크롤바(손잡이와 여백) 약 18px.
  static const _scrollbarWidth = _contentPadding + 18.0;

  static const _maxNameChars = 20;
  static const _nameChipHeight = 28.0;
  static const _bottomBarHeight = 44.0;
  static const _buttonSize = 36.0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateModified);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ───────────────────────── 파일: 열기 / 저장 ─────────────────────────

  /// 끝에 붙은 빈 줄은 무시하고 비교한다 — 마지막 줄을 보내면 자동으로 새 줄이 붙는데, 그것만으로 "변경됨"이
  /// 되면 스크립트를 끝까지 실행할 때마다 저장하라는 표시가 뜨기 때문이다.
  static String _trimEnd(String s) => s.replaceFirst(RegExp(r'\n+$'), '');

  void _updateModified() {
    _checkScrollable();
    final modified = _path != null
        ? _trimEnd(_controller.text) != _trimEnd(_savedText)
        : _controller.text.isNotEmpty;
    if (modified != _modified) setState(() => _modified = modified);
  }

  String get _displayName => _path == null
      ? AppLocalizations.of(context).senderUntitled
      : p.basename(_path!);

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
      );
  }

  String _errorText(Object e) {
    final l10n = AppLocalizations.of(context);
    if (e is SenderFileException) {
      return switch (e.kind) {
        SenderFileError.tooLarge => l10n.senderFileTooLarge(
          SenderFile.maxBytes ~/ (1024 * 1024),
        ),
        SenderFileError.notUtf8 => l10n.senderFileNotUtf8,
        SenderFileError.io => l10n.senderFileError(e.detail),
      };
    }
    return l10n.senderFileError('$e');
  }

  /// 저장하지 않은 변경이 있으면 물어본다. 계속해도 되면 true. ("저장"을 골랐는데 저장을 취소하면 false)
  Future<bool> _confirmDiscard() async {
    if (!_modified) return true;
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.senderUnsavedTitle),
        content: Text(l10n.senderUnsavedBody(_displayName)),
        actions: [
          TextButton(
            autofocus: true,
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'discard'),
            child: Text(l10n.senderDiscard),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'save'),
            child: Text(l10n.senderSaveFirst),
          ),
        ],
      ),
    );
    return switch (choice) {
      'discard' => true,
      'save' => await _save(),
      _ => false,
    };
  }

  Future<void> _new() async {
    if (!await _confirmDiscard()) return;
    _setDocument(null, '', '\n');
  }

  Future<void> _open() async {
    if (!await _confirmDiscard()) return;
    final file = await openFile();
    if (file == null) return;
    try {
      final doc = await SenderFile.read(file.path);
      _setDocument(file.path, doc.text, doc.eol);
    } catch (e) {
      _toast(_errorText(e));
    }
  }

  /// 편집 중인 파일에 저장한다. 파일이 아직 없으면 "다른 이름으로 저장". 저장했으면 true.
  Future<bool> _save() => _path == null ? _saveAs() : _write(_path!);

  Future<bool> _saveAs() async {
    final location = await getSaveLocation(
      suggestedName: _path == null
          ? SenderFile.suggestedName
          : p.basename(_path!),
      confirmButtonText: AppLocalizations.of(context).senderSaveFirst,
    );
    if (location == null) return false;
    return _write(location.path);
  }

  Future<bool> _write(String path) async {
    final text = _controller.text;
    try {
      await SenderFile.write(path, text, eol: _eol);
    } catch (e) {
      _toast(_errorText(e));
      return false;
    }
    if (!mounted) return true;
    setState(() {
      _path = path;
      _savedText = text;
      _modified = false;
    });
    return true;
  }

  /// 칸의 내용을 문서로 바꾼다. 커서는 맨 앞에 두어서 Enter를 누르면 첫 줄부터 보내진다.
  void _setDocument(String? path, String text, String eol) {
    _path = path;
    _savedText = text;
    _eol = eol;
    _modified = false;
    _controller.value = TextEditingValue(
      text: text,
      selection: const TextSelection.collapsed(offset: 0),
    );
    setState(() {});
  }

  // ───────────────────────── 키보드 ─────────────────────────

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // 파일 단축키: Windows/Linux는 Ctrl, macOS는 ⌘. (앱 전역 단축키는 Ctrl+Shift+T/W/R/K라 겹치지 않는다.)
    final kb = HardwareKeyboard.instance;
    final command = defaultTargetPlatform == TargetPlatform.macOS
        ? kb.isMetaPressed
        : kb.isControlPressed;
    if (command && event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyS) {
        kb.isShiftPressed ? _saveAs() : _save();
        return KeyEventResult.handled;
      }
      if (event.logicalKey == LogicalKeyboardKey.keyO) {
        _open();
        return KeyEventResult.handled;
      }
    }

    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;
    if (!isEnter) return KeyEventResult.ignored;

    final connected =
        context.read<TerminalSessionProvider>().status ==
        ConnectionStatus.connected;
    // 연결되지 않았을 때는 전송할 대상이 없으므로, Enter도 그냥 보통의
    // 줄바꿈(CR/LF)으로만 동작해서 미리 스크립트를 자유롭게 써둘 수 있게 한다.
    if (!connected || HardwareKeyboard.instance.isControlPressed) {
      _insertNewlineAtCursor();
    } else {
      _sendCurrentLine();
    }
    return KeyEventResult.handled;
  }

  // TextField의 "기본 동작에 맡기기"에 기대지 않고 직접 줄바꿈을 넣는다 —
  // 플랫폼 텍스트 입력 채널이 raw 키 이벤트 처리 결과와 별개로 움직여서
  // Ctrl+Enter를 그냥 무시(ignored)하면 실제로는 줄바꿈이 전혀 안 들어가는
  // 문제가 있었다 (터미널 raw 입력에서 겪은 것과 같은 종류의 이중 채널 이슈).
  void _insertNewlineAtCursor() {
    final text = _controller.text;
    final selection = _controller.selection;
    final start = selection.start < 0 ? text.length : selection.start;
    final end = selection.end < 0 ? text.length : selection.end;
    final newText = text.replaceRange(start, end, '\n');
    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: start + 1),
    );
  }

  void _sendCurrentLine() {
    final session = context.read<TerminalSessionProvider>();
    if (session.status != ConnectionStatus.connected) return;

    final text = _controller.text;
    final cursor = _controller.selection.baseOffset;
    final safeCursor = cursor < 0 ? text.length : cursor;

    var lineStart = 0;
    if (safeCursor > 0) {
      final idx = text.lastIndexOf('\n', safeCursor - 1);
      lineStart = idx == -1 ? 0 : idx + 1;
    }
    var lineEnd = text.indexOf('\n', safeCursor);
    if (lineEnd == -1) lineEnd = text.length;

    session.send(text.substring(lineStart, lineEnd));

    if (lineEnd == text.length) {
      // 마지막 줄이었다 — 새 빈 줄을 만들고 거기로 이동해서 바로 이어 쓸 수 있게.
      final newText = '$text\n';
      _controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    } else {
      var nextLineEnd = text.indexOf('\n', lineEnd + 1);
      if (nextLineEnd == -1) nextLineEnd = text.length;
      _controller.selection = TextSelection.collapsed(offset: nextLineEnd);
    }
  }

  // ───────────────────────── 스크롤바 위 커서 ─────────────────────────

  /// 프레임이 끝난 뒤 칸이 스크롤되는지(= 스크롤바가 있는지) 다시 읽는다. Flutter의 스크롤 크기 알림은 글이 짧아져서
  /// 스크롤할 필요가 없어진 경우에는 오지 않기도 해서, 알림만 믿으면 화살표 영역이 남는다.
  /// 글이 바뀔 때, 칸의 크기가 바뀔 때, 알림이 올 때 부른다. 한 프레임에 한 번만 확인한다.
  void _checkScrollable() {
    if (_scrollCheckQueued) return;
    _scrollCheckQueued = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollCheckQueued = false;
      if (!mounted || !_scroll.hasClients) return;
      final scrollable = _scroll.position.maxScrollExtent > 0;
      if (scrollable != _scrollable) setState(() => _scrollable = scrollable);
    });
  }

  /// TextField는 칸 전체를 텍스트 입력용 I자 커서로 덮어서, 그 안의 스크롤바 위에서도 커서가 바뀌지 않는다.
  /// 스크롤바가 있을 때만 오른쪽 가장자리에 화살표 커서 영역을 겹친다. 이 영역은 마우스 이벤트를 가로채지
  /// 않아서([PassThroughCursorRegion]) 스크롤바를 눌러 끄는 동작은 그대로 된다.
  Widget _withScrollbarCursor(Widget field) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: (_) {
        _checkScrollable();
        return false;
      },
      // 칸 크기가 바뀌면(스크립트 영역을 끌어서 키우거나 줄일 때) 스크롤바가 생기거나 사라질 수 있다.
      child: LayoutBuilder(
        builder: (context, _) {
          _checkScrollable();
          return Stack(
            children: [
              Positioned.fill(child: field),
              if (_scrollable)
                const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  width: _scrollbarWidth,
                  child: PassThroughCursorRegion(
                    cursor: SystemMouseCursors.basic,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ───────────────────────── 화면 ─────────────────────────

  static String get _commandKey =>
      defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : 'Ctrl+';
  static String get _saveAsKey =>
      defaultTargetPlatform == TargetPlatform.macOS ? '⌘⇧S' : 'Ctrl+Shift+S';

  /// 하단 줄 맨 왼쪽(새로 만들기 버튼 앞)에 보이는 파일 이름과 변경 여부 (파일이 없으면 '제목 없음'). 이름은 최대
  /// [_maxNameChars]자까지만 보이고 넘으면 줄임표로 자른다. 전체 경로는 툴팁에, 눌러도 입력 칸에 포커스가 간다.
  ///
  /// 본문과 헷갈리지 않게 [StatusPill]처럼 윤곽선이 있는 둥근 칩으로 감싸고, 본문(밝은 글자)과 다른 강조색을 쓴다
  /// (저장하지 않은 변경이 있으면 경고색).
  Widget _nameChip(ColorScheme scheme, AppLocalizations l10n) {
    final base = _path != null ? _displayName : l10n.senderUntitled;
    final runes = base.runes.toList();
    final shown = runes.length > _maxNameChars
        ? '${String.fromCharCodes(runes.take(_maxNameChars))}…'
        : base;
    final name = _modified ? '● $shown' : shown;
    final dark = scheme.brightness == Brightness.dark;
    final color = _modified
        ? (dark ? AppColors.warning : AppColors.warningTextLight)
        : scheme.primary;
    final chip = Container(
      key: const ValueKey('line-sender-name-chip'),
      height: _nameChipHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _path == null
                ? Icons.edit_note_rounded
                : Icons.description_outlined,
            size: 15,
            color: color,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppFonts.userContent.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusNode.requestFocus,
      child: Tooltip(message: _path ?? base, child: chip),
    );
  }

  /// 하단 줄의 파일 버튼 한 개. 앱의 다른 아이콘 버튼과 같은 [IconBadge] 모양이다.
  Widget _fileButton(
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    required Color color,
  }) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: IconBadge(
      icon: icon,
      color: color,
      size: _buttonSize,
      tooltip: tooltip,
      onTap: onTap,
    ),
  );

  /// 윤곽선만 있는 둥근 칩 모양의 작은 컨트롤 (줄 끝 문자 선택).
  Widget _outlinedChip(
    ColorScheme scheme, {
    required IconData icon,
    required String label,
  }) => Container(
    height: 32,
    padding: const EdgeInsets.only(left: 10, right: 4),
    decoration: BoxDecoration(
      border: Border.all(color: scheme.outlineVariant),
      borderRadius: BorderRadius.circular(AppRadius.chip),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: scheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppFonts.mono.copyWith(
            fontSize: 12.5,
            color: scheme.onSurface,
          ),
        ),
        Icon(
          Icons.arrow_drop_down_rounded,
          size: 20,
          color: scheme.onSurfaceVariant,
        ),
      ],
    ),
  );

  /// 하단 줄: 왼쪽에 파일 버튼 네 개(새로 만들기, 열기, 저장, 다른 이름으로 저장), 오른쪽 끝에 Echo 스위치와 줄 끝 문자
  /// 선택, 전송 버튼. 위쪽에 가는 구분선을 그어 입력 칸과 구별한다 (선의 두께도 이 높이 안에 들어간다).
  Widget _bottomBar(
    TerminalSessionProvider session,
    ColorScheme scheme,
    AppLocalizations l10n,
  ) {
    final colors = PortsideColors.of(context);
    final connected = session.status == ConnectionStatus.connected;
    final ending = session.lineEnding.label ?? l10n.senderLineEndingNone;
    return Container(
      height: _bottomBarHeight,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Flexible(child: _nameChip(scheme, l10n)),
                const SizedBox(width: 10),
                // 편집기의 새 파일 · 열기 · 저장 · 다른 이름으로 저장 순서.
                _fileButton(
                  Icons.note_add_outlined,
                  l10n.senderNew,
                  _new,
                  color: colors.idle,
                ),
                _fileButton(
                  Icons.folder_open_rounded,
                  l10n.senderOpen('${_commandKey}O'),
                  _open,
                  color: colors.idle,
                ),
                _fileButton(
                  Icons.save_outlined,
                  l10n.senderSave('${_commandKey}S'),
                  _save,
                  color: _modified ? scheme.primary : colors.idle,
                ),
                _fileButton(
                  Icons.save_as_outlined,
                  '${l10n.senderSaveAs} ($_saveAsKey)',
                  _saveAs,
                  color: colors.idle,
                ),
              ],
            ),
          ),
          Tooltip(
            message: l10n.senderEchoTooltip,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.senderEcho,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                Transform.scale(
                  scale: 0.8,
                  child: Switch(
                    value: session.localEcho,
                    activeTrackColor: AppColors.accent,
                    onChanged: (value) => session.setLocalEcho(value),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          PopupMenuButton<LineEnding>(
            tooltip: l10n.senderLineEndingTooltip,
            initialValue: session.lineEnding,
            onSelected: session.setLineEnding,
            itemBuilder: (context) => [
              for (final e in LineEnding.values)
                PopupMenuItem(
                  value: e,
                  child: Text(
                    e.label ?? l10n.senderLineEndingNone,
                    style: AppFonts.mono.copyWith(fontSize: 13),
                  ),
                ),
            ],
            child: _outlinedChip(
              scheme,
              icon: Icons.keyboard_return_rounded,
              label: ending,
            ),
          ),
          const SizedBox(width: 8),
          IconBadge(
            icon: Icons.send_rounded,
            color: scheme.primary,
            active: connected,
            size: _buttonSize,
            tooltip: l10n.senderSend,
            onTap: connected ? _sendCurrentLine : null,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<TerminalSessionProvider>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            key: const ValueKey('line-sender-box'),
            decoration: BoxDecoration(
              color: PortsideColors.of(context).inset,
              borderRadius: BorderRadius.circular(AppRadius.tile),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Focus(
                    onKeyEvent: _onKeyEvent,
                    child: _withScrollbarCursor(
                      TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        scrollController: _scroll,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: AppFonts.mono.copyWith(
                          fontSize: 13,
                          color: scheme.onSurface,
                        ),
                        // 바깥 상자(Container)가 배경과 모서리를 맡으므로, 테마의 기본 채움과 테두리는 끈다.
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: l10n.senderHint,
                          contentPadding: const EdgeInsets.fromLTRB(
                            _contentPadding,
                            _contentPadding,
                            _contentPadding,
                            _contentPadding,
                          ),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        _bottomBar(session, scheme, l10n),
      ],
    );
  }
}
