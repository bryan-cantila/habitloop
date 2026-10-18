import 'package:flutter/material.dart';

/// Design tokens for HabitLoop.
///
/// Style: Organic / biophilic — soft blobs, curved shapes, rounded cards;
/// calm and human.
/// Palette: Ink Teal #053D3A + Warm Sand #FFE2B8.
class AppTheme {
  static const Color inkTeal = Color(0xFF053D3A);
  static const Color inkTealLight = Color(0xFF0B4F4B);
  static const Color inkTealDeep = Color(0xFF032726);
  static const Color warmSand = Color(0xFFFFE2B8);
  static const Color cream = Color(0xFFFFF6E8);
  static const Color sandDark = Color(0xFFF0D49A);
  static const Color leafGreen = Color(0xFF5B8C5A);
  static const Color leafLight = Color(0xFFDDEBC8);
  static const Color clay = Color(0xFFC97B4A);
  static const Color skySoft = Color(0xFF9CC5C0);

  static const double radiusCard = 28;
  static const double radiusPill = 999;

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: inkTeal,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme.copyWith(
        primary: inkTeal,
        onPrimary: cream,
        secondary: leafGreen,
        surface: cream,
        onSurface: inkTealDeep,
        surfaceContainerHighest: warmSand,
      ),
      scaffoldBackgroundColor: warmSand,
      // Rounded system fonts — no custom font downloads needed.
      appBarTheme: const AppBarTheme(
        backgroundColor: warmSand,
        foregroundColor: inkTealDeep,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: cream,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusCard),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: inkTeal,
        foregroundColor: cream,
        shape: StadiumBorder(),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cream,
        selectedItemColor: inkTeal,
        unselectedItemColor: Color(0xFF8AA5A2),
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// A small set of friendly accent colors users can pick per habit.
  static const List<Color> habitColors = [
    leafGreen,
    Color(0xFF4E9B8F),
    Color(0xFFC97B4A),
    Color(0xFFD9A441),
    Color(0xFFB56576),
    Color(0xFF6D597A),
    Color(0xFF355070),
    Color(0xFF3E7CB1),
  ];
}

/// The ~12 built-in icons users can pick for a habit.
/// Habits store an index into this list (no IconData serialization needed).
const List<IconData> habitIcons = [
  Icons.spa,
  Icons.directions_walk,
  Icons.menu_book,
  Icons.water_drop,
  Icons.bedtime,
  Icons.fitness_center,
  Icons.self_improvement,
  Icons.brush,
  Icons.music_note,
  Icons.eco,
  Icons.pets,
  Icons.phone_android,
];
