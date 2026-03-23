import 'package:flutter/material.dart';
import '../common/asset_browser_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget adminTile(String title, String prefix, IconData icon) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: cs.primary,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            backgroundColor: cs.secondary,
            child: Icon(icon, color: Colors.white),
          ),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => AssetBrowserPage(
                title: '$title (Admin)',
                basePrefix: prefix,
                isAdmin: true,
              ),
            ));
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: cs.secondary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Seleccione la sección a gestionar:',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          const SizedBox(height: 20),
          adminTile('Data Sheets', 'assets/pdfs/Datasheets/', Icons.description),
          adminTile('Planos e Información Técnica', 'assets/pdfs/Planos/', Icons.architecture),
          
          const SizedBox(height: 40),
          Card(
            color:cs.onSurface,
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Nota: Las subidas se sincronizarán automaticamente en la nube.',
                      style: TextStyle(fontSize: 12, color:Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
