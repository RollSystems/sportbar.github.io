const CACHE_NAME = 'marcador-cache-v1';
const ASSETS = [
  './sport-bar-app.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  // Network-first para el HTML principal, para que siempre traigas la última versión si hay internet
  if (req.mode === 'navigate' || req.url.includes('sport-bar-app.html')) {
    event.respondWith(
      fetch(req)
        .then((res) => {
          const copy = res.clone();
          caches.open(CACHE_NAME).then((cache) => cache.put(req, copy));
          return res;
        })
        .catch(() => caches.match(req).then((res) => res || caches.match('./sport-bar-app.html')))
    );
    return;
  }
  // Cache-first para el resto (íconos, manifest)
  event.respondWith(
    caches.match(req).then((cached) => cached || fetch(req))
  );
});
