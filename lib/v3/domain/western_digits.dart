import 'package:intl/intl.dart';

/// Forces Western digits 0-9 even when the UI locale is Arabic.
abstract final class WesternDigits {
  WesternDigits._();

  static final _int = NumberFormat('0', 'en');
  static final _decimal = NumberFormat('0.##', 'en');

  static String formatInt(int value) => _int.format(value);

  static String formatNumber(num value) {
    if (value is int || value == value.roundToDouble()) {
      return _int.format(value.round());
    }
    return _decimal.format(value);
  }

  static String formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
