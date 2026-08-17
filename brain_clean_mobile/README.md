# Brain Clean — تطبيق تنقية الدماغ

## ما هو Brain Clean؟
تطبيق عربي لمكافحة إدمان الشاشات وتحسين صفاء الذهن،
مبني على أساس علمي (مؤشر BCI + وحدة القلق المزمن).

## المميزات الرئيسية
- مؤشر BCI (Brain Clean Index) — يقيس صفاء ذهنك يومياً
- مؤشر الهدوء (Calm Index) — يتابع تحسن القلق عبر الوقت
- صفا — مساعد ذكاء اصطناعي عربي مخصص
- اختبار القلق المزمن — 8 أسئلة + برنامج مخصص
- دفتر القلق + نافذة القلق — عادتان يوميتان علميتان
- 6 ثيمات بصرية (Midnight / Aurora / Pine / Solar / Slate / Daylight)
- تمارين تركيز، تنفس، ومهام يومية

## Tech Stack
Flutter · Riverpod · Supabase · RevenueCat · Claude (Edge) · Hive AES-256

## How to Run
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## BCI Formula
BCI = (60% × diagnostic score) + (40% × daily commitment score)
Calm Index = 100 − anxiety assessment score
