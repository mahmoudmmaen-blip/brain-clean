import 'dart:ui'; // ضروري جداً لتأثير الضبابية
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// استيراد الملفات الخاصة بك
import '../../../core/constants/app_routes.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../diagnostic/presentation/bc_score_provider.dart';
import '../../diagnostic/presentation/widgets/bc_score_breakdown.dart';
import '../../diagnostic/presentation/widgets/bc_score_hero_card.dart';
import '../../diagnostic/presentation/widgets/brain_rot_colors.dart';
import '../../../../recovery_settings_provider.dart';
import '../../../../app_strings.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final session = ref.watch(bcScoreSessionProvider);
    final challengeDays = ref.watch(challengeDurationProvider);
    final committedAt = session == null
        ? null
        : session.committedAt.toLocal().toString().substring(0, 16);

    return Scaffold(
      appBar: AppBar(title: Text(loc.dashboardTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- كارت تحدي النقاء (بتصميم Glassmorphism العصري) ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    title: Text(
                      AppStrings.challengeTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(AppStrings.challengeSubtitle(challengeDays)),
                    trailing: const Icon(Icons.edit, size: 20),
                    onTap: () => showChallengeDurationPicker(context, ref),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (session != null) ...[
              BcScoreHeroCard.fromSession(
                session: session,
                fontSize: 48,
                subtitle: loc.dashboardCommittedAt(committedAt!),
              ),
              BcScoreBreakdown.fromSession(session: session),
            ],

            const SizedBox(height: 24),

            // كارت واحة المشاعر
            Card(
              clipBehavior: Clip.antiAlias,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: const Icon(Icons.psychology, color: Colors.white),
                ),
                title: Text(AppStrings.emotionOasis),
                subtitle: const Text('تحدث مع المرشد السلوكي لدعم رحلتك'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/emotion-oasis'),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => context.push(AppRoutes.diagnostic),
              child: Text(loc.dashboardRetakeDiagnostic),
            ),
          ],
        ),
      ),
    );
  }
}