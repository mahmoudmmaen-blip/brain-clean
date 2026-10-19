import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';
import '../../application/v3_state_providers.dart';

/// Read-only future letter; optional name prompt when profile name is empty.
class V3LetterScreen extends ConsumerStatefulWidget {
  const V3LetterScreen({super.key});

  @override
  ConsumerState<V3LetterScreen> createState() => _V3LetterScreenState();
}

class _V3LetterScreenState extends ConsumerState<V3LetterScreen> {
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final text = _name.text.trim();
    if (text.isEmpty) return;
    final app = await ref.read(v3StateRepositoryProvider).load();
    final profile = app.profile;
    if (profile == null) return;
    await ref.read(v3StateRepositoryProvider).saveProfile(
          profile.copyWith(name: text),
        );
    ref.invalidate(v3AppStateProvider);
    _name.clear();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final appAsync = ref.watch(v3AppStateProvider);

    return Scaffold(
      key: const Key('v3_letter'),
      backgroundColor: AppDesignConstants.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(loc.v3LetterTitle),
      ),
      body: appAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (app) {
          final letter = app.userInputs.futureLetter?.trim() ?? '';
          final name = app.profile?.name?.trim() ?? '';
          final needName = name.isEmpty;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(AppDesignConstants.paddingScreen),
              children: [
                if (needName) ...[
                  Text(
                    loc.v3LetterNamePrompt,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('v3_letter_name_field'),
                    controller: _name,
                    decoration: InputDecoration(
                      hintText: loc.v3SettingsNameHint,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FilledButton(
                      key: const Key('v3_letter_name_save'),
                      onPressed: _saveName,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppDesignConstants.brandGreen,
                      ),
                      child: Text(loc.v3LetterNameSave),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (letter.isEmpty)
                  Text(
                    loc.v3LetterEmpty,
                    key: const Key('v3_letter_empty'),
                    style: const TextStyle(
                      color: AppDesignConstants.darkOnSurfaceMuted,
                      height: 1.5,
                    ),
                  )
                else
                  Text(
                    letter,
                    key: const Key('v3_letter_body'),
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.65,
                      color: AppDesignConstants.darkOnSurface,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
