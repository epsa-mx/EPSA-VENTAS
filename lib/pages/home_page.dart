import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:epsa_ventas/pages/common/asset_browser_page.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget tile(String text, VoidCallback onTap, {double h = 120}) {
      return InkWell(
        onTap: onTap,
        child: Container(
          height: h,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: kElevationToShadow[2],
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(12),
          child: Text(text, textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xffffffff), letterSpacing: 1.2)),
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
                launchUrlString('https://forms.gle/oCgTbsf6uGCzage88');
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
        ],
      ),
    );
  }
}

