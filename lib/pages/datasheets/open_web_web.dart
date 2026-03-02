import 'package:web/web.dart' as web;

/// Abre el PDF desde /assets/... respetando el base-href (GitHub Pages).
void openPdfOnWeb(String assetPath) {
  // 1. Quitar slash inicial si existe
  String path = assetPath.startsWith('/') ? assetPath.substring(1) : assetPath;

  // 2. Flutter Web pone TODO dentro de una carpeta física llamada "assets"
  // Si tu assetPath ya empieza con "assets/", no queremos duplicarlo.
  // Pero en el sistema de archivos del build, la ruta es:
  // [dominio]/[base-href]/assets/[assetPath]
  
  // Como Uri.base.resolve ya incluye el base-href, solo necesitamos 
  // asegurarnos de que el path apunte a la carpeta física 'assets/' del build.
  
  final resolved = Uri.base.resolve('assets/$path').toString();

  try {
    web.window.location.assign(resolved); // misma pestaña
  } catch (_) {
    web.window.open(resolved, '_self');   // fallback
  }
}
