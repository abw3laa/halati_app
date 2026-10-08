import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:halati/l10n/app_localization.dart';
import 'package:halati/services/settings_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('SettingsService initializes with valid defaults', () async {
    SharedPreferences.setMockInitialValues({});

    final settings = SettingsService();
    await settings.load();

    expect(settings.loaded, isTrue);
    expect(settings.language.code, 'ar');
    expect(settings.darkMode, isFalse);
  });
}
