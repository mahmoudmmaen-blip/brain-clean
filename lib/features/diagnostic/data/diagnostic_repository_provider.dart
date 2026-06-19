import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'diagnostic_repository.dart';

part 'diagnostic_repository_provider.g.dart';

@riverpod
DiagnosticRepository diagnosticRepository(DiagnosticRepositoryRef ref) {
  return DiagnosticRepository();
}
