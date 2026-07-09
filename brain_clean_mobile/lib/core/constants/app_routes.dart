/// Central route paths for [GoRouter].
abstract final class AppRoutes {
  static const splash = '/';
  static const biometricLock = '/biometric-lock';
  static const onboarding = '/onboarding';

  static const home = '/home';
  static const exercises = '/exercises';
  static const safa = '/safa';
  static const journey = '/journey';
  static const more = '/more';

  // Home branch
  static const diagnostic = '/home/diagnostic';
  static const detox = '/home/detox';
  static const recovery = '/home/recovery';
  static const pomodoro = '/home/pomodoro';
  static const singleTask = '/home/single-task';
  static const delayedGratification = '/home/delayed-gratification';
  static const emotionWheel = '/home/emotion-wheel';
  static String silenceChallenge(int streakDays) =>
      '/home/silence-challenge/$streakDays';
  static String breathingFriction(int currentBhi) =>
      '/home/breathing-friction/$currentBhi';

  // Exercises branch
  static const cognitiveHub = '/exercises/cognitive-hub';
  static const cognitiveVisual = '/exercises/cognitive-visual';
  static const cognitiveMemory = '/exercises/cognitive-memory';
  static const cognitiveTest = '/exercises/cognitive-test';
  static const focusedThinking = '/exercises/focused-thinking';
  static const crossword = '/exercises/crossword';
  static const games = '/exercises/games';
  static const gameNBack = '/exercises/n-back';
  static const gameSpeedSort = '/exercises/speed-sort';
  static const gameColorWord = '/exercises/color-word';
  static const gameNumberMemory = '/exercises/number-memory';
  static const gamePatternMatch = '/exercises/pattern-match';

  // Safa branch
  static const emotionOasis = '/safa/emotion-oasis';

  // Journey branch
  static const dashboard = '/journey/dashboard';
  static const weeklyReport = '/weekly-report';

  // Full-screen assessments (outside shell stacks)
  static const anxietyDiagnostic = '/anxiety-diagnostic';
  static const anxietyResult = '/anxiety-result';
  static const worryJournal = '/worry-journal';
  static const worryWindow = '/worry-window';

  // More branch
  static const settings = '/more/settings';
  static const profile = '/more/profile';
  static const proPaywall = '/more/pro-paywall';
  static const accountability = '/more/accountability';

  /// Maps legacy flat paths to the new shell-nested paths.
  static String? legacyRedirect(String path) {
    const exact = <String, String>{
      '/diagnostic': diagnostic,
      '/detox': detox,
      '/recovery': recovery,
      '/pomodoro': pomodoro,
      '/single-task': singleTask,
      '/delayed-gratification': delayedGratification,
      '/emotion-wheel': emotionWheel,
      '/cognitive': cognitiveHub,
      '/cognitive/visual': cognitiveVisual,
      '/cognitive/memory': cognitiveMemory,
      '/cognitive-test': cognitiveTest,
      '/focused-thinking': focusedThinking,
      '/crossword': crossword,
      '/games': games,
      '/n-back': gameNBack,
      '/speed-sort': gameSpeedSort,
      '/color-word': gameColorWord,
      '/number-memory': gameNumberMemory,
      '/pattern-match': gamePatternMatch,
      '/emotion-oasis': emotionOasis,
      '/dashboard': dashboard,
      '/weekly-report': weeklyReport,
      '/settings': settings,
      '/profile': profile,
      '/pro-paywall': proPaywall,
    };
    final mapped = exact[path];
    if (mapped != null) return mapped;

    final silence = RegExp(r'^/silence-challenge/(\d+)$').firstMatch(path);
    if (silence != null) {
      return silenceChallenge(int.parse(silence.group(1)!));
    }

    final breathing = RegExp(r'^/breathing-friction/(\d+)$').firstMatch(path);
    if (breathing != null) {
      return breathingFriction(int.parse(breathing.group(1)!));
    }

    return null;
  }
}
