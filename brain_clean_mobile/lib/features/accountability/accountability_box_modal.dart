import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

extension on _AccountabilityCategory {
  String get label => switch (this) {
        _AccountabilityCategory.physical => 'اللياقة البدنية',
        _AccountabilityCategory.nutritional => 'التغذية الصحية',
        _AccountabilityCategory.altruistic => 'العمل الخيري',
        _AccountabilityCategory.mental => 'التحدي الذهني',
      };

  IconData get icon => switch (this) {
        _AccountabilityCategory.physical => Icons.fitness_center,
        _AccountabilityCategory.nutritional => Icons.restaurant,
        _AccountabilityCategory.altruistic => Icons.volunteer_activism,
        _AccountabilityCategory.mental => Icons.psychology,
      };

  List<String> get penalties => switch (this) {
        _AccountabilityCategory.physical => const [
            'تمرين 30 دقيقة',
            'تمارين قوة',
            'مشي 5000 خطوة',
            'تمدد صباحي',
            'نشاط خارجي',
          ],
        _AccountabilityCategory.nutritional => const [
            'تجنب السكر',
            'وجبة متوازنة',
            'شرب 2 لتر ماء',
            'تقليل الكافيين',
            'وجبة بروtein',
          ],
        _AccountabilityCategory.altruistic => const [
            'مساعدة جار',
            'تبرع صغير',
            'رسالة شكر',
            'خدمة مجتمعية',
            'دعم صديق',
          ],
        _AccountabilityCategory.mental => const [
            'قراءة 20 دقيقة',
            'حل لغز',
            'تعلم كلمة جديدة',
            'تأمل موجّه',
            'كتابة يوميات',
          ],
      };
}

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
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تسجيل العقوبة ✓'),
        backgroundColor: Color(0xFF1D9E75),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                const Expanded(
                  child: Text(
                    'غرفة المساءلة الرقمية',
                    style: TextStyle(
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
                                  cat.icon,
                                  color: const Color(0xFF1D9E75),
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat.label,
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
                          ...List.generate(_expanded!.penalties.length, (i) {
                            final label = _expanded!.penalties[i];
                            return ListTile(
                              leading: Radio<int>(
                                value: i,
                                groupValue: _selectedOptionIndex,
                                activeColor: const Color(0xFF1D9E75),
                                onChanged: (_) => _selectPenalty(label),
                              ),
                              title: Text(
                                label,
                                style: const TextStyle(color: Color(0xFFE6EDF3)),
                              ),
                              onTap: () => _selectPenalty(label),
                            );
                          }),
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
