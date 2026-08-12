import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/application/app_preferences_provider.dart';
import '../../../core/config/app_config.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/language_toggle_button.dart';
import '../../../core/services/external_link_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';

/// Quiet vertical rhythm — Phase A hierarchy unchanged.
const double _kGapAfterIdentity = 6;
const double _kGapBeforeFirstSection = 24;
const double _kGapBetweenSections = 18;
const double _kGapSectionToRow = 2;
const double _kBottomScrollPadding = 40;
const int _kDisplayNameMaxLength = 40;

/// V2 Profile tab — calm personal control center (not Brain Profile analytics).
///
/// Locked hierarchy (Phase A):
/// identity → recovery setup → preferences → privacy/data →
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

  Future<void> _editDisplayName() async {
    final loc = AppLocalizations.of(context)!;
    final current = ref.read(appPreferencesProvider).profileDisplayName.trim();
    final controller = TextEditingController(text: current);
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: Text(
            loc.v2ProfileEditNameTitle,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          content: TextField(
            key: const Key('v2_profile_name_field'),
            controller: controller,
            autofocus: true,
            maxLength: _kDisplayNameMaxLength,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: loc.v2ProfileEditNameHint,
              hintStyle: const TextStyle(color: AppColors.textSecondary),
              counterStyle: const TextStyle(color: AppColors.textSecondary),
            ),
            onSubmitted: (value) => Navigator.of(ctx).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(loc.commonCancel),
            ),
            TextButton(
              key: const Key('v2_profile_name_save'),
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: Text(loc.commonConfirm),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (saved == null || !mounted) return;
    try {
      await ref
          .read(appPreferencesProvider.notifier)
          .setProfileDisplayName(saved);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.v2ProfileNameSaveFailed)),
      );
    }
  }

  Future<void> _openExternal(Future<bool> Function() open) async {
    final loc = AppLocalizations.of(context)!;
    final ok = await open();
    if (!mounted || ok) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.settingsLinkUnavailable)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final prefs = ref.watch(appPreferencesProvider);
    final isPro = ref.watch(isProUserProvider);
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
          subscriptionSubtitle:
              isPro ? loc.v2PremiumAlreadyActive : loc.v2PremiumFreeStatus,
          appVersion: AppConfig.appVersion,
          onEditDisplayName: _editDisplayName,
          onOpenBrainProfile: () {
            final location = V2SetupRecovery.profileBrainActionLocation(
              hasProfilePack: _hasBrainProfile,
            );
            if (!_hasBrainProfile) {
              context.go(location);
            } else {
              context.push(location);
            }
          },
          onOpenSettings: () => context.push(AppRoutes.settings),
          onOpenPremium: () => context.go(
            '${AppRoutes.v2Premium}?source=profile',
          ),
          onOpenSafa: () => context.go(
            '${AppRoutes.v2Safa}?origin=profile&returnTo=${Uri.encodeComponent(AppRoutes.v2Profile)}',
          ),
          onOpenPrivacyPolicy: () =>
              _openExternal(externalLinkService.openPrivacyPolicy),
          onOpenContact: () =>
              _openExternal(externalLinkService.openContactEmail),
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
    required this.subscriptionSubtitle,
    required this.appVersion,
    required this.onEditDisplayName,
    required this.onOpenBrainProfile,
    required this.onOpenSettings,
    required this.onOpenPremium,
    required this.onOpenSafa,
    required this.onOpenPrivacyPolicy,
    required this.onOpenContact,
  });

  final AppLocalizations loc;
  final String displayName;
  final bool loadingSetup;
  final bool hasBrainProfile;
  final String subscriptionSubtitle;
  final String appVersion;
  final VoidCallback onEditDisplayName;
  final VoidCallback onOpenBrainProfile;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSafa;
  final VoidCallback onOpenPrivacyPolicy;
  final VoidCallback onOpenContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, _kBottomScrollPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            label: '${loc.v2ProfileEditNameTitle}. $displayName',
            child: InkWell(
              key: const Key('v2_profile_identity'),
              onTap: onEditDisplayName,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 20,
                      color: AppColors.textSecondary.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: _kGapAfterIdentity),
          Text(
            loc.v2ProfileOrientation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: _kGapBeforeFirstSection),
          _SectionLabel(loc.v2ProfileSectionRecovery),
          const SizedBox(height: _kGapSectionToRow),
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
          const SizedBox(height: _kGapBetweenSections),
          _SectionLabel(loc.v2ProfileSectionPreferences),
          const SizedBox(height: _kGapSectionToRow),
          _ProfileRow(
            key: const Key('v2_profile_settings_row'),
            title: loc.v2ProfilePreferencesRow,
            subtitle: loc.v2ProfilePreferencesHint,
            onTap: onOpenSettings,
          ),
          const SizedBox(height: _kGapBetweenSections),
          _SectionLabel(loc.v2ProfileSectionSubscription),
          const SizedBox(height: _kGapSectionToRow),
          _ProfileRow(
            key: const Key('v2_profile_premium_row'),
            title: loc.v2PremiumManage,
            subtitle: subscriptionSubtitle,
            onTap: onOpenPremium,
          ),
          const SizedBox(height: _kGapBetweenSections),
          _SectionLabel(loc.v2ProfileSectionHelp),
          const SizedBox(height: _kGapSectionToRow),
          _ProfileRow(
            key: const Key('v2_profile_safa_row'),
            title: loc.v2SafaEntryProfile,
            subtitle: loc.v2ProfileHelpHint,
            onTap: onOpenSafa,
          ),
          const SizedBox(height: _kGapBetweenSections),
          _SectionLabel(loc.v2ProfileSectionAbout),
          const SizedBox(height: _kGapSectionToRow),
          Padding(
            key: const Key('v2_profile_version_row'),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.settingsVersion,
                  softWrap: true,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appVersion,
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _ProfileRow(
            key: const Key('v2_profile_privacy_policy_row'),
            title: loc.settingsPrivacyPolicy,
            subtitle: loc.v2ProfileLegalHint,
            onTap: onOpenPrivacyPolicy,
          ),
          _ProfileRow(
            key: const Key('v2_profile_contact_row'),
            title: loc.settingsContactUs,
            subtitle: loc.v2ProfileContactHint,
            onTap: onOpenContact,
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
    return Semantics(
      header: true,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        softWrap: true,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
