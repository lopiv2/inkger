import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/buttons/import_button.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/side_bar_reader.dart';
import 'package:inkger/frontend/widgets/side_bar_writer.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final Widget content; // Recibirá el contenido dinámico desde el router

  const HomeScreen({super.key, required this.content});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarVisible = true;
  bool isLoading = true;
  String? errorMessage;

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
    final response = await CommonServices.loadSettingsToSharedPrefs();
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await PreferenceService.initializeDirectories();
      final preferencesProvider = Provider.of<PreferencesProvider>(
        context,
        listen: false,
      );
      await preferencesProvider.loadFromSharedPrefs();
      await preferencesProvider.refreshPathsFromDatabase();
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _logout() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesProvider>(context);
    final isFullScreen = preferences.preferences.fullScreenMode;
    final isReaderMode = preferences.preferences.readerMode;

    return Scaffold(
      body: Row(
        children: [
          // Sidebar con animación
          if (!isFullScreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _isSidebarVisible ? 250 : 0,
              child: Visibility(
                visible: _isSidebarVisible && !isFullScreen,
                child: Column(
                  children: [
                    // Logotipo
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) {
                        return FadeTransition(
                          opacity: animation,
                          child: SizeTransition(
                            sizeFactor: animation,
                            axis: Axis.horizontal,
                            child: child,
                          ),
                        );
                      },
                      child:
                          !isReaderMode
                              ? TopBarLogo(
                                backGroundColor: Colors.blueGrey,
                                borderColor: Colors.black,
                                imagePath: 'images/logo_inkger.png',
                              )
                              : TopBarLogo(
                                backGroundColor: Colors.grey[850],
                                borderColor: Colors.grey[700]!,
                                imagePath: 'images/logo_inkger_white.png',
                              ),
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeInOut,
                        switchOutCurve: Curves.easeInOut,
                        transitionBuilder: (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              child: child,
                            ),
                          );
                        },
                        child:
                            !isReaderMode
                                // Sidebar
                                ? Sidebar(
                                  onItemSelected: (selectedItem) {
                                    if (selectedItem == 'Tests') {
                                      context.go('/tests');
                                    } else if (selectedItem == 'Home') {
                                      context.go('/home');
                                    }
                                  },
                                )
                                : SidebarWriter(
                                  onItemSelected: (selectedItem) {
                                    if (selectedItem == 'Tests') {
                                      context.go('/tests');
                                    } else if (selectedItem == 'Home') {
                                      context.go('/home');
                                    }
                                  },
                                ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color:
                            preferences.preferences.readerMode == false
                                ? Colors.blueGrey
                                : Colors.grey[850],
                        border: Border(
                          bottom: BorderSide(
                            color:
                                preferences.preferences.readerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                            width: 2,
                          ),
                          right: BorderSide(
                            color:
                                preferences.preferences.readerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                            width: 2,
                          ),
                          left: BorderSide(
                            color:
                                preferences.preferences.readerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                            width: 2,
                          ),
                        ),
                      ),
                      child:
                          preferences.isLoading
                              ? const CircularProgressIndicator()
                              : AnimatedToggleSwitch<bool>.dual(
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
                                styleBuilder:
                                    (b) => ToggleStyle(
                                      indicatorColor:
                                          b ? Colors.red : Colors.green,
                                    ),
                                iconBuilder:
                                    (value) =>
                                        value
                                            ? const Icon(Icons.history_edu)
                                            : const Icon(Icons.library_books),
                                textBuilder:
                                    (value) =>
                                        value
                                            ? const Center(
                                              child: Text('Writer'),
                                            )
                                            : const Center(
                                              child: Text('Reader'),
                                            ),
                                onChanged: (b) {
                                  preferences.toggleFullReaderMode(
                                    b,
                                  ); // ya no necesitas comparar
                                  context.go(b ? '/home-writer' : '/home');
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
                if (!isFullScreen)
                  AnimatedSwitcher(
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                          sizeFactor: animation,
                          axis: Axis.horizontal,
                          child: child,
                        ),
                      );
                    },
                    duration: Duration(milliseconds: 300),
                    child:
                        !isReaderMode
                            ? TopBar(
                              backGroundColor: Colors.blueGrey,
                              borderColor: Colors.black,
                            )
                            : TopBar(
                              backGroundColor: Colors.grey[850],
                              borderColor: Colors.grey[700],
                            ),
                  ),
                // Área de contenido dinámico
                Expanded(
                  child: Container(
                    color: Colors.blueGrey,
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

  Widget TopBarLogo({
    required backGroundColor,
    required borderColor,
    required imagePath,
  }) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backGroundColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 2),
          left: BorderSide(color: borderColor, width: 2),
        ),
      ),
      child: Center(child: Image.asset(imagePath, width: 250, height: 150)),
    );
  }

  Widget TopBar({required backGroundColor, required borderColor}) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: backGroundColor,
        border: Border.all(color: borderColor, width: 2),
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
            showBadge: true,
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
                  _logout();
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
