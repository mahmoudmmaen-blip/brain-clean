import 'bri_axis.dart';
import 'bri_question.dart';

/// Free BRI bank — 16 questions (4 per axis). Retake cooldown: 7 days.
abstract final class BriQuestionBank {
  static const questionCount = 16;
  static const cooldownDays = 7;

  static const questions = <BriQuestion>[
    // —— Short-form / reels addiction ——
    BriQuestion(
      id: 'bri_sf_1',
      stemKey: 'briQShortForm1',
      axis: BriAxis.shortFormAddiction,
      order: 0,
    ),
    BriQuestion(
      id: 'bri_sf_2',
      stemKey: 'briQShortForm2',
      axis: BriAxis.shortFormAddiction,
      order: 1,
    ),
    BriQuestion(
      id: 'bri_sf_3',
      stemKey: 'briQShortForm3',
      axis: BriAxis.shortFormAddiction,
      order: 2,
    ),
    BriQuestion(
      id: 'bri_sf_4',
      stemKey: 'briQShortForm4',
      axis: BriAxis.shortFormAddiction,
      order: 3,
      higherMeansWorse: false,
    ),
    // —— Attention scatter ——
    BriQuestion(
      id: 'bri_at_1',
      stemKey: 'briQAttention1',
      axis: BriAxis.attentionScatter,
      order: 4,
    ),
    BriQuestion(
      id: 'bri_at_2',
      stemKey: 'briQAttention2',
      axis: BriAxis.attentionScatter,
      order: 5,
    ),
    BriQuestion(
      id: 'bri_at_3',
      stemKey: 'briQAttention3',
      axis: BriAxis.attentionScatter,
      order: 6,
    ),
    BriQuestion(
      id: 'bri_at_4',
      stemKey: 'briQAttention4',
      axis: BriAxis.attentionScatter,
      order: 7,
      higherMeansWorse: false,
    ),
    // —— Information fatigue ——
    BriQuestion(
      id: 'bri_if_1',
      stemKey: 'briQInfoFatigue1',
      axis: BriAxis.infoFatigue,
      order: 8,
    ),
    BriQuestion(
      id: 'bri_if_2',
      stemKey: 'briQInfoFatigue2',
      axis: BriAxis.infoFatigue,
      order: 9,
    ),
    BriQuestion(
      id: 'bri_if_3',
      stemKey: 'briQInfoFatigue3',
      axis: BriAxis.infoFatigue,
      order: 10,
    ),
    BriQuestion(
      id: 'bri_if_4',
      stemKey: 'briQInfoFatigue4',
      axis: BriAxis.infoFatigue,
      order: 11,
      higherMeansWorse: false,
    ),
    // —— Boredom resistance ——
    BriQuestion(
      id: 'bri_br_1',
      stemKey: 'briQBoredom1',
      axis: BriAxis.boredomResistance,
      order: 12,
    ),
    BriQuestion(
      id: 'bri_br_2',
      stemKey: 'briQBoredom2',
      axis: BriAxis.boredomResistance,
      order: 13,
    ),
    BriQuestion(
      id: 'bri_br_3',
      stemKey: 'briQBoredom3',
      axis: BriAxis.boredomResistance,
      order: 14,
    ),
    BriQuestion(
      id: 'bri_br_4',
      stemKey: 'briQBoredom4',
      axis: BriAxis.boredomResistance,
      order: 15,
      higherMeansWorse: false,
    ),
  ];
}
