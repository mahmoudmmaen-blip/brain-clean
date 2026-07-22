import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:uuid/uuid.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../recovery/domain/recovery_daily_program_sync.dart';
import '../../recovery/presentation/recovery_protocol_controller.dart';
import '../application/worry_journal_daily_program_gate.dart';
import '../data/worry_repository_provider.dart';
import '../domain/worry_entry.dart';
import 'worry_today_entries_provider.dart';
import 'widgets/worry_journal_widget.dart';

class WorryJournalScreen extends ConsumerStatefulWidget {
  const WorryJournalScreen({super.key});

  @override
  ConsumerState<WorryJournalScreen> createState() => _WorryJournalScreenState();
}

class _WorryJournalScreenState extends ConsumerState<WorryJournalScreen> {
  static const _uuid = Uuid();
  final _contentController = TextEditingController();
  bool _pastExpanded = true;

  /// Clears the Daily Program journal gate after the current frame/build.
  void _disarmDailyProgramGateSafely() {
    final gate = ref.read(worryJournalDailyProgramGateProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      gate.disarm();
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    final entry = WorryEntry(
      id: _uuid.v4(),
      content: content,
      createdAt: DateTime.now().toUtc(),
    );
    await ref.read(worryRepositoryProvider).saveEntry(entry);
    await ref
        .read(recoveryProtocolControllerProvider.notifier)
        .applyEngagementAutoMark(RecoveryEngagementAutoMark.mentalSupport);
    ref.invalidate(worryTodayEntriesProvider);
    ref.invalidate(worryHabitDoneTodayProvider);

    _contentController.clear();
    await ref
        .read(worryJournalDailyProgramGateProvider.notifier)
        .completeJournalStepIfArmed();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.worrySavedSnackbar)),
    );
  }

  String _preview(String text) {
    if (text.length <= 60) return text;
    return '${text.substring(0, 60)}…';
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final todayAsync = ref.watch(worryTodayEntriesProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _disarmDailyProgramGateSafely();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(loc.worryJournalTitle),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        onPressed: _saveEntry,
        child: Text(
          loc.worrySaveFab,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 88),
        children: [
          GlassCard(
            child: Text(
              loc.worrySafaPrompt,
              textAlign: TextAlign.center,
              style: AppDesignConstants.arabicText(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                height: AppDesignConstants.arabicBodyLineHeight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          WorryJournalWidget(
            controller: _contentController,
            hintText: loc.worryJournalHint,
            minLines: 8,
            maxLines: 20,
          ),
          const SizedBox(height: 20),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _pastExpanded = !_pastExpanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      loc.worryPastEntriesTitle,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _pastExpanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_pastExpanded)
            todayAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Text(
                loc.worryLoadError,
                style: TextStyle(color: colorScheme.error),
              ),
              data: (entries) {
                if (entries.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      loc.worryNoEntriesToday,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return Column(
                  children: entries.map((entry) {
                    final time = DateFormat.Hm().format(entry.createdAt.toLocal());
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _PastEntryCard(
                        time: time,
                        preview: _preview(entry.content),
                        fullText: entry.content,
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    ),
    );
  }
}

class _PastEntryCard extends StatefulWidget {
  const _PastEntryCard({
    required this.time,
    required this.preview,
    required this.fullText,
  });

  final String time;
  final String preview;
  final String fullText;

  @override
  State<_PastEntryCard> createState() => _PastEntryCardState();
}

class _PastEntryCardState extends State<_PastEntryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.time,
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _expanded ? widget.fullText : widget.preview,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.right,
              style: AppDesignConstants.arabicText(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
