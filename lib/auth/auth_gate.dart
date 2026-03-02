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
        body: Center(child: CircularProgressIndicator(color: cs.primary)),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [cs.surface, cs.background],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/branding/epsa_logo.svg',
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),
            
            Text(
              'Ventas EPSA',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: cs.secondary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Acceso exclusivo para personal autorizado',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 50),

            if (_error != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.error, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
            ],

            SizedBox(
              width: 280,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _loginGoogle,
                icon: SvgPicture.network(
                  'https://www.gstatic.com/lamda/images/google_signin_buttons/google_icon.svg',
                  height: 24,
                ),
                label: const Text(
                  'Iniciar sesión con Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: cs.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
