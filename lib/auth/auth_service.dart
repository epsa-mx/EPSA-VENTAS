import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'whitelist.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Verifica si el usuario ya está autenticado en Firebase
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// Cierra sesión en Firebase y Google
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// Inicia sesión con Google y valida contra la Whitelist
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Iniciar el flujo de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return 'Inicio de sesión cancelado.';

      // 2. Validar contra la Whitelist antes de completar en Firebase
      final email = googleUser.email.toLowerCase();
      if (!Whitelist.emails.contains(email)) {
        await _googleSignIn.disconnect();
        return 'El correo $email no está autorizado.';
      }

      // 3. Obtener credenciales para Firebase
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Autenticar en Firebase
      await _auth.signInWithCredential(credential);
      
      return null; // Éxito
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Error de autenticación.';
    } catch (e) {
      return 'Error inesperado: $e';
    }
  }

  Future<String?> currentUserEmail() async {
    return _auth.currentUser?.email;
  }
}
