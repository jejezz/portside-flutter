import 'dart:convert';
import 'dart:io';

import 'package:portside/l10n/app_localizations.dart';
import 'package:portside/models/connection_settings.dart';
import 'package:portside/state/terminal_session_provider.dart';
import 'package:portside/theme/tokens.dart';
import 'package:portside/widgets/line_sender.dart';
import 'package:file_selector_platform_interface/file_selector_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_serial.dart';

/// 파일 선택/저장 대화상자를 흉내 낸다: 다음에 열릴 대화상자가 돌려줄 경로를 미리 정해 둔다 (null = 취소).
class FakeFileSelector extends FileSelectorPlatform
    with MockPlatformInterfaceMixin {
  final List<String?> openAnswers = [];
  final List<String?> saveAnswers = [];
  int openCalls = 0;
  int saveCalls = 0;
  String? lastSuggestedName;

  @override
  Future<XFile?> openFile({
    List<XTypeGroup>? acceptedTypeGroups,
    String? initialDirectory,
    String? confirmButtonText,
  }) async {
    openCalls++;
    final path = openAnswers.isEmpty ? null : openAnswers.removeAt(0);
    return path == null ? null : XFile(path);
  }

  @override
  Future<FileSaveLocation?> getSaveLocation({
    List<XTypeGroup>? acceptedTypeGroups,
    SaveDialogOptions options = const SaveDialogOptions(),
  }) async {
    saveCalls++;
    lastSuggestedName = options.suggestedName;
    final path = saveAnswers.isEmpty ? null : saveAnswers.removeAt(0);
    return path == null ? null : FileSaveLocation(path);
  }
}

