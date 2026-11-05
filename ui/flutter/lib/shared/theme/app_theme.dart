import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/painting.dart' show TextStyle;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_charcoal.dart';
import 'app_palette.dart';
import 'app_theme_color.dart';

class AppTheme {
  const AppTheme._();

  // Flutter's automatic CJK fallback can select faces with mismatched weights
  // on Windows. Keep Geist for supported glyphs, but make the native Windows
  // UI font the deterministic fallback for Chinese text.
  static const _windowsFontFamilyFallback = <String>['Microsoft YaHei UI'];

  static bool get _usesWindowsFontFallback => !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

  static shad.Typography _typography() {
    if (defaultTargetPlatform == TargetPlatform.android) return _androidTypography;

    const typography = shad.Typography.geist();
    if (!_usesWindowsFontFallback) return typography;

    return typography.copyWith(
      // Do not pass `package` here: Flutter prefixes every fallback family
      // with the package name when it is set, including system font names.
      sans: () => const TextStyle(
        fontFamily: 'packages/shadcn_flutter/GeistSans',
        fontFamilyFallback: _windowsFontFamilyFallback,
      ),
    );
  }

  static shad.ThemeData light([AppThemeColor themeColor = AppThemeColor.green]) {
    return _buildTheme(palette: AppPalette.lightFor(themeColor), brightness: Brightness.light);
  }

  static shad.ThemeData dark([AppThemeColor themeColor = AppThemeColor.green]) {
    return _buildTheme(palette: AppPalette.darkFor(themeColor), brightness: Brightness.dark);
  }

  static shad.ThemeData _buildTheme({required AppPalette palette, required Brightness brightness}) {
    return shad.ThemeData(
      colorScheme: shad.ColorScheme.fromColors(
        brightness: brightness,
        colors: {
          'background': palette.bg,
          'foreground': palette.textPrimary,
          'card': palette.cardBg,
          'cardForeground': palette.textPrimary,
          'popover': palette.sideBg,
          'popoverForeground': palette.textPrimary,
          'primary': palette.brand,
          'primaryForeground': palette.brandForeground,
          'secondary': palette.surfaceSoft,
          'secondaryForeground': palette.textPrimary,
          'muted': palette.surfaceSoft,
          'mutedForeground': palette.textSecondary,
          'accent': palette.inputBg,
          'accentForeground': palette.textPrimary,
          'destructive': palette.error,
          'destructiveForeground': palette.bg,
          'border': palette.border,
          'input': palette.border,
          'ring': palette.brand,
          'chart1': palette.brand,
          'chart2': palette.textSecondary,
          'chart3': palette.textMuted,
          'chart4': palette.surfaceSoft,
          'chart5': palette.cardHoverBg,
        },
      ),
      typography: _typography(),
      radius: 0.5,
      scaling: 1,
      surfaceBlur: 0,
      surfaceOpacity: 1,
      platform: defaultTargetPlatform,
    );
  }

  static const shad.Typography _androidTypography = shad.Typography.geist(
    sans: material.TextStyle(),
    mono: material.TextStyle(fontFamily: 'monospace'),
    inlineCode: material.TextStyle(fontFamily: 'monospace', fontSize: 14, fontWeight: material.FontWeight.w600),
  );

  static material.ThemeData materialLight([AppThemeColor themeColor = AppThemeColor.green]) {
    return _buildMaterialTheme(palette: AppPalette.lightFor(themeColor), brightness: Brightness.light);
  }

  static material.ThemeData materialDark([AppThemeColor themeColor = AppThemeColor.green]) {
    return _buildMaterialTheme(palette: AppPalette.darkFor(themeColor), brightness: Brightness.dark);
  }

  static material.ThemeData _buildMaterialTheme({required AppPalette palette, required Brightness brightness}) {
    final theme = material.ThemeData.from(
      colorScheme: material.ColorScheme.fromSeed(
        seedColor: palette.brand,
        brightness: brightness,
        surface: palette.bg,
        primary: palette.brand,
      ),
      useMaterial3: true,
    );
    return theme.copyWith(
      extensions: <material.ThemeExtension<dynamic>>[palette],
      colorScheme: brightness == Brightness.dark
          ? theme.colorScheme.copyWith(
              surface: palette.bg,
              onSurface: palette.textPrimary,
              surfaceDim: palette.bg,
              surfaceBright: palette.cardHoverBg,
              surfaceContainerLowest: palette.bg,
              surfaceContainerLow: palette.cardBg,
              surfaceContainer: palette.cardBg,
              surfaceContainerHigh: palette.cardBg,
              surfaceContainerHighest: palette.inputBg,
              onSurfaceVariant: palette.textSecondary,
              primaryContainer: palette.inputBg,
              onPrimaryContainer: palette.textPrimary,
              secondary: palette.textSecondary,
              onSecondary: palette.bg,
              secondaryContainer: palette.inputBg,
              onSecondaryContainer: palette.textPrimary,
              error: palette.error,
              onError: palette.bg,
              errorContainer: palette.cardBg,
              onErrorContainer: palette.error,
              outline: palette.border,
              outlineVariant: palette.border,
              inverseSurface: palette.inputBg,
              onInverseSurface: palette.textPrimary,
              surfaceTint: const material.Color(0x00000000),
            )
          : theme.colorScheme,
      scaffoldBackgroundColor: palette.bg,
      canvasColor: palette.bg,
      cardColor: palette.cardBg,
      dividerColor: palette.border,
      hintColor: palette.searchHint,
      disabledColor: brightness == Brightness.dark ? AppCharcoal.disabled : theme.disabledColor,
      textSelectionTheme: brightness == Brightness.dark
          ? const material.TextSelectionThemeData(
              cursorColor: AppCharcoal.text,
              selectionColor: AppCharcoal.selection,
              selectionHandleColor: AppCharcoal.focus,
            )
          : theme.textSelectionTheme,
      textTheme: (_usesWindowsFontFallback
              ? theme.textTheme.apply(fontFamilyFallback: _windowsFontFamilyFallback)
              : theme.textTheme)
          .apply(
            bodyColor: brightness == Brightness.dark ? palette.textPrimary : null,
            displayColor: brightness == Brightness.dark ? palette.textPrimary : null,
          ),
      primaryTextTheme: (_usesWindowsFontFallback
              ? theme.primaryTextTheme.apply(fontFamilyFallback: _windowsFontFamilyFallback)
              : theme.primaryTextTheme)
          .apply(
            bodyColor: brightness == Brightness.dark ? palette.textPrimary : null,
            displayColor: brightness == Brightness.dark ? palette.textPrimary : null,
          ),
    );
  }
}
