# قۇرئان كەرىم — Kur'an Okuyucu

Flutter ile yazılmış, PDF tabanlı Kur'an-ı Kerim mushaf okuyucusu (Uygurca arayüz, sağdan sola).

**Web sürümü:** https://forgotten1432.github.io/quran_app/

## Özellikler

- Dikey modda tek sayfa, yatay modda / masaüstünde çift sayfa (ekrana sığacak şekilde)
- Sure ve cüz listesi (aramalı), sayfaya git, kaydırıcı
- Yer imleri ve son okunan sayfanın hatırlanması
- Çift dokunuşla / parmakla yakınlaştırma
- Web/masaüstü klavye kısayolları:
  `←` / `Space` / `PageDown` sonraki sayfa, `→` / `PageUp` önceki sayfa,
  `Home` / `End` ilk / son sayfa, `G` sayfaya git, `B` yer imi, `Esc` menüyü kapat
- Web'de PDF indirme ilerlemesi (yüzde) gösterilir
- Menü 5 saniye dokunulmazsa kendiliğinden gizlenir
- **Okuma modları:** normal, sepya ve gece (sayfa renkleri ters çevrilir, süsleme tonları korunur)
- **Ekranı açık tutma:** okurken ekran kararmaz (ayarlardan kapatılabilir)
- **Kaldığın yerden devam:** açılışta son okunan sure ve sayfa kartı
- **Hatim takibi:** ekranda 3 sn kalan sayfa okundu sayılır; ilerleme yüzdesi,
  okunmamış ilk sayfaya gitme, tamamlanan hatimlerin listesi
- **Günlük hatırlatma** (yalnızca yerel Android / iOS / macOS derlemelerinde; PWA'da yok)
- **Web'de çevrimdışı kullanım:** PDF ilk açılışta önbelleğe alınır (`web/sw.js`),
  sonra internetsiz açılır

## Geliştirme

`assets/quran.pdf` (~200 MB) Git LFS ile saklanır:

```bash
git lfs install && git lfs pull
flutter pub get
flutter test
flutter run            # veya: flutter run -d chrome
```

## Yayınlama

- **GitHub Pages:** `main` dalına her push'ta `.github/workflows/pages.yml` web sürümünü derleyip yayınlar.
  İlk kurulumda depo ayarlarında *Settings → Pages → Source: GitHub Actions* seçilmelidir.
- Uygulama yalnızca **PWA** olarak dağıtılır (Android/macOS derlemesi yapılmıyor).
  Telefonda tarayıcı menüsünden *Ana ekrana ekle* ile uygulama gibi kurulabilir.
