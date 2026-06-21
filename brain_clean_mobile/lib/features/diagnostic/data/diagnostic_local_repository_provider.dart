import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'diagnostic_local_repository.dart';

part 'diagnostic_local_repository_provider.g.dart';

@Riverpod(keepAlive: true)
DiagnosticLocalRepository diagnosticLocalRepository(
  DiagnosticLocalRepositoryRef ref,
) {
  return DiagnosticLocalRepository();
}
