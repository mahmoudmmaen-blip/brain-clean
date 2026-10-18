import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_design_constants.dart';

/// Share-card variants — no personal answers, no name.
sealed class ShareCardVariant {
  const ShareCardVariant();

  factory ShareCardVariant.sosWin({
    required int before,
    required int after,
  }) = SosWinShareCard;

  factory ShareCardVariant.dayMilestone({
    required int days,
    int? clarityFrom,
    int? clarityTo,
  }) = DayMilestoneShareCard;
}

class SosWinShareCard extends ShareCardVariant {
  const SosWinShareCard({required this.before, required this.after});

  final int before;
  final int after;
}

class DayMilestoneShareCard extends ShareCardVariant {
  const DayMilestoneShareCard({
    required this.days,
    this.clarityFrom,
    this.clarityTo,
  });

  final int days;
  final int? clarityFrom;
  final int? clarityTo;
}

/// Renders a shareable PNG (RepaintBoundary) and shares via [share_plus].
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.variant,
    required this.locale,
    this.boundaryKey,
  });

  final ShareCardVariant variant;
  final String locale;
  final GlobalKey? boundaryKey;

  static const storeName = 'Brain Clean';

  String get _bigLine {
    final ar = locale.startsWith('ar');
    return switch (variant) {
      SosWinShareCard(:final before, :final after) => ar
          ? 'تجاوزت رغبة في التصفح: من $before إلى $after'
          : 'You rode out a scroll urge: from $before to $after',
      DayMilestoneShareCard(:final days) => ar
          ? 'أكملت $days يومًا من برنامج الصفاء'
          : 'You completed $days days of the Clarity program',
    };
  }

  String? get _smallLine {
    final ar = locale.startsWith('ar');
    return switch (variant) {
      SosWinShareCard() => null,
      DayMilestoneShareCard(:final clarityFrom, :final clarityTo) =>
        (clarityFrom != null && clarityTo != null)
            ? (ar
                ? 'الصفاء: من $clarityFrom إلى $clarityTo'
                : 'Clarity: from $clarityFrom to $clarityTo')
            : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
      key: const Key('v3_share_card'),
      width: 360,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppDesignConstants.darkSurface,
        borderRadius: BorderRadius.circular(AppDesignConstants.radiusCard),
        border: Border.all(color: AppDesignConstants.darkBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/branding/brain_clean_mark.png',
            width: 56,
            height: 56,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.spa,
              size: 56,
              color: AppDesignConstants.brandGreen,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _bigLine,
            key: const Key('v3_share_card_big'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppDesignConstants.darkOnSurface,
              height: 1.35,
            ),
          ),
          if (_smallLine != null) ...[
            const SizedBox(height: 12),
            Text(
              _smallLine!,
              key: const Key('v3_share_card_small'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: AppDesignConstants.darkOnSurfaceMuted,
              ),
            ),
          ],
          const SizedBox(height: 20),
          const Text(
            storeName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppDesignConstants.brandGreen,
            ),
          ),
        ],
      ),
    );

    final key = boundaryKey;
    if (key == null) return card;
    return RepaintBoundary(key: key, child: card);
  }
}

/// Capture [ShareCard] behind a [RepaintBoundary] and open the share sheet.
Future<void> shareShareCardPng({
  required GlobalKey boundaryKey,
  String? shareText,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 3);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final bytes = byteData.buffer.asUint8List();
  await Share.shareXFiles(
    [
      XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'brain_clean_share.png',
      ),
    ],
    text: shareText,
  );
}

/// Off-stage card used to produce PNG bytes without showing UI (tests / share).
Future<Uint8List?> captureShareCardBytes({
  required GlobalKey boundaryKey,
}) async {
  final boundary =
      boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return null;
  final image = await boundary.toImage(pixelRatio: 2);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
