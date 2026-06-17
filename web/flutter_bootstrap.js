{{flutter_js}}
{{flutter_build_config}}

// ─── Duniya PWA: register the offline service worker ──────────────
// This runs BEFORE the Flutter engine loads so the SW is controlling
// the page by the time the app boots. The SW (duniya_service_worker.js)
// caches the app shell + assets for offline use.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker
      .register('/duniya_service_worker.js')
      .then(function (registration) {
        console.log(
          '[Duniya PWA] Service worker registered with scope:',
          registration.scope
        );
        // Check for updates every hour.
        setInterval(function () {
          registration.update().catch(function () {});
        }, 60 * 60 * 1000);
      })
      .catch(function (err) {
        console.warn('[Duniya PWA] Service worker registration failed:', err);
      });
  });
}

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    // Initialize the Flutter engine
    let appRunner = await engineInitializer.initializeEngine({
      useColorEmoji: true,
    });
    // Run the app
    await appRunner.runApp();
  }
});
