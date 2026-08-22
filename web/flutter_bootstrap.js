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

/// Remove the branded Pulse loader with a smooth fade-out.
/// Safe to call multiple times — checks if the loader still exists.
function _removePulseLoader() {
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

/// Show a fallback error message when the Flutter app fails to load
/// after a reasonable timeout. The user can click "Retry" to reload.
function _showPulseLoaderFallback() {
  var loader = document.getElementById('pulse-loader');
  if (!loader) return;
  // Check if the Flutter app has already taken over (loader was removed)
  if (!loader.parentNode) return;

  // Replace the spinner with an error message
  var ring = loader.querySelector('.pulse-loader-ring');
  var loadingText = loader.querySelector('.pulse-loader-loading');
  if (ring) {
    ring.innerHTML = '<div style="text-align:center;color:#B44DFF;font-size:48px;margin-bottom:8px;">⚠</div>' +
      '<div style="text-align:center;color:#fff;font-size:16px;font-weight:600;max-width:320px;line-height:1.5;">' +
      'The app is taking longer than expected to load. This may be due to a slow connection or a temporary server issue.</div>';
    ring.style.animation = 'none';
  }
  if (loadingText) {
    loadingText.innerHTML = '<a href="javascript:location.reload()" style="color:#9900FF;text-decoration:underline;cursor:pointer;font-weight:600;">Retry</a>';
    loadingText.style.fontSize = '14px';
  }
}

// Timeout: if the app hasn't loaded after 45 seconds, show a fallback
// message with a Retry button instead of leaving the user staring at
// an infinite spinner.
var _pulseLoaderTimeout = setTimeout(_showPulseLoaderFallback, 45000);

_flutter.loader.load({
  onEntrypointLoaded: async function (engineInitializer) {
    try {
      // Initialize the Flutter engine.
      // Note: HTML renderer was removed in Flutter 3.29+.
      // The default renderer (CanvasKit/Skwasm) is determined at build time.
      let appRunner = await engineInitializer.initializeEngine({
        useColorEmoji: true,
      });

      // Run the app — this can throw if the Dart code has a runtime
      // error during initialization. The try/catch ensures the loader
      // is removed even in that case.
      await appRunner.runApp();

      // App loaded successfully — cancel the timeout and remove the
      // branded loader with a smooth fade-out transition.
      clearTimeout(_pulseLoaderTimeout);
      _removePulseLoader();
    } catch (err) {
      // The Flutter engine or app threw an error during initialization.
      // Cancel the timeout, remove the loader, and show an error message
      // so the user isn't stuck staring at an infinite spinner.
      clearTimeout(_pulseLoaderTimeout);
      console.error('[Pulse] Flutter initialization failed:', err);
      _removePulseLoader();

      // Show a minimal error overlay so the user knows something went wrong.
      var errorOverlay = document.createElement('div');
      errorOverlay.style.cssText = 'position:fixed;inset:0;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:16px;background:#07070B;color:#fff;z-index:9999;font-family:sans-serif;';
      errorOverlay.innerHTML =
        '<div style="font-size:48px;">⚠</div>' +
        '<div style="font-size:18px;font-weight:700;">Pulse failed to start</div>' +
        '<div style="font-size:14px;color:#888;max-width:400px;text-align:center;line-height:1.5;">The application encountered an error during initialization. Please try refreshing the page.</div>' +
        '<button onclick="location.reload()" style="background:#9900FF;color:#fff;border:none;padding:12px 24px;border-radius:12;font-size:14px;font-weight:700;cursor:pointer;margin-top:8px;">Retry</button>';
      document.body.appendChild(errorOverlay);
    }
  }
});

