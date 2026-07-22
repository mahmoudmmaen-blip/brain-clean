import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const CLAUDE_API_KEY = Deno.env.get("CLAUDE_API_KEY")!;
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
        max_tokens: 150,
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
