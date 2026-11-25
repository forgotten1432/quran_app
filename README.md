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
- **Android / macOS:** `.github/workflows/release.yml` APK ve DMG üretir; `v*` etiketlerinde GitHub Release oluşturur.
