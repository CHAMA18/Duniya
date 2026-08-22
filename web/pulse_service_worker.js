/**
 * Pulse PWA Service Worker
 * ═════════════════════════════════════════════════════════════════
 * Provides offline support for the Pulse Flutter web app by:
 *
 * 1. Pre-caching the app shell (index.html, main.dart.js, flutter.js,
 *    canvaskit, fonts, favicons) on install so the app boots offline.
 * 2. Serving cached assets cache-first (instant loads, no network).
 * 3. Falling back to the cached index.html for navigation requests
 *    (SPA route handling — Flutter handles client-side routing).
 * 4. Using a network-first strategy for Firestore/Auth requests so
 *    live data is always preferred when online, cache as fallback.
 *
 * The service worker is registered from flutter_bootstrap.js (see
 * the registration block at the bottom of this file).
 */

// CACHE_VERSION is replaced by build.sh with a timestamp-based version
// on every deploy. This ensures the service worker busts all caches
// automatically when a new version is deployed.
const CACHE_VERSION = '%%BUILD_VERSION%%';
const CACHE_NAME = `pulse-pwa-${CACHE_VERSION}`;
const RUNTIME_CACHE = `pulse-runtime-${CACHE_VERSION}`;

// Core app shell — these are the files needed to boot the app offline.
// The exact filenames may include content hashes, so we use a
// cache-first strategy with runtime population rather than hard-coding
// every asset URL. The install step pre-caches the static shell.
// Version query params ensure CDN/browsers don't serve stale copies.
const APP_SHELL = [
  `/`,
  `/index.html?v=${CACHE_VERSION}`,
  `/app.html?v=${CACHE_VERSION}`,
  `/404.html?v=${CACHE_VERSION}`,
  `/landing.html?v=${CACHE_VERSION}`,
  `/loader-splash.png?v=${CACHE_VERSION}`,
  `/manifest.json?v=${CACHE_VERSION}`,
  `/flutter_bootstrap.js?v=${CACHE_VERSION}`,
  `/favicon.svg`,
  `/favicon.png`,
  `/icons/Icon-192.png`,
  `/icons/Icon-512.png`,
];

// Files that should always be served cache-first (they're either
// immutable hashed assets or static brand assets).
const CACHE_FIRST_PATTERNS = [
  /\/main\.dart\.js/,
  /\/flutter\.js/,
  /\/flutter_bootstrap\.js/,
  /\/canvaskit\//,
  /\/assets\//,
  /\/icons\//,
  /\.png$/,
  /\.svg$/,
  /\.woff2?$/,
  /\.ttf$/,
  /\.otf$/,
];

// Firebase / Google API endpoints — network-first (live data preferred),
// cache as fallback when offline.
const NETWORK_FIRST_PATTERNS = [
  /firestore\.googleapis\.com/,
  /identitytoolkit\.googleapis\.com/,
  /securetoken\.googleapis\.com/,
  /firebaseinstallations\.googleapis\.com/,
  /www\.gstatic\.com\/flutter-canvaskit/,
];

// ─── Install: pre-cache the app shell ─────────────────────────────
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => {
      return cache.addAll(APP_SHELL).catch((err) => {
        // Some shell URLs might 404 (e.g. /favicon.svg before build);
        // don't fail the whole install for that.
        console.warn('[Pulse SW] Some shell assets failed to pre-cache:', err);
      });
    })
  );
  // Take over immediately so the SW is active on first load.
  self.skipWaiting();
});

// ─── Activate: clean up old caches (cache busting) ────────────────
// On every new deploy, CACHE_VERSION changes, so the old caches are
// automatically purged. This is the core cache-busting mechanism.
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== RUNTIME_CACHE)
          .map((name) => {
            console.log('[Pulse SW] Deleting old cache:', name);
            return caches.delete(name);
          })
      );
    })
  );
  // Claim all clients so the SW controls the page immediately.
  self.clients.claim();
});

