/// BCS bonus from focused-thinking focus-check score (0–1).
double focusedThinkingBcsBonus(double focusCheckScore) {
  if (focusCheckScore >= 0.8) return 15;
  if (focusCheckScore >= 0.6) return 10;
  if (focusCheckScore >= 0.4) return 5;
  return 2;
}

/// Arabic thinking-guide prompts (rotate every 60s).
const List<String> thinkingPromptsAr = [
  'ما أول خطوة عملية يمكنك فعلها؟',
  'ما العقبة الرئيسية أمامك؟',
  'كيف ستبدو الصورة بعد 5 سنوات؟',
  'ما الذي تخشاه في هذا الموضوع؟',
  'ما الموارد التي تحتاجها؟',
];

/// English thinking-guide prompts.
const List<String> thinkingPromptsEn = [
  "What's the first practical step you can take?",
  'What is the main obstacle in your way?',
  'What will this look like in 5 years?',
  'What do you fear about this topic?',
  'What resources do you need?',
];

List<String> thinkingPromptsForLocale(bool isArabic) =>
    isArabic ? thinkingPromptsAr : thinkingPromptsEn;

/// Suggested topic chips (last entry is custom placeholder).
const List<String> suggestedTopicsAr = [
  'هدفي الكبير',
  'مشكلة أريد حلها',
  'شخص أقدّره',
  'مهارة أريد تطويرها',
  'قرار أفكر فيه',
  'اكتب موضوعك...',
];

const List<String> suggestedTopicsEn = [
  'My big goal',
  'A problem to solve',
  'Someone I appreciate',
  'A skill to develop',
  "A decision I'm considering",
  'Write your own...',
];

List<String> suggestedTopicsForLocale(bool isArabic) =>
    isArabic ? suggestedTopicsAr : suggestedTopicsEn;

/// Duration options in minutes.
const List<int> focusedThinkingDurations = [5, 10, 15, 20];

/// Focus-check interval in seconds.
const int focusCheckIntervalSeconds = 180;

/// Prompt rotation interval in seconds.
const int thinkingPromptIntervalSeconds = 60;
