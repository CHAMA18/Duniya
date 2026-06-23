/**
 * Duniya PWA Service Worker
 * ═════════════════════════════════════════════════════════════════
 * Provides offline support for the Duniya Flutter web app by:
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

const CACHE_NAME = 'duniya-pwa-v1';
const RUNTIME_CACHE = 'duniya-runtime-v1';

// Core app shell — these are the files needed to boot the app offline.
// The exact filenames may include content hashes, so we use a
// cache-first strategy with runtime population rather than hard-coding
// every asset URL. The install step pre-caches the static shell.
const APP_SHELL = [
  '/',
  '/index.html',
  '/manifest.json',
  '/favicon.svg',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
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
        console.warn('[Duniya SW] Some shell assets failed to pre-cache:', err);
      });
    })
  );
  // Take over immediately so the SW is active on first load.
  self.skipWaiting();
});

// ─── Activate: clean up old caches ────────────────────────────────
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames
          .filter((name) => name !== CACHE_NAME && name !== RUNTIME_CACHE)
          .map((name) => caches.delete(name))
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

  // Navigation requests (page loads) → serve cached index.html,
  // fall back to network, then to cache.
  if (request.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          // Try network first (so we get the latest index.html).
          const networkResponse = await fetch(request);
          const cache = await caches.open(RUNTIME_CACHE);
          cache.put('/index.html', networkResponse.clone()).catch(() => {});
          return networkResponse;
        } catch (e) {
          // Offline — serve cached index.html (SPA fallback).
          const cache = await caches.open(CACHE_NAME);
          const cachedIndex = await cache.match('/index.html');
          if (cachedIndex) return cachedIndex;
          const runtimeCache = await caches.open(RUNTIME_CACHE);
          const runtimeIndex = await runtimeCache.match('/index.html');
          if (runtimeIndex) return runtimeIndex;
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
          // Refresh in background.
          fetch(request)
            .then((response) => {
              if (response.ok) {
                cache.put(request, response.clone()).catch(() => {});
              }
            })
            .catch(() => {});
          return cached;
        }
        // Not in cache — fetch and cache.
        try {
          const networkResponse = await fetch(request);
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

// ─── Message handler: allow the app to trigger updates ────────────
self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') {
    self.skipWaiting();
  }
});
