import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:inkger/backend/services/preferences_service.dart';
import 'package:inkger/frontend/screens/home_screen.dart';
import 'package:inkger/frontend/screens/login_screen.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:intl/intl.dart' as intl;
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PreferencesProvider()),
        // Otros providers...
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    //intl.Intl.defaultLocale = preferences.locale.toLanguageTag();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inkger - Visor y gestor de Libros y Comics',
      localizationsDelegates: [
        AppLocalizations.delegate, // Add this line
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
      routes: {
        '/home': (context) => HomeScreen(), // A implementar
      },
    );
  }
}
