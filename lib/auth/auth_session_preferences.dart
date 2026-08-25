import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's *preference* for restoring an authenticated session.
///
/// Passwords and Firebase tokens are intentionally never written here. Firebase
/// Auth owns credentials; this store contains only the remembered email and
/// selected login tab needed to restore the login experience safely.
class AuthSessionPreferences {
  AuthSessionPreferences._();

  static final AuthSessionPreferences instance = AuthSessionPreferences._();

  static const _rememberSessionKey = 'pulse.auth.rememberSession';
  static const _emailKey = 'pulse.auth.rememberedEmail';
  static const _loginModeKey = 'pulse.auth.rememberedLoginMode';

  SharedPreferences? _preferences;

  Future<void> initialize() async {
    _preferences ??= await SharedPreferences.getInstance();
  }

  bool get rememberSession =>
      _preferences?.getBool(_rememberSessionKey) ?? false;

  String get rememberedEmail => _preferences?.getString(_emailKey) ?? '';

  int get rememberedLoginMode => _preferences?.getInt(_loginModeKey) ?? 0;

  Future<void> save({
    required bool rememberSession,
    required String email,
    required int loginMode,
  }) async {
    await initialize();
    if (!rememberSession) {
      await clear();
      return;
    }

    await _preferences!.setBool(_rememberSessionKey, true);
    await _preferences!.setString(_emailKey, email.trim());
    await _preferences!.setInt(_loginModeKey, loginMode);
  }

  Future<void> clear() async {
    await initialize();
    await _preferences!.remove(_rememberSessionKey);
    await _preferences!.remove(_emailKey);
    await _preferences!.remove(_loginModeKey);
  }
}
