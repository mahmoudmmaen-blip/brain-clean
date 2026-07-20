import 'daily_program_state.dart';
import 'daily_step.dart';

abstract interface class DailyProgramRepository {
  Future<DailyProgramState> getToday({required int dayNumber});

  Future<DailyProgramState> completeStep(DailyStep step);

  Future<DailyProgramState> skipStep(DailyStep step);

  Future<DailyProgramState> completeDayEnd({String? reflectionNote});
}
