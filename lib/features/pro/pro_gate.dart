import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import 'application/subscription_service_provider.dart';

/// Routes to [destination] for Pro users, otherwise opens V2 Premium.
void navigateWithProGate(
  BuildContext context,
  WidgetRef ref,
  String destination,
) {
  if (ref.read(isProUserProvider)) {
    context.push(destination);
  } else {
    context.push(AppRoutes.v2PremiumWithSource('pro_gate'));
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
    context.push(AppRoutes.v2PremiumWithSource('pro_gate'));
  }
}
