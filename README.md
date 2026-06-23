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
