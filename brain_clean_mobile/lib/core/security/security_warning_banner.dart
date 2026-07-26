import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Local-first release: root / compromise banners are not shown.
///
/// Cloud sync is not part of this product surface, so a "compromised device"
/// warning that mentions disabled sync is not appropriate. Keep this widget as
/// a no-op so older call sites remain compile-safe.
class SecurityWarningBanner extends ConsumerWidget {
  const SecurityWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SizedBox.shrink();
  }
}
