import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/hive_meta_keys.dart';
import '../../../core/data/app_meta_box_provider.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/storage/hive_bootstrap.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../routing/v3_routes.dart';

/// One-time screen when pre-V3 Hive boxes are detected (§5.5).
class V3MigrationScreen extends ConsumerWidget {
  const V3MigrationScreen({super.key});

  Future<void> _continue(BuildContext context, WidgetRef ref) async {
    await HiveBootstrap.deleteLegacyBoxes();
    try {
      final box = ref.read(appMetaBoxProvider);
      await box.put(HiveMetaKeys.v3MigrationCompleted, true);
    } catch (_) {
      // Meta box missing in tests — still navigate.
    }
    if (context.mounted) context.go(V3Routes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      key: const Key('v3_migration'),
      backgroundColor: AppDesignConstants.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                loc.v3MigrationTitle,
                key: const Key('v3_migration_title'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              FilledButton(
                key: const Key('v3_migration_continue'),
                onPressed: () => _continue(context, ref),
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                  minimumSize: const Size(48, 48),
                ),
                child: Text(loc.v3MigrationContinue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Whether the one-time migration screen should be shown.
Future<bool> shouldShowV3Migration({
  Box<dynamic>? metaBox,
  bool? legacyBoxesOverride,
}) async {
  try {
    if (metaBox?.get(HiveMetaKeys.v3MigrationCompleted) == true) {
      return false;
    }
  } catch (_) {}
  if (legacyBoxesOverride != null) return legacyBoxesOverride;
  try {
    return await HiveBootstrap.hasLegacyBoxes();
  } catch (_) {
    return false;
  }
}
