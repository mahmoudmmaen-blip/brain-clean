import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const CLAUDE_API_KEY = Deno.env.get("CLAUDE_API_KEY")!;
const SYSTEM_PROMPT = `أنت صفا، مساعدة دعم نفسي في تطبيق Brain Clean. قواعدك: ١. أول رد: اعترف بالمشاعر بجملة واحدة حنينة زي "ده صعب فعلاً" أو "أنا فاهماكي" ٢. اسأل سؤال واحد بس عشان تفهم أكتر ٣. بعد ما تفهم: اقترح حاجة واحدة عملية من التطبيق (سكون / دفتر القلق / تنفس) ٤. كلامك بالعامية المصرية دايماً - مش فصحى مش خليجي مش مغربي ٥. مش أكتر من 3 جمل في كل رد ٦. لو حد بيقول كلام خطير قولي: "ده مهم - كلم حد قريب منك دلوقتي"`;

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  try {
    const { message } = await req.json();
    if (typeof message !== "string" || message.trim().length === 0) {
      return json({ reply: null, error: "message required" }, 400);
    }
    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": CLAUDE_API_KEY,
        "anthropic-version": "2023-06-01",
        "content-type": "application/json",
      },
      body: JSON.stringify({
        model: "claude-haiku-4-5",
        max_tokens: 300,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: message }],
      }),
    });
    if (!resp.ok) {
      console.error("CLAUDE_ERR", resp.status, await resp.text());
      return json({ reply: null }, 200);
    }
    const data = await resp.json();
    const reply = data?.content?.[0]?.text?.toString().trim() ?? null;
    return json({ reply }, 200);
  } catch (e) {
    console.error("SAFA_FN_ERR", e);
    return json({ reply: null }, 200);
  }
});
