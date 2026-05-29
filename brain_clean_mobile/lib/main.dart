import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localization_config.dart';
import 'core/network/supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/services/midnight_reset_service.dart';
import 'core/storage/hive_bootstrap.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();
  await HiveBootstrap.warmUpPersistentBoxes();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: BrainCleanApp()));
}

class BrainCleanApp extends ConsumerStatefulWidget {
  const BrainCleanApp({super.key});

  @override
  ConsumerState<BrainCleanApp> createState() => _BrainCleanAppState();
}

class _BrainCleanAppState extends ConsumerState<BrainCleanApp> {
  MidnightResetService? _midnightReset;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _midnightReset = MidnightResetService(read: ref.read);
      WidgetsBinding.instance.addObserver(_midnightReset!);
      _midnightReset!.triggerResetIfNeeded();
    });
  }

  @override
  void dispose() {
    if (_midnightReset != null) {
      WidgetsBinding.instance.removeObserver(_midnightReset!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);

    return MaterialApp.router(
      title: 'Brain Clean',
      debugShowCheckedModeBanner: false,
      theme: ref.watch(appLightThemeProvider),
      darkTheme: ref.watch(appDarkThemeProvider),
      themeMode: themeMode,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: supportedLocales,
      localeResolutionCallback: resolveAppLocale,
      routerConfig: router,
    );
  }
}
