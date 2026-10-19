class UsageDayTotal {
  const UsageDayTotal({
    required this.date,
    required this.minutes,
  });

  /// Local calendar day `yyyy-MM-dd`.
  final String date;
  final int minutes;

  double get hours => minutes / 60.0;

  Map<String, dynamic> toJson() => {
        'date': date,
        'minutes': minutes,
      };

  factory UsageDayTotal.fromJson(Map<String, dynamic> json) {
    return UsageDayTotal(
      date: json['date'] as String,
      minutes: (json['minutes'] as num).toInt(),
    );
  }
}
