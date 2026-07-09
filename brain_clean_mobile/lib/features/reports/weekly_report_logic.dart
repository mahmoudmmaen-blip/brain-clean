/// Notification copy for scheduled weekly report alerts.
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
