import 'clarity_check_content.dart';
import 'exercises_content.dart';
import 'program_content.dart';
import 'sos_content.dart';

/// All V3 bundled content, loaded once.
class ContentBundle {
  const ContentBundle({
    required this.program,
    required this.exercises,
    required this.clarityCheck,
    required this.sos,
  });

  final ProgramContent program;
  final ExercisesContent exercises;
  final ClarityCheckContent clarityCheck;
  final SosContent sos;
}
