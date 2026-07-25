# Brain Clean — Privacy Policy

**Last updated:** 25 July 2026  
**Contact:** brainclean.app@gmail.com

This page is the public privacy policy for the Brain Clean Android app (`com.brainclean.mobile`).  
It is intended for Google Play and website hosting (for example GitHub Pages).

---

## English

### 1. Who we are

Brain Clean (“we”, “the app”) is a **digital wellbeing** and **daily routine** app that helps users with focus, mood awareness, and recovery-oriented habits.

Brain Clean is **not** a medical device and does **not** provide medical diagnosis, treatment, or a cure for any condition.

### 2. What this policy covers

How we handle information when you use Brain Clean on Android.

### 3. Information stored on your device

Most information stays on your phone. Depending on how you use the app, this may include:

- Daily Program progress and related routine data  
- Recovery / habit check-ins  
- Worry journal and similar free-text notes  
- Emotion history  
- Diagnostic drafts and related scores  
- Reminder preferences  
- XP / progress ledger data  
- Optional biometric app-lock preference  

Worry journal and similar free-text notes are designed to remain **local on your device** in v1.

Local durable storage may be encrypted on device where the app implements secure storage.

### 4. Account and cloud features (when enabled in a production build)

If a production build is configured with cloud credentials, the app may:

- Create an **anonymous** account (a random user ID; the app does not ask for email/password for this flow)  
- Sync selected progress-related data for backup / app functionality  

Cloud features are **optional at build configuration time**. Builds without valid cloud configuration continue in offline / local-first mode.

When cloud sync is enabled and you are signed in anonymously, the app may sync data such as:

- Anonymous user ID  
- Daily score / progress snapshots  
- Emotion labels and categories you confirm  
- Diagnostic questionnaire answers and related scores  
- Detox / check-in flags  
- XP event metadata used for verification  

### 5. In-app AI helpers (when cloud is enabled)

If you use optional AI features (for example Safa / Emotion Oasis chat) in a cloud-enabled production build, the message text you send may be processed through our backend (Supabase Edge Functions) and AI providers solely to generate a reply.

### 6. Purchases (when enabled in a production build)

If Pro / billing is enabled in a production build, purchases are handled by **Google Play Billing** and **RevenueCat**.

We do **not** store your full payment card details in the Brain Clean app.

### 7. What we do **not** collect in v1

- **No advertising SDKs** in the current build — this app does **not** contain ads.  
- **No** Android Usage Access / installed-app usage / social-app usage-time collection in v1.  
- **No** collection of your name, email, or phone number through the anonymous auth flow described above.

### 8. Notifications

Reminders in this build are **local notifications** (scheduled on your device). They are not Firebase Cloud Messaging push in the current codebase.

Notification content is generally fixed app copy (for example reminder text), not your private journal entries.

### 9. Biometrics

Optional app lock may use your device biometric or screen-lock APIs (`local_auth`).

Biometric templates stay on your device. Brain Clean does not upload fingerprint or face data.

### 10. How we use information

We use information to:

- Provide digital wellbeing and daily routine features  
- Keep local progress working offline  
- Optionally back up / sync selected data when cloud is enabled  
- Verify XP events when cloud verification is enabled  
- Process Pro entitlements when billing is enabled  
- Generate AI replies only when you use those features  

### 11. Sharing

We do **not sell** your personal information.

When cloud or billing is enabled in a production build, we use service providers needed to run the app, such as:

- **Supabase** (authentication, database, Edge Functions)  
- **AI providers** reached via our Edge Functions when you use AI chat features  
- **RevenueCat** and **Google Play** for purchases / entitlements  

These parties process data as needed to provide those services — not for selling your data.

### 12. Security

- Data sent over the network uses **HTTPS** (encrypted in transit).  
- Local durable app data may be stored with encryption where implemented.  

No method of transmission or storage is 100% secure.

### 13. Retention and deletion requests

- **Local data** is typically removed when you clear app storage or uninstall the app.  
- **Cloud data** (when cloud was enabled): email **brainclean.app@gmail.com** and request deletion of your anonymous account / associated server records.  

