# سياسة الخصوصية — تطبيق حالاتي (Halati)

**آخر تحديث:** يُحدَّث هذا التاريخ يدوياً في كل مرة يتغيّر فيها محتوى هذه
الصفحة.

تطبيق حالاتي ("التطبيق") من تطوير ياسر أبو علاء. توضح هذه السياسة ما
يجمعه التطبيق من بيانات، وما لا يجمعه، وكيف تُستخدم.

## 1. البيانات التي **لا** يجمعها التطبيق

- لا يجمع التطبيق اسمك، رقم هاتفك، أو أي معرّف شخصي
- لا يرسل أي حالة واتساب أو ملف وسائط تحمّله إلى أي خادم خاص بنا لتخزينه
  أو تحليله
- لا يبيع أو يشارك أي بيانات مع أطراف ثالثة لأغراض إعلانية
- لا يحتوي التطبيق على إعلانات ولا على أدوات تتبع تسويقي (Analytics/Ads
  SDKs)

## 2. البيانات التي تبقى على جهازك فقط

هذه المعلومات تُخزَّن **محلياً على جهازك فقط** عبر `SharedPreferences`
(تخزين داخلي خاص بالتطبيق)، ولا تُرسَل لأي مكان:

- تفضيل اللغة (عربي/إنجليزي/تركي)
- تفضيل المظهر (داكن/فاتح)
- رابط مجلد حالات واتساب الذي منحته صلاحية الوصول إليه (SAF tree URI)
- سجلّ صغير بأوقات نشر الحالات التي شاهدتها، يُستخدم فقط لحساب عدّاد
  الـ24 ساعة الخاص بميزة "الاحتفاظ بالحالة بعد حذفها"

## 3. الأذونات التي يطلبها التطبيق ولماذا

| الإذن | الغرض منه |
|---|---|
| **الوسائط / التخزين** (Photos, Videos, أو Storage) | لعرض حالات واتساب المؤقتة وحفظ نسخة منها على جهازك، ولحفظ الفيديوهات/الصور التي تُنزّلها من داخل التطبيق |
| **الوصول لمجلد محدد عبر منتقي الملفات (Storage Access Framework)** | مطلوب من أندرويد 11 فما فوق للوصول لمجلد `.Statuses` الخاص بواتساب تحديداً، بدلاً من طلب صلاحية شاملة لكامل التخزين |
| **تثبيت تطبيقات من مصادر غير معروفة** | يُستخدم فقط عند تثبيت تحديث جديد للتطبيق نفسه تنزّله من داخل شاشة الإعدادات، بما أن التطبيق موزَّع خارج متجر Google Play |
| **الإنترنت** | لتنزيل الفيديوهات/الصور من الروابط التي تلصقها بنفسك، وللتحقق من وجود تحديث جديد للتطبيق |

> **ملاحظة عن إذن "جهات الاتصال":** في حال طلب التطبيق مستقبلاً إذن قراءة
> جهات الاتصال، فالغرض الوحيد منه هو محاولة عرض اسم صاحب الحالة إن كان
> رقمه محفوظاً لديك — **مع ذلك، تنبيه مهم**: نظام أندرويد وواتساب لا
> يوفّران أي طريقة لربط ملف حالة واتساب برقم هاتف صاحبها، لذلك حتى مع
> منح هذا الإذن، لا يمكن للتطبيق فعلياً تحديد اسم صاحب الحالة تلقائياً —
> هذا قيد تقني في نظام أندرويد نفسه ينطبق على أي تطبيق مشابه، وليس خاصاً
> بحالاتي.

## 4. الوسائط التي تُنزّلها من الإنترنت

عند لصق رابط فيديو (من يوتيوب أو غيره) واستخدام ميزة "تنزيل"، يُرسَل
الرابط الذي أدخلته أنت فقط إلى خادم استخراج مخصص (`halati-extract-
server`) لاستخراج رابط الملف المباشر، ثم يُنزَّل الملف مباشرة إلى جهازك.
لا يُخزَّن الرابط أو الملف على هذا الخادم بعد إتمام الاستخراج.

## 5. حذف بياناتك

بما أن كل البيانات تبقى محلياً على جهازك، يمكنك حذفها بالكامل بأي من
الطريقتين:
- حذف التطبيق من جهازك مباشرة
- من إعدادات أندرويد: التطبيقات ← حالاتي ← التخزين ← مسح البيانات

## 6. التواصل

لأي استفسار متعلق بالخصوصية، يمكن التواصل عبر:
- واتساب: +905354883886
- تيليجرام: @abw3laa

---

# Privacy Policy — Halati App (English)

**Last updated:** manually updated whenever this page's content changes.

Halati ("the App") is developed by Yasser Abu Alaa. This policy explains
what data the App collects, what it doesn't, and how it's used.

## 1. Data the App does NOT collect

- No name, phone number, or personal identifier is collected
- No WhatsApp status or downloaded media file is sent to any server we
  operate for storage or analysis
- No data is sold or shared with third parties for advertising purposes
- The App contains no ads and no marketing/analytics tracking SDKs

## 2. Data kept only on your device

Stored locally only, via `SharedPreferences`, never transmitted anywhere:

- Language preference (Arabic/English/Turkish)
- Theme preference (dark/light)
- The WhatsApp status folder URI you granted access to (SAF tree URI)
- A small log of when statuses you've viewed were originally posted,
  used only to compute the 24-hour countdown for the "keep status after
  deletion" feature

## 3. Permissions requested and why

| Permission | Purpose |
|---|---|
| **Media / Storage** | To display temporary WhatsApp statuses and save a copy locally, and to save videos/images you download from within the App |
| **Storage Access Framework folder picker** | Required on Android 11+ to access WhatsApp's `.Statuses` folder specifically, instead of requesting broad full-storage access |
| **Install unknown apps** | Only used when installing a new App update downloaded from the Settings screen, since the App is distributed outside Google Play |
| **Internet** | To download videos/images from links you paste yourself, and to check for a new App update |

> **Note on the "Contacts" permission:** if the App requests contacts
> read access in the future, its only purpose is attempting to show a
> status owner's saved contact name. **Important caveat**: Android and
> WhatsApp provide no way to link a status file to its sender's phone
> number — so even with this permission granted, the App cannot actually
> resolve a status owner's name automatically. This is an Android
> platform limitation affecting any similar app, not specific to Halati.

## 4. Media you download from the internet

When you paste a video link (YouTube or otherwise) and use the Download
feature, only the URL you entered is sent to a dedicated extraction
server (`halati-extract-server`) to resolve a direct media URL, which is
then downloaded straight to your device. Neither the link nor the file
is stored on that server after extraction completes.

## 5. Deleting your data

Since all data stays local to your device, you can remove it entirely by
either:
- Uninstalling the App
- Android Settings → Apps → Halati → Storage → Clear data

## 6. Contact

For any privacy-related question:
- WhatsApp: +905354883886
- Telegram: @abw3laa
