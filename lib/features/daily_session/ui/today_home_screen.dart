import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../application/daily_session_controller.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';

/// Clearance below last CTA so Safa cannot sit against the shell [NavigationBar].
/// Body is already laid above the bar; this is visual breathing room only.
const double _kTodayContentBottomClearance = 40;

/// HOM-01 — calm Today home (one action, not a warehouse).
class TodayHomeScreen extends ConsumerStatefulWidget {
  const TodayHomeScreen({super.key});

  @override
  ConsumerState<TodayHomeScreen> createState() => _TodayHomeScreenState();
}

class _TodayHomeScreenState extends ConsumerState<TodayHomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(dailySessionControllerProvider).loadToday());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final controller = ref.watch(dailySessionControllerProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.v2TodayHomeTitle),
        backgroundColor: AppColors.background,
      ),
      // AppBar owns top inset; shell NavigationBar owns bottom. Extra SafeArea
      // here shrank the body (~20px) and caused BOTTOM OVERFLOWED on short heights.
      body: TodayHomeBody(
        loc: loc,
        languageCode: isAr ? 'ar' : 'en',
        loading: controller.loading,
        errorKey: controller.errorKey,
        plan: controller.plan,
        session: controller.session,
        onRetry: controller.loadToday,
        onBuildPlan: () => context.go(AppRoutes.v2PlanBuilding),
        onPrimary: () => _onPrimary(context, controller),
        onViewPlan: () {
          final id = controller.plan?.id;
          if (id == null) return;
          context.go('${AppRoutes.v2PlanReveal}?plan=$id');
        },
        onOpenSafa: () => context.go(
          '${AppRoutes.v2Safa}?origin=today&returnTo=${Uri.encodeComponent(AppRoutes.v2Home)}',
        ),
      ),
    );
  }

  Future<void> _onPrimary(
    BuildContext context,
    DailySessionController controller,
  ) async {
    final session = controller.session;
    if (session?.status.isDoneToday == true) {
      context.go(
        '${AppRoutes.v2SessionLeave}?session=${session!.id}&done=1',
      );
      return;
    }
    if (session?.status == DailySessionStatus.inProgress) {
      context.go('${AppRoutes.v2SessionAct}?session=${session!.id}');
      return;
    }
    if (session?.status == DailySessionStatus.reflecting) {
      context.go('${AppRoutes.v2SessionReflect}?session=${session!.id}');
      return;
    }
    final ensured = await controller.ensureSession();
    if (!context.mounted || ensured == null) return;
    context.go('${AppRoutes.v2SessionPrepare}?session=${ensured.id}');
  }
}

