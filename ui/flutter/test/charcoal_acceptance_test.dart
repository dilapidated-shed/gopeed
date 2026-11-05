import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gopeed/app/application/app_appearance_controller.dart';
import 'package:gopeed/core/window/app_window_appearance.dart';
import 'package:gopeed/shared/theme/app_charcoal.dart';
import 'package:gopeed/shared/theme/app_component_themes.dart';
import 'package:gopeed/shared/theme/app_palette.dart';
import 'package:gopeed/shared/theme/app_theme.dart';
import 'package:gopeed/shared/widgets/app_text_field.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

const _boundary = ValueKey('charcoal-shared-controls');

double _contrast(Color first, Color second) {
  final a = first.computeLuminance();
  final b = second.computeLuminance();
  return ((a > b ? a : b) + 0.05) / ((a > b ? b : a) + 0.05);
}

Future<bool> _capture(WidgetTester tester, String name) async {
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(_boundary));
  final isCharcoal = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    try {
      final rgba = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!.buffer.asUint8List();
      final firstPixelIsCharcoal = rgba[0] == 33 && rgba[1] == 33 && rgba[2] == 33 && rgba[3] == 255;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      final directory = Directory('../../build/charcoal-gopeed')..createSync(recursive: true);
      File('${directory.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
      return firstPixelIsCharcoal;
    } finally {
      image.dispose();
    }
  });
  return isCharcoal!;
}

Widget _controls(TextEditingController controller, {bool light = false}) {
  return shad.ShadcnApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    materialTheme: light ? AppTheme.materialLight() : AppTheme.materialDark(),
    themeMode: light ? shad.ThemeMode.light : shad.ThemeMode.dark,
    home: AppComponentThemes(
      child: RepaintBoundary(
        key: _boundary,
        child: shad.Scaffold(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Body ink'),
                const SizedBox(height: 16),
                AppTextField(controller: controller, placeholder: const Text('Input hint')),
                const SizedBox(height: 16),
                shad.SecondaryButton(onPressed: () {}, child: const Text('Action')),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  test('unset main and child appearances are dark, preserving explicit saved choices', () {
    const appearance = AppAppearanceState();
    for (final brightness in Brightness.values) {
      expect(appearance.resolveIsLight(brightness), isFalse);
    }
    expect(AppThemeMode.fromKey(null), AppThemeMode.dark);
    expect(AppThemeMode.fromKey(''), AppThemeMode.dark);
    expect(AppThemeMode.fromKey('light'), AppThemeMode.light);
    expect(AppThemeMode.fromKey('system'), AppThemeMode.system);
    expect(const AppWindowAppearance.defaults().themeMode, 'dark');
    expect(AppWindowAppearance.fromJson({}).themeMode, 'dark');
    expect(AppWindowAppearance.fromJson({'themeMode': 'light'}).themeMode, 'light');
  });

  test('ordinary dark text and semantic text meet AA on every maintained neutral surface', () {
    final palette = AppPalette.dark;
    for (final surface in [palette.bg, palette.cardBg, palette.inputBg, palette.cardHoverBg]) {
      for (final text in [
        palette.textPrimary,
        palette.textSecondary,
        palette.textMuted,
        palette.taskMeta,
        palette.taskMetaSubtle,
        palette.searchHint,
        palette.error,
        palette.success,
      ]) {
        expect(_contrast(text, surface), greaterThanOrEqualTo(4.5));
      }
    }
    expect(_contrast(palette.primaryActionForeground, palette.primaryActionBg), greaterThanOrEqualTo(4.5));
    final material = AppTheme.materialDark();
    expect(material.colorScheme.surface, AppCharcoal.background);
    expect(material.colorScheme.onSurface, AppCharcoal.text);
    expect(material.colorScheme.surfaceContainer, AppCharcoal.surface);
    expect(material.colorScheme.inverseSurface, AppCharcoal.interactive);
    expect(material.colorScheme.onInverseSurface, AppCharcoal.text);
    expect(material.textSelectionTheme.cursorColor, AppCharcoal.text);
    expect(material.textSelectionTheme.selectionColor, AppCharcoal.selection);
  });

  for (final brightness in Brightness.values) {
    for (final width in [390.0, 768.0, 1280.0]) {
      testWidgets('shared charcoal controls at $width under system $brightness', (tester) async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        tester.platformDispatcher.platformBrightnessTestValue = brightness;
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 900);
        final controller = TextEditingController();
        addTearDown(() {
          controller.dispose();
          tester.platformDispatcher.clearPlatformBrightnessTestValue();
          tester.view.resetDevicePixelRatio();
          tester.view.resetPhysicalSize();
        });
        try {
          await tester.pumpWidget(_controls(controller));
          await tester.pumpAndSettle();
          final context = tester.element(find.text('Body ink'));
          expect(shad.Theme.of(context).brightness, Brightness.dark);
          expect(shad.Theme.of(context).colorScheme.background, AppCharcoal.background);
          expect(DefaultTextStyle.of(context).style.color, AppCharcoal.text);
          final name = '${width.toInt()}-${brightness.name}';
          expect(await _capture(tester, '$name-empty'), isTrue);

          await tester.enterText(find.byType(AppTextField), 'λğ✓ retained input');
          await tester.pumpAndSettle();
          controller.selection = const TextSelection(baseOffset: 0, extentOffset: 3);
          await tester.pump();
          expect(controller.text, 'λğ✓ retained input');
          expect(controller.selection.textInside(controller.text), 'λğ✓');
          expect(tester.takeException(), isNull);
          expect(await _capture(tester, '$name-input-selection'), isTrue);

          await tester.pumpWidget(_controls(controller, light: true));
          await tester.pumpAndSettle();
          expect(await _capture(tester, '$name-declared-light-negative'), isFalse);
        } finally {
          debugDefaultTargetPlatformOverride = null;
        }
      });
    }
  }
}
