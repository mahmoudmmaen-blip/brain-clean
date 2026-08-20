export default {
  async fetch(request, env) {
    const cors = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: cors });
    }
    // Retired NVIDIA / unauthenticated Anthropic proxy.
    // All AI traffic must use JWT-gated Supabase Edge Function `safa-chat`.
    return new Response(
      JSON.stringify({
        error: 'gone',
        message: 'Use safa-chat Edge Function. Direct AI proxy is disabled.',
      }),
      {
        status: 410,
        headers: { 'Content-Type': 'application/json', ...cors },
      },
    );
  },
};
