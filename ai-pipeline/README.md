# Brain Clean AI Pipeline

Machine-readable AI coach responses for Brain Clean / Pure Day. All model output must be **strict JSON** parseable by `JSON.parse()` with zero preprocessing.

## Architecture: Static vs Dynamic Layers

```
┌─────────────────────────────────────────────────────────────┐
│  STATIC LAYER (prompts.js → SYSTEM_PROMPT)                  │
│  • Role & tone rules                                        │
│  • JSON-only output contract                                │
│  • Completion vs Clarification decision boundary            │
│  • Schema for status "complete" | status "clarify"          │
│  • Immutable across requests                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  DYNAMIC LAYER (pipeline.js → buildDynamicLayer)            │
│  • userMessage — current user utterance                     │
│  • locale — ar | en (RTL/LTR hint)                          │
│  • bcScore, streakDays — live recovery metrics              │
│  • history — prior turns [{ role, content }]                │
│  • variables — intent-specific slots (lapseType, etc.)    │
│  • timestamp — ISO injection time                           │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    LLM / Coach Provider
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  PARSER (parser.js)                                         │
│  • JSON.parse(raw.trim()) ONLY — no regex, no fence strip   │
│  • validatePipelineResponse — schema guard                  │
└─────────────────────────────────────────────────────────────┘
```

| Layer | Source | Changes per request? |
|-------|--------|----------------------|
| **Static** | `SYSTEM_PROMPT` in `prompts.js` | No |
| **Dynamic** | `buildDynamicLayer(ctx)` in `pipeline.js` | Yes |

## Response schemas

### Completion (`status: "complete"`)

Use when intent is clear and required variables are present.

```json
{
  "status": "complete",
  "message": "Short coaching line for the user.",
  "context": {
    "intent": "focus_session",
    "action": "start_pomodoro",
    "assembledVariables": {
      "bcScore": 72,
      "locale": "en"
    }
  }
}
```

### Clarification (`status: "clarify"`)

Use when intent or required variables are missing.

```json
{
  "status": "clarify",
  "message": "Brief explanation of what is missing.",
  "questions": [
    "Targeted question 1?",
    "Targeted question 2?"
  ]
}
```

## API

```js
import {
  SYSTEM_PROMPT,
  assemblePipelinePrompt,
  processModelOutput,
  routingHint,
} from './ai-pipeline/index.js';

const { system, user } = assemblePipelinePrompt({
  userMessage: 'Start focus session',
  bcScore: 72,
  locale: 'en',
});

// After model returns `raw` string:
const decision = processModelOutput(raw);
```

## Pre-LLM routing hint

`routingHint(ctx)` mirrors the Completion/Clarification boundary for client-side guards (optional). It does **not** replace model output validation.

## Tests

```bash
npm run test:ai-pipeline
```

Tests assert:

- Native `JSON.parse()` succeeds on valid fixtures
- Markdown fences / preamble / trailing text **fail** parse (zero leakage)
- Completion and Clarification shapes validate end-to-end
