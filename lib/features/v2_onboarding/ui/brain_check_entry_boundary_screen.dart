import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/routing/startup_destination.dart';
import '../../../core/theme/app_colors.dart';
import '../../brain_check/application/brain_check_controller_provider.dart';
import '../../brain_check/domain/brain_check_mode.dart';
import '../../brain_check/domain/brain_check_phase.dart';

/// CHK-01 entry boundary — intro / resume / completed (no questionnaire UI).
class BrainCheckEntryBoundaryScreen extends ConsumerStatefulWidget {
  const BrainCheckEntryBoundaryScreen({
    super.key,
    this.mode = 'lite',
    this.source = 'onboarding',
  });

  final String mode;
  final String source;

  @override
  ConsumerState<BrainCheckEntryBoundaryScreen> createState() =>
      _BrainCheckEntryBoundaryScreenState();
}

class _BrainCheckEntryBoundaryScreenState
    extends ConsumerState<BrainCheckEntryBoundaryScreen> {
  var _loading = true;
  BrainCheckPhase _phase = BrainCheckPhase.empty;
  String? _error;

  BrainCheckMode get _parsedMode {
    switch (widget.mode) {
      case 'full':
        return BrainCheckMode.full;
      case 'pulse':
        return BrainCheckMode.pulse;
      case 'lite':
      default:
        return BrainCheckMode.lite;
    }
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_hydrate);
  }

  Future<void> _hydrate() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final controller = ref.read(brainCheckControllerProvider);
      await controller.hydrate();
      if (!mounted) return;
      setState(() {
        _phase = controller.progress.phase;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'hydrate_failed';
        _phase = BrainCheckPhase.empty;
      });
    }
  }

  Future<void> _startFresh() async {
    final controller = ref.read(brainCheckControllerProvider);
    if (controller.progress.phase == BrainCheckPhase.resumeGate) {
      final confirmed = await _confirmRestart();
      if (!confirmed || !mounted) return;
      await controller.restart(confirmed: true);
    } else {
      await controller.start(mode: _parsedMode, source: widget.source);
    }
    if (!mounted) return;
    context.go(AppRoutes.v2BrainCheckFlow);
  }

  Future<void> _resume() async {
    final controller = ref.read(brainCheckControllerProvider);
    await controller.resume();
    if (!mounted) return;
    context.go(AppRoutes.v2BrainCheckFlow);
  }

  Future<bool> _confirmRestart() async {
    final loc = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(loc.brainCheckRestartTitle),
          content: Text(loc.brainCheckRestartBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(loc.brainCheckRestartCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(loc.brainCheckRestartConfirm),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(loc.v2BrainCheckEntryTitle),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go(StartupDestination.resolve()),
        ),
      ),
      body: SafeArea(
        child: BrainCheckEntryBody(
          loc: loc,
          loading: _loading,
          errorKey: _error,
          phase: _phase,
          onStart: _startFresh,
          onResume: _resume,
          onGoHome: () => context.go(StartupDestination.resolve()),
          onRetry: _hydrate,
        ),
      ),
    );
  }
}

/// Sync-testable CHK-01 entry body.
class BrainCheckEntryBody extends StatelessWidget {
  const BrainCheckEntryBody({
    super.key,
    required this.loc,
    required this.loading,
    required this.errorKey,
    required this.phase,
    required this.onStart,
    required this.onResume,
    required this.onGoHome,
    required this.onRetry,
  });

  final AppLocalizations loc;
  final bool loading;
  final String? errorKey;
  final BrainCheckPhase phase;
  final VoidCallback onStart;
  final VoidCallback onResume;
  final VoidCallback onGoHome;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: Semantics(
          liveRegion: true,
          label: loc.v2BrainCheckEntryLoading,
          child: Text(loc.v2BrainCheckEntryLoading),
        ),
      );
    }

    if (errorKey != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              liveRegion: true,
              child: Text(
                loc.v2BrainCheckEntryError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: onRetry,
                child: Text(loc.v2OnboardingRetry),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onGoHome,
                child: Text(loc.v2OnboardingGoHome),
              ),
            ),
          ],
        ),
      );
    }

    final isResume = phase == BrainCheckPhase.resumeGate;
    final isCompleted = phase == BrainCheckPhase.completed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text(
              loc.v2BrainCheckEntryTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 16),
          Text(loc.v2BrainCheckEntryBody),
          const SizedBox(height: 12),
          Text(
            loc.v2BrainCheckEntryNonMedical,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          Text(loc.v2BrainCheckEntryDuration),
          const SizedBox(height: 32),
          if (isCompleted) ...[
            Text(loc.v2BrainCheckEntryAlreadyComplete),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onGoHome,
                child: Text(loc.v2OnboardingGoHome),
              ),
            ),
          ] else if (isResume) ...[
            Text(loc.v2BrainCheckEntryResumeHint),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onResume,
                child: Text(loc.v2BrainCheckEntryResume),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onStart,
                child: Text(loc.v2BrainCheckEntryStartOver),
              ),
            ),
          ] else ...[
            SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: onStart,
                child: Text(loc.v2BrainCheckEntryStart),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onGoHome,
                child: Text(loc.v2OnboardingSkipBrainCheck),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
