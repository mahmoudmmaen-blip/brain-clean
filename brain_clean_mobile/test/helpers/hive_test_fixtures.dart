import 'dart:io';

import 'package:brain_clean_mobile/core/storage/hive_bootstrap.dart';
import 'package:brain_clean_mobile/core/storage/hive_boxes.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository.dart';
import 'package:brain_clean_mobile/features/diagnostic/data/diagnostic_local_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

/// In-memory Hive box — isolates widget tests from path_provider / device I/O.
class InMemoryHiveBox implements Box<dynamic> {
  InMemoryHiveBox([Map<String, dynamic>? seed]) : _store = Map.of(seed ?? {});

  final Map<String, dynamic> _store;

  @override
  dynamic get(key, {dynamic defaultValue}) => _store[key] ?? defaultValue;

  @override
  Future<void> put(key, value) async => _store[key.toString()] = value;

  @override
  Future<void> delete(key) async => _store.remove(key.toString());

  @override
  Iterable get keys => _store.keys;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Opens real Hive boxes on a temp dir (integration-style unit tests).
Future<HiveTestContext> openHiveTestContext() async {
  HiveBootstrap.resetForTesting();
  final tempDir = await Directory.systemTemp.createTemp('bc_hive_test_');
  Hive.init(tempDir.path);
  HiveBootstrap.registerRecoveryAdaptersForTests();
  final diagnosticBox =
      await Hive.openBox<dynamic>(HiveBoxes.diagnosticPersistence);
  final recoveryBox =
      await Hive.openBox<dynamic>(HiveBoxes.recoveryProtocol);
  return HiveTestContext(
    tempDir: tempDir,
    diagnosticBox: diagnosticBox,
    recoveryBox: recoveryBox,
  );
}

/// Holds opened boxes and tears down Hive after each test file.
class HiveTestContext {
  HiveTestContext({
    required this.tempDir,
    required this.diagnosticBox,
    required this.recoveryBox,
  });

  final Directory tempDir;
  final Box<dynamic> diagnosticBox;
  final Box<dynamic> recoveryBox;

  DiagnosticLocalRepository get diagnosticRepository =>
      DiagnosticLocalRepository(box: diagnosticBox);

  Override get diagnosticRepositoryOverride =>
      diagnosticLocalRepositoryProvider.overrideWithValue(diagnosticRepository);

  Future<void> dispose() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
    HiveBootstrap.resetForTesting();
  }
}
