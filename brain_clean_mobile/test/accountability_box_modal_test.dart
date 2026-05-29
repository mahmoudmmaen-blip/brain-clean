import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_hive_repository.dart';
import 'package:brain_clean_mobile/features/recovery/data/recovery_protocol_storage_provider.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_bc_penalty_provider.dart';
import 'package:brain_clean_mobile/features/recovery/domain/accountability_category.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/recovery_protocol_controller.dart';
import 'package:brain_clean_mobile/features/recovery/presentation/widgets/accountability_box_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_l10n.dart';

void main() {
  testWidgets('accountability modal applies −15 BCS penalty on first option',
      (tester) async {
    final container = ProviderContainer(
      overrides: [
        recoveryProtocolStorageProvider.overrideWithValue(
          RecoveryProtocolMemoryRepository(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final scrollController = ScrollController();
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: supportedLocales,
          home: Scaffold(
            body: AccountabilityBoxSheetBody(
              scrollController: scrollController,
              initialExpanded: AccountabilityCategory.physical,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await container.read(recoveryProtocolControllerProvider.future);
    final before = container.read(recoveryBcPenaltyTotalProvider);

    final firstPenalty = find.text(testL10nAr.accountabilityPenPhysical1);
    expect(firstPenalty, findsOneWidget);
    await tester.ensureVisible(firstPenalty);
    await tester.tap(firstPenalty);
    await tester.pumpAndSettle();

    final recovery = container.read(recoveryProtocolControllerProvider).value!;
    expect(recovery.totalPenaltyCount, 1);
    expect(container.read(recoveryBcPenaltyTotalProvider), before + 15);
  });
}
