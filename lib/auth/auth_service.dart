// lib/auth/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'whitelist.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  static const _keyAuthed = 'epsa_authed_email';
  static const _keyWhen   = 'epsa_authed_at';

  // Cambia este PIN si lo deseas; en producción, usa variables de entorno o remoto.
  // Si quieres usar HASH, guarda aquí el SHA256 del PIN real.
  static const String _pinPlano = '5728';            // ⚠️ PIN plano (simple)
  // static final String _pinHash = sha256.convert(utf8.encode('1234')).toString(); // Alternativa: hash

  Future<bool> isLoggedIn() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyAuthed) != null;
  }

  Future<void> logout() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_keyAuthed);
    await sp.remove(_keyWhen);
  }

  /// Autentica: email en whitelist + PIN correcto
  Future<String?> loginWithEmailAndPin(String email, String pin) async {
    final normalized = email.trim().toLowerCase();
    if (!Whitelist.emails.contains(normalized)) {
      return 'Este correo no está autorizado (whitelist).';
    }

    // Validación de PIN simple
    if (pin != _pinPlano) {
      return 'PIN incorrecto.';
    }

    // Si usas hash:
    // final pinHash = sha256.convert(utf8.encode(pin)).toString();
    // if (pinHash != _pinHash) return 'PIN incorrecto.';

    final sp = await SharedPreferences.getInstance();
    await sp.setString(_keyAuthed, normalized);
    await sp.setInt(_keyWhen, DateTime.now().millisecondsSinceEpoch);
    return null; // null = OK
  }

  Future<String?> currentUserEmail() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_keyAuthed);
  }
}
