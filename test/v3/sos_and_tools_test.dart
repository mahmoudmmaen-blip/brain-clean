import 'dart:io';

import 'package:brain_clean_mobile/core/data/app_meta_box_provider.dart';
import 'package:brain_clean_mobile/core/l10n/app_localization_config.dart';
import 'package:brain_clean_mobile/core/providers/locale_provider.dart';
import 'package:brain_clean_mobile/core/theme/app_theme.dart';
import 'package:brain_clean_mobile/features/games/n_back_game.dart';
import 'package:brain_clean_mobile/features/pro/application/subscription_service_provider.dart';
import 'package:brain_clean_mobile/v3/application/v3_state_providers.dart';
import 'package:brain_clean_mobile/v3/content/content.dart';
import 'package:brain_clean_mobile/v3/content/exercises_content.dart';
import 'package:brain_clean_mobile/v3/data/focus_log.dart';
import 'package:brain_clean_mobile/v3/data/user_inputs.dart';
import 'package:brain_clean_mobile/v3/data/v3_state_repository.dart';
import 'package:brain_clean_mobile/v3/domain/program_engine.dart';
import 'package:brain_clean_mobile/v3/domain/sos_helpers.dart';
import 'package:brain_clean_mobile/v3/ui/shell/v3_tab_placeholder.dart';
import 'package:brain_clean_mobile/v3/ui/sos/sos_flow_screen.dart';
import 'package:brain_clean_mobile/v3/ui/sos/sos_hub_screen.dart';
import 'package:brain_clean_mobile/v3/ui/tools/tools_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/hive_test_fixtures.dart';

