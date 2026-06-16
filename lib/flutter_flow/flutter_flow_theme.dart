// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

enum DeviceSize {
  mobile,
  tablet,
  desktop,
}

abstract class FlutterFlowTheme {
  static DeviceSize deviceSize = DeviceSize.mobile;

  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    deviceSize = getDeviceSize(context);
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color primaryBtnText;
  late Color lineColor;

  FFDesignTokens get designToken => FFDesignTokens(this);

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => {
        DeviceSize.mobile: MobileTypography(this),
        DeviceSize.tablet: TabletTypography(this),
        DeviceSize.desktop: DesktopTypography(this),
      }[deviceSize]!;
}

DeviceSize getDeviceSize(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 479) {
    return DeviceSize.mobile;
  } else if (width < 991) {
    return DeviceSize.tablet;
  } else {
    return DeviceSize.desktop;
  }
}

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // ═══════════════════════════════════════════════════════════
  // DUNIYA BRAND THEME — Purple #9900FF
  // ═══════════════════════════════════════════════════════════
  late Color primary = const Color(0xFF9900FF); // Duniya Purple
  late Color secondary = const Color(0xFF7C3AED); // Violet 600
  late Color tertiary = const Color(0xFFA855F7); // Secondary purple accent
  late Color alternate = const Color(0xFFE2D7FB); // Soft lavender borders
  late Color primaryText = const Color(0xFF111827); // Gray 900
  late Color secondaryText = const Color(0xFF6B7280); // Gray 500
  late Color primaryBackground = const Color(0xFFF8F5FF); // Soft lavender
  late Color secondaryBackground = const Color(0xFFFFFFFF); // Clean cards
  late Color accent1 = const Color(0x4D9900FF); // Purple @ 30%
  late Color accent2 = const Color(0x4D7C3AED); // Violet @ 30%
  late Color accent3 = const Color(0x4DA855F7); // Purple accent @ 30%
  late Color accent4 = const Color(0x4DE2D7FB); // Lavender @ 30%
  late Color success = const Color(0xFF10B981); // Emerald 500
  late Color warning = const Color(0xFFF59E0B); // Amber 500
  late Color error = const Color(0xFFEF4444); // Red 500
  late Color info = const Color(0xFF7C3AED); // Violet 600

  late Color primaryBtnText = const Color(0xFFFFFFFF); // White on purple
  late Color lineColor = const Color(0xFFE9DCF9); // Lavender dividers
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

/// Helper to build Satoshi TextStyle consistently
TextStyle _satoshi({
  required Color color,
  FontWeight fontWeight = FontWeight.normal,
  double fontSize = 14.0,
  FontStyle fontStyle = FontStyle.normal,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: 'Satoshi',
    color: color,
    fontWeight: fontWeight,
    fontSize: fontSize,
    fontStyle: fontStyle,
    letterSpacing: letterSpacing,
    height: height,
  );
}

