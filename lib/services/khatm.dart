import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Hatim takibi: mevcut hatimde okunan sayfalar ve tamamlanan hatimler.
class KhatmTracker extends ChangeNotifier {
  KhatmTracker._(this._prefs, this._read, this._completed, this._startedAt);

  static const _kRead = 'khatm_read_pages';
  static const _kCompleted = 'khatm_completed';
  static const _kStarted = 'khatm_started';

  final SharedPreferences _prefs;
  final Set<int> _read;
  final List<DateTime> _completed;
  DateTime _startedAt;

  static Future<KhatmTracker> load() async {
    final prefs = await SharedPreferences.getInstance();
    final read = (prefs.getStringList(_kRead) ?? [])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
    final completed = (prefs.getStringList(_kCompleted) ?? [])
        .map(DateTime.tryParse)
        .whereType<DateTime>()
        .toList();
    final started =
        DateTime.tryParse(prefs.getString(_kStarted) ?? '') ?? DateTime.now();
    final tracker = KhatmTracker._(prefs, read, completed, started);
    if (prefs.getString(_kStarted) == null) tracker._saveStarted();
    return tracker;
  }

  Set<int> get readPages => Set.unmodifiable(_read);
  List<DateTime> get completed => List.unmodifiable(_completed);
  DateTime get startedAt => _startedAt;

  bool isRead(int page) => _read.contains(page);

  int readCount(int totalPages) =>
      _read.where((p) => p >= 1 && p <= totalPages).length;

  double progress(int totalPages) =>
      totalPages <= 0 ? 0 : readCount(totalPages) / totalPages;

  /// Okunmamış ilk sayfa (hepsi okunduysa null).
  int? firstUnread(int totalPages) {
    for (int p = 1; p <= totalPages; p++) {
      if (!_read.contains(p)) return p;
    }
    return null;
  }

  /// Sayfaları okundu olarak işaretler. Yeni bir sayfa eklendiyse true.
  bool markRead(Iterable<int> pages) {
    final changed = pages.fold(false, (c, p) => _read.add(p) || c);
    if (changed) {
      _saveRead();
      notifyListeners();
    }
    return changed;
  }

  void setRead(int page, bool read) {
    final changed = read ? _read.add(page) : _read.remove(page);
    if (changed) {
      _saveRead();
      notifyListeners();
    }
  }

  /// Mevcut hatmi tamamlandı olarak kaydeder ve yeni hatim başlatır.
  void completeKhatm() {
    _completed.add(DateTime.now());
    _prefs.setStringList(
        _kCompleted, _completed.map((d) => d.toIso8601String()).toList());
    _resetCurrent();
  }

  /// Mevcut hatmi (kaydetmeden) sıfırlar.
  void resetCurrent() => _resetCurrent();

  void _resetCurrent() {
    _read.clear();
    _startedAt = DateTime.now();
    _saveRead();
    _saveStarted();
    notifyListeners();
  }

  void _saveRead() => _prefs.setStringList(
      _kRead, (_read.toList()..sort()).map((p) => '$p').toList());

  void _saveStarted() =>
      _prefs.setString(_kStarted, _startedAt.toIso8601String());
}
