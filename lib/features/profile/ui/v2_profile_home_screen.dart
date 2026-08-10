import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';

/// V2 Profile tab — calm personal control center (not Brain Profile analytics).
///
/// Hierarchy: identity → recovery setup link → preferences → privacy/data →
/// subscription → help → about.
class V2ProfileHomeScreen extends ConsumerStatefulWidget {
  const V2ProfileHomeScreen({super.key});

  @override
  ConsumerState<V2ProfileHomeScreen> createState() =>
      _V2ProfileHomeScreenState();
}

class _V2ProfileHomeScreenState extends ConsumerState<V2ProfileHomeScreen> {
  var _loadingSetup = true;
  var _hasBrainProfile = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadSetup);
  }

  Future<void> _loadSetup() async {
    if (!mounted) return;
    setState(() => _loadingSetup = true);
    try {
      final pack = await ref.read(brainProfileRepositoryProvider).latest();
      if (!mounted) return;
      setState(() {
        _hasBrainProfile = pack != null;
        _loadingSetup = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasBrainProfile = false;
        _loadingSetup = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final stored = prefs.profileDisplayName.trim();
    final displayName = stored.isEmpty ? loc.v2ProfileDefaultIdentity : stored;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Semantics(
          header: true,
          child: Text(loc.v2ProfileTitle),
        ),
        actions: const [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: V2ProfileHomeBody(
          loc: loc,
          displayName: displayName,
          loadingSetup: _loadingSetup,
          hasBrainProfile: _hasBrainProfile,
          appVersion: AppConfig.appVersion,
          onOpenBrainProfile: () => context.push(AppRoutes.v2BrainProfile),
          onOpenSettings: () => context.push(AppRoutes.settings),
          onOpenPremium: () => context.go(
            '${AppRoutes.v2Premium}?source=profile',
          ),
          onOpenSafa: () => context.go(
            '${AppRoutes.v2Safa}?origin=profile&returnTo=${Uri.encodeComponent(AppRoutes.v2Profile)}',
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
class V2ProfileHomeBody extends StatelessWidget {
  const V2ProfileHomeBody({
    super.key,
    required this.loc,
    required this.displayName,
    required this.loadingSetup,
    required this.hasBrainProfile,
    required this.appVersion,
    required this.onOpenBrainProfile,
    required this.onOpenSettings,
    required this.onOpenPremium,
    required this.onOpenSafa,
  });

  final AppLocalizations loc;
  final String displayName;
  final bool loadingSetup;
  final bool hasBrainProfile;
  final String appVersion;
  final VoidCallback onOpenBrainProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSafa;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              displayName,
              key: const Key('v2_profile_identity'),
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            loc.v2ProfileOrientation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 28),
          _SectionLabel(loc.v2ProfileSectionRecovery),
          _ProfileRow(
            key: const Key('v2_profile_brain_profile_row'),
            title: loc.v2ProfileBrainProfile,
            subtitle: loadingSetup
                ? loc.v2ProfileBrainProfileLoading
                : hasBrainProfile
                    ? loc.v2ProfileBrainProfileReady
                    : loc.v2ProfileBrainProfileMissing,
            onTap: onOpenBrainProfile,
          ),
          const SizedBox(height: 20),
          _SectionLabel(loc.v2ProfileSectionPreferences),
          _ProfileRow(
            key: const Key('v2_profile_preferences_row'),
            title: loc.v2ProfilePreferencesRow,
            subtitle: loc.v2ProfilePreferencesHint,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 20),
          _SectionLabel(loc.v2ProfileSectionPrivacy),
          _ProfileRow(
            key: const Key('v2_profile_privacy_row'),
            title: loc.v2ProfilePrivacyRow,
            subtitle: loc.v2ProfilePrivacyHint,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: 20),
          _SectionLabel(loc.v2ProfileSectionSubscription),
          _ProfileRow(
            key: const Key('v2_profile_premium_row'),
            title: loc.v2PremiumManage,
            subtitle: loc.v2ProfileSubscriptionHint,
            onTap: onOpenPremium,
          ),
          const SizedBox(height: 20),
          _SectionLabel(loc.v2ProfileSectionHelp),
          _ProfileRow(
            key: const Key('v2_profile_safa_row'),
            title: loc.v2SafaEntryProfile,
            subtitle: loc.v2ProfileHelpHint,
            onTap: onOpenSafa,
          ),
          const SizedBox(height: 20),
          _SectionLabel(loc.v2ProfileSectionAbout),
          ListTile(
            key: const Key('v2_profile_version_row'),
            contentPadding: EdgeInsets.zero,
            minVerticalPadding: 12,
            title: Text(
              loc.settingsVersion,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            trailing: Text(
              appVersion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Semantics(
        header: true,
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        minVerticalPadding: 14,
        title: Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            height: 1.3,
          ),
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.chevron_left
              : Icons.chevron_right,
          color: AppColors.textSecondary.withValues(alpha: 0.8),
        ),
        onTap: onTap,
      ),
    );
  }
}