class MobileTypography extends Typography {
  MobileTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Satoshi';
  bool get displayLargeIsCustom => true;
  TextStyle get displayLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w300,
        fontSize: 57.0,
        height: 1.12,
        letterSpacing: -0.02,
      );
  String get displayMediumFamily => 'Satoshi';
  bool get displayMediumIsCustom => true;
  TextStyle get displayMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 45.0,
        height: 1.16,
        letterSpacing: -0.02,
      );
  String get displaySmallFamily => 'Satoshi';
  bool get displaySmallIsCustom => true;
  TextStyle get displaySmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.25,
        letterSpacing: -0.01,
      );
  String get headlineLargeFamily => 'Satoshi';
  bool get headlineLargeIsCustom => true;
  TextStyle get headlineLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 32.0,
        height: 1.25,
        letterSpacing: -0.02,
      );
  String get headlineMediumFamily => 'Satoshi';
  bool get headlineMediumIsCustom => true;
  TextStyle get headlineMedium => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get headlineSmallFamily => 'Satoshi';
  bool get headlineSmallIsCustom => true;
  TextStyle get headlineSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.3,
        letterSpacing: -0.01,
      );
  String get titleLargeFamily => 'Satoshi';
  bool get titleLargeIsCustom => true;
  TextStyle get titleLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get titleMediumFamily => 'Satoshi';
  bool get titleMediumIsCustom => true;
  TextStyle get titleMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        height: 1.33,
        letterSpacing: -0.005,
      );
  String get titleSmallFamily => 'Satoshi';
  bool get titleSmallIsCustom => true;
  TextStyle get titleSmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        height: 1.38,
        letterSpacing: -0.005,
      );
  String get labelLargeFamily => 'Satoshi';
  bool get labelLargeIsCustom => true;
  TextStyle get labelLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.43,
        letterSpacing: 0.02,
      );
  String get labelMediumFamily => 'Satoshi';
  bool get labelMediumIsCustom => true;
  TextStyle get labelMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
        height: 1.5,
        letterSpacing: 0.04,
      );
  String get labelSmallFamily => 'Satoshi';
  bool get labelSmallIsCustom => true;
  TextStyle get labelSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
        height: 1.45,
        letterSpacing: 0.06,
      );
  String get bodyLargeFamily => 'Satoshi';
  bool get bodyLargeIsCustom => true;
  TextStyle get bodyLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.5,
      );
  String get bodyMediumFamily => 'Satoshi';
  bool get bodyMediumIsCustom => true;
  TextStyle get bodyMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
  String get bodySmallFamily => 'Satoshi';
  bool get bodySmallIsCustom => true;
  TextStyle get bodySmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
}

class TabletTypography extends Typography {
  TabletTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Satoshi';
  bool get displayLargeIsCustom => true;
  TextStyle get displayLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w300,
        fontSize: 57.0,
        height: 1.12,
        letterSpacing: -0.02,
      );
  String get displayMediumFamily => 'Satoshi';
  bool get displayMediumIsCustom => true;
  TextStyle get displayMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 45.0,
        height: 1.16,
        letterSpacing: -0.02,
      );
  String get displaySmallFamily => 'Satoshi';
  bool get displaySmallIsCustom => true;
  TextStyle get displaySmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.25,
        letterSpacing: -0.01,
      );
  String get headlineLargeFamily => 'Satoshi';
  bool get headlineLargeIsCustom => true;
  TextStyle get headlineLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 32.0,
        height: 1.25,
        letterSpacing: -0.02,
      );
  String get headlineMediumFamily => 'Satoshi';
  bool get headlineMediumIsCustom => true;
  TextStyle get headlineMedium => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get headlineSmallFamily => 'Satoshi';
  bool get headlineSmallIsCustom => true;
  TextStyle get headlineSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.3,
        letterSpacing: -0.01,
      );
  String get titleLargeFamily => 'Satoshi';
  bool get titleLargeIsCustom => true;
  TextStyle get titleLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get titleMediumFamily => 'Satoshi';
  bool get titleMediumIsCustom => true;
  TextStyle get titleMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        height: 1.33,
        letterSpacing: -0.005,
      );
  String get titleSmallFamily => 'Satoshi';
  bool get titleSmallIsCustom => true;
  TextStyle get titleSmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        height: 1.38,
        letterSpacing: -0.005,
      );
  String get labelLargeFamily => 'Satoshi';
  bool get labelLargeIsCustom => true;
  TextStyle get labelLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.43,
        letterSpacing: 0.02,
      );
  String get labelMediumFamily => 'Satoshi';
  bool get labelMediumIsCustom => true;
  TextStyle get labelMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
        height: 1.5,
        letterSpacing: 0.04,
      );
  String get labelSmallFamily => 'Satoshi';
  bool get labelSmallIsCustom => true;
  TextStyle get labelSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
        height: 1.45,
        letterSpacing: 0.06,
      );
  String get bodyLargeFamily => 'Satoshi';
  bool get bodyLargeIsCustom => true;
  TextStyle get bodyLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.5,
      );
  String get bodyMediumFamily => 'Satoshi';
  bool get bodyMediumIsCustom => true;
  TextStyle get bodyMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
  String get bodySmallFamily => 'Satoshi';
  bool get bodySmallIsCustom => true;
  TextStyle get bodySmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
}

