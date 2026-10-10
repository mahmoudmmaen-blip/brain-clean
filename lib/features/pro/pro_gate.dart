import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../v3/routing/v3_routes.dart';
import 'application/subscription_service_provider.dart';

/// Routes to [destination] for Pro users, otherwise opens the V3 paywall.
void navigateWithProGate(
  BuildContext context,
  WidgetRef ref,
  String destination,
) {
  if (ref.read(isProUserProvider)) {
    context.push(destination);
  } else {
    context.push('${V3Routes.paywall}?source=pro_gate');
  }
}
