// Çevrimdışı kullanım için service worker.
// - Mushaf PDF'i: önbellek öncelikli (bir kez indirilir, sonra internetsiz açılır).
// - Uygulama dosyaları: önbellekten hemen sun, arka planda güncelle.
// - Sayfa (navigasyon): önce ağ, ağ yoksa önbellekteki index.html.
const APP_CACHE = 'quran-app-v1';
const PDF_CACHE = 'quran-pdf-v1';
const KEEP = [APP_CACHE, PDF_CACHE];
// Flutter'ın Arapça vb. yedek fontları buradan gelir.
const FONT_ORIGIN = 'https://fonts.gstatic.com';

// Uygulamanın açılması için gereken çekirdek dosyalar.
const CORE = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'main.dart.js',
  'manifest.json',
  'favicon.png',
  'canvaskit/canvaskit.js',
  'canvaskit/canvaskit.wasm',
  'assets/FontManifest.json',
  'assets/AssetManifest.bin.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const cache = await caches.open(APP_CACHE);
    // Biri başarısız olsa bile diğerlerini önbelleğe al.
    await Promise.all(CORE.map((u) => cache.add(u).catch(() => {})));
  })());
  self.skipWaiting();
});

// Sayfa, SW devreye girmeden önce yüklediği dosyaların listesini gönderir.
self.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.type !== 'cache-urls' || !Array.isArray(data.urls)) return;
  event.waitUntil((async () => {
    const cache = await caches.open(APP_CACHE);
    for (const u of data.urls) {
      try {
        const url = new URL(u, self.location.href);
        const sameOrigin = url.origin === self.location.origin;
        if ((!sameOrigin && url.origin !== FONT_ORIGIN) || url.pathname.endsWith('.pdf')) continue;
        if (!(await cache.match(url.href))) await cache.add(url.href);
      } catch (e) { /* yoksay */ }
    }
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    for (const key of await caches.keys()) {
      if (!KEEP.includes(key)) await caches.delete(key);
    }
    await self.clients.claim();
  })());
});

async function cacheFirst(cacheName, request) {
  const cache = await caches.open(cacheName);
  const hit = await cache.match(request);
  if (hit) return hit;
  const response = await fetch(request);
  if (response.ok) cache.put(request, response.clone()).catch(() => {});
  return response;
}

async function pdfFirst(request) {
  const cache = await caches.open(PDF_CACHE);
  const hit = await cache.match(request, { ignoreSearch: true });
  if (hit) return hit;
  const response = await fetch(request);
  if (response.ok && response.status === 200) {
    cache.put(request, response.clone()).catch(() => {});
  }
  return response;
}

async function staleWhileRevalidate(event) {
  const cache = await caches.open(APP_CACHE);
  const hit = await cache.match(event.request);
  const update = fetch(event.request).then((response) => {
    if (response.ok && response.status === 200) {
      cache.put(event.request, response.clone()).catch(() => {});
    }
    return response;
  });
  if (hit) {
    event.waitUntil(update.catch(() => {}));
    return hit;
  }
  return update;
}

async function networkFirstPage(request) {
  const cache = await caches.open(APP_CACHE);
  try {
    const response = await fetch(request);
    if (response.ok) cache.put('index.html', response.clone()).catch(() => {});
    return response;
  } catch (e) {
    return (await cache.match('index.html')) || (await cache.match('./')) || Response.error();
  }
}

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin === FONT_ORIGIN) {
    event.respondWith(cacheFirst(APP_CACHE, request));
    return;
  }
  if (url.origin !== self.location.origin) return;
  // Kısmi (Range) isteklere dokunma.
  if (request.headers.has('range')) return;

  if (url.pathname.endsWith('.pdf')) {
    event.respondWith(pdfFirst(request));
  } else if (request.mode === 'navigate') {
    event.respondWith(networkFirstPage(request));
  } else {
    event.respondWith(staleWhileRevalidate(event));
  }
});
