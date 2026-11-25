import 'dart:async';

import 'package:flutter/foundation.dart';
// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/quran_index.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  pdfrxFlutterInitialize();
  if (!kIsWeb) {
    // Tam ekran okuma modu (build içinde her seferinde çağrılmamalı).
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home = const QuranReader()});

  /// Testlerde farklı bir ana ekran verebilmek için.
  final Widget home;

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'قۇرئان كەرىم',
      theme: ThemeData(
        colorSchemeSeed: primaryColor,
        useMaterial3: true,
        scaffoldBackgroundColor: bgColor,
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
      home: home,
    );
  }
}

// ═══════════════════════════════════════════════════════
// AÇILIŞ / YÜKLEME EKRANI - Animasyonlu
// ═══════════════════════════════════════════════════════
/// PDF yüklenirken gösterilen açılış ekranı.
///
/// [progress] null ise belirsiz ilerleme gösterilir; 0..1 arası ise yüzde.
class SplashView extends StatefulWidget {
  const SplashView({super.key, this.progress, this.downloadedBytes});

  final double? progress;
  final int? downloadedBytes;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    final downloaded = widget.downloadedBytes;
    String? progressText;
    if (progress != null) {
      progressText = "${(progress * 100).clamp(0, 100).toStringAsFixed(0)}%";
    } else if (downloaded != null && downloaded > 0) {
      progressText = "${(downloaded / (1024 * 1024)).toStringAsFixed(1)} MB";
    }

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
                if (progress == null)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: MyApp.primaryColor,
                      backgroundColor:
                          MyApp.primaryColor.withValues(alpha: 0.15),
                    ),
                  )
                else
                  SizedBox(
                    width: 200,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        color: MyApp.primaryColor,
                        backgroundColor:
                            MyApp.primaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  progressText == null
                      ? "يۈكلىنىۋاتىدۇ..."
                      : "يۈكلىنىۋاتىدۇ... $progressText",
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(color: MyApp.textSecondary),
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

  /// Mushafın 1. sayfasından önceki PDF sayfası sayısı (kapak vb.).
  static const int pageOffset = 5;

  /// Sayfanın dikeyde hafifçe uzatılma oranı (görsel ayar).
  static const double stretchFactor = 1.035;

  /// PDF henüz yüklenmemişken varsayılan sayfa sayısı.
  static const int defaultPageCount = 604;

  static const String _assetPath = 'assets/quran.pdf';

  @override
  State<QuranReader> createState() => _QuranReaderState();
}

class _QuranReaderState extends State<QuranReader> {
  PageController? _pageController;
  Orientation? _controllerOrientation;
  final TransformationController _transformationController =
      TransformationController();
  final FocusNode _focusNode = FocusNode(debugLabel: 'reader');
  TapDownDetails? _doubleTapDetails;

  PdfDocument? _document;
  int _totalPdfPages = 0;
  int _currentMushafPage = 1;
  bool _isLoading = true;
  double? _loadProgress;
  int? _downloadedBytes;
  double _pageAspectRatio = 1.41;
  bool _isMenuVisible = false;
  bool _isZoomed = false;

  /// Menü bu süre boyunca etkileşim olmazsa kendiliğinden gizlenir.
  static const Duration menuAutoHideDelay = Duration(seconds: 5);
  Timer? _menuHideTimer;

  DateTime? _currentBackPressTime;
  List<int> _bookmarks = [];

