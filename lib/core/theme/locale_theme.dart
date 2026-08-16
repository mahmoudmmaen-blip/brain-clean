import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_theme.dart';
import 'app_colors.dart';

class LocaleTheme {
  static ThemeData themed({
    required Locale locale,
    required AppColorTheme theme,
  }) {
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final primary = AppColors.primary;
    final background =
        isDark ? AppColors.background : AppColors.backgroundLight;
    final surface = isDark ? AppColors.card : AppColors.cardLight;
    final outline = isDark ? AppColors.border : AppColors.borderLight;
    final baseTextTheme =
        isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // الخطوط تتغير تلقائياً بناءً على اللغة
      textTheme: locale.languageCode == 'ar'
          ? GoogleFonts.cairoTextTheme(baseTextTheme)
          : GoogleFonts.robotoTextTheme(baseTextTheme),
      // --- الألوان الفاخرة المزدوجة (Premium Dual-Theme Canvas) ---
      scaffoldBackgroundColor: background,
      colorScheme: isDark
          ? ColorScheme.dark(
              background: background,
              surface: surface, // زجاجي نقي للوضع المظلم
              primary: primary,
              outline: outline, // خطوط هيكلية ناعمة
            )
          : ColorScheme.light(
              background: background,
              surface: surface, // كروت بيضاء ناصعة للوضع الفاتح
              primary: primary,
              outline: outline,
            ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: surface,
      ),
    );
  }

  // تأثير الزجاج الفاخر (استخدمه في كروت واحة المشاعر ودفاتر التدوين)
  // مثال للاستخدام: boxShadow: [LocaleTheme.premiumShadow]
  static BoxShadow get premiumShadow => BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 12,
        offset: const Offset(0, 4),
      );
}
