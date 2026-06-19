import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../diagnostic/presentation/bc_score_provider.dart';
import '../gamification/level_system.dart';
import '../home/presentation/home_streak_provider.dart';

final shareCardBoundaryKey = GlobalKey();

/// Renders a 400×300 share card and shares it as PNG.
class ShareButton extends ConsumerWidget {
  const ShareButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      key: const Key('share_progress_button'),
      onPressed: () => _share(context, ref),
      icon: const Icon(Icons.share),
      label: Text(loc.shareProgressLabel),
    );
  }

  Future<void> _share(BuildContext context, WidgetRef ref) async {
    try {
      final boundary = shareCardBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/brain_clean_share.png');
      await file.writeAsBytes(byteData.buffer.asUint8List());

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Brain Clean',
      );
    } catch (_) {
      // Share may fail in tests.
    }
  }
}

/// Off-screen (or inline) share card for capture.
class ShareCardCapture extends ConsumerWidget {
  const ShareCardCapture({super.key, this.visible = false});

  final bool visible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';
    final bcs =
        (ref.watch(bcScoreSessionProvider)?.bcScore ?? 0).clamp(0.0, 100.0);
    final streak = ref.watch(homeStreakSnapshotProvider).days;
    final level = BrainLevel.forScore(bcs.round());

    final card = RepaintBoundary(
      key: shareCardBoundaryKey,
      child: SizedBox(
        width: 400,
        height: 300,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1117), Color(0xFF161B22)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  '🧠 Brain Clean',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${bcs.round()}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  isArabic ? 'مؤشر وضوح الدماغ' : 'Brain Clarity Score',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isArabic
                      ? '🔥 $streak يوم تركيز متواصل'
                      : '🔥 $streak day focus streak',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '${level.emoji} ${level.localizedName(isArabic)}',
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                const Text(
                  'brain-clean.app',
                  style: TextStyle(color: Color(0xFF30363D), fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (visible) return card;
    return Offstage(offstage: true, child: card);
  }
}
