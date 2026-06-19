import 'package:hive/hive.dart';

import '../../domain/recovery_hive_payload.dart';
import '../../domain/recovery_hive_type_ids.dart';
import '../../domain/recovery_protocol_state.dart';

/// Hive adapter for [RecoveryProtocolState] — persists camelCase JSON envelope.
class RecoveryProtocolStateAdapter extends TypeAdapter<RecoveryProtocolState> {
  @override
  final int typeId = RecoveryHiveTypeIds.recoveryProtocolState;

  @override
  RecoveryProtocolState read(BinaryReader reader) {
    final raw = Map<String, dynamic>.from(reader.readMap());
    return RecoveryHivePayload.decodeState(raw);
  }

  @override
  void write(BinaryWriter writer, RecoveryProtocolState obj) {
    writer.writeMap(RecoveryHivePayload.encodeState(obj));
  }
}
