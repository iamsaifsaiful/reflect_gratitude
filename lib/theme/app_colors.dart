import 'package:flutter/painting.dart';

/// The warm, organic palette from the approved design.
class AppColors {
  AppColors._();

  // Grounds
  static const background = Color(0xFFF4EBDE); // warm cream
  static const surface = Color(0xFFFFFCF7); // cards
  static const surfaceWarm = Color(0xFFFBEEE0); // quote and link cards
  static const field = Color(0xFFFBF4EA); // text fields

  // Text
  static const ink = Color(0xFF38302A);
  static const inkSoft = Color(0xFF4A3B2E);
  static const body = Color(0xFF5E5445);
  static const muted = Color(0xFF8A7C6C);
  static const subtle = Color(0xFF9C9080);
  static const faint = Color(0xFFB7AB9B);
  static const eyebrow = Color(0xFFB0755A);

  // Lines and tracks
  static const line = Color(0xFFEDE2D2);
  static const lineWarm = Color(0xFFEBD9C4);
  static const track = Color(0xFFE4D6C4);
  static const empty = Color(0xFFEFE4D6);
  static const quoteMark = Color(0xFFDDB68C);
  static const activeBorder = Color(0xFFE4B79C);

  // Accents. Each daily prompt owns one.
  static const terracotta = Color(0xFFBE6A47); // primary, Reflection
  static const terracottaDark = Color(0xFFA24E2E);
  static const terracottaSoft = Color(0xFFF6E1D3);
  static const partial = Color(0xFFD79269);
  static const gold = Color(0xFFD6A24A); // Gratitude
  static const goldSoft = Color(0xFFF6ECD5);
  static const sage = Color(0xFF7C8A66); // Successes
  static const sageDark = Color(0xFF5E6844);
  static const sageSoft = Color(0xFFE6ECDA);
  static const sageCard = Color(0xFFE6E8D6);
  static const plum = Color(0xFFB98BA0); // Final thoughts
  static const plumSoft = Color(0xFFEFE1EA);

  static const onAccent = Color(0xFFFFF7EE);

  /// Palette for the streak card artwork.
  static const List<Color> emberPalette = [Color(0xFFE7B27A), Color(0xFFC67C4F), Color(0xFF9C4C31)];
}
