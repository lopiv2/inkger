import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/screens/home_screen.dart';
import 'package:inkger/frontend/screens/login_screen.dart';
import 'package:inkger/frontend/widgets/book_grid.dart';
import 'package:inkger/frontend/widgets/central_content.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
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
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: BooksGrid(),
                ),
          ),
          GoRoute(
            path: '/audiobooks', // Use root path for the default home
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: BooksGrid(),
                ),
          ),
          GoRoute(
            path: '/books', // Use root path for the default home
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: BooksGrid(),
                ),
          ),
          GoRoute(
            path: '/comics', // Use root path for the default home
            pageBuilder:
                (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: BooksGrid(),
                ),
          ),
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
