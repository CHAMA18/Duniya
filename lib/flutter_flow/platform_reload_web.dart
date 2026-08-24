/// Web implementation: triggers a full browser page reload.
import 'dart:html' as html;

Future<void> reloadPage() async {
  html.window.location.reload();
}