We will delete or anonymize associated server-side records within a reasonable period, subject to legal obligations and technical constraints.

Please include enough detail for us to identify the relevant anonymous account where possible (for example approximate install date or other non-sensitive context you can share).

### 14. Children

Brain Clean is not directed at children under 13 (or under the higher age required in your country). Do not use the app if you are under the applicable age.

### 15. International users

If you use cloud features, your information may be processed on servers in regions used by our service providers.

### 16. Changes to this policy

We may update this policy. The “Last updated” date at the top will change when we do.

### 17. Contact

For privacy questions or deletion requests: **brainclean.app@gmail.com**

---

## العربية

### 1. من نحن

Brain Clean («نحن»، «التطبيق») تطبيق لـ**العافية الرقمية** و**الروتين اليومي** يساعد على التركيز والوعي بالمزاج وعادات التعافي.

Brain Clean **ليس** جهازًا طبيًا، و**لا** يقدّم تشخيصًا طبيًا، ولا علاجًا، ولا ادّعاء شفاء لأي حالة.

### 2. نطاق هذه السياسة

توضّح كيف نتعامل مع المعلومات عند استخدام Brain Clean على Android.

### 3. البيانات المخزَّنة على جهازك

معظم البيانات تبقى على هاتفك، وقد تشمل حسب استخدامك:

- تقدّم البرنامج اليومي والبيانات المرتبطة  
- تتبّع التعافي / العادات  
- دفتر القلق والملاحظات النصية المشابهة  
- سجل المشاعر  
- مسودات التشخيص والدرجات المرتبطة  
- إعدادات التذكير  
- بيانات نقاط XP / التقدّم  
- تفضيل قفل التطبيق بالقياسات الحيوية (اختياري)  

نصوص دفتر القلق والملاحظات الحرة مصمّمة لتبقى **محلية على جهازك** في الإصدار v1.

قد يُشفَّر التخزين المحلي الدائم حيث يطبّق التطبيق التخزين الآمن.

### 4. الحساب والميزات السحابية (عند تفعيلها في نسخة الإنتاج)

إذا تم ضبط نسخة الإنتاج بإعدادات سحابية صالحة، قد يقوم التطبيق بـ:

- إنشاء حساب **مجهول** (معرّف مستخدم عشوائي؛ التطبيق لا يطلب بريدًا/كلمة مرور في هذا المسار)  
- مزامنة بيانات تقدّم محددة للنسخ الاحتياطي / وظائف التطبيق  

الميزات السحابية **اختيارية على مستوى إعداد البناء**. النسخ بدون إعداد سحابي صالح تستمر بوضع محلي / دون اتصال.

عند تفعيل المزامنة ووجود جلسة مجهولة، قد تُزامَن بيانات مثل:

- معرّف مستخدم مجهول  
- لقطات الدرجة / التقدّم اليومي  
- تصنيفات المشاعر التي تؤكدها  
- إجابات استبيان التشخيص والدرجات المرتبطة  
- علامات التحقق من التخلّص (Detox)  
- بيانات أحداث XP للتحقق  

### 5. المساعدات الذكية داخل التطبيق (عند تفعيل السحابة)

إذا استخدمت ميزات الذكاء الاصطناعي الاختيارية (مثل صفا / دردشة واحة المشاعر) في نسخة إنتاج مفعَّلة سحابيًا، قد تُعالَج نصوص الرسائل التي ترسلها عبر خوادمنا (Supabase Edge Functions) ومزوّدي الذكاء الاصطناعي فقط لإنشاء الرد.

### 6. المشتريات (عند تفعيلها في نسخة الإنتاج)

إذا كان Pro / الفوترة مفعّلين في نسخة الإنتاج، تتم المشتريات عبر **Google Play Billing** و**RevenueCat**.

نحن **لا** نخزّن بيانات بطاقتك الكاملة داخل تطبيق Brain Clean.

