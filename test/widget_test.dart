import 'package:flutter_test/flutter_test.dart';

import 'package:halati/l10n/app_localization.dart';
import 'package:halati/services/settings_service.dart';

void main() {
  test('SettingsService initializes with valid defaults', () async {
    final settings = SettingsService();
    await settings.load();

    expect(settings.loaded, isTrue);
    expect(settings.language.code, 'ar');
    expect(settings.darkMode, isFalse);
  });
}
