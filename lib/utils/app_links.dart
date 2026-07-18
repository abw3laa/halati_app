/// Real, centralized links Halati points to — kept in one place so
/// updating a link (e.g. after moving hosting, or updating the MediaFire
/// download) only ever needs a single edit.
class AppLinks {
  AppLinks._();

  /// Shown/opened from the Settings "مشاركة التطبيق" button. Points at
  /// the same GitHub Pages site referenced by the update manifest
  /// (`UPDATE_SERVER_TEMPLATE.md`), *not* Google Play — this app is
  /// intentionally distributed outside the Play Store, via MediaFire /
  /// GitHub as agreed.
  static const String appDownloadPageUrl =
      'https://abw3laa.github.io/halati_app/';

  /// Real, hosted privacy policy (GitHub Pages, same repo as the update
  /// manifest — see PRIVACY_POLICY.md for the source document and hosting
  /// instructions).
  static const String privacyPolicyUrl =
      'https://abw3laa.github.io/halati_app/privacy.html';
}
