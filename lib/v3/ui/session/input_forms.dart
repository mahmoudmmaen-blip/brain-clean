import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';
import '../../data/user_inputs.dart';

/// Renders and saves practice `input` forms from spec §5.3.
class PracticeInputForm extends ConsumerStatefulWidget {
  const PracticeInputForm({
    super.key,
    required this.inputKey,
    required this.onSaved,
  });

  final String inputKey;
  final VoidCallback onSaved;

  @override
  ConsumerState<PracticeInputForm> createState() => _PracticeInputFormState();
}

class _PracticeInputFormState extends ConsumerState<PracticeInputForm> {
  final _text = TextEditingController();
  final _app1 = TextEditingController();
  final _app2 = TextEditingController();
  final _app3 = TextEditingController();
  final _hours = TextEditingController();
  final _pickups = TextEditingController();
  final _r5 = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _r15 = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _r60 = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final _ifThen = List.generate(
    3,
    (_) => (TextEditingController(), TextEditingController()),
  );
  final _rules = List.generate(3, (_) => TextEditingController());
  final _week = List.generate(3, (_) => TextEditingController());
  final _selectedTriggers = <String>{};
  double _urgeBefore = 5;
  double _urgeAfter = 3;
  TimeOfDay _time = const TimeOfDay(hour: 22, minute: 0);

  static const _triggerOptions = [
    'bored',
    'stressed',
    'lonely',
    'tired',
    'curious',
  ];

  @override
  void dispose() {
    _text.dispose();
    _app1.dispose();
    _app2.dispose();
    _app3.dispose();
    _hours.dispose();
    _pickups.dispose();
    for (final c in [..._r5, ..._r15, ..._r60, ..._rules, ..._week]) {
      c.dispose();
    }
    for (final p in _ifThen) {
      p.$1.dispose();
      p.$2.dispose();
    }
    super.dispose();
  }

