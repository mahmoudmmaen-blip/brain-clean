import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/application/app_preferences_provider.dart';
import '../../core/constants/app_routes.dart';

const onboardingPageViewKey = Key('onboarding_page_view');
const onboardingSkipKey = Key('onboarding_skip_button');
const onboardingStartQuizKey = Key('onboarding_start_quiz_button');

/// First-launch onboarding — shown once, stored in Hive app_meta.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _bg = Color(0xFF0D1117);
  static const _text = Color(0xFFE6EDF3);

  final _controller = PageController();
  int _page = 0;

  Future<void> _finish({required String destination}) async {
    await ref.read(appPreferencesProvider.notifier).completeOnboarding();
    if (!mounted) return;
    context.go(destination);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                key: onboardingSkipKey,
                onPressed: () => _finish(destination: AppRoutes.home),
                child: const Text(
                  'تخطي',
                  style: TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                key: onboardingPageViewKey,
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  _OnboardingPage(
                    icon: Icons.psychology_outlined,
                    iconColor: Color(0xFF1D9E75),
                    title: 'مرحباً بك في Brain Clean',
                    body: 'استعد وعيك الرقمي في 21 يوماً',
                  ),
                  _OnboardingPage(
                    icon: Icons.track_changes,
                    iconColor: Color(0xFF3B82F6),
                    title: 'تتبع تركيزك يومياً',
                    body: 'معادلات علمية حقيقية لقياس صحة دماغك',
                  ),
                  _OnboardingPage(
                    icon: Icons.emoji_events,
                    iconColor: Color(0xFFF59E0B),
                    title: 'ابدأ رحلتك الآن',
                    body: 'أجب على 10 أسئلة لتحديد مستوى تعفن دماغك',
                    showStartButton: true,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _page == i ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _page == i
                        ? const Color(0xFF1D9E75)
                        : const Color(0xFF30363D),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_page == 2)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    key: onboardingStartQuizKey,
                    onPressed: () =>
                        _finish(destination: AppRoutes.diagnostic),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D9E75),
                    ),
                    child: const Text('ابدأ التقييم'),
                  ),
                ),
              )
            else
              const SizedBox(height: 76),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    this.showStartButton = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final bool showStartButton;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: iconColor),
          const SizedBox(height: 32),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE6EDF3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF8B949E),
              height: 1.5,
            ),
          ),
          if (showStartButton) const SizedBox(height: 24),
        ],
      ),
    );
  }
}
