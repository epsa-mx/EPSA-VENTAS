import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'whitelist.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // En la web, es recomendable pasar el clientId explícitamente si hay problemas
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  Future<void> logout() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<String?> signInWithGoogle() async {
    try {
      // 1. Iniciar el flujo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Inicio de sesión cancelado.';

      // 2. Validar contra la Whitelist
      final email = googleUser.email.toLowerCase();
      if (!Whitelist.emails.contains(email)) {
        await _googleSignIn.disconnect();
        return 'El correo $email no está autorizado.';
      }

      // 3. Obtener credenciales
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Validación de seguridad para evitar el "Null check operator"
      if (googleAuth.idToken == null && googleAuth.accessToken == null) {
        return 'No se pudieron obtener las credenciales de Google.';
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Autenticar en Firebase
      await _auth.signInWithCredential(credential);
      
      return null; 
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Error de Firebase: ${e.code}';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<String?> currentUserEmail() async {
    return _auth.currentUser?.email;
  }
}
