import 'package:flutter/material.dart';

class LocaleTheme {
  static ThemeData themed({required Brightness brightness, required Locale locale}) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      // الخطوط تتغير تلقائياً بناءً على اللغة
      fontFamily: locale.languageCode == 'ar' ? 'Cairo' : 'Roboto', 
      
      // --- الألوان الفاخرة المزدوجة (Premium Dual-Theme Canvas) ---
      scaffoldBackgroundColor: isDark ? const Color(0xFF07090F) : const Color(0xFFF8FAFC),
      colorScheme: isDark 
          ? const ColorScheme.dark(
              background: Color(0xFF07090F),
              surface: Color(0xFF131920), // زجاجي نقي للوضع المظلم
              primary: Color(0xFF6366F1),
              outline: Color(0xFF232D38), // خطوط هيكلية ناعمة
            )
          : const ColorScheme.light(
              background: Color(0xFFF8FAFC),
              surface: Color(0xFFFFFFFF), // كروت بيضاء ناصعة للوضع الفاتح
              primary: Color(0xFF4F46E5),
              outline: Color(0xFFE2E8F0),
            ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF131920) : const Color(0xFFFFFFFF),
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