// ─── Fetch: strategy routing ──────────────────────────────────────
self.addEventListener('fetch', (event) => {
  const request = event.request;

  // Only handle GET requests.
  if (request.method !== 'GET') {
    return;
  }

  const url = new URL(request.url);

  // Skip cross-origin requests that aren't Firebase/Google APIs
  // (we don't want to cache third-party tracking pixels, etc.)
  const isSameOrigin = url.origin === self.location.origin;
  const isFirebaseApi = NETWORK_FIRST_PATTERNS.some((p) => p.test(url.href));
  const isCanvasKit = /www\.gstatic\.com\/flutter-canvaskit/.test(url.href);

  if (!isSameOrigin && !isFirebaseApi && !isCanvasKit) {
    return;
  }

  // Navigation requests (page loads) → network-first with cache busting.
  // Always fetch fresh HTML from the server; only fall back to
  // cache when offline. For deep-link paths (e.g. /pointOfSale),
  // the server returns 404.html (the SPA shell) which loads Flutter
  // and the router handles the route.
  if (request.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          // Network first — always get the latest HTML.
          // Add a cache-busting query param to defeat intermediate caches.
          const bustUrl = new URL(request.url);
          bustUrl.searchParams.set('_v', CACHE_VERSION);
          const networkResponse = await fetch(bustUrl.href, {
            cache: 'no-cache',
            credentials: 'same-origin',
          });
          const cache = await caches.open(RUNTIME_CACHE);
          // Cache the response keyed by the original URL (not the
          // cache-busted URL) so it can be served offline.
          cache.put(request.url, networkResponse.clone()).catch(() => {});
          return networkResponse;
        } catch (e) {
          // Offline — try to serve from cache.
          const runtimeCache = await caches.open(RUNTIME_CACHE);
          // Try the exact URL first (deep-link path cached from a
          // previous online visit).
          const cachedExact = await runtimeCache.match(request.url);
          if (cachedExact) return cachedExact;
          // Fall back to cached index.html (root page).
          const cache = await caches.open(CACHE_NAME);
          const cachedIndex = await cache.match('/index.html');
          if (cachedIndex) return cachedIndex;
          // Fall back to cached app.html (SPA shell).
          const cachedApp = await cache.match('/app.html');
          if (cachedApp) return cachedApp;
          // Fall back to cached 404.html (SPA fallback shell).
          const cached404 = await cache.match('/404.html');
          if (cached404) return cached404;
          throw e;
        }
      })()
    );
    return;
  }

  // Firebase/Google API requests → network-first with cache fallback.
  if (isFirebaseApi) {
    event.respondWith(
      (async () => {
        try {
          const networkResponse = await fetch(request);
          // Only cache successful responses.
          if (networkResponse.ok) {
            const cache = await caches.open(RUNTIME_CACHE);
            cache.put(request, networkResponse.clone()).catch(() => {});
          }
          return networkResponse;
        } catch (e) {
          // Offline — try cache.
          const cache = await caches.open(RUNTIME_CACHE);
          const cached = await cache.match(request);
          if (cached) return cached;
          throw e;
        }
      })()
    );
    return;
  }

  // App assets (main.dart.js, canvaskit, fonts, images) → cache-first.
  const isCacheFirst = CACHE_FIRST_PATTERNS.some((p) => p.test(url.pathname));
  if (isCacheFirst) {
    event.respondWith(
      (async () => {
        const cache = await caches.open(RUNTIME_CACHE);
        const cached = await cache.match(request);
        if (cached) {
          // Refresh in background — cache-busted so CDN/browser HTTP caches
          // can never pin a stale immutable copy of e.g. main.dart.js from
          // a previous deploy.
          fetchWithBust(request)
            .then((response) => {
              if (response.ok) {
                cache.put(request, response.clone()).catch(() => {});
              }
            })
            .catch(() => {});
          return cached;
        }
        // Not in cache — fetch and cache (cache-busted).
        try {
          const networkResponse = await fetchWithBust(request);
          if (networkResponse.ok) {
            cache.put(request, networkResponse.clone()).catch(() => {});
          }
          return networkResponse;
        } catch (e) {
          // Offline and not cached — nothing we can do.
          throw e;
        }
      })()
    );
    return;
  }

  // Default: try network, fall back to cache.
  event.respondWith(
    (async () => {
      try {
        const networkResponse = await fetch(request);
        if (networkResponse.ok && isSameOrigin) {
          const cache = await caches.open(RUNTIME_CACHE);
          cache.put(request, networkResponse.clone()).catch(() => {});
        }
        return networkResponse;
      } catch (e) {
        const cache = await caches.open(RUNTIME_CACHE);
        const cached = await cache.match(request);
        if (cached) return cached;
        throw e;
      }
    })()
  );
});

// Fetch a URL with a per-deploy cache-busting query param so immutable /
// long-lived HTTP caches can never pin a stale bundle (main.dart.js is
// served with `Cache-Control: immutable` but its filename does NOT change
// between builds). CACHE_VERSION changes on every deploy, so this always
// pulls the freshest file from the CDN.
function fetchWithBust(request) {
  const bustUrl = new URL(request.url);
  bustUrl.searchParams.set('_v', CACHE_VERSION);
  return fetch(bustUrl.href, { cache: 'no-cache', credentials: 'same-origin' });
}

// ─── Message handler: allow the app to trigger updates ────────────
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') {
    self.skipWaiting();
  }
  if (event.data === 'GET_VERSION') {
    event.ports[0].postMessage({ version: CACHE_VERSION });
  }
  if (event.data && event.data.type === 'FORCE_UPDATE') {
    // Clear all caches and force a full reload.
    caches.keys().then((names) => {
      Promise.all(names.map((n) => caches.delete(n))).then(() => {
        self.skipWaiting();
      });
    });
  }
});
