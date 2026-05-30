import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import 'ambient_sound_player.dart';
import 'application/single_task_provider.dart';
import 'domain/task_category.dart';
import 'widgets/ambient_sound_widgets.dart';

const singleTaskInputKey = Key('single_task_input');
const singleTaskStartKey = Key('single_task_start');
const singleTaskCategoryChipsKey = Key('single_task_category_chips');
const singleTaskDifficultyKey = Key('single_task_difficulty');

/// Single-tasking focus mode with navigation lock while active.
class SingleTaskScreen extends ConsumerStatefulWidget {
  const SingleTaskScreen({super.key});

  @override
  ConsumerState<SingleTaskScreen> createState() => _SingleTaskScreenState();
}

class _SingleTaskScreenState extends ConsumerState<SingleTaskScreen> {
  static const _bg = Color(0xFF0D1117);
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(ambientSoundControllerProvider.notifier)
          .play(AmbientSound.rain);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _confirmAbandon() async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        title: Text(
          loc.singleTaskPauseTitle,
          style: const TextStyle(color: Color(0xFFE6EDF3)),
        ),
        content: Text(
          loc.singleTaskPauseBody,
          style: const TextStyle(color: Color(0xFF8B949E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              loc.commonCancel,
              style: const TextStyle(color: Color(0xFF8B949E)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      final abandoned =
          ref.read(singleTaskControllerProvider.notifier).abandonTask();
      if (abandoned) {
        final isAr = ref.read(localeProvider).languageCode == 'ar';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isAr
                  ? 'المهمة غير المكتملة تضعف التركيز قليلاً'
                  : loc.singleTaskAbandonSnack,
            ),
            backgroundColor: const Color(0xFFDA3633),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final isAr = ref.read(localeProvider).languageCode == 'ar';
    final taskState = ref.watch(singleTaskControllerProvider);
    final notifier = ref.read(singleTaskControllerProvider.notifier);

    return PopScope(
      canPop: !taskState.isLocked,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          automaticallyImplyLeading: !taskState.isLocked,
          title: Text(
            loc.singleTaskModeTitle,
            style: const TextStyle(color: Color(0xFFE6EDF3)),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF8B949E)),
          actions: const [AmbientSoundToggleButton()],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: taskState.isLocked
                ? _ActiveTaskView(
                    label: taskState.activeTaskLabel!,
                    loc: loc,
                    onComplete: () {
                      final bonus = taskState.estimatedBonus;
                      ref
                          .read(singleTaskControllerProvider.notifier)
                          .completeTask();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isAr
                                ? 'أحسنت! +${bonus.toStringAsFixed(0)} نقاط تركيز'
                                : loc.singleTaskFocusRewardSnackBonus(
                                    bonus.toStringAsFixed(0),
                                  ),
                          ),
                          backgroundColor: const Color(0xFF1D9E75),
                        ),
                      );
                    },
                    onAbandon: _confirmAbandon,
                  )
                : _IdleTaskView(
                    controller: _controller,
                    loc: loc,
                    isAr: isAr,
                    category: taskState.category,
                    difficulty: taskState.difficultyStars,
                    estimatedBonus: taskState.estimatedBonus,
                    onCategory: notifier.setCategory,
                    onDifficulty: notifier.setDifficulty,
                    onStart: () {
                      notifier.startTask(_controller.text);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

String _categoryLabel(TaskCategory category, AppLocalizations loc, bool isAr) {
  if (isAr) {
    switch (category) {
      case TaskCategory.mental:
        return '🧠 ذهني';
      case TaskCategory.physical:
        return '💪 بدني';
      case TaskCategory.creative:
        return '🎨 إبداعي';
      case TaskCategory.educational:
        return '📚 تعليمي';
      case TaskCategory.household:
        return '🏠 منزلي';
    }
  }
  switch (category) {
    case TaskCategory.mental:
      return loc.taskCategoryMental;
    case TaskCategory.physical:
      return loc.taskCategoryPhysical;
    case TaskCategory.creative:
      return loc.taskCategoryCreative;
    case TaskCategory.educational:
      return loc.taskCategoryEducational;
    case TaskCategory.household:
      return loc.taskCategoryHousehold;
  }
}

class _IdleTaskView extends StatelessWidget {
  const _IdleTaskView({
    required this.controller,
    required this.loc,
    required this.isAr,
    required this.category,
    required this.difficulty,
    required this.estimatedBonus,
    required this.onCategory,
    required this.onDifficulty,
    required this.onStart,
  });

  final TextEditingController controller;
  final AppLocalizations loc;
  final bool isAr;
  final TaskCategory category;
  final int difficulty;
  final double estimatedBonus;
  final void Function(TaskCategory) onCategory;
  final void Function(int) onDifficulty;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          loc.singleTaskModeTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE6EDF3),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          key: singleTaskCategoryChipsKey,
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: TaskCategory.values.map((cat) {
              final selected = cat == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_categoryLabel(cat, loc, isAr)),
                  selected: selected,
                  selectedColor: const Color(0xFF1D9E75),
                  backgroundColor: const Color(0xFF161B22),
                  labelStyle: TextStyle(
                    color: selected
                        ? Colors.white
                        : const Color(0xFF8B949E),
                  ),
                  onSelected: (_) => onCategory(cat),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          key: singleTaskDifficultyKey,
          children: List.generate(3, (index) {
            final stars = index + 1;
            final selected = stars <= difficulty;
            return IconButton(
              onPressed: () => onDifficulty(stars),
              icon: Icon(
                selected ? Icons.star : Icons.star_border,
                color: selected
                    ? const Color(0xFFFFB800)
                    : const Color(0xFF8B949E),
              ),
            );
          }),
        ),
        Text(
          isAr
              ? 'إنجاز هذه المهمة سيضيف +${estimatedBonus.toStringAsFixed(0)} نقطة'
              : loc.singleTaskEstimatedBonus(estimatedBonus.toStringAsFixed(0)),
          style: const TextStyle(color: Color(0xFF1D9E75), fontSize: 14),
        ),
        const SizedBox(height: 16),
        TextField(
          key: singleTaskInputKey,
          controller: controller,
          style: const TextStyle(color: Color(0xFFE6EDF3)),
          decoration: InputDecoration(
            hintText: loc.singleTaskHint,
            hintStyle: const TextStyle(color: Color(0xFF8B949E)),
            filled: true,
            fillColor: const Color(0xFF161B22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 24),
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF1D9E75), Color(0xFF0F7A5A)],
            ),
          ),
          child: ElevatedButton(
            key: singleTaskStartKey,
            onPressed: onStart,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(loc.singleTaskStartFocus),
          ),
        ),
      ],
    );
  }
}

class _ActiveTaskView extends StatefulWidget {
  const _ActiveTaskView({
    required this.label,
    required this.loc,
    required this.onComplete,
    required this.onAbandon,
  });

  final String label;
  final AppLocalizations loc;
  final VoidCallback onComplete;
  final VoidCallback onAbandon;

  @override
  State<_ActiveTaskView> createState() => _ActiveTaskViewState();
}

class _ActiveTaskViewState extends State<_ActiveTaskView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE6EDF3),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FadeTransition(
              opacity: Tween(begin: 0.4, end: 1.0).animate(_pulse),
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF1D9E75),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.loc.singleTaskFocusing,
              style: const TextStyle(color: Color(0xFF1D9E75), fontSize: 16),
            ),
          ],
        ),
        const Spacer(),
        FilledButton(
          onPressed: widget.onComplete,
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF1D9E75),
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(widget.loc.singleTaskCompleted),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: widget.onAbandon,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF8B949E),
            side: const BorderSide(color: Color(0xFF8B949E)),
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(widget.loc.singleTaskPauseButton),
        ),
      ],
    );
  }
}
