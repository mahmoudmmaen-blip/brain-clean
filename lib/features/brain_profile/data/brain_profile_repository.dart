import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/profile_pack.dart';
import '../domain/profile_version.dart';

/// Abstract persistence for V2 Brain Profile history.
abstract class BrainProfileRepository {
  Future<ProfilePack?> findBySourceSessionId(String sessionId);
  Future<ProfilePack?> latest();
  Future<List<ProfilePack>> history();
  Future<void> save(ProfilePack pack);
}

/// Isolated Hive store — never touches V1 diagnostic boxes.
class BrainProfileLocalRepository implements BrainProfileRepository {
  BrainProfileLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const historyKey = 'profile_history';
  static const schemaKey = 'schema_version';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.brainProfile);
  }

  Future<void> _ensureSchema(Box<dynamic> box) async {
    final existing = box.get(schemaKey);
    if (existing == null) {
      await box.put(schemaKey, ProfileVersion.profileSchema);
    }
  }

  List<ProfilePack> _decodeHistory(dynamic raw) {
    final packs = <ProfilePack>[];
    if (raw is! List) return packs;
    for (final item in raw) {
      if (item is! Map) continue;
      try {
        packs.add(
          ProfilePack.fromJson(Map<String, dynamic>.from(item)),
        );
      } catch (e) {
        debugPrint('BrainProfileLocalRepository: skip corrupt pack: $e');
      }
    }
    return packs;
  }

  @override
  Future<List<ProfilePack>> history() async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final packs = _decodeHistory(box.get(historyKey));
      packs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return List<ProfilePack>.unmodifiable(packs);
    } catch (e) {
      debugPrint('BrainProfileLocalRepository: history failed: $e');
      return const [];
    }
  }

  @override
  Future<ProfilePack?> latest() async {
    final packs = await history();
    if (packs.isEmpty) return null;
    return packs.last;
  }

  @override
  Future<ProfilePack?> findBySourceSessionId(String sessionId) async {
    final packs = await history();
    for (final pack in packs) {
      if (pack.source.sessionId == sessionId) return pack;
    }
    return null;
  }

  /// Idempotent: same source session never appends a duplicate.
  @override
  Future<void> save(ProfilePack pack) async {
    try {
      final box = await _openBox();
      await _ensureSchema(box);
      final existing = _decodeHistory(box.get(historyKey));
      for (final prior in existing) {
        if (prior.source.sessionId == pack.source.sessionId) {
          // Keep first immutable profile for this session.
          return;
        }
        if (prior.id == pack.id) {
          return;
        }
      }
      final next = [
        ...existing.map((p) => p.toJson()),
        pack.toJson(),
      ];
      await box.put(historyKey, next);
    } catch (e) {
      debugPrint('BrainProfileLocalRepository: save failed: $e');
      rethrow;
    }
  }
}
