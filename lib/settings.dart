import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Sayfa görünümü: normal, sepya (göz yormayan) veya gece (koyu).
enum ReadingMode { light, sepia, night }

/// Kullanıcı tercihleri. Değişiklikler anında kaydedilir.
class AppSettings extends ChangeNotifier {
  AppSettings._(this._prefs);

  static const _kMode = 'reading_mode';
  static const _kKeepScreenOn = 'keep_screen_on';
  static const _kReminderOn = 'reminder_enabled';
  static const _kReminderMinutes = 'reminder_minutes';

  final SharedPreferences _prefs;

  static Future<AppSettings> load() async =>
      AppSettings._(await SharedPreferences.getInstance());

  ReadingMode get readingMode {
    final i = _prefs.getInt(_kMode) ?? 0;
    return ReadingMode.values[i.clamp(0, ReadingMode.values.length - 1)];
  }

  set readingMode(ReadingMode mode) {
    _prefs.setInt(_kMode, mode.index);
    notifyListeners();
  }

  /// Okurken ekranın kararmasını engelle (varsayılan: açık).
  bool get keepScreenOn => _prefs.getBool(_kKeepScreenOn) ?? true;

  set keepScreenOn(bool value) {
    _prefs.setBool(_kKeepScreenOn, value);
    notifyListeners();
  }

  bool get reminderEnabled => _prefs.getBool(_kReminderOn) ?? false;

  set reminderEnabled(bool value) {
    _prefs.setBool(_kReminderOn, value);
    notifyListeners();
  }

  /// Hatırlatma saati, gece yarısından itibaren dakika (varsayılan 20:00).
  int get reminderMinutes => _prefs.getInt(_kReminderMinutes) ?? 20 * 60;

  set reminderMinutes(int value) {
    _prefs.setInt(_kReminderMinutes, value % (24 * 60));
    notifyListeners();
  }
}
