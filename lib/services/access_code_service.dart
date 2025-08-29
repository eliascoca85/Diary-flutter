import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessCodeService {
  static const String _accessCodeKey = 'access_code';
  static const String _accessCodeEnabledKey = 'access_code_enabled';
  static const String _loginStateKey = 'login_state';

  /// Verificar si existe un código de acceso configurado
  static Future<bool> hasAccessCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessCodeKey) != null;
  }

  /// Verificar si el código de acceso está habilitado
  static Future<bool> isAccessCodeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accessCodeEnabledKey) ?? false;
  }

  /// Configurar un nuevo código de acceso
  static Future<bool> setAccessCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hashedCode = _hashCode(code);

      await prefs.setString(_accessCodeKey, hashedCode);
      await prefs.setBool(_accessCodeEnabledKey, true);

      return true;
    } catch (e) {
      print('Error setting access code: $e');
      return false;
    }
  }

  /// Verificar un código de acceso
  static Future<bool> verifyAccessCode(String code) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedHashedCode = prefs.getString(_accessCodeKey);

      if (storedHashedCode == null) {
        return false;
      }

      final hashedInputCode = _hashCode(code);
      return hashedInputCode == storedHashedCode;
    } catch (e) {
      print('Error verifying access code: $e');
      return false;
    }
  }

  /// Habilitar o deshabilitar el código de acceso
  static Future<void> setAccessCodeEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accessCodeEnabledKey, enabled);
  }

  /// Eliminar el código de acceso completamente
  static Future<void> removeAccessCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessCodeKey);
    await prefs.remove(_accessCodeEnabledKey);
    await prefs.remove(_loginStateKey);
  }

  /// Marcar que el usuario ya se autenticó en esta sesión
  static Future<void> setLoginState(bool loggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginStateKey, loggedIn);
  }

  /// Verificar si el usuario ya se autenticó en esta sesión
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginStateKey) ?? false;
  }

  /// Limpiar el estado de login (para cerrar sesión)
  static Future<void> clearLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginStateKey);
  }

  /// Hash del código de acceso usando SHA-256
  static String _hashCode(String code) {
    final bytes = utf8.encode(code);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verificar si la aplicación debe mostrar el PIN al inicio
  static Future<bool> shouldShowPinScreen() async {
    // Solo mostrar PIN si:
    // 1. Hay un código de acceso configurado
    // 2. El código de acceso está habilitado
    // 3. El usuario no se ha autenticado en esta sesión
    final hasCode = await hasAccessCode();
    final isEnabled = await isAccessCodeEnabled();
    final isLoggedIn = await AccessCodeService.isLoggedIn();

    return hasCode && isEnabled && !isLoggedIn;
  }
}
