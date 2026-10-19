import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Short motion + haptics that respect reduce-motion.
abstract final class V3Motion {
  V3Motion._();

  static const maxDuration = Duration(milliseconds: 300);

  static bool reduceMotion(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context);

  static Duration duration(BuildContext context, Duration preferred) {
    if (reduceMotion(context)) return Duration.zero;
    if (preferred > maxDuration) return maxDuration;
    return preferred;
  }

  static Future<void> lightTap(BuildContext? context) async {
    if (context != null && reduceMotion(context)) return;
    await HapticFeedback.lightImpact();
  }

  static Future<void> mediumComplete(BuildContext? context) async {
    if (context != null && reduceMotion(context)) return;
    await HapticFeedback.mediumImpact();
  }
}
