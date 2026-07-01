import 'package:flutter/material.dart';

import 'app_color_theme.dart';

class LocaleTheme {
  static ThemeData themed({
    required Locale locale,
    required AppColorTheme theme,
  }) {
    final brightness = theme.brightness;
    final isDark = brightness == Brightness.dark;
    final primary = theme.accent;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // الخطوط تتغير تلقائياً بناءً على اللغة
      fontFamily: locale.languageCode == 'ar' ? 'Cairo' : 'Roboto',
      // --- الألوان الفاخرة المزدوجة (Premium Dual-Theme Canvas) ---
      scaffoldBackgroundColor: theme.background,
      colorScheme: isDark
          ? ColorScheme.dark(
              background: theme.background,
              surface: theme.surface, // زجاجي نقي للوضع المظلم
              primary: primary,
              outline: const Color(0xFF232D38), // خطوط هيكلية ناعمة
            )
          : ColorScheme.light(
              background: theme.background,
              surface: theme.surface, // كروت بيضاء ناصعة للوضع الفاتح
              primary: primary,
              outline: const Color(0xFFE2E8F0),
            ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: theme.surface,
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