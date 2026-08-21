import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../application/safa_controller.dart';
import '../data/safa_controller_provider.dart';
import '../domain/safa_context_category.dart';
import '../domain/safa_local_fallback.dart';
import '../domain/safa_session.dart';
import '../domain/safa_session_limit.dart';
import '../domain/safa_session_origin.dart';
import '../domain/safa_session_state.dart';
import '../domain/safa_suggested_destination.dart';

/// SAF-01 — Contextual Safa Support (Contract V1).
class SafaSupportScreen extends ConsumerStatefulWidget {
  const SafaSupportScreen({
    super.key,
    required this.origin,
    this.returnPath,
    this.view,
  });

  final SafaSessionOrigin origin;
  final String? returnPath;
  final String? view;

  @override
  ConsumerState<SafaSupportScreen> createState() => _SafaSupportScreenState();
}

class _SafaSupportScreenState extends ConsumerState<SafaSupportScreen> {
  late final SafaController _controller;
  late final TextEditingController _draftController;
  late final FocusNode _inputFocus;

  @override
  void initState() {
    super.initState();
    _controller = ref.read(safaControllerProvider);
    _draftController = TextEditingController();
    _inputFocus = FocusNode(debugLabel: 'safa_input');
    _controller.addListener(_onChange);
    Future.microtask(() {
      final locale = Localizations.localeOf(context).languageCode;
      _controller.open(
        origin: widget.origin,
        returnPath: widget.returnPath,
        locale: locale,
        view: widget.view,
      );
      final draft = _controller.session?.draftMessage ?? '';
      if (draft.isNotEmpty) {
        _draftController.text = draft;
      }
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    _draftController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _onChange() {
    if (!mounted) return;
    final draft = _controller.session?.draftMessage;
    if (draft != null &&
        draft != _draftController.text &&
        _controller.session?.uiState != SafaSessionState.sending) {
      // Preserve cursor when controller cleared draft after success.
      if (draft.isEmpty && _draftController.text.isNotEmpty) {
        _draftController.clear();
      }
    }
    setState(() {});
  }

  void _exit() {
    final path = _controller.session?.returnPath ?? AppRoutes.v2Home;
    _controller.clearSession();
    context.go(path);
  }

  void _goDestination(SafaSuggestedDestination dest) {
    final session = _controller.session;
    final originPath = session?.returnPath ?? AppRoutes.v2Home;
    if (dest == SafaSuggestedDestination.urgentHelp) {
      _controller.requestUrgentHelp();
      return;
    }
    final path = dest.resolvePath(originReturnPath: originPath);
    _controller.clearSession();
    context.go(path);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final session = _controller.session;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Semantics(
          header: true,
          child: Text(loc.v2SafaTitle),
        ),
        leading: IconButton(
          key: const Key('v2_safa_exit'),
          tooltip: loc.v2SafaReturn,
          onPressed: _exit,
          icon: const Icon(Icons.close),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 16),
                child: session == null
                    ? Center(child: Text(loc.v2SafaLoading))
                    : _SafaBody(
                        loc: loc,
                        session: session,
                        draftController: _draftController,
                        inputFocus: _inputFocus,
                        onDraftChanged: _controller.updateDraft,
                        onAckPrivacy: _controller.acknowledgePrivacyNotice,
                        onGrantConsent: _controller.grantSendConsent,
                        onDeclineConsent: _controller.declineConsent,
                        onSend: _controller.send,
                        onRetry: _controller.retry,
                        onClear: () {
                          _draftController.clear();
                          _controller.clearSession();
                          context.go(session.returnPath);
                        },
                        onUrgent: _controller.requestUrgentHelp,
                        onCategory: _controller.selectContextCategory,
                        onIncludeContext: _controller.setIncludeApprovedContext,
                        onGoDestination: _goDestination,
                        onExit: _exit,
                        onStartLater: () {
                          _controller.startNewSessionLater();
                          _draftController.clear();
                        },
                        onUseFallback: _controller.useLocalFallback,
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SafaBody extends StatelessWidget {
  const _SafaBody({
    required this.loc,
    required this.session,
    required this.draftController,
    required this.inputFocus,
    required this.onDraftChanged,
    required this.onAckPrivacy,
    required this.onGrantConsent,
    required this.onDeclineConsent,
    required this.onSend,
    required this.onRetry,
    required this.onClear,
    required this.onUrgent,
    required this.onCategory,
    required this.onIncludeContext,
    required this.onGoDestination,
    required this.onExit,
    required this.onStartLater,
    required this.onUseFallback,
  });

  final AppLocalizations loc;
  final SafaSession session;
  final TextEditingController draftController;
  final FocusNode inputFocus;
  final ValueChanged<String> onDraftChanged;
  final VoidCallback onAckPrivacy;
  final VoidCallback onGrantConsent;
  final VoidCallback onDeclineConsent;
  final Future<void> Function() onSend;
  final Future<void> Function() onRetry;
  final VoidCallback onClear;
  final VoidCallback onUrgent;
  final ValueChanged<SafaContextCategory> onCategory;
  final ValueChanged<bool> onIncludeContext;
  final ValueChanged<SafaSuggestedDestination> onGoDestination;
  final VoidCallback onExit;
  final VoidCallback onStartLater;
  final Future<void> Function() onUseFallback;

  @override
  Widget build(BuildContext context) {
    final state = session.uiState;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          liveRegion: true,
          child: Text(
            loc.v2SafaPurpose,
            style: theme.textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          child: Text(
            loc.v2SafaAiLimitation,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          liveRegion: true,
          label: loc.v2SafaSessionLimit(
            '${session.userMessageCount}',
            '${SafaSessionLimit.maxUserMessages}',
          ),
          child: Text(
            loc.v2SafaSessionLimit(
              '${session.userMessageCount}',
              '${SafaSessionLimit.maxUserMessages}',
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 16),
        Semantics(
          liveRegion: true,
          child: Text(_stateMessage(loc, state)),
        ),
        if (state == SafaSessionState.offline ||
            state == SafaSessionState.serviceUnavailable ||
            state == SafaSessionState.localFallback) ...[
          const SizedBox(height: 12),
          _offlineTipCard(context, loc),
        ],
        const SizedBox(height: 16),
        if (state == SafaSessionState.privacyNotice) ...[
          _primaryButton(
            key: const Key('v2_safa_ack_privacy'),
            label: loc.v2SafaAcknowledgeNotice,
            onPressed: onAckPrivacy,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_continue_without'),
            label: loc.v2SafaContinueWithout,
            onPressed: onDeclineConsent,
          ),
        ] else if (state == SafaSessionState.consentRequired) ...[
          Text(loc.v2SafaConsentBody),
          const SizedBox(height: 12),
          _primaryButton(
            key: const Key('v2_safa_grant_consent'),
            label: loc.v2SafaConsentAllow,
            onPressed: onGrantConsent,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_decline_consent'),
            label: loc.v2SafaConsentDecline,
            onPressed: onDeclineConsent,
          ),
        ] else if (state == SafaSessionState.safetyRedirect) ...[
          Semantics(
            liveRegion: true,
            child: Text(loc.v2SafaUrgentBody),
          ),
          const SizedBox(height: 12),
          Text(loc.v2SafaUrgentLocalEmergency),
          const SizedBox(height: 16),
          _primaryButton(
            key: const Key('v2_safa_urgent_return'),
            label: loc.v2SafaReturn,
            onPressed: onExit,
          ),
        ] else if (state == SafaSessionState.boundedSessionComplete) ...[
          if (session.latestResponse != null) _responseCard(context, loc, session),
          const SizedBox(height: 12),
          _primaryButton(
            key: const Key('v2_safa_try_suggested'),
            label: _actionLabel(loc, session),
            onPressed: () {
              final dest = session.latestResponse?.suggestedDestination ??
                  SafaSuggestedDestination.origin;
              onGoDestination(dest);
            },
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_return_origin'),
            label: loc.v2SafaReturn,
            onPressed: onExit,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_urgent'),
            label: loc.v2SafaUrgentHelp,
            onPressed: onUrgent,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_start_later'),
            label: loc.v2SafaStartLater,
            onPressed: onStartLater,
          ),
        ] else ...[
          if (_showComposer(state)) ...[
            Text(
              loc.v2SafaContextOptionalHeading,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _chip(
                  loc.v2SafaContextNone,
                  selected: session.contextCategory == SafaContextCategory.none,
                  onTap: () => onCategory(SafaContextCategory.none),
                ),
                _chip(
                  loc.v2SafaContextDifficult,
                  selected: session.contextCategory ==
                      SafaContextCategory.difficultMoment,
                  onTap: () => onCategory(SafaContextCategory.difficultMoment),
                ),
                _chip(
                  loc.v2SafaContextClarify,
                  selected: session.contextCategory ==
                      SafaContextCategory.clarifyStep,
                  onTap: () => onCategory(SafaContextCategory.clarifyStep),
                ),
                _chip(
                  loc.v2SafaContextContinue,
                  selected: session.contextCategory ==
                      SafaContextCategory.continueSupport,
                  onTap: () => onCategory(SafaContextCategory.continueSupport),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              key: const Key('v2_safa_include_context'),
              contentPadding: EdgeInsets.zero,
              value: session.includeApprovedContext,
              onChanged: (v) => onIncludeContext(v ?? false),
              title: Text(loc.v2SafaIncludeApprovedContext),
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 8),
            Semantics(
              textField: true,
              label: loc.v2SafaInputLabel,
              child: TextField(
                key: const Key('v2_safa_input'),
                focusNode: inputFocus,
                controller: draftController,
                enabled: state != SafaSessionState.sending,
                minLines: 3,
                maxLines: 5,
                maxLength: SafaSessionLimit.maxInputCharacters,
                onChanged: onDraftChanged,
                decoration: InputDecoration(
                  labelText: loc.v2SafaInputLabel,
                  hintText: loc.v2SafaInputHint,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _primaryButton(
              key: const Key('v2_safa_send'),
              label: state == SafaSessionState.sending
                  ? loc.v2SafaSending
                  : loc.v2SafaSend,
              onPressed: state == SafaSessionState.sending
                  ? null
                  : () {
                      FocusScope.of(context).unfocus();
                      onSend();
                    },
            ),
          ],
          if (session.latestResponse != null &&
              state != SafaSessionState.privacyNotice &&
              state != SafaSessionState.consentRequired) ...[
            const SizedBox(height: 16),
            _responseCard(context, loc, session),
            const SizedBox(height: 12),
            _primaryButton(
              key: const Key('v2_safa_suggested_action'),
              label: _actionLabel(loc, session),
              onPressed: () {
                final dest = session.latestResponse!.suggestedDestination;
                onGoDestination(dest);
              },
            ),
          ],
          if (_isFailureLike(state)) ...[
            const SizedBox(height: 12),
            _secondaryButton(
              key: const Key('v2_safa_fallback_grounding'),
              label: loc.v2SafaFallbackGrounding,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            _secondaryButton(
              key: const Key('v2_safa_fallback_simplify'),
              label: loc.v2SafaFallbackSimplify,
              onPressed: () {},
            ),
            const SizedBox(height: 8),
            _secondaryButton(
              key: const Key('v2_safa_retry'),
              label: loc.v2SafaRetry,
              onPressed: () => onRetry(),
            ),
            const SizedBox(height: 8),
            _secondaryButton(
              key: const Key('v2_safa_use_fallback'),
              label: loc.v2SafaUseLocalFallback,
              onPressed: () => onUseFallback(),
            ),
          ],
          const SizedBox(height: 16),
          _secondaryButton(
            key: const Key('v2_safa_urgent'),
            label: loc.v2SafaUrgentHelp,
            onPressed: onUrgent,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_clear'),
            label: loc.v2SafaClearSession,
            onPressed: onClear,
          ),
          const SizedBox(height: 8),
          _secondaryButton(
            key: const Key('v2_safa_return'),
            label: loc.v2SafaReturn,
            onPressed: onExit,
          ),
        ],
      ],
    );
  }

  Widget _offlineTipCard(BuildContext context, AppLocalizations loc) {
    return KeyedSubtree(
      key: const Key('v2_safa_offline_tip_card'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.cardSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.45)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.spa_outlined, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      loc.v2SafaOfflineTipTitle,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                loc.v2SafaOfflineTipBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _showComposer(SafaSessionState state) {
    return state == SafaSessionState.ready ||
        state == SafaSessionState.idle ||
        state == SafaSessionState.sending ||
        state == SafaSessionState.responseReady ||
        state == SafaSessionState.inputTooLong ||
        state == SafaSessionState.localFallback ||
        state == SafaSessionState.offline ||
        state == SafaSessionState.timeout ||
        state == SafaSessionState.serviceUnavailable ||
        state == SafaSessionState.invalidResponse ||
        state == SafaSessionState.userCancelled;
  }

  bool _isFailureLike(SafaSessionState state) {
    return state == SafaSessionState.localFallback ||
        state == SafaSessionState.offline ||
        state == SafaSessionState.timeout ||
        state == SafaSessionState.serviceUnavailable ||
        state == SafaSessionState.invalidResponse;
  }

  Widget _responseCard(
    BuildContext context,
    AppLocalizations loc,
    SafaSession session,
  ) {
    final r = session.latestResponse!;
    final ack = r.shortAcknowledgement;
    final body = r.boundedSupportText;
    final safety = r.safetyQualifier.startsWith('safa_')
        ? loc.v2SafaNotMedical
        : r.safetyQualifier;
    return Semantics(
      liveRegion: true,
      label: '${loc.v2SafaResponseHeading}. $ack. $body',
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(loc.v2SafaResponseHeading,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(ack),
              const SizedBox(height: 8),
              Text(body),
              const SizedBox(height: 8),
              Text(
                safety,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              if (r.fallbackUsed) ...[
                const SizedBox(height: 8),
                Text(loc.v2SafaFallbackGrounding),
                Text(loc.v2SafaFallbackSimplify),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(AppLocalizations loc, SafaSession session) {
    final override = session.latestResponse?.suggestedAction.labelOverride;
    if (override != null && override.isNotEmpty) return override;
    final key = session.latestResponse?.suggestedAction.labelKey;
    return switch (key) {
      'v2SafaSuggestedReturnToday' => loc.v2SafaSuggestedReturnToday,
      SafaLocalFallback.simplifyKey => loc.v2SafaFallbackSimplify,
      SafaLocalFallback.groundingKey => loc.v2SafaFallbackGrounding,
      _ => loc.v2SafaSuggestedReturn,
    };
  }

  String _stateMessage(AppLocalizations loc, SafaSessionState state) {
    return switch (state) {
      SafaSessionState.idle => loc.v2SafaStateIdle,
      SafaSessionState.privacyNotice => loc.v2SafaPrivacyNotice,
      SafaSessionState.consentRequired => loc.v2SafaConsentBody,
      SafaSessionState.ready => loc.v2SafaStateReady,
      SafaSessionState.sending => loc.v2SafaSending,
      SafaSessionState.responseReady => loc.v2SafaStateResponseReady,
      SafaSessionState.localFallback => loc.v2SafaStateLocalFallback,
      SafaSessionState.offline => loc.v2SafaOffline,
      SafaSessionState.timeout => loc.v2SafaTimeout,
      SafaSessionState.serviceUnavailable => loc.v2SafaServiceUnavailable,
      SafaSessionState.invalidResponse => loc.v2SafaInvalidResponse,
      SafaSessionState.inputTooLong => loc.v2SafaInputTooLong,
      SafaSessionState.boundedSessionComplete => loc.v2SafaSessionComplete,
      SafaSessionState.safetyRedirect => loc.v2SafaUrgentBody,
      SafaSessionState.userCancelled => loc.v2SafaUserCancelled,
      SafaSessionState.cleared => loc.v2SafaCleared,
    };
  }

  Widget _chip(String label, {required bool selected, required VoidCallback onTap}) {
    return SizedBox(
      height: 48,
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  Widget _primaryButton({
    required Key key,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: FilledButton(
        key: key,
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _secondaryButton({
    required Key key,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: OutlinedButton(
        key: key,
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
