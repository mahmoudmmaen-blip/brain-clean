import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/brain_profile_domain.dart';
import '../domain/brain_profile_domain_result.dart';
import '../domain/profile_pack.dart';

/// PRF-02 — plain-language domain detail sheet content.
class BrainProfileDomainDetailBody extends StatelessWidget {
  const BrainProfileDomainDetailBody({
    super.key,
    required this.loc,
    required this.languageCode,
    required this.domain,
    required this.result,
    required this.pack,
    required this.onClose,
  });

  final AppLocalizations loc;
  final String languageCode;
  final BrainProfileDomain domain;
  final BrainProfileDomainResult? result;
  final ProfilePack pack;
  final VoidCallback onClose;

  bool get _isStronger => pack.strongerDomainIds.contains(domain.id);
  bool get _isSupport => pack.supportDomainIds.contains(domain.id);

  @override
  Widget build(BuildContext context) {
    final estimate = result == null || !result!.hasData
        ? loc.brainProfileDomainNoData
        : loc.brainProfileDomainMean(
            '${result!.displayScore ?? (result!.normalizedMean! + 0.5).floor()}',
          );

    final role = _isStronger
        ? loc.brainProfileDomainStrongerLabel
        : _isSupport
            ? loc.brainProfileDomainSupportLabel
            : loc.brainProfileDomainNeutralLabel;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                domain.titleForLocale(languageCode),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 12),
            Text(domain.definitionForLocale(languageCode)),
            const SizedBox(height: 16),
            Semantics(
              header: true,
              child: Text(
                loc.brainProfileDomainEstimateHeading,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            const SizedBox(height: 4),
            Text(estimate),
            const SizedBox(height: 12),
            Text(
              role,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(loc.brainProfileDomainBasedOnAnswers),
            const SizedBox(height: 8),
            Text(
              loc.brainProfileDomainNonMedical,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              loc.brainProfileDomainPlanPreviewHint,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onClose,
                child: Text(loc.brainProfileDomainClose),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
