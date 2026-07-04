import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/services/purchases_service.dart';

/// Whether the current user holds the live Brain Clean Pro entitlement.
bool _hasProEntitlement(WidgetRef ref) =>
    ref.read(entitlementStatusProvider).valueOrNull ?? false;

/// Routes to [destination] for Pro users, otherwise opens the paywall.
void navigateWithProGate(
  BuildContext context,
  WidgetRef ref,
  String destination,
) {
  if (_hasProEntitlement(ref)) {
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
  if (_hasProEntitlement(ref)) {
    context.push('/silence-challenge/$streakDays');
  } else {
    context.push(AppRoutes.proPaywall);
  }
}
