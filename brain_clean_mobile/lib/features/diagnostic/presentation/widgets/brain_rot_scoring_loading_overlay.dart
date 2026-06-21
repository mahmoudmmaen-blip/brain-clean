import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_design_constants.dart';
import '../../../../core/theme/theme_extensions.dart';

/// Full-screen veil while coherence / ε validation runs after the 10th answer.
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

enum _OverlayVisibility { detached, fadingIn, shown, fadingOut }

class _BrainRotScoringLoadingOverlayState extends State<BrainRotScoringLoadingOverlay>
    with SingleTickerProviderStateMixin {
  static const _fadeDuration = Duration(milliseconds: 280);

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  _OverlayVisibility _phase = _OverlayVisibility.detached;

  bool get _isInTree => _phase != _OverlayVisibility.detached;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: _fadeDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.96, end: 1).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    if (widget.visible) {
      _phase = _OverlayVisibility.shown;
      _fadeController.value = 1;
    }
  }

  @override
  void didUpdateWidget(BrainRotScoringLoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible == oldWidget.visible) return;

    if (widget.visible) {
      setState(() => _phase = _OverlayVisibility.fadingIn);
      _fadeController.forward(from: 0).whenComplete(_onFadeInComplete);
    } else {
      setState(() => _phase = _OverlayVisibility.fadingOut);
      _fadeController.reverse().whenComplete(_onFadeOutComplete);
    }
  }

  void _onFadeInComplete() {
    if (!mounted || !widget.visible) return;
    if (_phase == _OverlayVisibility.fadingIn) {
      setState(() => _phase = _OverlayVisibility.shown);
    }
  }

  void _onFadeOutComplete() {
    if (!mounted || widget.visible) return;
    if (_phase == _OverlayVisibility.fadingOut) {
      setState(() => _phase = _OverlayVisibility.detached);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInTree) return const SizedBox.shrink();

    return Positioned.fill(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) => IgnorePointer(
            ignoring: _fadeAnimation.value < 0.05,
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: child,
            ),
          ),
          child: ColoredBox(
            color: Theme.of(context)
                .colorScheme
                .surface
                .withValues(alpha: 0.9),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: const _ScoringIndicatorCard(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Isolated repaint island — spinner + Arabic analysis label.
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
