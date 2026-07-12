import 'daily_program_state.dart';
import 'daily_step.dart';
import 'daily_step_status.dart';

/// Pure helpers for the daily hybrid journey.
class DailyProgramService {
  const DailyProgramService._();

  static List<DailyStepEntry> buildTodaySteps() {
    final order = DailyStep.values;
    return [
      for (var i = 0; i < order.length; i++)
        DailyStepEntry(
          step: order[i],
          status: i == 0 ? DailyStepStatus.current : DailyStepStatus.locked,
        ),
    ];
  }

  static String getStepTitle(DailyStep step) {
    return switch (step) {
      DailyStep.dayStart => 'بداية اليوم',
      DailyStep.water => 'اشرب كوب ماء',
      DailyStep.movement => 'الحركة',
      DailyStep.sukoon => 'جلسة سكون',
      DailyStep.mood => 'قيّم مزاجك',
      DailyStep.journal => 'دفتر اليوم',
      DailyStep.dayEnd => 'إغلاق اليوم',
    };
  }

  static String getStepEmoji(DailyStep step) {
    return switch (step) {
      DailyStep.dayStart => '🌅',
      DailyStep.water => '💧',
      DailyStep.movement => '🚶',
      DailyStep.sukoon => '🧘',
      DailyStep.mood => '😊',
      DailyStep.journal => '📝',
      DailyStep.dayEnd => '🏁',
    };
  }

  static String getStepSubtitle(DailyStep step) {
    return switch (step) {
      DailyStep.dayStart => 'ابدأ يومك بنِيّة هادئة',
      DailyStep.water => 'كوب واحد يوقظ جسمك',
      DailyStep.movement => 'تحرك دقيقتين — يكفي',
      DailyStep.sukoon => 'دقيقة سكون أو تنفس',
      DailyStep.mood => 'سجّل إحساسك بصدق',
      DailyStep.journal => 'اختياري — سطر واحد يكفي',
      DailyStep.dayEnd => 'أختِم يومك بلطف',
    };
  }

  static String getMorningMessage(DateTime date) {
    return switch (date.day % 5) {
      0 => 'صباح الخير 🌿 هدفنا اليوم مش الكمال، بس خطوة واحدة صح.',
      1 => 'يوم جديد 🌅 خطوة صغيرة النهارده أحسن من خطة مثالية بكرة.',
      2 => 'أهلاً بيك 🌿 مش لازم تعمل كل حاجة — يكفي تبدأ.',
      3 => 'نفس عميق 🍃 اليوم رحلة، مش سباق.',
      _ => 'بداية هادية ✨ كل خطوة بتقرّبك من صفاء ذهنك.',
    };
  }

  static String getMicroReward(DailyStep step) {
    return switch (step.indexInJourney % 4) {
      0 => '✔ رائع',
      1 => '+5 نقاط هدوء',
      2 => 'تم تحديث مؤشرك',
      _ => 'خطوة للأمام 💚',
    };
  }

  /// Advances statuses after completing [step].
  static List<DailyStepEntry> afterComplete(
    List<DailyStepEntry> steps,
    DailyStep step,
  ) {
    final now = DateTime.now();
    final updated = <DailyStepEntry>[];
    var unlockNext = false;

    for (final entry in steps) {
      if (entry.step == step) {
        updated.add(
          entry.copyWith(
            status: DailyStepStatus.done,
            completedAt: now,
          ),
        );
        unlockNext = true;
        continue;
      }
      if (unlockNext && entry.status == DailyStepStatus.locked) {
        updated.add(entry.copyWith(status: DailyStepStatus.current));
        unlockNext = false;
      } else {
        updated.add(entry);
      }
    }
    return updated;
  }

  /// Marks optional journal as skipped and unlocks the next step.
  static List<DailyStepEntry> afterSkip(
    List<DailyStepEntry> steps,
    DailyStep step,
  ) {
    if (step != DailyStep.journal) return steps;
    final now = DateTime.now();
    final updated = <DailyStepEntry>[];
    var unlockNext = false;

    for (final entry in steps) {
      if (entry.step == step) {
        updated.add(
          entry.copyWith(
            status: DailyStepStatus.skipped,
            completedAt: now,
          ),
        );
        unlockNext = true;
        continue;
      }
      if (unlockNext && entry.status == DailyStepStatus.locked) {
        updated.add(entry.copyWith(status: DailyStepStatus.current));
        unlockNext = false;
      } else {
        updated.add(entry);
      }
    }
    return updated;
  }
}
