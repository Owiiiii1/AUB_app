import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';

class AubFonts {
  const AubFonts._();

  static const display = 'Oswald';
  static const body = 'Work Sans';
}

class AubText {
  const AubText._();

  static const headlineXl = TextStyle(
    fontFamily: AubFonts.display,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 38 / 32,
    letterSpacing: 0.04 * 32,
    color: AubColors.textPrimary,
  );

  static const headlineLg = TextStyle(
    fontFamily: AubFonts.display,
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 30 / 24,
    letterSpacing: 0.03 * 24,
    color: AubColors.textPrimary,
  );

  static const headlineMd = TextStyle(
    fontFamily: AubFonts.display,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 26 / 20,
    letterSpacing: 0.02 * 20,
    color: AubColors.textPrimary,
  );

  static const headlineSm = TextStyle(
    fontFamily: AubFonts.display,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 22 / 16,
    letterSpacing: 0.02 * 16,
    color: AubColors.textPrimary,
  );

  static const bodyLg = TextStyle(
    fontFamily: AubFonts.body,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    color: AubColors.textPrimary,
  );

  static const bodyMd = TextStyle(
    fontFamily: AubFonts.body,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    color: AubColors.textPrimary,
  );

  static const bodySm = TextStyle(
    fontFamily: AubFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 18 / 13,
    color: AubColors.textSecondary,
  );

  static const labelCaps = TextStyle(
    fontFamily: AubFonts.display,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    letterSpacing: 0.08 * 11,
    color: AubColors.textSecondary,
  );

  static const labelMd = TextStyle(
    fontFamily: AubFonts.body,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 16 / 13,
    color: AubColors.textPrimary,
  );

  static const labelSm = TextStyle(
    fontFamily: AubFonts.body,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 14 / 11,
    color: AubColors.textSecondary,
  );
}
