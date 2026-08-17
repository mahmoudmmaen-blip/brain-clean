/// Shared date/duration formatting helpers.
///
/// Calendar day keys (`yyyy-MM-dd`) are used as storage and idempotency keys,
/// so the format must stay stable across features.
abstract final class DateFormatUtils {
  /// `yyyy-MM-dd` key for [date] in its own timezone.
  static String dayKey(DateTime date) =>
      '${date.year}-${_pad2(date.month)}-${_pad2(date.day)}';

  /// `yyyy-MM-dd` key for [date] converted to UTC.
  static String utcDayKey(DateTime date) => dayKey(date.toUtc());

  /// `mm:ss` countdown text; minutes are zero-padded unless [padMinutes] is
  /// false.
  static String countdown(int totalSeconds, {bool padMinutes = true}) {
    final safeSeconds = totalSeconds < 0 ? 0 : totalSeconds;
    final minutes = (safeSeconds ~/ 60).toString();
    return '${padMinutes ? minutes.padLeft(2, '0') : minutes}:'
        '${_pad2(safeSeconds % 60)}';
  }

  static String _pad2(int value) => value.toString().padLeft(2, '0');
}
