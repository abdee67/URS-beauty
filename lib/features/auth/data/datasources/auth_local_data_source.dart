import 'package:shared_preferences/shared_preferences.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const _tokenKey = 'AUTH_TOKEN';

  final SharedPreferences _prefs;
  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> cacheToken(String token) {
    return _prefs.setString(_tokenKey, token);
  }

  @override
  Future<String?> getCachedToken() {
    return Future.value(_prefs.getString(_tokenKey));
  }

  @override
  Future<void> clearToken() {
    return _prefs.remove(_tokenKey);
  }
}
