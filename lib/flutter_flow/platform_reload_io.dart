/// Mobile/desktop implementation: no-op (caller should restart the app).
///
/// Calling `html.window.location.reload()` is a no-op on native platforms.
/// Real app restart is the host OS's responsibility (e.g. Android's
/// System.exit(0) + PendingIntent, or just letting the user force-quit).
Future<void> reloadPage() async {
  // No-op on mobile/desktop.
}
