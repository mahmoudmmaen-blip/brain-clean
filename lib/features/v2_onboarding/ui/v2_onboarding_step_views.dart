import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/v2_onboarding_answers.dart';
import '../domain/v2_onboarding_progress.dart';

class _OnbScaffold extends StatelessWidget {
  const _OnbScaffold({
    required this.title,
    required this.body,
    required this.ctaLabel,
    required this.onCta,
    this.ctaEnabled = true,
    this.footnote,
    this.secondaryLabel,
    this.onSecondary,
    this.extra,
  });

  final String title;
  final String body;
  final String ctaLabel;
  final VoidCallback? onCta;
  final bool ctaEnabled;
  final String? footnote;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height -
              MediaQuery.paddingOf(context).vertical -
              80,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
            ),
            if (extra != null) ...[
              const SizedBox(height: 20),
              extra!,
            ],
            if (footnote != null) ...[
              const SizedBox(height: 16),
              Text(
                footnote!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: ctaEnabled ? onCta : null,
                child: Text(ctaLabel),
              ),
            ),
            if (secondaryLabel != null && onSecondary != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: TextButton(
                  onPressed: onSecondary,
                  child: Text(secondaryLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Screen 1 — Welcome
class OnbWelcomeView extends StatelessWidget {
  const OnbWelcomeView({
    super.key,
    required this.loc,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _OnbScaffold(
      title: loc.v2OnboardingWelcomeTitle,
      body: loc.v2OnboardingWelcomePromise,
      footnote: loc.v2OnboardingWelcomeDisclaimer,
      ctaLabel: loc.v2OnboardingWelcomeStart,
      onCta: onContinue,
    );
  }
}

/// Screen 2 — five quick questions on one scrollable page.
class OnbQuickSetupView extends StatefulWidget {
  const OnbQuickSetupView({
    super.key,
    required this.loc,
    required this.onContinue,
    this.initialScreenHours,
    this.initialGoal,
    this.initialHardest,
    this.initialReminder,
    this.initialFirstName,
  });

  final AppLocalizations loc;
  final Future<void> Function({
    required V2ScreenHoursBand screenHours,
    required V2OnboardingGoal mainGoal,
    required V2RitualWindow hardestTime,
    V2RitualWindow? reminderTime,
    String? firstName,
  }) onContinue;
  final V2ScreenHoursBand? initialScreenHours;
  final V2OnboardingGoal? initialGoal;
  final V2RitualWindow? initialHardest;
  final V2RitualWindow? initialReminder;
  final String? initialFirstName;

  @override
  State<OnbQuickSetupView> createState() => _OnbQuickSetupViewState();
}

class _OnbQuickSetupViewState extends State<OnbQuickSetupView> {
  late V2ScreenHoursBand? _hours = widget.initialScreenHours;
  late V2OnboardingGoal? _goal = widget.initialGoal;
  late V2RitualWindow? _hardest = widget.initialHardest;
  late V2RitualWindow? _reminder = widget.initialReminder;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.initialFirstName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  bool get _ready => _hours != null && _goal != null && _hardest != null;

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.v2OnboardingQuickSetupTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            loc.v2OnboardingQuickSetupBody,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 20),
          Text(loc.v2OnboardingQScreenHours,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final band in V2ScreenHoursBand.values)
                ChoiceChip(
                  label: Text(_hoursLabel(loc, band)),
                  selected: _hours == band,
                  onSelected: (_) => setState(() => _hours = band),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(loc.v2OnboardingQMainGoal,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final goal in V2OnboardingGoal.values)
                ChoiceChip(
                  label: Text(_goalLabel(loc, goal)),
                  selected: _goal == goal,
                  onSelected: (_) => setState(() => _goal = goal),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(loc.v2OnboardingQHardestTime,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final w in V2RitualWindow.values)
                ChoiceChip(
                  label: Text(_windowLabel(loc, w)),
                  selected: _hardest == w,
                  onSelected: (_) => setState(() => _hardest = w),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Text(loc.v2OnboardingQFirstName,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _nameCtrl,
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              LengthLimitingTextInputFormatter(24),
            ],
            decoration: InputDecoration(
              hintText: loc.v2OnboardingQFirstNameHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          Text(loc.v2OnboardingQReminder,
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final w in V2RitualWindow.values)
                ChoiceChip(
                  label: Text(_windowLabel(loc, w)),
                  selected: _reminder == w,
                  onSelected: (_) => setState(() => _reminder = w),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            loc.v2OnboardingWelcomeDisclaimer,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: !_ready
                  ? null
                  : () => widget.onContinue(
                        screenHours: _hours!,
                        mainGoal: _goal!,
                        hardestTime: _hardest!,
                        reminderTime: _reminder,
                        firstName: _nameCtrl.text.trim(),
                      ),
              child: Text(loc.v2OnboardingQuickSetupContinue),
            ),
          ),
        ],
      ),
    );
  }

  String _hoursLabel(AppLocalizations loc, V2ScreenHoursBand band) {
    return switch (band) {
      V2ScreenHoursBand.under2 => loc.v2OnboardingHoursUnder2,
      V2ScreenHoursBand.from2to4 => loc.v2OnboardingHours2to4,
      V2ScreenHoursBand.from4to6 => loc.v2OnboardingHours4to6,
      V2ScreenHoursBand.over6 => loc.v2OnboardingHoursOver6,
    };
  }

  String _goalLabel(AppLocalizations loc, V2OnboardingGoal goal) {
    return switch (goal) {
      V2OnboardingGoal.focus => loc.v2OnboardingGoalFocus,
      V2OnboardingGoal.sleep => loc.v2OnboardingGoalSleep,
      V2OnboardingGoal.lessScrolling => loc.v2OnboardingGoalLessScrolling,
      V2OnboardingGoal.calm => loc.v2OnboardingGoalCalm,
    };
  }

  String _windowLabel(AppLocalizations loc, V2RitualWindow w) {
    return switch (w) {
      V2RitualWindow.morning => loc.v2OnboardingRitualMorning,
      V2RitualWindow.afternoon => loc.v2OnboardingRitualAfternoon,
      V2RitualWindow.evening => loc.v2OnboardingRitualEvening,
    };
  }
}

/// Screen 3 — plan ready + Start Day 1.
class OnbPlanReadyView extends StatelessWidget {
  const OnbPlanReadyView({
    super.key,
    required this.loc,
    required this.onStartDay1,
    this.busy = false,
  });

  final AppLocalizations loc;
  final VoidCallback onStartDay1;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return _OnbScaffold(
      title: loc.v2OnboardingPlanReadyTitle,
      body: loc.v2OnboardingPlanReadyBody,
      footnote: loc.v2OnboardingWelcomeDisclaimer,
      extra: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                loc.v2OnboardingPlanReadyCardTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(loc.v2OnboardingPlanReadyCardBody),
            ],
          ),
        ),
      ),
      ctaLabel: busy
          ? loc.v2OnboardingLoading
          : loc.v2OnboardingStartDay1,
      ctaEnabled: !busy,
      onCta: onStartDay1,
    );
  }
}