class TodayHomeBody extends StatelessWidget {
  const TodayHomeBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.loading,
    required this.errorKey,
    required this.plan,
    required this.session,
    required this.onRetry,
    required this.onBuildPlan,
    required this.onPrimary,
    required this.onViewPlan,
    required this.onOpenSafa,
  });

  final AppLocalizations loc;
  final String languageCode;
  final bool loading;
  final String? errorKey;
  final RecoveryPlan? plan;
  final DailySession? session;
  final VoidCallback onRetry;
  final VoidCallback onBuildPlan;
  final VoidCallback onPrimary;
  final VoidCallback onViewPlan;
  final VoidCallback onOpenSafa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
    );
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w600,
    );
    final bodyStyle = theme.textTheme.bodyLarge?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
    final pathStyle = bodyStyle?.copyWith(
      color: AppColors.textPrimary,
      height: 1.5,
    );

    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2TodayHomeLoading,
          child: Text(
            loc.v2TodayHomeLoading,
            style: bodyStyle,
          ),
        ),
      );
    }

    if (errorKey != null || plan == null) {
      final message = switch (errorKey) {
        'missing_plan' => loc.recoveryPlanMissing,
        'unsupported_plan_version' => loc.recoveryPlanUnsupportedVersion,
        'missing_today_act' => loc.v2TodayPreviewMissingAct,
        'persistence_failed' => loc.v2TodayReadyPersistFailed,
        _ => loc.recoveryPlanGenerationError,
      };
      final isEmptyPlan = errorKey == 'missing_plan';
      final rebuild = errorKey == 'missing_plan' ||
          errorKey == 'unsupported_plan_version' ||
          errorKey == 'missing_today_act';
      final support = isEmptyPlan ? loc.recoveryPlanMissingProfile : null;

      return KeyedSubtree(
        key: const Key('v2_today_empty_state'),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const topPad = 24.0;
            final minBodyHeight =
                (constraints.maxHeight - topPad - _kTodayContentBottomClearance)
                    .clamp(0.0, double.infinity);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                24,
                topPad,
                24,
                _kTodayContentBottomClearance,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minBodyHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 40,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(height: 24),
                    Semantics(
                      header: true,
                      liveRegion: true,
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: titleStyle,
                      ),
                    ),
                    if (support != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        support,
                        textAlign: TextAlign.center,
                        style: bodyStyle,
                      ),
                    ],
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: rebuild ? onBuildPlan : onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size(48, 48),
                        ),
                        child: Text(
                          rebuild
                              ? loc.recoveryPlanBuildCta
                              : loc.recoveryPlanRetry,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    final p = plan!;
    final today = p.dayTemplate.todayPreview;
    final title = resolveTodayActTitle(p, languageCode) ??
        loc.v2TodayPreviewFallbackTitle;
    final because = today.because.forLocale(languageCode);
    final timeLabel = loc.recoveryPlanTimeRange(
      '${today.estimatedMinutesMin}',
      '${today.estimatedMinutesMax}',
    );
    final minLabels = resolveTodayMinimumPathLabels(p, languageCode);
    // Avoid repeating the hero Act as a peer minimum-path card.
    final extraMinLabels = minLabels
        .where((label) => !_samePathLabel(label, title))
        .toList(growable: false);
    final statusLabel = _statusLabel(loc, session);
    final ctaLabel = _ctaLabel(loc, session);
    final showSupportingDetail = _showSupportingDetail(session);
    final quietHintStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.45,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        24,
        16,
        24,
        _kTodayContentBottomClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Zone A — Act hero (action-first).
          Semantics(
            header: true,
            label: '${loc.v2TodayPreviewActHeading}: $title',
            child: Text(
              title,
              key: const Key('v2_today_act_title'),
              style: titleStyle,
            ),
          ),
          const SizedBox(height: 10),
          // Zone B — Effort with the Act.
          Semantics(
            label: timeLabel,
            child: Text(
              timeLabel,
              key: const Key('v2_today_time'),
              style: quietHintStyle,
            ),
          ),
          const SizedBox(height: 16),
          // Zone C — Compact session status (not a full peer card).
          Semantics(
            liveRegion: true,
            label: '${loc.v2TodayHomeStatusHeading}: $statusLabel',
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DecoratedBox(
                key: const Key('v2_today_status_chip'),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    statusLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Zone D — Primary CTA early.
          SizedBox(
            height: 48,
            child: FilledButton(
              key: const Key('v2_today_primary_cta'),
              onPressed: onPrimary,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textPrimary,
                minimumSize: const Size(48, 48),
              ),
              child: Text(ctaLabel),
            ),
          ),
          if (showSupportingDetail) ...[
            const SizedBox(height: 28),
            Semantics(
              header: true,
              child: Text(
                loc.v2TodayPreviewBecauseHeading,
                style: sectionStyle,
              ),
            ),
            const SizedBox(height: 8),
            Semantics(
              label: '${loc.v2TodayPreviewBecauseHeading}: $because',
              child: Text(because, style: bodyStyle),
            ),
            if (extraMinLabels.isNotEmpty) ...[
              const SizedBox(height: 20),
              Semantics(
                header: true,
                child: Text(
                  loc.recoveryPlanMinimumPath,
                  style: sectionStyle,
                ),
              ),
              const SizedBox(height: 8),
              ...extraMinLabels.asMap().entries.map(
                    (entry) => Padding(
                      key: Key('v2_today_path_row_${entry.key}'),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        entry.value,
                        style: pathStyle,
                        softWrap: true,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: 16),
            // Standard path: progressive hint only (selection on Prepare).
            Text(
              loc.v2TodayHomeStandardPathHint,
              key: const Key('v2_today_standard_hint'),
              style: quietHintStyle,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: onViewPlan,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size(48, 48),
              ),
              child: Text(loc.v2TodayHomeViewPlan),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 48,
            child: TextButton(
              key: const Key('v2_today_safa_entry'),
              onPressed: onOpenSafa,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(48, 48),
              ),
              child: Text(loc.v2SafaEntryToday),
            ),
          ),
        ],
      ),
    );
  }

  /// Ready / not-started surfaces may show path education; active or done days do not.
  static bool _showSupportingDetail(DailySession? session) {
    if (session == null) return true;
    return switch (session.status) {
      DailySessionStatus.notStarted => true,
      DailySessionStatus.prepared => true,
      DailySessionStatus.invalid => true,
      DailySessionStatus.inProgress => false,
      DailySessionStatus.reflecting => false,
      DailySessionStatus.completed => false,
      DailySessionStatus.partial => false,
    };
  }

  static bool _samePathLabel(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();

  String _statusLabel(AppLocalizations loc, DailySession? session) {
    if (session == null) return loc.v2TodayHomeStatusReady;
    return switch (session.status) {
      DailySessionStatus.completed => loc.v2TodayHomeStatusDone,
      DailySessionStatus.partial => loc.v2TodayHomeStatusPartial,
      DailySessionStatus.inProgress => loc.v2TodayHomeStatusInProgress,
      DailySessionStatus.reflecting => loc.v2TodayHomeStatusReflect,
      DailySessionStatus.prepared => loc.v2TodayHomeStatusReady,
      _ => loc.v2TodayHomeStatusReady,
    };
  }

  String _ctaLabel(AppLocalizations loc, DailySession? session) {
    if (session == null) return loc.v2TodayHomeCtaStart;
    return switch (session.status) {
      DailySessionStatus.completed => loc.v2TodayHomeCtaViewCompleted,
      DailySessionStatus.inProgress => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.reflecting => loc.v2TodayHomeCtaContinue,
      DailySessionStatus.partial => loc.v2TodayHomeCtaViewCompleted,
      _ => loc.v2TodayHomeCtaStart,
    };
  }
}
