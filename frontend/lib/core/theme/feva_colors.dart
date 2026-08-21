import 'package:flutter/material.dart';

class FevaColors {
  FevaColors._();

  // Nova Store luxury fashion palette
  static const Color matteBlack = Color(0xFF111111); // Rich Charcoal Black
  static const Color espressoBrown = Color(0xFF3D2B1F); // Warm Espresso Brown (primary)
  static const Color champagneGold = Color(
    0xFFC9A227,
  ); // Professional gold accent
  static const Color ivoryWhite = Color(0xFFF6EEE5); // Warm ivory background
  static const Color pureWhite = Color(
    0xFFFFFFFF,
  ); // Pure White (surface/cards)
  static const Color warmGray = Color(0xFF7A7175); // Muted warm gray
  static const Color softBeige = Color(0xFFE7E1D8); // Dividers / Beige-Grey
  static const Color success = Color(0xFF0F5132); // Deep Emerald
  static const Color error = Color(0xFFC62828); // Elegant Crimson
  static const Color darkSurface = Color(0xFF2A1F16); // Deep espresso dark
  static const Color darkElevated = Color(0xFF3D2B1F); // Elevated dark surface
}

class FevaColorScheme extends ThemeExtension<FevaColorScheme> {
  const FevaColorScheme({
    required this.background,
    required this.surface,
    required this.surfaceElevated,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.divider,
    required this.cardBackground,
    required this.inputFill,
  });

  final Color background;
  final Color surface;
  final Color surfaceElevated;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color divider;
  final Color cardBackground;
  final Color inputFill;

  static const light = FevaColorScheme(
    background: FevaColors.ivoryWhite,
    surface: FevaColors.ivoryWhite,
    surfaceElevated: FevaColors.pureWhite,
    primaryText: FevaColors.espressoBrown,
    secondaryText: FevaColors.warmGray,
    accent: FevaColors.champagneGold,
    divider: FevaColors.softBeige,
    cardBackground: FevaColors.pureWhite,
    inputFill: FevaColors.softBeige,
  );

  static const dark = FevaColorScheme(
    background: FevaColors.matteBlack,
    surface: FevaColors.darkSurface,
    surfaceElevated: FevaColors.darkElevated,
    primaryText: FevaColors.ivoryWhite,
    secondaryText: FevaColors.warmGray,
    accent: FevaColors.champagneGold,
    divider: FevaColors.darkElevated,
    cardBackground: FevaColors.darkSurface,
    inputFill: FevaColors.darkElevated,
  );

  @override
  FevaColorScheme copyWith({
    Color? background,
    Color? surface,
    Color? surfaceElevated,
    Color? primaryText,
    Color? secondaryText,
    Color? accent,
    Color? divider,
    Color? cardBackground,
    Color? inputFill,
  }) {
    return FevaColorScheme(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      accent: accent ?? this.accent,
      divider: divider ?? this.divider,
      cardBackground: cardBackground ?? this.cardBackground,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  FevaColorScheme lerp(ThemeExtension<FevaColorScheme>? other, double t) {
    if (other is! FevaColorScheme) return this;
    return FevaColorScheme(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      primaryText: Color.lerp(primaryText, other.primaryText, t)!,
      secondaryText: Color.lerp(secondaryText, other.secondaryText, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}

extension FevaColorContext on BuildContext {
  FevaColorScheme get fevaColors =>
      Theme.of(this).extension<FevaColorScheme>() ?? FevaColorScheme.light;
}
