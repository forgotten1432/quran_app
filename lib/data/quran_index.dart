/// Mushaf içindekiler verisi (sure ve cüz başlangıç sayfaları).
///
/// Sayfa numaraları basılı mushafın sayfa numaralarıdır (PDF sayfası değil).
library;

class QuranSection {
  const QuranSection(this.name, this.page);

  final String name;
  final int page;
}

const List<QuranSection> surahs = [
  QuranSection("1. الفاتحة", 1),
  QuranSection("2. البقرة", 2),
  QuranSection("3. آل عمران", 50),
  QuranSection("4. النساء", 77),
  QuranSection("5. المائدة", 106),
  QuranSection("6. الأنعام", 128),
  QuranSection("7. الأعراف", 151),
  QuranSection("8. الأنفال", 177),
  QuranSection("9. التوبة", 187),
  QuranSection("10. يونس", 208),
  QuranSection("11. هود", 221),
  QuranSection("12. يوسف", 235),
  QuranSection("13. الرعد", 249),
  QuranSection("14. إبراهيم", 255),
  QuranSection("15. الحجر", 261),
  QuranSection("16. النحل", 267),
  QuranSection("17. الإسراء", 282),
  QuranSection("18. الكهف", 293),
  QuranSection("19. مريم", 305),
  QuranSection("20. طه", 312),
  QuranSection("21. الأنبياء", 322),
  QuranSection("22. الحج", 331),
  QuranSection("23. المؤمنون", 342),
  QuranSection("24. النور", 350),
  QuranSection("25. الفرقان", 359),
  QuranSection("26. الشعراء", 367),
  QuranSection("27. النمل", 376),
  QuranSection("28. القصص", 385),
  QuranSection("29. العنكبوت", 396),
  QuranSection("30. الروم", 404),
  QuranSection("31. لقمان", 411),
  QuranSection("32. السجدة", 415),
  QuranSection("33. الأحزاب", 418),
  QuranSection("34. سبأ", 428),
  QuranSection("35. فاطر", 434),
  QuranSection("36. يس", 440),
  QuranSection("37. الصافات", 445),
  QuranSection("38. ص", 452),
  QuranSection("39. الزمر", 458),
  QuranSection("40. غافر", 467),
  QuranSection("41. فصلت", 477),
  QuranSection("42. الشورى", 483),
  QuranSection("43. الزخرف", 489),
  QuranSection("44. الدخان", 495),
  QuranSection("45. الجاثية", 498),
  QuranSection("46. الأحقاف", 502),
  QuranSection("47. محمد", 506),
  QuranSection("48. الفتح", 511),
  QuranSection("49. الحجرات", 515),
  QuranSection("50. ق", 518),
  QuranSection("51. الذاريات", 520),
  QuranSection("52. الطور", 523),
  QuranSection("53. النجم", 526),
  QuranSection("54. القمر", 528),
  QuranSection("55. الرحمن", 531),
  QuranSection("56. الواقعة", 534),
  QuranSection("57. الحديد", 537),
  QuranSection("58. المجادلة", 542),
  QuranSection("59. الحشر", 545),
  QuranSection("60. الممتحنة", 549),
  QuranSection("61. الصف", 551),
  QuranSection("62. الجمعة", 553),
  QuranSection("63. المنافقون", 554),
  QuranSection("64. التغابن", 556),
  QuranSection("65. الطلاق", 558),
  QuranSection("66. التحريم", 560),
  QuranSection("67. الملك", 562),
  QuranSection("68. القلم", 564),
  QuranSection("69. الحاقة", 567),
  QuranSection("70. المعارج", 569),
  QuranSection("71. نوح", 571),
  QuranSection("72. الجن", 573),
  QuranSection("73. المزمل", 576),
  QuranSection("74. المدثر", 578),
  QuranSection("75. القيامة", 580),
  QuranSection("76. الإنسان", 582),
  QuranSection("77. المرسلات", 584),
  QuranSection("78. النبأ", 586),
  QuranSection("79. النازعات", 587),
  QuranSection("80. عبس", 589),
  QuranSection("81. التكوير", 590),
  QuranSection("82. الانفطار", 591),
  QuranSection("83. المطففين", 592),
  QuranSection("84. الانشقاق", 594),
  QuranSection("85. البروج", 595),
  QuranSection("86. الطارق", 596),
  QuranSection("87. الأعلى", 597),
  QuranSection("88. الغاشية", 597),
  QuranSection("89. الفجر", 598),
  QuranSection("90. البلد", 600),
  QuranSection("91. الشمس", 600),
  QuranSection("92. الليل", 601),
  QuranSection("93. الضحى", 602),
  QuranSection("94. الشرح", 602),
  QuranSection("95. التين", 603),
  QuranSection("96. العلق", 603),
  QuranSection("97. القدر", 604),
  QuranSection("98. البينة", 604),
  QuranSection("99. الزلزلة", 605),
  QuranSection("100. العاديات", 605),
  QuranSection("101. القارعة", 606),
  QuranSection("102. التكاثر", 606),
  QuranSection("103. العصر", 607),
  QuranSection("104. الهمزة", 607),
  QuranSection("105. الفيل", 607),
  QuranSection("106. قريش", 608),
  QuranSection("107. الماعون", 608),
  QuranSection("108. الكوثر", 608),
  QuranSection("109. الكافرون", 608),
  QuranSection("110. النصر", 609),
  QuranSection("111. المسد", 609),
  QuranSection("112. الإخلاص", 609),
  QuranSection("113. الفلق", 610),
  QuranSection("114. الناس", 610),
];

