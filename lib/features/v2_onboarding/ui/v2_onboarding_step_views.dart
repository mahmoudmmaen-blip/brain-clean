import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
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

/// ONB-01 Welcome
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
      body: loc.v2OnboardingWelcomeBody,
      ctaLabel: loc.v2OnboardingContinue,
      onCta: onContinue,
    );
  }
}

/// ONB-02 Expectations — exactly 3 items.
class OnbExpectationsView extends StatelessWidget {
  const OnbExpectationsView({
    super.key,
    required this.loc,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final items = [
      loc.v2OnboardingExpectation1,
      loc.v2OnboardingExpectation2,
      loc.v2OnboardingExpectation3,
    ];
    return _OnbScaffold(
      title: loc.v2OnboardingExpectationsTitle,
      body: loc.v2OnboardingExpectationsBody,
      footnote: loc.v2OnboardingExpectationsFootnote,
      ctaLabel: loc.v2OnboardingContinue,
      onCta: onContinue,
      extra: Semantics(
        container: true,
        label: loc.v2OnboardingExpectationsTitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}.',
                      style: const TextStyle(color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(items[i])),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ONB-03 Consent
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
  final void Function({
    required bool nonMedical,
    required bool terms,
    required bool analytics,
  }) onChanged;
  final Future<bool> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final canContinue = nonMedical && terms;
    return _OnbScaffold(
      title: loc.v2OnboardingConsentTitle,
      body: loc.v2OnboardingConsentBody,
      footnote: canContinue ? null : loc.v2OnboardingConsentHint,
      ctaLabel: loc.v2OnboardingContinue,
      ctaEnabled: canContinue,
      onCta: () {
        onContinue();
      },
      extra: Column(
        children: [
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: nonMedical,
            onChanged: (v) => onChanged(
              nonMedical: v ?? false,
              terms: terms,
              analytics: analytics,
            ),
            title: Text(loc.v2OnboardingConsentNonMedical),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: terms,
            onChanged: (v) => onChanged(
              nonMedical: nonMedical,
              terms: v ?? false,
              analytics: analytics,
            ),
            title: Text(loc.v2OnboardingConsentTerms),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: analytics,
            onChanged: (v) => onChanged(
              nonMedical: nonMedical,
              terms: terms,
              analytics: v ?? false,
            ),
            title: Text(loc.v2OnboardingConsentAnalytics),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }
}

/// ONB-04 Privacy
class OnbPrivacyView extends StatelessWidget {
  const OnbPrivacyView({
    super.key,
    required this.loc,
    required this.onContinue,
  });

  final AppLocalizations loc;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return _OnbScaffold(
      title: loc.v2OnboardingPrivacyTitle,
      body: loc.v2OnboardingPrivacyBody,
      footnote: loc.v2OnboardingPrivacyFootnote,
      ctaLabel: loc.v2OnboardingContinue,
      onCta: onContinue,
      secondaryLabel: loc.v2OnboardingPrivacyPolicyLink,
      onSecondary: () {
        showModalBottomSheet<void>(
          context: context,
          builder: (ctx) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        loc.settingsPrivacyPolicy,
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(loc.v2OnboardingPrivacyCachedSummary),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(loc.v2OnboardingContinue),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// ONB-05 Ritual window
class OnbRitualView extends StatefulWidget {
  const OnbRitualView({
    super.key,
    required this.loc,
    required this.selected,
    required this.onContinue,
    required this.onSkip,
  });

  final AppLocalizations loc;
  final V2RitualWindow? selected;
  final void Function(V2RitualWindow window) onContinue;
  final VoidCallback onSkip;

  @override
  State<OnbRitualView> createState() => _OnbRitualViewState();
}

class _OnbRitualViewState extends State<OnbRitualView> {
  late V2RitualWindow _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected ?? V2RitualWindow.morning;
  }

  @override
  Widget build(BuildContext context) {
    final loc = widget.loc;
    final options = <(V2RitualWindow, String)>[
      (V2RitualWindow.morning, loc.v2OnboardingRitualMorning),
      (V2RitualWindow.afternoon, loc.v2OnboardingRitualAfternoon),
      (V2RitualWindow.evening, loc.v2OnboardingRitualEvening),
    ];

    return _OnbScaffold(
      title: loc.v2OnboardingRitualTitle,
      body: loc.v2OnboardingRitualBody,
      ctaLabel: loc.v2OnboardingContinue,
      onCta: () => widget.onContinue(_selected),
      secondaryLabel: loc.v2OnboardingRitualDecideLater,
      onSecondary: widget.onSkip,
      extra: Semantics(
        container: true,
        label: loc.v2OnboardingRitualTitle,
        child: Column(
          children: [
            for (final (window, label) in options)
              RadioListTile<V2RitualWindow>(
                contentPadding: EdgeInsets.zero,
                value: window,
                groupValue: _selected,
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selected = v);
                },
                title: Text(label),
              ),
          ],
        ),
      ),
    );
  }
}

/// ONB-06 Brain Check intro
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
  Widget build(BuildContext context) {
    return _OnbScaffold(
      title: loc.v2OnboardingCheckIntroTitle,
      body: loc.v2OnboardingCheckIntroBody,
      footnote: loc.v2OnboardingCheckIntroMeta,
      ctaLabel: loc.v2OnboardingStartBrainCheck,
      onCta: onStart,
      secondaryLabel: loc.v2OnboardingSkipBrainCheck,
      onSecondary: onSkip,
    );
  }
}
