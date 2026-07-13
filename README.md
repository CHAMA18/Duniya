# MediTracker

A new Flutter project.

## Getting Started

FlutterFlow projects are built to run on the Flutter _stable_ release.

---

## ⚠️ CRITICAL BUILD RULE — READ BEFORE REBUILDING

**NEVER rebuild from source and deploy without verifying the purple theme is preserved.**

The deployed app uses a `#9900FF` purple theme (Duniya brand). This theme was originally applied via surgical JS edits to the compiled `main.dart.js`. The source code has now been updated to include the purple theme (see `flutter_flow_theme.dart` and `main.dart`), but:

1. The **live deployed build** at `medi-tracker-deploy/public/main.dart.js` is the source of truth
2. Any new build from source MUST be verified to include the purple theme before deployment
3. The safe approach for adding features is **surgical JS edits** to the compiled `main.dart.js`
4. The Flutter build output directory (`build/`) has been intentionally removed to prevent accidental rebuilds

If you must rebuild:
- Verify `flutter_flow_theme.dart` has `Color(0xFF9900FF)` as primary
- Verify `main.dart` has `Color(0xFF9900FF)` as primaryColor
- Build and compare the new `main.dart.js` size (~6.5MB) with the deployed one
- Obfuscate API keys before pushing to GitHub
- Test thoroughly before deploying

---

## 🚀 Render deployment

### Current setup: Static Site (no instance-hour limit)

`render.yaml` deploys Duniya as a **Render Static Site** (`runtime: static`). This is the correct service type for a Flutter web app, which produces only static HTML/JS/CSS.

Why not the previous Docker web service:
- Render free **web services** get 750 instance-hours/month — a 24/7 service consumes ~720 of those just staying alive, leaving almost no headroom for rebuilds. Partway through the month deploys would fail with "pipeline exhausted".
- Render **static sites** are served from a CDN with **no instance-hour limit**. They have a separate 500 build-minutes/month quota, which is more than enough for ~25 Flutter web rebuilds a month.

### One-time migration (Render dashboard)

If you still have the old Docker web service (`medi-tracker`):

1. **Create a new Static Site** on Render → New → Static Site → connect the GitHub repo → Render will read `render.yaml` and pre-fill the config. Service name will be `duniya-web`.
2. **Verify the build** completes successfully. The build runs `./build.sh`, which:
   - Downloads Flutter 3.24.5 from the pinned tarball (cached on `/opt/render-cache` for subsequent builds).
   - Runs `flutter pub get` then `flutter build web --release --web-renderer html`.
   - Copies `web/_redirects` to `build/web/_redirects` so deep links like `/loginUni` work on the CDN.
3. **Wire up the custom domain** `ivm.duniyahealthcare.com` on the new static site (Settings → Custom Domains).
4. **Delete the old `medi-tracker` web service** once traffic is verified on the new static site.

### Local reproduction of the production build

```bash
./build.sh          # outputs to ./build/web
# Then serve locally to test:
python3 -m http.server --directory build/web 8080
```

### Files involved

| File | Purpose |
|---|---|
| `render.yaml` | Render service definition (static site). |
| `build.sh` | Build pipeline script (Flutter install + `flutter build web`). |
| `web/_redirects` | SPA fallback rule copied into the build output. |
| `Dockerfile` | Fallback Docker runtime (kept for reference; not used by static site). |
| `nginx.conf` | Fallback nginx config (only used if you re-enable the Docker service). |
| `.dockerignore` | Excludes `skills/`, `upload/`, `ios/`, `android/`, `.git/` etc. from Docker context. |

### Troubleshooting

- **Build OOMs at `flutter build web`**: switch renderer to `html` (already set in `build.sh`). Canvaskit builds of this app need 2–4 GB RAM; html needs ~1.5 GB. If you still OOM, upgrade the Render plan to a paid tier for builds only.
- **Deep links 404**: ensure `web/_redirects` is present and `build.sh` ran the copy step.
- **Custom domain not serving**: Render static sites need the domain added under Settings → Custom Domains AND the DNS CNAME pointing to Render's `onrender.com` host.
- **Build still "pipeline exhausted"**: this means you've used up the 500 free build-minutes for the month. Either wait for the next billing cycle, upgrade to a paid plan, or reduce deploy frequency.
