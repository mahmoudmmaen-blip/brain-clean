import 'package:hive/hive.dart';

import '../../domain/recovery_day_record.dart';
import '../../domain/recovery_hive_type_ids.dart';
import '../../domain/recovery_protocol_constants.dart';

/// Binary Hive adapter for [RecoveryDayRecord].
class RecoveryDayRecordAdapter extends TypeAdapter<RecoveryDayRecord> {
  @override
  final int typeId = RecoveryHiveTypeIds.recoveryDayRecord;

  @override
  RecoveryDayRecord read(BinaryReader reader) {
    final dayIndex = reader.readInt();
    final taskCount = reader.readInt();
    final tasks = <bool>[];
    for (var i = 0; i < taskCount; i++) {
      tasks.add(reader.readBool());
    }
    final penaltyApplied = reader.readBool();
    return RecoveryDayRecord(
      dayIndex: dayIndex,
      taskCompleted: tasks,
      penaltyApplied: penaltyApplied,
    );
  }

  @override
  void write(BinaryWriter writer, RecoveryDayRecord obj) {
    assert(
      obj.taskCompleted.length ==
          RecoveryProtocolConstants.mandatoryTaskCount,
    );
    writer
      ..writeInt(obj.dayIndex)
      ..writeInt(obj.taskCompleted.length);
    for (final task in obj.taskCompleted) {
      writer.writeBool(task);
    }
    writer.writeBool(obj.penaltyApplied);
  }
}
