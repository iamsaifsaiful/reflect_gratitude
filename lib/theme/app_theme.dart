import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Dark status-bar icons, for screens on the cream background.
const SystemUiOverlayStyle darkStatusBar = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.dark, // Android
  statusBarBrightness: Brightness.light, // iOS
  systemNavigationBarColor: AppColors.surface,
  systemNavigationBarIconBrightness: Brightness.dark,
);

/// Light status-bar icons, for screens that open on artwork.
const SystemUiOverlayStyle lightStatusBar = SystemUiOverlayStyle(
  statusBarColor: Color(0x00000000),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: AppColors.surface,
  systemNavigationBarIconBrightness: Brightness.dark,
);

/// Type: Spectral (serif) for headings and numbers, Nunito Sans for everything else.
class AppText {
  AppText._();

  static const String serif = 'Spectral';
  static const String sans = 'NunitoSans';

  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = AppColors.ink,
    double height = 1.15,
    FontStyle style = FontStyle.normal,
  }) =>
      TextStyle(
        fontFamily: serif,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        fontStyle: style,
      );

  static TextStyle body(
    double size, {
    FontWeight weight = FontWeight.w600,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  /// Small uppercase label above a section. Pass text already upper-cased.
  static const TextStyle eyebrow = TextStyle(
    fontFamily: sans,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.5,
    color: AppColors.eyebrow,
  );
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.terracotta).copyWith(
    primary: AppColors.terracotta,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.sage,
    onSecondary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.ink,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppText.sans,
    splashFactory: InkRipple.splashFactory,
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.terracotta,
      selectionColor: AppColors.terracotta.withValues(alpha: 0.25),
      selectionHandleColor: AppColors.terracotta,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.ink,
      contentTextStyle: AppText.body(14, color: AppColors.onAccent),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  );
}
