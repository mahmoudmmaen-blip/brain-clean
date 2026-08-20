import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'interactive_diagnostic_controller.dart';

final interactiveDiagnosticControllerProvider =
    ChangeNotifierProvider.autoDispose<InteractiveDiagnosticController>(
  (ref) => InteractiveDiagnosticController(),
);
