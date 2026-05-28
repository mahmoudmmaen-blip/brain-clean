import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localization_config.dart';
import 'core/network/supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/storage/hive_bootstrap.dart';
import 'core/theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveBootstrap.initialize();
  await HiveBootstrap.warmUpPersistentBoxes();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: BrainCleanApp()));
}

class BrainCleanApp extends ConsumerWidget {
  const BrainCleanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
