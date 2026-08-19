import 'package:flutter/foundation.dart';

/// Notifies [GoRouter] to re-run [GoRouter.redirect] without recreating the router.
final class GoRouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}
