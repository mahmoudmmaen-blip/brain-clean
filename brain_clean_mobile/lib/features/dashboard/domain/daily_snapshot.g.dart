// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_snapshot.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DailySnapshotAdapter extends TypeAdapter<DailySnapshot> {
  @override
  final int typeId = 13;

  @override
  DailySnapshot read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DailySnapshot(
      date: fields[0] as DateTime,
      bcsValue: fields[1] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DailySnapshot obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.bcsValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailySnapshotAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
