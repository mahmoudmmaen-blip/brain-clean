/// Parses store free-trial billing periods (ISO-8601 / unit+value) into days.
///
/// Never invents a duration — returns null when the period cannot be read.
abstract final class TrialPeriod {
  TrialPeriod._();

  static final RegExp _iso = RegExp(
    r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?$',
    caseSensitive: false,
  );

  /// Days from an ISO-8601 period such as `P2W`, `P14D`, `P1M`.
  ///
  /// Month ≈ 30 days, year ≈ 365 days — only used when the store sends those
  /// units for a free phase (uncommon for trials).
  static int? daysFromIso8601(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    final match = _iso.firstMatch(iso.trim());
    if (match == null) return null;
    final years = int.tryParse(match.group(1) ?? '') ?? 0;
    final months = int.tryParse(match.group(2) ?? '') ?? 0;
    final weeks = int.tryParse(match.group(3) ?? '') ?? 0;
    final days = int.tryParse(match.group(4) ?? '') ?? 0;
    final total = years * 365 + months * 30 + weeks * 7 + days;
    return total > 0 ? total : null;
  }

  /// Days from a RevenueCat [Period]-style unit name + value.
  static int? daysFromUnitValue(String? unit, int? value) {
    if (unit == null || value == null || value <= 0) return null;
    switch (unit.toUpperCase()) {
      case 'DAY':
      case 'DAYS':
        return value;
      case 'WEEK':
      case 'WEEKS':
        return value * 7;
      case 'MONTH':
      case 'MONTHS':
        return value * 30;
      case 'YEAR':
      case 'YEARS':
        return value * 365;
      default:
        return null;
    }
  }
}
