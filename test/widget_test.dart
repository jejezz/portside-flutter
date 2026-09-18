import 'package:flutter_test/flutter_test.dart';
import 'package:portside/app.dart';

void main() {
  testWidgets('홈 화면이 크래시 없이 뜨는지', (WidgetTester tester) async {
    await tester.pumpWidget(const PortsideApp());
    expect(find.text('Connect'), findsOneWidget);
    expect(find.byTooltip('Terminal'), findsOneWidget);
  });
}
