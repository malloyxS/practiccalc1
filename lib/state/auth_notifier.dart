import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/auth_api.dart';
import '../core/api_exceptions.dart';
import '../core/session_config.dart';
import '../models/app_user.dart';
import '../models/role.dart';

class AuthNotifier extends ChangeNotifier {
  static const kAccess = 'auth_access_token';
  static const kRefresh = 'auth_refresh_token';
  static const kRole = 'auth_role';
  static const kActivity = 'auth_last_activity';
  static const kSessionStart = 'auth_session_start';

  final SharedPreferences _prefs;
  final AuthApi _api;

  AuthNotifier(this._prefs, this._api);

  AppUser? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _refreshing = false;

  AppUser? get user => _user;
  String? get accessToken => _accessToken;
  bool get isAuthenticated => _user != null;

  /// Роль для отрисовки интерфейса. Берётся из localStorage,
  /// поэтому её можно подменить в DevTools. Решение на сервере от этого не зависит.
  Role get uiRole => Role.parse(_prefs.getString(kRole) ?? _user?.role.id);

  bool has(Role role) => isAuthenticated && uiRole.level >= role.level;

  bool get isReader => uiRole == Role.reader;
  bool get isLibrarian => uiRole == Role.librarian;
  bool get isAdmin => uiRole == Role.admin;

  bool can(Operation operation) =>
      isAuthenticated && canPerform(uiRole, operation);

  Future<void> restore() async {
    final access = _prefs.getString(kAccess);
    final refresh = _prefs.getString(kRefresh);
    if (access == null) return;

    if (_sessionExpired()) {
      await logout();
      return;
    }

    _accessToken = access;
    _refreshToken = refresh;
    try {
      _user = await _api.me();
    } on UnauthorizedException {
      if (refresh != null) {
        try {
          await refreshTokens();
        } catch (_) {
          await logout();
          return;
        }
      } else {
        await logout();
        return;
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final result = await _api.login(username, password);
    await _apply(result);
  }

  Future<void> register({
    required String username,
    required String password,
    required String displayName,
  }) async {
    final result = await _api.register(
      username: username,
      password: password,
      displayName: displayName,
    );
    await _apply(result);
  }

  Future<void> refreshTokens() async {
    if (_refreshing) {
      while (_refreshing) {
        await Future<void>.delayed(const Duration(milliseconds: 40));
      }
      return;
    }
    final refresh = _refreshToken ?? _prefs.getString(kRefresh);
    if (refresh == null) {
      throw const UnauthorizedException();
    }
    _refreshing = true;
    try {
      final result = await _api.refresh(refresh);
      await _apply(result, keepSessionStart: true);
    } finally {
      _refreshing = false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    await _prefs.remove(kAccess);
    await _prefs.remove(kRefresh);
    await _prefs.remove(kRole);
    await _prefs.remove(kActivity);
    await _prefs.remove(kSessionStart);
    notifyListeners();
  }

  @visibleForTesting
  void debugAssign(AppUser user) {
    _user = user;
    notifyListeners();
  }

  Future<void> _apply(
    AuthTokens result, {
    bool keepSessionStart = false,
  }) async {
    _accessToken = result.accessToken;
    _refreshToken = result.refreshToken;
    _user = result.user;
    await _prefs.setString(kAccess, result.accessToken);
    await _prefs.setString(kRefresh, result.refreshToken);
    await _prefs.setString(kRole, result.user.role.id);
    await touchActivity();
    if (!keepSessionStart || _prefs.getString(kSessionStart) == null) {
      await _prefs.setString(kSessionStart, DateTime.now().toIso8601String());
    }
    notifyListeners();
  }

  Future<void> touchActivity() async {
    await _prefs.setString(kActivity, DateTime.now().toIso8601String());
  }

  DateTime? get lastActivity {
    final raw = _prefs.getString(kActivity);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  DateTime? get sessionStartedAt {
    final raw = _prefs.getString(kSessionStart);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  bool idleExpired({Duration? timeout}) {
    final last = lastActivity;
    if (last == null) return false;
    return DateTime.now().difference(last) >=
        (timeout ?? const Duration(seconds: idleSeconds));
  }

  bool _sessionExpired() {
    final started = sessionStartedAt;
    if (started == null) return false;
    return DateTime.now().difference(started) >=
        const Duration(seconds: sessionMaxSeconds);
  }

  bool get sessionExpired => _sessionExpired();
}
