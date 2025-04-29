import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/screens/calendar_screen.dart';
import 'package:inkger/frontend/screens/comic_reader_screen.dart';
import 'package:inkger/frontend/screens/dashboard_screen.dart';
import 'package:inkger/frontend/screens/epub_reader_screen.dart';
import 'package:inkger/frontend/screens/home_screen.dart';
import 'package:inkger/frontend/screens/login_screen.dart';
import 'package:inkger/frontend/screens/name_generators_screen.dart';
import 'package:inkger/frontend/screens/preferences_screen.dart';
import 'package:inkger/frontend/screens/series_detail_screen.dart';
import 'package:inkger/frontend/screens/series_screen.dart';
import 'package:inkger/frontend/screens/writer_welcome_screen.dart';
import 'package:inkger/frontend/utils/user_profile_loader.dart';
import 'package:inkger/frontend/widgets/book_grid.dart';
import 'package:inkger/frontend/widgets/central_content.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/widgets/comic_grid.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter(this.authProvider);

  late final router = GoRouter(
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuth = authProvider.isAuthenticated;
      final isLoginRoute = state.uri.path == '/login';
      if (!isAuth && !isLoginRoute) return '/login';
      if (isAuth && isLoginRoute) return '/home';

      return null;
    },
    routes: [
      // Ruta de login (pantalla completa)
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: LoginScreen()),
      ),

      // Layout principal con sidebar (shell route)
      ShellRoute(
        builder: (context, state, child) {
          return HomeScreen(content: child);
        },
        routes: [
          GoRoute(
            path: '/home', // Use root path for the default home
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: DashboardScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 1000),
              );
            },
          ),
          GoRoute(
            path: '/books', // Use root path for the default home
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: BooksGrid(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      // Animación de deslizamiento desde la derecha
                      const begin = Offset(
                        1.0,
                        0.0,
                      ); // Comienza fuera de la pantalla a la derecha
                      const end = Offset.zero; // Llega al centro de la pantalla
                      const curve = Curves.easeInOut;

                      var tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 1000),
              );
            },
          ),
          GoRoute(
            path: '/series',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child:
                    SeriesScreen(), // Suponiendo que tienes una vista llamada SeriesGrid
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      // Animación de transición combinando Slide y Scale
                      var tween =
                          Tween<Offset>(
                            begin: const Offset(0, 1), // Comienza desde abajo
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            ),
                          );

                      // Aquí puedes agregar un ScaleTransition para hacerlo más interesante
                      return SlideTransition(
                        position: tween,
                        child: ScaleTransition(
                          scale: animation.drive(
                            Tween<double>(begin: 0.8, end: 1.0),
                          ),
                          child: child,
                        ),
                      );
                    },
                transitionDuration: const Duration(
                  milliseconds: 1200,
                ), // Transición más suave
              );
            },
            routes: [
              GoRoute(
                path: ':seriesId', // Usamos el título como ID
                pageBuilder: (context, state) {
                  final seriesTitle = state.pathParameters['seriesId']!;
                  final coverPath =
                      state.extra as String; // Pasamos la coverPath como extra
                  return NoTransitionPage(
                    key: state.pageKey,
                    child: SeriesDetailScreen(
                      seriesTitle: seriesTitle,
                      coverPath: coverPath,
                    ),
                  );
                },
              ),
            ],
          ),
          // Ruta de perfil de usuario (pantalla completa)
          GoRoute(
            path: '/user-profile',
            pageBuilder: (context, state) =>
                MaterialPage(key: state.pageKey, child: UserProfileLoader()),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: CalendarScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Empieza desde abajo
                      const end = Offset.zero; // Termina en su posición normal
                      const curve = Curves.easeInOut; // Curva de animación

                      final tween = Tween(
                        begin: begin,
                        end: end,
                      ).chain(CurveTween(curve: curve));
                      final offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 800),
              );
            },
          ),
          GoRoute(
            path: '/home-writer', // Use root path for the default home
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: WriterWelcomeScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent:
                              animation, // Usa el animation proporcionado por GoRouter
                          curve: Curves.fastOutSlowIn,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 1000),
              );
            },
          ),
          GoRoute(
            path:
                '/home-writer/generators', // Use root path for the default home
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: NameGeneratorsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return ScaleTransition(
                        scale: CurvedAnimation(
                          parent:
                              animation, // Usa el animation proporcionado por GoRouter
                          curve: Curves.bounceInOut,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 1000),
              );
            },
          ),
          GoRoute(
            path: '/comic-reader/:comicId', // Parámetro obligatorio
            name: 'comic-reader', // Nombre opcional para navegación con nombre
            pageBuilder: (context, state) {
              // Extraer parámetros de la ruta
              final comicId = state.pathParameters['comicId']!;

              // Extraer datos complejos del objeto 'extra'
              final args = state.extra as Map<String, dynamic>? ?? {};

              return NoTransitionPage(
                key: state.pageKey,
                child: CustomReaderComic(
                  cbzBytes: args['epubBytes'],
                  comicTitle: args['bookTitle'],
                  initialProgress: args['initialProgress'] ?? 0,
                  comicId: int.parse(comicId), // Convertir a int
                ),
              );
            },
          ),
          GoRoute(
            path: '/ebook-reader/:bookId', // Parámetro obligatorio
            name: 'ebook-reader', // Nombre opcional para navegación con nombre
            pageBuilder: (context, state) {
              // Extraer parámetros de la ruta
              final bookId = state.pathParameters['bookId']!;

              // Extraer datos complejos del objeto 'extra'
              final args = state.extra as Map<String, dynamic>? ?? {};

              return NoTransitionPage(
                key: state.pageKey,
                child: CustomReaderEpub(
                  epubBytes: args['epubBytes'],
                  bookTitle: args['bookTitle'],
                  initialProgress: args['initialProgress'] ?? 0,
                  bookId: int.parse(bookId), // Convertir a int
                ),
              );
            },
          ),
          GoRoute(
            path: '/audiobooks', // Use root path for the default home
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: BooksGrid()),
          ),
          GoRoute(
            path: '/settings', // Use root path for the default home
            pageBuilder: (context, state) => NoTransitionPage(
              key: state.pageKey,
              child: PreferencesScreen(),
            ),
          ),
          GoRoute(
            path: '/comics',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ComicsGrid(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        ),
                        child: child,
                      );
                    },
                transitionDuration: const Duration(milliseconds: 2000),
              );
            },
          ),
          GoRoute(
            path: '/tests',
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: CentralContent()),
          ),
        ],
      ),
    ],
  );
}