class DesktopTypography extends Typography {
  DesktopTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Satoshi';
  bool get displayLargeIsCustom => true;
  TextStyle get displayLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w300,
        fontSize: 57.0,
        height: 1.12,
        letterSpacing: -0.02,
      );
  String get displayMediumFamily => 'Satoshi';
  bool get displayMediumIsCustom => true;
  TextStyle get displayMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 45.0,
        height: 1.16,
        letterSpacing: -0.02,
      );
  String get displaySmallFamily => 'Satoshi';
  bool get displaySmallIsCustom => true;
  TextStyle get displaySmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.25,
        letterSpacing: -0.01,
      );
  String get headlineLargeFamily => 'Satoshi';
  bool get headlineLargeIsCustom => true;
  TextStyle get headlineLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 32.0,
        height: 1.25,
        letterSpacing: -0.02,
      );
  String get headlineMediumFamily => 'Satoshi';
  bool get headlineMediumIsCustom => true;
  TextStyle get headlineMedium => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get headlineSmallFamily => 'Satoshi';
  bool get headlineSmallIsCustom => true;
  TextStyle get headlineSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.3,
        letterSpacing: -0.01,
      );
  String get titleLargeFamily => 'Satoshi';
  bool get titleLargeIsCustom => true;
  TextStyle get titleLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
        height: 1.27,
        letterSpacing: -0.01,
      );
  String get titleMediumFamily => 'Satoshi';
  bool get titleMediumIsCustom => true;
  TextStyle get titleMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 18.0,
        height: 1.33,
        letterSpacing: -0.005,
      );
  String get titleSmallFamily => 'Satoshi';
  bool get titleSmallIsCustom => true;
  TextStyle get titleSmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        height: 1.38,
        letterSpacing: -0.005,
      );
  String get labelLargeFamily => 'Satoshi';
  bool get labelLargeIsCustom => true;
  TextStyle get labelLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.43,
        letterSpacing: 0.02,
      );
  String get labelMediumFamily => 'Satoshi';
  bool get labelMediumIsCustom => true;
  TextStyle get labelMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
        height: 1.5,
        letterSpacing: 0.04,
      );
  String get labelSmallFamily => 'Satoshi';
  bool get labelSmallIsCustom => true;
  TextStyle get labelSmall => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
        height: 1.45,
        letterSpacing: 0.06,
      );
  String get bodyLargeFamily => 'Satoshi';
  bool get bodyLargeIsCustom => true;
  TextStyle get bodyLarge => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        height: 1.5,
      );
  String get bodyMediumFamily => 'Satoshi';
  bool get bodyMediumIsCustom => true;
  TextStyle get bodyMedium => _satoshi(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
  String get bodySmallFamily => 'Satoshi';
  bool get bodySmallIsCustom => true;
  TextStyle get bodySmall => _satoshi(
        color: theme.secondaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
        height: 1.5,
      );
}

class DarkModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  // ═══════════════════════════════════════════════════════════
  // DUNIYA BRAND DARK THEME — Purple #9900FF
  // ═══════════════════════════════════════════════════════════
  late Color primary = const Color(0xFF9900FF); // Duniya Purple
  late Color secondary = const Color(0xFFA78BFA); // Violet 400
  late Color tertiary = const Color(0xFFFBBF24); // Amber 400
  late Color alternate = const Color(0xFF374151); // Gray 700
  late Color primaryText = const Color(0xFFF9FAFB); // Gray 50
  late Color secondaryText = const Color(0xFF9CA3AF); // Gray 400
  late Color primaryBackground = const Color(0xFF111827); // Gray 900
  late Color secondaryBackground = const Color(0xFF1E1B2E); // Dark purple tint
  late Color accent1 = const Color(0x4D9900FF); // Purple @ 30%
  late Color accent2 = const Color(0x4DA78BFA); // Violet 400 @ 30%
  late Color accent3 = const Color(0x4DFBBF24); // Amber 400 @ 30%
  late Color accent4 = const Color(0x4D374151); // Gray 700 @ 30%
  late Color success = const Color(0xFF10B981); // Emerald 500
  late Color warning = const Color(0xFFF59E0B); // Amber 500
  late Color error = const Color(0xFFEF4444); // Red 500
  late Color info = const Color(0xFFA78BFA); // Violet 400

  late Color primaryBtnText = const Color(0xFFFFFFFF); // White on purple
  late Color lineColor = const Color(0xFF374151); // Gray 700 — dividers
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
  FFElevation get elevation => const FFElevation();
}

