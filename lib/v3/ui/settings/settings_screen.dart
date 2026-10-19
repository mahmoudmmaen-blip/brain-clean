import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/app_snack_bar.dart';
import '../../../core/presentation/confirm_dialog.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/security/security_status_provider.dart';
import '../../../core/services/external_link_service.dart';
import '../../../core/theme/app_color_theme.dart';
import '../../../core/theme/app_color_theme_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../features/pro/application/subscription_service_provider.dart';
import '../../../features/v2_premium/data/premium_controller_provider.dart';
import '../../../features/v2_premium/domain/premium_purchase_phase.dart';
import '../../application/notification_scheduler.dart';
import '../../application/usage_providers.dart';
import '../../application/v3_backup_service.dart';
import '../../application/v3_onboarding_gate_provider.dart';
import '../../application/v3_state_providers.dart';
import '../../data/v3_backup_crypto.dart';
import '../../routing/v3_routes.dart';
import 'backup_passphrase_sheet.dart';

const _playSubscriptionsUrl =
    'https://play.google.com/store/account/subscriptions';

/// V3 Settings — profile, prefs, usage, premium, backup, legal, reset.
class V3SettingsScreen extends ConsumerWidget {
  const V3SettingsScreen({super.key});

  TimeOfDay _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 20;
    final m = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0;
    return TimeOfDay(hour: h.clamp(0, 23), minute: m.clamp(0, 59));
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final app = await ref.read(v3StateRepositoryProvider).load();
    final profile = app.profile;
    if (profile == null) return;
    final controller = TextEditingController(text: profile.name ?? '');
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.v3SettingsNameEditTitle),
        content: TextField(
          key: const Key('v3_settings_name_field'),
          controller: controller,
          autofocus: true,
          maxLength: 40,
          decoration: InputDecoration(hintText: loc.v3SettingsNameHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved == null || !context.mounted) return;
    final trimmed = saved.trim();
    await ref.read(v3StateRepositoryProvider).saveProfile(
          trimmed.isEmpty
              ? profile.copyWith(clearName: true)
              : profile.copyWith(name: trimmed),
        );
    ref.invalidate(v3AppStateProvider);
  }

  Future<void> _pickReminder(BuildContext context, WidgetRef ref) async {
    final app = await ref.read(v3StateRepositoryProvider).load();
    final profile = app.profile;
    if (profile == null || !context.mounted) return;
    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(profile.reminderTime),
    );
    if (picked == null) return;
    final hhmm =
        '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    await ref.read(v3StateRepositoryProvider).saveProfile(
          profile.copyWith(reminderTime: hhmm),
        );
    ref.invalidate(v3AppStateProvider);
    if (context.mounted) {
      await rescheduleV3Notifications(ref, AppLocalizations.of(context)!);
    }
  }

  Future<void> _setEvening(BuildContext context, WidgetRef ref, bool value) async {
    final app = await ref.read(v3StateRepositoryProvider).load();
    final profile = app.profile;
    if (profile == null) return;
    await ref.read(v3StateRepositoryProvider).saveProfile(
          profile.copyWith(eveningCheckIn: value),
        );
    ref.invalidate(v3AppStateProvider);
    if (context.mounted) {
      await rescheduleV3Notifications(ref, AppLocalizations.of(context)!);
    }
  }

  Future<void> _setLanguage(WidgetRef ref, Locale next) async {
    ref.read(localeProvider.notifier).state = next;
    await persistLocale(ref, next);
    final app = await ref.read(v3StateRepositoryProvider).load();
    final profile = app.profile;
    if (profile != null) {
      await ref.read(v3StateRepositoryProvider).saveProfile(
            profile.copyWith(locale: next.languageCode),
          );
      ref.invalidate(v3AppStateProvider);
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final controller = ref.read(premiumControllerProvider);
    await controller.restore();
    if (!context.mounted) return;
    ref.invalidate(isProUserProvider);
    final phase = controller.state.phase;
    final msg = switch (phase) {
      PremiumPurchasePhase.restored => loc.v3SettingsRestoreOk,
      PremiumPurchasePhase.nothingToRestore => loc.v3SettingsRestoreNone,
      _ => loc.v3SettingsRestoreFail,
    };
    showAppSnackBar(context, msg);
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final pass = await showBackupPassphraseSheet(context, confirmTwice: true);
    if (pass == null || !context.mounted) return;
    try {
      await V3BackupService(ref.read(v3StateRepositoryProvider))
          .exportToShareFile(passphrase: pass);
      if (context.mounted) showAppSnackBar(context, loc.v3BackupExportDone);
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, loc.v3BackupImportFailed);
      }
    }
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.any,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !context.mounted) return;
    final file = result.files.first;
    final bytes = file.bytes ??
        (file.path == null ? null : await File(file.path!).readAsBytes());
    if (bytes == null || !context.mounted) return;

    final pass = await showBackupPassphraseSheet(context, confirmTwice: false);
    if (pass == null || !context.mounted) return;

    final confirmed = await showConfirmDialog(
      context,
      title: loc.v3BackupImportConfirmTitle,
      message: loc.v3BackupImportConfirmBody,
      confirmLabel: loc.commonConfirm,
      cancelLabel: loc.commonCancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    try {
      await V3BackupService(ref.read(v3StateRepositoryProvider)).importFromBytes(
        fileBytes: bytes,
        passphrase: pass,
      );
      ref.invalidate(v3AppStateProvider);
      await ref.read(v3OnboardingGateProvider.notifier).hydrate();
      if (context.mounted) {
        showAppSnackBar(context, loc.v3BackupImportDone);
        context.go(V3Routes.today);
      }
    } on V3BackupException catch (e) {
      if (!context.mounted) return;
      showAppSnackBar(
        context,
        e.code == 'wrong_passphrase'
            ? loc.v3BackupWrongPassphrase
            : loc.v3BackupImportFailed,
      );
    } catch (_) {
      if (context.mounted) {
        showAppSnackBar(context, loc.v3BackupImportFailed);
      }
    }
  }

  Future<void> _reset(BuildContext context, WidgetRef ref) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showConfirmDialog(
      context,
      title: loc.v3SettingsResetConfirmTitle,
      message: loc.v3SettingsResetConfirmBody,
      confirmLabel: loc.commonConfirm,
      cancelLabel: loc.commonCancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(v3StateRepositoryProvider).clearAll();
    ref.invalidate(v3AppStateProvider);
    ref.read(v3OnboardingGateProvider.notifier).markOnboardingIncomplete();
    if (context.mounted) context.go(V3Routes.welcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final isPro = ref.watch(isProUserProvider);
    final locale = ref.watch(localeProvider);
    final theme = ref.watch(selectedColorThemeProvider);
    final biometric = ref.watch(biometricLockSettingsProvider);
    final usage = ref.watch(usageSnapshotProvider).asData?.value;
    final appAsync = ref.watch(v3AppStateProvider);

    return Scaffold(
      key: const Key('v3_settings'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(loc.v3SettingsTitle),
      ),
      body: appAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (app) {
          final profile = app.profile;
          final name = profile?.name?.trim() ?? '';
          final letter = app.userInputs.futureLetter?.trim() ?? '';
          final reminder = profile?.reminderTime ?? '20:00';
          final evening = profile?.eveningCheckIn ?? true;
          final usageOn = usage?.hasAccess == true;

          return ListView(
            padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
            children: [
              ListTile(
                key: const Key('v3_settings_name'),
                title: Text(loc.v3SettingsName),
                subtitle: Text(name.isEmpty ? loc.v3SettingsNameHint : name),
                trailing: const Icon(Icons.edit_outlined),
                onTap: () => _editName(context, ref),
              ),
              ListTile(
                key: const Key('v3_settings_reminder'),
                title: Text(loc.v3SettingsReminderTime),
                subtitle: Text(reminder),
                trailing: const Icon(Icons.schedule_rounded),
                onTap: () => _pickReminder(context, ref),
              ),
              SwitchListTile(
                key: const Key('v3_settings_evening'),
                title: Text(loc.v3SettingsEveningCheckIn),
                value: evening,
                onChanged: (v) => _setEvening(context, ref, v),
              ),
              const Divider(),
              ListTile(
                title: Text(loc.v3SettingsLanguage),
                subtitle: Text(
                  locale.languageCode == 'ar'
                      ? loc.settingsLanguageArabic
                      : loc.settingsLanguageEnglish,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      key: const Key('v3_settings_lang_ar'),
                      label: Text(loc.settingsLanguageArabic),
                      selected: locale.languageCode == 'ar',
                      onSelected: (_) => _setLanguage(ref, const Locale('ar')),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      key: const Key('v3_settings_lang_en'),
                      label: Text(loc.settingsLanguageEnglish),
                      selected: locale.languageCode == 'en',
                      onSelected: (_) => _setLanguage(ref, const Locale('en')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(loc.v3SettingsTheme),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      key: const Key('v3_settings_theme_dark'),
                      label: Text(loc.v3SettingsThemeDark),
                      selected: theme == AppColorTheme.dark,
                      onSelected: (_) => ref
                          .read(selectedColorThemeProvider.notifier)
                          .select(AppColorTheme.dark),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      key: const Key('v3_settings_theme_light'),
                      label: Text(loc.v3SettingsThemeLight),
                      selected: theme == AppColorTheme.light,
                      onSelected: (_) => ref
                          .read(selectedColorThemeProvider.notifier)
                          .select(AppColorTheme.light),
                    ),
                  ),
                ],
              ),
              SwitchListTile(
                key: const Key('v3_settings_biometric'),
                title: Text(loc.v3SettingsBiometric),
                value: biometric,
                onChanged: (enabled) async {
                  final ok = await ref
                      .read(biometricLockSettingsProvider.notifier)
                      .setEnabled(enabled);
                  if (!ok && context.mounted) {
                    showAppSnackBar(context, loc.settingsBiometricUnavailable);
                  }
                },
              ),
              const Divider(),
              ListTile(
                key: const Key('v3_settings_usage'),
                title: Text(loc.v3SettingsUsageTitle),
                subtitle: Text(
                  usageOn ? loc.v3SettingsUsageOn : loc.v3SettingsUsageOff,
                ),
                trailing: usageOn
                    ? null
                    : TextButton(
                        key: const Key('v3_settings_usage_enable'),
                        onPressed: () async {
                          await ref.read(usageDataSourceProvider).openSettings();
                          await ref
                              .read(usageSnapshotProvider.notifier)
                              .refresh();
                        },
                        child: Text(loc.v3SettingsUsageEnable),
                      ),
              ),
              const Divider(),
              if (isPro) ...[
                ListTile(
                  key: const Key('v3_settings_premium'),
                  title: Text(loc.v3SettingsPremiumSubscribed),
                  subtitle: Text(loc.v3SettingsManageSubscription),
                  onTap: () => externalLinkService.openUri(_playSubscriptionsUrl),
                ),
              ] else
                ListTile(
                  key: const Key('v3_settings_premium'),
                  title: Text(loc.v3SettingsPremiumSubscribe),
                  onTap: () => context.push(
                    '${V3Routes.paywall}?source=settings',
                  ),
                ),
              ListTile(
                key: const Key('v3_settings_restore'),
                title: Text(loc.v3SettingsRestorePurchases),
                onTap: () => _restore(context, ref),
              ),
              const Divider(),
              ListTile(
                title: Text(loc.v3SettingsBackup),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('v3_settings_backup_export'),
                      onPressed: () => _export(context, ref),
                      child: Text(loc.v3SettingsBackupExport),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('v3_settings_backup_import'),
                      onPressed: () => _import(context, ref),
                      child: Text(loc.v3SettingsBackupImport),
                    ),
                  ),
                ],
              ),
              if (letter.isNotEmpty)
                ListTile(
                  key: const Key('v3_settings_letter'),
                  title: Text(loc.v3SettingsLetter),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(V3Routes.letter),
                ),
              const Divider(),
              ListTile(
                key: const Key('v3_settings_privacy'),
                title: Text(loc.settingsPrivacyPolicy),
                onTap: () => externalLinkService.openPrivacyPolicy(),
              ),
              ListTile(
                key: const Key('v3_settings_contact'),
                title: Text(loc.settingsContactUs),
                onTap: () => externalLinkService.openContactEmail(),
              ),
              ListTile(
                key: const Key('v3_settings_reset'),
                title: Text(
                  loc.v3SettingsReset,
                  style: const TextStyle(color: Colors.redAccent),
                ),
                onTap: () => _reset(context, ref),
              ),
              const SizedBox(height: 16),
              Text(
                loc.v3SettingsVersion(AppConfig.appVersion),
                key: const Key('v3_settings_version'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppDesignConstants.darkOnSurfaceMuted,
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}
