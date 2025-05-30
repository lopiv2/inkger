import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/buttons/import_button.dart';
import 'package:inkger/frontend/buttons/scan_pendings_button.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class TopBar extends StatefulWidget {
  bool isSidebarVisible = true;
  final VoidCallback onToggleSidebar;
  Color backGroundColor = Colors.red;
  Color borderColor = Colors.red;
  TopBar({
    super.key,
    required this.isSidebarVisible,
    required this.onToggleSidebar,
    required this.backGroundColor,
    required this.borderColor,
  });

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _overlayEntry?.remove();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesProvider>(context);
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: widget.backGroundColor,
        border: Border.all(color: widget.borderColor, width: 2),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: widget.onToggleSidebar,
          ),
          const SizedBox(width: 10),
          // Barra de búsqueda
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  controller: _controller,
                  onChanged: (query) async {
                    _searchQuery = query;
                    await _performSearch(query);
                  },
                  decoration: InputDecoration(
                    hintText: '${AppLocalizations.of(context)!.search}...',
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.search, color: Colors.black),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          const ImportIconButton(
            iconSize: 32,
            iconColor: Colors.green,
            tooltipText: 'Subir documentos',
            showBadge: false,
          ),
          const ScanPendingFilesButton(
            iconSize: 32,
            iconColor: Colors.lightGreen,
            tooltipText: 'Escanear archivos pendientes',
          ),
          AnimatedToggleSwitch<bool>.dual(
            animationDuration: Duration(seconds: 1),
            current: preferences.preferences.readerMode,
            first: false,
            second: true,
            height: 30,
            spacing: 50.0,
            style: const ToggleStyle(
              borderColor: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            styleBuilder: (b) =>
                ToggleStyle(indicatorColor: b ? Colors.red : Colors.green),
            iconBuilder: (value) => value
                ? const Icon(Icons.history_edu)
                : const Icon(Icons.library_books),
            textBuilder: (value) => value
                ? const Center(child: Text('Writer'))
                : const Center(child: Text('Reader')),
            onChanged: (b) {
              preferences.toggleFullReaderMode(b); // ya no necesitas comparar
              context.go(b ? '/home-writer' : '/home');
            },
          ),
          // Avatar
          PopupMenuButton<String>(
            offset: Offset(0, 80),
            icon: const CircleAvatar(
              backgroundImage: AssetImage('images/avatars/avatar_01.png'),
              radius: 30,
            ),
            onSelected: (String value) {
              switch (value) {
                case 'profile':
                  context.push("/user-profile");
                  break;
                case 'settings':
                  context.push("/settings");
                  break;
                case 'logout':
                  logout(context);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Perfil'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Configuración'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Cerrar sesión'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }

  void _showOverlay() {
    // Eliminar overlay anterior si existe
    _overlayEntry?.remove();
    _overlayEntry =
        null; // <-- Añadir esta línea para evitar reinserción del viejo overlay

    if (_searchResults.isEmpty) return; // No mostrar si no hay resultados

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: 300,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4.0,
            child: ListView(
              shrinkWrap: true,
              children: _searchResults.map((item) {
                final isComic = item.runtimeType.toString().contains('Comic');
                return ListTile(
                  title: Text(item.title),
                  onTap: () async {
                    final providerBooks = Provider.of<BooksProvider>(
                      context,
                      listen: false,
                    );
                    final providerComics = Provider.of<ComicsProvider>(
                      context,
                      listen: false,
                    );

                    if (isComic) {
                      await providerComics.loadcomics(item.id);
                      context.push(
                        '/item-details/comic/${item.id}',
                        extra: item.toJson(),
                      );
                    } else {
                      await providerBooks.loadBooks(item.id);
                      context.push(
                        '/item-details/book/${item.id}',
                        extra: item.toJson(),
                      );
                    }

                    _overlayEntry?.remove();
                    _overlayEntry = null; // <-- También aquí
                    _controller.clear();
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    final providerBooks = Provider.of<BooksProvider>(context, listen: false);
    final providerComics = Provider.of<ComicsProvider>(context, listen: false);

    final books = providerBooks.books
        .where((b) => b.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    final comics = providerComics.comics
        .where((c) => c.title.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _searchResults = [...books, ...comics];
    });

    _showOverlay();
  }
}
