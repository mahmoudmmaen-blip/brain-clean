/// Store-price parsing and savings math for the V3 paywall.
///
/// Prices always come from the store as formatted strings (e.g. "12.34 CUR").
/// These helpers extract a numeric value so the yearly "save X%" badge and
/// "≈ monthly" line can be computed from the two real prices — never hard-coded.
abstract final class PaywallPriceMath {
  PaywallPriceMath._();

  static final RegExp _numberPattern = RegExp(r'\d[\d\s.,]*');

  /// Extracts the first numeric value in a store price string.
  ///
  /// Handles common decimal/group separators ("1,234.56", "1.234,56",
  /// "12,00"). Returns null when no number is found.
  static double? parseStorePrice(String priceString) {
    final match = _numberPattern.firstMatch(priceString);
    if (match == null) return null;
    var token = match.group(0)!.replaceAll(' ', '');
    if (token.isEmpty) return null;

    final lastDot = token.lastIndexOf('.');
    final lastComma = token.lastIndexOf(',');
    if (lastDot >= 0 && lastComma >= 0) {
      // The rightmost separator is the decimal separator.
      if (lastComma > lastDot) {
        token = token.replaceAll('.', '').replaceAll(',', '.');
      } else {
        token = token.replaceAll(',', '');
      }
    } else if (lastComma >= 0) {
      final parts = token.split(',');
      if (parts.length == 2 && parts[1].length == 2) {
        token = token.replaceAll(',', '.');
      } else {
        token = token.replaceAll(',', '');
      }
    }
    return double.tryParse(token);
  }

  /// Yearly savings vs paying monthly for 12 months, rounded to a whole
  /// percent. Returns null when the yearly plan is not actually cheaper.
  static int? yearlySavingsPercent({
    required double monthlyPrice,
    required double yearlyPrice,
  }) {
    if (monthlyPrice <= 0) return null;
    final yearlyFullPrice = monthlyPrice * 12;
    if (yearlyFullPrice <= yearlyPrice) return null;
    return ((yearlyFullPrice - yearlyPrice) / yearlyFullPrice * 100).round();
  }

  /// Yearly store price ÷ 12, re-inserted into the original price format.
  ///
  /// Returns null when the amount cannot be parsed.
  static String? monthlyEquivalentPriceString(String yearlyPriceString) {
    final yearly = parseStorePrice(yearlyPriceString);
    if (yearly == null) return null;
    final match = _numberPattern.firstMatch(yearlyPriceString);
    if (match == null) return null;
    final monthly = yearly / 12;
    final originalToken = match.group(0)!;
    final decimals = _decimalPlaces(originalToken);
    final formatted = monthly.toStringAsFixed(decimals);
    return yearlyPriceString.replaceRange(match.start, match.end, formatted);
  }

  /// Just the monthly amount text (e.g. "8.25") for compact copy such as «≈ 8.25».
  static String? monthlyEquivalentAmount(String yearlyPriceString) {
    final yearly = parseStorePrice(yearlyPriceString);
    if (yearly == null) return null;
    final match = _numberPattern.firstMatch(yearlyPriceString);
    final decimals = match == null ? 2 : _decimalPlaces(match.group(0)!);
    final formatted = (yearly / 12).toStringAsFixed(decimals);
    // Trim trailing zeros after decimal only when the source had fewer.
    return formatted;
  }

  static int _decimalPlaces(String token) {
    final trimmed = token.replaceAll(' ', '');
    final normalized = trimmed.contains(',') && !trimmed.contains('.')
        ? trimmed.replaceAll(',', '.')
        : trimmed;
    final dot = normalized.lastIndexOf('.');
    if (dot < 0) return 0;
    var places = normalized.length - dot - 1;
    // Ignore grouping noise after the decimal marker.
    if (places > 2) places = 2;
    return places;
  }
}
