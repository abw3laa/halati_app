import 'package:flutter/material.dart';

/// Supported app languages.
enum AppLanguage { ar, en, tr }

extension AppLanguageCode on AppLanguage {
  String get code => switch (this) {
        AppLanguage.ar => 'ar',
        AppLanguage.en => 'en',
        AppLanguage.tr => 'tr',
      };

  String get nativeName => switch (this) {
        AppLanguage.ar => 'العربية',
        AppLanguage.en => 'English',
        AppLanguage.tr => 'Türkçe',
      };

  TextDirection get direction =>
      this == AppLanguage.ar ? TextDirection.rtl : TextDirection.ltr;

  static AppLanguage fromCode(String code) => switch (code) {
        'en' => AppLanguage.en,
        'tr' => AppLanguage.tr,
        _ => AppLanguage.ar,
      };
}

/// Very small, dependency-free i18n layer. Usage: `T('updates')`
/// after wrapping the app in [AppLocalizationScope].
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _dict = {
    'app_name': {'ar': 'حالاتي', 'en': 'Halati', 'tr': 'Halati'},

    // Bottom nav
    'nav_updates': {'ar': 'التحديثات', 'en': 'Updates', 'tr': 'Güncellemeler'},
    'nav_download': {'ar': 'تنزيل', 'en': 'Download', 'tr': 'İndir'},
    'nav_settings': {'ar': 'الإعدادات', 'en': 'Settings', 'tr': 'Ayarlar'},
    'nav_about': {'ar': 'حول', 'en': 'About', 'tr': 'Hakkında'},

    // Updates screen
    'updates_title': {'ar': 'الحالات', 'en': 'Statuses', 'tr': 'Durumlar'},
    'my_status': {'ar': 'حالتي', 'en': 'My status', 'tr': 'Durumum'},
    'add_status': {'ar': 'إضافة حالة', 'en': 'Add status', 'tr': 'Durum ekle'},
    'recent_updates': {
      'ar': 'التحديثات الأخيرة',
      'en': 'Recent updates',
      'tr': 'Son güncellemeler'
    },
    'viewed_updates': {
      'ar': 'التحديثات التي تمت مشاهدتها',
      'en': 'Viewed updates',
      'tr': 'Görüntülenen güncellemeler'
    },
    'no_statuses': {
      'ar': 'لا توجد حالات لعرضها حالياً. افتح واتساب وشاهد بعض الحالات ثم عد إلى هنا.',
      'en': 'No statuses to show yet. Open WhatsApp, view a few statuses, then come back.',
      'tr': 'Henüz gösterilecek durum yok. WhatsApp\'ı açıp birkaç durumu görüntüleyin.'
    },
    'grant_access': {
      'ar': 'منح صلاحية الوصول لمجلد حالات واتساب',
      'en': 'Grant access to WhatsApp status folder',
      'tr': 'WhatsApp durum klasörüne erişim izni ver'
    },
    'saved': {'ar': 'تم الحفظ بنجاح', 'en': 'Saved successfully', 'tr': 'Başarıyla kaydedildi'},
    'save': {'ar': 'حفظ', 'en': 'Save', 'tr': 'Kaydet'},

    // Download screen
    'download_title': {'ar': 'تنزيل', 'en': 'Download', 'tr': 'İndir'},
    'link_hint': {
      'ar': 'أدخل رابط الفيديو هنا...',
      'en': 'Paste video link here...',
      'tr': 'Video bağlantısını buraya yapıştırın...'
    },
    'paste': {'ar': 'لصق', 'en': 'Paste', 'tr': 'Yapıştır'},
    'choose_format': {'ar': 'اختر التنسيق:', 'en': 'Choose format:', 'tr': 'Format seçin:'},
    'format_video': {'ar': 'فيديو', 'en': 'Video', 'tr': 'Video'},
    'format_audio': {'ar': 'صوت', 'en': 'Audio', 'tr': 'Ses'},
    'format_image': {'ar': 'صور', 'en': 'Image', 'tr': 'Resim'},
    'download_now': {'ar': 'تنزيل الآن', 'en': 'Download now', 'tr': 'Şimdi indir'},
    'my_downloads': {'ar': 'تحميلاتي', 'en': 'My downloads', 'tr': 'İndirmelerim'},
    'downloading': {'ar': 'جارٍ التنزيل...', 'en': 'Downloading...', 'tr': 'İndiriliyor...'},
    'cancel': {'ar': 'إلغاء', 'en': 'Cancel', 'tr': 'İptal'},
    'invalid_link': {
      'ar': 'الرجاء إدخال رابط صحيح',
      'en': 'Please enter a valid link',
      'tr': 'Lütfen geçerli bir bağlantı girin'
    },
    'direct_link_note': {
      'ar': 'يمكنك لصق رابط فيديو مباشر (mp4/jpg/mp3)، أو رابط صفحة من تيك توك/إنستغرام/فيسبوك/يوتيوب — سيقوم السيرفر باستخراج الرابط المباشر بدون علامة مائية تلقائياً.',
      'en': 'Paste a direct media link (mp4/jpg/mp3), or a TikTok/Instagram/Facebook/YouTube page link — the server will automatically extract a clean, watermark-free direct URL.',
      'tr': 'Doğrudan bir medya bağlantısı (mp4/jpg/mp3) veya bir TikTok/Instagram/Facebook/YouTube sayfa bağlantısı yapıştırın — sunucu otomatik olarak filigransız doğrudan bağlantıyı çıkaracaktır.'
    },

    // Downloads list
    'downloads_title': {'ar': 'تحميلاتي', 'en': 'My downloads', 'tr': 'İndirmelerim'},
    'tab_video': {'ar': 'فيديو', 'en': 'Video', 'tr': 'Video'},
    'tab_images': {'ar': 'صور', 'en': 'Images', 'tr': 'Resimler'},
    'tab_music': {'ar': 'موسيقى', 'en': 'Music', 'tr': 'Müzik'},
    'empty_downloads': {
      'ar': 'لا توجد ملفات محملة في هذا القسم بعد.',
      'en': 'No downloaded files in this section yet.',
      'tr': 'Bu bölümde henüz indirilen dosya yok.'
    },
    'delete': {'ar': 'حذف', 'en': 'Delete', 'tr': 'Sil'},

    // Settings screen
    'settings_title': {'ar': 'الإعدادات', 'en': 'Settings', 'tr': 'Ayarlar'},
    'language': {'ar': 'اللغة', 'en': 'Language', 'tr': 'Dil'},
    'dark_mode': {'ar': 'المظهر الداكن', 'en': 'Dark mode', 'tr': 'Karanlık mod'},
    'dark_mode_desc': {
      'ar': 'تفعيل الوضع الليلي للتطبيق',
      'en': 'Enable the app\'s night mode',
      'tr': 'Uygulamanın gece modunu etkinleştir'
    },
    'storage_path': {'ar': 'مسار التخزين', 'en': 'Storage path', 'tr': 'Depolama yolu'},
    'storage_path_desc': {
      'ar': 'يتم تصنيف الوسائط المحملة تلقائياً إلى مجلدات فرعية (صور، فيديو، مقاطع صوتية) لسهولة الوصول إليها.',
      'en': 'Downloaded media is automatically sorted into subfolders (images, video, audio) for easy access.',
      'tr': 'İndirilen medya, kolay erişim için otomatik olarak alt klasörlere (resim, video, ses) ayrılır.'
    },
    'share_app': {'ar': 'مشاركة التطبيق مع الأصدقاء', 'en': 'Share app with friends', 'tr': 'Uygulamayı arkadaşlarınla paylaş'},
    'privacy_policy': {'ar': 'سياسة الخصوصية وشروط الاستخدام', 'en': 'Privacy policy & terms', 'tr': 'Gizlilik politikası ve şartlar'},
    'encryption_note': {
      'ar': 'يتم تشفير جميع عمليات الحفظ محلياً على جهازك لضمان الخصوصية القصوى.',
      'en': 'All saves are processed locally on your device to guarantee maximum privacy.',
      'tr': 'Gizliliği en üst düzeyde tutmak için tüm kayıtlar cihazınızda yerel olarak işlenir.'
    },

    // About screen
    'about_title': {'ar': 'حول التطبيق', 'en': 'About', 'tr': 'Hakkında'},
    'developer': {'ar': 'المطور', 'en': 'Developer', 'tr': 'Geliştirici'},
    'app_features': {'ar': 'مميزات التطبيق', 'en': 'App features', 'tr': 'Uygulama özellikleri'},
    'feature_1': {
      'ar': 'تحميل حالات واتساب (فيديو وصور) بجودة عالية',
      'en': 'Save WhatsApp statuses (video & photo) in high quality',
      'tr': 'WhatsApp durumlarını (video ve fotoğraf) yüksek kalitede kaydet'
    },
    'feature_2': {
      'ar': 'واجهة عصرية وسهلة الاستخدام تتبع معايير M3',
      'en': 'Modern, easy-to-use interface following M3 guidelines',
      'tr': 'M3 standartlarını takip eden modern ve kolay arayüz'
    },
    'feature_3': {
      'ar': 'دعم كامل للوضع الليلي المريح للعين',
      'en': 'Full support for an eye-friendly dark mode',
      'tr': 'Göz dostu karanlık mod için tam destek'
    },
    'feature_4': {
      'ar': 'تصنيف تلقائي للملفات المحملة لتسهيل الوصول',
      'en': 'Automatic sorting of downloaded files for easy access',
      'tr': 'Kolay erişim için indirilen dosyaların otomatik sınıflandırılması'
    },
    'contact_developer': {'ar': 'تواصل مع المطور', 'en': 'Contact the developer', 'tr': 'Geliştiriciyle iletişim'},
    'whatsapp': {'ar': 'واتساب', 'en': 'WhatsApp', 'tr': 'WhatsApp'},
    'telegram': {'ar': 'تيليجرام', 'en': 'Telegram', 'tr': 'Telegram'},
    'facebook': {'ar': 'فيسبوك', 'en': 'Facebook', 'tr': 'Facebook'},
    'all_rights': {
      'ar': 'جميع الحقوق محفوظة © 2026',
      'en': 'All rights reserved © 2026',
      'tr': 'Tüm hakları saklıdır © 2026'
    },

    // Generic
    'ok': {'ar': 'حسناً', 'en': 'OK', 'tr': 'Tamam'},
    'search': {'ar': 'بحث', 'en': 'Search', 'tr': 'Ara'},

    // In-app updates
    'update_available_title': {
      'ar': 'تحديث جديد متاح',
      'en': 'A new update is available',
      'tr': 'Yeni bir güncelleme mevcut'
    },
    'update_download_now': {'ar': 'تنزيل الآن', 'en': 'Download now', 'tr': 'Şimdi indir'},
    'update_skip': {'ar': 'تجاهل هذا الإصدار', 'en': 'Skip this version', 'tr': 'Bu sürümü atla'},
    'update_cancel': {'ar': 'إلغاء', 'en': 'Cancel', 'tr': 'İptal'},
    'update_downloaded': {
      'ar': 'اكتمل التنزيل، جارٍ فتح المثبّت...',
      'en': 'Download complete, opening installer...',
      'tr': 'İndirme tamamlandı, yükleyici açılıyor...'
    },
    'update_install_now': {'ar': 'تثبيت الآن', 'en': 'Install now', 'tr': 'Şimdi yükle'},
    'update_retry': {'ar': 'إعادة المحاولة', 'en': 'Retry', 'tr': 'Tekrar dene'},
    'update_close': {'ar': 'إغلاق', 'en': 'Close', 'tr': 'Kapat'},
    'update_generic_error': {
      'ar': 'تعذر إتمام التحديث. تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      'en': 'Could not complete the update. Check your connection and try again.',
      'tr': 'Güncelleme tamamlanamadı. Bağlantınızı kontrol edip tekrar deneyin.'
    },
    'update_permission_denied': {
      'ar': 'يجب السماح بتثبيت التطبيقات من مصادر غير معروفة لإتمام التحديث.',
      'en': 'You must allow installing apps from unknown sources to finish updating.',
      'tr': 'Güncellemeyi tamamlamak için bilinmeyen kaynaklardan uygulama yüklemeye izin vermelisiniz.'
    },
    'settings_check_updates': {'ar': 'التحقق من التحديثات', 'en': 'Check for updates', 'tr': 'Güncellemeleri kontrol et'},
    'settings_current_version': {'ar': 'الإصدار الحالي', 'en': 'Current version', 'tr': 'Mevcut sürüm'},
    'update_up_to_date': {
      'ar': 'أنت تستخدم أحدث إصدار ✅',
      'en': "You're on the latest version ✅",
      'tr': 'En son sürümü kullanıyorsunuz ✅'
    },
    'update_checking': {'ar': 'جارٍ التحقق من التحديثات...', 'en': 'Checking for updates...', 'tr': 'Güncellemeler kontrol ediliyor...'},
  };

  static String of(String key, AppLanguage lang) {
    return _dict[key]?[lang.code] ?? key;
  }
}

/// InheritedWidget that exposes the current language + a `t()` translate fn.
class AppLocalizationScope extends InheritedWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  const AppLocalizationScope({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    required super.child,
  });

  static AppLocalizationScope of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<AppLocalizationScope>();
    assert(scope != null, 'AppLocalizationScope not found in context');
    return scope!;
  }

  String t(String key) => AppStrings.of(key, language);

  @override
  bool updateShouldNotify(AppLocalizationScope oldWidget) =>
      oldWidget.language != language;
}

/// Shorthand accessor, e.g. `T(context, 'save')`.
String T(BuildContext context, String key) =>
    AppLocalizationScope.of(context).t(key);
