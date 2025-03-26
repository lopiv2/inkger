import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/buttons/import_button.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Widget content; // Recibirá el contenido dinámico desde el router

  const HomeScreen({super.key, required this.content});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarVisible = true;
  bool _isLoading = true;
  String? _errorMessage;

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPreferences();
    });
  }

  Future<void> loadPreferences() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await PreferenceService.initializeDirectories();
      final preferencesProvider = Provider.of<PreferencesProvider>(
        context,
        listen: false,
      );
      await preferencesProvider.refreshPathsFromDatabase();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /*if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }*/
    
    return Scaffold(
      body: Row(
        children: [
          // Sidebar con animación
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isSidebarVisible ? 250 : 0,
            child: Visibility(
              visible: _isSidebarVisible,
              child: Column(
                children: [
                  // Logotipo
                  Container(
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      border: const Border(
                        top: BorderSide(color: Colors.black, width: 2),
                        left: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'images/logo_inkger_2.png',
                        width: 250,
                        height: 150,
                      ),
                    ),
                  ),
                  // Sidebar
                  Expanded(
                    child: Sidebar(
                      onItemSelected: (selectedItem) {
                        if (selectedItem == 'Tests') {
                          context.go('/tests');
                        } else if (selectedItem == 'Home') {
                          context.go('/home');
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra superior
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.menu, color: Colors.white),
                        onPressed: _toggleSidebar,
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
                              prefixIcon: Icon(Icons.search, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      const ImportIconButton(
                        iconSize: 32,
                        iconColor: Colors.green,
                        tooltipText: 'Subir documentos',
                        showBadge: true,
                      ),
                      // Avatar
                      PopupMenuButton<String>(
                        icon: const CircleAvatar(
                          backgroundImage: AssetImage('images/avatars/avatar_01.png'),
                          radius: 30,
                        ),
                        onSelected: (String value) {
                          switch (value) {
                            case 'profile':
                              print('Perfil seleccionado');
                              break;
                            case 'settings':
                              print('Configuración seleccionada');
                              break;
                            case 'logout':
                              print('Cerrar sesión seleccionado');
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
                ),
                // Área de contenido dinámico
                Expanded(
                  child: Container(
                    color: Colors.lightGreen,
                    child: widget.content, // Contenido inyectado por el router
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}