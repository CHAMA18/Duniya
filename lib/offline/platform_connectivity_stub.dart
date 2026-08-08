import 'dart:async';

/// Stub (non-web) implementation: assumes always online.
/// Mobile/desktop platforms use Firebase's built-in retry logic.
bool get isOnline => true;

/// No-op stream that never emits (never offline on non-web).
Stream<Event> get onOnline => const Stream.empty();
Stream<Event> get onOffline => const Stream.empty();