const List<QuranSection> juzs = [
  QuranSection("الجزء 1", 2),
  QuranSection("الجزء 2", 22),
  QuranSection("الجزء 3", 42),
  QuranSection("الجزء 4", 62),
  QuranSection("الجزء 5", 82),
  QuranSection("الجزء 6", 102),
  QuranSection("الجزء 7", 122),
  QuranSection("الجزء 8", 142),
  QuranSection("الجزء 9", 162),
  QuranSection("الجزء 10", 182),
  QuranSection("الجزء 11", 202),
  QuranSection("الجزء 12", 222),
  QuranSection("الجزء 13", 242),
  QuranSection("الجزء 14", 262),
  QuranSection("الجزء 15", 282),
  QuranSection("الجزء 16", 302),
  QuranSection("الجزء 17", 322),
  QuranSection("الجزء 18", 342),
  QuranSection("الجزء 19", 362),
  QuranSection("الجزء 20", 382),
  QuranSection("الجزء 21", 402),
  QuranSection("الجزء 22", 422),
  QuranSection("الجزء 23", 442),
  QuranSection("الجزء 24", 462),
  QuranSection("الجزء 25", 482),
  QuranSection("الجزء 26", 502),
  QuranSection("الجزء 27", 522),
  QuranSection("الجزء 28", 542),
  QuranSection("الجزء 29", 562),
  QuranSection("الجزء 30", 586),
];

/// [sections] içinde [page] sayfasını kapsayan son bölümün indeksi.
///
/// Aynı sayfada birden fazla bölüm başlıyorsa, o sayfada ilk başlayan seçilir.
/// Liste sayfaya göre artan sırada olmalıdır. Sayfa ilk bölümden önceyse 0 döner.
int activeSectionIndex(List<QuranSection> sections, int page) {
  for (int i = sections.length - 1; i >= 0; i--) {
    if (page >= sections[i].page) {
      while (i > 0 && sections[i - 1].page == sections[i].page) {
        i--;
      }
      return i;
    }
  }
  return 0;
}

/// [page] sayfasının ait olduğu bölüm.
QuranSection sectionForPage(List<QuranSection> sections, int page) =>
    sections[activeSectionIndex(sections, page)];
