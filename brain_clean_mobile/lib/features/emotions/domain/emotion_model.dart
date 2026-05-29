/// Eight sectors of the feelings wheel.
enum EmotionCategory {
  sadness,
  fear,
  love,
  joy,
  surprise,
  disgust,
  anger,
  calm,
}

/// A single selectable emotion on the wheel.
class EmotionModel {
  const EmotionModel({
    required this.category,
    required this.label,
    required this.intensity,
    required this.recoveryImpact,
  });

  final EmotionCategory category;
  final String label;

  /// 1 = core, 2 = mid, 3 = outer ring.
  final int intensity;
  final double recoveryImpact;

  static double recoveryImpactFor(EmotionCategory category, int intensity) {
    if (category == EmotionCategory.surprise ||
        category == EmotionCategory.calm) {
      return 0;
    }
    if (category == EmotionCategory.love || category == EmotionCategory.joy) {
      if (intensity == 1) return 0.05;
      if (intensity == 3) return 0.10;
      return 0.075;
    }
    // sadness, fear, anger, disgust
    if (intensity == 1) return -0.08;
    if (intensity == 3) return -0.15;
    return -0.11;
  }

  static EmotionModel _e(
    EmotionCategory category,
    int intensity,
    String label,
  ) =>
      EmotionModel(
        category: category,
        label: label,
        intensity: intensity,
        recoveryImpact: recoveryImpactFor(category, intensity),
      );

  static final List<EmotionModel> catalog = [
    ..._ring(EmotionCategory.sadness, 1, const ['حزن']),
    ..._ring(
      EmotionCategory.sadness,
      2,
      const ['هم', 'يأس', 'إهمال', 'عار', 'خيبة أمل', 'معاناة', 'اشمئزاز'],
    ),
    ..._ring(
      EmotionCategory.sadness,
      3,
      const [
        'أسى',
        'صدمة',
        'اكتئاب',
        'ضعف',
        'غم',
        'وحدة',
        'عزلة',
        'تأنيب',
        'ندم',
      ],
    ),
    ..._ring(EmotionCategory.fear, 1, const ['خوف']),
    ..._ring(
      EmotionCategory.fear,
      2,
      const ['فزع', 'زعر', 'توتر', 'تضاؤل', 'غيرة', 'امتعاض', 'ازدراء'],
    ),
    ..._ring(
      EmotionCategory.fear,
      3,
      const [
        'قلق',
        'أنزلال',
        'يقظة',
        'تحفز',
        'انزعاج',
        'هستيريا',
        'ملع',
        'عجز',
        'ارتياع',
      ],
    ),
    ..._ring(EmotionCategory.love, 1, const ['حب']),
    ..._ring(
      EmotionCategory.love,
      2,
      const ['سلام', 'لطف', 'رغبة', 'توق', 'حنان', 'افتتان', 'انتشاء'],
    ),
    ..._ring(
      EmotionCategory.love,
      3,
      const [
        'ارتياح',
        'رضا',
        'عطف',
        'رعاية',
        'شغف',
        'انجذاب',
        'رقة',
        'ولع',
        'رومانسية',
      ],
    ),
    ..._ring(EmotionCategory.joy, 1, const ['فرح']),
    ..._ring(
      EmotionCategory.joy,
      2,
      const ['تفاؤل', 'حماس', 'أمل', 'طموح', 'إثارة', 'انتشاء', 'قمة'],
    ),
    ..._ring(
      EmotionCategory.joy,
      3,
      const [
        'نشوة',
        'بهجة',
        'سعادة',
        'ابتهاج',
        'نرو',
        'تيم',
        'هيام',
        'مياه',
      ],
    ),
    ..._ring(EmotionCategory.surprise, 1, const ['دهشة']),
    ..._ring(
      EmotionCategory.surprise,
      2,
      const ['استثارة', 'تجاوز', 'تعجب', 'حيرة', 'مباغتة'],
    ),
    ..._ring(
      EmotionCategory.surprise,
      3,
      const [
        'استغراب',
        'وجوم',
        'إنشداه',
        'تحفز',
        'تأثر',
        'إشباع',
        'اكتفاء',
      ],
    ),
    ..._ring(EmotionCategory.disgust, 1, const ['قرف']),
    ..._ring(
      EmotionCategory.disgust,
      2,
      const ['نفور', 'كراهية', 'بغض', 'احتقار', 'سخريية', 'تقزز', 'اشمئزاز'],
    ),
    ..._ring(
      EmotionCategory.disgust,
      3,
      const [
        'مقز',
        'غثيان',
        'فظاظة',
        'بشاعة',
        'نفور شديد',
        'رجض',
        'عنف',
        'وحشية',
        'زهد',
      ],
    ),
    ..._ring(EmotionCategory.anger, 1, const ['غضب']),
    ..._ring(
      EmotionCategory.anger,
      2,
      const ['غيظ', 'سخط', 'حنق', 'استياء', 'عداء', 'تحدّي', 'كره'],
    ),
    ..._ring(
      EmotionCategory.anger,
      3,
      const [
        'ثورة',
        'فورة',
        'غضب شديد',
        'عدوان',
        'حقد',
        'انتقام',
        'استفزاز',
        'عنف',
        'غضب مكبوت',
      ],
    ),
    ..._ring(EmotionCategory.calm, 1, const ['هدوء']),
    ..._ring(
      EmotionCategory.calm,
      2,
      const ['طمأنينة', 'سكينة', 'رزانة', 'اتزان', 'صفاء', 'سكون', 'راحة'],
    ),
    ..._ring(
      EmotionCategory.calm,
      3,
      const [
        'استرخاء',
        'تأمل',
        'خمول',
        'ركود',
        'انفراج',
        'هدوء النفس',
        'سكينة عميقة',
        'فترة',
        'راحة بال',
      ],
    ),
  ];