void main() {
  late InMemoryHiveBox box;
  late InMemoryHiveBox metaBox;
  late V3StateLocalRepository repo;
  late ContentBundle bundle;

  setUpAll(() async {
    bundle = await ContentRepository(
      assetLoader: (p) => File(p).readAsString(),
    ).load();
  });

  setUp(() {
    box = InMemoryHiveBox();
    metaBox = InMemoryHiveBox();
    repo = V3StateLocalRepository(box: box);
  });

  List<Override> overrides({bool isPro = false}) => [
        v3StateRepositoryProvider.overrideWithValue(repo),
        v3ContentProvider.overrideWith((ref) async => bundle),
        v3AppStateProvider.overrideWith((ref) => repo.load()),
        isProUserProvider.overrideWith((ref) => isPro),
        localeProvider.overrideWith((ref) => const Locale('en')),
        appMetaBoxProvider.overrideWithValue(metaBox),
      ];

  Widget wrap(Widget child, {bool isPro = false}) {
    return ProviderScope(
      overrides: overrides(isPro: isPro),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: supportedLocales,
        theme: AppTheme.dark,
        home: child,
      ),
    );
  }

  test('SOS is never locked for free or Pro', () {
    expect(ProgramEngine.isSosLocked(isPro: false), isFalse);
    expect(ProgramEngine.isSosLocked(isPro: true), isFalse);
  });

  test('replacement fallback uses defaults when user list empty', () {
    final items = resolveSosReplacements(
      sos: bundle.sos,
      inputs: const UserInputs(),
      duration: '5',
      languageCode: 'en',
    );
    expect(items, isNotEmpty);
    expect(items.first.toLowerCase(), contains('water'));
  });

  test('replacement prefers user list when present', () {
    final items = resolveSosReplacements(
      sos: bundle.sos,
      inputs: const UserInputs(
        replacements: ReplacementLists(minutes5: ['Walk around the room']),
      ),
      duration: '5',
      languageCode: 'en',
    );
    expect(items, ['Walk around the room']);
  });

  test('why statement falls back to default', () {
    expect(
      resolveSosWhy(inputs: const UserInputs(), defaultWhy: 'DEFAULT'),
      'DEFAULT',
    );
    expect(
      resolveSosWhy(
        inputs: const UserInputs(whyStatement: ' My why '),
        defaultWhy: 'DEFAULT',
      ),
      'My why',
    );
  });

  testWidgets('SOS hub reachable for non-Pro and lists 4 flows', (tester) async {
    await tester.pumpWidget(wrap(const V3SosHubScreen(), isPro: false));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_sos')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_flow_sos_urge')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_flow_sos_bored')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_flow_sos_stress')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_flow_sos_sleep')), findsOneWidget);
  });

  testWidgets('SOS text and rate steps render', (tester) async {
    await tester.pumpWidget(
      wrap(const V3SosFlowScreen(flowId: 'sos_urge'), isPro: false),
    );
    await tester.pump();
    expect(find.byKey(const Key('v3_sos_step_text')), findsOneWidget);
    await tester.tap(find.textContaining('Tap to continue'));
    await tester.pump();
    expect(find.byKey(const Key('v3_sos_step_rate_before')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_rate_slider')), findsOneWidget);
  });

  testWidgets('SOS stress shows safety line', (tester) async {
    await tester.pumpWidget(
      wrap(const V3SosFlowScreen(flowId: 'sos_stress'), isPro: false),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('v3_sos_safety')), findsOneWidget);
  });

  testWidgets('SOS breath and dim_screen on sleep flow', (tester) async {
    await tester.pumpWidget(
      wrap(const V3SosFlowScreen(flowId: 'sos_sleep'), isPro: false),
    );
    await tester.pump();
    await tester.tap(find.textContaining('Tap to continue'));
    await tester.pump();
    expect(find.byKey(const Key('v3_sos_step_breath')), findsOneWidget);
    expect(find.byKey(const Key('v3_sos_dim_overlay')), findsOneWidget);
  });

  testWidgets('SOS show_why and suggest_replacement steps render',
      (tester) async {
    await tester.pumpWidget(
      wrap(const V3SosFlowScreen(flowId: 'sos_bored'), isPro: false),
    );
    await tester.pump();
    // first text
    await tester.tap(find.textContaining('Tap to continue'));
    await tester.pump();
    // second text
    await tester.tap(find.textContaining('Tap to continue'));
    await tester.pump();
    expect(find.byKey(const Key('v3_sos_step_replacement')), findsOneWidget);
    final defaults = resolveSosReplacements(
      sos: bundle.sos,
      inputs: const UserInputs(),
      duration: '15',
      languageCode: 'en',
    );
    expect(defaults, isNotEmpty);
    expect(find.text(defaults.first), findsOneWidget);
  });

  test('focus log is appended to repository', () async {
    await repo.appendFocusLog(
      FocusLog(at: DateTime(2026, 1, 1, 12), minutes: 25, completed: true),
    );
    final state = await repo.load();
    expect(state.focusLogs, hasLength(1));
    expect(state.focusLogs.first.minutes, 25);
    expect(state.focusLogs.first.completed, isTrue);
  });

  testWidgets('Pro exercises locked for free users', (tester) async {
    await tester.pumpWidget(wrap(const V3ToolsScreen(), isPro: false));
    await tester.pumpAndSettle();
    expect(find.byKey(V3ShellKeys.toolsTab), findsOneWidget);

    final proExercise = bundle.exercises.exercises.firstWhere(
      (e) => e.tier == ExerciseTier.pro,
    );
    final tile = find.byKey(Key('v3_tools_ex_${proExercise.id}'));
    await tester.scrollUntilVisible(
      tile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tile, findsOneWidget);
    expect(
      find.descendant(of: tile, matching: find.byIcon(Icons.lock_outline)),
      findsOneWidget,
    );
  });

  testWidgets('brain game screen opens', (tester) async {
    await tester.pumpWidget(
      wrap(const NBackGameScreen()),
    );
    await tester.pump();
    expect(find.byType(NBackGameScreen), findsOneWidget);
  });

  testWidgets('tools games section uses neutral titles', (tester) async {
    await tester.pumpWidget(wrap(const V3ToolsScreen()));
    await tester.pumpAndSettle();
    final game = find.byKey(const Key('v3_tools_game_nback'));
    await tester.scrollUntilVisible(
      game,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(game, findsOneWidget);
    expect(find.textContaining('IQ'), findsNothing);
    expect(find.textContaining('intelligence'), findsNothing);
    expect(find.textContaining('proven'), findsNothing);
  });
}
