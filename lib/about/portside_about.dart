import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';
import 'about_dialog.dart';

/// Portside의 정보 창 문구. 공통 about_dialog.dart는 템플릿과 같게 두고,
/// 앱마다 다른 부분만 여기서 넘긴다 (conventions/about-dialog.md §3).
Future<void> showPortsideAbout(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showAppAboutDialog(
    context,
    tagline: l10n.aboutTagline,
    description: l10n.aboutDescription,
    features: [
      l10n.aboutFeature1,
      l10n.aboutFeature2,
      l10n.aboutFeature3,
      l10n.aboutFeature4,
      l10n.aboutFeature5,
      l10n.aboutFeature6,
    ],
  );
}
