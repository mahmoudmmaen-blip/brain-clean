"""
Cursor Cloud Agent Automation Script
=====================================
سكريبت مجاني بالكامل - بيبعت Prompt لـ Cursor Cloud Agent،
يستنى لحد ما يخلص، ويرجعلك رابط الـ Pull Request النهائي.

الإعداد المطلوب (مرة واحدة بس):
1. روح https://cursor.com/settings واعمل API Key
2. حط الـ API Key في المتغير CURSOR_API_KEY تحت (أو كـ Environment Variable)
3. تأكد إن الـ Repo بتاعك مربوط بـ GitHub وCursor عنده صلاحية عليه

التشغيل:
    python cursor_automation.py "الـ Prompt اللي عايز تبعته"
"""

import requests
import time
import sys
import os

# ============ الإعدادات ============
CURSOR_API_KEY = os.environ.get("CURSOR_API_KEY", "ضع_الـ_API_KEY_هنا")
GITHUB_REPO_URL = os.environ.get("GITHUB_REPO_URL", "https://github.com/your-org/your-repo")
BASE_BRANCH = "main"  # أو "master" حسب المشروع بتاعك

BASE_URL = "https://api.cursor.com/v0"
HEADERS = {
    "Authorization": f"Bearer {CURSOR_API_KEY}",
    "Content-Type": "application/json"
}

# كل قد ايه (بالثانية) نتأكد من حالة الـ Agent
POLL_INTERVAL = 20
# أقصى وقت انتظار (بالدقايق) قبل ما نوقف
MAX_WAIT_MINUTES = 60


def create_agent(prompt: str) -> dict:
    """يبعت الـ Prompt لـ Cursor ويبدأ Agent جديد في الخلفية"""
    payload = {
        "prompt": {"text": prompt},
        "source": {"repository": GITHUB_REPO_URL, "ref": BASE_BRANCH},
        "target": {"autoCreatePr": True}  # يعمل PR أوتوماتيك لما يخلص
    }
    resp = requests.post(f"{BASE_URL}/agents", headers=HEADERS, json=payload)
    if not resp.ok:
        print("\n❌ رد السيرفر بالتفصيل:")
        print(f"Status Code: {resp.status_code}")
        print(f"Response Body: {resp.text}")
        print(f"Payload اللي اتبعت: {payload}\n")
    resp.raise_for_status()
    return resp.json()


def get_agent_status(agent_id: str) -> dict:
    """يستعلم عن حالة الـ Agent الحالية"""
    resp = requests.get(f"{BASE_URL}/agents/{agent_id}", headers=HEADERS)
    if not resp.ok:
        print(f"\n❌ فشل الاستعلام: {resp.status_code} - {resp.text}\n")
    resp.raise_for_status()
    return resp.json()


def wait_for_completion(agent_id: str) -> dict:
    """يفضل يسأل كل شوية لحد ما الـ Agent يخلص أو الوقت يخلص"""
    elapsed = 0
    max_seconds = MAX_WAIT_MINUTES * 60

    while elapsed < max_seconds:
        status = get_agent_status(agent_id)
        state = status.get("status", "UNKNOWN")
        print(f"[{elapsed // 60} min] الحالة: {state}")

        if state in ("FINISHED", "COMPLETED", "DONE"):
            return status
        if state in ("FAILED", "ERROR", "CANCELLED"):
            raise RuntimeError(f"الـ Agent فشل. الحالة: {state}")

        time.sleep(POLL_INTERVAL)
        elapsed += POLL_INTERVAL

    raise TimeoutError("خلص الوقت المسموح من غير ما الـ Agent يخلص")


def main():
    if len(sys.argv) < 2:
        print("الاستخدام: python cursor_automation.py \"الـ Prompt بتاعك\"")
        sys.exit(1)

    prompt = sys.argv[1]

    if CURSOR_API_KEY == "ضع_الـ_API_KEY_هنا":
        print("⚠️  لازم تحط الـ API Key بتاعك الأول في المتغير CURSOR_API_KEY")
        sys.exit(1)

    print("🚀 بعت الـ Prompt لـ Cursor Cloud Agent...")
    result = create_agent(prompt)
    agent_id = result["id"]
    print(f"✅ اتبعت. Agent ID: {agent_id}")
    print(f"🔗 تقدر تتابعه من: {result.get('target', {}).get('url', 'غير متاح')}")

    print("\n⏳ مستني الـ Agent يخلص شغله...")
    final = wait_for_completion(agent_id)

    print("\n🎉 خلص! النتيجة:")
    print(final)


if __name__ == "__main__":
    main()
