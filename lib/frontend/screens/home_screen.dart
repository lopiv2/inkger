import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/screens/top_bar.dart';
import 'package:inkger/frontend/screens/top_bar_logo.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
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
  bool isSidebarVisible = true;
  bool isLoading = true;
  String? errorMessage;

  void toggleSidebar() {
    if (!mounted) return;
    setState(() {
      isSidebarVisible = !isSidebarVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadPreferences();
    });
  }

  //Cargar preferencias en SharedPrefs desde API y BBDD
  Future<void> loadPreferences() async {
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

      // Cargar preferencias desde la API y sincronizar con SharedPreferences
      await preferencesProvider.loadFromApiAndSync();

      // Refrescar rutas desde la base de datos
      await preferencesProvider.refreshPathsFromDatabase();
    } catch (e, stackTrace) {
      print('Error al cargar preferencias: $e');
      print(stackTrace);
      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesProvider>(context);
    final iswriterMode = preferences.preferences.writerMode;

    // Asegurarse de que el valor de iswriterMode esté sincronizado
    if (isLoading) {
      return const Center(
        child: CustomLoader(),
      );
    }
    late Color themeColor = Colors.blueGrey;
    themeColor = Color(preferences.preferences.themeColor);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar con animación
          if (!preferences.preferences.fullScreenMode)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSidebarVisible ? 250 : 0,
              decoration: const BoxDecoration(),
              clipBehavior: Clip.hardEdge,
              child: isSidebarVisible
                  ? Column(
                      children: [
                        // Logotipo
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: !iswriterMode
                              ? TopBarLogo(
                                  backGroundColor: themeColor,
                                  borderColor: Colors.black,
                                  imagePath: 'images/logo_inkger.png',
                                )
                              : TopBarLogo(
                                  backGroundColor: Colors.grey[850]!,
                                  borderColor: Colors.grey[700]!,
                                  imagePath: 'images/logo_inkger_white.png',
                                ),
                        ),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: !iswriterMode
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
                          padding: const EdgeInsets.all(10),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: preferences.preferences.writerMode == false
                                ? themeColor
                                : Colors.grey[850],
                            border: Border(
                              bottom: BorderSide(
                                color: preferences.preferences.writerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                                width: 2,
                              ),
                              right: BorderSide(
                                color: preferences.preferences.writerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                                width: 2,
                              ),
                              left: BorderSide(
                                color: preferences.preferences.writerMode == false
                                    ? Colors.black
                                    : Colors.grey[700]!,
                                width: 2,
                              ),
                            ),
                          ),
                          child: preferences.isLoading
                              ? const CustomLoader(size: 60.0, color: Colors.blue)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        context.go('/versions');
                                      },
                                      child: const Text(
                                        "Version 1.0",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    )
                                  ],
                                ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra superior
                if (!preferences.preferences.fullScreenMode)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: !iswriterMode
                        ? TopBar(
                            backGroundColor: themeColor,
                            borderColor: Colors.black,
                            isSidebarVisible: isSidebarVisible,
                            onToggleSidebar: toggleSidebar,
                          )
                        : TopBar(
                            backGroundColor: Colors.grey[850]!,
                            borderColor: Colors.grey[700]!,
                            isSidebarVisible: isSidebarVisible,
                            onToggleSidebar: toggleSidebar,
                          ),
                  ),
                // Área de contenido dinámico
                Expanded(
                  child: Container(color: themeColor, child: widget.content),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
