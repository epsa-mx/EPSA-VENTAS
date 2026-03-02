import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../main.dart'; 

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final ok = await AuthService.instance.isLoggedIn();
    if (!mounted) return;
    if (ok) {
      _goHome();
    } else {
      setState(() => _loading = false);
    }
  }

  void _goHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Shell()),
    );
  }

  Future<void> _loginGoogle() async {
    setState(() { _error = null; _loading = true; });

    final msg = await AuthService.instance.signInWithGoogle();

    if (!mounted) return;
    if (msg != null) {
      setState(() { _error = msg; _loading = false; });
    } else {
      _goHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 👇 Logo movido fuera de la caja
                SvgPicture.asset(
                  'assets/branding/epsa_logo.svg',
                  height: 240,
                  fit: BoxFit.contain,
                ),
                
                const SizedBox(height: 40),

                // Caja principal (ahora contiene el botón y errores)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: kElevationToShadow[4],
                  ),
                  child: Column(
                    children: [
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: cs.error, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],

                      // Botón de Google con texto de acceso integrado
                      InkWell(
                        onTap: _loginGoogle,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: kElevationToShadow[0],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.network(
                                    'https://www.gstatic.com/lamda/images/google_signin_buttons/google_icon.svg',
                                    height: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'INGRESAR CON GOOGLE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Acceso exclusivo para personal de comercial',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
