// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'settings.dart';

/// Okuma moduna göre arayüz renkleri. `Palette.of(context)` ile erişilir.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.primary,
    required this.primaryDark,
    required this.bg,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.brightness,
  });

  final Color primary;
  final Color primaryDark;
  final Color bg;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final Brightness brightness;

  static const light = Palette(
    primary: Color(0xFF00897B),
    primaryDark: Color(0xFF00695C),
    bg: Color(0xFFFFF8E1),
    surface: Color(0xFFFFFDE7),
    textPrimary: Color(0xFF263238),
    textSecondary: Color(0xFF546E7A),
    divider: Color(0xFFEEEEEE),
    brightness: Brightness.light,
  );

  static const sepia = Palette(
    primary: Color(0xFF00796B),
    primaryDark: Color(0xFF004D40),
    bg: Color(0xFFF4ECD8),
    surface: Color(0xFFFBF5E6),
    textPrimary: Color(0xFF3E2F1C),
    textSecondary: Color(0xFF6D5B45),
    divider: Color(0xFFE6DCC4),
    brightness: Brightness.light,
  );

  static const night = Palette(
    primary: Color(0xFF4DB6AC),
    primaryDark: Color(0xFF00897B),
    bg: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    textPrimary: Color(0xFFE0E0E0),
    textSecondary: Color(0xFF9E9E9E),
    divider: Color(0xFF2C2C2C),
    brightness: Brightness.dark,
  );

  static Palette forMode(ReadingMode mode) => switch (mode) {
        ReadingMode.light => light,
        ReadingMode.sepia => sepia,
        ReadingMode.night => night,
      };

  static Palette of(BuildContext context) =>
      Theme.of(context).extension<Palette>() ?? light;

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(ThemeExtension<Palette>? other, double t) =>
      (other is Palette && t >= 0.5) ? other : this;
}

ThemeData buildTheme(ReadingMode mode) {
  final pal = Palette.forMode(mode);
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: pal.primary,
      brightness: pal.brightness,
      surface: pal.surface,
    ),
    useMaterial3: true,
    scaffoldBackgroundColor: pal.bg,
    extensions: [pal],
    dialogTheme: DialogThemeData(
      backgroundColor: pal.bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: pal.bg,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: pal.bg,
      foregroundColor: pal.primary,
      elevation: 0,
      scrolledUnderElevation: 2,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      backgroundColor: pal.primaryDark,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
  );
}

/// Mushaf sayfasına uygulanacak renk filtresi (normal modda null).
ColorFilter? pageColorFilter(ReadingMode mode) => switch (mode) {
      ReadingMode.light => null,
      // Kâğıt rengini sıcak krem tona çevirir; mürekkep siyah kalır.
      ReadingMode.sepia => const ColorFilter.matrix(<double>[
          1.00, 0, 0, 0, 0, //
          0, 0.94, 0, 0, 0, //
          0, 0, 0.80, 0, 0, //
          0, 0, 0, 1, 0,
        ]),
      // Renkleri ters çevirip tonu 180° döndürür: zemin koyu, yazı açık,
      // süslemelerin renk tonları korunur. Hafif kısılmış parlaklık.
      ReadingMode.night => const ColorFilter.matrix(<double>[
          0.4879, -1.2155, -0.1224, 0, 235, //
          -0.3621, -0.3655, -0.1224, 0, 235, //
          -0.3621, -1.2155, 0.7276, 0, 235, //
          0, 0, 0, 1, 0,
        ]),
    };
