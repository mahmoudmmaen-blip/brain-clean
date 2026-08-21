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
import '../../../core/theme/app_design_constants.dart';
import '../../../core/theme/v2_shell_visual.dart';
import '../../brain_check/data/brain_check_local_repository_provider.dart';
import '../../brain_profile/data/brain_profile_repository_provider.dart';
import '../../home/presentation/home_streak_provider.dart';
import '../../pro/application/subscription_service_provider.dart';
import '../../v2_onboarding/domain/v2_setup_recovery.dart';
import '../../../core/services/smart_notification_service.dart';

/// Quiet vertical rhythm — Phase A hierarchy unchanged.
const double _kGapBeforeFirstSection = AppDesignConstants.v2GapMajor;
const double _kGapBetweenSections = AppDesignConstants.v2GapSection;
const double _kGapSectionToRow = AppDesignConstants.v2GapSectionLabel;
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
  int? _daysUntilWeeklyCheck;

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
      final result =
          await ref.read(brainCheckLocalRepositoryProvider).loadResult();
      if (!mounted) return;
      setState(() {
        _hasBrainProfile = pack != null;
        _daysUntilWeeklyCheck = _weeklyUnlockDays(result?.completedAt);
        _loadingSetup = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasBrainProfile = false;
        _daysUntilWeeklyCheck = null;
        _loadingSetup = false;
      });
    }
  }

  /// Null = unlocked; >0 = locked for that many days.
  static int? _weeklyUnlockDays(DateTime? lastCompletedUtc) {
    if (lastCompletedUtc == null) return null;
    final last = lastCompletedUtc.toLocal();
    final lastDay = DateTime(last.year, last.month, last.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final elapsed = today.difference(lastDay).inDays;
    if (elapsed >= 7) return null;
    return 7 - elapsed;
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
            FilledButton(
              key: const Key('v2_profile_name_save'),
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              style: V2ShellVisual.primaryFilled(),
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
    final streak = ref.watch(homeStreakSnapshotProvider);
    final stored = prefs.profileDisplayName.trim();
    final displayName = stored.isEmpty ? loc.v2ProfileDefaultIdentity : stored;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: const SizedBox.shrink(),
        actions: const [LanguageToggleButton()],
      ),
      body: SafeArea(
        child: V2ProfileHomeBody(
          loc: loc,
          displayName: displayName,
          purityDays: streak.days,
          notificationsEnabled: prefs.emotionNotificationsEnabled,
          loadingSetup: _loadingSetup,
          hasBrainProfile: _hasBrainProfile,
          daysUntilWeeklyCheck: _daysUntilWeeklyCheck,
          subscriptionSubtitle:
              isPro ? loc.v2PremiumAlreadyActive : loc.v2PremiumFreeStatus,
          isPro: isPro,
          appVersion: AppConfig.appVersion,
          onEditDisplayName: _editDisplayName,
          onNotificationsChanged: (enabled) async {
            try {
              await ref
                  .read(appPreferencesProvider.notifier)
                  .setEmotionNotifications(enabled);
              await ref
                  .read(smartNotificationServiceProvider)
                  .rescheduleAll();
            } catch (_) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.v2ProfileNameSaveFailed)),
              );
            }
          },
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
          onOpenBaselineCheck: () =>
              context.go(V2SetupRecovery.baselineBrainCheckLocation()),
          onOpenWeeklyCheck: () {
            if (_daysUntilWeeklyCheck != null && _daysUntilWeeklyCheck! > 0) {
              return;
            }
            context.go(V2SetupRecovery.weeklyBrainCheckLocation());
          },
          onOpenTestsCatalog: () => context.push(AppRoutes.v2Tests),
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
    required this.purityDays,
    required this.notificationsEnabled,
    required this.loadingSetup,
    required this.hasBrainProfile,
    required this.daysUntilWeeklyCheck,
    required this.subscriptionSubtitle,
    required this.isPro,
    required this.appVersion,
    required this.onEditDisplayName,
    required this.onNotificationsChanged,
    required this.onOpenBrainProfile,
    required this.onOpenBaselineCheck,
    required this.onOpenWeeklyCheck,
    required this.onOpenTestsCatalog,
    required this.onOpenSettings,
    required this.onOpenPremium,
    required this.onOpenSafa,
    required this.onOpenPrivacyPolicy,
    required this.onOpenContact,
  });

  final AppLocalizations loc;
  final String displayName;
  final int purityDays;
  final bool notificationsEnabled;
  final bool loadingSetup;
  final bool hasBrainProfile;
  final int? daysUntilWeeklyCheck;
  final String subscriptionSubtitle;
  final bool isPro;
  final String appVersion;
  final VoidCallback onEditDisplayName;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onOpenBrainProfile;
  final VoidCallback onOpenBaselineCheck;
  final VoidCallback onOpenWeeklyCheck;
  final VoidCallback onOpenTestsCatalog;
  final VoidCallback onOpenSettings;
  final VoidCallback onOpenPremium;
  final VoidCallback onOpenSafa;
  final VoidCallback onOpenPrivacyPolicy;
  final VoidCallback onOpenContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: V2ShellVisual.pagePadding(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          V2PageHeader(
            title: loc.v2ProfileTitle,
            subtitle: loc.v2ProfileOrientation,
          ),
          const SizedBox(height: _kGapBeforeFirstSection),
          Semantics(
            header: true,
            label: '${loc.v2ProfileEditNameTitle}. $displayName',
            child: InkWell(
              key: const Key('v2_profile_identity'),
              onTap: onEditDisplayName,
              borderRadius:
                  BorderRadius.circular(AppDesignConstants.radiusChip),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        displayName,
                        style: V2ShellVisual.heroTitle(theme),
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
          const SizedBox(height: _kGapBetweenSections),
          V2HeroCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.v2ProfilePurityHeading,
                        style: V2ShellVisual.sectionLabel(theme),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.v2ProfilePurityDay(purityDays),
                        style: V2ShellVisual.heroMetricValue(theme),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loc.v2ProfilePuritySubtitle,
                        style: V2ShellVisual.captionMuted(theme),
                      ),
                    ],
                  ),
                ),
                Text('🌿', style: theme.textTheme.displaySmall),
              ],
            ),
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.v2ProfileSectionRecovery),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
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
              _ProfileRow(
                key: const Key('v2_profile_baseline_check_row'),
                title: loc.v2ProfileBaselineTestTitle,
                subtitle: loc.v2ProfileBaselineTestSubtitle,
                onTap: onOpenBaselineCheck,
              ),
              _ProfileRow(
                key: const Key('v2_profile_weekly_check_row'),
                title: loc.v2ProfileWeeklyTestTitle,
                subtitle: loadingSetup
                    ? loc.v2ProfileBrainProfileLoading
                    : (daysUntilWeeklyCheck != null &&
                            daysUntilWeeklyCheck! > 0)
                        ? loc.v2ProfileWeeklyTestLocked(daysUntilWeeklyCheck!)
                        : hasBrainProfile
                            ? loc.v2ProfileWeeklyTestReady
                            : loc.v2ProfileWeeklyTestSubtitle,
                onTap: (daysUntilWeeklyCheck != null &&
                        daysUntilWeeklyCheck! > 0)
                    ? null
                    : onOpenWeeklyCheck,
              ),
              _ProfileRow(
                key: const Key('v2_profile_tests_catalog_row'),
                title: loc.v2ProfileTestsCatalogTitle,
                subtitle: loc.v2ProfileTestsCatalogSubtitle,
                onTap: onOpenTestsCatalog,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.v2ProfileSectionPreferences),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              _ProfileRow(
                key: const Key('v2_profile_settings_row'),
                title: loc.v2ProfilePreferencesRow,
                subtitle: loc.v2ProfilePreferencesHint,
                onTap: onOpenSettings,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.v2ProfileNotificationsRow,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            loc.v2ProfileNotificationsHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      key: const Key('v2_profile_notifications_switch'),
                      value: notificationsEnabled,
                      activeThumbColor: AppColors.primary,
                      onChanged: onNotificationsChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.v2ProfileSectionSubscription),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              _ProfileRow(
                key: const Key('v2_profile_premium_row'),
                title: isPro ? loc.v2PremiumManage : loc.v2PremiumViewPlans,
                subtitle: subscriptionSubtitle,
                onTap: onOpenPremium,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.v2ProfileSectionHelp),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              _ProfileRow(
                key: const Key('v2_profile_safa_row'),
                title: loc.v2SafaEntryProfile,
                subtitle: loc.v2ProfileHelpHint,
                onTap: onOpenSafa,
              ),
            ],
          ),
          const SizedBox(height: _kGapBetweenSections),
          V2SectionLabel(loc.v2ProfileSectionAbout),
          const SizedBox(height: _kGapSectionToRow),
          V2SettingsGroup(
            children: [
              Padding(
                key: const Key('v2_profile_version_row'),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
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
        ],
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
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusChip),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppDesignConstants.minTouchTarget,
          ),
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
                const SizedBox(width: AppDesignConstants.v2GapTight),
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
