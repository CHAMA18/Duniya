---
title: Build & Deploy
description: Build the Duniya Flutter web app and deploy it to production.
---

# Build & Deploy

This page covers how to build the Duniya Flutter web app from source and
deploy it to a production environment.

---

## Prerequisites

- **Flutter SDK 3.35.5** (or compatible). Install from
  [flutter.dev](https://docs.flutter.dev/get-started/install).
- **Dart 3.9.2** (bundled with Flutter).
- A Firebase project with Firestore, Auth, and Storage enabled.
- The Duniya source code (clone from GitHub).

---

## Local development

### 1. Clone the repo

```bash
git clone https://github.com/CHAMA18/Duniya.git
cd Duniya
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

The Firebase configuration is in `lib/firebase_options.dart`. If you are
forking the project, replace the configuration values with your own
Firebase project's config:

```dart
// lib/firebase_options.dart
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'YOUR_PROJECT_ID',
      authDomain: 'YOUR_PROJECT.firebaseapp.com',
      storageBucket: 'YOUR_PROJECT.appspot.com',
    );
  }
}
```

### 4. Run in debug mode

```bash
flutter run -d chrome
```

This launches the app in Chrome in debug mode with hot reload.

---

## Production build

### 1. Build the web bundle

```bash
flutter build web --release
```

This produces optimised JavaScript, HTML, and assets in `build/web/`.

The build output includes:

- `index.html` — the entry point.
- `main.dart.js` — the compiled Dart code (minified).
- `flutter.js` — the Flutter bootstrap script.
- `assets/` — fonts, images, and other assets.
- `flutter_service_worker.js` — for offline caching.

### 2. Verify the build

You can serve the build locally to verify it works:

```bash
# Using Python's built-in HTTP server
cd build/web
python3 -m http.server 8080

# Or using Node's http-server
npx http-server build/web -p 8080
```

Open `http://localhost:8080` in your browser.

---

## Deployment options

### Option A — Docker (recommended for production)

The repo includes a `Dockerfile` and `nginx.conf` for containerised
deployment.

```bash
# Build the Docker image
docker build -t duniya-web .

# Run the container
docker run -p 80:80 duniya-web
```

The container serves the web bundle via nginx on port 80.

### Option B — Render.com

The repo includes a `render.yaml` for one-click deployment to Render.

1. Push the repo to GitHub.
2. Go to [render.com](https://render.com) and create a new Static Site.
3. Connect your GitHub repo.
4. Render will detect `render.yaml` and configure the deployment
   automatically.

### Option C — Static file server (Node)

For development or small-scale hosting, use the bundled `serve_web.dart`:

```bash
# Build the web bundle
flutter build web --release

# Serve it
dart run serve_web.dart
```

This serves the bundle on port 3000 by default.

### Option D — Any static file host

Because `build/web/` is a self-contained static bundle, you can deploy it
to any static file host:

- **Firebase Hosting** — `firebase deploy --only hosting`
- **Netlify** — drag and drop the `build/web/` folder.
- **Vercel** — `vercel --prod` from the project root.
- **GitHub Pages** — push the contents of `build/web/` to a `gh-pages`
  branch.

---

## Environment-specific configuration

### Firebase configuration

The Firebase config is baked into the build at compile time. To use a
different Firebase project per environment, create multiple
`firebase_options_*.dart` files and switch on `--dart-define` flags:

```bash
flutter build web --release \
  --dart-define=FIREBASE_ENV=production
```

Then in `lib/firebase_options.dart`:

```dart
const env = String.fromEnvironment('FIREBASE_ENV', defaultValue: 'dev');
final options = env == 'production'
    ? ProductionFirebaseOptions.currentPlatform
    : DevFirebaseOptions.currentPlatform;
```

### API keys

DPO and Stripe keys are currently hardcoded in
`lib/backend/api_requests/api_calls.dart`. For production, move these to
Firebase Remote Config or a Cloud Function proxy.

---

## CI/CD pipeline

A recommended GitHub Actions workflow:

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.35.5'
      - run: flutter pub get
      - run: flutter build web --release
      - name: Deploy to Firebase Hosting
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: ${{ secrets.GITHUB_TOKEN }}
          firebaseServiceAccount: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          channelId: live
          projectId: your-firebase-project-id
```

---

## Post-deploy verification

After deploying, verify:

1. **The app loads** — open the URL in a browser; you should see the
   Duniya login page.
2. **Authentication works** — sign in with a test account.
3. **Firestore is reachable** — the Home dashboard should populate with
   data (or show an empty state if the account has no pharmacies).
4. **Payments work** (production only) — test a small subscription
   payment via DPO or Stripe.
5. **The purple theme is preserved** — the primary buttons should be
   `#9900FF`. If they are a different color, the theme was overwritten
   during build.

---

## Troubleshooting

??? question "The build fails with 'Wasm dry run findings'"
    This is a warning, not an error. Duniya uses `dart:html` for web-only
    features (file download, blob creation) which is incompatible with
    WebAssembly. The build will succeed with JavaScript compilation. You
    can suppress the warning with `--no-wasm-dry-run`.

??? question "The app loads but shows a blank screen"
    Check the browser console for JavaScript errors. The most common
    cause is a misconfigured Firebase project — verify that the API key,
    project ID, and auth domain in `lib/firebase_options.dart` match your
    Firebase project.

??? question "The purple theme is gone after rebuilding"
    You likely ran FlutterFlow's theme generator, which overwrites
    `lib/flutter_flow/flutter_flow_theme.dart`. Restore the file from
    git: `git checkout lib/flutter_flow/flutter_flow_theme.dart`.

??? question "Fonts are missing"
    The Satoshi font must be present in `assets/fonts/`. Verify the
    `pubspec.yaml` declares the font asset:
    ```yaml
    fonts:
      - family: Satoshi
        fonts:
          - asset: assets/fonts/Satoshi-Variable.woff2
    ```

??? question "The Excel import fails on deployment"
    The `excel` package requires the file picker to work. On web, ensure
    the browser has permission to access the file system. The picker
    should work in all modern browsers without additional configuration.
