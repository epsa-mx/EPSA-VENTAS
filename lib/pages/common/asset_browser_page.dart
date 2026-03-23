import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/asset_repo.dart';
import '../../pages/datasheets/open_web.dart'
if (dart.library.html) '../../pages/datasheets/open_web_web.dart';

class AssetBrowserPage extends StatefulWidget {
  final String title;       // Título de la pantalla (p.ej. "Planos" o "Data Sheets")
  final String basePrefix;  // Prefijo raíz (p.ej. 'assets/Planos/' o 'assets/pdfs/DataSheets/')
  final String subpath;     // Subcarpeta actual (inicia en '')
  final bool isAdmin;       // Indica si estamos en modo administrador

  const AssetBrowserPage({
    super.key,
    required this.title,
    required this.basePrefix,
    this.subpath = '',
    this.isAdmin = false,
  });

  @override
  State<AssetBrowserPage> createState() => _AssetBrowserPageState();
}

class _AssetBrowserPageState extends State<AssetBrowserPage> {
  Future<File> _materializeAsset(String assetPath) async {
    final bytes = await rootBundle.load(assetPath);
    final temp = await getTemporaryDirectory();
    final rel = assetPath.split('assets/').last;
    final out = File('${temp.path}/$rel');
    await out.parent.create(recursive: true);
    await out.writeAsBytes(bytes.buffer.asUint8List());
    return out;
  }

  void _openFile(String fullAssetPath) async {
    if (kIsWeb) {
      openPdfOnWeb(fullAssetPath);
    } else {
      final file = await _materializeAsset(fullAssetPath);
      await OpenFilex.open(file.path);
    }
  }

  void _openFolder(String name) {
    final next = (widget.subpath.isEmpty) ? '$name/' : '${widget.subpath}$name/';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => AssetBrowserPage(
        title: widget.title,
        basePrefix: widget.basePrefix,
        subpath: next,
        isAdmin: widget.isAdmin, // Pasamos el estado de admin al navegar
      ),
    ));
  }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.create_new_folder),
            title: const Text('Crear Carpeta'),
            onTap: () {
              Navigator.pop(context);
              // Lógica para crear carpeta en Firebase Storage próximamente
            },
          ),
          ListTile(
            leading: const Icon(Icons.upload_file),
            title: const Text('Subir Archivo'),
            onTap: () {
              Navigator.pop(context);
              // Lógica para subir archivo a Firebase Storage próximamente
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBreadcrumb() {
    final cs = Theme.of(context).colorScheme;
    final crumbs = <Widget>[
      InkWell(
        onTap: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => AssetBrowserPage(
              title: widget.title, 
              basePrefix: widget.basePrefix,
              isAdmin: widget.isAdmin,
            ),
          ));
        },
        child: Text(widget.title, style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w600)),
      ),
    ];

    if (widget.subpath.isNotEmpty) {
      final parts = widget.subpath.split('/').where((e) => e.isNotEmpty).toList();
      String acc = '';
      for (int i = 0; i < parts.length; i++) {
        acc += '${parts[i]}/';
        crumbs.add(const Text(' / '));
        final untilHere = acc;
        crumbs.add(
          InkWell(
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => AssetBrowserPage(
                  title: widget.title,
                  basePrefix: widget.basePrefix,
                  subpath: untilHere,
                  isAdmin: widget.isAdmin,
                ),
              ));
            },
            child: Text(AssetRepo.pretty(parts[i]), style: TextStyle(color: cs.onPrimary)),
          ),
        );
      }
    }
    return crumbs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(children: _buildBreadcrumb())),
      body: FutureBuilder<AssetLevel>(
        future: AssetRepo.loadLevel(base: widget.basePrefix, subpath: widget.subpath),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final level = snap.data!;
          final items = [
            ...level.folders.map((f) => _FolderTile(name: f, onTap: () => _openFolder(f))),
            ...level.files.map((f) {
              final full = AssetRepo.join(level.base, level.subpath, f);
              return _FileTile(
                name: AssetRepo.pretty(f),
                onTap: () => _openFile(full),
              );
            }),
          ];

          if (items.isEmpty) {
            return const Center(child: Text('Vacío'));
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => items[i],
          );
        },
      ),
      // 👇 Botón de añadir solo visible si isAdmin es true
      floatingActionButton: widget.isAdmin 
          ? FloatingActionButton(
              onPressed: _showAddOptions,
              child: const Icon(Icons.add),
            ) 
          : null,
    );
  }
}

class _FolderTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _FolderTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.folder),
      title: Text(AssetRepo.pretty(name)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _FileTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _FileTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SvgPicture.asset(
        'assets/branding/docs_icon.svg',
        height: 24,
        colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn),
      ),
      title: Text(name),
      onTap: onTap,
      trailing: const Icon(Icons.arrow_right),
    );
  }
}
