// ─────────────────────────────────────────────────────────────────────────────
// filter_web_font_manifest.dart
//
// Post-build step for the WEB build only (run from build.sh). Rewrites
// build/web/assets/FontManifest.json to remove font families that are only
// needed on native platforms:
//
//   - EraerRegular   — unused legacy font (no references in lib/).
//   - GrutchShaded   — unused legacy font (no references in lib/).
//
// Keeping static Satoshi + MaterialIcons + package icon fonts. The Flutter
// asset declaration excludes Satoshi's variable font files, which CanvasKit
// cannot load safely in this project.
//
// Native builds are unaffected — this script only touches build/web output.
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final path =
      args.isNotEmpty ? args.first : 'build/web/assets/FontManifest.json';
  final file = File(path);
  if (!file.existsSync()) {
    stderr.writeln(
        'filter_web_font_manifest: $path not found — skipping (non-fatal).');
    exit(0);
  }

  final Object? decoded = jsonDecode(file.readAsStringSync());
  if (decoded is! List) {
    stderr.writeln(
        'filter_web_font_manifest: unexpected FontManifest format — skipping.');
    exit(0);
  }

  const nativeOnlyFamilies = {'EraerRegular', 'GrutchShaded'};
  final kept = <dynamic>[];
  var dropped = 0;
  for (final entry in decoded) {
    if (entry is! Map<String, dynamic>) {
      kept.add(entry);
      continue;
    }
    final family = (entry['family'] as String? ?? '').trim();
    if (nativeOnlyFamilies.contains(family)) {
      dropped++;
      continue;
    }
    kept.add(entry);
  }

  file.writeAsStringSync(const JsonEncoder.withIndent('  ').convert(kept));

  // Safety check: the web app hard-requires static Satoshi. If it ever
  // disappears from the manifest, fail instead of silently shipping a font
  // fallback or reintroducing the CanvasKit null-font blank-page crash.
  final hasSatoshi = kept.any((entry) =>
      entry is Map<String, dynamic> &&
      (entry['family'] as String? ?? '').trim() == 'Satoshi');
  stdout.writeln(
      'filter_web_font_manifest: kept ${kept.length}/${decoded.length} '
      'families (dropped $dropped native-only). Satoshi present: $hasSatoshi');
  if (!hasSatoshi) {
    stderr.writeln(
        'filter_web_font_manifest: ERROR — "Satoshi" family is missing from '
        'the web FontManifest. The web app will crash (CanvasKit null-font). '
        'Check pubspec.yaml fonts section.');
    exit(1);
  }
}