  static List<EmotionModel> _ring(
    EmotionCategory category,
    int intensity,
    List<String> labels,
  ) =>
      labels.map((label) => _e(category, intensity, label)).toList();

  static List<EmotionModel> forCategory(EmotionCategory category) =>
      catalog.where((e) => e.category == category).toList();

  static String categoryLabel(EmotionCategory category) => switch (category) {
        EmotionCategory.sadness => 'حزن',
        EmotionCategory.fear => 'خوف',
        EmotionCategory.love => 'حب',
        EmotionCategory.joy => 'فرح',
        EmotionCategory.surprise => 'دهشة',
        EmotionCategory.disgust => 'اشمئزاز',
        EmotionCategory.anger => 'غضب',
        EmotionCategory.calm => 'هدوء',
      };

  static String categoryEmoji(EmotionCategory category) => switch (category) {
        EmotionCategory.sadness => '😢',
        EmotionCategory.fear => '😨',
        EmotionCategory.love => '❤️',
        EmotionCategory.joy => '😊',
        EmotionCategory.surprise => '😲',
        EmotionCategory.disgust => '🤢',
        EmotionCategory.anger => '😠',
        EmotionCategory.calm => '😌',
      };

  static const List<EmotionCategory> negativeMoodCategories = [
    EmotionCategory.sadness,
    EmotionCategory.fear,
    EmotionCategory.anger,
    EmotionCategory.disgust,
  ];

  static const List<EmotionCategory> neutralMoodCategories = [
    EmotionCategory.surprise,
    EmotionCategory.calm,
  ];

  static const List<EmotionCategory> positiveMoodCategories = [
    EmotionCategory.love,
    EmotionCategory.joy,
  ];

  static String ringLabel(int intensity) => switch (intensity) {
        1 => 'المشاعر الأساسية',
        2 => 'مشاعر متوسطة',
        3 => 'مشاعر عميقة',
        _ => '',
      };
}
