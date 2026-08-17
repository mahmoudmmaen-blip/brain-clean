const ALLOWED_MODELS = new Set(['claude-haiku-4-5', 'claude-3-5-haiku-latest']);
const MAX_BODY_BYTES = 16 * 1024;
const MAX_OUTPUT_TOKENS = 300;

function allowedOrigins(env) {
  return (env.ALLOWED_ORIGINS ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter(Boolean);
}

function corsHeaders(request, env) {
  const origin = request.headers.get('Origin');
  const allowed = allowedOrigins(env);
  const headers = {
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    Vary: 'Origin',
  };
  if (origin && allowed.includes(origin)) {
    headers['Access-Control-Allow-Origin'] = origin;
  }
  return headers;
}

function json(body, status, headers) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json', ...headers },
  });
}

/** Constant-time-ish comparison to avoid leaking the token via timing. */
function tokenMatches(provided, expected) {
  if (!provided || !expected || provided.length !== expected.length) return false;
  let diff = 0;
  for (let i = 0; i < provided.length; i++) {
    diff |= provided.charCodeAt(i) ^ expected.charCodeAt(i);
  }
  return diff === 0;
}

/** Rebuilds the upstream payload from an allowlist — clients cannot pass arbitrary fields. */
function sanitizeBody(body) {
  if (typeof body !== 'object' || body === null) return null;
  const model = typeof body.model === 'string' ? body.model : 'claude-haiku-4-5';
  if (!ALLOWED_MODELS.has(model)) return null;

  if (!Array.isArray(body.messages) || body.messages.length === 0) return null;
  if (body.messages.length > 20) return null;
  const messages = [];
  for (const m of body.messages) {
    if (!m || (m.role !== 'user' && m.role !== 'assistant')) return null;
    if (typeof m.content !== 'string' || m.content.trim().length === 0) return null;
    if (m.content.length > 4000) return null;
    messages.push({ role: m.role, content: m.content });
  }

  const requested = Number(body.max_tokens);
  const maxTokens = Number.isInteger(requested) && requested > 0
    ? Math.min(requested, MAX_OUTPUT_TOKENS)
    : MAX_OUTPUT_TOKENS;

  const payload = { model, max_tokens: maxTokens, messages };
  if (typeof body.system === 'string' && body.system.length <= 4000) {
    payload.system = body.system;
  }
  return payload;
}

export default {
  async fetch(request, env) {
    const cors = corsHeaders(request, env);
    if (request.method === 'OPTIONS') return new Response(null, { headers: cors });
    if (request.method !== 'POST') {
      return json({ error: 'Method Not Allowed' }, 405, cors);
    }
    if (!env.ANTHROPIC_API_KEY || !env.PROXY_AUTH_TOKEN) {
      return json({ error: 'Proxy not configured' }, 503, cors);
    }

    const auth = request.headers.get('Authorization') ?? '';
    if (!tokenMatches(auth.replace(/^Bearer\s+/i, ''), env.PROXY_AUTH_TOKEN)) {
      return json({ error: 'Unauthorized' }, 401, cors);
    }

    const raw = await request.text();
    if (raw.length > MAX_BODY_BYTES) {
      return json({ error: 'Payload too large' }, 413, cors);
    }

    let parsed;
    try {
      parsed = JSON.parse(raw);
    } catch {
      return json({ error: 'Invalid JSON' }, 400, cors);
    }

    const payload = sanitizeBody(parsed);
    if (!payload) return json({ error: 'Invalid request' }, 400, cors);

    try {
      const res = await fetch('https://api.anthropic.com/v1/messages', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': env.ANTHROPIC_API_KEY,
          'anthropic-version': '2023-06-01',
        },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      return json(data, res.status, cors);
    } catch {
      // Upstream details are never echoed back to the client.
      return json({ error: 'Upstream request failed' }, 502, cors);
    }
  },
};
