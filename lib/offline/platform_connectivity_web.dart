import 'dart:html' as html;
import 'dart:async';

/// Web implementation: uses browser online/offline events.
bool get isOnline => html.window.navigator.onLine ?? true;

/// Streams that emit browser Event objects on connectivity change.
Stream<html.Event> get onOnline => html.window.onOnline;
Stream<html.Event> get onOffline => html.window.onOffline;
