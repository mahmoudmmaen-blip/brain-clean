/**
 * AI pipeline test suite — strict JSON.parse compliance (no regex cleaning).
 * Run: npm run test:ai-pipeline
 */

import assert from 'node:assert/strict';
import { test, describe } from 'node:test';

import {
  SYSTEM_PROMPT,
  parseAiResponse,
  parseAndValidateAiResponse,
  assemblePipelinePrompt,
  buildDynamicLayer,
  processModelOutput,
  routingHint,
} from '../ai-pipeline/index.js';

// ---------------------------------------------------------------------------
// Assertion helpers — native JSON.parse only
// ---------------------------------------------------------------------------

/**
 * @param {string} raw
 * @returns {import('../ai-pipeline/pipeline.js').PipelineResponse}
 */
function assertParsesStrictJson(raw) {
  assert.equal(typeof raw, 'string', 'fixture must be a string');
  const parsed = parseAiResponse(raw);
  assert.ok(parsed !== null && typeof parsed === 'object', 'must parse to object');
  return parseAndValidateAiResponse(raw);
}

function assertRejectsNonJson(raw) {
  assert.throws(() => parseAiResponse(raw), (err) => err instanceof SyntaxError);
}

function assertRejectsMarkdownWrappedJson(raw) {
  assert.throws(() => parseAiResponse(raw), (err) => {
    return err instanceof SyntaxError;
  }, 'markdown-wrapped JSON must not parse without cleaning');
}

// ---------------------------------------------------------------------------
// Fixtures — valid pipeline responses (JSON-only strings)
// ---------------------------------------------------------------------------

const COMPLETE_FIXTURE = JSON.stringify({
  status: 'complete',
  message: 'Start a 25-minute focus session now to protect your streak.',
  context: {
    intent: 'focus_session',
    action: 'start_pomodoro',
    assembledVariables: {
      bcScore: 72,
      streakDays: 4,
      locale: 'en',
    },
  },
});

const CLARIFY_FIXTURE = JSON.stringify({
  status: 'clarify',
  message: 'I need a bit more detail before recommending an action.',
  questions: [
    'Which type of setback are you logging: lapse (هفوة), slip (ذلة), or relapse (انتكاسة)?',
    'Did this happen today or on a prior date?',
  ],
});

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

describe('SYSTEM_PROMPT (Static Layer)', () => {
  test('includes strict JSON-only output rule', () => {
    assert.match(
      SYSTEM_PROMPT,
      /Return ONLY a valid JSON object/i,
    );
    assert.match(
      SYSTEM_PROMPT,
      /Failure to comply breaks the parser/i,
    );
    assert.match(SYSTEM_PROMPT, /Do NOT include any conversational filler/i);
  });

  test('defines Completion vs Clarification boundary', () => {
    assert.match(SYSTEM_PROMPT, /status "complete"/i);
    assert.match(SYSTEM_PROMPT, /status "clarify"/i);
    assert.match(SYSTEM_PROMPT, /DECISION BOUNDARY/i);
    assert.match(SYSTEM_PROMPT, /self-contained and ready for execution/i);
    assert.match(SYSTEM_PROMPT, /vital user intent or variables are missing/i);
  });
});

describe('parseAiResponse — strict JSON.parse (no regex cleaning)', () => {
  test('parses completion fixture natively', () => {
    const result = assertParsesStrictJson(COMPLETE_FIXTURE);
    assert.equal(result.status, 'complete');
  });

  test('parses clarification fixture natively', () => {
    const result = assertParsesStrictJson(CLARIFY_FIXTURE);
    assert.equal(result.status, 'clarify');
  });

  test('rejects markdown code-fence wrapping (parsing leakage)', () => {
    assertRejectsMarkdownWrappedJson('```json\n' + COMPLETE_FIXTURE + '\n```');
  });

  test('rejects conversational preamble (parsing leakage)', () => {
    assertRejectsNonJson('Here is your response:\n' + COMPLETE_FIXTURE);
  });

  test('rejects trailing commentary (parsing leakage)', () => {
    assertRejectsNonJson(COMPLETE_FIXTURE + '\n\nHope that helps!');
  });
});

describe('Completion scenario', () => {
  test('asserts status complete and context assembly', () => {
    const result = assertParsesStrictJson(COMPLETE_FIXTURE);
    assert.equal(result.status, 'complete');
    assert.equal(result.context.intent, 'focus_session');
    assert.equal(result.context.action, 'start_pomodoro');
    assert.equal(typeof result.context.assembledVariables.bcScore, 'number');
    assert.equal(result.context.assembledVariables.bcScore, 72);
    assert.equal(result.context.assembledVariables.locale, 'en');
    assert.ok(result.message.length > 0);
  });

  test('processModelOutput accepts completion via pipeline API', () => {
    const result = processModelOutput(COMPLETE_FIXTURE);
    assert.equal(result.status, 'complete');
    assert.deepEqual(result.context.assembledVariables.streakDays, 4);
  });

  test('routingHint returns complete for self-contained dynamic context', () => {
    const hint = routingHint({
      userMessage: 'Start a 25 minute focus session',
      bcScore: 72,
      streakDays: 4,
      locale: 'en',
    });
    assert.equal(hint, 'complete');
  });
});

describe('Clarification scenario', () => {
  test('asserts status clarify and targeting questions', () => {
    const result = assertParsesStrictJson(CLARIFY_FIXTURE);
    assert.equal(result.status, 'clarify');
    assert.ok(Array.isArray(result.questions));
    assert.ok(result.questions.length >= 1);
    for (const q of result.questions) {
      assert.ok(q.includes('?') || q.length > 10, `question should be targeted: ${q}`);
    }
    assert.ok(result.message.length > 0);
  });

  test('processModelOutput accepts clarification via pipeline API', () => {
    const result = processModelOutput(CLARIFY_FIXTURE);
    assert.equal(result.status, 'clarify');
    assert.equal(result.questions.length, 2);
  });

  test('routingHint returns clarify when lapse type is missing', () => {
    const hint = routingHint({
      userMessage: 'I had a lapse today',
      variables: {},
    });
    assert.equal(hint, 'clarify');
  });

  test('routingHint returns clarify for vague intent', () => {
    assert.equal(routingHint({ userMessage: 'help' }), 'clarify');
    assert.equal(routingHint({ userMessage: 'مساعدة' }), 'clarify');
  });
});

describe('Dynamic Layer assembly', () => {
  test('buildDynamicLayer injects user context as JSON', () => {
    const layer = buildDynamicLayer({
      userMessage: 'Log detox check-in',
      bcScore: 65,
      locale: 'ar',
      variables: { habit: 'boredom_befriended' },
    });
    const parsed = JSON.parse(layer);
    assert.equal(parsed.userMessage, 'Log detox check-in');
    assert.equal(parsed.bcScore, 65);
    assert.equal(parsed.locale, 'ar');
    assert.equal(parsed.variables.habit, 'boredom_befriended');
  });

  test('assemblePipelinePrompt combines static and dynamic layers', () => {
    const { system, user } = assemblePipelinePrompt({
      userMessage: 'How is my score?',
      bcScore: 80,
    });
    assert.ok(system.includes('Return ONLY a valid JSON object'));
    assert.ok(user.includes('DYNAMIC CONTEXT'));
    assert.ok(user.includes('"bcScore": 80'));
  });
});