// ---------------------------------------------------------------------------
// Legacy view stubs kept so older tests/imports still compile.
// ---------------------------------------------------------------------------

class OnbExpectationsView extends StatelessWidget {
  const OnbExpectationsView({
    super.key,
    required this.loc,
    required this.onContinue,
  });
  final AppLocalizations loc;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => OnbWelcomeView(
        loc: loc,
        onContinue: onContinue,
      );
}

class OnbConsentView extends StatelessWidget {
  const OnbConsentView({
    super.key,
    required this.loc,
    required this.nonMedical,
    required this.terms,
    required this.analytics,
    required this.onChanged,
    required this.onContinue,
  });
  final AppLocalizations loc;
  final bool nonMedical;
  final bool terms;
  final bool analytics;
  final void Function({bool? nonMedical, bool? terms, bool? analytics})
      onChanged;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => OnbWelcomeView(
        loc: loc,
        onContinue: onContinue,
      );
}

class OnbPrivacyView extends StatelessWidget {
  const OnbPrivacyView({
    super.key,
    required this.loc,
    required this.onContinue,
  });
  final AppLocalizations loc;
  final VoidCallback onContinue;
  @override
  Widget build(BuildContext context) => OnbWelcomeView(
        loc: loc,
        onContinue: onContinue,
      );
}

class OnbRitualView extends StatelessWidget {
  const OnbRitualView({
    super.key,
    required this.loc,
    required this.onContinue,
    required this.onSkip,
  });
  final AppLocalizations loc;
  final void Function(V2RitualWindow?) onContinue;
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context) => OnbWelcomeView(
        loc: loc,
        onContinue: onSkip,
      );
}

class OnbCheckIntroView extends StatelessWidget {
  const OnbCheckIntroView({
    super.key,
    required this.loc,
    required this.onStart,
    required this.onSkip,
  });
  final AppLocalizations loc;
  final VoidCallback onStart;
  final VoidCallback onSkip;
  @override
  Widget build(BuildContext context) => OnbPlanReadyView(
        loc: loc,
        onStartDay1: onStart,
      );
}
