import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recovery_load_meta_provider.g.dart';

/// UI flags set after the last Hive load (migration / corruption recovery).
class RecoveryLoadMeta {
  const RecoveryLoadMeta({
    this.migratedFromLegacy = false,
    this.recoveredFromCorruption = false,
  });

  final bool migratedFromLegacy;
  final bool recoveredFromCorruption;

  bool get showNotice => migratedFromLegacy || recoveredFromCorruption;

  RecoveryLoadMeta copyWith({
    bool? migratedFromLegacy,
    bool? recoveredFromCorruption,
  }) {
    return RecoveryLoadMeta(
      migratedFromLegacy: migratedFromLegacy ?? this.migratedFromLegacy,
      recoveredFromCorruption:
          recoveredFromCorruption ?? this.recoveredFromCorruption,
    );
  }
}

@Riverpod(keepAlive: true)
class RecoveryLoadMetaNotifier extends _$RecoveryLoadMetaNotifier {
  @override
  RecoveryLoadMeta build() => const RecoveryLoadMeta();

  void apply({
    bool migratedFromLegacy = false,
    bool recoveredFromCorruption = false,
  }) {
    state = RecoveryLoadMeta(
      migratedFromLegacy: migratedFromLegacy,
      recoveredFromCorruption: recoveredFromCorruption,
    );
  }

  void clearNotice() {
    state = const RecoveryLoadMeta();
  }
}
