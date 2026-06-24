import 'package:hive/hive.dart';

import '../../domain/xp_ledger_entry.dart';
import '../../domain/xp_source.dart';
import '../../domain/xp_sync_state.dart';

/// Binary Hive adapter for [XpLedgerEntry].
class XpLedgerEntryAdapter extends TypeAdapter<XpLedgerEntry> {
  @override
  final int typeId = XpLedgerHiveTypeIds.xpLedgerEntry;

  @override
  XpLedgerEntry read(BinaryReader reader) {
    final id = reader.readString();
    final sourceIndex = reader.readInt();
    final hasRefId = reader.readBool();
    final refId = hasRefId ? reader.readString() : null;
    final amount = reader.readInt();
    final createdAtUtc = DateTime.parse(reader.readString());
    final deviceId = reader.readString();
    final signature = reader.readString();
    final syncStateIndex = reader.readInt();
    return XpLedgerEntry(
      id: id,
      source: XpSource.values[sourceIndex],
      refId: refId,
      amount: amount,
      createdAtUtc: createdAtUtc,
      deviceId: deviceId,
      signature: signature,
      syncState: XpSyncState.values[syncStateIndex],
    );
  }

  @override
  void write(BinaryWriter writer, XpLedgerEntry obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.source.index)
      ..writeBool(obj.refId != null);
    if (obj.refId != null) {
      writer.writeString(obj.refId!);
    }
    writer
      ..writeInt(obj.amount)
      ..writeString(obj.createdAtUtc.toUtc().toIso8601String())
      ..writeString(obj.deviceId)
      ..writeString(obj.signature)
      ..writeInt(obj.syncState.index);
  }
}
