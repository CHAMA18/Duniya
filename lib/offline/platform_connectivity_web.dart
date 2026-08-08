import 'dart:html' as html;
import 'dart:async';

/// Web implementation: uses browser online/offline events.
bool get isOnline => html.window.navigator.onLine ?? true;

Stream<Event> get onOnline => html.window.onOnline;
Stream<Event> get onOffline => html.window.onOffline;
