import '../domain/anxiety_level.dart';

String safaProgramFallbackArabic(AnxietyLevel level) {
  return switch (level) {
    AnxietyLevel.calm =>
      'قلقك تحت السيطرة — استمر على نفس الإيقاع. ركّز على دفتر القلق لو حسيت بأي ضغط. صفا هنا لو محتاج. أنت على الطريق الصح 💚',
    AnxietyLevel.moderate =>
      'لاحظت بداية قلق مزمن — دفتر القلق هيفيدك كتير. جرّب نافذة القلق كل يوم الساعة 5 العصر. صفا هتابع معاك أسبوعياً. خطوة صغيرة كل يوم تصنع فرقاً 🌿',
    AnxietyLevel.high =>
      'القلق بيأثر على يومك — ابدأ بنافذة القلق اليومية وأضف حركة خفيفة. صفا ستبني معك خطة أسبوعية. أنت أقوى من القلق 💪',
    AnxietyLevel.severe =>
      'القلق عالي — يُنصح بمراجعة مختص إلى جانب البرنامج. ابدأ بدفتر القلق يومياً. صفا معاك في كل خطوة. مش لازم تعدي ده لوحدك 🤝',
  };
}

String safaProgramFallbackEnglish(AnxietyLevel level) {
  return switch (level) {
    AnxietyLevel.calm =>
      'Your anxiety is under control — keep your current pace. Use the worry journal if pressure builds. Safa is here if you need support. You are on the right path 💚',
    AnxietyLevel.moderate =>
      'Early chronic anxiety signs — the worry journal will help a lot. Try a daily worry window at 5 PM. Safa will check in weekly. Small daily steps make a difference 🌿',
    AnxietyLevel.high =>
      'Anxiety is affecting your days — start a daily worry window and add light movement. Safa will build a weekly plan with you. You are stronger than anxiety 💪',
    AnxietyLevel.severe =>
      'Anxiety is high — consider seeing a specialist alongside the program. Start the worry journal daily. Safa is with you every step. You do not have to face this alone 🤝',
  };
}

String anxietyLevelArabicLabel(AnxietyLevel level) {
  return switch (level) {
    AnxietyLevel.calm => 'هادئ',
    AnxietyLevel.moderate => 'متوسط',
    AnxietyLevel.high => 'مرتفع',
    AnxietyLevel.severe => 'شديد',
  };
}
