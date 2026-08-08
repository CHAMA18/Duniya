import 'dart:async';

/// Stub (non-web) implementation: assumes always online.
/// Mobile/desktop platforms use Firebase's built-in retry logic.
bool get isOnline => true;

/// No-op stream that never emits (never offline on non-web).
/// Uses `void` as the stream type — callers only need to know *when*
/// connectivity changes, not what the event payload is.
Stream<void> get onOnline => const Stream.empty();
Stream<void> get onOffline => const Stream.empty();
