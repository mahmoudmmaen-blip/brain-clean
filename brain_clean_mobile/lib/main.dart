import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/l10n/app_localization_config.dart';
import 'core/network/supabase_client.dart';
import 'core/providers/locale_provider.dart';
import 'core/routing/app_router.dart';
import 'core/services/midnight_reset_service.dart';
import 'core/services/notifications_service.dart';
import 'core/services/purchases_service.dart';
import 'core/services/smart_notification_service.dart';
import 'core/services/weekly_report_service.dart';
import 'core/services/worry_window_notification_service.dart';
import 'core/security/root_detector.dart';
import 'core/security/security_status_provider.dart';
import 'core/storage/hive_bootstrap.dart';
import 'core/theme/app_color_theme.dart';
import 'core/theme/app_color_theme_provider.dart';
import 'core/theme/locale_theme.dart';
import 'features/gamification/application/xp_sync_service.dart';
import 'features/smart_reminders/application/smart_reminder_provider.dart';
import 'features/smart_reminders/data/smart_reminder_repository_provider.dart';

/// Loads bundled `.env.example` as documentation defaults only.
///
/// Real secrets must come from `--dart-define` (preferred). Placeholder
/// values in `.env.example` are ignored by [AppConfig] validation.
/// Never commit a real `.env`.
Future<void> _loadDotEnvSafely() async {
  try {
    await dotenv.load(fileName: '.env.example', isOptional: true);
  } catch (error) {
    debugPrint('dotenv: .env.example load failed: $error');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _loadDotEnvSafely();

  try {
    final notifications = NotificationsService();
    await notifications.initialize();
    await notifications.scheduleDailyReminder();
  } catch (error) {
    debugPrint('NotificationsService startup failed: $error');
  }

  await HiveBootstrap.initialize();
  HiveBootstrap.markRoutingGuardEnabled();
  await RootDetector.checkAndFlag();
  await HiveBootstrap.warmUpPersistentBoxes();
  await SupabaseConfig.initialize();

  await PurchasesService.initialize();

  runApp(const ProviderScope(child: BrainCleanApp()));
}

class BrainCleanApp extends ConsumerStatefulWidget {
  const BrainCleanApp({super.key});

  @override
  ConsumerState<BrainCleanApp> createState() => _BrainCleanAppState();
}

class _BrainCleanAppState extends ConsumerState<BrainCleanApp>
    with WidgetsBindingObserver {
  MidnightResetService? _midnightReset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(biometricLockSettingsProvider.notifier).hydrate();
      _midnightReset = MidnightResetService(read: ref.read);
      WidgetsBinding.instance.addObserver(_midnightReset!);
      _midnightReset!.triggerResetIfNeeded();
      ref.read(weeklyReportServiceProvider).schedule();
      ref.read(smartNotificationServiceProvider).rescheduleAll();
      ref.read(worryWindowNotificationServiceProvider).reschedule();
      ref.read(xpSyncServiceProvider.notifier).syncIfPossible();
      _trackSmartReminderOpen();
    });
  }

  void _trackSmartReminderOpen() {
    Future<void>(() async {
      try {
        await ref.read(smartReminderRepositoryProvider).logAppOpen();
        await ref.read(smartReminderProvider.notifier).analyzeAndSchedule();
      } catch (error) {
        debugPrint('SmartReminder tracking failed: $error');
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(xpSyncServiceProvider.notifier).syncIfPossible();
      _trackSmartReminderOpen();
    }
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final enabled = ref.read(biometricLockSettingsProvider);
      if (enabled) {
        ref.read(biometricAuthControllerProvider.notifier).lock();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_midnightReset != null) {
      WidgetsBinding.instance.removeObserver(_midnightReset!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final locale = ref.watch(localeProvider);
    final isRtl = isRtlLocale(locale);
    final colorTheme = ref.watch(effectiveColorThemeProvider);
    final themeData = LocaleTheme.themed(locale: locale, theme: colorTheme);

    return MaterialApp.router(
      key: ValueKey('theme-${colorTheme.name}'),
      title: 'Brain Clean',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      darkTheme: themeData,
      themeMode: colorTheme.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      locale: locale,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: supportedLocales,
      builder: (context, child) {
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      routerConfig: router,
    );
  }
}