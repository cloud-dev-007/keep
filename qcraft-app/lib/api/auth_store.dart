import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds the auth token + current user, persisted across restarts.
/// A ChangeNotifier so the root widget can swap between Login and Home.
class AuthStore extends ChangeNotifier {
  static const _kToken = 'auth_token';
  static const _kEmail = 'auth_email';
  static const _kName = 'auth_name';

  String? _token;
  String? _email;
  String? _name;
  bool _loaded = false;

  String? get token => _token;
  String? get email => _email;
  String? get name => _name;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// True once the persisted token has been read from disk.
  bool get loaded => _loaded;

  /// Load any persisted session. Call once at startup.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_kToken);
    _email = prefs.getString(_kEmail);
    _name = prefs.getString(_kName);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setSession({
    required String token,
    String? email,
    String? name,
  }) async {
    _token = token;
    _email = email;
    _name = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    if (email != null) await prefs.setString(_kEmail, email);
    if (name != null) await prefs.setString(_kName, name);
    notifyListeners();
  }

  Future<void> clear() async {
    _token = null;
    _email = null;
    _name = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kEmail);
    await prefs.remove(_kName);
    notifyListeners();
  }
}

/// Single shared instance.
final AuthStore authStore = AuthStore();
