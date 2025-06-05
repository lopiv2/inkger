import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:inkger/frontend/widgets/custom_svg_loader.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:inkger/frontend/dialogs/create_user_dialog.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late String _currentQuote;
  bool _isLoading = false;
  FocusNode _passwordFocusNode = FocusNode();

  // Lista con todas las claves para las frases
  final List<String> _quoteKeys = List.generate(
    40,
    (index) => 'quote_${index + 1}',
  );

  Future<void> _login() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      Constants.logger.warning(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    //_setRandomQuote(); // Inicializar al iniciar la pantalla
  }

  void _setRandomQuote() {
    final loc = AppLocalizations.of(context)!;
    final quotesMap = {
      for (var key in _quoteKeys) key: _getQuoteByKeyFromLoc(loc, key),
    };

    final randomQuoteKey = _quoteKeys[Random().nextInt(_quoteKeys.length)];
    setState(() {
      _currentQuote = quotesMap[randomQuoteKey] ?? loc.quote_1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    _setRandomQuote();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Fondo con imagen
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/login_back.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Contenido con fondo
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                width: width * 0.6,
                height: MediaQuery.of(context).size.height * 1,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/Book_02.png'),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 40,
                ),
                child: SizedBox(
                  width: width > 800 ? 500 : double.infinity,
                  child: FocusTraversalGroup(
                    policy: WidgetOrderTraversalPolicy(),
                    child: Row(
                      children: [
                        // Columna izquierda: logo + frase
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(120, 20, 20, 300),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/images/logo_inkger.png',
                                  height: 300,
                                ),
                                const SizedBox(height: 24),
                                FocusTraversalOrder(
                                  order: NumericFocusOrder(3),
                                  child: Text(
                                    _currentQuote,
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  icon: const Icon(Icons.casino),
                                  tooltip: 'Cita aleatoria',
                                  onPressed: () {
                                    _setRandomQuote();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    
                        const SizedBox(width: 40),
                    
                        // Columna derecha: login
                        Expanded(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 80),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  loc.loginAccount,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 350,
                                        ),
                                        child: FocusTraversalOrder(
                                          order: NumericFocusOrder(1),
                                          child: TextFormField(
                                            controller: _usernameController,
                                            decoration: InputDecoration(
                                              labelText: loc.user,
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.person),
                                            ),
                                            textInputAction: TextInputAction.next,
                                            onFieldSubmitted: (_) => FocusScope.of(
                                              context,
                                            ).requestFocus(_passwordFocusNode),
                                            validator: (value) =>
                                                value == null || value.isEmpty
                                                ? 'Por favor ingrese su usuario'
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      FocusTraversalOrder(
                                        order: NumericFocusOrder(2),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 350,
                                          ),
                                          child: TextFormField(
                                            controller: _passwordController,
                                            focusNode: _passwordFocusNode,
                                            decoration: InputDecoration(
                                              labelText: loc.password,
                                              border: OutlineInputBorder(),
                                              prefixIcon: Icon(Icons.lock),
                                            ),
                                            obscureText: true,
                                            textInputAction: TextInputAction.go,
                                            onFieldSubmitted: (_) => _login(),
                                            validator: (value) =>
                                                value == null || value.isEmpty
                                                ? 'Por favor ingrese su contraseña'
                                                : null,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 30),
                                      _isLoading
                                          ? const CustomLoader(
                                              size: 60.0,
                                              color: Colors.blue,
                                            )
                                          : ElevatedButton(
                                              onPressed: _login,
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 40,
                                                      vertical: 15,
                                                    ),
                                                backgroundColor:
                                                    Colors.deepPurple,
                                              ),
                                              child: Text(
                                                loc.startSession,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(height: 20),
                                      ElevatedButton(
                                        onPressed: () => showDialog(
                                          context: context,
                                          builder: (context) => CreateUserDialog(),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 40,
                                            vertical: 15,
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                        child: Text(
                                          loc.createUser,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Método auxiliar para obtener la frase según la key en loc
  String _getQuoteByKeyFromLoc(AppLocalizations loc, String key) {
    switch (key) {
      case 'quote_1':
        return loc.quote_1;
      case 'quote_2':
        return loc.quote_2;
      case 'quote_3':
        return loc.quote_3;
      case 'quote_4':
        return loc.quote_4;
      case 'quote_5':
        return loc.quote_5;
      case 'quote_6':
        return loc.quote_6;
      case 'quote_7':
        return loc.quote_7;
      case 'quote_8':
        return loc.quote_8;
      case 'quote_9':
        return loc.quote_9;
      case 'quote_10':
        return loc.quote_10;
      case 'quote_11':
        return loc.quote_11;
      case 'quote_12':
        return loc.quote_12;
      case 'quote_13':
        return loc.quote_13;
      case 'quote_14':
        return loc.quote_14;
      case 'quote_15':
        return loc.quote_15;
      case 'quote_16':
        return loc.quote_16;
      case 'quote_17':
        return loc.quote_17;
      case 'quote_18':
        return loc.quote_18;
      case 'quote_19':
        return loc.quote_19;
      case 'quote_20':
        return loc.quote_20;
      case 'quote_21':
        return loc.quote_21;
      case 'quote_22':
        return loc.quote_22;
      case 'quote_23':
        return loc.quote_23;
      case 'quote_24':
        return loc.quote_24;
      case 'quote_25':
        return loc.quote_25;
      case 'quote_26':
        return loc.quote_26;
      case 'quote_27':
        return loc.quote_27;
      case 'quote_28':
        return loc.quote_28;
      case 'quote_29':
        return loc.quote_29;
      case 'quote_30':
        return loc.quote_30;
      case 'quote_31':
        return loc.quote_31;
      case 'quote_32':
        return loc.quote_32;
      case 'quote_33':
        return loc.quote_33;
      case 'quote_34':
        return loc.quote_34;
      case 'quote_35':
        return loc.quote_35;
      case 'quote_36':
        return loc.quote_36;
      case 'quote_37':
        return loc.quote_37;
      case 'quote_38':
        return loc.quote_38;
      case 'quote_39':
        return loc.quote_39;
      case 'quote_40':
        return loc.quote_40;
      default:
        return loc.quote_1;
    }
  }
}
