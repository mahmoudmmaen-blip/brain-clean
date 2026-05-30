/// Motivational weekly report message based on active streak days this week.
String weeklyReportMessage({
  required int streakDaysThisWeek,
  required bool isArabic,
}) {
  if (streakDaysThisWeek >= 5) {
    return isArabic ? 'أسبوع استثنائي 🏆' : 'Exceptional week 🏆';
  }
  if (streakDaysThisWeek >= 3) {
    return isArabic ? 'أداء جيد، استمر 💪' : 'Good effort, keep going 💪';
  }
  return isArabic ? 'الأسبوع القادم أفضل 🌱' : 'Next week will be better 🌱';
}

String weeklyNotificationBody({
  required int focusDays,
  required int bcs,
  required bool isArabic,
}) {
  if (isArabic) {
    return 'أيام التركيز: $focusDays | BCS: $bcs | إنجازاتك في تقدم!';
  }
  return 'Focus days: $focusDays | BCS: $bcs | Keep it up!';
}
