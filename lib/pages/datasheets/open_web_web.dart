import 'package:web/web.dart' as web;

/// Abre el PDF desde /assets/... respetando el base-href (GitHub Pages).
void openPdfOnWeb(String assetPath) {
  // Quita slash inicial para resolver correctamente sobre el base-href
  final normalized = assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;

  // En Flutter Web, los assets viven bajo "/assets/". Como tu ruta lógica
  // ya empieza con "assets/...", el path final debe ser "assets/<assetPath>"
  // -> ej. "assets/assets/pdfs/..."
  final resolved = Uri.base.resolve('assets/$normalized').toString();

  try {
    web.window.location.assign(resolved); // misma pestaña
  } catch (_) {
    web.window.open(resolved, '_self');   // fallback
  }
}

