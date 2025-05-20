import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Asegúrate de tener este paquete
import 'package:inkger/frontend/models/app_preferences.dart';
import 'package:inkger/frontend/services/common_services.dart';
import 'package:inkger/frontend/utils/preferences_provider.dart';
import 'package:inkger/frontend/widgets/custom_snackbar.dart';
import 'package:inkger/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _backgroundImageController =
      TextEditingController();

  double sliderItemSizeValue = 5;
  double sliderScanIntervalValue = 1;
  Color themeColor = Colors.blue; // 🎨 Nuevo campo para color
  String hexColor = "#000000";
  String languageCode = "es";

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      final rawValue = prefs.get("defaultGridItemSize");
      final rawValueScan = prefs.get("scanInterval");
      final rawThemeColor = prefs.get("themeColor");
      int colorIntTheme;

      if (rawValue is double) {
        sliderItemSizeValue = rawValue;
      } else if (rawValue is String) {
        sliderItemSizeValue = double.tryParse(rawValue) ?? 7.0;
      } else {
        sliderItemSizeValue = 7.0;
      }
      if (rawValueScan is double) {
        sliderScanIntervalValue = rawValueScan;
      } else if (rawValueScan is String) {
        sliderScanIntervalValue = double.tryParse(rawValueScan) ?? 5.0;
      } else {
        sliderScanIntervalValue = 5.0;
      }
      if (rawThemeColor is String) {
        // Intenta convertir la cadena en un entero.
        colorIntTheme =
            int.tryParse(rawThemeColor) ??
            Colors.blue.value; // Valor por defecto si la conversión falla
      } else if (rawThemeColor is int) {
        // Si ya es un entero, no hace falta convertirlo, solo asignarlo
        colorIntTheme = rawThemeColor;
      } else {
        colorIntTheme =
            Colors.blue.value; // Valor por defecto si no es ni String ni int
      }

      _apiKeyController.text = prefs.getString("Comicvine Key") ?? '';
      _backgroundImageController.text =
          prefs.getString("backgroundImagePath") ?? '';
      themeColor = Color(colorIntTheme);
      languageCode = prefs.getString("languageCode") ?? "es";
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("id");

    final settings = [
      {
        'userId': userId,
        'key': 'Comicvine Key',
        'value': _apiKeyController.text.trim(),
      },
      {
        'userId': userId,
        'key': 'defaultGridItemSize',
        'value': sliderItemSizeValue.toString(),
      },
      {
        'userId': userId,
        'key': 'backgroundImagePath',
        'value': _backgroundImageController.text.trim(),
      },
      {
        'userId': userId,
        'key': 'themeColor',
        'value': themeColor.value.toString(),
      },
      {
        'userId': userId,
        'key': 'scanInterval',
        'value': sliderScanIntervalValue.toString(),
      },
      {
        'userId': userId,
        'key': 'languageCode',
        'value': languageCode.toString(),
      },
    ];

    final res = await CommonServices.saveMultipleSettingsToSharedPrefs(
      prefs,
      settings,
    );

    final newPrefs = AppPreferences(
      comicvineApiKey: _apiKeyController.text.trim(),
      defaultGridItemSize: sliderItemSizeValue,
      backgroundImagePath: _backgroundImageController.text.trim(),
      themeColor: themeColor.value,
      darkMode: false,
      languageCode: languageCode,
      textScaleFactor: 2,
      notificationsEnabled: true,
      fullScreenMode: false,
      readerMode: false,
      scanInterval: sliderScanIntervalValue,
    );

    // ignore: use_build_context_synchronously
    final prefsProvider = context.read<PreferencesProvider>();
    await prefsProvider.updatePreferences(newPrefs);

    if (res.statusCode == 200 && context.mounted) {
      CustomSnackBar.show(
        // ignore: use_build_context_synchronously
        context,
        // ignore: use_build_context_synchronously
        AppLocalizations.of(context)!.preferencesSaved,
        Colors.green,
        duration: const Duration(seconds: 4),
      );
    }
  }

  void _pickThemeColor() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar color de tema'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: themeColor,
              onColorChanged: (color) => setState(() {
                themeColor = color;
                //hexColor = colorToHex(color);
              }),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefsProvider = context.watch<PreferencesProvider>();

    if (prefsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tamaño de elementos en la parrilla",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: sliderItemSizeValue,
                      min: 5,
                      max: 10,
                      divisions: 5,
                      label: sliderItemSizeValue.round().toString(),
                      onChanged: (value) =>
                          setState(() => sliderItemSizeValue = value),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Frecuencia de escaneo de archivos nuevos (en minutos)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: sliderScanIntervalValue,
                      min: 1,
                      max: 15,
                      divisions: 15,
                      label: sliderScanIntervalValue.round().toString(),
                      onChanged: (value) =>
                          setState(() => sliderScanIntervalValue = value),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Comicvine API Key',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _backgroundImageController,
                      decoration: const InputDecoration(
                        labelText: 'Ruta de imagen de fondo',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Color de tema: "),
                        GestureDetector(
                          onTap: _pickThemeColor,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: themeColor,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              themeColor = Colors.blueGrey;
                              //hexColor = colorToHex(themeColor);
                            });
                          },
                          child: const Text("Color por defecto"),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text("Idioma: "),
                        DropdownButton<String>(
                          value: languageCode,
                          items: const [
                            DropdownMenuItem(
                              value: "es",
                              child: Text("Español"),
                            ),
                            DropdownMenuItem(
                              value: "en",
                              child: Text("English"),
                            ),
                            DropdownMenuItem(
                              value: "fr",
                              child: Text("Français"),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                languageCode = value;
                              });
                              // Cambia el locale en el provider
                              context.read<PreferencesProvider>().setLocale(
                                value,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar'),
                      onPressed: _savePreferences,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Container(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}
