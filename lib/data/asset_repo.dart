import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class AssetLevel {
  final String base;              // ej. "assets/Planos/"
  final String subpath;           // ej. "CVT/Antiguos/"
  final List<String> folders;     // ej. ["CVT", "LCP"]
  final List<String> files;       // ej. ["Plano1.pdf", "Plano2.png"]
  AssetLevel({required this.base, required this.subpath, required this.folders, required this.files});
}

class AssetRepo {
  /// Carga los "hijos inmediatos" (carpetas/archivos) dentro de [base]+[subpath]
  /// leyendo AssetManifest.json. Soporta niveles anidados arbitrarios.
  static Future<AssetLevel> loadLevel({
    required String base,     // p.ej. 'assets/Planos/' o 'assets/pdfs/DataSheets/'
    String subpath = '',      // p.ej. 'CVT/' o 'CVT/Antiguos/'
  }) async {
    final raw = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifest = json.decode(raw);

    String norm(String s) {
      var r = s.replaceAll('\\', '/');
      if (!r.endsWith('/')) r += '/';
      return r;
    }

    final baseDir = norm(base);
    final current = norm('$baseDir$subpath');

    final keys = manifest.keys.where((k) => k.startsWith(current)).toList();

    final folders = <String>{};
    final files = <String>[];

    for (final full in keys) {
      // ej. full = "assets/Planos/CVT/INTERCEPTOR_FV_5IN.pdf"
      var rel = full.substring(current.length); // "INTERCEPTOR_FV_5IN.pdf" o "CVT/..."
      if (rel.isEmpty) continue;                // carpeta exacta
      final slash = rel.indexOf('/');

      if (slash >= 0) {
        // hay más niveles -> es carpeta inmediata
        final folder = rel.substring(0, slash);
        folders.add(folder);
      } else {
        // es archivo directo de este nivel
        files.add(rel);
      }
    }

    final sortedFolders = folders.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    files.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return AssetLevel(base: baseDir, subpath: subpath, folders: sortedFolders, files: files);
  }

  /// Helper para componer rutas
  static String join(String base, String subpath, String name) {
    String j = '$base$subpath$name';
    return j.replaceAll('//', '/');
  }

  /// Nombre bonito para mostrar archivos
  static String pretty(String fileOrFolder) {
    final noExt = fileOrFolder.split('.').first;
    return noExt.replaceAll(RegExp(r'[_\-]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
