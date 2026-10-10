import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';
import '../../data/user_profile.dart';
import '../../routing/v3_routes.dart';
import 'onboarding_keys.dart';

class V3SetupScreen extends ConsumerStatefulWidget {
  const V3SetupScreen({super.key});

  @override
  ConsumerState<V3SetupScreen> createState() => _V3SetupScreenState();
}

class _V3SetupScreenState extends ConsumerState<V3SetupScreen> {
  final _nameController = TextEditingController();
  String _goal = 'focus';
  TimeOfDay _reminder = const TimeOfDay(hour: 20, minute: 0);

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminder,
    );
    if (picked != null) setState(() => _reminder = picked);
  }

  Future<void> _submit() async {
    final locale = ref.read(localeProvider).languageCode;
    final profile = UserProfile(
      name: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
      goal: _goal,
      reminderTime:
          '${_reminder.hour.toString().padLeft(2, '0')}:${_reminder.minute.toString().padLeft(2, '0')}',
      eveningCheckIn: true,
      onboardingDone: false,
      createdAt: DateTime.now(),
      locale: locale,
    );
    await ref.read(v3StateRepositoryProvider).saveProfile(profile);
    if (mounted) context.go(V3Routes.result);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(loc.v3SetupTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: loc.v3SetupNameHint,
                  filled: true,
                  fillColor: AppDesignConstants.darkSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                loc.v3SetupGoalTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppDesignConstants.darkOnSurface,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _GoalChip(
                    label: loc.v3GoalFocus,
                    selected: _goal == 'focus',
                    onTap: () => setState(() => _goal = 'focus'),
                  ),
                  _GoalChip(
                    label: loc.v3GoalSleep,
                    selected: _goal == 'sleep',
                    onTap: () => setState(() => _goal = 'sleep'),
                  ),
                  _GoalChip(
                    label: loc.v3GoalBrowse,
                    selected: _goal == 'browse',
                    onTap: () => setState(() => _goal = 'browse'),
                  ),
                  _GoalChip(
                    label: loc.v3GoalCalm,
                    selected: _goal == 'calm',
                    onTap: () => setState(() => _goal = 'calm'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(loc.v3SetupReminder),
                subtitle: Text(_reminder.format(context)),
                trailing: const Icon(Icons.schedule_rounded),
                onTap: _pickTime,
              ),
              const SizedBox(height: 32),
              FilledButton(
                key: V3OnboardingKeys.setupSubmit,
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppDesignConstants.brandGreen,
                  minimumSize: const Size.fromHeight(52),
                ),
                child: Text(loc.v3SetupSubmit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppDesignConstants.brandGreen.withValues(alpha: 0.25),
      checkmarkColor: AppDesignConstants.brandGreen,
    );
  }
}
