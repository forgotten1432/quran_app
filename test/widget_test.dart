// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quran_app/data/quran_index.dart';
import 'package:quran_app/main.dart';

void main() {
  group('quran_index', () {
    test('114 sure ve 30 cüz var', () {
      expect(surahs.length, 114);
      expect(juzs.length, 30);
    });

    test('başlangıç sayfaları artan sırada', () {
      for (final list in [surahs, juzs]) {
        for (int i = 1; i < list.length; i++) {
          expect(list[i].page, greaterThanOrEqualTo(list[i - 1].page),
              reason: list[i].name);
        }
      }
    });

    test('sayfaya göre aktif sure bulunur', () {
      expect(sectionForPage(surahs, 1).name, contains('الفاتحة'));
      expect(sectionForPage(surahs, 2).name, contains('البقرة'));
      expect(sectionForPage(surahs, 49).name, contains('البقرة'));
      expect(sectionForPage(surahs, 50).name, contains('آل عمران'));
      expect(sectionForPage(surahs, 610).name, startsWith('113.'));
      expect(sectionForPage(surahs, 619).name, startsWith('113.'));
    });

    test('aynı sayfada başlayan surelerden ilki seçilir', () {
      // 87 (الأعلى) ve 88 (الغاشية) ikisi de 597. sayfada başlıyor.
      expect(sectionForPage(surahs, 597).name, startsWith('87.'));
    });

    test('sayfaya göre aktif cüz bulunur', () {
      expect(sectionForPage(juzs, 1).name, 'الجزء 1');
      expect(sectionForPage(juzs, 21).name, 'الجزء 1');
      expect(sectionForPage(juzs, 22).name, 'الجزء 2');
      expect(sectionForPage(juzs, 600).name, 'الجزء 30');
    });
  });

  testWidgets('açılış ekranı başlığı ve ilerlemeyi gösterir',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MyApp(home: SplashView(progress: 0.42)),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('قۇرئان كەرىم'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.textContaining('42%'), findsOneWidget);
  });
}
