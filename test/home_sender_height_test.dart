import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portside/app.dart';
import 'package:portside/settings/app_settings.dart';
import 'package:portside/widgets/line_sender.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 홈 화면은 터미널 영역과 LineSender 영역을 "남는 공간의 비율(flex)"로 나눈다. 그래서 LineSender가 필요로 하는 최소
/// 높이를 지키려면 비율의 하한을 창 높이에 맞춰 계산해야 한다. 이 테스트는 실제 고정 요소(툴바, 상태 바 등)가 있는
/// 상태에서 창 크기와 구분선 위치를 바꿔 가며 그것을 확인한다.
Future<void> _pumpApp(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  SharedPreferences.setMockInitialValues({AppSettings.localeKey: 'ko'});
  final settings = await AppSettings.load();
  await tester.pumpWidget(PortsideApp(settings: settings));
  await tester.pump();
}

Finder _divider() => find.byWidgetPredicate(
  (w) => w is MouseRegion && w.cursor == SystemMouseCursors.resizeUpDown,
);

void main() {
  // 앱의 최소 창 크기(860x560), 기본 창 크기(1200x720), 큰 화면.
  const sizes = [Size(860, 560), Size(1200, 720), Size(1920, 1080)];

  for (final size in sizes) {
    group('window ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('the LineSender is fully visible at the default split', (
        tester,
      ) async {
        await _pumpApp(tester, size);
        expect(tester.takeException(), isNull);
        final r = tester.getRect(find.byType(LineSender));
        expect(
          r.height,
          greaterThanOrEqualTo(LineSender.minHeight),
          reason: '기본 비율에서 LineSender가 잘렸다',
        );
        expect(r.bottom, lessThanOrEqualTo(size.height));
        // 이름 칩과 하단 줄의 버튼이 모두 화면 안에 있다.
        expect(
          tester
              .getRect(find.byKey(const ValueKey('line-sender-name-chip')))
              .top,
          greaterThanOrEqualTo(0),
        );
        expect(
          tester.getRect(find.byIcon(Icons.send_rounded)).bottom,
          lessThanOrEqualTo(size.height),
        );
      });

      testWidgets(
        'dragging the divider all the way down stops at the minimum (nothing is cut off)',
        (tester) async {
          await _pumpApp(tester, size);
          final before = tester.getRect(find.byType(LineSender)).height;
          await tester.drag(_divider(), Offset(0, size.height)); // 영역을 줄이는 방향
          await tester.pump();
          expect(tester.takeException(), isNull);
          final r = tester.getRect(find.byType(LineSender));
          expect(r.height, lessThanOrEqualTo(before + 0.5));
          expect(
            r.height,
            greaterThanOrEqualTo(LineSender.minHeight),
            reason: '끝까지 줄였을 때 LineSender가 잘렸다',
          );
          // 하단 줄(전송 버튼)이 그대로 보인다.
          final send = tester.getRect(find.byIcon(Icons.send_rounded));
          expect(send.bottom, lessThanOrEqualTo(r.bottom));
          expect(send.top, greaterThanOrEqualTo(r.top));
        },
      );

      testWidgets(
        'dragging the divider all the way up grows the area without overflow',
        (tester) async {
          await _pumpApp(tester, size);
          final before = tester.getRect(find.byType(LineSender)).height;
          await tester.drag(_divider(), Offset(0, -size.height));
          await tester.pump();
          expect(tester.takeException(), isNull);
          expect(
            tester.getRect(find.byType(LineSender)).height,
            greaterThan(before),
          );
        },
      );
    });
  }

  testWidgets(
    'the terminal area keeps a usable height even at the minimum window with the sender at its minimum',
    (tester) async {
      await _pumpApp(tester, const Size(860, 560));
      await tester.drag(_divider(), const Offset(0, 560));
      await tester.pump();
      expect(tester.takeException(), isNull);
      final sender = tester.getRect(find.byType(LineSender));
      final divider = tester.getRect(_divider());
      // 터미널(위쪽 카드)은 툴바 아래부터 구분선 위까지 — 최소한 몇 줄은 보일 높이가 남는다.
      final terminalHeight = divider.top - 130;
      expect(
        terminalHeight,
        greaterThan(120),
        reason: 'LineSender가 너무 많이 차지해서 터미널이 눌렸다 (센더 높이 ${sender.height})',
      );
    },
  );
}
