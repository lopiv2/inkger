import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/screens/top_bar.dart';
import 'package:inkger/frontend/screens/top_bar_logo.dart';
import 'package:inkger/frontend/services/common_services.dart';
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
  bool isSidebarVisible = true;
  bool isLoading = true;
  String? errorMessage;

  void toggleSidebar() {
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
    // ignore: unused_local_variable
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

  @override
  Widget build(BuildContext context) {
    final preferences = Provider.of<PreferencesProvider>(context);
    final isFullScreen = preferences.preferences.fullScreenMode;
    final isReaderMode = preferences.preferences.readerMode;
    late Color themeColor = Colors.blueGrey;
    themeColor = Color(preferences.preferences.themeColor);

    return Scaffold(
      body: Row(
        children: [
          // Sidebar con animación
          if (!isFullScreen)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSidebarVisible ? 250 : 0,
              decoration: const BoxDecoration(), // <- solución
              clipBehavior: Clip.hardEdge, // <-- evita que el contenido sobresalga al encoger
              child: isSidebarVisible ? Column(
                children: [
                  // Logotipo
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axis: Axis.horizontal,
                              child: child,
                            ),
                          );
                        },
                    child: !isReaderMode
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
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                axis: Axis.horizontal,
                                child: child,
                              ),
                            );
                          },
                      child: !isReaderMode
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
                      color: preferences.preferences.readerMode == false
                          ? themeColor
                          : Colors.grey[850],
                      border: Border(
                        bottom: BorderSide(
                          color: preferences.preferences.readerMode == false
                              ? Colors.black
                              : Colors.grey[700]!,
                          width: 2,
                        ),
                        right: BorderSide(
                          color: preferences.preferences.readerMode == false
                              ? Colors.black
                              : Colors.grey[700]!,
                          width: 2,
                        ),
                        left: BorderSide(
                          color: preferences.preferences.readerMode == false
                              ? Colors.black
                              : Colors.grey[700]!,
                          width: 2,
                        ),
                      ),
                    ),
                    child: preferences.isLoading
                        ? const CircularProgressIndicator()
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Version 1.0", style: TextStyle(color: Colors.white),),
                          ],
                        )
                  ),
                ],
              ) : const SizedBox.shrink(),
            ),
          // Contenido principal
          Expanded(
            child: Column(
              children: [
                // Barra superior
                if (!isFullScreen)
                  AnimatedSwitcher(
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
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
                    child: !isReaderMode
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
