import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const CLAUDE_API_KEY = Deno.env.get("CLAUDE_API_KEY")!;
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;

/// Comma-separated browser origins allowed to call this function.
const ALLOWED_ORIGINS = (Deno.env.get("ALLOWED_ORIGINS") ?? "")
  .split(",")
  .map((o) => o.trim())
  .filter((o) => o.length > 0);

const MAX_MESSAGE_LENGTH = 2000;
const SYSTEM_PROMPT = `أنت صفا، مساعدة دعم نفسي في تطبيق Brain Clean. اتبعي القواعد دي بالترتيب:

١. أول رد: اعترفي بالمشاعر بجملة واحدة حقيقية ومحددة تعكس تفاصيل الموقف اللي قاله المستخدم فعلاً — مش جملة عامة زي "ده صعب" فقط، لازم تربطيها بموضوعه تحديداً (مثال: خناقة مع زميل ≠ نفس رد التوتر من الشغل).

٢. اسألي سؤال واحد بس، يكون سؤال يوسّع فهمك لسياق الموقف تحديداً (مين، إيه اللي حصل بالظبط، امتى بدأ)، مش سؤال عام.

٣. اقترحي حاجة عملية واحدة بس، تختاريها حسب نوع الموقف مش بترتيب ثابت:
   - لو الموضوع توتر جسدي/فسيولوجي لحظي (خفقان، اختناق، توتر عضلي) → اقترحي تمرين تنفس محدد بخطوات واضحة
   - لو الموضوع علاقة مع شخص (خناقة، سوء فهم، غضب من حد) → اقترحي إنه يكتب اللي حاسس بيه في دفتر القلق قبل ما يتصرف، أو يفكر في جملة واحدة يقولها للطرف التاني بعد ما يهدأ
   - لو الموضوع قلق مستمر أو تفكير زايد (overthinking) → اقترحي نافذة القلق (تحديد وقت محدد للتفكير في الموضوع بدل ما يفكر فيه طول اليوم)
   - لو الموضوع إرهاق ذهني عام أو تشتت → اقترحي جلسة سكون
   لازم يكون الاقتراح مربوط بكلمة أو تفصيلة قالها المستخدم فعلاً، مش نصيحة عامة تصلح لأي حد.

٤. كلامك بالعامية المصرية دايماً - مش فصحى مش خليجي مش مغربي.

٥. الرد كله ماكسيموم 3 جمل قصيرة، من غير فقرات منفصلة ولا سطور جديدة.

٦. لو حد بيقول كلام خطير (إيذاء نفس، أذى لحد تاني) قولي: "ده مهم - كلم حد قريب منك دلوقتي" وبس، من غير أي اقتراح تاني.`;

function corsHeaders(req: Request): Record<string, string> {
  const origin = req.headers.get("Origin");
  const headers: Record<string, string> = {
    "Access-Control-Allow-Headers":
      "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    "Vary": "Origin",
  };
  if (origin && ALLOWED_ORIGINS.includes(origin)) {
    headers["Access-Control-Allow-Origin"] = origin;
  }
  return headers;
}

function json(req: Request, body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders(req), "content-type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders(req) });
  }
  if (req.method !== "POST") {
    return json(req, { reply: null, error: "method not allowed" }, 405);
  }
  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader?.startsWith("Bearer ")) {
      return json(req, { reply: null, error: "unauthorized" }, 401);
    }
    const userClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
      global: { headers: { Authorization: authHeader } },
    });
    const { data: userData, error: userError } = await userClient.auth.getUser();
    if (userError || !userData?.user) {
      return json(req, { reply: null, error: "unauthorized" }, 401);
    }

    const { message } = await req.json();
    if (typeof message !== "string" || message.trim().length === 0) {
      return json(req, { reply: null, error: "message required" }, 400);
    }
    if (message.length > MAX_MESSAGE_LENGTH) {
      return json(req, { reply: null, error: "message too long" }, 413);
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
        max_tokens: 150,
        system: SYSTEM_PROMPT,
        messages: [{ role: "user", content: message }],
      }),
    });
    if (!resp.ok) {
      console.error("CLAUDE_ERR", resp.status);
      return json(req, { reply: null }, 200);
    }
    const data = await resp.json();
    const reply = data?.content?.[0]?.text?.toString().trim() ?? null;
    return json(req, { reply }, 200);
  } catch (e) {
    console.error("SAFA_FN_ERR", e instanceof Error ? e.name : "unknown");
    return json(req, { reply: null }, 200);
  }
});
