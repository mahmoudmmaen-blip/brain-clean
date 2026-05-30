import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import 'ambient_sound_player.dart';
import 'widgets/ambient_sound_widgets.dart';
import 'application/single_task_provider.dart';

const singleTaskInputKey = Key('single_task_input');
const singleTaskStartKey = Key('single_task_start');

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
    if (confirmed == true) {
      ref.read(singleTaskControllerProvider.notifier).abandonTask();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final taskState = ref.watch(singleTaskControllerProvider);

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
                      ref
                          .read(singleTaskControllerProvider.notifier)
                          .completeTask();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(loc.singleTaskFocusRewardSnack),
                          backgroundColor: const Color(0xFF1D9E75),
                        ),
                      );
                    },
                    onAbandon: _confirmAbandon,
                  )
                : _IdleTaskView(
                    controller: _controller,
                    loc: loc,
                    onStart: () {
                      ref
                          .read(singleTaskControllerProvider.notifier)
                          .startTask(_controller.text);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}

class _IdleTaskView extends StatelessWidget {
  const _IdleTaskView({
    required this.controller,
    required this.loc,
    required this.onStart,
  });

  final TextEditingController controller;
  final AppLocalizations loc;
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
        const SizedBox(height: 24),
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
