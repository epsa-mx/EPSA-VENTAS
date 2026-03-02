// lib/core/update_watcher.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ✅ Recarga multiplataforma (stub en móvil, web real en navegador)
import 'package:epsa_ventas/core/browser_reload_stub.dart'
if (dart.library.html) 'package:epsa_ventas/core/browser_reload_web.dart';

/// Envuelve tu app y revisa periódicamente si hay un build nuevo en el servidor.
/// - Lee `version.json` (si existe) o, en su defecto, `AssetManifest.json`.
/// - Si cambia el hash/versión: muestra diálogo, limpia sesión y recarga.
class UpdateWatcher extends StatefulWidget {
  final Widget child;

  /// Cada cuánto checar. Puedes subirlo a 5–10 min en producción.
  final Duration interval;

  const UpdateWatcher({
    super.key,
    required this.child,
    this.interval = const Duration(minutes: 2),
  });

  @override
  State<UpdateWatcher> createState() => _UpdateWatcherState();
}

class _UpdateWatcherState extends State<UpdateWatcher> {
  Timer? _timer;
  String? _lastSeenVersion; // versión/hint visto localmente

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _boot() async {
    final prefs = await SharedPreferences.getInstance();
    _lastSeenVersion = prefs.getString('app.version_seen');

    // Chequeo inmediato
    unawaited(_checkForUpdate());

    // Programar chequeo periódico
    _timer = Timer.periodic(widget.interval, (_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    try {
      final version = await _fetchRemoteVersion();
      if (version == null || version.isEmpty) return;

      // Primera vez: persistir y salir
      if (_lastSeenVersion == null) {
        _lastSeenVersion = version;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('app.version_seen', version);
        return;
      }

      // Si cambió: avisar → cerrar sesión → recargar
      if (version != _lastSeenVersion) {
        if (!mounted) return;
        await _showUpdateDialogAndReload(version);
      }
    } catch (e) {
      // Silencioso para no romper UX por problemas de red
      debugPrint('UpdateWatcher: error checking updates: $e');
    }
  }

  Future<String?> _fetchRemoteVersion() async {
    // Construye URLs relativas respetando el base-href (GitHub Pages)
    String bust() => DateTime.now().millisecondsSinceEpoch.toString();

    // 1) Intentar version.json (si existe en tu build/web)
    try {
      final vUrl = Uri.base.resolve('version.json?cb=${bust()}');
      final vRes = await http.get(vUrl, headers: {'Cache-Control': 'no-cache'});
      if (vRes.statusCode == 200 && vRes.body.isNotEmpty) {
        try {
          final map = json.decode(vRes.body) as Map<String, dynamic>;
          // Cualquier campo usable como “firma” del build
          return map['app_version']?.toString()
              ?? map['version']?.toString()
              ?? map['flutter_version']?.toString()
              ?? vRes.body; // fallback: cuerpo completo
        } catch (_) {
          return vRes.body; // si no es JSON válido, usa cuerpo
        }
      }
    } catch (_) {
      // continúa con fallback
    }

    // 2) Fallback: AssetManifest.json (cambia cada build)
    try {
      final aUrl = Uri.base.resolve('AssetManifest.json?cb=${bust()}');
      final aRes = await http.get(aUrl, headers: {'Cache-Control': 'no-cache'});
      if (aRes.statusCode == 200 && aRes.body.isNotEmpty) {
        final b = aRes.body;
        // Hash barato: largo + primeras/últimas letras
        return 'AMJ-${b.length}-${b.substring(0, 20)}...${b.substring(b.length - 20)}';
      }
    } catch (_) {
      // continúa con fallback
    }

    // 3) Último fallback: headers de main.dart.js (etag/last-modified)
    try {
      final mUrl = Uri.base.resolve('main.dart.js?cb=${bust()}');
      final mRes = await http.head(mUrl, headers: {'Cache-Control': 'no-cache'});
      if (mRes.statusCode == 200) {
        final etag = mRes.headers['etag'];
        final lm = mRes.headers['last-modified'];
        if (etag != null || lm != null) {
          return 'JS:${etag ?? ''}|${lm ?? ''}';
        }
      }
    } catch (_) {}

    return null;
  }

  Future<void> _showUpdateDialogAndReload(String newVersion) async {
    // Evita mostrar múltiples diálogos
    _timer?.cancel();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva versión disponible'),
        content: const Text(
          'Se publicó una nueva versión de la aplicación.\n'
              'Para continuar, se cerrará tu sesión y se recargará la página.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // 1) Limpiar sesión (ajusta si guardas claves específicas)
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              await prefs.setString('app.version_seen', newVersion);

              // 2) Recargar (web) o reiniciar navegación (móvil)
              if (kIsWeb) {
                reloadPage(); // ✅ implementado vía import condicional
              } else {
                if (context.mounted) {
                  Navigator.of(ctx).pop(); // cierra diálogo
                  Navigator.of(ctx).pushNamedAndRemoveUntil('/', (r) => false);
                }
              }
            },
            child: const Text('Actualizar ahora'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
