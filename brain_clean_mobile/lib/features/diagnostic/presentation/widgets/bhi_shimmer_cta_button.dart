import 'package:flutter/material.dart';

/// Gradient CTA with a subtle looping shimmer (3s period).
class BhiShimmerCtaButton extends StatefulWidget {
  const BhiShimmerCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.borderRadius = 14,
  });

  final String label;
  final VoidCallback onPressed;
  final double height;
  final double borderRadius;

  static const _gradientStart = Color(0xFF1D9E75);
  static const _gradientEnd = Color(0xFF0F7A5A);

  @override
  State<BhiShimmerCtaButton> createState() => _BhiShimmerCtaButtonState();
}

class _BhiShimmerCtaButtonState extends State<BhiShimmerCtaButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, child) {
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              gradient: LinearGradient(
                begin: Alignment(-1 + 2 * _shimmer.value, 0),
                end: Alignment(_shimmer.value, 0),
                colors: const [
                  BhiShimmerCtaButton._gradientStart,
                  Color(0xFF2AB88A),
                  BhiShimmerCtaButton._gradientEnd,
                  BhiShimmerCtaButton._gradientStart,
                ],
                stops: const [0.0, 0.35, 0.7, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: BhiShimmerCtaButton._gradientStart.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          );
        },
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: widget.onPressed,
            child: Center(
              child: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
