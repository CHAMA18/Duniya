{{flutter_js}}
{{flutter_build_config}}

// ─── Pulse Cache Busting ──────────────────────────────────────────
// BUILD_VERSION is replaced by build.sh with a unique timestamp on
// every deploy. This forces browsers/CDNs to fetch a fresh copy.
const PULSE_BUILD_VERSION = '%%BUILD_VERSION%%';

// ─── Pulse PWA: register the offline service worker ──────────────
// This runs BEFORE the Flutter engine loads so the SW is controlling  // the page by the time the app boots. The SW (pulse_service_worker.js)
// caches the app shell + assets for offline use.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    // Cache-bust the service worker URL so the browser always fetches
    // the latest version (defeats HTTP caches and CDN edge caches).
    var swUrl = '/pulse_service_worker.js?v=' + PULSE_BUILD_VERSION;
    navigator.serviceWorker
      .register(swUrl, { updateViaCache: 'none' })
      .then(function (registration) {
        console.log(
          '[Pulse PWA] Service worker registered with scope:',
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
        console.warn('[Pulse PWA] Service worker registration failed:', err);
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

    // Fade out + remove the branded Pulse loader (#pulse-loader in
    // index.html) once the Flutter app has rendered its first frame.
    // The 400ms fade-out transition gives a smooth handoff from the
    // HTML loading screen to the Flutter canvas.
    var loader = document.getElementById('pulse-loader');
    if (loader) {
      loader.classList.add('fade-out');
      setTimeout(function () {
        if (loader && loader.parentNode) {
          loader.parentNode.removeChild(loader);
        }
      }, 500);
    }
  }
});

