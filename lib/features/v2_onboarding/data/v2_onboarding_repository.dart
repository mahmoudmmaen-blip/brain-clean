import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/storage/hive_boxes.dart';
import '../domain/v2_onboarding_state.dart';
import '../domain/v2_onboarding_status.dart';
import '../domain/v2_onboarding_step.dart';
import '../domain/v2_onboarding_version.dart';

abstract class V2OnboardingRepository {
  Future<V2OnboardingState> load();
  Future<V2OnboardingState> save(V2OnboardingState state);
  Future<V2OnboardingState> restart({String? languageCode});
}

/// Isolated Hive store — never touches V1 onboarding / diagnostic boxes.
class V2OnboardingLocalRepository implements V2OnboardingRepository {
  V2OnboardingLocalRepository({Box<dynamic>? box}) : _boxOverride = box;

  static const stateKey = 'onboarding_state';
  static const schemaKey = 'schema_version';

  final Box<dynamic>? _boxOverride;

  Future<Box<dynamic>> _openBox() async {
    if (_boxOverride != null) return _boxOverride!;
    await HiveBootstrap.warmUpPersistentBoxes();
    return Hive.box<dynamic>(HiveBoxes.v2Onboarding);
  }

  @override
  Future<V2OnboardingState> load() async {
    try {
      final box = await _openBox();
      final existingSchema = box.get(schemaKey);
      if (existingSchema == null) {
        await box.put(schemaKey, V2OnboardingVersion.schema);
      }
      final raw = box.get(stateKey);
      if (raw == null) {
        return V2OnboardingState.fresh();
      }
      if (raw is! Map) {
        return V2OnboardingState.fresh().copyWith(
          status: V2OnboardingStatus.corrupt,
          currentStep: V2OnboardingStep.welcome,
        );
      }
      try {
        return V2OnboardingState.fromJson(Map<String, dynamic>.from(raw));
      } catch (e) {
        debugPrint('V2OnboardingLocalRepository: corrupt state: $e');
        return V2OnboardingState.fresh().copyWith(
          status: V2OnboardingStatus.corrupt,
          currentStep: V2OnboardingStep.welcome,
        );
      }
    } catch (e) {
      debugPrint('V2OnboardingLocalRepository: load failed: $e');
      return V2OnboardingState.fresh().copyWith(
        status: V2OnboardingStatus.corrupt,
      );
    }
  }

  @override
  Future<V2OnboardingState> save(V2OnboardingState state) async {
    try {
      final box = await _openBox();
      await box.put(schemaKey, V2OnboardingVersion.schema);
      // Idempotent: same payload rewrite is fine.
      await box.put(stateKey, state.toJson());
      return state;
    } catch (e) {
      debugPrint('V2OnboardingLocalRepository: save failed: $e');
      rethrow;
    }
  }

  /// Explicit restart — resets V2 onboarding only; never Brain Check answers.
  @override
  Future<V2OnboardingState> restart({String? languageCode}) async {
    final fresh = V2OnboardingState.fresh(languageCode: languageCode);
    return save(fresh);
  }
}
