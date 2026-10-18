import 'package:flutter/material.dart';

/// Slot for real usage data (C06). Renders nothing until usage is wired.
class UsageSummaryCard extends StatelessWidget {
  const UsageSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink(
      key: Key('v3_progress_usage_summary_slot'),
    );
  }
}
