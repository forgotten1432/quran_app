import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:quran_app/services/khatm.dart';
import 'package:quran_app/settings.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('KhatmTracker', () {
    test('sayfaları işaretler ve ilerlemeyi hesaplar', () async {
      final k = await KhatmTracker.load();
      expect(k.progress(100), 0);
      expect(k.markRead([1, 2, 3]), isTrue);
      expect(k.markRead([2]), isFalse, reason: 'zaten okunmuş');
      expect(k.readCount(100), 3);
      expect(k.progress(100), closeTo(0.03, 1e-9));
      expect(k.firstUnread(100), 4);
    });

    test('kalıcıdır', () async {
      (await KhatmTracker.load()).markRead([5, 7]);
      final again = await KhatmTracker.load();
      expect(again.readPages, {5, 7});
    });

    test('tamamlanan hatim kaydedilir ve yeni hatim başlar', () async {
      final k = await KhatmTracker.load();
      k.markRead(List.generate(10, (i) => i + 1));
      expect(k.firstUnread(10), isNull);
      k.completeKhatm();
      expect(k.completed, hasLength(1));
      expect(k.readCount(10), 0);
      final again = await KhatmTracker.load();
      expect(again.completed, hasLength(1));
      expect(again.readPages, isEmpty);
    });

    test('tek sayfa geri alınabilir', () async {
      final k = await KhatmTracker.load();
      k.setRead(9, true);
      expect(k.isRead(9), isTrue);
      k.setRead(9, false);
      expect(k.isRead(9), isFalse);
    });
  });

  group('AppSettings', () {
    test('varsayılanlar ve kayıt', () async {
      final s = await AppSettings.load();
      expect(s.readingMode, ReadingMode.light);
      expect(s.keepScreenOn, isTrue);
      expect(s.reminderEnabled, isFalse);
      expect(s.reminderMinutes, 20 * 60);

      s.readingMode = ReadingMode.night;
      s.keepScreenOn = false;
      s.reminderMinutes = 7 * 60 + 30;
      final again = await AppSettings.load();
      expect(again.readingMode, ReadingMode.night);
      expect(again.keepScreenOn, isFalse);
      expect(again.reminderMinutes, 450);
    });
  });
}
