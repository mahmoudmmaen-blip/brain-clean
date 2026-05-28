import 'package:flutter/material.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Lightweight full-screen veil while coherence checks run after Q10.
///
/// Renders on the first frame when [visible] becomes true (no fade-in delay).
class BrainRotScoringLoadingOverlay extends StatefulWidget {
  const BrainRotScoringLoadingOverlay({
    super.key,
    required this.visible,
  });

  final bool visible;

  @override
  State<BrainRotScoringLoadingOverlay> createState() =>
      _BrainRotScoringLoadingOverlayState();
}

class _BrainRotScoringLoadingOverlayState
    extends State<BrainRotScoringLoadingOverlay> {
  static const _hideDuration = Duration(milliseconds: 180);

  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    if (widget.visible) {
      _showContent = true;
    }
  }

  @override
  void didUpdateWidget(BrainRotScoringLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      setState(() => _showContent = true);
    } else if (!widget.visible && oldWidget.visible) {
      Future<void>.delayed(_hideDuration, () {
        if (mounted && !widget.visible) {
          setState(() => _showContent = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_showContent && !widget.visible) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: RepaintBoundary(
        child: IgnorePointer(
          ignoring: !widget.visible,
          child: AnimatedOpacity(
            opacity: widget.visible ? 1 : 0,
            duration: widget.visible ? Duration.zero : _hideDuration,
            curve: Curves.easeOut,
            child: ColoredBox(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.9),
              child: const Center(
                child: _ScoringIndicatorCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Isolated repaint island — spinner + label only.
class _ScoringIndicatorCard extends StatelessWidget {
  const _ScoringIndicatorCard();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Material(
        color: theme.cardTheme.color ?? theme.colorScheme.surface,
        elevation: context.isLightTheme ? 3 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
          side: BorderSide(
            color: context.brandPrimary.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.psychology_alt_outlined,
                size: 32,
                color: context.brandPrimary,
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: context.brandPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                loc.diagnosticBrainRotScoring,
                textAlign: TextAlign.center,
                style: context.arabicLabelStyle.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
