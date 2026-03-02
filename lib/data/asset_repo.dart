import 'package:flutter/services.dart' show AssetManifest, rootBundle;

class AssetLevel {
  final String base;              // ej. "assets/Planos/"
  final String subpath;           // ej. "CVT/Antiguos/"
  final List<String> folders;     // ej. ["CVT", "LCP"]
  final List<String> files;       // ej. ["Plano1.pdf", "Plano2.png"]
  AssetLevel({required this.base, required this.subpath, required this.folders, required this.files});
}

class AssetRepo {
  /// Carga los "hijos inmediatos" (carpetas/archivos) dentro de [base]+[subpath]
  /// usando la API AssetManifest de Flutter.
  static Future<AssetLevel> loadLevel({
    required String base,     // p.ej. 'assets/Planos/' o 'assets/pdfs/DataSheets/'
    String subpath = '',      // p.ej. 'CVT/' o 'CVT/Antiguos/'
  }) async {
    // Nueva forma oficial de cargar el manifiesto en Flutter 3.22+
    final AssetManifest manifest = await AssetManifest.loadFromAssetBundle(rootBundle);

    String norm(String s) {
      var r = s.replaceAll('\\', '/');
      if (!r.endsWith('/')) r += '/';
      return r;
    }

    final baseDir = norm(base);
    final current = norm('$baseDir$subpath');

    // Obtenemos todos los assets que empiezan con nuestra ruta actual
    final keys = manifest.listAssets().where((k) => k.startsWith(current)).toList();

    final folders = <String>{};
    final files = <String>[];

    for (final full in keys) {
      // ej. full = "assets/Planos/CVT/INTERCEPTOR_FV_5IN.pdf"
      var rel = full.substring(current.length); 
      if (rel.isEmpty) continue;                
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
    final sortedFiles = files..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return AssetLevel(base: baseDir, subpath: subpath, folders: sortedFolders, files: sortedFiles);
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
