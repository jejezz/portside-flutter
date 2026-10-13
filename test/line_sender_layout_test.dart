import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portside/l10n/app_localizations.dart';
import 'package:portside/models/connection_settings.dart';
import 'package:portside/models/line_ending.dart';
import 'package:portside/state/terminal_session_provider.dart';
import 'package:portside/theme/tokens.dart';
import 'package:portside/widgets/glass_card.dart';
import 'package:portside/widgets/line_sender.dart';
import 'package:provider/provider.dart';

import 'helpers/fake_serial.dart';

void main() {
  late FakeSerialService serial;
  late TerminalSessionProvider session;

  setUp(() {
    serial = FakeSerialService();
    session = TerminalSessionProvider(serial);
  });

  tearDown(() => session.dispose());

  Future<void> pumpSender(
    WidgetTester tester, {
    required double height,
    double width = 700,
  }) async {
    tester.view.physicalSize = const Size(900, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ChangeNotifierProvider<TerminalSessionProvider>.value(
        value: session,
        child: MaterialApp(
          theme: AppTheme.dark().copyWith(extensions: [PortsideColors.dark]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ko'),
          home: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                width: width,
                height: height,
                child: const LineSender(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Rect rectOf(WidgetTester tester, Finder f) => tester.getRect(f);

  Finder newFile() => find.byIcon(Icons.note_add_outlined);
  Finder open() => find.byIcon(Icons.folder_open_rounded);
  Finder save() => find.byIcon(Icons.save_outlined);
  Finder saveAs() => find.byIcon(Icons.save_as_outlined);
  List<Finder> fileButtons() => [newFile(), open(), save(), saveAs()];

  /// 아이콘이 아니라 배지 전체를 찾는다.
  Finder badgeOf(Finder icon) =>
      find.ancestor(of: icon, matching: find.byType(IconBadge));
  Finder endingChip() => find.byType(PopupMenuButton<LineEnding>);
  Finder sendButton() => badgeOf(find.byIcon(Icons.send_rounded));
  Finder echo() => find.byType(Switch);
  Finder box() => find.byKey(const ValueKey('line-sender-box'));
  Finder nameChip() => find.byKey(const ValueKey('line-sender-name-chip'));

  /// 하단 줄 위쪽에 선(1px)이 있는 박스 — 버튼들을 감싸고 있다.
  Finder dividerBar() => find.byWidgetPredicate((w) {
    if (w is! Container) return false;
    final d = w.decoration;
    if (d is! BoxDecoration) return false;
    final border = d.border;
    return border is Border &&
        border.top.style == BorderStyle.solid &&
        border.top.width == 1 &&
        border.bottom.style == BorderStyle.none;
  });

  testWidgets(
    'the four file buttons are in the bottom bar, left-aligned, in editor order, on one line',
    (tester) async {
      await pumpSender(tester, height: 200);
      final sender = tester.getRect(find.byType(LineSender));
      final field = rectOf(tester, find.byType(TextField));
      final rects = [for (final b in fileButtons()) rectOf(tester, badgeOf(b))];

      for (var i = 0; i < rects.length; i++) {
        expect(
          rects[i].top,
          greaterThanOrEqualTo(field.bottom - 1),
          reason: '버튼 $i가 입력 칸 아래에 있어야 한다',
        );
      }
      for (var i = 0; i < rects.length - 1; i++) {
        expect(
          rects[i].right,
          lessThanOrEqualTo(rects[i + 1].left + 1),
          reason: '버튼 $i가 다음 버튼과 겹친다',
        );
        expect(
          rects[i].center.dy,
          closeTo(rects[i + 1].center.dy, 0.01),
          reason: '한 줄이 아니다',
        );
      }
      // 파일 이름 칩이 맨 왼쪽, 그 바로 오른쪽에 버튼들이 이어진다.
      final chip = rectOf(tester, nameChip());
      expect(chip.left, closeTo(sender.left, 1));
      expect(rects.first.left, greaterThanOrEqualTo(chip.right));
    },
  );

  testWidgets(
    'Echo, the line ending chip and the send button are right-aligned on the same bar',
    (tester) async {
      await pumpSender(tester, height: 200);
      final sender = tester.getRect(find.byType(LineSender));
      final echoRect = rectOf(tester, echo());
      final chip = rectOf(tester, endingChip());
      final send = rectOf(tester, sendButton());
      final saveAsBadge = rectOf(tester, badgeOf(saveAs()));

      expect(send.right, closeTo(sender.right, 1));
      expect(chip.right, lessThan(send.left));
      expect(echoRect.right, lessThanOrEqualTo(chip.left + 1));
      expect(chip.center.dy, closeTo(send.center.dy, 0.5));
      expect(echoRect.center.dy, closeTo(send.center.dy, 1.5));
      expect(
        chip.center.dy,
        closeTo(saveAsBadge.center.dy, 0.5),
        reason: '파일 버튼과 같은 줄이어야 한다',
      );
      // 왼쪽 그룹과 오른쪽 그룹이 겹치지 않는다.
      expect(
        saveAsBadge.right,
        lessThan(rectOf(tester, find.text('Echo')).left),
      );
    },
  );

  testWidgets(
    'the existing Echo switch and send button keep working from the new bar',
    (tester) async {
      await pumpSender(tester, height: 200);
      expect(session.localEcho, isTrue);
      await tester.tap(echo());
      await tester.pump();
      expect(session.localEcho, isFalse);

      session.connect(
        const ConnectionSettings(portName: 'TEST', baudRate: 115200),
      );
      serial.clearWritten();
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'AT');
      await tester.tap(sendButton());
      await tester.pump();
      expect(serial.writtenText, 'AT\n'); // Portside의 기본 줄 끝은 LF
    },
  );

  testWidgets(
    'the name chip is in the bottom bar, before the New button; nothing sits above the text',
    (tester) async {
      await pumpSender(tester, height: 200);
      final sender = tester.getRect(find.byType(LineSender));
      final inputBox = rectOf(tester, box());
      final chip = rectOf(tester, nameChip());
      final name = rectOf(tester, find.text('제목 없음'));
      final newBtn = rectOf(tester, badgeOf(newFile()));

      expect(inputBox.top, closeTo(sender.top, 1));
      expect(chip.top, greaterThanOrEqualTo(inputBox.bottom - 1));
      expect(chip.left, closeTo(sender.left, 1));
      expect(chip.right, lessThanOrEqualTo(newBtn.left));
      expect(chip.center.dy, closeTo(newBtn.center.dy, 0.5));
      expect(name.left, greaterThanOrEqualTo(chip.left));
      expect(name.right, lessThanOrEqualTo(chip.right));
    },
  );

  testWidgets(
    'the name chip is a rounded pill in the app\'s StatusPill style: tinted fill and outline, accent color',
    (tester) async {
      await pumpSender(tester, height: 200);
      final scheme = Theme.of(tester.element(find.byType(LineSender)))
          .colorScheme;
      final d =
          tester.widget<Container>(nameChip()).decoration! as BoxDecoration;
      expect(d.borderRadius, BorderRadius.circular(AppRadius.chip));
      expect(d.border, isNotNull);
      expect(d.color, isNotNull);
      expect(
        d.color!.a,
        lessThan(0.3),
        reason: '옅은 색조 배경 (StatusPill과 같은 14%)',
      );

      // 본문 글자와 다른 강조색이다.
      final body = tester
          .widget<TextField>(find.byType(TextField))
          .style
          ?.color;
      final nameColor = tester.widget<Text>(find.text('제목 없음')).style?.color;
      expect(body, scheme.onSurface);
      expect(nameColor, scheme.primary);
      expect(nameColor, isNot(body));
    },
  );

  testWidgets(
    'unsaved changes switch the chip (text, icon, fill) to the warning color',
    (tester) async {
      await pumpSender(tester, height: 200);
      final cleanText = tester.widget<Text>(find.text('제목 없음')).style?.color;
      final cleanFill =
          (tester.widget<Container>(nameChip()).decoration! as BoxDecoration)
              .color;
      await tester.enterText(find.byType(TextField), 'AT+GMR');
      await tester.pump();
      final modifiedText = tester
          .widget<Text>(find.textContaining('제목 없음'))
          .style
          ?.color;
      expect(modifiedText, isNot(cleanText));
      expect(modifiedText, AppColors.warning); // 다크 테마
      expect(
        (tester.widget<Container>(nameChip()).decoration! as BoxDecoration)
            .color,
        isNot(cleanFill),
      );
      final icon = tester.widget<Icon>(
        find.descendant(of: nameChip(), matching: find.byType(Icon)),
      );
      expect(icon.color, modifiedText);
    },
  );

  testWidgets('tapping the chip focuses the input box', (tester) async {
    await pumpSender(tester, height: 200);
    final node = tester.widget<TextField>(find.byType(TextField)).focusNode!;
    expect(node.hasFocus, isFalse);
    await tester.tap(nameChip());
    await tester.pump();
    expect(node.hasFocus, isTrue);
  });

  testWidgets(
    'a line above the button bar separates it from the box: below the box, as wide as the box',
    (tester) async {
      await pumpSender(tester, height: 200);
      final bar = rectOf(tester, dividerBar());
      final field = rectOf(tester, find.byType(TextField));
      expect(bar.top, greaterThanOrEqualTo(field.bottom - 1));
      expect(bar.left, closeTo(field.left, 1));
      expect(bar.right, closeTo(field.right, 1));
      for (final f in [
        ...fileButtons().map(badgeOf),
        endingChip(),
        sendButton(),
      ]) {
        final r = rectOf(tester, f);
        expect(
          r.top,
          greaterThanOrEqualTo(bar.top + 1),
          reason: '버튼이 선 위로 올라갔다',
        );
        expect(r.bottom, lessThanOrEqualTo(bar.bottom));
      }
    },
  );

  testWidgets(
    'the bottom bar and its line stay glued to the bottom and keep their size at any height',
    (tester) async {
      final fromBottom = <double, List<double>>{};
      final lefts = <double, List<double>>{};
      final sizes = <double, List<Size>>{};
      final lineFromBottom = <double, double>{};
      for (final h in [LineSender.minHeight, 150.0, 220.0, 400.0]) {
        await pumpSender(tester, height: h);
        final sender = tester.getRect(find.byType(LineSender));
        final targets = [
          ...fileButtons().map(badgeOf),
          endingChip(),
          sendButton(),
        ];
        final rects = [for (final f in targets) rectOf(tester, f)];
        fromBottom[h] = [for (final r in rects) sender.bottom - r.bottom];
        lefts[h] = [for (final r in rects) r.left - sender.left];
        sizes[h] = [for (final r in rects) r.size];
        lineFromBottom[h] = sender.bottom - rectOf(tester, dividerBar()).top;
        expect(tester.takeException(), isNull, reason: '높이 $h에서 넘침이 있다');
      }
      final base = LineSender.minHeight;
      for (final h in fromBottom.keys) {
        for (var i = 0; i < fromBottom[h]!.length; i++) {
          expect(
            fromBottom[h]![i],
            closeTo(fromBottom[base]![i], 0.01),
            reason: '높이 $h, 컨트롤 $i가 맨 아래에서 떨어졌다',
          );
          expect(
            lefts[h]![i],
            closeTo(lefts[base]![i], 0.01),
            reason: '높이 $h, 컨트롤 $i의 가로 위치가 바뀌었다',
          );
          expect(
            sizes[h]![i],
            sizes[base]![i],
            reason: '높이 $h, 컨트롤 $i의 크기가 바뀌었다',
          );
        }
        expect(
          lineFromBottom[h],
          closeTo(lineFromBottom[base]!, 0.01),
          reason: '높이 $h에서 선의 위치가 달라졌다',
        );
      }
    },
  );

  testWidgets(
    'at LineSender.minHeight everything is intact and the box still has room for a line',
    (tester) async {
      await pumpSender(tester, height: LineSender.minHeight);
      expect(tester.takeException(), isNull);
      expect(
        rectOf(tester, find.byType(TextField)).height,
        greaterThanOrEqualTo(40),
      );
      final sender = tester.getRect(find.byType(LineSender));
      for (final f in [
        nameChip(),
        ...fileButtons(),
        echo(),
        endingChip(),
        sendButton(),
      ]) {
        final r = rectOf(tester, f);
        expect(r.top, greaterThanOrEqualTo(sender.top), reason: '위로 잘렸다');
        expect(r.bottom, lessThanOrEqualTo(sender.bottom), reason: '아래로 잘렸다');
      }
    },
  );

  testWidgets(
    'the buttons are IconBadge squares of the app\'s own style, 36px, and the box uses the full width',
    (tester) async {
      await pumpSender(tester, height: 200);
      for (final b in [...fileButtons(), find.byIcon(Icons.send_rounded)]) {
        expect(tester.getSize(badgeOf(b)), const Size(36, 36));
      }
      final sender = tester.getRect(find.byType(LineSender));
      final field = rectOf(tester, find.byType(TextField));
      expect(field.left, closeTo(sender.left, 1));
      expect(field.right, closeTo(sender.right, 1));
    },
  );

  testWidgets('the box keeps Portside\'s inset fill', (tester) async {
    await pumpSender(tester, height: 200);
    final fill =
        (tester.widget<Container>(box()).decoration! as BoxDecoration).color;
    expect(fill, PortsideColors.dark.inset);
  });

  testWidgets(
    'choosing a line ending from the chip changes what the sender appends',
    (tester) async {
      await pumpSender(tester, height: 200);
      expect(find.text(r'\n'), findsOneWidget); // Portside의 기본 줄 끝
      await tester.tap(endingChip());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.text(r'\r\n').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(session.lineEnding, LineEnding.crlf);
      expect(find.text(r'\r\n'), findsOneWidget);
    },
  );

  testWidgets(
    'a fairly narrow sender (520 wide) does not overflow and keeps the groups apart',
    (tester) async {
      await pumpSender(tester, height: 160, width: 520);
      expect(tester.takeException(), isNull);
      expect(
        rectOf(tester, badgeOf(saveAs())).right,
        lessThan(rectOf(tester, find.text('Echo')).left),
      );
      expect(
        rectOf(tester, sendButton()).right,
        lessThanOrEqualTo(tester.getRect(find.byType(LineSender)).right),
      );
    },
  );

  testWidgets(
    'inside the app\'s GlassCard the card padding provides the margin',
    (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        ChangeNotifierProvider<TerminalSessionProvider>.value(
          value: session,
          child: MaterialApp(
            theme: AppTheme.dark().copyWith(extensions: [PortsideColors.dark]),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('ko'),
            home: Scaffold(
              body: Align(
                alignment: Alignment.bottomCenter,
                child: SizedBox(
                  height: LineSender.minHeight + 26,
                  child: GlassCard(
                    padding: const EdgeInsets.all(12),
                    child: const LineSender(),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final card = tester.getRect(find.byType(GlassCard));
      final sender = tester.getRect(find.byType(LineSender));
      expect(sender.left - card.left, closeTo(13, 1)); // 카드 보더 1 + 여백 12
      expect(sender.height, closeTo(LineSender.minHeight, 1));
    },
  );
}
