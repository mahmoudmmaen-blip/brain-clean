import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../diagnostic/presentation/bc_score_provider.dart';

const accountabilityModalKey = Key('accountability_box_modal');

Future<void> showAccountabilityBoxModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const AccountabilityBoxModal(),
  );
}

class AccountabilityBoxModal extends StatelessWidget {
  const AccountabilityBoxModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: accountabilityModalKey,
      initialChildSize: 0.62,
      maxChildSize: 0.93,
      minChildSize: 0.40,
      builder: (context, scrollController) {
        return _AccountabilityBoxBody(scrollController: scrollController);
      },
    );
  }
}

enum _AccountabilityCategory {
  physical,
  nutritional,
  altruistic,
  mental,
}

String _categoryLabel(AppLocalizations loc, _AccountabilityCategory cat) =>
    switch (cat) {
      _AccountabilityCategory.physical => loc.accountabilityModalCatPhysical,
      _AccountabilityCategory.nutritional =>
        loc.accountabilityModalCatNutritional,
      _AccountabilityCategory.altruistic => loc.accountabilityModalCatAltruistic,
      _AccountabilityCategory.mental => loc.accountabilityModalCatMental,
    };

IconData _categoryIcon(_AccountabilityCategory cat) => switch (cat) {
      _AccountabilityCategory.physical => Icons.fitness_center,
      _AccountabilityCategory.nutritional => Icons.restaurant,
      _AccountabilityCategory.altruistic => Icons.volunteer_activism,
      _AccountabilityCategory.mental => Icons.psychology,
    };

List<String> _categoryPenalties(
  AppLocalizations loc,
  _AccountabilityCategory cat,
) =>
    switch (cat) {
      _AccountabilityCategory.physical => [
          loc.accountabilityModalPenPhysical1,
          loc.accountabilityModalPenPhysical2,
          loc.accountabilityModalPenPhysical3,
          loc.accountabilityModalPenPhysical4,
          loc.accountabilityModalPenPhysical5,
        ],
      _AccountabilityCategory.nutritional => [
          loc.accountabilityModalPenNutritional1,
          loc.accountabilityModalPenNutritional2,
          loc.accountabilityModalPenNutritional3,
          loc.accountabilityModalPenNutritional4,
          loc.accountabilityModalPenNutritional5,
        ],
      _AccountabilityCategory.altruistic => [
          loc.accountabilityModalPenAltruistic1,
          loc.accountabilityModalPenAltruistic2,
          loc.accountabilityModalPenAltruistic3,
          loc.accountabilityModalPenAltruistic4,
          loc.accountabilityModalPenAltruistic5,
        ],
      _AccountabilityCategory.mental => [
          loc.accountabilityModalPenMental1,
          loc.accountabilityModalPenMental2,
          loc.accountabilityModalPenMental3,
          loc.accountabilityModalPenMental4,
          loc.accountabilityModalPenMental5,
        ],
    };

class _AccountabilityBoxBody extends ConsumerStatefulWidget {
  const _AccountabilityBoxBody({required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<_AccountabilityBoxBody> createState() =>
      _AccountabilityBoxBodyState();
}

class _AccountabilityBoxBodyState extends ConsumerState<_AccountabilityBoxBody> {
  _AccountabilityCategory? _expanded;
  int? _selectedOptionIndex;

  static const _bg = Color(0xFF0D1117);
  static const _handle = Color(0xFF30363D);

  Future<void> _selectPenalty(String label) async {
    ref.read(bcScoreProvider.notifier).applyPenalty(15);
    if (!mounted) return;
    final loc = AppLocalizations.of(context)!;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.accountabilityPenaltyRecorded),
        backgroundColor: const Color(0xFF1D9E75),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _handle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loc.accountabilityRoomTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE6EDF3),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.35,
                    children: _AccountabilityCategory.values.map((cat) {
                      final selected = _expanded == cat;
                      return Material(
                        color: const Color(0xFF161B22),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            setState(() {
                              _expanded = selected ? null : cat;
                              _selectedOptionIndex = null;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _categoryIcon(cat),
                                  color: const Color(0xFF1D9E75),
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _categoryLabel(loc, cat),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_expanded != null)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          ...List.generate(
                            _categoryPenalties(loc, _expanded!).length,
                            (i) {
                              final label =
                                  _categoryPenalties(loc, _expanded!)[i];
                              return ListTile(
                                leading: Radio<int>(
                                  value: i,
                                  groupValue: _selectedOptionIndex,
                                  activeColor: const Color(0xFF1D9E75),
                                  onChanged: (_) => _selectPenalty(label),
                                ),
                                title: Text(
                                  label,
                                  style: const TextStyle(
                                    color: Color(0xFFE6EDF3),
                                  ),
                                ),
                                onTap: () => _selectPenalty(label),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
