import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/constants/app_routes.dart';

/// Routes to [destination] for Pro users, otherwise opens the paywall.
void navigateWithProGate(
  BuildContext context,
  WidgetRef ref,
  String destination,
) {
  if (ref.read(isProUserProvider)) {
    context.push(destination);
  } else {
    context.push(AppRoutes.proPaywall);
  }
}

/// Pushes paywall with optional custom streak-days path builder.
void navigateSilenceWithProGate(
  BuildContext context,
  WidgetRef ref,
  int streakDays,
) {
  if (ref.read(isProUserProvider)) {
    context.push('/silence-challenge/$streakDays');
  } else {
    context.push(AppRoutes.proPaywall);
  }
}
