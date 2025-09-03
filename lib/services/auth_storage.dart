import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  static const _key = 'accessToken';

  // Настройки платформ (чтоб надёжно держался после перезагрузки и т.п.)
  static const _aOptions = AndroidOptions(encryptedSharedPreferences: true);
  static const _iOptions = IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static const _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) =>
      _storage.write(key: _key, value: token, aOptions: _aOptions, iOptions: _iOptions);

  Future<String?> readToken() =>
      _storage.read(key: _key, aOptions: _aOptions, iOptions: _iOptions);

  Future<void> deleteToken() =>
      _storage.delete(key: _key, aOptions: _aOptions, iOptions: _iOptions);
}
