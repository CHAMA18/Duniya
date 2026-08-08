{{flutter_js}}
{{flutter_build_config}}

// ─── Duniya PWA: register the offline service worker ──────────────
// This runs BEFORE the Flutter engine loads so the SW is controlling
// the page by the time the app boots. The SW (duniya_service_worker.js)
// caches the app shell + assets for offline use.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker
      .register('/duniya_service_worker.js', { updateViaCache: 'none' })
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
    // Force the HTML renderer on web to avoid CanvasKit null-check
    // errors caused by font/TextStyle interactions with Skia text
    // rendering.  The HTML renderer is lighter (smaller bundle, lower
    // RAM) and fully compatible with Duniya's UI.
    let appRunner = await engineInitializer.initializeEngine({
      useColorEmoji: true,
      renderer: 'html',
    });
    // Run the app
    await appRunner.runApp();
  }
});
