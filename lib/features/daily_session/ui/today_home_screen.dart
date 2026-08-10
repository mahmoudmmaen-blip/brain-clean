import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../recovery_plan/domain/recovery_plan.dart';
import '../../recovery_plan/domain/today_act_presentation.dart';
import '../application/daily_session_controller.dart';
import '../data/daily_session_controller_provider.dart';
import '../domain/daily_session.dart';
import '../domain/daily_session_status.dart';

/// Clearance below last CTA so Safa cannot sit against the shell [NavigationBar].
/// Body is already laid above the bar; this is visual breathing room only.
const double _kTodayContentBottomClearance = 40;

/// Today loaded density rhythm (Phase B) — keep hierarchy; tune only spacing.
const double _kTodayPadH = 24;
const double _kTodayPadTop = 20;
const double _kTodayGapActTime = 8;
const double _kTodayGapTimeStatus = 12;
const double _kTodayGapStatusCta = 22;
const double _kTodayGapCtaSupport = 28;
const double _kTodayGapSupportTitleBody = 6;
const double _kTodayGapSupportSections = 16;
const double _kTodayGapAfterSupport = 20;
const double _kTodayGapCtaToSecondary = 28;
const double _kTodayGapSecondaryCluster = 4;

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
    final actStyle = theme.textTheme.headlineSmall?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w700,
      height: 1.25,
    );
    final emptyTitleStyle = actStyle;
    final supportHeadingStyle = theme.textTheme.titleSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w600,
      height: 1.3,
    );
    final bodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
    final supportBodyStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.5,
    );
    final pathStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.45,
    );
    final timeStyle = theme.textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
      height: 1.35,
      fontWeight: FontWeight.w400,
    );
    final statusStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w500,
      height: 1.2,
    );
    final secondaryActionStyle = theme.textTheme.labelLarge?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w500,
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
                _kTodayPadH,
                topPad,
                _kTodayPadH,
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
                        style: emptyTitleStyle,
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
                      height: AppDesignConstants.minTouchTarget,
                      child: FilledButton(
                        onPressed: rebuild ? onBuildPlan : onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textPrimary,
                          minimumSize: const Size(
                            AppDesignConstants.minTouchTarget,
                            AppDesignConstants.minTouchTarget,
                          ),
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
    final resolvedPrimary = _isResolvedPrimary(session);
    final quietHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      height: 1.45,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        _kTodayPadH,
        _kTodayPadTop,
        _kTodayPadH,
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
              style: actStyle,
            ),
          ),
          const SizedBox(height: _kTodayGapActTime),
          // Zone B — Effort with the Act.
          Semantics(
            label: timeLabel,
            child: Text(
              timeLabel,
              key: const Key('v2_today_time'),
              style: timeStyle,
            ),
          ),
          const SizedBox(height: _kTodayGapTimeStatus),
          // Zone C — Compact status chip (subtle surface, not a peer card).
          Semantics(
            liveRegion: true,
            label: '${loc.v2TodayHomeStatusHeading}: $statusLabel',
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: DecoratedBox(
                key: const Key('v2_today_status_chip'),
                decoration: BoxDecoration(
                  color: AppColors.card.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(
                    AppDesignConstants.radiusButton,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(statusLabel, style: statusStyle),
                ),
              ),
            ),
          ),
          const SizedBox(height: _kTodayGapStatusCta),
          // Zone D — Primary CTA early.
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: resolvedPrimary
                ? OutlinedButton(
                    key: const Key('v2_today_primary_cta'),
                    onPressed: onPrimary,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(
                        color: AppColors.border.withValues(alpha: 0.9),
                      ),
                      minimumSize: const Size(
                        AppDesignConstants.minTouchTarget,
                        AppDesignConstants.minTouchTarget,
                      ),
                    ),
                    child: Text(ctaLabel),
                  )
                : FilledButton(
                    key: const Key('v2_today_primary_cta'),
                    onPressed: onPrimary,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(
                        AppDesignConstants.minTouchTarget,
                        AppDesignConstants.minTouchTarget,
                      ),
                    ),
                    child: Text(ctaLabel),
                  ),
          ),
          if (showSupportingDetail) ...[
            const SizedBox(height: _kTodayGapCtaSupport),
            Semantics(
              header: true,
              child: Text(
                loc.v2TodayPreviewBecauseHeading,
                style: supportHeadingStyle,
              ),
            ),
            const SizedBox(height: _kTodayGapSupportTitleBody),
            Semantics(
              label: '${loc.v2TodayPreviewBecauseHeading}: $because',
              child: Text(because, style: supportBodyStyle),
            ),
            if (extraMinLabels.isNotEmpty) ...[
              const SizedBox(height: _kTodayGapSupportSections),
              Semantics(
                header: true,
                child: Text(
                  loc.recoveryPlanMinimumPath,
                  style: supportHeadingStyle,
                ),
              ),
              const SizedBox(height: _kTodayGapSupportTitleBody),
              ...extraMinLabels.asMap().entries.map(
                    (entry) => Padding(
                      key: Key('v2_today_path_row_${entry.key}'),
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '· ${entry.value}',
                        style: pathStyle,
                        softWrap: true,
                      ),
                    ),
                  ),
            ],
            const SizedBox(height: _kTodayGapSupportSections),
            // Standard path: progressive hint only (selection on Prepare).
            Text(
              loc.v2TodayHomeStandardPathHint,
              key: const Key('v2_today_standard_hint'),
              style: quietHintStyle,
            ),
            const SizedBox(height: _kTodayGapAfterSupport),
          ] else
            const SizedBox(height: _kTodayGapCtaToSecondary),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: OutlinedButton(
              onPressed: onViewPlan,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.75),
                ),
                minimumSize: const Size(
                  AppDesignConstants.minTouchTarget,
                  AppDesignConstants.minTouchTarget,
                ),
                textStyle: secondaryActionStyle,
              ),
              child: Text(loc.v2TodayHomeViewPlan),
            ),
          ),
          const SizedBox(height: _kTodayGapSecondaryCluster),
          SizedBox(
            height: AppDesignConstants.minTouchTarget,
            child: TextButton(
              key: const Key('v2_today_safa_entry'),
              onPressed: onOpenSafa,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(
                  AppDesignConstants.minTouchTarget,
                  AppDesignConstants.minTouchTarget,
                ),
                textStyle: secondaryActionStyle,
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

  /// Completed / partial primary actions stay available but visually quieter.
  static bool _isResolvedPrimary(DailySession? session) {
    if (session == null) return false;
    return session.status == DailySessionStatus.completed ||
        session.status == DailySessionStatus.partial;
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
