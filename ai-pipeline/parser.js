/**
 * Strict JSON parsing — no regex extraction or markdown stripping.
 * @module ai-pipeline/parser
 */

/**
 * Parses an AI response with native `JSON.parse` only.
 * @param {string} raw - Raw model output (must be JSON only).
 * @returns {unknown} Parsed value.
 * @throws {SyntaxError} If the payload is not valid JSON.
 * @throws {TypeError} If raw is not a string.
 */
export function parseAiResponse(raw) {
  if (typeof raw !== 'string') {
    throw new TypeError('AI response must be a string');
  }
  return JSON.parse(raw.trim());
}

/**
 * @param {unknown} value
 * @returns {value is Record<string, unknown>}
 */
function isObject(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

/**
 * Validates pipeline JSON shape after parse.
 * @param {unknown} parsed
 * @returns {import('./pipeline.js').PipelineResponse}
 */
export function validatePipelineResponse(parsed) {
  if (!isObject(parsed)) {
    throw new Error('Response must be a JSON object');
  }

  const status = parsed.status;
  if (status !== 'complete' && status !== 'clarify') {
    throw new Error(`Invalid status: ${String(status)}`);
  }

  if (typeof parsed.message !== 'string' || parsed.message.trim() === '') {
    throw new Error('Missing or empty "message"');
  }

  if (status === 'complete') {
    if (!isObject(parsed.context)) {
      throw new Error('Completion requires "context" object');
    }
    const { intent, action, assembledVariables } = parsed.context;
    if (typeof intent !== 'string' || intent.trim() === '') {
      throw new Error('Completion requires context.intent');
    }
    if (typeof action !== 'string' || action.trim() === '') {
      throw new Error('Completion requires context.action');
    }
    if (!isObject(assembledVariables)) {
      throw new Error('Completion requires context.assembledVariables object');
    }
    return /** @type {import('./pipeline.js').CompleteResponse} */ (parsed);
  }

  if (!Array.isArray(parsed.questions) || parsed.questions.length === 0) {
    throw new Error('Clarification requires non-empty "questions" array');
  }
  for (const q of parsed.questions) {
    if (typeof q !== 'string' || q.trim() === '') {
      throw new Error('Each question must be a non-empty string');
    }
  }
  return /** @type {import('./pipeline.js').ClarifyResponse} */ (parsed);
}

/**
 * Parse + validate in one step (strict, no cleaning).
 * @param {string} raw
 * @returns {import('./pipeline.js').PipelineResponse}
 */
export function parseAndValidateAiResponse(raw) {
  return validatePipelineResponse(parseAiResponse(raw));
}
