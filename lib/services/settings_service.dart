import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localization.dart';

/// Central, observable app settings (language, theme, WhatsApp status
/// folder access). Backed by [SharedPreferences] so choices survive app
/// restarts.
///
/// Note: auto-save, status retention period, the contact exclusion list,
/// and save notifications were intentionally removed — Halati now always
/// keeps every status visible (including ones the sender deleted) until
/// its real 24-hour WhatsApp lifetime naturally ends, so those settings
/// no longer apply.
class SettingsService extends ChangeNotifier {
  static const _kLanguage = 'settings.language';
  static const _kDarkMode = 'settings.dark_mode';
  static const _kStatusTreeUri = 'settings.status_tree_uri';

  SharedPreferences? _prefs;

  AppLanguage language = AppLanguage.ar;
  bool darkMode = false;
  String? statusTreeUri;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final p = _prefs!;
    language = AppLanguageCode.fromCode(p.getString(_kLanguage) ?? 'ar');
    darkMode = p.getBool(_kDarkMode) ?? false;
    statusTreeUri = p.getString(_kStatusTreeUri);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage lang) async {
    language = lang;
    await _prefs?.setString(_kLanguage, lang.code);
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    darkMode = value;
    await _prefs?.setBool(_kDarkMode, value);
    notifyListeners();
  }

  Future<void> setStatusTreeUri(String? uri) async {
    statusTreeUri = uri;
    if (uri == null) {
      await _prefs?.remove(_kStatusTreeUri);
    } else {
      await _prefs?.setString(_kStatusTreeUri, uri);
    }
    notifyListeners();
  }
}
