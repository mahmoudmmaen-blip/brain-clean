/**
 * Brain Clean AI pipeline — assembles Static + Dynamic layers and validates output.
 * @module ai-pipeline/pipeline
 */

import { SYSTEM_PROMPT } from './prompts.js';
import { parseAndValidateAiResponse } from './parser.js';

/**
 * @typedef {Object} DynamicContext
 * @property {string} userMessage
 * @property {string} [locale] - e.g. "ar" | "en"
 * @property {number} [bcScore]
 * @property {number} [streakDays]
 * @property {Array<{role: string, content: string}>} [history]
 * @property {Record<string, unknown>} [variables]
 */

/**
 * @typedef {Object} CompleteResponse
 * @property {'complete'} status
 * @property {string} message
 * @property {{ intent: string, action: string, assembledVariables: Record<string, unknown> }} context
 */

/**
 * @typedef {Object} ClarifyResponse
 * @property {'clarify'} status
 * @property {string} message
 * @property {string[]} questions
 */

/** @typedef {CompleteResponse | ClarifyResponse} PipelineResponse */

/**
 * Static Layer — system instructions (immutable).
 * @returns {string}
 */
export function getStaticLayer() {
  return SYSTEM_PROMPT;
}

/**
 * Dynamic Layer — per-request user context, history, and live variables.
 * @param {DynamicContext} ctx
 * @returns {string} JSON string injected after the static prompt.
 */
export function buildDynamicLayer(ctx) {
  const payload = {
    userMessage: ctx.userMessage,
    locale: ctx.locale ?? 'ar',
    bcScore: ctx.bcScore ?? null,
    streakDays: ctx.streakDays ?? null,
    history: ctx.history ?? [],
    variables: ctx.variables ?? {},
    timestamp: new Date().toISOString(),
  };
  return JSON.stringify(payload, null, 2);
}

/**
 * Full prompt sent to the model: Static Layer + Dynamic Layer.
 * @param {DynamicContext} ctx
 * @returns {{ system: string, user: string }}
 */
export function assemblePipelinePrompt(ctx) {
  return {
    system: getStaticLayer(),
    user: [
      '## DYNAMIC CONTEXT (injected — do not echo verbatim unless needed)',
      buildDynamicLayer(ctx),
      '',
      'Respond with ONLY the JSON object per the system instructions.',
    ].join('\n'),
  };
}

/**
 * Processes a raw model string through strict parse + schema validation.
 * @param {string} rawModelOutput
 * @returns {PipelineResponse}
 */
export function processModelOutput(rawModelOutput) {
  return parseAndValidateAiResponse(rawModelOutput);
}

/**
 * Determines whether dynamic context has enough signal for Completion (pre-LLM guard).
 * @param {DynamicContext} ctx
 * @returns {'complete' | 'clarify'}
 */
export function routingHint(ctx) {
  const msg = (ctx.userMessage ?? '').trim();
  if (!msg) return 'clarify';

  const vague = /^(help|مساعدة|what should i do|ماذا أفعل)\.?$/i.test(msg);
  if (vague) return 'clarify';

  if (/lapse|هفوة|slip|ذلة|relapse|انتكاس/i.test(msg) && !ctx.variables?.lapseType) {
    return 'clarify';
  }

  if (/score|نقاط|bc_score/i.test(msg) && ctx.bcScore == null) {
    return 'clarify';
  }

  return 'complete';
}
