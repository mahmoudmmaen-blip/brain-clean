import 'package:flutter/material.dart';

import '../../../../core/theme/theme_extensions.dart';
import '../../domain/diagnostic_model.dart';

/// Upper questionnaire progress — fill width animates forward/back with navigation.
class BrainRotDirectionalProgressBar extends StatefulWidget {
  const BrainRotDirectionalProgressBar({
    super.key,
    required this.questionIndex,
    required this.slideDirection,
    this.duration = const Duration(milliseconds: 400),
  });

  final int questionIndex;
  final int slideDirection;
  final Duration duration;

  @override
  State<BrainRotDirectionalProgressBar> createState() =>
      _BrainRotDirectionalProgressBarState();
}

class _BrainRotDirectionalProgressBarState
    extends State<BrainRotDirectionalProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _fillAnimation;

  double _from = 0;
  double _to = 0;
  late bool _growFromStart;

  static double _progressForIndex(int index) =>
      (index + 1) / BrainRotTest.questionCount;

  @override
  void initState() {
    super.initState();
    _to = _progressForIndex(widget.questionIndex);
    _from = _to;
    _growFromStart = true;

    _controller = AnimationController(vsync: this, duration: widget.duration);
    _fillAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _growFromStart = _resolveGrowFromStart(context, widget.slideDirection);
  }

  @override
  void didUpdateWidget(BrainRotDirectionalProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questionIndex != widget.questionIndex ||
        oldWidget.slideDirection != widget.slideDirection) {
      _from = _displayedFill;
      _to = _progressForIndex(widget.questionIndex);
      _growFromStart = _resolveGrowFromStart(context, widget.slideDirection);
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _displayedFill => _from + (_to - _from) * _fillAnimation.value;

  bool _resolveGrowFromStart(BuildContext context, int slideDirection) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final sign = slideDirection >= 0 ? 1.0 : -1.0;
    final horizontalSign = isRtl ? -sign : sign;
    return horizontalSign >= 0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fillAnimation,
      builder: (context, _) {
        final fill = _displayedFill.clamp(0.0, 1.0);
        final t = _fillAnimation.value;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 8,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: context.diagnosticProgressTrack),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final barWidth = constraints.maxWidth * fill;
                    return Align(
                      alignment: _growFromStart
                          ? AlignmentDirectional.centerStart
                          : AlignmentDirectional.centerEnd,
                      child: Container(
                        width: barWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.horizontal(
                            left: _growFromStart
                                ? const Radius.circular(6)
                                : Radius.zero,
                            right: _growFromStart
                                ? Radius.zero
                                : const Radius.circular(6),
                          ),
                          gradient: LinearGradient(
                            begin: _growFromStart
                                ? Alignment.centerLeft
                                : Alignment.centerRight,
                            end: _growFromStart
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            colors: [
                              context.brandPrimary.withValues(alpha: 0.5),
                              context.brandPrimary,
                            ],
                            stops: [0.0, 0.3 + 0.7 * t],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
