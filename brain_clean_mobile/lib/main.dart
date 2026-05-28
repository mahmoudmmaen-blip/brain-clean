import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localization_config.dart';
import 'core/network/supabase_client.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: BrainCleanApp()));
}

class BrainCleanApp extends ConsumerWidget {
  const BrainCleanApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    return MaterialApp.router(
      title: 'Brain Clean',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: supportedLocales,
      localeResolutionCallback: resolveAppLocale,
      routerConfig: router,
    );
  }
}
