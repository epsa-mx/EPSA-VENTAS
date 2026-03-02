import 'package:flutter/material.dart';
import 'package:epsa_ventas/pages/home_page.dart';
import 'package:epsa_ventas/pages/tools_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/auth_gate.dart';
import 'auth/auth_service.dart';
import 'package:epsa_ventas/core/update_watcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const EpsaApp());
}

class EpsaApp extends StatelessWidget {
  const EpsaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final light = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFB31017),
        secondary: Color(0xFF173C5B),
        surface: Color(0xFFF6FCFC),
        background: Color(0xFFF4F4F4),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black,
        onBackground: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6FCFC),
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF173C5B),
        indicatorColor: Color(0xFFB31017),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );

    final dark = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF014365),
        secondary: Color(0xFFB31017),
        surface: Color(0xFF003049),
        background: Color(0xFF121212),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onBackground: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF003049),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF173C5B),
        indicatorColor: Color(0xFFB31017),
        labelTextStyle: MaterialStatePropertyAll(
          TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );

    return MaterialApp(
      title: 'EPSA Ventas',
      theme: light,
      darkTheme: dark,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class Shell extends StatefulWidget {
  const Shell({super.key});
  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;
  final pages = const [HomePage(), ToolsPage()];

  @override
  Widget build(BuildContext context) {
    return UpdateWatcher(
      interval: const Duration(minutes: 5),
      child: Scaffold(
        appBar: AppBar(
          title: SvgPicture.asset(
            'assets/branding/epsa_logo.svg',
            height: 150,
            fit: BoxFit.contain,
          ),
          centerTitle: true,
          elevation: 0,
          actions: [
            PopupMenuButton(
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
              ],
              onSelected: (value) async {
                if (value == 'logout') {
                  await AuthService.instance.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const AuthGate()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
        body: pages[index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Herramientas'),
          ],
          onDestinationSelected: (i) => setState(() => index = i),
        ),
      ),
    );
  }
}