class FFSpacing {
  const FFSpacing();
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
}

class FFRadius {
  const FFRadius();
  double get sm => 12.0;
  double get md => 20.0;
  double get lg => 32.0;
  double get full => 9999.0;
}

class FFElevation {
  const FFElevation();

  /// Elevation for metric / summary cards (small cards)
  double get card => 2.0;

  /// Elevation for detail / content cards (medium cards)
  double get cardHigh => 4.0;

  /// Elevation for overlay cards (dialog-like)
  double get cardOverlay => 8.0;

  /// Elevation for the sidebar
  double get sidebar => 1.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get sm => const BoxShadow(
      blurRadius: 4.0,
      color: const Color(0x0A000000),
      offset: const Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 8.0,
      color: const Color(0x0A000000),
      offset: const Offset(0.0, 4.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 16.0,
      color: const Color(0x0F000000),
      offset: const Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 24.0,
      color: const Color(0x14000000),
      offset: const Offset(0.0, 12.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    // ═════════════════════════════════════════════════════════════
    // BRAND FONT POLICY — Satoshi everywhere.
    //
    // The Duniya MediTracker brand uses Satoshi as the only typeface.
    // Any caller that asks for "GoogleFonts" (either via useGoogleFonts
    // or by passing a GoogleFonts TextStyle as `font:`) is silently
    // rerouted to Satoshi so the UI stays visually consistent. This
    // also avoids runtime HTTP fetches to fonts.googleapis.com which
    // would otherwise pull Plus Jakarta Sans / Roboto / Inter in.
    // ═════════════════════════════════════════════════════════════
    const String brandFontFamily = 'Satoshi';

    // Case 1: caller explicitly named a fontFamily AND did NOT ask for
    // Google Fonts → honour that family (still Satoshi in practice,
    // because every FlutterFlowTheme *Family getter already returns
    // 'Satoshi', but allow overrides if a caller truly wants another
    // bundled font).
    if (fontFamily != null && !useGoogleFonts) {
      return TextStyle(
        fontFamily: fontFamily,
        package: package,
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        decoration: decoration,
        height: lineHeight,
        shadows: shadows,
      );
    }

    // Case 2: caller asked for Google Fonts (legacy FF-generated code).
    // Reroute to Satoshi — never reach out to the network.
    if (useGoogleFonts) {
      return TextStyle(
        fontFamily: brandFontFamily,
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        decoration: decoration,
        height: lineHeight,
        shadows: shadows,
      );
    }

    // Case 3: caller passed a concrete TextStyle via `font:` (often a
    // GoogleFonts.X(...) result). Ignore its font family and force
    // Satoshi, while still applying any color/size/weight overrides.
    if (font != null) {
      return TextStyle(
        fontFamily: brandFontFamily,
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
        letterSpacing: letterSpacing ?? this.letterSpacing,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
        decoration: decoration,
        height: lineHeight,
        shadows: shadows,
      );
    }

    // Case 4: no font family, no font → just copyWith applied overrides.
    return copyWith(
      fontFamily: brandFontFamily,
      package: package,
      color: color,
      fontSize: fontSize,
      letterSpacing: letterSpacing,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
      height: lineHeight,
      shadows: shadows,
    );
  }
}
