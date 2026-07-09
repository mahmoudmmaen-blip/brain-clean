import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/smart_reminder_repository.dart';
import 'smart_reminder_repository_impl.dart';

part 'smart_reminder_repository_provider.g.dart';

@Riverpod(keepAlive: true)
SmartReminderRepository smartReminderRepository(
  SmartReminderRepositoryRef ref,
) {
  return SmartReminderRepositoryImpl();
}
