/// Product-safety session bounds (Contract §6 / §7.4).
abstract final class SafaSessionLimit {
  static const maxUserMessages = 3;
  static const maxAssistantResponses = 3;
  static const maxInputCharacters = 500;
  static const maxResponseCharacters = 1200;
  static const edgeTimeout = Duration(seconds: 30);
}
