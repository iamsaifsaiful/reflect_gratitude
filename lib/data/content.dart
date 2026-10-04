import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';

import '../logic/dates.dart';

/// One month of the "Let's Spend The Year Together" calendar.
class MonthTheme {
  const MonthTheme({
    required this.month,
    required this.name,
    required this.intention,
    required this.essayTitle,
    required this.blogUrl,
    required this.readMinutes,
    required this.palette,
  });

  final int month;
  final String name;
  final String intention;
  final String essayTitle;
  final String blogUrl;
  final int readMinutes;

  /// Three colours (light, mid, deep) for the abstract artwork that stands in
  /// for the month's photograph.
  final List<Color> palette;

  String get monthName => monthNames[month - 1];

  factory MonthTheme.fromJson(Map<String, dynamic> json) => MonthTheme(
        month: json['month'] as int,
        name: json['name'] as String,
        intention: json['intention'] as String,
        essayTitle: json['essayTitle'] as String,
        blogUrl: (json['blogUrl'] as String?) ?? '',
        readMinutes: (json['readMinutes'] as int?) ?? 4,
        palette: (json['palette'] as List).map((hex) => parseHexColor(hex as String)).toList(),
      );
}

Color parseHexColor(String hex) {
  final clean = hex.replaceFirst('#', '');
  final value = int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
  return Color(value);
}

/// Monthly themes and daily quotes, bundled with the app in assets/content.
class ContentRepository {
  ContentRepository({required this.themes, required this.quotes})
      : assert(themes.isNotEmpty),
        assert(quotes.isNotEmpty);

  final List<MonthTheme> themes;
  final List<String> quotes;

  static Future<ContentRepository> load(AssetBundle bundle) async {
    final themesJson = jsonDecode(await bundle.loadString('assets/content/themes.json')) as List;
    final quotesJson = jsonDecode(await bundle.loadString('assets/content/quotes.json')) as List;
    return ContentRepository(
      themes: themesJson.map((t) => MonthTheme.fromJson(Map<String, dynamic>.from(t as Map))).toList(),
      quotes: quotesJson.map((q) => q as String).toList(),
    );
  }

  MonthTheme themeFor(int month) =>
      themes.firstWhere((t) => t.month == month, orElse: () => themes.first);

  /// The same quote all day, a new one each day.
  String quoteFor(DateTime day) => quotes[(dayOfYear(day) - 1) % quotes.length];
}
