import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/screens/comic_reader_screen.dart';
import 'package:inkger/frontend/screens/epub_reader_screen.dart';
import 'package:inkger/frontend/screens/home_screen.dart';
import 'package:inkger/frontend/screens/login_screen.dart';
import 'package:inkger/frontend/screens/writer_welcome_screen.dart';
import 'package:inkger/frontend/widgets/book_grid.dart';
import 'package:inkger/frontend/widgets/central_content.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/widgets/comic_grid.dart';
import 'package:inkger/frontend/widgets/test/transform_controller.dart';

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
        pageBuilder:
            (context, state) =>
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
                child: BooksGrid(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
            path: '/home-writer', // Use root path for the default home
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: WriterWelcomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(key: state.pageKey, child: BooksGrid()),
          ),
          GoRoute(
            path: '/books', // Use root path for the default home
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(key: state.pageKey, child: BooksGrid()),
          ),
          GoRoute(
            path: '/comics',
            pageBuilder: (context, state) {
              return CustomTransitionPage(
                key: state.pageKey,
                child: ComicsGrid(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOut,
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 3000),
              );
            },
          ),
          /*GoRoute(
            path: '/comics', // Use root path for the default home
            pageBuilder:
                (context, state) =>
                    NoTransitionPage(key: state.pageKey, child: ComicsGrid()),
          ),*/
          GoRoute(
            path: '/tests',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: CentralContent(),
                ),
          ),
        ],
      ),
    ],
  );
}
