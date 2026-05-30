import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/hive_meta_keys.dart';
import '../data/app_meta_box_provider.dart';
import '../services/smart_notification_service.dart';
import '../services/weekly_report_service.dart';

/// Loads persisted locale from Hive or defaults to Arabic.
Locale readPersistedLocale(T Function<T>(ProviderListenable<T> provider) read) {
  try {
    final box = read(appMetaBoxProvider);
    final code = box.get(HiveMetaKeys.locale, defaultValue: 'ar') as String;
    return Locale(code);
  } catch (_) {
    return const Locale('ar');
  }
}

/// User-selected app locale — persisted in Hive [HiveMetaKeys.locale].
final localeProvider = StateProvider<Locale>((ref) {
  return readPersistedLocale(ref.read);
});

Future<void> persistLocale(
  WidgetRef ref,
  Locale locale,
) async {
  try {
    await ref.read(appMetaBoxProvider).put(
          HiveMetaKeys.locale,
          locale.languageCode,
        );
  } catch (_) {
    // Best-effort persistence.
  }
}

Future<void> toggleLocale(WidgetRef ref) async {
  final current = ref.read(localeProvider);
  final next = current.languageCode == 'ar'
      ? const Locale('en')
      : const Locale('ar');
  ref.read(localeProvider.notifier).state = next;
  await persistLocale(ref, next);
  try {
    ref.read(smartNotificationServiceProvider).rescheduleAll();
    ref.read(weeklyReportServiceProvider).schedule();
  } catch (_) {}
}

String localeFlagEmoji(Locale locale) =>
    locale.languageCode == 'ar' ? '🇸🇦' : '🇺🇸';

bool isRtlLocale(Locale locale) => locale.languageCode == 'ar';
