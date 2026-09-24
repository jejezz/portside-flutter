import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'about/extra_licenses.dart';
import 'app.dart';
import 'app_identity.dart';
import 'settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerExtraLicenses();

  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    // 최소 크기: 툴바 한 줄(포트 선택/보드레이트/Connect/뷰 전환/도움말/설정)이
    // 겹치지 않는 최소 콘텐츠 폭은 위젯 테스트로 잰 값이 800px 부근이라
    // (790px부터 RenderFlex 오버플로) 여유를 두고 860으로 잡았다.
    const options = WindowOptions(
      size: Size(1200, 720),
      minimumSize: Size(860, 560),
      center: true,
      title: AppIdentity.displayName,
    );
    await windowManager.waitUntilReadyToShow(options, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final settings = await AppSettings.load();
  runApp(PortsideApp(settings: settings));
}
