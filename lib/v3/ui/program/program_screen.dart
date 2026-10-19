import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../content/content_repository.dart';
import '../../content/program_content.dart';
import '../../data/day_progress.dart';
import '../../domain/program_day_tile.dart';
import '../../routing/v3_routes.dart';
import '../shell/v3_shell_keys.dart';

class V3ProgramScreen extends ConsumerWidget {
  const V3ProgramScreen({super.key, this.nowOverride});

  /// Injectable clock for widget tests.
  final DateTime? nowOverride;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final locale = ref.watch(localeProvider).languageCode;
    final isPro = ref.watch(isProUserProvider);
    final appAsync = ref.watch(v3AppStateProvider);
    final contentAsync = ref.watch(v3ContentProvider);
    final now = nowOverride ?? DateTime.now();

    return Scaffold(
      key: V3ShellKeys.programTab,
      backgroundColor: AppDesignConstants.darkBackground,
      body: contentAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (bundle) {
          return appAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (app) {
              return SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
                  children: [
                    Text(
                      loc.v3TabProgram,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final week in bundle.program.weeks) ...[
                      _WeekSection(
                        week: week,
                        days: bundle.program.days
                            .where((d) => d.week == week.week)
                            .toList(growable: false),
                        locale: locale,
                        progress: app.dayProgress,
                        now: now,
                        isPro: isPro,
                        loc: loc,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _WeekSection extends StatelessWidget {
  const _WeekSection({
    required this.week,
    required this.days,
    required this.locale,
    required this.progress,
    required this.now,
    required this.isPro,
    required this.loc,
  });

  final ProgramWeek week;
  final List<ProgramDay> days;
  final String locale;
  final List<DayProgress> progress;
  final DateTime now;
  final bool isPro;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.v3WeekLabel(week.week, week.title.resolve(locale)),
          style: const TextStyle(
            fontSize: AppDesignConstants.typeH3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          week.goal.resolve(locale),
          style: const TextStyle(
            color: AppDesignConstants.darkOnSurfaceMuted,
            height: AppDesignConstants.arabicBodyLineHeight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in days)
              _DayTile(
                day: day.day,
                state: ProgramDayTile.state(
                  day: day.day,
                  progress: progress,
                  now: now,
                  isPro: isPro,
                ),
                loc: loc,
              ),
          ],
        ),
      ],
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.day,
    required this.state,
    required this.loc,
  });

  final int day;
  final ProgramDayTileState state;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final keyName = switch (state) {
      ProgramDayTileState.done => 'v3_program_tile_${day}_done',
      ProgramDayTileState.today => 'v3_program_tile_${day}_today',
      ProgramDayTileState.future => 'v3_program_tile_${day}_future',
      ProgramDayTileState.proLocked => 'v3_program_tile_${day}_proLocked',
    };

    final borderColor = switch (state) {
      ProgramDayTileState.today => AppDesignConstants.brandGreen,
      ProgramDayTileState.proLocked => AppDesignConstants.accentGold,
      ProgramDayTileState.done => AppDesignConstants.brandGreen.withValues(alpha: 0.4),
      ProgramDayTileState.future => AppDesignConstants.darkBorder,
    };

    final bg = switch (state) {
      ProgramDayTileState.today =>
        AppDesignConstants.brandGreen.withValues(alpha: 0.15),
      ProgramDayTileState.proLocked =>
        AppDesignConstants.accentGoldDim,
      ProgramDayTileState.done => AppDesignConstants.darkSurface,
      ProgramDayTileState.future => AppDesignConstants.darkSurfaceSecondary,
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        key: Key(keyName),
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onTap(context),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: state == ProgramDayTileState.today ? 2 : 1),
          ),
          child: switch (state) {
            ProgramDayTileState.done => const Icon(
                Icons.check_rounded,
                color: AppDesignConstants.brandGreen,
                size: 22,
              ),
            ProgramDayTileState.proLocked => const Icon(
                Icons.lock_rounded,
                color: AppDesignConstants.accentGold,
                size: 20,
              ),
            ProgramDayTileState.future => const Icon(
                Icons.lock_outline,
                color: AppDesignConstants.darkOnSurfaceDim,
                size: 18,
              ),
            ProgramDayTileState.today => Text(
                '$day',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppDesignConstants.brandGreen,
                ),
              ),
          },
        ),
      ),
    );
  }

  void _onTap(BuildContext context) {
    switch (state) {
      case ProgramDayTileState.done:
        context.push(V3Routes.programDayPath(day));
      case ProgramDayTileState.proLocked:
        context.push('${V3Routes.paywall}?source=program');
      case ProgramDayTileState.future:
        final opensAfter = day - 1;
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: AppDesignConstants.darkSurface,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              key: const Key('v3_program_future_sheet'),
              loc.v3ProgramOpensAfter(opensAfter),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ),
        );
      case ProgramDayTileState.today:
        context.push(V3Routes.sessionPath(day));
    }
  }
}
