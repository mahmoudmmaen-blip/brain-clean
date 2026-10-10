import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/l10n/app_localization_config.dart';
import 'core/network/supabase_client.dart';
import 'core/providers/locale_provider.dart';
import 'core/security/root_detector.dart';
import 'core/security/security_status_provider.dart';
import 'core/storage/hive_bootstrap.dart';
import 'core/theme/app_color_theme.dart';
import 'core/theme/app_color_theme_provider.dart';
import 'core/theme/locale_theme.dart';
import 'core/theme/system_ui.dart';
import 'v3/routing/v3_router.dart';

Future<void> _loadDotEnvSafely() async {
  try {
    await dotenv.load(fileName: '.env', isOptional: true);
  } catch (error) {
    debugPrint('dotenv: .env load failed: $error');
  }
  if (dotenv.env.isEmpty) {
    try {
      await dotenv.load(fileName: '.env.example', isOptional: true);
    } catch (error) {
      debugPrint('dotenv: .env.example load failed: $error');
    }
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemUi.enableEdgeToEdge();

  await _loadDotEnvSafely();

  await HiveBootstrap.initialize();
  await RootDetector.checkAndFlag();
  await HiveBootstrap.warmUpPersistentBoxes();
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: BrainCleanApp()));
}

class BrainCleanApp extends ConsumerStatefulWidget {
  const BrainCleanApp({super.key});

  @override
  ConsumerState<BrainCleanApp> createState() => _BrainCleanAppState();
}

class _BrainCleanAppState extends ConsumerState<BrainCleanApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(biometricLockSettingsProvider.notifier).hydrate();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(v3GoRouterProvider);
    final locale = ref.watch(localeProvider);
    final isRtl = isRtlLocale(locale);

    return Consumer(
      builder: (context, ref, _) {
        final colorTheme = ref.watch(selectedColorThemeProvider);
        final themeData = LocaleTheme.themed(locale: locale, theme: colorTheme);
        final overlay = SystemUi.overlayStyle(colorTheme.brightness);
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: overlay,
          child: MaterialApp.router(
            key: ValueKey<String>('app-theme-${colorTheme.name}'),
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
          ),
        );
      },
    );
  }
}