void main() {
  late Directory tmp;
  late FakeFileSelector dialogs;
  late FakeSerialService serial;
  late TerminalSessionProvider session;

  String file(String name) => p.join(tmp.path, name);

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('dt_ls_');
    dialogs = FakeFileSelector();
    FileSelectorPlatform.instance = dialogs;
    serial = FakeSerialService();
    session = TerminalSessionProvider(serial);
  });

  tearDown(() async {
    session.dispose();
    if (tmp.existsSync()) await tmp.delete(recursive: true);
  });

  Future<void> pumpSender(WidgetTester tester, {bool connected = true}) async {
    tester.view.physicalSize = const Size(1000, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    if (connected) {
      session.connect(
        const ConnectionSettings(portName: 'TEST', baudRate: 115200),
      );
      serial.clearWritten(); // 연결할 때 보내는 깨우기용 Enter는 테스트와 상관없다
    }
    await tester.pumpWidget(
      ChangeNotifierProvider<TerminalSessionProvider>.value(
        value: session,
        child: MaterialApp(
          theme: AppTheme.dark().copyWith(extensions: [PortsideColors.dark]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          home: const Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(height: 200, child: LineSender()),
            ),
          ),
        ),
      ),
    );
  }

  /// 파일 입출력이 따르는 동작은 가짜 시계 밖(runAsync)에서 해야 끝난다.
  Future<void> act(WidgetTester tester, Future<void> Function() action) async {
    await tester.runAsync(action);
    // 팝업 메뉴는 닫힌 뒤에야 동작이 시작되고, 파일 입출력은 실제 시간이 걸린다. 실제 시간과 화면 갱신을 번갈아 돌려서
    // 입출력이 끝난 뒤의 setState까지 화면에 반영되게 한다.
    for (var i = 0; i < 4; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 120)),
      );
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  Finder field() => find.byType(TextField);
  String text(WidgetTester tester) =>
      tester.widget<TextField>(field()).controller!.text;
  Future<void> typeText(WidgetTester tester, String value) async {
    await tester.enterText(field(), value);
    await tester.pump();
  }

  Future<void> tapOpen(WidgetTester tester) =>
      act(tester, () => tester.tap(find.byIcon(Icons.folder_open_rounded)));
  Future<void> tapSave(WidgetTester tester) =>
      act(tester, () => tester.tap(find.byIcon(Icons.save_outlined)));

  Future<void> tapSaveAs(WidgetTester tester) =>
      act(tester, () => tester.tap(find.byIcon(Icons.save_as_outlined)));

  Future<void> tapNew(WidgetTester tester) =>
      act(tester, () => tester.tap(find.byIcon(Icons.note_add_outlined)));

  Future<void> pressCommand(
    WidgetTester tester,
    LogicalKeyboardKey key, {
    bool shift = false,
  }) async {
    await tester.runAsync(() async {
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(key);
      if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await Future<void>.delayed(const Duration(milliseconds: 150));
    });
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets(
    'Open loads a script; the cursor is at the top so Enter sends the first line; the file name shows',
    (tester) async {
      File(file('deploy.sh')).writeAsStringSync('cd /srv\nls -l\nexit\n');
      dialogs.openAnswers.add(file('deploy.sh'));
      await pumpSender(tester);
      expect(find.text('deploy.sh'), findsNothing); // 파일과 연결되기 전에는 이름 줄이 없다

      await tapOpen(tester);
      expect(text(tester), 'cd /srv\nls -l\nexit\n');
      expect(find.text('deploy.sh'), findsOneWidget);
      expect(find.textContaining('●'), findsNothing);

      // 칸에 포커스만 준다 (눌러서 캐럿을 옮기면 "맨 앞에서 시작"을 확인할 수 없다).
      tester.widget<TextField>(field()).focusNode!.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      // 첫 줄부터 한 줄씩: 커서가 맨 앞에서 시작했다.
      expect(serial.writtenText, 'cd /srv\n'); // Portside의 기본 줄 끝은 LF
    },
  );

  testWidgets(
    'editing marks the file modified; Save writes it and clears the mark; the button needs no file yet',
    (tester) async {
      File(file('a.txt')).writeAsStringSync('one\n');
      dialogs.openAnswers.add(file('a.txt'));
      await pumpSender(tester);
      await tapOpen(tester);

      await typeText(tester, 'one\ntwo\n');
      expect(find.textContaining('● a.txt'), findsOneWidget);
      expect(File(file('a.txt')).readAsStringSync(), 'one\n'); // 저장 전에는 파일이 그대로

      await tapSave(tester);
      expect(File(file('a.txt')).readAsStringSync(), 'one\ntwo\n');
      expect(find.textContaining('●'), findsNothing);
      expect(find.text('a.txt'), findsOneWidget);
      expect(dialogs.saveCalls, 0); // 이미 파일이 있으니 저장 대화상자 없이 덮어쓴다
    },
  );

  testWidgets(
    'a new script has no file: Save asks where, suggests a name, then remembers it',
    (tester) async {
      dialogs.saveAnswers.add(file('made.txt'));
      await pumpSender(tester);
      await typeText(tester, 'echo hi');

      await tapSave(tester);
      expect(dialogs.saveCalls, 1);
      expect(dialogs.lastSuggestedName, 'line-sender.txt');
      expect(File(file('made.txt')).readAsStringSync(), 'echo hi');
      expect(find.text('made.txt'), findsOneWidget);

      // 두 번째 저장부터는 묻지 않는다.
      await typeText(tester, 'echo hi\necho again');
      await tapSave(tester);
      expect(dialogs.saveCalls, 1);
      expect(File(file('made.txt')).readAsStringSync(), 'echo hi\necho again');
    },
  );

  testWidgets(
    'cancelling the save dialog saves nothing and keeps the text and the modified state',
    (tester) async {
      dialogs.saveAnswers.add(null);
      await pumpSender(tester);
      await typeText(tester, 'keep me');
      await tapSave(tester);
      expect(dialogs.saveCalls, 1);
      expect(text(tester), 'keep me');
      expect(tmp.listSync(), isEmpty);
    },
  );

  testWidgets(
    'Save as writes a copy under a new name and continues editing that one',
    (tester) async {
      File(file('orig.txt')).writeAsStringSync('v1');
      dialogs.openAnswers.add(file('orig.txt'));
      dialogs.saveAnswers.add(file('copy.txt'));
      await pumpSender(tester);
      await tapOpen(tester);
      await typeText(tester, 'v2');

      await tapSaveAs(tester);
      expect(dialogs.lastSuggestedName, 'orig.txt'); // 지금 이름을 제안
      expect(File(file('copy.txt')).readAsStringSync(), 'v2');
      expect(File(file('orig.txt')).readAsStringSync(), 'v1'); // 원본은 그대로
      expect(find.text('copy.txt'), findsOneWidget);
    },
  );

  testWidgets('Ctrl+S saves, Ctrl+Shift+S saves as, Ctrl+O opens', (
    tester,
  ) async {
    File(file('k.txt')).writeAsStringSync('a');
    dialogs.openAnswers.add(file('k.txt'));
    dialogs.saveAnswers.add(file('k2.txt'));
    await pumpSender(tester);

    await tester.tap(field());
    await tester.pump();
    await pressCommand(tester, LogicalKeyboardKey.keyO);
    expect(dialogs.openCalls, 1);
    expect(text(tester), 'a');

    await typeText(tester, 'ab');
    await pressCommand(tester, LogicalKeyboardKey.keyS);
    expect(File(file('k.txt')).readAsStringSync(), 'ab');
    expect(dialogs.saveCalls, 0);

    await pressCommand(tester, LogicalKeyboardKey.keyS, shift: true);
    expect(dialogs.saveCalls, 1);
    expect(File(file('k2.txt')).readAsStringSync(), 'ab');
  });

  testWidgets(
    'opening with unsaved changes asks first: Cancel keeps, Discard opens, Save writes then opens',
    (tester) async {
      File(file('first.txt')).writeAsStringSync('first');
      File(file('second.txt')).writeAsStringSync('second');
      dialogs.openAnswers.addAll([
        file('first.txt'),
        file('second.txt'),
        file('second.txt'),
        file('first.txt'),
      ]);
      await pumpSender(tester);
      await tapOpen(tester); // first.txt

      await typeText(tester, 'first EDITED');
      await tapOpen(tester); // 변경이 있다 → 묻는다
      expect(find.text('저장하지 않은 변경 사항'), findsOneWidget);
      expect(find.textContaining('first.txt의 변경 사항'), findsOneWidget);
      await act(tester, () => tester.tap(find.text('취소')));
      expect(dialogs.openCalls, 1, reason: '취소하면 선택창도 열지 않는다');
      expect(text(tester), 'first EDITED');

      await tapOpen(tester);
      await act(tester, () => tester.tap(find.text('버리기')));
      expect(dialogs.openCalls, 2);
      expect(text(tester), 'second');
      expect(
        File(file('first.txt')).readAsStringSync(),
        'first',
        reason: '버렸으니 파일은 그대로',
      );

      await typeText(tester, 'second EDITED');
      await tapOpen(tester);
      await act(tester, () => tester.tap(find.text('저장')));
      expect(
        File(file('second.txt')).readAsStringSync(),
        'second EDITED',
        reason: '저장하고 나서 연다',
      );
      // 저장한 뒤 second.txt를 다시 열었으니, 방금 저장한 내용이 그대로 보인다.
      expect(text(tester), 'second EDITED');
      expect(dialogs.openCalls, 3);
    },
    skip: false,
  );

  testWidgets(
    'New script clears the box (asking first when there are changes) and forgets the file',
    (tester) async {
      File(file('n.txt')).writeAsStringSync('old');
      dialogs.openAnswers.add(file('n.txt'));
      await pumpSender(tester);
      await tapOpen(tester);

      await tapNew(tester); // 변경 없음 → 묻지 않는다
      expect(text(tester), '');
      expect(find.text('n.txt'), findsNothing);

      await typeText(tester, 'draft');
      await tapNew(tester); // 내용이 있다 → 묻는다 ("제목 없음")
      expect(find.text('저장하지 않은 변경 사항'), findsOneWidget);
      expect(find.textContaining('제목 없음의 변경 사항'), findsOneWidget);
      await act(tester, () => tester.tap(find.text('취소')));
      expect(text(tester), 'draft');
    },
  );

  testWidgets(
    'CRLF scripts keep CRLF when saved; non-UTF-8 files are refused with a message and change nothing',
    (tester) async {
      File(file('win.bat'))
          .writeAsBytesSync(utf8.encode('echo 1\r\necho 2\r\n'));
      File(file('cp949.txt')).writeAsBytesSync([0xC7, 0xD1, 0xB1, 0xDB]);
      dialogs.openAnswers.addAll([file('win.bat'), file('cp949.txt')]);
      await pumpSender(tester);

      await tapOpen(tester);
      expect(text(tester), 'echo 1\necho 2\n'); // 칸 안에서는 LF
      await typeText(tester, 'echo 1\necho 2\necho 3\n');
      await tapSave(tester);
      expect(
        File(file('win.bat')).readAsBytesSync(),
        utf8.encode('echo 1\r\necho 2\r\necho 3\r\n'),
      );

      await tapOpen(tester);
      expect(find.text('UTF-8 텍스트 파일만 열 수 있습니다'), findsOneWidget);
      expect(find.text('win.bat'), findsOneWidget); // 하던 문서가 그대로
      expect(text(tester), 'echo 1\necho 2\necho 3\n');
    },
  );

  testWidgets(
    'sending the last line (which appends a newline) does not count as a change',
    (tester) async {
      File(file('s.txt')).writeAsStringSync('one\ntwo');
      dialogs.openAnswers.add(file('s.txt'));
      await pumpSender(tester);
      await tapOpen(tester);
      await tester.tap(field());
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter); // one
      await tester.sendKeyEvent(LogicalKeyboardKey.enter); // two → 끝에 새 줄이 붙는다
      await tester.pump();
      expect(text(tester).endsWith('\n'), isTrue);
      expect(find.textContaining('●'), findsNothing);
    },
  );

  testWidgets(
    'a script is kept per tab and works while no shell is connected (write ahead)',
    (tester) async {
      dialogs.saveAnswers.add(file('ahead.txt'));
      await pumpSender(tester, connected: false);
      await typeText(tester, 'later 1\nlater 2');
      await tapSave(tester);
      expect(File(file('ahead.txt')).readAsStringSync(), 'later 1\nlater 2');
      expect(serial.written, isEmpty);
    },
  );

  testWidgets(
    'a very long file name shows only its first 20 characters and never overflows the bar',
    (tester) async {
      final longName = '${'very-long-script-name-' * 5}end.txt';
      File(file(longName)).writeAsStringSync('echo hi');
      dialogs.openAnswers.add(file(longName));
      await pumpSender(tester);

      await tapOpen(tester);
      expect(tester.takeException(), isNull);
      expect(find.text(longName), findsNothing);
      expect(find.text('${longName.substring(0, 20)}…'), findsOneWidget);
      final sender = tester.getRect(find.byType(LineSender));
      final chip = tester.getRect(
        find.byKey(const ValueKey('line-sender-name-chip')),
      );
      expect(chip.right, lessThanOrEqualTo(sender.right));
      expect(
        chip.right,
        lessThanOrEqualTo(
          tester.getRect(find.byIcon(Icons.note_add_outlined)).left,
        ),
      );
    },
  );
}
