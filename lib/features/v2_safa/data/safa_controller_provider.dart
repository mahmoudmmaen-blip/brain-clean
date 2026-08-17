import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/claude_ai_service_provider.dart';
import '../application/safa_controller.dart';
import '../data/safa_consent_store.dart';
import '../data/safa_edge_adapter.dart';

final safaConsentStoreProvider = Provider<SafaConsentStore>((ref) {
  return SafaConsentStore();
});

final safaEdgeAdapterProvider = Provider<SafaEdgeAdapter>((ref) {
  final claude = ref.watch(claudeAiServiceProvider);
  return SafaEdgeAdapter(claude: claude);
});

final safaControllerProvider = Provider<SafaController>((ref) {
  final controller = SafaController(
    edge: ref.watch(safaEdgeAdapterProvider),
    consentStore: ref.watch(safaConsentStoreProvider),
  );
  ref.onDispose(() {
    // Drop listeners only; no Hive persistence.
  });
  return controller;
});
