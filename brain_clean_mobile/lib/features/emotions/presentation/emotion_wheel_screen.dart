import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/emotion_provider.dart';
import '../domain/emotion_model.dart';

const emotionMoodNegativeKey = Key('emotion_mood_negative');
const emotionMoodNeutralKey = Key('emotion_mood_neutral');
const emotionMoodPositiveKey = Key('emotion_mood_positive');

Key emotionCategoryChipKey(EmotionCategory category) =>
    Key('emotion_category_${category.name}');

/// Three-step smart emotion picker with confirmation dialog.
class EmotionWheelScreen extends ConsumerWidget {
  const EmotionWheelScreen({super.key});

  static const _bg = Color(0xFF0D1117);
  static const _card = Color(0xFF161B22);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emotionState = ref.watch(emotionNotifierProvider);

    ref.listen(emotionNotifierProvider, (prev, next) {
      if (next.isAwaitingConfirmation &&
          next.selectedEmotion != null &&
          (prev?.isAwaitingConfirmation != true)) {
        _showConfirmationDialog(context, ref, next);
      }
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        title: const Text(
          'عجلة المشاعر',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (emotionState.moodGate == null)
            _MoodGateStep(
              onNegative: () => ref
                  .read(emotionNotifierProvider.notifier)
                  .selectMoodGate(EmotionMoodGate.negative),
              onNeutral: () => ref
                  .read(emotionNotifierProvider.notifier)
                  .selectMoodGate(EmotionMoodGate.neutral),
              onPositive: () => ref
                  .read(emotionNotifierProvider.notifier)
                  .selectMoodGate(EmotionMoodGate.positive),
            )
          else ...[
            if (emotionState.selectedCategory == null)
              _CategoryStep(
                categories: ref.watch(filteredEmotionCategoriesProvider),
                onSelect: (cat) => ref
                    .read(emotionNotifierProvider.notifier)
                    .selectCategory(cat),
                onBack: () =>
                    ref.read(emotionNotifierProvider.notifier).resetMoodGate(),
              )
            else
              _EmotionGridStep(
                category: emotionState.selectedCategory!,
                onSelect: (e) => ref
                    .read(emotionNotifierProvider.notifier)
                    .selectEmotion(e),
                onBack: () => ref
                    .read(emotionNotifierProvider.notifier)
                    .backToCategories(),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    EmotionState state,
  ) async {
    final emotion = state.selectedEmotion!;
    final impact = state.pendingImpact;
    final pct = (impact.abs() * 100).toStringAsFixed(0);
    final body = impact < 0
        ? 'الشعور بـ ${emotion.label} سيقلل نسبة تعافيك بمقدار $pct%\nهل تريد تسجيله؟'
        : 'الشعور بـ ${emotion.label} سيحسّن نسبة تعافيك بمقدار $pct%\nهل تريد تسجيله؟';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _card,
        title: const Text(
          'تأثير هذا الشعور على تعافيك',
          style: TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: Text(
          body,
          style: const TextStyle(color: Color(0xFF8B949E), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'لا، تجاهل',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: impact < 0
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF1D9E75),
            ),
            child: const Text('نعم، سجّل'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(emotionNotifierProvider.notifier).confirmImpact();
    } else {
      ref.read(emotionNotifierProvider.notifier).rejectImpact();
    }
  }
}

class _MoodGateStep extends StatelessWidget {
  const _MoodGateStep({
    required this.onNegative,
    required this.onNeutral,
    required this.onPositive,
  });

  final VoidCallback onNegative;
  final VoidCallback onNeutral;
  final VoidCallback onPositive;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MoodCard(
          key: emotionMoodNegativeKey,
          label: 'أشعر بشيء سلبي',
          icon: Icons.sentiment_dissatisfied,
          color: const Color(0xFFEF4444),
          onTap: onNegative,
        ),
        const SizedBox(height: 12),
        _MoodCard(
          key: emotionMoodNeutralKey,
          label: 'أشعر بشيء محايد',
          icon: Icons.sentiment_neutral,
          color: const Color(0xFFF59E0B),
          onTap: onNeutral,
        ),
        const SizedBox(height: 12),
        _MoodCard(
          key: emotionMoodPositiveKey,
          label: 'أشعر بشيء إيجابي',
          icon: Icons.sentiment_satisfied,
          color: const Color(0xFF1D9E75),
          onTap: onPositive,
        ),
      ],
    );
  }
}

class _MoodCard extends StatelessWidget {
  const _MoodCard({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF161B22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          height: 72,
          child: Row(
            children: [
              const SizedBox(width: 20),
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryStep extends StatelessWidget {
  const _CategoryStep({
    required this.categories,
    required this.onSelect,
    required this.onBack,
  });

  final List<EmotionCategory> categories;
  final ValueChanged<EmotionCategory> onSelect;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B949E)),
            label: const Text(
              'رجوع',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return ActionChip(
                key: emotionCategoryChipKey(cat),
                label: Text(
                  '${EmotionModel.categoryEmoji(cat)} ${EmotionModel.categoryLabel(cat)}',
                ),
                backgroundColor: const Color(0xFF161B22),
                labelStyle: const TextStyle(color: Color(0xFFE6EDF3)),
                side: const BorderSide(color: Color(0xFF30363D)),
                onPressed: () => onSelect(cat),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EmotionGridStep extends StatelessWidget {
  const _EmotionGridStep({
    required this.category,
    required this.onSelect,
    required this.onBack,
  });

  final EmotionCategory category;
  final ValueChanged<EmotionModel> onSelect;
  final VoidCallback onBack;

  Color _borderColor(int intensity) => switch (intensity) {
        1 => const Color(0xFF1D9E75),
        2 => const Color(0xFFF59E0B),
        3 => const Color(0xFFEF4444),
        _ => const Color(0xFF30363D),
      };

  @override
  Widget build(BuildContext context) {
    final emotions = EmotionModel.forCategory(category);
    final rings = [1, 2, 3];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF8B949E)),
            label: const Text(
              'رجوع',
              style: TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
        ),
        for (final ring in rings) ...[
          const SizedBox(height: 16),
          Text(
            EmotionModel.ringLabel(ring),
            style: const TextStyle(
              color: Color(0xFF8B949E),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: emotions
                .where((e) => e.intensity == ring)
                .map(
                  (e) => ActionChip(
                    label: Text(e.label),
                    backgroundColor: const Color(0xFF161B22),
                    labelStyle: const TextStyle(color: Color(0xFFE6EDF3)),
                    side: BorderSide(color: _borderColor(ring)),
                    onPressed: () => onSelect(e),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
