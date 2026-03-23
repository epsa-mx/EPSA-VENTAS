import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:epsa_ventas/pages/common/asset_browser_page.dart';
import 'package:epsa_ventas/pages/admin/admin_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // PIN de acceso para el modo administrador
  static const String _adminPin = '2025';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Helper para crear los botones estilizados
    Widget tile(String text, VoidCallback onTap, {double h = 120, Color? color}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          height: h,
          decoration: BoxDecoration(
            color: color ?? cs.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: kElevationToShadow[2],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Text(
            text, 
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xffffffff), 
              letterSpacing: 1.2,
              fontSize: 18, 
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Diálogo para ingresar el PIN de administrador
    void showAdminPinDialog() {
      final controller = TextEditingController();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Acceso Administrador'),
          content: TextField(
            controller: controller,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ingrese el PIN',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),

            ),
            FilledButton(
              onPressed: () {
                if (controller.text == _adminPin) {
                  Navigator.pop(context);
                  // Navegamos al Panel de Administración
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AdminPage(),
                  ));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PIN Incorrecto'), 
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('ENTRAR'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: tile('FORMULARIO DE\nVISITA', () {
                launchUrlString('https://forms.gle/XF9nfYehFXK5FPd57');
              })),
              const SizedBox(width: 12),
              Expanded(child: tile('DATA SHEETS', () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const AssetBrowserPage(
                    title: 'Data Sheets',
                    basePrefix: 'assets/pdfs/Datasheets/',
                  ),
                ));
              })),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: tile('STORY\nTELLINGS', () {
                launchUrlString('https://drive.google.com/drive/folders/1utFLJ9Sj9gcXdkd0HmJIvzNu-L665-SO?usp=sharing');
              })),
              const SizedBox(width: 12),
              Expanded(child: tile('REPORTE DE\nPENDIENTES', () {
                launchUrlString('https://docs.google.com/spreadsheets/d/1Y_X89_2wGli1pJpA7FsuCExsTdJjHeT_m1pUas_uw2Q/edit?resourcekey=&gid=1726008976#gid=1726008976');
              })),
            ],
          ),
          const SizedBox(height: 12),
          tile('PLANOS E INFORMACION TECNICA', () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const AssetBrowserPage(
                title: 'Planos',
                basePrefix: 'assets/pdfs/Planos/',
              ),
            ));
          }, h: 140),
          
          const SizedBox(height: 12),

          tile(
            'ADMINISTRADOR', 
            showAdminPinDialog, 
            h: 140,
            color: cs.secondary,
          ),
        ],
      ),
    );
  }
}
