import 'package:flutter/material.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_design_constants.dart';

class V3TabPlaceholder extends StatelessWidget {
  const V3TabPlaceholder({
    super.key,
    required this.tabKey,
    required this.title,
  });

  final Key tabKey;
  final String title;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppDesignConstants.darkBackground,
      body: SafeArea(
        child: Center(
          child: Column(
            key: tabKey,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: AppDesignConstants.typeH2,
                  fontWeight: FontWeight.bold,
                  color: AppDesignConstants.darkOnSurface,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.v3TodayPlaceholder,
                style: const TextStyle(
                  color: AppDesignConstants.darkOnSurfaceMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

abstract final class V3ShellKeys {
  static const todayTab = Key('v3_tab_today');
  static const programTab = Key('v3_tab_program');
  static const toolsTab = Key('v3_tab_tools');
  static const progressTab = Key('v3_tab_progress');
}
