import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../domain/anxiety_result.dart';
import '../safa_anxiety_program_provider.dart';

class SafaAnxietyProgramCard extends ConsumerWidget {
  const SafaAnxietyProgramCard({super.key, required this.result});

  final AnxietyResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final programAsync = ref.watch(safaAnxietyProgramProvider(result));

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            loc.safaProgramTitle,
            textAlign: TextAlign.center,
            style: AppDesignConstants.arabicText(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          programAsync.when(
            loading: () => _ProgramShimmer(color: colorScheme.onSurfaceVariant),
            error: (_, __) => Text(
              loc.safaProgramLoadError,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.error),
            ),
            data: (program) => Text(
              program,
              textAlign: TextAlign.center,
              style: AppDesignConstants.arabicText(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
                height: AppDesignConstants.arabicBodyLineHeight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.safa),
            child: Text(loc.safaProgramCta),
          ),
        ],
      ),
    );
  }
}

class _ProgramShimmer extends StatefulWidget {
  const _ProgramShimmer({required this.color});

  final Color color;

  @override
  State<_ProgramShimmer> createState() => _ProgramShimmerState();
}

class _ProgramShimmerState extends State<_ProgramShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(opacity: 0.35 + (_controller.value * 0.45), child: child);
      },
      child: Column(
        children: List.generate(
          3,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