  Future<void> _save(UserInputs Function(UserInputs) update) async {
    final repo = ref.read(v3StateRepositoryProvider);
    final current = (await repo.load()).userInputs;
    await repo.saveUserInputs(update(current));
    ref.invalidate(v3AppStateProvider);
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ..._fields(loc),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _onSave,
          style: FilledButton.styleFrom(
            backgroundColor: AppDesignConstants.brandGreen,
            minimumSize: const Size.fromHeight(48),
          ),
          child: Text(loc.v3InputSave),
        ),
      ],
    );
  }

  List<Widget> _fields(AppLocalizations loc) {
    switch (widget.inputKey) {
      case 'screen_audit':
        return [
          _field(_hours, loc.v3InputHours),
          _field(_app1, loc.v3InputApp(1)),
          _field(_app2, loc.v3InputApp(2)),
          _field(_app3, loc.v3InputApp(3)),
          _field(_pickups, loc.v3InputPickups, number: true),
        ];
      case 'trigger_pick':
        return [
          Wrap(
            spacing: 8,
            children: _triggerOptions.map((t) {
              final selected = _selectedTriggers.contains(t);
              return FilterChip(
                label: Text(t),
                selected: selected,
                onSelected: (v) => setState(() {
                  if (v) {
                    if (_selectedTriggers.length < 5) {
                      _selectedTriggers.add(t);
                    }
                  } else {
                    _selectedTriggers.remove(t);
                  }
                }),
              );
            }).toList(),
          ),
        ];
      case 'urge_rating_before_after':
        return [
          Text(loc.v3InputUrgeBefore),
          Slider(
            value: _urgeBefore,
            min: 1,
            max: 10,
            divisions: 9,
            label: _urgeBefore.round().toString(),
            onChanged: (v) => setState(() => _urgeBefore = v),
          ),
          Text(loc.v3InputUrgeAfter),
          Slider(
            value: _urgeAfter,
            min: 1,
            max: 10,
            divisions: 9,
            label: _urgeAfter.round().toString(),
            onChanged: (v) => setState(() => _urgeAfter = v),
          ),
        ];
      case 'time_pick':
        return [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(loc.v3InputPickTime),
            subtitle: Text(_time.format(context)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final picked = await showTimePicker(
                context: context,
                initialTime: _time,
              );
              if (picked != null) setState(() => _time = picked);
            },
          ),
        ];
      case 'why_statement':
      case 'relapse_plan':
      case 'identity_statement':
      case 'future_letter':
        return [
          TextField(
            controller: _text,
            maxLines: widget.inputKey == 'future_letter' ? 6 : 3,
            decoration: InputDecoration(
              labelText: loc.v3InputText,
              filled: true,
              fillColor: AppDesignConstants.darkSurface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ];
      case 'replacement_list':
        return [
          Text(loc.v3InputReplacements5),
          ..._r5.map((c) => _field(c, null)),
          Text(loc.v3InputReplacements15),
          ..._r15.map((c) => _field(c, null)),
          Text(loc.v3InputReplacements60),
          ..._r60.map((c) => _field(c, null)),
        ];
      case 'if_then':
        return [
          for (var i = 0; i < 3; i++) ...[
            _field(_ifThen[i].$1, loc.v3InputIf),
            _field(_ifThen[i].$2, loc.v3InputThen),
          ],
        ];
      case 'maintenance_rules':
        return [
          for (var i = 0; i < 3; i++)
            _field(_rules[i], loc.v3InputRule(i + 1)),
        ];
      case 'week_review':
        return [
          for (var i = 0; i < 3; i++)
            _field(_week[i], loc.v3InputWeekNote(i + 1)),
        ];
      default:
        return [Text(loc.v3InputUnsupported)];
    }
  }

  Widget _field(
    TextEditingController c,
    String? label, {
    bool number = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: AppDesignConstants.darkSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Future<void> _onSave() async {
    switch (widget.inputKey) {
      case 'screen_audit':
        await _save(
          (u) => u.copyWith(
            screenAudit: ScreenAuditInput(
              hours: double.tryParse(_hours.text),
              apps: [
                _app1.text,
                _app2.text,
                _app3.text,
              ].where((e) => e.trim().isNotEmpty).toList(),
              pickups: int.tryParse(_pickups.text),
            ),
          ),
        );
      case 'trigger_pick':
        await _save((u) => u.copyWith(triggers: _selectedTriggers.toList()));
      case 'urge_rating_before_after':
        widget.onSaved();
      case 'time_pick':
        widget.onSaved();
      case 'why_statement':
        await _save((u) => u.copyWith(whyStatement: _text.text.trim()));
      case 'relapse_plan':
        await _save((u) => u.copyWith(relapsePlan: _text.text.trim()));
      case 'identity_statement':
        await _save((u) => u.copyWith(identity: _text.text.trim()));
      case 'future_letter':
        await _save((u) => u.copyWith(futureLetter: _text.text.trim()));
      case 'replacement_list':
        await _save(
          (u) => u.copyWith(
            replacements: ReplacementLists(
              minutes5: _r5.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
              minutes15: _r15.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
              minutes60: _r60.map((c) => c.text.trim()).where((e) => e.isNotEmpty).toList(),
            ),
          ),
        );
      case 'if_then':
        await _save(
          (u) => u.copyWith(
            ifThen: _ifThen
                .map(
                  (p) => IfThenPair(
                    ifText: p.$1.text.trim(),
                    thenText: p.$2.text.trim(),
                  ),
                )
                .where((p) => p.ifText.isNotEmpty || p.thenText.isNotEmpty)
                .toList(),
          ),
        );
      case 'maintenance_rules':
        await _save(
          (u) => u.copyWith(
            rules: _rules
                .map((c) => c.text.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          ),
        );
      case 'week_review':
        widget.onSaved();
      default:
        widget.onSaved();
    }
  }
}
