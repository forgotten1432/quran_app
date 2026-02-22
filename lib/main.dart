import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Renk paleti - merkezi tanımlama
  static const Color primaryColor = Color(0xFF00897B); // Teal 600
  static const Color primaryDark = Color(0xFF00695C); // Teal 800
  static const Color accentColor = Color(0xFFFFD54F); // Amber 300
  static const Color bgColor = Color(0xFFFFF8E1); // Amber 50
  static const Color surfaceColor = Color(0xFFFFFDE7); // Lighter variant
  static const Color textPrimary = Color(0xFF263238); // Blue Grey 900
  static const Color textSecondary = Color(0xFF546E7A); // Blue Grey 600

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'قۇرئان كەرىم',
      theme: ThemeData(
        colorSchemeSeed: primaryColor,
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
        fontFamily: 'Roboto',
        dialogTheme: DialogThemeData(
          backgroundColor: bgColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgColor,
          foregroundColor: primaryColor,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: primaryDark,
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ═══════════════════════════════════════════════════════
// SPLASH SCREEN - Animasyonlu
// ═══════════════════════════════════════════════════════
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _animController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const QuranReader(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.bgColor,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Dekoratif ikon
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [MyApp.primaryColor, MyApp.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: MyApp.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      size: 60, color: Colors.white),
                ),
                const SizedBox(height: 30),
                const Text(
                  "قۇرئان كەرىم",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: MyApp.primaryDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: MyApp.textPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 50),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: MyApp.primaryColor,
                    backgroundColor: MyApp.primaryColor.withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════
// QURAN READER - Ana Ekran
// ═══════════════════════════════════════════════════════
class QuranReader extends StatefulWidget {
  const QuranReader({super.key});

  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  final int pageOffset = 5;
  final double stretchFactor = 1.035;

  PageController? _pageController;
  final TransformationController _transformationController =
      TransformationController();
  TapDownDetails? _doubleTapDetails;

  PdfDocument? _document;
  int _totalPages = 0;
  int _currentMushafPage = 1;
  bool _isLoading = true;
  double _pageAspectRatio = 1.41;
  Orientation? _lastOrientation;
  bool _isMenuVisible = false;
  bool _isZoomed = false;

  DateTime? currentBackPressTime;
  List<String> _bookmarks = [];

  // --- SURE LİSTESİ ---
  final List<Map<String, dynamic>> surahs = [
    {"name": "1. الفاتحة", "page": 1},
    {"name": "2. البقرة", "page": 2},
    {"name": "3. آل عمران", "page": 50},
    {"name": "4. النساء", "page": 77},
    {"name": "5. المائدة", "page": 106},
    {"name": "6. الأنعام", "page": 128},
    {"name": "7. الأعراف", "page": 151},
    {"name": "8. الأنفال", "page": 177},
    {"name": "9. التوبة", "page": 187},
    {"name": "10. يونس", "page": 208},
    {"name": "11. هود", "page": 221},
    {"name": "12. يوسف", "page": 235},
    {"name": "13. الرعد", "page": 249},
    {"name": "14. إبراهيم", "page": 255},
    {"name": "15. الحجر", "page": 261},
    {"name": "16. النحل", "page": 267},
    {"name": "17. الإسراء", "page": 282},
    {"name": "18. الكهف", "page": 293},
    {"name": "19. مريم", "page": 305},
    {"name": "20. طه", "page": 312},
    {"name": "21. الأنبياء", "page": 322},
    {"name": "22. الحج", "page": 331},
    {"name": "23. المؤمنون", "page": 342},
    {"name": "24. النور", "page": 350},
    {"name": "25. الفرقان", "page": 359},
    {"name": "26. الشعراء", "page": 367},
    {"name": "27. النمل", "page": 376},
    {"name": "28. القصص", "page": 385},
    {"name": "29. العنكبوت", "page": 396},
    {"name": "30. الروم", "page": 404},
    {"name": "31. لقمان", "page": 411},
    {"name": "32. السجدة", "page": 415},
    {"name": "33. الأحزاب", "page": 418},
    {"name": "34. سبأ", "page": 428},
    {"name": "35. فاطر", "page": 434},
    {"name": "36. يس", "page": 440},
    {"name": "37. الصافات", "page": 445},
    {"name": "38. ص", "page": 452},
    {"name": "39. الزمر", "page": 458},
    {"name": "40. غافر", "page": 467},
    {"name": "41. فصلت", "page": 477},
    {"name": "42. الشورى", "page": 483},
    {"name": "43. الزخرف", "page": 489},
    {"name": "44. الدخان", "page": 495},
    {"name": "45. الجاثية", "page": 498},
    {"name": "46. الأحقاف", "page": 502},
    {"name": "47. محمد", "page": 506},
    {"name": "48. الفتح", "page": 511},
    {"name": "49. الحجرات", "page": 515},
    {"name": "50. ق", "page": 518},
    {"name": "51. الذاريات", "page": 520},
    {"name": "52. الطور", "page": 523},
    {"name": "53. النجم", "page": 526},
    {"name": "54. القمر", "page": 528},
    {"name": "55. الرحمن", "page": 531},
    {"name": "56. الواقعة", "page": 534},
    {"name": "57. الحديد", "page": 537},
    {"name": "58. المجادلة", "page": 542},
    {"name": "59. الحشر", "page": 545},
    {"name": "60. الممتحنة", "page": 549},
    {"name": "61. الصف", "page": 551},
    {"name": "62. الجمعة", "page": 553},
    {"name": "63. المنافقون", "page": 554},
    {"name": "64. التغابن", "page": 556},
    {"name": "65. الطلاق", "page": 558},
    {"name": "66. التحريم", "page": 560},
    {"name": "67. الملك", "page": 562},
    {"name": "68. القلم", "page": 564},
    {"name": "69. الحاقة", "page": 567},
    {"name": "70. المعارج", "page": 569},
    {"name": "71. نوح", "page": 571},
    {"name": "72. الجن", "page": 573},
    {"name": "73. المزمل", "page": 576},
    {"name": "74. المدثر", "page": 578},
    {"name": "75. القيامة", "page": 580},
    {"name": "76. الإنسان", "page": 582},
    {"name": "77. المرسلات", "page": 584},
    {"name": "78. النبأ", "page": 586},
    {"name": "79. النازعات", "page": 587},
    {"name": "80. عبس", "page": 589},
    {"name": "81. التكوير", "page": 590},
    {"name": "82. الانفطار", "page": 591},
    {"name": "83. المطففين", "page": 592},
    {"name": "84. الانشقاق", "page": 594},
    {"name": "85. البروج", "page": 595},
    {"name": "86. الطارق", "page": 596},
    {"name": "87. الأعلى", "page": 597},
    {"name": "88. الغاشية", "page": 597},
    {"name": "89. الفجر", "page": 598},
    {"name": "90. البلد", "page": 600},
    {"name": "91. الشمس", "page": 600},
    {"name": "92. الليل", "page": 601},
    {"name": "93. الضحى", "page": 602},
    {"name": "94. الشرح", "page": 602},
    {"name": "95. التين", "page": 603},
    {"name": "96. العلق", "page": 603},
    {"name": "97. القدر", "page": 604},
    {"name": "98. البينة", "page": 604},
    {"name": "99. الزلزلة", "page": 605},
    {"name": "100. العاديات", "page": 605},
    {"name": "101. القارعة", "page": 606},
    {"name": "102. التكاثر", "page": 606},
    {"name": "103. العصر", "page": 607},
    {"name": "104. الهمزة", "page": 607},
    {"name": "105. الفيل", "page": 607},
    {"name": "106. قريش", "page": 608},
    {"name": "107. الماعون", "page": 608},
    {"name": "108. الكوثر", "page": 608},
    {"name": "109. الكافرون", "page": 608},
    {"name": "110. النصر", "page": 609},
    {"name": "111. المسد", "page": 609},
    {"name": "112. الإخلاص", "page": 609},
    {"name": "113. الفلق", "page": 610},
    {"name": "114. الناس", "page": 610},
  ];

  final List<Map<String, dynamic>> juzs = [
    {"name": "الجزء 1", "page": 2},
    {"name": "الجزء 2", "page": 22},
    {"name": "الجزء 3", "page": 42},
    {"name": "الجزء 4", "page": 62},
    {"name": "الجزء 5", "page": 82},
    {"name": "الجزء 6", "page": 102},
    {"name": "الجزء 7", "page": 122},
    {"name": "الجزء 8", "page": 142},
    {"name": "الجزء 9", "page": 162},
    {"name": "الجزء 10", "page": 182},
    {"name": "الجزء 11", "page": 202},
    {"name": "الجزء 12", "page": 222},
    {"name": "الجزء 13", "page": 242},
    {"name": "الجزء 14", "page": 262},
    {"name": "الجزء 15", "page": 282},
    {"name": "الجزء 16", "page": 302},
    {"name": "الجزء 17", "page": 322},
    {"name": "الجزء 18", "page": 342},
    {"name": "الجزء 19", "page": 362},
    {"name": "الجزء 20", "page": 382},
    {"name": "الجزء 21", "page": 402},
    {"name": "الجزء 22", "page": 422},
    {"name": "الجزء 23", "page": 442},
    {"name": "الجزء 24", "page": 462},
    {"name": "الجزء 25", "page": 482},
    {"name": "الجزء 26", "page": 502},
    {"name": "الجزء 27", "page": 522},
    {"name": "الجزء 28", "page": 542},
    {"name": "الجزء 29", "page": 562},
    {"name": "الجزء 30", "page": 586},
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _init();

    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      if (scale > 1.05 && !_isZoomed) {
        setState(() {
          _isZoomed = true;
        });
      } else if (scale <= 1.05 && _isZoomed) {
        setState(() {
          _isZoomed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _bookmarks = prefs.getStringList('bookmarks') ?? [];

      final savedPage = prefs.getInt('last_page') ?? 1;
      _currentMushafPage = savedPage;

      _document = await PdfDocument.openAsset('assets/quran.pdf');

      if (_document != null && _document!.pages.isNotEmpty) {
        final firstPage = _document!.pages[0];
        _pageAspectRatio = firstPage.height / firstPage.width;
      }

      if (mounted) {
        setState(() {
          _totalPages = _document!.pages.length;
          _isLoading = false;
        });

        int targetIndex = savedPage - 1;
        if (_pageController != null && _pageController!.hasClients) {
          _pageController!.jumpToPage(targetIndex);
        } else {
          _pageController?.dispose();
          _pageController = PageController(initialPage: targetIndex);
        }
      }
    } catch (e) {
      debugPrint("PDF yükleme hatası: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar("PDF يۈكلەنمىدى، قايتا سىناڭ");
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message,
      {IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _toggleBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    String pageStr = _currentMushafPage.toString();

    setState(() {
      if (_bookmarks.contains(pageStr)) {
        _bookmarks.remove(pageStr);
        _showSuccessSnackBar("بەلگە ئېلىۋېتىلدى", icon: Icons.bookmark_remove);
      } else {
        _bookmarks.add(pageStr);
        _showSuccessSnackBar("بەت ساقلاندى", icon: Icons.bookmark_added);
      }
      _bookmarks.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    });

    await prefs.setStringList('bookmarks', _bookmarks);
  }

  Future<void> _saveLastPage(int mushafPage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', mushafPage);
  }

  void _goToPage(int mushafPageNumber) {
    if (mushafPageNumber < 1) mushafPageNumber = 1;

    if (_totalPages > 0 && mushafPageNumber > _totalPages) {
      mushafPageNumber = _totalPages;
    } else if (_totalPages == 0 && mushafPageNumber > 604) {
      mushafPageNumber = 604;
    }

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _currentMushafPage = mushafPageNumber;
      _isMenuVisible = false;
    });

    if (_pageController != null && _pageController!.hasClients) {
      bool isLandscape =
          MediaQuery.of(context).orientation == Orientation.landscape;
      int targetIndex;
      if (isLandscape) {
        targetIndex = ((mushafPageNumber - 1) / 2).floor();
      } else {
        targetIndex = mushafPageNumber - 1;
      }
      _pageController!.jumpToPage(targetIndex);
    }

    _saveLastPage(mushafPageNumber);
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
    } else {
      final position = _doubleTapDetails!.localPosition;
      var scale = 1.75;

      final x = -position.dx * (scale - 1);
      final y = -position.dy * (scale - 1);

      final zoomed = Matrix4.identity()
        ..translateByDouble(x, y, 0.0, 0.0)
        ..scaleByDouble(scale, scale, 1.0, 1.0);

      _transformationController.value = zoomed;
    }
  }

  String _getCurrentSurahName() {
    for (int i = surahs.length - 1; i >= 0; i--) {
      if (_currentMushafPage >= surahs[i]['page']) {
        return surahs[i]['name'];
      }
    }
    return surahs[0]['name'];
  }

  String _getCurrentJuzName() {
    for (int i = juzs.length - 1; i >= 0; i--) {
      if (_currentMushafPage >= juzs[i]['page']) {
        return juzs[i]['name'];
      }
    }
    return juzs[0]['name'];
  }

  int findActiveIndex(List<Map<String, dynamic>> items) {
    for (int i = 0; i < items.length; i++) {
      if (i == items.length - 1 || items[i + 1]['page'] > _currentMushafPage) {
        return i;
      }
    }
    return 0;
  }

  // ───── Liste Dialog (Sûre / Cüz) - Arama destekli ─────
  void _showListDialog(String title, List<Map<String, dynamic>> items) {
    int activeIndex = findActiveIndex(items);
    const double itemHeight = 60.0;
    final scrollController =
        ScrollController(initialScrollOffset: activeIndex * itemHeight);

    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredItems = searchQuery.isEmpty
                ? items
                : items
                    .where(
                        (item) => item['name'].toString().contains(searchQuery))
                    .toList();

            return AlertDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: MyApp.primaryColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  // Arama alanı
                  TextField(
                    onChanged: (value) {
                      setDialogState(() {
                        searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "ئىزدەش...",
                      prefixIcon: const Icon(Icons.search,
                          color: MyApp.primaryColor, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: MyApp.primaryColor.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: MyApp.primaryColor, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text("نەتىجە تېپىلمىدى",
                            style: TextStyle(color: MyApp.textSecondary)))
                    : ListView.separated(
                        controller:
                            searchQuery.isEmpty ? scrollController : null,
                        itemCount: filteredItems.length,
                        separatorBuilder: (ctx, i) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          bool isActive = searchQuery.isEmpty &&
                              items.indexOf(item) == activeIndex;
                          return Container(
                            decoration: BoxDecoration(
                              color: isActive
                                  ? MyApp.primaryColor.withValues(alpha: 0.12)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                item['name'],
                                style: TextStyle(
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isActive
                                      ? MyApp.primaryColor
                                      : MyApp.textPrimary,
                                  fontSize: 18,
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: MyApp.primaryColor
                                      .withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "${item['page']}-بەت",
                                  style: TextStyle(
                                    color: isActive
                                        ? MyApp.primaryColor
                                        : MyApp.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              onTap: () => _goToPage(item['page']),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("تاقاش",
                      style: TextStyle(color: MyApp.primaryColor)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ───── Sayfa Atla Dialogu ─────
  void _showGoToPageDialog() {
    TextEditingController controller = TextEditingController();
    String hintText = _totalPages > 0 ? "1 - $_totalPages" : "1 - 604";

    showDialog(
      context: context,
      builder: (context) {
        void handleSubmit() {
          int? page = int.tryParse(controller.text);
          if (page != null) {
            _goToPage(page);
          }
        }

        return AlertDialog(
          title: const Text("بەتكە يۆتكىلىش",
              style: TextStyle(
                  color: MyApp.primaryColor, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            onSubmitted: (_) => handleSubmit(),
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.numbers, color: MyApp.primaryColor),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: MyApp.primaryColor, width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("بىكار قىلىش",
                  style: TextStyle(color: MyApp.textSecondary)),
            ),
            FilledButton(
              onPressed: handleSubmit,
              style: FilledButton.styleFrom(
                backgroundColor: MyApp.primaryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("يۆتكىلىش"),
            ),
          ],
        );
      },
    );
  }

  // ───── Bookmark Dialog - StatefulBuilder ile anlık güncelleme ─────
  void _showBookmarksDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Row(
                children: [
                  const Icon(Icons.bookmarks, color: MyApp.primaryColor),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text("ساقلانغانلار",
                        style: TextStyle(
                            color: MyApp.primaryColor,
                            fontWeight: FontWeight.bold)),
                  ),
                  if (_bookmarks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: MyApp.primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${_bookmarks.length}",
                        style: const TextStyle(
                            color: MyApp.primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: 350,
                child: _bookmarks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border,
                                size: 60, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text("تېخى بەلگە يوق",
                                style: TextStyle(color: Colors.grey.shade500)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _bookmarks.length,
                        separatorBuilder: (ctx, i) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final pageNum = int.parse(_bookmarks[index]);
                          // Sûre ismini bul
                          String surahName = "";
                          for (int i = surahs.length - 1; i >= 0; i--) {
                            if (pageNum >= surahs[i]['page']) {
                              surahName = surahs[i]['name'];
                              break;
                            }
                          }

                          return ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    MyApp.primaryColor,
                                    MyApp.primaryDark
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _bookmarks[index],
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            title: Text("${_bookmarks[index]}-بەت",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(surahName,
                                style: const TextStyle(
                                    fontSize: 13, color: MyApp.textSecondary)),
                            onTap: () =>
                                _goToPage(int.parse(_bookmarks[index])),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                String pageToRemove = _bookmarks[index];
                                final prefs =
                                    await SharedPreferences.getInstance();
                                setState(() {
                                  _bookmarks.remove(pageToRemove);
                                });
                                await prefs.setStringList(
                                    'bookmarks', _bookmarks);
                                setDialogState(() {}); // Dialog'u güncelle
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("تاقاش",
                      style: TextStyle(color: MyApp.primaryColor)),
                )
              ],
            );
          },
        );
      },
    );
  }

  // ───── Geri tuşu işleyicisi (PopScope uyumlu) ─────
  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      _showSuccessSnackBar("چىقىش ئۈچۈن قايتا بېسىڭ", icon: Icons.exit_to_app);
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MyApp.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: MyApp.primaryColor,
                backgroundColor: MyApp.primaryColor.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 16),
              const Text("يۈكلىنىۋاتىدۇ...",
                  style: TextStyle(color: MyApp.textSecondary)),
            ],
          ),
        ),
      );
    }

    if (_document == null) {
      return Scaffold(
        backgroundColor: MyApp.bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red.shade300),
              const SizedBox(height: 16),
              const Text("PDF يۈكلىنەلمىدى",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: MyApp.textPrimary)),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _init();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("قايتا سىناش"),
                style: FilledButton.styleFrom(
                  backgroundColor: MyApp.primaryColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final screenSize = MediaQuery.of(context).size;
    bool isBookmarked = _bookmarks.contains(_currentMushafPage.toString());
    final maxPage = _totalPages > 0 ? _totalPages : 604;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: OrientationBuilder(builder: (context, orientation) {
        bool isLandscape = orientation == Orientation.landscape;

        if (_lastOrientation != orientation) {
          _lastOrientation = orientation;
          _isMenuVisible = false;

          int initialIndex;
          if (isLandscape) {
            initialIndex = ((_currentMushafPage - 1) / 2).floor();
          } else {
            initialIndex = _currentMushafPage - 1;
          }

          _pageController?.dispose();
          _pageController =
              PageController(initialPage: initialIndex, keepPage: false);
        }

        if (_pageController == null) {
          int initialIndex = isLandscape
              ? ((_currentMushafPage - 1) / 2).floor()
              : (_currentMushafPage - 1);
          _pageController = PageController(initialPage: initialIndex);
        }

        return Scaffold(
          body: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isMenuVisible = !_isMenuVisible;
                  });
                },
                onDoubleTapDown: _handleDoubleTapDown,
                onDoubleTap: _handleDoubleTap,
                child: PageView.builder(
                  physics: _isZoomed
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  key: ValueKey(orientation),
                  controller: _pageController,
                  itemCount:
                      isLandscape ? (_totalPages / 2).ceil() : _totalPages,
                  onPageChanged: (index) {
                    int newPage = isLandscape ? (index * 2) + 1 : index + 1;
                    setState(() {
                      _currentMushafPage = newPage;
                    });
                    _saveLastPage(newPage);
                    _transformationController.value = Matrix4.identity();
                  },
                  itemBuilder: (context, index) {
                    Widget pageContent;

                    if (isLandscape) {
                      // YATAY MOD (TABLET & TELEFON İÇİN)
                      int rightPageIndex = (index * 2);
                      int leftPageIndex = (index * 2) + 1;
                      int pdfPageRight = rightPageIndex + pageOffset + 1;
                      int pdfPageLeft = leftPageIndex + pageOffset + 1;

                      double horizontalPadding = 0;
                      if (screenSize.shortestSide >= 600) {
                        horizontalPadding = screenSize.width * 0.10;
                      }

                      double availableWidth =
                          screenSize.width - horizontalPadding;
                      double adjustedOnePageWidth = availableWidth / 2;
                      double calculatedHeight =
                          (adjustedOnePageWidth * _pageAspectRatio) *
                              stretchFactor;

                      Widget leftPageWidget = Container();
                      if (pdfPageLeft <= _totalPages) {
                        leftPageWidget = PdfPageView(
                            document: _document!,
                            pageNumber: pdfPageLeft,
                            alignment: Alignment.centerRight);
                      }

                      Widget rightPageWidget = Container();
                      if (pdfPageRight <= _totalPages) {
                        rightPageWidget = PdfPageView(
                            document: _document!,
                            pageNumber: pdfPageRight,
                            alignment: Alignment.centerLeft);
                      }

                      pageContent = Center(
                        child: Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.diagonal3Values(1.0, stretchFactor, 1.0),
                          child: Container(
                            width: availableWidth,
                            height: calculatedHeight / stretchFactor,
                            color: MyApp.bgColor,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(child: rightPageWidget),
                                Container(width: 2, color: Colors.black12),
                                Expanded(child: leftPageWidget),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else {
                      // DİKEY MOD
                      int pdfPage = index + pageOffset + 1;
                      if (pdfPage > _totalPages) {
                        pageContent = Container();
                      } else {
                        pageContent = Transform(
                          alignment: Alignment.center,
                          transform:
                              Matrix4.diagonal3Values(1.0, stretchFactor, 1.0),
                          child: ClipRect(
                            child: Transform.scale(
                              scale: 1.15,
                              child: Center(
                                child: PdfPageView(
                                  document: _document!,
                                  pageNumber: pdfPage,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 1.0,
                      maxScale: 5.0,
                      child: pageContent,
                    );
                  },
                ),
              ),

              // ÜST MENÜ
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _isMenuVisible ? 0 : -120,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  decoration: BoxDecoration(
                    color: MyApp.bgColor.withValues(alpha: 0.97),
                    boxShadow: _isMenuVisible
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : [],
                  ),
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: Row(
                      children: [
                        // Cüz butonu
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.library_books,
                                color: MyApp.primaryColor, size: 20),
                            label: Text(
                              _getCurrentJuzName(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: MyApp.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            onPressed: () => _showListDialog("پارىلەر", juzs),
                          ),
                        ),
                        // Sayfa numarası (tıklanabilir)
                        InkWell(
                          onTap: _showGoToPageDialog,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [MyApp.primaryColor, MyApp.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      MyApp.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "$_currentMushafPage",
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        // Sûre butonu
                        Expanded(
                          child: TextButton.icon(
                            icon: const Icon(Icons.list_alt,
                                color: MyApp.primaryColor, size: 20),
                            label: Text(
                              _getCurrentSurahName(),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  color: MyApp.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14),
                            ),
                            onPressed: () => _showListDialog("سۈرىلەر", surahs),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ALT MENÜ
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _isMenuVisible
                    ? 0
                    : -(kToolbarHeight +
                        50 +
                        MediaQuery.of(context).padding.bottom),
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  decoration: BoxDecoration(
                    color: MyApp.bgColor.withValues(alpha: 0.97),
                    boxShadow: _isMenuVisible
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            )
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Sayfa slider'ı
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text("$maxPage",
                                style: const TextStyle(
                                    fontSize: 11, color: MyApp.textSecondary)),
                            Expanded(
                              child: SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: MyApp.primaryColor,
                                  inactiveTrackColor: MyApp.primaryColor
                                      .withValues(alpha: 0.15),
                                  thumbColor: MyApp.primaryColor,
                                  overlayColor: MyApp.primaryColor
                                      .withValues(alpha: 0.12),
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(
                                      enabledThumbRadius: 7),
                                ),
                                child: Slider(
                                  value: _currentMushafPage
                                      .toDouble()
                                      .clamp(1, maxPage.toDouble()),
                                  min: 1,
                                  max: maxPage.toDouble(),
                                  onChanged: (value) {
                                    setState(() {
                                      _currentMushafPage = value.round();
                                    });
                                  },
                                  onChangeEnd: (value) {
                                    _goToPage(value.round());
                                  },
                                ),
                              ),
                            ),
                            const Text("1",
                                style: TextStyle(
                                    fontSize: 11, color: MyApp.textSecondary)),
                          ],
                        ),
                      ),
                      // Alt butonlar
                      SizedBox(
                        height: kToolbarHeight,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Yer imleri
                            TextButton.icon(
                              icon: const Icon(Icons.bookmarks_outlined,
                                  color: MyApp.primaryColor, size: 22),
                              label: const Text("ساقلانغانلار",
                                  style: TextStyle(
                                      color: MyApp.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13)),
                              onPressed: _showBookmarksDialog,
                            ),
                            // Ayırıcı
                            Container(
                              width: 1,
                              height: 24,
                              color: Colors.grey.shade300,
                            ),
                            // Yer imi ekle/kaldır
                            TextButton.icon(
                              icon: Icon(
                                isBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: isBookmarked
                                    ? MyApp.primaryColor
                                    : MyApp.textSecondary,
                                size: 22,
                              ),
                              label: Text(
                                isBookmarked ? "بەلگە ئېلىۋېتىش" : "بەت ساقلاش",
                                style: TextStyle(
                                    color: isBookmarked
                                        ? MyApp.primaryColor
                                        : MyApp.textSecondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13),
                              ),
                              onPressed: _toggleBookmark,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
