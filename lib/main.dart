import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:inkger/backend/services/api_service.dart';
import 'package:inkger/frontend/utils/app_router.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/utils/book_filter_provider.dart';
import 'package:inkger/frontend/utils/book_provider.dart';
import 'package:inkger/frontend/utils/comic_filter_provider.dart';
import 'package:inkger/frontend/utils/comic_provider.dart';
import 'package:inkger/frontend/utils/event_provider.dart';
import 'package:inkger/frontend/utils/feeds_provider.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/utils/reading_list_provider.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();
  // Crea una ÚNICA instancia de AuthProvider
  final authProvider = AuthProvider();

  // Intenta el auto-login antes de iniciar la app
  final isLoggedIn = await authProvider.autoLogin();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: authProvider,
        ), // Usa la misma instancia
        ChangeNotifierProvider(create: (context) => PreferencesProvider()),
        ChangeNotifierProvider(create: (context) => BooksProvider()),
        ChangeNotifierProvider(create: (context) => ComicsProvider()),
        ChangeNotifierProvider(create: (context) => BookFilterProvider()),
        ChangeNotifierProvider(create: (context) => ComicFilterProvider()),
        ChangeNotifierProvider(create: (context) => FeedsProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => ReadingListProvider()),
      ],
      child: MyApp(isInitiallyLoggedIn: isLoggedIn), // Pasa el estado inicial
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isInitiallyLoggedIn;

  const MyApp({super.key, required this.isInitiallyLoggedIn});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _appRouter = AppRouter(authProvider);

    // Redirige si ya está autenticado
    if (widget.isInitiallyLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _appRouter.router.go('/home');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ApiService.initialize(context);
    final locale = context.watch<PreferencesProvider>().locale;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Inkger - Visor y gestor de Libros y Comics',
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en'), // English
        const Locale('es'), // Spanish
      ],
      locale: locale, // <- Aquí se setea el locale dinámicamente
      routerConfig: _appRouter.router,
    );
  }
}
