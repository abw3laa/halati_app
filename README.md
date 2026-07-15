# حالاتي (Halati) — Flutter Android App

تنفيذ Flutter كامل لتصاميم Stitch المرفقة (9 شاشات): التحديثات، عارض الحالة
(Story Viewer)، تنزيل، تحميلاتي، الإعدادات (بقسميها)، وحول التطبيق — بنفس
نظام الألوان والخطوط (Cairo) وM3 الوارد في `DESIGN.md`.

## هيكل المشروع

```
lib/
  main.dart                     نقطة الدخول + الثيمات + التوجيه
  theme/app_theme.dart          ألوان/أشكال DESIGN.md كثيم Material 3
  l10n/app_localization.dart    ترجمة عربي/إنجليزي/تركي + RTL/LTR تلقائي
  models/                       StatusItem, DownloadItem
  services/
    settings_service.dart       الإعدادات (SharedPreferences)
    status_service.dart         اكتشاف/حفظ حالات واتساب (SAF + مسار مباشر)
    download_service.dart       تنزيل روابط الوسائط المباشرة
  widgets/                      BottomNavBar, StatusRing
  screens/                      الشاشات التسع المطابقة للتصاميم
```

## خطوات التشغيل

1. تثبيت Flutter 3.22+ و Android SDK.
2. لأن هذا المستودع يحتوي فقط على `lib/` وملف Manifest، أنشئ سقالة أندرويد
   الكاملة أولاً (لا تحذف مجلد `lib/` الموجود):
   ```bash
   flutter create --platforms=android --org com.abwaalaa .
   ```
3. ادمج الأذونات من `android/app/src/main/AndroidManifest.xml` المرفق مع
   الملف الذي أنشأه الأمر أعلاه (خصوصاً أذونات التخزين والوسائط).
4. ثبّت الحزم:
   ```bash
   flutter pub get
   ```
5. شغّل التطبيق على جهاز/محاكي:
   ```bash
   flutter run
   ```

## ملاحظات تقنية مهمة

- **الوصول لحالات واتساب**: على أندرويد 11+ (Scoped Storage) لا يمكن لأي
  تطبيق قراءة مجلد `.Statuses` الخاص بواتساب مباشرة إلا عبر إطار الوصول
  للتخزين (SAF) — لهذا شاشة "التحديثات" تعرض زر **"منح صلاحية الوصول"** الذي
  يفتح منتقي مجلدات النظام؛ اختر مجلد
  `Android/media/com.whatsapp/WhatsApp/Media/.Statuses` مرة واحدة، ويُحفظ
  الإذن بشكل دائم عبر حزمة `shared_storage`. على أندرويد 10 وأقل يعمل
  المسار المباشر تلقائياً دون أي إعداد.
- **تنزيل تيك توك/إنستغرام عبر الرابط**: أداة "تنزيل" في التصميم الأصلي
  تفترض وجود خدمة استخراج للروابط من صفحات هذه المنصات. هذا يتطلب واجهة
  API خارجية أو خادم استخراج خاص بك (وقد يخالف شروط استخدام تلك المنصات)،
  ولا يمكن تنفيذه بأمان داخل التطبيق فقط. لذلك نفّذتُ الجزء الذي يمكن تنفيذه
  فعلياً على الجهاز: **تنزيل أي رابط وسائط مباشر** (رابط ينتهي بامتداد ملف
  مثل `.mp4/.jpg/.mp3`). إن توفّر لديك خادم استخراج خاص بك، اربطه داخل
  `lib/services/download_service.dart` (دالة `download`).
- **الخط Cairo**: يُحمَّل حالياً عبر `google_fonts` (يتطلب اتصال إنترنت أول
  مرة ثم يُخزَّن مؤقتاً). لتضمينه offline بالكامل، نزّل ملفات الخط وضعها في
  `assets/fonts/` وأضفها في `pubspec.yaml` بدلاً من `google_fonts`.
- تحقق من واجهة برمجة حزمة `shared_storage` مقابل الإصدار المثبت فعلياً
  عند `flutter pub get`، فبعض التسميات (enums/دوال) قد تختلف طفيفاً بين
  الإصدارات.

## الشاشات المطابقة للتصاميم

| ملف Stitch | الشاشة في التطبيق |
|---|---|
| `_6`, `halati_whatsapp_status_saver` | `updates_screen.dart` |
| `_4`, `_5` | `story_viewer_screen.dart` |
| `_7` | `download_screen.dart` |
| `_8` | `downloads_screen.dart` |
| `_1` (إعدادات الحالات) + `_3` (إعدادات عامة) | `settings_screen.dart` |
| `_2` | `about_screen.dart` |
