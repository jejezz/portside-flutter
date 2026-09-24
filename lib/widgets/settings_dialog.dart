import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/app_terminal_theme.dart';
import '../state/settings_provider.dart';
import '../theme/tokens.dart';

String _paletteLabel(AppLocalizations l10n, AppTerminalTheme palette) =>
    palette.label ??
    switch (palette) {
      AppTerminalTheme.defaultDark => l10n.paletteDefaultDark,
      AppTerminalTheme.whiteOnBlack => l10n.paletteWhiteOnBlack,
      AppTerminalTheme.greenPhosphor => l10n.paletteGreenPhosphor,
      AppTerminalTheme.light => l10n.paletteLight,
      _ => palette.name,
    };

class SettingsDialog extends StatelessWidget {
  const SettingsDialog({super.key});

  InputDecoration _insetDecoration(BuildContext context, {required String label, String? helper, Widget? prefixIcon}) {
    return InputDecoration(
      labelText: label,
      helperText: helper,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: PortsideColors.of(context).inset,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.tile),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.settings_rounded, size: 24, color: scheme.primary),
          const SizedBox(width: 10),
          Text(l10n.settingsTitle),
        ],
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              initialValue: settings.fontFamily,
              decoration: _insetDecoration(context, label: l10n.settingsFont),
              items: [
                for (final f in kFontFamilies) DropdownMenuItem(value: f, child: Text(f, style: TextStyle(fontFamily: f))),
              ],
              onChanged: (value) {
                if (value != null) settings.setFontFamily(value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(l10n.settingsFontSize, style: TextStyle(color: scheme.onSurfaceVariant)),
                Expanded(
                  child: Slider(
                    value: settings.fontSize,
                    min: 10,
                    max: 24,
                    divisions: 14,
                    activeColor: scheme.primary,
                    label: settings.fontSize.toStringAsFixed(0),
                    onChanged: settings.setFontSize,
                  ),
                ),
                SizedBox(width: 24, child: Text(settings.fontSize.toStringAsFixed(0))),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<AppTerminalTheme>(
              initialValue: settings.appTheme,
              decoration: _insetDecoration(
                context,
                label: l10n.settingsPalette,
                prefixIcon: const Icon(Icons.palette_rounded, size: 20, color: AppColors.accent),
              ),
              items: [
                for (final t in AppTerminalTheme.values) DropdownMenuItem(value: t, child: Text(_paletteLabel(l10n, t))),
              ],
              onChanged: (value) {
                if (value != null) settings.setAppTheme(value);
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: settings.scrollbackLines,
              decoration: _insetDecoration(context, label: l10n.settingsScrollback, helper: l10n.settingsScrollbackHelper),
              items: [
                for (final n in kScrollbackLinesOptions) DropdownMenuItem(value: n, child: Text(l10n.settingsScrollbackOption(n))),
              ],
              onChanged: (value) {
                if (value != null) settings.setScrollbackLines(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l10n.commonClose)),
      ],
    );
  }
}
