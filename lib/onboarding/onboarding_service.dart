import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent onboarding state for the Duniya app.
///
/// Wraps a small set of SharedPreferences flags so we can:
///   - remember whether the user has ever seen the full tour
///     (so we auto-launch it once on first login and never again),
///   - remember which chapters the user has already completed
///     (so a returning user who taps "Take Tour" can skip chapters
///     they've already seen, or resume where they left off).
///
/// All methods are no-ops if SharedPreferences hasn't been initialised
/// — they degrade gracefully to "show the tour" rather than crashing.
class OnboardingService {
  OnboardingService._();
  static final OnboardingService instance = OnboardingService._();

  static const _kTourCompletedKey = 'duniya.onboarding.tourCompleted';
  static const _kTourCompletedAtKey = 'duniya.onboarding.tourCompletedAt';
  static const _kChapterSeenKey = 'duniya.onboarding.chapterSeen.';

  SharedPreferences? _prefs;

  /// Initialise the backing store. Call once at app startup (in
  /// main.dart, after FFLocalizations.initialize()).
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// True if the user has completed the full tour at least once.
  bool get hasCompletedTour => _prefs?.getBool(_kTourCompletedKey) ?? false;

  /// Timestamp when the user last completed the tour, or null if never.
  DateTime? get tourCompletedAt {
    final ms = _prefs?.getInt(_kTourCompletedAtKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  /// Mark the tour as fully completed. Called when the user reaches the
  /// final step and taps "Get Started", or when they tap "Skip".
  Future<void> markTourCompleted() async {
    await _prefs?.setBool(_kTourCompletedKey, true);
    await _prefs?.setInt(
        _kTourCompletedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Reset the tour state — the next time the user lands on Home, the
  /// tour will auto-launch. Useful for testing or for users who want to
  /// see the tour again.
  Future<void> resetTour() async {
    await _prefs?.remove(_kTourCompletedKey);
    await _prefs?.remove(_kTourCompletedAtKey);
    final keys = _prefs?.getKeys() ?? <String>{};
    for (final key in keys) {
      if (key.startsWith(_kChapterSeenKey)) {
        await _prefs?.remove(key);
      }
    }
  }

  /// True if the user has seen the given chapter (by id).
  bool hasSeenChapter(String chapterId) =>
      _prefs?.getBool('$_kChapterSeenKey$chapterId') ?? false;

  /// Mark a chapter as seen.
  Future<void> markChapterSeen(String chapterId) async {
    await _prefs?.setBool('$_kChapterSeenKey$chapterId', true);
  }
}