  /// Görüntülenebilir mushaf sayfası sayısı (PDF sayfaları - ofset).
  int get _pageCount => _totalPdfPages > QuranReader.pageOffset
      ? _totalPdfPages - QuranReader.pageOffset
      : QuranReader.defaultPageCount;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformChanged);
    _init();
  }

  @override
  void dispose() {
    _menuHideTimer?.cancel();
    _pageController?.dispose();
    _transformationController
      ..removeListener(_onTransformChanged)
      ..dispose();
    _focusNode.dispose();
    _document?.dispose();
    super.dispose();
  }

  // ───── Menü görünürlüğü ve otomatik gizleme ─────
  void _setMenuVisible(bool visible) {
    _menuHideTimer?.cancel();
    if (visible) _restartMenuHideTimer();
    if (visible != _isMenuVisible) {
      setState(() => _isMenuVisible = visible);
    }
  }

  /// Menüyle her etkileşimde (dokunma, kaydırıcı) süre baştan başlar.
  void _restartMenuHideTimer() {
    _menuHideTimer?.cancel();
    _menuHideTimer = Timer(menuAutoHideDelay, () {
      if (!mounted || !_isMenuVisible) return;
      // Üstte bir dialog açıksa (sure listesi vb.) menüyü kapatma, bekle.
      if (ModalRoute.of(context)?.isCurrent == false) {
        _restartMenuHideTimer();
        return;
      }
      setState(() => _isMenuVisible = false);
    });
  }

  void _onTransformChanged() {
    final zoomed = _transformationController.value.getMaxScaleOnAxis() > 1.05;
    if (zoomed != _isZoomed) {
      setState(() => _isZoomed = zoomed);
    }
  }

  Future<PdfDocument> _openDocument() {
    if (kIsWeb) {
      // Web'de dosya ağdan indirilir; ilerleme gösterebilmek için URI ile aç.
      final uri = Uri.base.resolve('assets/${QuranReader._assetPath}');
      return PdfDocument.openUri(
        uri,
        progressCallback: (downloaded, [total]) {
          if (!mounted) return;
          setState(() {
            _downloadedBytes = downloaded;
            _loadProgress =
                (total != null && total > 0) ? downloaded / total : null;
          });
        },
      );
    }
    return PdfDocument.openAsset(QuranReader._assetPath);
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = (prefs.getStringList('bookmarks') ?? [])
          .map(int.tryParse)
          .whereType<int>()
          .toSet()
          .toList()
        ..sort();
      final savedPage = prefs.getInt('last_page') ?? 1;

      final document = await _openDocument();
      if (!mounted) {
        document.dispose();
        return;
      }

      double aspectRatio = _pageAspectRatio;
      if (document.pages.isNotEmpty) {
        final firstPage = document.pages.first;
        if (firstPage.width > 0) {
          aspectRatio = firstPage.height / firstPage.width;
        }
      }

      setState(() {
        _document = document;
        _totalPdfPages = document.pages.length;
        _pageAspectRatio = aspectRatio;
        _bookmarks = bookmarks.where((p) => p >= 1 && p <= _pageCount).toList();
        _currentMushafPage = savedPage.clamp(1, _pageCount);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("PDF yükleme hatası: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar("PDF يۈكلەنمىدى، قايتا سىناڭ");
      }
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _loadProgress = null;
      _downloadedBytes = null;
    });
    _init();
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
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
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

  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
        'bookmarks', _bookmarks.map((p) => p.toString()).toList());
  }

  Future<void> _toggleBookmark() async {
    final page = _currentMushafPage;
    final removed = _bookmarks.contains(page);
    setState(() {
      if (removed) {
        _bookmarks.remove(page);
      } else {
        _bookmarks = [..._bookmarks, page]..sort();
      }
    });
    if (removed) {
      _showSuccessSnackBar("بەلگە ئېلىۋېتىلدى", icon: Icons.bookmark_remove);
    } else {
      _showSuccessSnackBar("بەت ساقلاندى", icon: Icons.bookmark_added);
    }
    await _saveBookmarks();
  }

  Future<void> _saveLastPage(int mushafPage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_page', mushafPage);
  }

  // ───── Sayfa <-> PageView indeksi dönüşümleri ─────
  int _indexForPage(int mushafPage, bool isLandscape) =>
      isLandscape ? (mushafPage - 1) ~/ 2 : mushafPage - 1;

  int _pageForIndex(int index, bool isLandscape) =>
      isLandscape ? index * 2 + 1 : index + 1;

  bool get _isLandscape => _controllerOrientation == Orientation.landscape;

  /// Yön değiştiğinde (veya ilk kez) PageController'ı mevcut sayfaya göre kurar.
  /// Eski controller, ona bağlı PageView ağaçtan ayrıldıktan sonra atılır.
  PageController _controllerFor(Orientation orientation) {
    if (_pageController == null || _controllerOrientation != orientation) {
      final old = _pageController;
      _controllerOrientation = orientation;
      _pageController = PageController(
        initialPage: _indexForPage(
            _currentMushafPage, orientation == Orientation.landscape),
      );
      if (old != null) {
        _isMenuVisible = false;
        _menuHideTimer?.cancel();
        WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
      }
    }
    return _pageController!;
  }

  void _goToPage(int mushafPageNumber) {
    final page = mushafPageNumber.clamp(1, _pageCount);

    _menuHideTimer?.cancel();
    setState(() {
      _currentMushafPage = page;
      _isMenuVisible = false;
    });

    final controller = _pageController;
    if (controller != null && controller.hasClients) {
      controller.jumpToPage(_indexForPage(page, _isLandscape));
    }
    _saveLastPage(page);
  }

  /// Okuma yönünde [delta] kadar (spread) ilerler.
  void _turnPage(int delta) {
    final controller = _pageController;
    if (controller == null || !controller.hasClients || _isZoomed) return;
    final current = controller.page?.round() ?? 0;
    final itemCount = _itemCount(_isLandscape);
    final target = (current + delta).clamp(0, itemCount - 1);
    if (target == current) return;
    controller.animateToPage(target,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  int _itemCount(bool isLandscape) =>
      isLandscape ? (_pageCount / 2).ceil() : _pageCount;

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      return;
    }
    final position = _doubleTapDetails?.localPosition;
    if (position == null) return;
    const scale = 1.75;
    final x = -position.dx * (scale - 1);
    final y = -position.dy * (scale - 1);
    _transformationController.value = Matrix4.identity()
      ..translateByDouble(x, y, 0.0, 1.0)
      ..scaleByDouble(scale, scale, 1.0, 1.0);
  }

  // ───── Liste Dialog (Sûre / Cüz) - Arama destekli ─────
  void _showListDialog(String title, List<QuranSection> items) {
    final activeIndex = activeSectionIndex(items, _currentMushafPage);
    const double itemHeight = 60.0;
    final scrollController = ScrollController(
        initialScrollOffset:
            (activeIndex - 2).clamp(0, items.length) * itemHeight);

    showDialog<int>(
      context: context,
      builder: (dialogContext) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final query = searchQuery.trim();
            final filteredItems = query.isEmpty
                ? items
                : items.where((item) => item.name.contains(query)).toList();

            return AlertDialog(
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: MyApp.primaryColor,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    onChanged: (value) {
                      setDialogState(() => searchQuery = value);
                    },
                    onSubmitted: (_) {
                      if (filteredItems.isNotEmpty) {
                        Navigator.pop(dialogContext, filteredItems.first.page);
                      }
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
                width: 400,
                height: 400,
                child: filteredItems.isEmpty
                    ? const Center(
                        child: Text("نەتىجە تېپىلمىدى",
                            style: TextStyle(color: MyApp.textSecondary)))
                    : ListView.separated(
                        controller: query.isEmpty ? scrollController : null,
                        itemCount: filteredItems.length,
                        separatorBuilder: (ctx, i) =>
                            Divider(height: 1, color: Colors.grey.shade200),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          final isActive = identical(item, items[activeIndex]);
                          return Container(
                            decoration: BoxDecoration(
                              color: isActive
                                  ? MyApp.primaryColor.withValues(alpha: 0.12)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                item.name,
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
                                  "${item.page}-بەت",
                                  style: TextStyle(
                                    color: isActive
                                        ? MyApp.primaryColor
                                        : MyApp.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              onTap: () =>
                                  Navigator.pop(dialogContext, item.page),
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("تاقاش",
                      style: TextStyle(color: MyApp.primaryColor)),
                )
              ],
            );
          },
        );
      },
    ).then((page) {
      scrollController.dispose();
      if (page != null) _goToPage(page);
    });
  }

  // ───── Sayfa Atla Dialogu ─────
  void _showGoToPageDialog() {
    final controller = TextEditingController();
    final maxPage = _pageCount;

    showDialog<int>(
      context: context,
      builder: (dialogContext) {
        String? errorText;
        return StatefulBuilder(builder: (context, setDialogState) {
          void handleSubmit() {
            final page = int.tryParse(controller.text.trim());
            if (page == null || page < 1 || page > maxPage) {
              setDialogState(() => errorText = "1 - $maxPage");
              return;
            }
            Navigator.pop(dialogContext, page);
          }

          return AlertDialog(
            title: const Text("بەتكە يۆتكىلىش",
                style: TextStyle(
                    color: MyApp.primaryColor, fontWeight: FontWeight.bold)),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              autofocus: true,
              onSubmitted: (_) => handleSubmit(),
              decoration: InputDecoration(
                hintText: "1 - $maxPage",
                errorText: errorText,
                prefixIcon:
                    const Icon(Icons.numbers, color: MyApp.primaryColor),
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
                onPressed: () => Navigator.pop(dialogContext),
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
        });
      },
    ).then((page) {
      controller.dispose();
      if (page != null) _goToPage(page);
    });
  }

  // ───── Bookmark Dialog - StatefulBuilder ile anlık güncelleme ─────
  void _showBookmarksDialog() {
    showDialog<int>(
      context: context,
      builder: (dialogContext) {
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
                width: 400,
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
                          final pageNum = _bookmarks[index];
                          final surahName =
                              sectionForPage(surahs, pageNum).name;

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
                                  "$pageNum",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            title: Text("$pageNum-بەت",
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(surahName,
                                style: const TextStyle(
                                    fontSize: 13, color: MyApp.textSecondary)),
                            onTap: () => Navigator.pop(dialogContext, pageNum),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                setState(() {
                                  _bookmarks = [..._bookmarks]..remove(pageNum);
                                });
                                setDialogState(() {});
                                await _saveBookmarks();
                              },
                            ),
                          );
                        },
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("تاقاش",
                      style: TextStyle(color: MyApp.primaryColor)),
                )
              ],
            );
          },
        );
      },
    ).then((page) {
      if (page != null) _goToPage(page);
    });
  }

  // ───── Geri tuşu işleyicisi (PopScope uyumlu) ─────
  bool _shouldExitOnBack() {
    final now = DateTime.now();
    if (_currentBackPressTime == null ||
        now.difference(_currentBackPressTime!) > const Duration(seconds: 2)) {
      _currentBackPressTime = now;
      _showSuccessSnackBar("چىقىش ئۈچۈن قايتا بېسىڭ", icon: Icons.exit_to_app);
      return false;
    }
    return true;
  }

  // ───── Klavye kısayolları (web / masaüstü) ─────
  // Mushaf sağdan sola okunur: sol ok = sonraki sayfa, sağ ok = önceki sayfa.
  Map<ShortcutActivator, VoidCallback> get _shortcuts => {
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _turnPage(1),
        const SingleActivator(LogicalKeyboardKey.pageDown): () => _turnPage(1),
        const SingleActivator(LogicalKeyboardKey.space): () => _turnPage(1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            _turnPage(-1),
        const SingleActivator(LogicalKeyboardKey.pageUp): () => _turnPage(-1),
        const SingleActivator(LogicalKeyboardKey.home): () => _goToPage(1),
        const SingleActivator(LogicalKeyboardKey.end): () =>
            _goToPage(_pageCount),
        const SingleActivator(LogicalKeyboardKey.keyG): _showGoToPageDialog,
        const SingleActivator(LogicalKeyboardKey.keyB): _toggleBookmark,
        const SingleActivator(LogicalKeyboardKey.escape): () {
          _setMenuVisible(false);
        },
      };

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SplashView(
          progress: _loadProgress, downloadedBytes: _downloadedBytes);
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
                onPressed: _retry,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_shouldExitOnBack()) SystemNavigator.pop();
      },
      child: CallbackShortcuts(
        bindings: _shortcuts,
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          child: OrientationBuilder(builder: (context, orientation) {
            return _buildReader(context, orientation);
          }),
        ),
      ),
    );
  }

  Widget _buildReader(BuildContext context, Orientation orientation) {
    final isLandscape = orientation == Orientation.landscape;
    final controller = _controllerFor(orientation);
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final isBookmarked = _bookmarks.contains(_currentMushafPage);
    final maxPage = _pageCount;

    return Scaffold(
      body: Stack(
        children: [
          GestureDetector(
            onTap: () {
              _focusNode.requestFocus();
              _setMenuVisible(!_isMenuVisible);
            },
            onDoubleTapDown: _handleDoubleTapDown,
            onDoubleTap: _handleDoubleTap,
            child: PageView.builder(
              physics: _isZoomed
                  ? const NeverScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              key: ValueKey(orientation),
              controller: controller,
              itemCount: _itemCount(isLandscape),
              onPageChanged: (index) {
                final newPage =
                    _pageForIndex(index, isLandscape).clamp(1, maxPage);
                setState(() => _currentMushafPage = newPage);
                _saveLastPage(newPage);
                _transformationController.value = Matrix4.identity();
              },
              itemBuilder: (context, index) {
                final pageContent = isLandscape
                    ? _buildSpread(index, screenSize)
                    : _buildSinglePage(index);
                return InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 1.0,
                  maxScale: 5.0,
                  child: pageContent,
                );
              },
            ),
          ),
          // Menülere dokunulduğunda otomatik gizleme süresi yenilenir.
          Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: (_) {
              if (_isMenuVisible) _restartMenuHideTimer();
            },
            onPointerMove: (_) {
              if (_isMenuVisible) _restartMenuHideTimer();
            },
            child: Stack(
              children: [
                _buildTopMenu(mediaQuery),
                _buildBottomMenu(mediaQuery, maxPage, isBookmarked),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mushaf sayfası -> PDF sayfa numarası (1 tabanlı).
  int _pdfPageFor(int mushafPage) => mushafPage + QuranReader.pageOffset;

  Widget _buildSinglePage(int index) {
    final mushafPage = _pageForIndex(index, false);
    if (mushafPage > _pageCount) return const SizedBox.shrink();
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(1.0, QuranReader.stretchFactor, 1.0),
      child: ClipRect(
        child: Transform.scale(
          scale: 1.15,
          child: Center(
            child: PdfPageView(
              document: _document!,
              pageNumber: _pdfPageFor(mushafPage),
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    );
  }

  /// Yatay mod: sağda tek (ilk) sayfa, solda çift sayfa.
  Widget _buildSpread(int index, Size screenSize) {
    final rightMushafPage = _pageForIndex(index, true);
    final leftMushafPage = rightMushafPage + 1;

    final horizontalPadding =
        screenSize.shortestSide >= 600 ? screenSize.width * 0.10 : 0.0;
    // Sayfalar hem genişliğe hem yüksekliğe sığmalı (geniş masaüstü ekranlar).
    final onePageWidth = [
      (screenSize.width - horizontalPadding) / 2,
      screenSize.height / (_pageAspectRatio * QuranReader.stretchFactor),
    ].reduce((a, b) => a < b ? a : b);
    final spreadWidth = onePageWidth * 2;
    final spreadHeight = onePageWidth * _pageAspectRatio;

    Widget pageView(int mushafPage, Alignment alignment) {
      if (mushafPage > _pageCount) return const SizedBox.shrink();
      return PdfPageView(
        document: _document!,
        pageNumber: _pdfPageFor(mushafPage),
        alignment: alignment,
      );
    }

    return Center(
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1.0, QuranReader.stretchFactor, 1.0),
        child: Container(
          width: spreadWidth,
          height: spreadHeight,
          color: MyApp.bgColor,
          child: Row(
            // RTL içinde ilk çocuk sağda yer alır.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: pageView(rightMushafPage, Alignment.centerLeft)),
              Container(width: 2, color: Colors.black12),
              Expanded(child: pageView(leftMushafPage, Alignment.centerRight)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopMenu(MediaQueryData mediaQuery) {
    final topInset = mediaQuery.padding.top;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: _isMenuVisible ? 0 : -(kToolbarHeight + topInset + 10),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: topInset),
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
                    sectionForPage(juzs, _currentMushafPage).name,
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
              Tooltip(
                message: "بەتكە يۆتكىلىش",
                child: InkWell(
                  onTap: _showGoToPageDialog,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [MyApp.primaryColor, MyApp.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: MyApp.primaryColor.withValues(alpha: 0.3),
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
              ),
              // Sûre butonu
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.list_alt,
                      color: MyApp.primaryColor, size: 20),
                  label: Text(
                    sectionForPage(surahs, _currentMushafPage).name,
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
    );
  }

  Widget _buildBottomMenu(
      MediaQueryData mediaQuery, int maxPage, bool isBookmarked) {
    final bottomInset = mediaQuery.padding.bottom;
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      bottom: _isMenuVisible ? 0 : -(kToolbarHeight + 60 + bottomInset),
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(bottom: bottomInset),
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
            // Sayfa slider'ı. RTL'de slider'ın başı (1) sağdadır.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Text("1",
                      style:
                          TextStyle(fontSize: 11, color: MyApp.textSecondary)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        activeTrackColor: MyApp.primaryColor,
                        inactiveTrackColor:
                            MyApp.primaryColor.withValues(alpha: 0.15),
                        thumbColor: MyApp.primaryColor,
                        overlayColor:
                            MyApp.primaryColor.withValues(alpha: 0.12),
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 7),
                      ),
                      child: Slider(
                        value: _currentMushafPage
                            .toDouble()
                            .clamp(1, maxPage.toDouble()),
                        min: 1,
                        max: maxPage.toDouble(),
                        divisions: maxPage > 1 ? maxPage - 1 : null,
                        label: "$_currentMushafPage",
                        onChanged: (value) {
                          setState(() => _currentMushafPage = value.round());
                        },
                        onChangeEnd: (value) => _goToPage(value.round()),
                      ),
                    ),
                  ),
                  Text("$maxPage",
                      style: const TextStyle(
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
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.grey.shade300,
                  ),
                  TextButton.icon(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
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
    );
  }
}
