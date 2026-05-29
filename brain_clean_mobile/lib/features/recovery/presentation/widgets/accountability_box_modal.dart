import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../domain/accountability_category.dart';
import '../recovery_protocol_controller.dart';

const accountabilityModalKey = Key('accountability_box_modal');

Key accountabilityPenaltyOptionKey(int globalIndex) =>
    Key('accountability_penalty_$globalIndex');

Future<void> showAccountabilityBoxModal(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const AccountabilityBoxModal(),
  );
}

class AccountabilityBoxModal extends StatelessWidget {
  const AccountabilityBoxModal({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      key: accountabilityModalKey,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return AccountabilityBoxSheetBody(
          scrollController: scrollController,
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }
}

/// Scrollable accountability room body (testable outside [DraggableScrollableSheet]).
class AccountabilityBoxSheetBody extends ConsumerStatefulWidget {
  const AccountabilityBoxSheetBody({
    super.key,
    required this.scrollController,
    this.onClose,
    this.onPenaltyApplied,
    this.initialExpanded,
  });

  final ScrollController scrollController;
  final VoidCallback? onClose;
  final VoidCallback? onPenaltyApplied;
  final AccountabilityCategory? initialExpanded;

  @override
  ConsumerState<AccountabilityBoxSheetBody> createState() =>
      _AccountabilityBoxSheetBodyState();
}

class _AccountabilityBoxSheetBodyState
    extends ConsumerState<AccountabilityBoxSheetBody> {
  late AccountabilityCategory? _expanded;

  static const _bg = Color(0xFF0D1117);

  @override
  void initState() {
    super.initState();
    _expanded = widget.initialExpanded;
  }
  static const _handle = Color(0xFF30363D);

  Future<void> _selectPenalty(
    AccountabilityCategory category,
    int optionIndex,
  ) async {
    await ref
        .read(recoveryProtocolControllerProvider.notifier)
        .applyAccountabilityPenalty();
    if (!mounted) return;
    widget.onPenaltyApplied?.call();
    final loc = AppLocalizations.of(context)!;
    if (widget.onClose != null) {
      widget.onClose!();
    } else if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(loc.accountabilityPenaltyRecorded)),
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
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _handle,
              borderRadius: BorderRadius.circular(2),
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
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    icon: const Icon(Icons.close, color: Color(0xFF8B949E)),
                    onPressed: widget.onClose,
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
                    children: AccountabilityCategory.values.map((cat) {
                      final selected = _expanded == cat;
                      return _CategoryTile(
                        key: ValueKey('accountability_category_${cat.name}'),
                        category: cat,
                        selected: selected,
                        onTap: () {
                          setState(() {
                            _expanded = selected ? null : cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  if (_expanded != null) ...[
                    const SizedBox(height: 16),
                    ...List.generate(5, (i) {
                      final cat = _expanded!;
                      final global = cat.penaltyGlobalIndex(i);
                      return ListTile(
                        key: accountabilityPenaltyOptionKey(global),
                        tileColor: const Color(0xFF161B22),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: Text(
                          cat.penaltyLabel(loc, i),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.remove_circle_outline,
                          color: Color(0xFFEF4444),
                        ),
                        onTap: () => _selectPenalty(cat, i),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final AccountabilityCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Material(
      color: selected
          ? const Color(0xFF1D9E75).withValues(alpha: 0.12)
          : const Color(0xFF161B22),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(category.icon, color: const Color(0xFF1D9E75), size: 28),
              const SizedBox(height: 8),
              Text(
                category.title(loc),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
