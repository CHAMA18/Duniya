{{flutter_js}}
{{flutter_build_config}}

// ─── Duniya Cache Busting ──────────────────────────────────────────
// BUILD_VERSION is replaced by build.sh with a unique timestamp on
// every deploy. This forces browsers/CDNs to fetch a fresh copy.
const DUNIYA_BUILD_VERSION = '%%BUILD_VERSION%%';

// ─── Duniya PWA: register the offline service worker ──────────────
// This runs BEFORE the Flutter engine loads so the SW is controlling
// the page by the time the app boots. The SW (duniya_service_worker.js)
// caches the app shell + assets for offline use.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    // Cache-bust the service worker URL so the browser always fetches
    // the latest version (defeats HTTP caches and CDN edge caches).
    var swUrl = '/duniya_service_worker.js?v=' + DUNIYA_BUILD_VERSION;
    navigator.serviceWorker
      .register(swUrl, { updateViaCache: 'none' })
      .then(function (registration) {
        console.log(
          '[Duniya PWA] Service worker registered with scope:',
          registration.scope
        );
        // Check for updates every 5 minutes (cache busting —
        // ensures users get the latest version quickly).
        setInterval(function () {
          registration.update().catch(function () {});
        }, 5 * 60 * 1000);

        // When a new service worker is waiting, force it to activate.
        // This ensures cache busting takes effect immediately.
        if (registration.waiting) {
          registration.waiting.postMessage('SKIP_WAITING');
        }
        registration.addEventListener('updatefound', function () {
          var newWorker = registration.installing;
          if (newWorker) {
            newWorker.addEventListener('statechange', function () {
              if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                // New version available — force activate it.
                newWorker.postMessage('SKIP_WAITING');
              }
            });
          }
        });
      })
      .catch(function (err) {
        console.warn('[Duniya PWA] Service worker registration failed:', err);
      });
  });
}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    // Initialize the Flutter engine.
    // Note: HTML renderer was removed in Flutter 3.29+.
    // The default renderer (CanvasKit/Skwasm) is determined at build time.
    let appRunner = await engineInitializer.initializeEngine({
      useColorEmoji: true,
    });
    // Run the app
    await appRunner.runApp();
  }
});
