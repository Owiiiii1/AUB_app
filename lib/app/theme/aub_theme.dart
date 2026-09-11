import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';

ThemeData buildAubTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AubColors.navy,
    primary: AubColors.navy,
    onPrimary: AubColors.onNavy,
    secondary: AubColors.burgundy,
    onSecondary: AubColors.onNavy,
    tertiary: AubColors.gold,
    surface: AubColors.surfaceIvory,
    onSurface: AubColors.textPrimary,
    error: AubColors.alert,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AubColors.surfaceIvory,
    fontFamily: AubFonts.body,
    textTheme: const TextTheme(
      headlineLarge: AubText.headlineLg,
      headlineMedium: AubText.headlineMd,
      headlineSmall: AubText.headlineSm,
      titleLarge: AubText.headlineMd,
      titleMedium: AubText.headlineSm,
      titleSmall: AubText.headlineSm,
      bodyLarge: AubText.bodyLg,
      bodyMedium: AubText.bodyMd,
      bodySmall: AubText.bodySm,
      labelLarge: AubText.labelMd,
      labelMedium: AubText.labelMd,
      labelSmall: AubText.labelSm,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AubColors.surfaceIvory,
      foregroundColor: AubColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: AubText.headlineSm,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AubColors.surfaceCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AubRadii.lg),
        borderSide: const BorderSide(color: AubColors.borderMuted),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AubRadii.lg),
        borderSide: const BorderSide(color: AubColors.borderMuted),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AubRadii.lg),
        borderSide: const BorderSide(color: AubColors.navy, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AubRadii.lg),
        borderSide: const BorderSide(color: AubColors.alert, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AubColors.navy,
        foregroundColor: AubColors.onNavy,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AubRadii.lg),
        ),
        textStyle: AubText.labelMd.copyWith(color: AubColors.onNavy),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AubColors.navy,
        minimumSize: const Size(48, 48),
        side: const BorderSide(color: AubColors.navy),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AubRadii.lg),
        ),
      ),
    ),
    dividerColor: AubColors.borderHairline,
    cardTheme: CardThemeData(
      color: AubColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AubRadii.xl),
        side: const BorderSide(color: AubColors.borderMuted),
      ),
    ),
  );
}
