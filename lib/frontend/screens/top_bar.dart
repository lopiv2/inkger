import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/buttons/import_button.dart';
import 'package:inkger/frontend/buttons/scan_pendings_button.dart';
import 'package:inkger/frontend/utils/functions.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
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
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: Icon(Icons.search, color: Colors.black),
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
}
