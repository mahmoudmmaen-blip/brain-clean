/**
 * safa-chat — Claude proxy. Provider keys never leave this function.
 * There is no third-party GPU-cloud AI path.
 * CLAUDE_API_KEY is a Supabase secret only (rotate in Dashboard → Secrets).
 */
import {
  corsHeaders,
  jsonResponse,
  requireAuthenticatedUser,
} from "../_shared/jwt.ts";

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

const MAX_MESSAGE_CHARS = 500;
const RATE_WINDOW_MS = 10 * 60 * 1000;
const RATE_MAX = 20;
const hits = new Map<string, number[]>();

const ALLOWED_BODY_KEYS = new Set([
  "message",
  "locale",
  "origin",
  "contextCategory",
  "approvedContextSummary",
  "approvedStepTitle",
  "sessionToken",
]);

function rateLimited(userId: string): boolean {
  const now = Date.now();
  const prior = (hits.get(userId) ?? []).filter((t) => now - t < RATE_WINDOW_MS);
  if (prior.length >= RATE_MAX) {
    hits.set(userId, prior);
    return true;
  }
  prior.push(now);
  hits.set(userId, prior);
  return false;
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    const caller = await requireAuthenticatedUser(req);
    if (caller instanceof Response) return caller;

    const claudeKey = Deno.env.get("CLAUDE_API_KEY") ?? "";
    if (!claudeKey) {
      console.error("SAFA_FN_ERR missing CLAUDE_API_KEY");
      return jsonResponse({ reply: null }, 200);
    }

    if (rateLimited(caller.userId)) {
      return jsonResponse({ error: "Rate limited" }, 429);
    }

    const raw: unknown = await req.json();
    if (raw == null || typeof raw !== "object" || Array.isArray(raw)) {
      return jsonResponse({ reply: null, error: "message required" }, 400);
    }
    const body = raw as Record<string, unknown>;
    for (const key of Object.keys(body)) {
      if (!ALLOWED_BODY_KEYS.has(key)) {
        return jsonResponse({ error: "Invalid payload" }, 400);
      }
    }

    const message = typeof body.message === "string" ? body.message.trim() : "";
    if (!message || message.length > MAX_MESSAGE_CHARS) {
      return jsonResponse({ reply: null, error: "message required" }, 400);
    }

    const resp = await fetch("https://api.anthropic.com/v1/messages", {
      method: "POST",
      headers: {
        "x-api-key": claudeKey,
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
      return jsonResponse({ reply: null }, 200);
    }
    const data = await resp.json();
    const reply = data?.content?.[0]?.text?.toString().trim() ?? null;
    return jsonResponse({ reply }, 200);
  } catch (e) {
    console.error("SAFA_FN_ERR");
    return jsonResponse({ reply: null }, 200);
  }
});
