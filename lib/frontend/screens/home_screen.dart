import 'package:flutter/material.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/buttons/import_button.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/central_content.dart';
import 'package:inkger/frontend/widgets/side_bar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSidebarVisible =
      true; // Estado para controlar la visibilidad de la barra lateral

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible; // Cambia el estado de visibilidad
    });
  }

  @override
  void initState() {
    super.initState();
    // Inicializar rutas antes de correr la app
    loadPreferences();
  }

  // Método para cargar las preferencias y actualizarlas en el provider
  Future<void> loadPreferences() async {
    await PreferenceService.initializeDirectories(); // Obtener las rutas desde el backend

    // Una vez obtenidas las rutas, actualizamos el provider
    final preferencesProvider = Provider.of<PreferencesProvider>(context, listen: false);
    preferencesProvider.refreshPathsFromDatabase(); // Actualizamos las rutas en el provider
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Primera columna: Logotipo y Sidebar (con animación)
          AnimatedContainer(
            duration: Duration(milliseconds: 300), // Duración de la animación
            width:
                _isSidebarVisible ? 250 : 0, // Ancho fijo cuando está visible
            child: Visibility(
              // Envuelve todo en Visibility
              visible: _isSidebarVisible,
              child: Column(
                children: [
                  // Logotipo
                  Container(
                    height: 100, // Altura del logotipo
                    decoration: BoxDecoration(
                      color: Colors.blueGrey, // Color de fondo
                      border: Border(
                        top: BorderSide(
                          color: Colors.black, // Color del borde superior
                          width: 2, // Grosor del borde superior
                        ),
                        left: BorderSide(
                          color: Colors.black, // Color del borde inferior
                          width: 2, // Grosor del borde inferior
                        ),
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'images/logo_inkger_2.png', // Ruta de la imagen del logotipo
                        width: 250,
                        height: 150,
                      ),
                    ),
                  ),
                  // Sidebar
                  Expanded(
                    child: Sidebar(
                      onItemSelected: (selectedItem) {
                        print('Opción seleccionada: $selectedItem');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Segunda columna: Barra de búsqueda, Avatar y Contenido principal
          Expanded(
            child: Column(
              children: [
                // Fila superior: Barra de búsqueda y Avatar
                Container(
                  height: 100, // Altura de la fila superior
                  decoration: BoxDecoration(
                    color: Colors.blueGrey, // Color de fondo
                    border: Border.all(
                      color: Colors.black, // Color del borde
                      width: 2, // Grosor del borde
                    ),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ), // Espaciado horizontal
                  child: Row(
                    children: [
                      // Ícono para mostrar/ocultar la barra lateral
                      IconButton(
                        icon: Icon(
                          Icons.menu,
                          color: Colors.white,
                        ), // Ícono de tres rayas
                        onPressed:
                            _toggleSidebar, // Cambia la visibilidad de la barra lateral
                      ),
                      SizedBox(
                        width: 10,
                      ), // Espacio entre el ícono y la barra de búsqueda
                      // Barra de búsqueda
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey, // Color de fondo del contenedor
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Bordes redondeados
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(
                                  0.3,
                                ), // Color de la sombra
                                spreadRadius: 2, // Extensión de la sombra
                                blurRadius: 5, // Difuminado de la sombra
                                offset: Offset(
                                  0,
                                  3,
                                ), // Desplazamiento de la sombra (x, y)
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              border:
                                  InputBorder
                                      .none, // Quita el borde interno del TextField
                              filled: true,
                              fillColor: Colors.white.withOpacity(
                                0.3,
                              ), // Color de fondo del TextField
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ), // Espacio entre la barra de búsqueda y el avatar
                      ImportIconButton(
                        iconSize: 32,
                        iconColor: Colors.green,
                        tooltipText: 'Subir documentos',
                        showBadge: true,
                      ),
                      // Avatar y menú desplegable del usuario
                      PopupMenuButton<String>( 
                        icon: CircleAvatar(
                          backgroundImage: AssetImage(
                            'images/avatars/avatar_01.png',
                          ), // Ruta de la imagen del avatar
                          radius: 30,
                        ),
                        onSelected: (String value) {
                          // Acciones al seleccionar una opción del menú
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
                            PopupMenuItem(
                              value: 'profile',
                              child: Row(
                                children: [
                                  Icon(Icons.person, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('Perfil'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'settings',
                              child: Row(
                                children: [
                                  Icon(Icons.settings, color: Colors.black),
                                  SizedBox(width: 8),
                                  Text('Configuración'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
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
                // Contenido principal
                Expanded(
                  child: Container(
                    color: Colors.lightGreen,
                    child: CentralContent(),
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
