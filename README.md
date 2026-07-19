# حالاتي (Halati) — تطبيق Flutter لأندرويد

تطبيق شخصي لحفظ حالات واتساب (بما فيها حالات واتساب الأعمال) وتنزيل
وسائط من الإنترنت — موزَّع خارج Google Play (MediaFire/GitHub)، للاستخدام
الشخصي.

## هيكل المشروع

```
lib/
  main.dart                     نقطة الدخول + الثيمات + التوجيه
  theme/app_theme.dart          ألوان/أشكال Material 3
  l10n/app_localization.dart    ترجمة عربي/إنجليزي/تركي + RTL/LTR تلقائي
  models/                       StatusItem, DownloadItem, UpdateManifest
  services/
    settings_service.dart       الإعدادات (SharedPreferences)
    status_service.dart         اكتشاف/حفظ حالات واتساب (SAF + مسار مباشر)
    download_service.dart       تنزيل روابط الوسائط، تصنيف حسب النوع الحقيقي
    media_store_service.dart    نشر الملفات في المعرض/مدير الملفات العام
    video_api_service.dart      استخراج روابط تيك توك/إنستغرام/فيسبوك/يوتيوب
    update_service.dart         فحص/تنزيل/تثبيت تحديثات التطبيق تلقائياً
  widgets/                      BottomNavBar, UpdateDialog
  screens/                      شاشات: التحديثات (شبكة)، عارض الحالة، تنزيل،
                                 تحميلاتي، الإعدادات، حول
  utils/app_links.dart          روابط ثابتة (سياسة الخصوصية، صفحة التنزيل)
android/
  app/src/main/kotlin/.../MainActivity.kt   جسر MediaStore (Kotlin أصلي)
```

## خطوات التشغيل

```bash
flutter pub get
flutter run
```

مجلد `android/` كامل وجاهز بالفعل (`applicationId: com.abwaalaa.halati`)
— لا حاجة لتشغيل `flutter create` إطلاقاً.

## ملاحظات تقنية مهمة

### الوصول لحالات واتساب (SAF)
على أندرويد 11+ (Scoped Storage) لا يمكن لأي تطبيق قراءة مجلد
`.Statuses` الخاص بواتساب مباشرة إلا عبر إطار الوصول للتخزين (SAF).
زر **"منح صلاحية الوصول"** في شاشة "التحديثات" يفتح منتقي مجلدات
النظام؛ اختر مجلد
`Android/media/com.whatsapp/WhatsApp/Media/.Statuses` (أو
`com.whatsapp.w4b` لواتساب الأعمال) مرة واحدة، ويُحفظ الإذن بشكل دائم.
على أندرويد 10 وأقل يعمل المسار المباشر تلقائياً دون أي إعداد.

**الحزمة المستخدمة لهذا الغرض:** `saf_util` + `saf_stream` (ناشر موثّق
`flutter-cavalry.com`، نشطتان الصيانة). **لا تستخدم** `shared_storage` —
تلك الحزمة أصبحت متوقفة (discontinued) على pub.dev، وملف
`android/build.gradle` الخاص بها يستدعي داخلياً مستودع `jcenter()`
المُغلَق منذ سنوات، مما يُفشل أي بناء إصدار (`assembleRelease`) على أي
إصدار حديث من Gradle/AGP بشكل غير قابل للإصلاح من داخل هذا المشروع.

### عرض اسم صاحب الحالة
**غير متاح، بقرار مقصود.** ملفات حالات واتساب لا تحمل أي معلومة تربطها
برقم هاتف أو جهة اتصال — هذا قيد في نظام أندرويد وواتساب نفسه، وليس
قصوراً في حالاتي. التفاصيل الكاملة وسبب القرار في
`CONTACT_NAME_RESOLUTION.md`. واجهة "التحديثات" تعرض الحالات كشبكة
(Grid) من عمودين بدون أي اسم.

### تنزيل تيك توك/إنستغرام/فيسبوك/يوتيوب عبر الرابط
يعمل فعلياً عبر خادم استخراج مستقل (`halati_extract_server`، مبني على
`yt-dlp`)، منفصل عن هذا المستودع. الرابط الحالي مضبوط في
`lib/services/video_api_service.dart`. لروابط يوتيوب فقط، تظهر إمكانية
اختيار فيديو أو صوت.

### الخط Cairo
مُضمَّن محلياً بالكامل في `assets/fonts/` (وليس عبر `google_fonts`) —
يعمل بدون إنترنت من أول تشغيل، وهذا مهم لتوزيع خارج المتجر.

### التحديث التلقائي
يفحص التطبيق ملف `update.json` (مُستضاف على GitHub) عند كل تشغيل، ويعرض
نافذة تحديث إن وُجد إصدار أحدث، مع تنزيل وتثبيت مباشر من داخل التطبيق.
التفاصيل الكاملة في `UPDATE_SERVER_TEMPLATE.md`.

### سياسة الخصوصية
صفحة حقيقية كاملة بثلاث لغات، جاهزة للنشر عبر GitHub Pages —
`PRIVACY_POLICY.md` (المصدر) و `docs/privacy.html` (جاهزة للنشر).
تعليمات التفعيل في `PRIVACY_HOSTING_GUIDE.md`.

## وثائق إضافية

| الملف | الموضوع |
|---|---|
| `UPDATE_SERVER_TEMPLATE.md` | إعداد نظام التحديث التلقائي خطوة بخطوة |
| `PRIVACY_POLICY.md` / `docs/privacy.html` | سياسة الخصوصية الكاملة |
| `PRIVACY_HOSTING_GUIDE.md` | تفعيل GitHub Pages لنشر سياسة الخصوصية |
| `CONTACT_NAME_RESOLUTION.md` | لماذا لا يُعرَض اسم صاحب الحالة |
