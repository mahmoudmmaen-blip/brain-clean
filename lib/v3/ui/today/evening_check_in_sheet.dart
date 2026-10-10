import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';
import '../../data/evening_check_in.dart';

Future<void> showEveningCheckInSheet(
  BuildContext context, {
  required String reflection,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppDesignConstants.darkSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => EveningCheckInSheet(reflection: reflection),
  );
}

class EveningCheckInSheet extends ConsumerStatefulWidget {
  const EveningCheckInSheet({super.key, required this.reflection});

  final String reflection;

  @override
  ConsumerState<EveningCheckInSheet> createState() =>
      _EveningCheckInSheetState();
}

class _EveningCheckInSheetState extends ConsumerState<EveningCheckInSheet> {
  int _mood = 3;
  EveningChallengeAnswer _challenge = EveningChallengeAnswer.yes;
  final _note = TextEditingController();

  static const _faces = ['😞', '😐', '🙂', '😊', '😁'];

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    await ref.read(v3StateRepositoryProvider).appendEveningCheckIn(
          EveningCheckIn(
            date: date,
            mood: _mood,
            challenge: _challenge,
            note: _note.text.trim().isEmpty ? null : _note.text.trim(),
          ),
        );
    ref.invalidate(v3AppStateProvider);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              loc.v3EveningMood,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i = 0; i < 5; i++)
                  InkWell(
                    onTap: () => setState(() => _mood = i + 1),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: _mood == i + 1
                          ? AppDesignConstants.brandGreen
                              .withValues(alpha: 0.3)
                          : AppDesignConstants.darkBorder,
                      child: Text(_faces[i], style: const TextStyle(fontSize: 22)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              loc.v3EveningChallengeQ,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(loc.v3EveningYes),
                  selected: _challenge == EveningChallengeAnswer.yes,
                  onSelected: (_) =>
                      setState(() => _challenge = EveningChallengeAnswer.yes),
                ),
                ChoiceChip(
                  label: Text(loc.v3EveningPartly),
                  selected: _challenge == EveningChallengeAnswer.partly,
                  onSelected: (_) => setState(
                    () => _challenge = EveningChallengeAnswer.partly,
                  ),
                ),
                ChoiceChip(
                  label: Text(loc.v3EveningNo),
                  selected: _challenge == EveningChallengeAnswer.no,
                  onSelected: (_) =>
                      setState(() => _challenge = EveningChallengeAnswer.no),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(widget.reflection),
            const SizedBox(height: 8),
            TextField(
              controller: _note,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: loc.v3EveningNoteHint,
                filled: true,
                fillColor: AppDesignConstants.darkBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              key: const Key('v3_evening_save'),
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppDesignConstants.brandGreen,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(loc.v3EveningSave),
            ),
          ],
        ),
      ),
    );
  }
}