### 7. ما لا نجمعه في v1

- **لا** توجد حزم إعلانات في البناء الحالي — التطبيق **لا** يحتوي على إعلانات.  
- **لا** جمع لإحصاءات استخدام التطبيقات / صلاحية Usage Access / وقت تطبيقات التواصل في v1.  
- **لا** جمع لاسمك أو بريدك أو رقم هاتفك عبر مسار المصادقة المجهولة الموضّح أعلاه.

### 8. الإشعارات

التذكيرات في هذا البناء **إشعارات محلية** (تُجدوَل على جهازك)، وليست رسائل Firebase Cloud Messaging في الكود الحالي.

محتوى الإشعار عادةً نصوص ثابتة من التطبيق، وليس محتويات مذكراتك الخاصة.

### 9. القياسات الحيوية

قد يستخدم قفل التطبيق الاختياري واجهات الجهاز للقياسات الحيوية أو قفل الشاشة.

قوالب القياسات الحيوية تبقى على جهازك. Brain Clean لا يرفع بيانات البصمة أو الوجه.

### 10. كيف نستخدم المعلومات

نستخدم المعلومات من أجل:

- تقديم ميزات العافية الرقمية والروتين اليومي  
- استمرار التقدّم المحلي دون اتصال  
- النسخ الاحتياطي / المزامنة الاختيارية عند تفعيل السحابة  
- التحقق من أحداث XP عند تفعيل التحقق السحابي  
- معالجة صلاحيات Pro عند تفعيل الفوترة  
- إنشاء ردود الذكاء الاصطناعي فقط عند استخدامك لهذه الميزات  

### 11. المشاركة

نحن **لا نبيع** معلوماتك الشخصية.

عند تفعيل السحابة أو الفوترة في نسخة الإنتاج، نستخدم مزوّدي خدمة ضروريين لتشغيل التطبيق، مثل:

- **Supabase** (المصادقة، قاعدة البيانات، Edge Functions)  
- **مزوّدو الذكاء الاصطناعي** عبر Edge Functions عند استخدام الدردشة الذكية  
- **RevenueCat** و**Google Play** للمشتريات / الصلاحيات  

يعالج هؤلاء الأطراف البيانات بالقدر اللازم لتقديم الخدمة — وليس لبيع بياناتك.

### 12. الأمان

- البيانات عبر الشبكة تستخدم **HTTPS** (تشفير أثناء النقل).  
- قد تُشفَّر بيانات التطبيق المحلية الدائمة حيث يُنفَّذ ذلك.  

لا توجد طريقة نقل أو تخزين آمنة بنسبة 100%.

### 13. الاحتفاظ وطلب الحذف

- **البيانات المحلية** تُزال عادةً عند مسح بيانات التطبيق أو إلغاء التثبيت.  
- **البيانات السحابية** (إن وُجدت): راسل **brainclean.app@gmail.com** واطلب حذف حسابك المجهول / السجلات المرتبطة على الخادم.  

سنحذف أو نُجهّل السجلات المرتبطة على الخادم خلال مدة معقولة، مع مراعاة الالتزامات القانونية والقيود التقنية.

يُفضَّل تضمين تفاصيل تساعد على تحديد الحساب المجهول عند الإمكان (مثل تاريخ تقريبي للتثبيت أو سياق غير حسّاس يمكنك مشاركته).

### 14. الأطفال

التطبيق غير موجّه لمن هم دون 13 عامًا (أو دون السن الأعلى المطلوب في بلدك). لا تستخدم التطبيق إن كنت دون السن المعمول به.

### 15. المستخدمون الدوليون

عند استخدام الميزات السحابية، قد تُعالَج معلوماتك على خوادم في مناطق يستخدمها مزوّدو الخدمة.

### 16. تغييرات السياسة

قد نحدّث هذه السياسة. سيتغيّر تاريخ «آخر تحديث» في الأعلى عند ذلك.

### 17. التواصل

لأسئلة الخصوصية أو طلبات الحذف: **brainclean.app@gmail.com**
