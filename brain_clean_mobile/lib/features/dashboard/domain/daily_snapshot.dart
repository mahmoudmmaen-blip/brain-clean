import 'package:hive/hive.dart';

part 'daily_snapshot.g.dart';

@HiveType(typeId: 13)
class DailySnapshot {
  const DailySnapshot({
    required this.date,
    required this.bcsValue,
  });

  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final double bcsValue;
}
