/// V3 route paths (spec §3).
abstract final class V3Routes {
  static const splash = '/';
  static const biometricLock = '/biometric-lock';

  static const welcome = '/welcome';
  static const check = '/check';
  static const setup = '/setup';
  static const result = '/result';

  static const today = '/today';
  static const program = '/program';
  static const programDay = '/program/day/:n';
  static const session = '/session/:n';

  static const tools = '/tools';
  static const toolsExercise = '/tools/exercise/:id';
  static const toolsFocus = '/tools/focus';
  static const toolsGames = '/tools/games/:id';

  static const sos = '/sos';
  static const sosFlow = '/sos/:flowId';

  static const progress = '/progress';
  static const settings = '/settings';
  static const paywall = '/paywall';
  static const letter = '/letter';
  static const graduation = '/graduation';

  static const onboardingPaths = {
    welcome,
    check,
    setup,
    result,
  };

  static bool isOnboardingPath(String path) {
    if (onboardingPaths.contains(path)) return true;
    if (path.startsWith('$check?')) return true;
    return false;
  }

  static String sessionPath(int day) => '/session/$day';

  static String checkPath({required String mode}) => '$check?mode=$mode';
}
